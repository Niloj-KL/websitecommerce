from fastapi import FastAPI, HTTPException, Header, UploadFile, File, Form, Request
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, Any
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import json
import os
import re
import shutil
import secrets
import sqlite3
import hashlib
from datetime import datetime

app = FastAPI(title="Saja Website API", version="0.3.0")
BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"
UPLOADS_DIR = STATIC_DIR / "uploads"
ADMIN_STATIC_DIR = STATIC_DIR / "admin"
ADMIN_INDEX_FILE = ADMIN_STATIC_DIR / "index.html"
DB_FILE = BASE_DIR / "store.db"
LEGACY_PRODUCTS_FILE = BASE_DIR / "products.json"
LEGACY_ORDERS_FILE = BASE_DIR / "orders.json"
LEGACY_HOMEPAGE_CONFIG_FILE = BASE_DIR / "homepage_config.json"
ADMIN_USERNAME = os.environ.get("ADMIN_USERNAME", "admin")
ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "admin123")
ADMIN_SESSION_TTL_HOURS = 12
USER_SESSION_TTL_HOURS = 24 * 14
STATIC_DIR.mkdir(parents=True, exist_ok=True)
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
ADMIN_STATIC_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")

# DEV CORS ONLY
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # DEV ONLY
    allow_credentials=False,  # must be False with "*"
    allow_methods=["*"],
    allow_headers=["*"],
)

DEFAULT_PRODUCTS = [
    {
        "id": "p1",
        "slug": "cotton-tee-1",
        "title": "Cotton Tee - Model 1",
        "priceLkr": 4990,
        "compareAtPriceLkr": 5990,
        "imageUrls": [],
        "sizes": ["S", "M", "L", "XL"],
        "inStock": True,
        "collection": "tshirts",
        "description": "Soft and breathable cotton tee for everyday wear.",
    },
    {
        "id": "p2",
        "slug": "cotton-tee-2",
        "title": "Cotton Tee - Model 2",
        "priceLkr": 5250,
        "compareAtPriceLkr": None,
        "imageUrls": [],
        "sizes": ["S", "M", "L", "XL"],
        "inStock": True,
        "collection": "tshirts",
        "description": "Comfort-fit cotton tee with a clean modern look.",
    },
    {
        "id": "p3",
        "slug": "kurti-rose-1",
        "title": "Kurti - Rose Pattern",
        "priceLkr": 7900,
        "compareAtPriceLkr": 8900,
        "imageUrls": [
            "http://localhost:8000/static/kurtis/kurta1.png",
            "http://localhost:8000/static/kurtis/krta2.png",
            "http://localhost:8000/static/kurtis/krta3.png",
            "http://localhost:8000/static/kurtis/krta4.png",
            "http://localhost:8000/static/kurtis/krta5.png",
        ],
        "sizes": ["S", "M", "L", "XL"],
        "inStock": True,
        "collection": "kurtis",
        "description": "Elegant rose-pattern kurti",
    },
]

STANDARD_COLLECTIONS = [
    {"name": "Kurtis", "slug": "kurtis"},
    {"name": "T-Shirts", "slug": "tshirts"},
    {"name": "Shirts", "slug": "shirts"},
    {"name": "Dress", "slug": "dress"},
]


def _db_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn


def _json_dumps(value: Any) -> str:
    return json.dumps(value, separators=(",", ":"))


def _json_loads(value: Optional[str], fallback: Any) -> Any:
    if not value:
        return fallback
    try:
        parsed = json.loads(value)
        return parsed
    except json.JSONDecodeError:
        return fallback


def _ensure_db():
    with _db_conn() as conn:
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS products (
                id TEXT PRIMARY KEY,
                slug TEXT NOT NULL UNIQUE,
                title TEXT NOT NULL,
                price_lkr INTEGER NOT NULL,
                compare_at_price_lkr INTEGER NULL,
                image_urls TEXT NOT NULL,
                sizes TEXT NOT NULL,
                in_stock INTEGER NOT NULL,
                collection TEXT NOT NULL,
                description TEXT NOT NULL,
                created_at TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS orders (
                order_id TEXT PRIMARY KEY,
                cart_id TEXT NOT NULL,
                created_at TEXT NOT NULL,
                customer_name TEXT NULL,
                customer_email TEXT NULL,
                customer_phone TEXT NULL,
                delivery_address TEXT NULL,
                items_json TEXT NOT NULL,
                subtotal_lkr INTEGER NOT NULL,
                total_lkr INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS homepage_config (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                mode TEXT NOT NULL,
                selected_slugs TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS carts (
                cart_id TEXT PRIMARY KEY,
                items_json TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS users (
                user_id TEXT PRIMARY KEY,
                email TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL,
                full_name TEXT NOT NULL,
                phone TEXT NOT NULL,
                address TEXT NOT NULL,
                created_at TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS user_sessions (
                token TEXT PRIMARY KEY,
                user_id TEXT NOT NULL,
                created_at TEXT NOT NULL,
                expires_at TEXT NOT NULL,
                FOREIGN KEY(user_id) REFERENCES users(user_id)
            );
            """
        )
        existing_cols = conn.execute("PRAGMA table_info(orders)").fetchall()
        col_names = {row["name"] for row in existing_cols}
        if "customer_email" not in col_names:
            conn.execute("ALTER TABLE orders ADD COLUMN customer_email TEXT NULL")


def _read_legacy_json(path: Path, fallback: Any) -> Any:
    if not path.exists():
        return fallback
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        return data
    except json.JSONDecodeError:
        return fallback


def _ensure_seed_data():
    default_config = {"mode": "default", "selectedSlugs": []}
    with _db_conn() as conn:
        product_count = conn.execute("SELECT COUNT(*) AS c FROM products").fetchone()["c"]
        if product_count == 0:
            legacy_products = _read_legacy_json(LEGACY_PRODUCTS_FILE, DEFAULT_PRODUCTS)
            if not isinstance(legacy_products, list) or not legacy_products:
                legacy_products = DEFAULT_PRODUCTS
            for p in legacy_products:
                conn.execute(
                    """
                    INSERT OR IGNORE INTO products (
                        id, slug, title, price_lkr, compare_at_price_lkr,
                        image_urls, sizes, in_stock, collection, description, created_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        str(p.get("id", "")),
                        str(p.get("slug", "")),
                        str(p.get("title", "")),
                        int(p.get("priceLkr", 0)),
                        p.get("compareAtPriceLkr"),
                        _json_dumps(p.get("imageUrls", [])),
                        _json_dumps(p.get("sizes", ["S", "M", "L", "XL"])),
                        1 if p.get("inStock", True) else 0,
                        str(p.get("collection", "general")),
                        str(p.get("description", "")),
                        str(p.get("createdAt", datetime.now().isoformat(timespec="seconds"))),
                    ),
                )

        order_count = conn.execute("SELECT COUNT(*) AS c FROM orders").fetchone()["c"]
        if order_count == 0:
            legacy_orders = _read_legacy_json(LEGACY_ORDERS_FILE, [])
            if isinstance(legacy_orders, list):
                for o in legacy_orders:
                    conn.execute(
                        """
                        INSERT OR IGNORE INTO orders (
                            order_id, cart_id, created_at, customer_name, customer_email, customer_phone,
                            delivery_address, items_json, subtotal_lkr, total_lkr
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        (
                            str(o.get("orderId", "")),
                            str(o.get("cartId", "")),
                            str(o.get("createdAt", datetime.now().isoformat(timespec="seconds"))),
                            o.get("customerName"),
                            o.get("customerEmail"),
                            o.get("customerPhone"),
                            o.get("deliveryAddress"),
                            _json_dumps(o.get("items", [])),
                            int(o.get("subtotalLkr", 0)),
                            int(o.get("totalLkr", 0)),
                        ),
                    )

        config_row = conn.execute(
            "SELECT mode, selected_slugs FROM homepage_config WHERE id = 1"
        ).fetchone()
        if config_row is None:
            legacy_config = _read_legacy_json(LEGACY_HOMEPAGE_CONFIG_FILE, default_config)
            if not isinstance(legacy_config, dict):
                legacy_config = default_config
            mode = str(legacy_config.get("mode", "default")).strip().lower()
            if mode not in {"default", "custom"}:
                mode = "default"
            selected = legacy_config.get("selectedSlugs", [])
            if not isinstance(selected, list):
                selected = []
            conn.execute(
                "INSERT INTO homepage_config (id, mode, selected_slugs) VALUES (1, ?, ?)",
                (mode, _json_dumps(selected)),
            )


def _row_to_product(row: sqlite3.Row) -> dict[str, Any]:
    return {
        "id": row["id"],
        "slug": row["slug"],
        "title": row["title"],
        "priceLkr": row["price_lkr"],
        "compareAtPriceLkr": row["compare_at_price_lkr"],
        "imageUrls": _json_loads(row["image_urls"], []),
        "sizes": _json_loads(row["sizes"], ["S", "M", "L", "XL"]),
        "inStock": bool(row["in_stock"]),
        "collection": row["collection"],
        "description": row["description"],
        "createdAt": row["created_at"],
    }


def list_all_products() -> list[dict[str, Any]]:
    with _db_conn() as conn:
        rows = conn.execute(
            "SELECT * FROM products ORDER BY created_at DESC, id DESC"
        ).fetchall()
    return [_row_to_product(r) for r in rows]


def get_homepage_config() -> dict[str, Any]:
    with _db_conn() as conn:
        row = conn.execute(
            "SELECT mode, selected_slugs FROM homepage_config WHERE id = 1"
        ).fetchone()
    if row is None:
        return {"mode": "default", "selectedSlugs": []}
    return {
        "mode": row["mode"],
        "selectedSlugs": _json_loads(row["selected_slugs"], []),
    }


_ensure_db()
_ensure_seed_data()
ADMIN_SESSIONS: dict[str, datetime] = {}
LAST_DELETED_ORDER: Optional[dict[str, Any]] = None


def find_product(slug: str):
    with _db_conn() as conn:
        row = conn.execute("SELECT * FROM products WHERE slug = ?", (slug,)).fetchone()
    return _row_to_product(row) if row else None


def get_next_product_sequence() -> int:
    max_seq = 0
    with _db_conn() as conn:
        rows = conn.execute("SELECT id FROM products").fetchall()
    for row in rows:
        product_id = str(row["id"])
        if product_id.startswith("p"):
            suffix = product_id[1:]
            if suffix.isdigit():
                max_seq = max(max_seq, int(suffix))
            continue
        match = re.search(r"_(\d+)$", product_id)
        if match:
            max_seq = max(max_seq, int(match.group(1)))
    return max_seq + 1


def normalize_category_slug(category: str) -> str:
    cleaned = re.sub(r"[^a-z0-9]+", "-", category.lower()).strip("-")
    if cleaned in {"t-shirt", "t-shirts", "tee", "tees"}:
        return "tshirts"
    if cleaned in {"kurti"}:
        return "kurtis"
    return cleaned or "general"


def generate_product_id(category: str) -> str:
    category_slug = normalize_category_slug(category)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    sequence = get_next_product_sequence()
    return f"{category_slug}_{timestamp}_{sequence}"


def get_next_order_id() -> str:
    max_id_num = 0
    with _db_conn() as conn:
        rows = conn.execute("SELECT order_id FROM orders").fetchall()
    for row in rows:
        order_id = str(row["order_id"])
        if order_id.startswith("o"):
            suffix = order_id[1:]
            if suffix.isdigit():
                max_id_num = max(max_id_num, int(suffix))
    return f"o{max_id_num + 1}"


def product_order_value(product: dict[str, Any]) -> int:
    product_id = str(product.get("id", ""))
    if product_id.startswith("p"):
        suffix = product_id[1:]
        if suffix.isdigit():
            return int(suffix)
    match = re.search(r"_(\d+)$", product_id)
    if match:
        return int(match.group(1))
    return -1


def get_homepage_products() -> list[dict[str, Any]]:
    homepage_config = get_homepage_config()
    mode = homepage_config.get("mode", "default")
    selected_slugs = homepage_config.get("selectedSlugs", [])
    products = list_all_products()

    if mode == "custom" and isinstance(selected_slugs, list):
        by_slug = {p.get("slug"): p for p in products}
        picked = [by_slug[s] for s in selected_slugs if s in by_slug]
        return picked[:10]

    def sort_key(item: dict[str, Any]) -> tuple[str, int]:
        created_at = str(item.get("createdAt", ""))
        return (created_at, product_order_value(item))

    latest = sorted(products, key=sort_key, reverse=True)
    return latest[:10]


def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


def is_password_strong(password: str) -> bool:
    if len(password) < 8:
        return False
    has_alpha = any(ch.isalpha() for ch in password)
    has_digit = any(ch.isdigit() for ch in password)
    return has_alpha and has_digit


def is_valid_phone(phone: str) -> bool:
    return bool(re.fullmatch(r"\d{10}", phone))


def normalize_email(email: str) -> str:
    return email.strip().lower()


def get_user_by_email(email: str) -> Optional[dict[str, Any]]:
    with _db_conn() as conn:
        row = conn.execute(
            "SELECT user_id, email, password_hash, full_name, phone, address, created_at "
            "FROM users WHERE email = ?",
            (normalize_email(email),),
        ).fetchone()
    if row is None:
        return None
    return {
        "userId": row["user_id"],
        "email": row["email"],
        "passwordHash": row["password_hash"],
        "fullName": row["full_name"],
        "phone": row["phone"],
        "address": row["address"],
        "createdAt": row["created_at"],
    }


def get_public_user_profile(user: dict[str, Any]) -> dict[str, Any]:
    return {
        "userId": user["userId"],
        "email": user["email"],
        "fullName": user["fullName"],
        "phone": user["phone"],
        "address": user["address"],
        "createdAt": user["createdAt"],
    }


def create_user_session(user_id: str) -> dict[str, Any]:
    token = secrets.token_urlsafe(32)
    created_at = datetime.now()
    expires_at = created_at.timestamp() + (USER_SESSION_TTL_HOURS * 3600)
    expires_iso = datetime.fromtimestamp(expires_at).isoformat(timespec="seconds")
    with _db_conn() as conn:
        conn.execute(
            "INSERT INTO user_sessions (token, user_id, created_at, expires_at) VALUES (?, ?, ?, ?)",
            (
                token,
                user_id,
                created_at.isoformat(timespec="seconds"),
                expires_iso,
            ),
        )
    return {"token": token, "expiresInHours": USER_SESSION_TTL_HOURS}


def get_user_from_session(token: str) -> Optional[dict[str, Any]]:
    with _db_conn() as conn:
        row = conn.execute(
            """
            SELECT
              us.token AS token,
              us.expires_at AS expires_at,
              u.user_id AS user_id,
              u.email AS email,
              u.password_hash AS password_hash,
              u.full_name AS full_name,
              u.phone AS phone,
              u.address AS address,
              u.created_at AS created_at
            FROM user_sessions us
            JOIN users u ON u.user_id = us.user_id
            WHERE us.token = ?
            """,
            (token,),
        ).fetchone()
    if row is None:
        return None

    try:
        expires_at = datetime.fromisoformat(row["expires_at"])
    except ValueError:
        expires_at = datetime.min
    if datetime.now() > expires_at:
        with _db_conn() as conn:
            conn.execute("DELETE FROM user_sessions WHERE token = ?", (token,))
        return None

    return {
        "userId": row["user_id"],
        "email": row["email"],
        "passwordHash": row["password_hash"],
        "fullName": row["full_name"],
        "phone": row["phone"],
        "address": row["address"],
        "createdAt": row["created_at"],
    }


def require_user(x_user_token: Optional[str]) -> dict[str, Any]:
    if not x_user_token:
        raise HTTPException(status_code=401, detail="Login required")
    user = get_user_from_session(x_user_token)
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid or expired session")
    return user


def create_public_image_url(request: Request, relative_path: str) -> str:
    return f"{str(request.base_url).rstrip('/')}{relative_path}"


def validate_image_urls_count(image_urls: list[str], *, require_min_one: bool) -> None:
    count = len(image_urls)
    if require_min_one and count < 1:
        raise HTTPException(status_code=400, detail="At least 1 image is required")
    if count > 5:
        raise HTTPException(status_code=400, detail="Maximum 5 images are allowed")


def sanitize_filename(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]", "_", name)
    return cleaned or "image"


def create_admin_session() -> str:
    token = secrets.token_urlsafe(32)
    ADMIN_SESSIONS[token] = datetime.now()
    return token


def is_admin_session_valid(token: str) -> bool:
    created_at = ADMIN_SESSIONS.get(token)
    if created_at is None:
        return False
    age = datetime.now() - created_at
    if age.total_seconds() > ADMIN_SESSION_TTL_HOURS * 3600:
        ADMIN_SESSIONS.pop(token, None)
        return False
    return True


def require_admin(x_admin_token: Optional[str]):
    if not x_admin_token or not is_admin_session_valid(x_admin_token):
        raise HTTPException(status_code=403, detail="Admin access denied")

# -------------------------
# Cart (sqlite-backed store)
# Keyed by X-Cart-Id header
# -------------------------


def get_cart(cart_id: str) -> dict[str, Any]:
    with _db_conn() as conn:
        row = conn.execute(
            "SELECT items_json FROM carts WHERE cart_id = ?",
            (cart_id,),
        ).fetchone()
        if row is None:
            conn.execute(
                "INSERT INTO carts (cart_id, items_json) VALUES (?, ?)",
                (cart_id, _json_dumps([])),
            )
            return {"items": []}
        items = _json_loads(row["items_json"], [])
        if not isinstance(items, list):
            items = []
        return {"items": items}


def save_cart(cart_id: str, cart: dict[str, Any]):
    items = cart.get("items", [])
    with _db_conn() as conn:
        conn.execute(
            "INSERT INTO carts (cart_id, items_json) VALUES (?, ?) "
            "ON CONFLICT(cart_id) DO UPDATE SET items_json = excluded.items_json",
            (cart_id, _json_dumps(items)),
        )


def get_next_cart_item_id() -> str:
    max_id_num = 0
    with _db_conn() as conn:
        rows = conn.execute("SELECT items_json FROM carts").fetchall()
    for row in rows:
        items = _json_loads(row["items_json"], [])
        if not isinstance(items, list):
            continue
        for it in items:
            item_id = str(it.get("itemId", ""))
            if item_id.startswith("ci"):
                suffix = item_id[2:]
                if suffix.isdigit():
                    max_id_num = max(max_id_num, int(suffix))
    return f"ci{max_id_num + 1}"


def _row_to_order(row: sqlite3.Row) -> dict[str, Any]:
    items = _json_loads(row["items_json"], [])
    customer_email = row["customer_email"] if "customer_email" in row.keys() else None
    if isinstance(items, dict):
        # Backward-safety for malformed legacy rows.
        items = []
    return {
        "orderId": row["order_id"],
        "cartId": row["cart_id"],
        "createdAt": row["created_at"],
        "customerName": row["customer_name"],
        "customerPhone": row["customer_phone"],
        "deliveryAddress": row["delivery_address"],
        "items": items,
        "subtotalLkr": row["subtotal_lkr"],
        "totalLkr": row["total_lkr"],
        **({"customerEmail": customer_email} if customer_email else {}),
    }

def cart_totals(cart):
    subtotal = 0
    for it in cart["items"]:
        subtotal += int(it["priceLkr"]) * int(it["qty"])
    return {"subtotalLkr": subtotal, "totalLkr": subtotal}

class AddItemBody(BaseModel):
    productSlug: str
    size: str
    qty: int = 1

class UpdateQtyBody(BaseModel):
    qty: int


class AdminProductCreateBody(BaseModel):
    slug: str
    title: str
    priceLkr: int
    compareAtPriceLkr: Optional[int] = None
    imageUrls: list[str] = Field(default_factory=list)
    sizes: list[str] = Field(default_factory=lambda: ["S", "M", "L", "XL"])
    inStock: bool = True
    collection: str = "general"
    description: str = ""


class AdminProductUpdateBody(BaseModel):
    title: Optional[str] = None
    priceLkr: Optional[int] = None
    compareAtPriceLkr: Optional[int] = None
    imageUrls: Optional[list[str]] = None
    sizes: Optional[list[str]] = None
    inStock: Optional[bool] = None
    collection: Optional[str] = None
    description: Optional[str] = None


class CheckoutBody(BaseModel):
    useProfileContact: bool = True
    customerPhone: Optional[str] = None
    deliveryAddress: Optional[str] = None


class AdminLoginBody(BaseModel):
    username: str
    password: str


class UserSignupBody(BaseModel):
    fullName: str
    email: str
    password: str
    phone: str
    address: str


class UserLoginBody(BaseModel):
    email: str
    password: str


class AdminHomepageConfigBody(BaseModel):
    mode: str = "default"
    selectedSlugs: list[str] = Field(default_factory=list)


@app.get("/")
def root():
    return {"status": "ok", "service": "Saja Website API"}

@app.get("/collections")
def list_collections():
    return STANDARD_COLLECTIONS

@app.get("/products")
def list_products(collection: Optional[str] = None, q: Optional[str] = None):
    items = list_all_products()
    if collection:
        requested = normalize_category_slug(collection)
        items = [
            p for p in items
            if normalize_category_slug(str(p.get("collection", ""))) == requested
        ]
    if q:
        q_low = q.lower()
        items = [p for p in items if q_low in p.get("title", "").lower()]
    return items

@app.get("/products/{slug}")
def get_product(slug: str):
    p = find_product(slug)
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")
    return p


@app.get("/homepage-products")
def list_homepage_products():
    return get_homepage_products()


@app.post("/admin/login")
def admin_login(body: AdminLoginBody):
    if body.username != ADMIN_USERNAME or body.password != ADMIN_PASSWORD:
        raise HTTPException(status_code=401, detail="Invalid admin credentials")

    token = create_admin_session()
    return {"token": token, "expiresInHours": ADMIN_SESSION_TTL_HOURS}


@app.post("/admin/logout")
def admin_logout(x_admin_token: Optional[str] = Header(default=None)):
    require_admin(x_admin_token)
    ADMIN_SESSIONS.pop(x_admin_token, None)
    return {"status": "ok"}


@app.post("/auth/signup")
def user_signup(body: UserSignupBody):
    full_name = body.fullName.strip()
    email = normalize_email(body.email)
    password = body.password.strip()
    phone = body.phone.strip()
    address = body.address.strip()

    if not full_name:
        raise HTTPException(status_code=400, detail="Full name is required")
    if "@" not in email or "." not in email:
        raise HTTPException(status_code=400, detail="Invalid email")
    if not is_password_strong(password):
        raise HTTPException(
            status_code=400,
            detail="Password must be at least 8 characters and include letters and numbers",
        )
    if not is_valid_phone(phone):
        raise HTTPException(status_code=400, detail="Phone must be exactly 10 digits")
    if not address:
        raise HTTPException(status_code=400, detail="Address is required")

    existing = get_user_by_email(email)
    if existing is not None:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_id = f"u{secrets.token_hex(6)}"
    now_iso = datetime.now().isoformat(timespec="seconds")
    with _db_conn() as conn:
        conn.execute(
            """
            INSERT INTO users (user_id, email, password_hash, full_name, phone, address, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (user_id, email, hash_password(password), full_name, phone, address, now_iso),
        )

    user = get_user_by_email(email)
    if user is None:
        raise HTTPException(status_code=500, detail="Could not create account")
    session = create_user_session(user["userId"])
    return {
        "token": session["token"],
        "expiresInHours": session["expiresInHours"],
        "user": get_public_user_profile(user),
    }


@app.post("/auth/login")
def user_login(body: UserLoginBody):
    email = normalize_email(body.email)
    password = body.password.strip()
    user = get_user_by_email(email)
    if user is None or user["passwordHash"] != hash_password(password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    session = create_user_session(user["userId"])
    return {
        "token": session["token"],
        "expiresInHours": session["expiresInHours"],
        "user": get_public_user_profile(user),
    }


@app.post("/auth/logout")
def user_logout(x_user_token: Optional[str] = Header(default=None)):
    if x_user_token:
        with _db_conn() as conn:
            conn.execute("DELETE FROM user_sessions WHERE token = ?", (x_user_token,))
    return {"status": "ok"}


@app.get("/me")
def get_me(x_user_token: Optional[str] = Header(default=None)):
    user = require_user(x_user_token)
    return get_public_user_profile(user)


@app.get("/admin-panel")
def admin_panel():
    if not ADMIN_INDEX_FILE.exists():
        raise HTTPException(status_code=404, detail="Admin panel not found")
    return FileResponse(str(ADMIN_INDEX_FILE))

# ---------- ADMIN PRODUCT APIs ----------
@app.get("/admin/products")
def admin_list_products(x_admin_token: Optional[str] = Header(default=None)):
    require_admin(x_admin_token)
    return list_all_products()


@app.post("/admin/products")
def admin_create_product(
    body: AdminProductCreateBody,
    x_admin_token: Optional[str] = Header(default=None),
):
    require_admin(x_admin_token)
    if find_product(body.slug):
        raise HTTPException(status_code=400, detail="Slug already exists")
    validate_image_urls_count(body.imageUrls, require_min_one=True)

    now_iso = datetime.now().isoformat(timespec="seconds")
    new_product = {
        "id": generate_product_id(body.collection),
        "slug": body.slug,
        "title": body.title,
        "priceLkr": body.priceLkr,
        "compareAtPriceLkr": body.compareAtPriceLkr,
        "imageUrls": body.imageUrls,
        "sizes": body.sizes,
        "inStock": body.inStock,
        "collection": body.collection,
        "description": body.description,
        "createdAt": now_iso,
    }
    with _db_conn() as conn:
        conn.execute(
            """
            INSERT INTO products (
                id, slug, title, price_lkr, compare_at_price_lkr,
                image_urls, sizes, in_stock, collection, description, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                new_product["id"],
                new_product["slug"],
                new_product["title"],
                new_product["priceLkr"],
                new_product["compareAtPriceLkr"],
                _json_dumps(new_product["imageUrls"]),
                _json_dumps(new_product["sizes"]),
                1 if new_product["inStock"] else 0,
                new_product["collection"],
                new_product["description"],
                new_product["createdAt"],
            ),
        )
    return new_product


@app.patch("/admin/products/{slug}")
def admin_update_product(
    slug: str,
    body: AdminProductUpdateBody,
    x_admin_token: Optional[str] = Header(default=None),
):
    require_admin(x_admin_token)
    existing = find_product(slug)
    if not existing:
        raise HTTPException(status_code=404, detail="Product not found")

    updates = body.model_dump(exclude_unset=True)
    if "imageUrls" in updates:
        validate_image_urls_count(updates["imageUrls"], require_min_one=False)
    merged = {**existing, **updates}
    with _db_conn() as conn:
        conn.execute(
            """
            UPDATE products
            SET title = ?, price_lkr = ?, compare_at_price_lkr = ?, image_urls = ?,
                sizes = ?, in_stock = ?, collection = ?, description = ?
            WHERE slug = ?
            """,
            (
                merged["title"],
                merged["priceLkr"],
                merged["compareAtPriceLkr"],
                _json_dumps(merged["imageUrls"]),
                _json_dumps(merged["sizes"]),
                1 if merged["inStock"] else 0,
                merged["collection"],
                merged["description"],
                slug,
            ),
        )
    return merged


@app.delete("/admin/products/{slug}")
def admin_delete_product(
    slug: str,
    x_admin_token: Optional[str] = Header(default=None),
):
    require_admin(x_admin_token)
    deleted = find_product(slug)
    if deleted is None:
        raise HTTPException(status_code=404, detail="Product not found")

    with _db_conn() as conn:
        conn.execute("DELETE FROM products WHERE slug = ?", (slug,))
        row = conn.execute(
            "SELECT mode, selected_slugs FROM homepage_config WHERE id = 1"
        ).fetchone()
        if row is not None:
            selected_slugs = _json_loads(row["selected_slugs"], [])
            if isinstance(selected_slugs, list) and slug in selected_slugs:
                selected_slugs = [s for s in selected_slugs if s != slug]
                conn.execute(
                    "UPDATE homepage_config SET selected_slugs = ? WHERE id = 1",
                    (_json_dumps(selected_slugs),),
                )
    return {"message": "Product deleted", "slug": deleted.get("slug")}


@app.post("/admin/upload-image")
async def admin_upload_image(
    request: Request,
    file: UploadFile = File(...),
    productSlug: Optional[str] = Form(default=None),
    priceLkr: Optional[int] = Form(default=None),
    compareAtPriceLkr: Optional[int] = Form(default=None),
    x_admin_token: Optional[str] = Header(default=None),
):
    require_admin(x_admin_token)
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are allowed")

    timestamp = datetime.now().strftime("%Y%m%d%H%M%S%f")
    cleaned_name = sanitize_filename(file.filename or "image")
    final_name = f"{timestamp}_{cleaned_name}"
    destination = UPLOADS_DIR / final_name

    with destination.open("wb") as output:
        shutil.copyfileobj(file.file, output)

    image_url = create_public_image_url(request, f"/static/uploads/{final_name}")

    updated_product = None
    if productSlug:
        p = find_product(productSlug)
        if not p:
            raise HTTPException(status_code=404, detail="Product not found")
        if "imageUrls" not in p or not isinstance(p["imageUrls"], list):
            p["imageUrls"] = []
        if len(p["imageUrls"]) >= 5:
            raise HTTPException(status_code=400, detail="Maximum 5 images are allowed")
        p["imageUrls"].append(image_url)
        if priceLkr is not None:
            p["priceLkr"] = priceLkr
        if compareAtPriceLkr is not None:
            p["compareAtPriceLkr"] = compareAtPriceLkr
        with _db_conn() as conn:
            conn.execute(
                """
                UPDATE products
                SET price_lkr = ?, compare_at_price_lkr = ?, image_urls = ?
                WHERE slug = ?
                """,
                (
                    p["priceLkr"],
                    p["compareAtPriceLkr"],
                    _json_dumps(p["imageUrls"]),
                    productSlug,
                ),
            )
        updated_product = p

    return {
        "imageUrl": image_url,
        "product": updated_product,
        "message": "Image uploaded successfully",
    }


@app.get("/admin/orders")
def admin_list_orders(x_admin_token: Optional[str] = Header(default=None)):
    require_admin(x_admin_token)
    with _db_conn() as conn:
        rows = conn.execute(
            "SELECT * FROM orders ORDER BY created_at DESC"
        ).fetchall()
    return [_row_to_order(r) for r in rows]


@app.delete("/admin/orders/{order_id}")
def admin_delete_order(order_id: str, x_admin_token: Optional[str] = Header(default=None)):
    global LAST_DELETED_ORDER
    require_admin(x_admin_token)
    with _db_conn() as conn:
        row = conn.execute(
            "SELECT * FROM orders WHERE order_id = ?",
            (order_id,),
        ).fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="Order not found")
    deleted = _row_to_order(row)
    LAST_DELETED_ORDER = deleted
    with _db_conn() as conn:
        conn.execute("DELETE FROM orders WHERE order_id = ?", (order_id,))
    return {"message": "Order removed", "orderId": deleted.get("orderId")}


@app.post("/admin/orders/undo-delete")
def admin_undo_delete_order(x_admin_token: Optional[str] = Header(default=None)):
    global LAST_DELETED_ORDER
    require_admin(x_admin_token)
    if LAST_DELETED_ORDER is None:
        raise HTTPException(status_code=400, detail="Nothing to undo")
    with _db_conn() as conn:
        conn.execute(
            """
            INSERT OR REPLACE INTO orders (
                order_id, cart_id, created_at, customer_name, customer_email, customer_phone,
                delivery_address, items_json, subtotal_lkr, total_lkr
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                LAST_DELETED_ORDER.get("orderId"),
                LAST_DELETED_ORDER.get("cartId"),
                LAST_DELETED_ORDER.get("createdAt"),
                LAST_DELETED_ORDER.get("customerName"),
                LAST_DELETED_ORDER.get("customerEmail"),
                LAST_DELETED_ORDER.get("customerPhone"),
                LAST_DELETED_ORDER.get("deliveryAddress"),
                _json_dumps(LAST_DELETED_ORDER.get("items", [])),
                int(LAST_DELETED_ORDER.get("subtotalLkr", 0)),
                int(LAST_DELETED_ORDER.get("totalLkr", 0)),
            ),
        )
    restored_order_id = LAST_DELETED_ORDER.get("orderId")
    LAST_DELETED_ORDER = None
    return {"message": "Order restored", "orderId": restored_order_id}


@app.get("/admin/homepage-config")
def admin_get_homepage_config(x_admin_token: Optional[str] = Header(default=None)):
    require_admin(x_admin_token)
    return get_homepage_config()


@app.put("/admin/homepage-config")
def admin_update_homepage_config(
    body: AdminHomepageConfigBody,
    x_admin_token: Optional[str] = Header(default=None),
):
    require_admin(x_admin_token)
    mode = body.mode.strip().lower()
    if mode not in {"default", "custom"}:
        raise HTTPException(status_code=400, detail="Invalid mode")
    if len(body.selectedSlugs) > 10:
        raise HTTPException(status_code=400, detail="Maximum 10 products allowed")

    valid_slugs = {str(p.get("slug")) for p in list_all_products()}
    filtered_slugs: list[str] = []
    for slug in body.selectedSlugs:
        if slug in valid_slugs and slug not in filtered_slugs:
            filtered_slugs.append(slug)

    with _db_conn() as conn:
        conn.execute(
            "INSERT INTO homepage_config (id, mode, selected_slugs) VALUES (1, ?, ?) "
            "ON CONFLICT(id) DO UPDATE SET mode = excluded.mode, selected_slugs = excluded.selected_slugs",
            (mode, _json_dumps(filtered_slugs)),
        )
    return {"mode": mode, "selectedSlugs": filtered_slugs}


# ---------- CART APIs ----------
@app.get("/cart")
def get_my_cart(x_cart_id: Optional[str] = Header(default=None)):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")
    cart = get_cart(x_cart_id)
    return {"items": cart["items"], **cart_totals(cart)}


@app.post("/checkout")
def checkout(
    body: CheckoutBody,
    x_cart_id: Optional[str] = Header(default=None),
    x_user_token: Optional[str] = Header(default=None),
):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")
    user = require_user(x_user_token)

    cart = get_cart(x_cart_id)
    if not cart["items"]:
        raise HTTPException(status_code=400, detail="Cart is empty")

    if body.useProfileContact:
        customer_phone = str(user.get("phone", "")).strip()
        delivery_address = str(user.get("address", "")).strip()
    else:
        customer_phone = str(body.customerPhone or "").strip()
        delivery_address = str(body.deliveryAddress or "").strip()
        if not is_valid_phone(customer_phone):
            raise HTTPException(status_code=400, detail="Phone must be exactly 10 digits")
        if not delivery_address:
            raise HTTPException(status_code=400, detail="Address is required")

    totals = cart_totals(cart)
    order = {
        "orderId": get_next_order_id(),
        "cartId": x_cart_id,
        "createdAt": datetime.now().isoformat(timespec="seconds"),
        "customerName": user.get("fullName"),
        "customerPhone": customer_phone,
        "deliveryAddress": delivery_address,
        "customerEmail": user.get("email"),
        "items": [dict(it) for it in cart["items"]],
        "subtotalLkr": totals["subtotalLkr"],
        "totalLkr": totals["totalLkr"],
    }
    with _db_conn() as conn:
        conn.execute(
            """
            INSERT INTO orders (
                order_id, cart_id, created_at, customer_name, customer_email, customer_phone,
                delivery_address, items_json, subtotal_lkr, total_lkr
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                order["orderId"],
                order["cartId"],
                order["createdAt"],
                order["customerName"],
                order.get("customerEmail"),
                order["customerPhone"],
                order["deliveryAddress"],
                _json_dumps(order["items"]),
                order["subtotalLkr"],
                order["totalLkr"],
            ),
        )
    cart["items"] = []
    save_cart(x_cart_id, cart)
    return {"message": "Checkout completed", "order": order}

@app.post("/cart/items")
def add_cart_item(body: AddItemBody, x_cart_id: Optional[str] = Header(default=None)):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")

    p = find_product(body.productSlug)
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")

    if body.size not in p["sizes"]:
        raise HTTPException(status_code=400, detail="Invalid size")

    if body.qty < 1:
        raise HTTPException(status_code=400, detail="Qty must be >= 1")

    cart = get_cart(x_cart_id)

    # If same product+size exists, just increase qty
    for it in cart["items"]:
        if it["productSlug"] == body.productSlug and it["size"] == body.size:
            it["qty"] += body.qty
            save_cart(x_cart_id, cart)
            return {"items": cart["items"], **cart_totals(cart)}

    item = {
        "itemId": get_next_cart_item_id(),
        "productSlug": body.productSlug,
        "title": p["title"],
        "priceLkr": p["priceLkr"],      # snapshot
        "imageUrl": (p["imageUrls"][0] if p["imageUrls"] else None),
        "size": body.size,
        "qty": body.qty,
    }
    cart["items"].append(item)
    save_cart(x_cart_id, cart)
    return {"items": cart["items"], **cart_totals(cart)}

@app.patch("/cart/items/{item_id}")
def update_cart_item_qty(item_id: str, body: UpdateQtyBody, x_cart_id: Optional[str] = Header(default=None)):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")

    cart = get_cart(x_cart_id)

    for it in cart["items"]:
        if it["itemId"] == item_id:
            if body.qty < 1:
                raise HTTPException(status_code=400, detail="Qty must be >= 1")
            it["qty"] = body.qty
            save_cart(x_cart_id, cart)
            return {"items": cart["items"], **cart_totals(cart)}

    raise HTTPException(status_code=404, detail="Cart item not found")

@app.delete("/cart/items/{item_id}")
def delete_cart_item(item_id: str, x_cart_id: Optional[str] = Header(default=None)):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")

    cart = get_cart(x_cart_id)
    before = len(cart["items"])
    cart["items"] = [it for it in cart["items"] if it["itemId"] != item_id]

    if len(cart["items"]) == before:
        raise HTTPException(status_code=404, detail="Cart item not found")

    save_cart(x_cart_id, cart)
    return {"items": cart["items"], **cart_totals(cart)}

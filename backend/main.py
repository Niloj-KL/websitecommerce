from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Saja Website API", version="0.1.0")

# -------------------------
# CORS (DEV ONLY)
# -------------------------
# Flutter web runs on different localhost ports while developing.
# For development, allow all origins. In production, lock this down
# to only your real domain(s), e.g. https://yourshop.lk
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # DEV ONLY
    allow_credentials=False,      # must be False if allow_origins is "*"
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------
# Dummy in-memory data (replace with DB later)
# -------------------------
PRODUCTS = [
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
        "description": "Soft cotton tee. Demo product for development.",
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
        "description": "Another cotton tee demo product.",
    },
    {
        "id": "p3",
        "slug": "kurti-rose-1",
        "title": "Kurti - Rose Pattern",
        "priceLkr": 7900,
        "compareAtPriceLkr": 8900,
        "imageUrls": [],
        "sizes": ["S", "M", "L", "XL"],
        "inStock": True,
        "collection": "kurtis",
        "description": "Kurti demo product (patterned).",
    },
    {
        "id": "p4",
        "slug": "dress-summer-1",
        "title": "Summer Dress - Light",
        "priceLkr": 9900,
        "compareAtPriceLkr": None,
        "imageUrls": [],
        "sizes": ["S", "M", "L"],
        "inStock": False,
        "collection": "dress",
        "description": "Summer dress demo product (out of stock).",
    },
]

# -------------------------
# Routes
# -------------------------
@app.get("/")
def root():
    return {"status": "ok", "service": "Saja Website API"}


@app.get("/collections")
def list_collections():
    """
    Returns collections derived from PRODUCTS.
    Flutter collections slugs should match these.
    """
    cols = sorted(set(p["collection"] for p in PRODUCTS))
    return [{"name": c.upper(), "slug": c} for c in cols]


@app.get("/products")
def list_products(collection: str | None = None, q: str | None = None):
    """
    List products.
    Optional filters:
      - collection: filter by collection slug
      - q: simple search by title
    """
    items = PRODUCTS

    if collection:
        items = [p for p in items if p.get("collection") == collection]

    if q:
        q_low = q.lower()
        items = [p for p in items if q_low in p.get("title", "").lower()]

    return items


@app.get("/products/{slug}")
def get_product(slug: str):
    """
    Get a single product by slug.
    """
    for p in PRODUCTS:
        if p.get("slug") == slug:
            return p
    raise HTTPException(status_code=404, detail="Product not found")

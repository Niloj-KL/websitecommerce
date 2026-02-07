from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from fastapi.staticfiles import StaticFiles
from pathlib import Path

app = FastAPI(title="Saja Website API", version="0.2.0")
BASE_DIR = Path(__file__).resolve().parent
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")

# DEV CORS ONLY
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],     # DEV ONLY
    allow_credentials=False, # must be False with "*"
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------
# Dummy products (later DB)
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
    "imageUrls": [
        #"https://drive.google.com/file/d/1vGXeezMEzHAPEWTAkpOpz3aplH38Kvj0",
        
        #"https://drive.google.com/uc?export=view&id=1D-5wo4EWO-E1-UG60quehjHFs7cRxDH4",
       # "https://drive.google.com/uc?export=view&id=1-otR3A7TQQHNme3d8l2PLSHLtFmMq6c3",
       # "https://drive.google.com/uc?export=view&id=1WX8RWockjVWz1bEAhPl_BP1md4ji9KvP",
       # "https://drive.google.com/uc?export=view&id=1V6AL2_3ExLBr1Dml2u-IQrzFT9t9Cgqb"
         "http://localhost:8000/static/kurtis/kurta1.png",
       "http://localhost:8000/static/kurtis/krta2.png",
        "http://localhost:8000/static/kurtis/krta3.png",
         "http://localhost:8000/static/kurtis/krta4.png",
        "http://localhost:8000/static/kurtis/krta5.png",
    ],
    "sizes": ["S", "M", "L", "XL"],
    "inStock": True,
    "collection": "kurtis",
    "description": "Elegant rose-pattern kurti"


    },

     {
 
    "id": "p3",
    "slug": "kurti-rose-1",
    "title": "Kurti - Rose Pattern",
    "priceLkr": 3400,
    "compareAtPriceLkr": 3000,
    "imageUrls": [
        #"https://drive.google.com/file/d/1vGXeezMEzHAPEWTAkpOpz3aplH38Kvj0",
        
        #"https://drive.google.com/uc?export=view&id=1D-5wo4EWO-E1-UG60quehjHFs7cRxDH4",
       # "https://drive.google.com/uc?export=view&id=1-otR3A7TQQHNme3d8l2PLSHLtFmMq6c3",
       # "https://drive.google.com/uc?export=view&id=1WX8RWockjVWz1bEAhPl_BP1md4ji9KvP",
       # "https://drive.google.com/uc?export=view&id=1V6AL2_3ExLBr1Dml2u-IQrzFT9t9Cgqb"

         "http://localhost:8000/static/kurtis/krta4.png",
        "http://localhost:8000/static/kurtis/krta5.png",
    ],
    "sizes": ["S", "M", "L", "XL"],
    "inStock": True,
    "collection": "kurtis",
    "description": "Elegant rose-pattern kurti"


    },
]

def find_product(slug: str):
    for p in PRODUCTS:
        if p["slug"] == slug:
            return p
    return None

# -------------------------
# Cart (in-memory store)
# Keyed by X-Cart-Id header
# -------------------------
CARTS = {}  # cart_id -> {"items":[...]}
ITEM_SEQ = 1

def get_cart(cart_id: str):
    if cart_id not in CARTS:
        CARTS[cart_id] = {"items": []}
    return CARTS[cart_id]

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

@app.get("/")
def root():
    return {"status": "ok", "service": "Saja Website API"}

@app.get("/collections")
def list_collections():
    cols = sorted(set(p["collection"] for p in PRODUCTS))
    return [{"name": c.upper(), "slug": c} for c in cols]

@app.get("/products")
def list_products(collection: Optional[str] = None, q: Optional[str] = None):
    items = PRODUCTS
    if collection:
        items = [p for p in items if p.get("collection") == collection]
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

# ---------- CART APIs ----------
@app.get("/cart")
def get_my_cart(x_cart_id: Optional[str] = Header(default=None)):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")
    cart = get_cart(x_cart_id)
    return {"items": cart["items"], **cart_totals(cart)}

@app.post("/cart/items")
def add_cart_item(body: AddItemBody, x_cart_id: Optional[str] = Header(default=None)):
    global ITEM_SEQ
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
            return {"items": cart["items"], **cart_totals(cart)}

    item = {
        "itemId": f"ci{ITEM_SEQ}",
        "productSlug": body.productSlug,
        "title": p["title"],
        "priceLkr": p["priceLkr"],      # snapshot
        "imageUrl": (p["imageUrls"][0] if p["imageUrls"] else None),
        "size": body.size,
        "qty": body.qty,
    }
    ITEM_SEQ += 1
    cart["items"].append(item)
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

    return {"items": cart["items"], **cart_totals(cart)}

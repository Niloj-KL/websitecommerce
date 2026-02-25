from fastapi import FastAPI, HTTPException, Header, UploadFile, File, Form, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from typing import Optional
from pathlib import Path
import shutil
import os

# -------------------------
# App Setup
# -------------------------
app = FastAPI(title="Saja Website API", version="1.0.0")

BASE_DIR = Path(__file__).resolve().parent
MEDIA_DIR = BASE_DIR / "media"
MEDIA_DIR.mkdir(exist_ok=True)

app.mount("/media", StaticFiles(directory=str(MEDIA_DIR)), name="media")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # DEV ONLY
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------
# Database Setup
# -------------------------
DATABASE_URL = "sqlite:///./ecommerce.db"

engine = create_engine(
    DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()


# -------------------------
# Product Model
# -------------------------
class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    slug = Column(String, unique=True, index=True)
    title = Column(String)
    description = Column(String)
    priceLkr = Column(Integer)
    compareAtPriceLkr = Column(Integer, nullable=True)
    imageUrl = Column(String)
    collection = Column(String)
    inStock = Column(Boolean, default=True)


Base.metadata.create_all(bind=engine)


# -------------------------
# Dependency
# -------------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# -------------------------
# Root
# -------------------------
@app.get("/")
def root():
    return {"status": "ok", "service": "Saja Website API"}


# -------------------------
# ADMIN: Create Product (Image Upload)
# -------------------------
@app.post("/admin/products")
async def create_product(
    slug: str = Form(...),
    title: str = Form(...),
    description: str = Form(...),
    priceLkr: int = Form(...),
    compareAtPriceLkr: Optional[int] = Form(None),
    collection: str = Form(...),
    inStock: bool = Form(True),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    # Save image
    image_path = MEDIA_DIR / image.filename
    with open(image_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    product = Product(
        slug=slug,
        title=title,
        description=description,
        priceLkr=priceLkr,
        compareAtPriceLkr=compareAtPriceLkr,
        imageUrl=f"/media/{image.filename}",
        collection=collection,
        inStock=inStock,
    )

    db.add(product)
    db.commit()
    db.refresh(product)

    return {"message": "Product created successfully", "id": product.id}


# -------------------------
# List Collections
# -------------------------
@app.get("/collections")
def list_collections(db: Session = Depends(get_db)):
    collections = db.query(Product.collection).distinct().all()
    return [{"name": c[0].upper(), "slug": c[0]} for c in collections]


# -------------------------
# List Products
# -------------------------
@app.get("/products")
def list_products(
    collection: Optional[str] = None,
    q: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Product)

    if collection:
        query = query.filter(Product.collection == collection)

    if q:
        query = query.filter(Product.title.ilike(f"%{q}%"))

    products = query.all()

    return [
        {
            "slug": p.slug,
            "title": p.title,
            "priceLkr": p.priceLkr,
            "compareAtPriceLkr": p.compareAtPriceLkr,
            "imageUrls": [f"http://localhost:8000{p.imageUrl}"],
            "collection": p.collection,
            "inStock": p.inStock,
            "description": p.description,
            "sizes": ["S", "M", "L", "XL"],  # Keep static for now
        }
        for p in products
    ]


# -------------------------
# Get Single Product
# -------------------------
@app.get("/products/{slug}")
def get_product(slug: str, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.slug == slug).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return {
        "slug": product.slug,
        "title": product.title,
        "priceLkr": product.priceLkr,
        "compareAtPriceLkr": product.compareAtPriceLkr,
        "imageUrls": [f"http://localhost:8000{product.imageUrl}"],
        "collection": product.collection,
        "inStock": product.inStock,
        "description": product.description,
        "sizes": ["S", "M", "L", "XL"],
    }


# -------------------------
# CART (still in-memory)
# -------------------------
CARTS = {}
ITEM_SEQ = 1


def get_cart(cart_id: str):
    if cart_id not in CARTS:
        CARTS[cart_id] = {"items": []}
    return CARTS[cart_id]


def cart_totals(cart):
    subtotal = sum(int(it["priceLkr"]) * int(it["qty"]) for it in cart["items"])
    return {"subtotalLkr": subtotal, "totalLkr": subtotal}


@app.get("/cart")
def get_my_cart(x_cart_id: Optional[str] = Header(default=None)):
    if not x_cart_id:
        raise HTTPException(status_code=400, detail="Missing X-Cart-Id header")
    cart = get_cart(x_cart_id)
    return {"items": cart["items"], **cart_totals(cart)}
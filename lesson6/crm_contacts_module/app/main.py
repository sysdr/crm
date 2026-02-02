from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
import os

from . import crud, models, schemas
from .database import engine, get_db

# --- Create tables if they don't exist ---
# In a real production system, you'd use a dedicated migration tool (e.g., Alembic)
# This is for simplicity in our hands-on setup.
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="CRM Contacts API",
    description="API for managing customer contacts.",
    version="0.1.0",
)

# Serve dashboard HTML
@app.get("/", response_class=HTMLResponse, summary="Dashboard")
def get_dashboard():
    dashboard_path = os.path.join(os.path.dirname(__file__), "dashboard.html")
    with open(dashboard_path, "r") as f:
        return f.read()

@app.post("/contacts/", response_model=schemas.ContactInDB, status_code=status.HTTP_201_CREATED, summary="Create a new contact")
def create_contact_endpoint(contact: schemas.ContactCreate, db: Session = Depends(get_db)):
    db_contact = crud.get_contact_by_email(db, email=contact.email)
    if db_contact:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
    return crud.create_contact(db=db, contact=contact)

@app.get("/contacts/", response_model=List[schemas.ContactInDB], summary="Retrieve a list of contacts")
def read_contacts_endpoint(skip: int = 0, limit: int = 100, tag: Optional[str] = None, db: Session = Depends(get_db)):
    contacts = crud.get_contacts(db, skip=skip, limit=limit, tag=tag)
    return contacts

@app.get("/contacts/{contact_id}", response_model=schemas.ContactInDB, summary="Retrieve a single contact by ID")
def read_contact_endpoint(contact_id: uuid.UUID, db: Session = Depends(get_db)):
    db_contact = crud.get_contact(db, contact_id=contact_id)
    if db_contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found or inactive")
    return db_contact

@app.put("/contacts/{contact_id}", response_model=schemas.ContactInDB, summary="Update an existing contact by ID")
def update_contact_endpoint(contact_id: uuid.UUID, contact: schemas.ContactUpdate, db: Session = Depends(get_db)):
    db_contact = crud.update_contact(db, contact_id=contact_id, contact=contact)
    if db_contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")
    return db_contact

@app.delete("/contacts/{contact_id}", response_model=schemas.ContactInDB, summary="Soft-delete a contact by ID")
def delete_contact_endpoint(contact_id: uuid.UUID, db: Session = Depends(get_db)):
    db_contact = crud.delete_contact(db, contact_id=contact_id) # Performs soft delete
    if db_contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")
    return db_contact

from sqlalchemy.orm import Session
from sqlalchemy import func
from . import models, schemas
from typing import List, Optional
import uuid

def create_contact(db: Session, contact: schemas.ContactCreate):
    db_contact = models.Contact(**contact.dict(exclude_unset=True))
    db.add(db_contact)
    db.commit()
    db.refresh(db_contact)
    return db_contact

def get_contact(db: Session, contact_id: uuid.UUID):
    return db.query(models.Contact).filter(models.Contact.id == contact_id, models.Contact.is_active == True).first()

def get_contact_by_email(db: Session, email: str):
    return db.query(models.Contact).filter(models.Contact.email == email, models.Contact.is_active == True).first()

def get_contacts(db: Session, skip: int = 0, limit: int = 100, tag: Optional[str] = None):
    query = db.query(models.Contact).filter(models.Contact.is_active == True)
    if tag:
        # For JSONB column, checking if array contains element
        query = query.filter(models.Contact.tags.contains([tag]))
    return query.offset(skip).limit(limit).all()

def update_contact(db: Session, contact_id: uuid.UUID, contact: schemas.ContactUpdate):
    db_contact = db.query(models.Contact).filter(models.Contact.id == contact_id).first()
    if db_contact:
        update_data = contact.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_contact, key, value)
        db_contact.updated_at = func.now() # Manually update timestamp for consistency
        db.add(db_contact)
        db.commit()
        db.refresh(db_contact)
    return db_contact

def delete_contact(db: Session, contact_id: uuid.UUID):
    db_contact = db.query(models.Contact).filter(models.Contact.id == contact_id).first()
    if db_contact:
        db_contact.is_active = False # Soft delete
        db.add(db_contact)
        db.commit()
        db.refresh(db_contact)
    return db_contact

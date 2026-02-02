from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional, List
from datetime import datetime
import uuid

class ContactBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone_number: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    status: Optional[str] = "Lead" # Default status
    tags: Optional[List[str]] = None # For Assignment
    notes: Optional[str] = None # For Assignment

class ContactCreate(ContactBase):
    pass

class ContactUpdate(ContactBase):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    status: Optional[str] = None
    tags: Optional[List[str]] = None # For Assignment
    notes: Optional[str] = None # For Assignment
    is_active: Optional[bool] = None

class ContactInDB(ContactBase):
    id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_active: bool

    model_config = ConfigDict(from_attributes=True)

import uuid
from sqlalchemy import Column, String, DateTime, Boolean, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB # Added JSONB for tags
from sqlalchemy.sql import func
from .database import Base

class Contact(Base):
    __tablename__ = "contacts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    first_name = Column(String, index=True)
    last_name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    phone_number = Column(String, nullable=True)
    company = Column(String, nullable=True)
    title = Column(String, nullable=True)
    status = Column(String, default="Lead") # e.g., Lead, Opportunity, Customer, Churned
    tags = Column(JSONB, nullable=True, default=[]) # For Assignment: JSONB for flexible tags
    notes = Column(Text, nullable=True) # For Assignment: Text field for notes
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    is_active = Column(Boolean, default=True)

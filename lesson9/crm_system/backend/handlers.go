package main

import (
	"encoding/json"
	"net/http"
	"log"
)

// ContactHandler handles HTTP requests related to contacts
type ContactHandler struct {
	repo *ContactRepository
}

// NewContactHandler creates a new ContactHandler
func NewContactHandler(repo *ContactRepository) *ContactHandler {
	return &ContactHandler{repo: repo}
}

// CreateContact handles POST requests to create a new contact
func (h *ContactHandler) CreateContact(w http.ResponseWriter, r *http.Request) {
	var contact Contact
	if err := json.NewDecoder(r.Body).Decode(&contact); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// For simplicity, generate a UUID for the contact ID here.
	// In a real system, this might be done in a service layer or even by the DB.
	contact.ID = generateUUID() 

	if err := h.repo.CreateContact(contact); err != nil {
		log.Printf("Failed to create contact: %v", err)
		http.Error(w, "Failed to create contact", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(contact)
}

// GetContacts handles GET requests to retrieve contacts.
// It supports filtering by name via query parameter: /contacts?name=John
func (h *ContactHandler) GetContacts(w http.ResponseWriter, r *http.Request) {
	nameFilter := r.URL.Query().Get("name")

	var contacts []Contact
	var err error

	if nameFilter != "" {
		contacts, err = h.repo.GetContactsByName(nameFilter)
	} else {
		contacts, err = h.repo.GetAllContacts()
	}

	if err != nil {
		log.Printf("Failed to retrieve contacts: %v", err)
		http.Error(w, "Failed to retrieve contacts", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(contacts)
}

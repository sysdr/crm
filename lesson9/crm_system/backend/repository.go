package main

import (
	"database/sql"
	"fmt"
	"log"
)

// ContactRepository handles database operations for contacts
type ContactRepository struct {
	db *sql.DB
}

// NewContactRepository creates a new ContactRepository
func NewContactRepository(db *sql.DB) *ContactRepository {
	return &ContactRepository{db: db}
}

// CreateContact inserts a new contact into the database
func (r *ContactRepository) CreateContact(contact Contact) error {
	query := `INSERT INTO contacts (id, first_name, last_name, email, phone) VALUES ($1, $2, $3, $4, $5)`
	_, err := r.db.Exec(query, contact.ID, contact.FirstName, contact.LastName, contact.Email, contact.Phone)
	if err != nil {
		log.Printf("Error creating contact: %v", err)
		return fmt.Errorf("failed to create contact: %w", err)
	}
	return nil
}

// GetContactsByName fetches contacts filtered by first_name or last_name (case-insensitive, partial match)
func (r *ContactRepository) GetContactsByName(name string) ([]Contact, error) {
	searchQuery := "%" + name + "%" // Add wildcards for partial match
	query := `SELECT id, first_name, last_name, email, phone FROM contacts 
	          WHERE LOWER(first_name) LIKE LOWER($1) OR LOWER(last_name) LIKE LOWER($1)`
	
	rows, err := r.db.Query(query, searchQuery)
	if err != nil {
		log.Printf("Error querying contacts by name '%s': %v", name, err)
		return nil, fmt.Errorf("failed to query contacts by name: %w", err)
	}
	defer rows.Close()

	var contacts []Contact
	for rows.Next() {
		var contact Contact
		if err := rows.Scan(&contact.ID, &contact.FirstName, &contact.LastName, &contact.Email, &contact.Phone); err != nil {
			log.Printf("Error scanning contact row: %v", err)
			return nil, fmt.Errorf("failed to scan contact row: %w", err)
		}
		contacts = append(contacts, contact)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Error during rows iteration: %v", err)
		return nil, fmt.Errorf("error during rows iteration: %w", err)
	}

	return contacts, nil
}

// GetAllContacts fetches all contacts from the database
func (r *ContactRepository) GetAllContacts() ([]Contact, error) {
	query := `SELECT id, first_name, last_name, email, phone FROM contacts`
	rows, err := r.db.Query(query)
	if err != nil {
		log.Printf("Error querying all contacts: %v", err)
		return nil, fmt.Errorf("failed to query all contacts: %w", err)
	}
	defer rows.Close()

	var contacts []Contact
	for rows.Next() {
		var contact Contact
		if err := rows.Scan(&contact.ID, &contact.FirstName, &contact.LastName, &contact.Email, &contact.Phone); err != nil {
			log.Printf("Error scanning contact row: %v", err)
			return nil, fmt.Errorf("failed to scan contact row: %w", err)
		}
		contacts = append(contacts, contact)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Error during rows iteration: %v", err)
		return nil, fmt.Errorf("error during rows iteration: %w", err)
	}

	return contacts, nil
}

// GetContactsCount returns the total number of contacts in the database
func (r *ContactRepository) GetContactsCount() (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM contacts`
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		log.Printf("Error getting contacts count: %v", err)
		return 0, fmt.Errorf("failed to get contacts count: %w", err)
	}
	return count, nil
}

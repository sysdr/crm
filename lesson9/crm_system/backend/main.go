package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq" // PostgreSQL driver
	"github.com/google/uuid" // For generating UUIDs
)

// generateUUID generates a new UUID
func generateUUID() string {
	return uuid.New().String()
}

func main() {
	// Database connection setup
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")

	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Failed to open database connection: %v", err)
	}
	defer db.Close()

	// Ping the database to ensure connection is established
	for i := 0; i < 5; i++ {
		err = db.Ping()
		if err == nil {
			log.Println("Successfully connected to the database!")
			break
		}
		log.Printf("Waiting for database to be ready (attempt %d): %v", i+1, err)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatalf("Failed to connect to database after multiple retries: %v", err)
	}

	// Initialize repository and handlers
	contactRepo := NewContactRepository(db)
	contactHandler := NewContactHandler(contactRepo)
	var appMetrics Metrics
	metricsHandler := NewMetricsHandler(contactRepo, &appMetrics)

	// Setup router
	router := mux.NewRouter()

	// CORS for API (allow dashboard from any origin)
	router.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}
			next.ServeHTTP(w, r)
		})
	})

	// API routes
	router.HandleFunc("/api/metrics", metricsHandler.GetMetrics).Methods("GET")
	router.HandleFunc("/api/demo", metricsHandler.Demo).Methods("POST")
	router.HandleFunc("/contacts", contactHandler.CreateContact).Methods("POST")
	router.HandleFunc("/contacts", contactHandler.GetContacts).Methods("GET")

	// Static frontend (dashboard)
	router.PathPrefix("/").Handler(http.FileServer(http.Dir("frontend")))

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port
	}
	log.Printf("Server starting on port %s...", port)
	log.Fatal(http.ListenAndServe(":"+port, router))
}

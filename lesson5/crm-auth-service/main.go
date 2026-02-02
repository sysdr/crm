package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/mux"
)

const APP_PORT = 8080

var jwtKey = []byte(os.Getenv("JWT_SECRET"))

// Credentials struct to hold username and password from login request
type Credentials struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// Claims struct to hold JWT claims
type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

// User struct (simplified for this lesson, would come from DB)
type User struct {
	ID       int
	Username string
	Password string // In real-world, store hashed passwords
}

// Mock database for users (replace with actual DB connection from Day 3)
var mockUsers = map[string]User{
	"admin": {ID: 1, Username: "admin", Password: "password123"},
	"john":  {ID: 2, Username: "john", Password: "securepass"},
}

// AuthenticateUser mocks DB interaction
func AuthenticateUser(username, password string) *User {
	user, exists := mockUsers[username]
	if !exists || user.Password != password {
		return nil
	}
	return &user
}

// Login endpoint handler
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	user := AuthenticateUser(creds.Username, creds.Password)
	if user == nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Set token expiration to 5 minutes
	expirationTime := time.Now().Add(5 * time.Minute)
	claims := &Claims{
		Username: user.Username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   fmt.Sprintf("%d", user.ID),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		log.Printf("Error signing token: %v", err)
		http.Error(w, "Could not generate token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"token": tokenString})
	log.Printf("User '%s' logged in successfully, token issued.", user.Username)
}

// AuthMiddleware for protected endpoints
func AuthMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tokenString := r.Header.Get("Authorization")
		if tokenString == "" {
			http.Error(w, "Missing authorization header", http.StatusUnauthorized)
			return
		}

		// Expecting "Bearer <token>"
		if len(tokenString) < 7 || tokenString[:7] != "Bearer " {
			http.Error(w, "Invalid authorization header format", http.StatusUnauthorized)
			return
		}
		tokenString = tokenString[7:]

		claims := &Claims{}
		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

		if err != nil {
			if errors.Is(err, jwt.ErrSignatureInvalid) {
				http.Error(w, "Invalid token signature", http.StatusUnauthorized)
				return
			}
			if errors.Is(err, jwt.ErrTokenExpired) {
				http.Error(w, "Token expired", http.StatusUnauthorized)
				return
			}
			log.Printf("Token parsing error: %v", err)
			http.Error(w, "Invalid token", http.StatusUnauthorized)
			return
		}

		if !token.Valid {
			http.Error(w, "Invalid token", http.StatusUnauthorized)
			return
		}

		// Token is valid, pass the request to the next handler
		log.Printf("User '%s' authenticated successfully for protected endpoint.", claims.Username)
		next.ServeHTTP(w, r)
	}
}

// Protected endpoint handler
func ProtectedHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Welcome to the protected realm, authenticated user!"})
}

func main() {
	// Set JWT_SECRET environment variable
	if os.Getenv("JWT_SECRET") == "" {
		log.Println("JWT_SECRET environment variable not set. Using default.")
		os.Setenv("JWT_SECRET", "supersecretjwtkey")
	}
	jwtKey = []byte(os.Getenv("JWT_SECRET"))

	router := mux.NewRouter()

	router.HandleFunc("/login", LoginHandler).Methods("POST")
	router.HandleFunc("/protected", AuthMiddleware(ProtectedHandler)).Methods("GET")

	log.Printf("Auth Service starting on port %d...", APP_PORT)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", APP_PORT), router))
}

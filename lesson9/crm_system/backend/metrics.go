package main

import (
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"sync"
	"time"
)

// Metrics holds dashboard metrics (totalContacts from DB; rest updated by /api/demo)
type Metrics struct {
	mu                   sync.RWMutex
	TotalContacts        int     `json:"totalContacts"`
	Revenue              int     `json:"revenue"`
	ActiveDeals          int     `json:"activeDeals"`
	ConversionRate       int     `json:"conversionRate"`
	NewLeads             int     `json:"newLeads"`
	ClosedDeals          int     `json:"closedDeals"`
	PendingTasks         int     `json:"pendingTasks"`
	CustomerSatisfaction int     `json:"customerSatisfaction"`
	LastUpdated          string  `json:"lastUpdated"`
}

// MetricsHandler handles /api/metrics and /api/demo
type MetricsHandler struct {
	repo    *ContactRepository
	metrics *Metrics
}

// NewMetricsHandler creates a new MetricsHandler
func NewMetricsHandler(repo *ContactRepository, m *Metrics) *MetricsHandler {
	return &MetricsHandler{repo: repo, metrics: m}
}

// GetMetrics returns current metrics (totalContacts from DB)
func (h *MetricsHandler) GetMetrics(w http.ResponseWriter, r *http.Request) {
	count, err := h.repo.GetContactsCount()
	if err != nil {
		log.Printf("Failed to get contacts count: %v", err)
		http.Error(w, "Failed to get metrics", http.StatusInternalServerError)
		return
	}
	h.metrics.mu.Lock()
	h.metrics.TotalContacts = count
	h.metrics.LastUpdated = time.Now().UTC().Format(time.RFC3339)
	out := *h.metrics
	h.metrics.mu.Unlock()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(out)
}

// Demo creates sample contacts and updates in-memory metrics so dashboard is non-zero
func (h *MetricsHandler) Demo(w http.ResponseWriter, r *http.Request) {
	samples := []Contact{
		{FirstName: "Demo User One", LastName: "Test", Email: "demo1@example.com", Phone: "555-0101"},
		{FirstName: "Demo User Two", LastName: "Test", Email: "demo2@example.com", Phone: "555-0102"},
		{FirstName: "Demo User Three", LastName: "Test", Email: "demo3@example.com", Phone: "555-0103"},
		{FirstName: "Demo User Four", LastName: "Test", Email: "demo4@example.com", Phone: "555-0104"},
		{FirstName: "Demo User Five", LastName: "Test", Email: "demo5@example.com", Phone: "555-0105"},
	}
	for i := range samples {
		samples[i].ID = generateUUID()
		if err := h.repo.CreateContact(samples[i]); err != nil {
			log.Printf("Demo: skip duplicate or error: %v", err)
		}
	}
	h.metrics.mu.Lock()
	h.metrics.ActiveDeals = rand.Intn(10) + 5
	h.metrics.Revenue = rand.Intn(50000) + 10000
	h.metrics.ConversionRate = min(100, rand.Intn(30)+40)
	h.metrics.NewLeads = rand.Intn(20) + 10
	h.metrics.ClosedDeals = rand.Intn(5) + 1
	h.metrics.PendingTasks = rand.Intn(15) + 5
	h.metrics.CustomerSatisfaction = min(100, rand.Intn(20)+75)
	h.metrics.LastUpdated = time.Now().UTC().Format(time.RFC3339)
	out := *h.metrics
	h.metrics.mu.Unlock()
	count, _ := h.repo.GetContactsCount()
	out.TotalContacts = count
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{"success": true, "message": "Demo data generated", "metrics": out})
}

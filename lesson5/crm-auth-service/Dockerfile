# Use the official Golang image as a builder
FROM golang:1.22-alpine AS builder

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN go build -o crm-auth-service .

# Use a minimal base image for the final stage
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /root/

# Copy the built executable from the builder stage
COPY --from=builder /app/crm-auth-service .

# Expose the port the app runs on
EXPOSE 8080

# Set environment variable for JWT secret
ENV JWT_SECRET="supersecretjwtkey"

# Command to run the executable
CMD ["./crm-auth-service"]

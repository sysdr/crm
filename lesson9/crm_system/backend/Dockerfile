# Use the official Golang image as a base
FROM golang:1.22-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go application
RUN go build -o crm-backend .

# Expose the port the application runs on
EXPOSE 8080

# Command to run the executable
CMD ["./crm-backend"]

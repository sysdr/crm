# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the src directory into the container
COPY src /app/src

# Make sure the database is initialized
RUN python src/database.py

# Expose the port the app runs on
EXPOSE 5000

# Run the application using Gunicorn (more robust for production)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "src.app:app"]

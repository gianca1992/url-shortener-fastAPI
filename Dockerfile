# Use an official Python runtime as base image
FROM python:3.9.1-alpine

# Set the working directory in the container
WORKDIR .
#C opy the file from local to the container
COPY . .

# This will fix some building failures I faced 
RUN apk add --no-cache build-base libffi-dev
RUN apk add --no-cache python3-dev

# Create and activate a virtual environment
RUN python -m venv venv
RUN source ./venv/bin/activate

# Copy the requirements file to the container
COPY /requirements.txt ./

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt
 
# Expose the port to interact with the app
EXPOSE 8000

# Specify the commands to run when the container starts
CMD python -m uvicorn shortener_app.main:app --host 0.0.0.0 --port 8000

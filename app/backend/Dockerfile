FROM python:3.10-slim

WORKDIR /app

RUN pip install --no-cache-dir fastapi uvicorn sqlalchemy psycopg2-binary pydantic

# Copy backend application code
COPY . /app/

# Expose FastAPI default port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

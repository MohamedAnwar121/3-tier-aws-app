from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from database import engine, Base, get_db
from models import ServerModel
from schemas import ServerCreate, ServerResponse

# Initialize Database Schema
Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.post("/api/servers", response_model=ServerResponse)
def create_server(server: ServerCreate, db: Session = Depends(get_db)):
    db_server = ServerModel(**server.model_dump())
    db.add(db_server)
    db.commit()
    db.refresh(db_server)
    return db_server

@app.get("/api/servers", response_model=list[ServerResponse])
def get_servers(db: Session = Depends(get_db)):
    return db.query(ServerModel).all()

@app.put("/api/servers/{server_id}", response_model=ServerResponse)
def update_server(server_id: int, server: ServerCreate, db: Session = Depends(get_db)):
    db_server = db.query(ServerModel).filter(ServerModel.id == server_id).first()
    if not db_server:
        raise HTTPException(status_code=404, detail="Server not found")
    for key, value in server.model_dump().items():
        setattr(db_server, key, value)
    db.commit()
    db.refresh(db_server)
    return db_server

@app.delete("/api/servers/{server_id}")
def delete_server(server_id: int, db: Session = Depends(get_db)):
    db_server = db.query(ServerModel).filter(ServerModel.id == server_id).first()
    if not db_server:
        raise HTTPException(status_code=404, detail="Server not found")
    db.delete(db_server)
    db.commit()
    return {"message": "Server deleted successfully"}

@app.get("/health")
def health():
    return "ok"

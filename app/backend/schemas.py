from pydantic import BaseModel

class ServerCreate(BaseModel):
    hostname: str
    ip_address: str
    os_name: str
    status: str

class ServerResponse(ServerCreate):
    id: int
    class Config:
        from_attributes = True

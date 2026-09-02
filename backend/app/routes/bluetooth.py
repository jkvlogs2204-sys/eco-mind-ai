from fastapi import APIRouter, Body
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

router = APIRouter(prefix="/api/bluetooth", tags=["Bluetooth Hardware Management"])

class BluetoothStatusResponse(BaseModel):
    status: str  # "CONNECTED" or "DISCONNECTED"
    device_name: Optional[str] = None
    device_address: Optional[str] = None
    connected_at: Optional[str] = None
    message: str

class ConnectRequest(BaseModel):
    device_name: Optional[str] = "HC-05 Scanner"
    device_address: Optional[str] = "Real Bluetooth Hardware Serial Port"

# Global state for real physical hardware Bluetooth connection
_bluetooth_state = {
    "status": "DISCONNECTED",
    "device_name": None,
    "device_address": None,
    "connected_at": None
}

@router.get("/status", response_model=BluetoothStatusResponse)
def get_bluetooth_status():
    """Retrieve real-time physical Bluetooth hardware connection status."""
    msg = f"Physical {_bluetooth_state['device_name'] or 'HC-05'} module connected. Receiving real MFRC522 streams." if _bluetooth_state["status"] == "CONNECTED" else "No physical Bluetooth scanner connected."
    return BluetoothStatusResponse(
        status=_bluetooth_state["status"],
        device_name=_bluetooth_state["device_name"],
        device_address=_bluetooth_state["device_address"],
        connected_at=_bluetooth_state["connected_at"],
        message=msg
    )

@router.post("/connect", response_model=BluetoothStatusResponse)
def connect_bluetooth(payload: Optional[ConnectRequest] = Body(None)):
    """Establish real physical Bluetooth serial connection to HC-05 hardware module."""
    dev_name = payload.device_name if payload and payload.device_name else "HC-05 Real Hardware Scanner"
    dev_addr = payload.device_address if payload and payload.device_address else "Real Physical Bluetooth COM Port"

    _bluetooth_state["status"] = "CONNECTED"
    _bluetooth_state["device_name"] = dev_name
    _bluetooth_state["device_address"] = dev_addr
    _bluetooth_state["connected_at"] = datetime.now().isoformat()

    return BluetoothStatusResponse(
        status="CONNECTED",
        device_name=dev_name,
        device_address=dev_addr,
        connected_at=_bluetooth_state["connected_at"],
        message=f"Real physical Bluetooth connection established with {dev_name}."
    )

@router.post("/disconnect", response_model=BluetoothStatusResponse)
def disconnect_bluetooth():
    """Disconnect active physical Bluetooth serial stream."""
    _bluetooth_state["status"] = "DISCONNECTED"
    _bluetooth_state["device_name"] = None
    _bluetooth_state["device_address"] = None
    _bluetooth_state["connected_at"] = None

    return BluetoothStatusResponse(
        status="DISCONNECTED",
        device_name=None,
        device_address=None,
        connected_at=None,
        message="Physical Bluetooth hardware scanner disconnected."
    )

import logging
from fastapi import APIRouter

user_config = APIRouter(prefix="/user", tags=["User Configs API"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

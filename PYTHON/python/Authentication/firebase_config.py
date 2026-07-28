import os
import json
import firebase_admin
from firebase_admin import credentials, firestore, auth

config_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "json", "firebase_config.json"))

if not os.path.exists(config_path):
    raise FileNotFoundError(f"Firebase configuration file not found: {config_path}")

with open(config_path, "r") as f:
    firebase_config = json.load(f)

if not firebase_admin._apps:
    cred = credentials.Certificate(firebase_config)
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("Firebase initialized successfully!")

import firebase_admin
from firebase_admin import auth, credentials, firestore
import os
import json

# ✅ Load Firebase credentials
config_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "firebase_config.json"))

if not firebase_admin._apps:
    cred = credentials.Certificate(config_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()  # ✅ Initialize Firestore

def create_user(email, password, full_name, phone_number, is_admin, badge_number, address):
    try:
        # ✅ Create user in Firebase Authentication
        user = auth.create_user(
            email=email,
            password=password,
            phone_number=phone_number
        )
        print(f"✅ User Created in Authentication: {user.uid}")

    except firebase_admin.auth.EmailAlreadyExistsError:
        print(f"⚠️ User with email {email} already exists! Fetching existing user...")

        # ✅ Fetch existing user if email already exists
        user = auth.get_user_by_email(email)
        print(f"✅ Existing User UID: {user.uid}")

    # ✅ Add user to Firestore under 'users' collection
    user_ref = db.collection("users").document(user.uid)
    user_ref.set({
        "full_name": full_name,
        "email": email,
        "phone_number": phone_number,
        "is_admin": is_admin,
        "badge_number": badge_number,
        "address": {
            "latitude": address[0],
            "longitude": address[1]
        }
    }, merge=True)

    print("✅ User data stored in Firestore under 'users' collection!")

# ✅ Example usage
create_user(
    email="admin@gmail.com",
    password="admin123",
    full_name="Administrator",
    phone_number="+1 452-234-5423",
    is_admin=True,
    badge_number="123456",
    address=(37.7749, -122.4194)  # Example latitude & longitude
)
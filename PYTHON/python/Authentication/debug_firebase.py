import firebase_admin
from firebase_admin import auth, firestore
from decouple import config
import os
import sys

# Ensure the correct path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))

# Import Firebase config
from python.Authentication import firebase_config

# Initialize Firestore
db = firestore.client()


def check_firestore_user(uid):
    user_ref = db.collection("users").document(uid)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        print(f"✅ User Found in Firestore: {user_data}")
    else:
        print(f"❌ User not found in Firestore.")


if __name__ == "__main__":
    email = "admin@gmail.com"

    print("\n🔍 Checking user in Firebase Authentication...")
    user = auth.get_user_by_email(email)

    if user:
        print(f"✅ User Found: {user.uid}, Email Verified: {user.email_verified}")
        print("\n🔍 Checking Firestore database for user...")
        check_firestore_user(user.uid)
    else:
        print("❌ User not found in Firebase Authentication.")

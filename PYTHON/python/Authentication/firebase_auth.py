import requests
from firebase_admin import auth, firestore
from decouple import config
from python.Authentication import firebase_config  # Ensure this is present

# Initialize Firestore
db = firestore.client()  # This is missing in your script
API_KEY = config("FIREBASE_API_KEY")


def register_user(email, password, full_name, phone_number, badge_number, is_admin):
    """
    Register a new user in Firebase Authentication and Firestore.

    Args:
        email (str): User's email address.
        password (str): User's password.
        full_name (str): User's full name.
        phone_number (str): User's phone number.
        badge_number (str): Unique badge number.
        is_admin (bool): Whether the user is an admin.

    Returns:
        dict or None: User data if registration is successful, None otherwise.
    """
    try:
        # Create user in Firebase Authentication
        user = auth.create_user(email=email, password=password)

        # Store user details in Firestore
        user_data = {
            "full_name": full_name,
            "email": email,
            "phone_number": phone_number,
            "badge_number": badge_number,
            "is_admin": is_admin,
            "address": {
                "latitude": None,
                "longitude": None
            }
        }
        db.collection("users").document(user.uid).set(user_data)

        print(f"User created: {user.uid} and added to Firestore")
        return {"uid": user.uid, "email": user.email}

    except Exception as e:
        print(f"Error registering user: {e}")
        return None

def login_user(email, password):
    """Log in a user and check if they are an admin before granting access."""
    try:
        url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
        payload = {"email": email, "password": password, "returnSecureToken": True}
        response = requests.post(url, json=payload)

        if response.status_code == 200:
            user_data = response.json()
            uid = user_data.get("localId")  # Get UID from Firebase Authentication

            print(f"✅ Authenticated User ID: {uid}")  # Debugging: Confirm UID

            # Fetch user details from Firestore
            user_ref = db.collection("users").document(uid)
            user_doc = user_ref.get()

            if user_doc.exists:
                user_info = user_doc.to_dict()
                print(f"✅ User found in Firestore: {user_info}")  # Debugging: Confirm Firestore Data

                if user_info.get("is_admin", False):
                    return user_data  # ✅ Allow login
                else:
                    print("❌ Access Denied: User is not an admin.")
                    return None
            else:
                print(f"⚠️ Error: User with UID {uid} not found in Firestore.")
                return None
        else:
            print(f"❌ Login failed: {response.json()}")
            return None
    except Exception as e:
        print(f"⚠️ Error logging in user: {e}")
        return None


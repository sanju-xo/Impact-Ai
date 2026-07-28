import os
import firebase_admin
from firebase_admin import credentials, messaging
import datetime
import uuid

# Initialize Firebase Admin SDK (only if not already initialized)
if not firebase_admin._apps:
    cred_path = r"C:\Users\LOQ\Desktop\MINI PROJECT\PYTHON\json\firebase_config.json"
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

now = datetime.datetime.now()
crash_id = str(uuid.uuid4())

# Create and send FCM notification with title and body
message = messaging.Message(
    notification=messaging.Notification(
        title="Crash Alert ⚠️",
        body="A crash has been detected! Check the app for details."
    ),
    topic="crash_alerts"  # Ensure the mobile app is subscribed to this topic
)

try:
    # Send the message
    response = messaging.send(message)
    print(f"✅ Notification sent successfully! Response: {response}")
except Exception as e:
    print(f":x: Error sending notification: {e}")
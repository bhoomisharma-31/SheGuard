"""
SheGuard AI - Alert Module (P1)
Handles SMS alerts (Fast2SMS) and alert logging (Firestore).

Flow:
1. trigger_alert() is called from main.py's /trigger-alert route.
2. It sends an SMS to the guardian via Fast2SMS (Quick SMS route - no DLT needed).
3. It logs the alert event to Firestore for record-keeping.
4. Returns a result dict indicating success/failure of each step.

NOTE: ARM-state verification happens on the mobile side (P2/P3) before this
endpoint is ever called. This module assumes the alert is already authorized
and simply executes the send + log.
"""

import os
import requests
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone


# ---------------------------------------------------------------------------
# Firebase Admin initialization (singleton pattern - init once, reuse)
# ---------------------------------------------------------------------------

_firebase_app = None
_db = None


def _init_firebase():
    """
    Initializes the Firebase Admin SDK using credentials from .env.
    Safe to call multiple times - only initializes once.
    """
    global _firebase_app, _db

    if _firebase_app is not None:
        return _db

    project_id = os.getenv("FIREBASE_PROJECT_ID")
    private_key = os.getenv("FIREBASE_PRIVATE_KEY")
    client_email = os.getenv("FIREBASE_CLIENT_EMAIL")

    if not all([project_id, private_key, client_email]):
        raise RuntimeError(
            "Firebase credentials missing in .env "
            "(FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL required)"
        )

    # private_key comes from .env with literal \n characters - convert to real newlines
    private_key = private_key.replace("\\n", "\n")

    cred_dict = {
        "type": "service_account",
        "project_id": project_id,
        "private_key": private_key,
        "client_email": client_email,
        "token_uri": "https://oauth2.googleapis.com/token",
    }

    cred = credentials.Certificate(cred_dict)
    _firebase_app = firebase_admin.initialize_app(cred)
    _db = firestore.client()
    return _db


# ---------------------------------------------------------------------------
# Fast2SMS sender
# ---------------------------------------------------------------------------

FAST2SMS_URL = "https://www.fast2sms.com/dev/bulkV2"


def send_sms(numbers: str, message: str) -> dict:
    """
    Sends an SMS via Fast2SMS Quick SMS route (route=q).
    This route works without DLT registration - ideal for dev/testing.

    Args:
        numbers: comma-separated 10-digit Indian mobile numbers (no +91 prefix)
        message: SMS text content

    Returns:
        dict with 'success' (bool) and 'response' (raw API response or error message)
    """
    api_key = os.getenv("FAST2SMS_API_KEY")
    if not api_key:
        return {"success": False, "response": "FAST2SMS_API_KEY missing in .env"}

    headers = {
        "authorization": api_key,
        "Content-Type": "application/x-www-form-urlencoded",
    }
    payload = {
        "route": "q",  # Quick SMS - transactional, no DLT template needed
        "message": message,
        "language": "english",
        "flash": 0,
        "numbers": numbers,
    }

    try:
        resp = requests.post(FAST2SMS_URL, headers=headers, data=payload, timeout=10)
        data = resp.json()
        return {"success": data.get("return", False), "response": data}
    except requests.exceptions.RequestException as e:
        return {"success": False, "response": str(e)}


# ---------------------------------------------------------------------------
# Firestore alert logging
# ---------------------------------------------------------------------------

def log_alert_to_firestore(user_id: str, guardian_number: str, latitude: float,
                             longitude: float, reason: str | None, sms_success: bool) -> str:
    """
    Logs the alert event to the 'alerts' Firestore collection.

    Returns:
        The Firestore document ID of the created alert record.
    """
    db = _init_firebase()

    alert_doc = {
        "user_id": user_id,
        "guardian_number": guardian_number,
        "latitude": latitude,
        "longitude": longitude,
        "reason": reason,
        "sms_sent": sms_success,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

    _, doc_ref = db.collection("alerts").add(alert_doc)
    return doc_ref.id


# ---------------------------------------------------------------------------
# Main entrypoint - called from main.py's /trigger-alert route
# ---------------------------------------------------------------------------

def trigger_alert(user_id: str, guardian_number: str, latitude: float,
                   longitude: float, reason: str | None = None) -> dict:
    """
    Executes the full alert flow: send SMS + log to Firestore.

    Args:
        user_id: ID of the user who triggered the alert
        guardian_number: 10-digit Indian mobile number (no +91), e.g. "9876543210"
        latitude, longitude: user's current location
        reason: optional context string (e.g. "manual trigger", "shake detected")

    Returns:
        dict with keys: sms_success, sms_response, alert_id
    """
    maps_link = f"https://maps.google.com/?q={latitude},{longitude}"
    message = (
        f"SheGuard Alert: User may be in danger.\n"
        f"Location:\n"
        f"{maps_link}\n"
        f"Please check on them immediately."
    )

    sms_result = send_sms(guardian_number, message)

    alert_id = log_alert_to_firestore(
        user_id=user_id,
        guardian_number=guardian_number,
        latitude=latitude,
        longitude=longitude,
        reason=reason,
        sms_success=sms_result["success"],
    )

    return {
        "sms_success": sms_result["success"],
        "sms_response": sms_result["response"],
        "alert_id": alert_id,
    }
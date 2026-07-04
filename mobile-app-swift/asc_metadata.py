#!/usr/bin/env python3
"""
App Store Connect metadata + screenshot uploader for TiliGo.
Run during Codemagic build — requires ASC environment variables.
"""

import os, sys, time, json, base64, hashlib, math, requests

try:
    import jwt
except ImportError:
    os.system("pip install PyJWT cryptography -q")
    import jwt

APP_ID        = os.environ.get("APP_ID", "6777145744")
ISSUER_ID     = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
KEY_ID        = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
PRIVATE_KEY   = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")
SCRIPT_DIR    = os.path.dirname(os.path.abspath(__file__))
SCREENSHOTS   = os.path.join(SCRIPT_DIR, "screenshots", "en-GB")
BASE_URL      = "https://api.appstoreconnect.apple.com/v1"

DESCRIPTION = """TiliGo is your all-in-one delivery management platform. Whether you're coordinating courier runs, tracking live orders, or managing your delivery operations, TiliGo keeps everything moving smoothly.

Key Features:
• Real-time order tracking
• Efficient route management
• Instant delivery notifications
• Seamless courier coordination
• Simple, intuitive interface

Designed for businesses and individuals who demand fast, reliable delivery. Stay connected to your orders from pickup to drop-off, every step of the way.

Download TiliGo and take control of your deliveries today."""

KEYWORDS     = "delivery,courier,tracking,orders,logistics,dispatch,fleet,parcel,shipping,food delivery"
SUPPORT_URL  = "https://tiligo-delivery-flow.base44.app"
MARKETING_URL = "https://tiligo-delivery-flow.base44.app"
COPYRIGHT    = "2026 TiliGo"
CATEGORY     = "SHOPPING"
WHATS_NEW    = "Performance improvements and reliability enhancements for a smoother delivery experience."

SCREENSHOT_DEVICES = {
    "iphone_65_01.png": "IPHONE_65",
    "ipad_13_01.png":   "IPAD_PRO_3GEN_129",
}


def make_token():
    payload = {"iss": ISSUER_ID, "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})


def headers():
    return {"Authorization": f"Bearer {make_token()}", "Content-Type": "application/json"}


def get(path, params=None):
    r = requests.get(f"{BASE_URL}{path}", headers=headers(), params=params or {})
    r.raise_for_status()
    return r.json()


def patch(path, body):
    r = requests.patch(f"{BASE_URL}{path}", headers=headers(), json=body)
    if not r.ok:
        print(f"  PATCH {path} -> {r.status_code}: {r.text[:300]}")
    r.raise_for_status()
    return r.json()


def post(path, body):
    r = requests.post(f"{BASE_URL}{path}", headers=headers(), json=body)
    if not r.ok:
        print(f"  POST {path} -> {r.status_code}: {r.text[:300]}")
    r.raise_for_status()
    return r.json()


def step(msg):
    print(f"\n{'='*60}\n  {msg}\n{'='*60}")


# ── 1. App info (category + copyright) ───────────────────────
step("Updating app info (category + copyright)")
infos = get(f"/apps/{APP_ID}/appInfos")["data"]
if not infos:
    print("  No app infos found — skipping category update")
else:
    info_id = infos[0]["id"]
    patch(f"/appInfos/{info_id}", {
        "data": {
            "type": "appInfos",
            "id": info_id,
            "attributes": {"primaryCategory": CATEGORY}
        }
    })
    print(f"  Category set to {CATEGORY} (info {info_id})")

    # App info localization (en-GB) — name/subtitle visible in store listing header
    locs = get(f"/appInfos/{info_id}/appInfoLocalizations")["data"]
    gb_loc = next((l for l in locs if l["attributes"]["locale"] == "en-GB"), None)
    if gb_loc:
        patch(f"/appInfoLocalizations/{gb_loc['id']}", {
            "data": {
                "type": "appInfoLocalizations",
                "id": gb_loc["id"],
                "attributes": {"name": "TiliGo"}
            }
        })
        print(f"  en-GB app info localization updated")
    else:
        post("/appInfoLocalizations", {
            "data": {
                "type": "appInfoLocalizations",
                "attributes": {"locale": "en-GB", "name": "TiliGo"},
                "relationships": {"appInfo": {"data": {"type": "appInfos", "id": info_id}}}
            }
        })
        print("  en-GB app info localization created")


# ── 2. App Store version metadata ────────────────────────────
step("Updating version metadata (description, keywords, support URL)")
versions = get(f"/apps/{APP_ID}/appStoreVersions",
               params={"filter[appStoreState]": "PREPARE_FOR_SUBMISSION,WAITING_FOR_REVIEW,DEVELOPER_REMOVED_FROM_SALE",
                       "filter[platform]": "IOS"})["data"]
if not versions:
    versions = get(f"/apps/{APP_ID}/appStoreVersions",
                   params={"filter[platform]": "IOS"})["data"]

if not versions:
    print("  No app store version found — skipping version metadata")
else:
    ver_id = versions[0]["id"]
    print(f"  Using version {ver_id}")

    # Copyright lives on the version
    patch(f"/appStoreVersions/{ver_id}", {
        "data": {
            "type": "appStoreVersions",
            "id": ver_id,
            "attributes": {"copyright": COPYRIGHT}
        }
    })
    print(f"  Copyright set to '{COPYRIGHT}'")

    ver_locs = get(f"/appStoreVersions/{ver_id}/appStoreVersionLocalizations")["data"]
    gb_ver_loc = next((l for l in ver_locs if l["attributes"]["locale"] == "en-GB"), None)

    loc_attrs = {
        "description": DESCRIPTION,
        "keywords": KEYWORDS,
        "supportUrl": SUPPORT_URL,
        "marketingUrl": MARKETING_URL,
        "whatsNew": WHATS_NEW,
    }

    if gb_ver_loc:
        patch(f"/appStoreVersionLocalizations/{gb_ver_loc['id']}", {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": gb_ver_loc["id"],
                "attributes": loc_attrs
            }
        })
        print("  en-GB version localization updated")
        ver_loc_id = gb_ver_loc["id"]
    else:
        loc_attrs["locale"] = "en-GB"
        resp = post("/appStoreVersionLocalizations", {
            "data": {
                "type": "appStoreVersionLocalizations",
                "attributes": loc_attrs,
                "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}}
            }
        })
        ver_loc_id = resp["data"]["id"]
        print("  en-GB version localization created")


    # ── 3. Screenshots ────────────────────────────────────────
    step("Uploading screenshots")
    existing_sets = get(f"/appStoreVersionLocalizations/{ver_loc_id}/appScreenshotSets")["data"]

    for fname, device_type in SCREENSHOT_DEVICES.items():
        img_path = os.path.join(SCREENSHOTS, fname)
        if not os.path.exists(img_path):
            print(f"  Skipping {fname} — file not found")
            continue

        # Find or create screenshot set for this device
        ss_set = next((s for s in existing_sets
                       if s["attributes"]["screenshotDisplayType"] == device_type), None)
        if ss_set:
            ss_set_id = ss_set["id"]
            print(f"  Using existing screenshot set {ss_set_id} for {device_type}")
        else:
            resp = post("/appScreenshotSets", {
                "data": {
                    "type": "appScreenshotSets",
                    "attributes": {"screenshotDisplayType": device_type},
                    "relationships": {
                        "appStoreVersionLocalization": {
                            "data": {"type": "appStoreVersionLocalizations", "id": ver_loc_id}
                        }
                    }
                }
            })
            ss_set_id = resp["data"]["id"]
            print(f"  Created screenshot set {ss_set_id} for {device_type}")

        # Check if screenshots already exist in this set
        existing_shots = get(f"/appScreenshotSets/{ss_set_id}/appScreenshots")["data"]
        if existing_shots:
            print(f"  {device_type} already has {len(existing_shots)} screenshot(s) — skipping upload")
            continue

        # Upload screenshot
        file_data = open(img_path, "rb").read()
        file_size = len(file_data)
        md5 = base64.b64encode(hashlib.md5(file_data).digest()).decode()

        reserve = post("/appScreenshots", {
            "data": {
                "type": "appScreenshots",
                "attributes": {"fileName": fname, "fileSize": file_size},
                "relationships": {
                    "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": ss_set_id}}
                }
            }
        })
        ss_id = reserve["data"]["id"]
        upload_ops = reserve["data"]["attributes"].get("uploadOperations", [])

        # Execute upload operations
        for op in upload_ops:
            up_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
            offset = op["offset"]
            length = op["length"]
            chunk  = file_data[offset:offset + length]
            ur = requests.put(op["url"], headers=up_headers, data=chunk)
            ur.raise_for_status()

        # Commit the upload
        patch(f"/appScreenshots/{ss_id}", {
            "data": {
                "type": "appScreenshots",
                "id": ss_id,
                "attributes": {"uploaded": True, "sourceFileChecksum": md5}
            }
        })
        print(f"  Uploaded {fname} → {device_type} ({file_size:,} bytes)")


step("Done — all metadata + screenshots updated")

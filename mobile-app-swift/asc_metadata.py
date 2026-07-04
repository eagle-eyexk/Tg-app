#!/usr/bin/env python3
"""
App Store Connect metadata + screenshot uploader for TiliGo.
Run during Codemagic build — requires ASC environment variables.
"""

import os, sys, time, json, base64, hashlib, subprocess, requests

try:
    import jwt
except ImportError:
    subprocess.run([sys.executable, "-m", "pip", "install", "PyJWT", "cryptography", "-q"])
    import jwt

APP_ID       = os.environ.get("APP_ID", "6777145744")
ISSUER_ID    = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
KEY_ID       = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
# Fix escaped newlines — Codemagic injects multiline env vars with literal \n
_raw_key     = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")
PRIVATE_KEY  = _raw_key.replace("\\n", "\n")

SCRIPT_DIR   = os.path.dirname(os.path.abspath(__file__))
SCREENSHOTS  = os.path.join(SCRIPT_DIR, "screenshots", "en-GB")
BASE_URL     = "https://api.appstoreconnect.apple.com/v1"

# ── Content ──────────────────────────────────────────────────
DESCRIPTION_EN = """TiliGo is your fast and reliable delivery management platform, serving customers across Europe and the Balkans. Track orders in real time, coordinate couriers, and manage every delivery from pickup to drop-off.

Key Features:
• Real-time order tracking
• Smart route management
• Instant delivery notifications
• Seamless courier coordination
• Clean, intuitive interface

Whether you run a restaurant, a shop, or a courier business, TiliGo keeps your operations moving. Available across the UK, Europe, and the Balkan region.

Download TiliGo and take control of your deliveries today."""

KEYWORDS_EN  = "delivery,courier,tracking,orders,logistics,dispatch,food delivery,balkan,europe,shipping"
SUPPORT_URL  = "https://tiligo-delivery-flow.base44.app"
MARKETING_URL = "https://tiligo-delivery-flow.base44.app"
COPYRIGHT    = "2026 TiliGo"
CATEGORY     = "SHOPPING"
WHATS_NEW    = "Improved performance and reliability for faster delivery management."

# Locales to set (en-US is the required default; en-GB for UK)
LOCALES = ["en-US", "en-GB"]

SCREENSHOT_DEVICES = {
    "iphone_65_01.png": "IPHONE_65",
    "ipad_13_01.png":   "IPAD_PRO_3GEN_129",
}


# ── Auth ─────────────────────────────────────────────────────
def make_token():
    if not ISSUER_ID or not KEY_ID or not PRIVATE_KEY.strip():
        raise RuntimeError("Missing ASC credentials (ISSUER_ID / KEY_ID / PRIVATE_KEY)")
    payload = {"iss": ISSUER_ID, "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})


def hdrs():
    return {"Authorization": f"Bearer {make_token()}", "Content-Type": "application/json"}


def get(path, params=None):
    r = requests.get(f"{BASE_URL}{path}", headers=hdrs(), params=params or {})
    r.raise_for_status()
    return r.json()


def patch(path, body):
    r = requests.patch(f"{BASE_URL}{path}", headers=hdrs(), json=body)
    if not r.ok:
        print(f"  WARN PATCH {path} -> {r.status_code}: {r.text[:400]}")
        return None
    return r.json()


def post(path, body):
    r = requests.post(f"{BASE_URL}{path}", headers=hdrs(), json=body)
    if not r.ok:
        print(f"  WARN POST {path} -> {r.status_code}: {r.text[:400]}")
        return None
    return r.json()


def step(msg):
    print(f"\n{'='*60}\n  {msg}\n{'='*60}")


# ── Main ─────────────────────────────────────────────────────
try:
    make_token()
    print("  JWT auth OK")
except Exception as e:
    print(f"ERROR: Cannot generate JWT token: {e}")
    print("  Skipping metadata upload — build will still succeed.")
    sys.exit(0)   # non-fatal: don't fail the whole build


# ── 1. App info (category) ────────────────────────────────────
step("Updating app info (category + copyright)")
try:
    infos = get(f"/apps/{APP_ID}/appInfos")["data"]
    if infos:
        info_id = infos[0]["id"]
        patch(f"/appInfos/{info_id}", {
            "data": {
                "type": "appInfos",
                "id": info_id,
                "attributes": {"primaryCategory": CATEGORY}
            }
        })
        print(f"  Category set to {CATEGORY}")

        existing_locs = get(f"/appInfos/{info_id}/appInfoLocalizations")["data"]
        existing_locale_codes = {l["attributes"]["locale"] for l in existing_locs}

        for locale in LOCALES:
            if locale in existing_locale_codes:
                loc = next(l for l in existing_locs if l["attributes"]["locale"] == locale)
                patch(f"/appInfoLocalizations/{loc['id']}", {
                    "data": {"type": "appInfoLocalizations", "id": loc["id"],
                             "attributes": {"name": "TiliGo"}}
                })
            else:
                post("/appInfoLocalizations", {
                    "data": {
                        "type": "appInfoLocalizations",
                        "attributes": {"locale": locale, "name": "TiliGo"},
                        "relationships": {"appInfo": {"data": {"type": "appInfos", "id": info_id}}}
                    }
                })
            print(f"  App info localization set for {locale}")
except Exception as e:
    print(f"  WARN: App info update failed: {e}")


# ── 2. Version metadata ───────────────────────────────────────
step("Updating version metadata (description, keywords, support URL, copyright)")
ver_loc_ids = {}
try:
    all_versions = get(f"/apps/{APP_ID}/appStoreVersions",
                       params={"filter[platform]": "IOS"})["data"]
    editable = [v for v in all_versions
                if v["attributes"]["appStoreState"] in (
                    "PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED",
                    "REJECTED", "METADATA_REJECTED", "WAITING_FOR_REVIEW")]
    versions = editable if editable else all_versions

    if versions:
        ver_id = versions[0]["id"]
        print(f"  Version: {ver_id} ({versions[0]['attributes'].get('versionString','')})")

        # Copyright on the version object
        patch(f"/appStoreVersions/{ver_id}", {
            "data": {
                "type": "appStoreVersions",
                "id": ver_id,
                "attributes": {"copyright": COPYRIGHT}
            }
        })
        print(f"  Copyright set: '{COPYRIGHT}'")

        ver_locs = get(f"/appStoreVersions/{ver_id}/appStoreVersionLocalizations")["data"]
        existing_ver_locales = {l["attributes"]["locale"]: l for l in ver_locs}

        for locale in LOCALES:
            loc_attrs = {
                "description": DESCRIPTION_EN,
                "keywords": KEYWORDS_EN,
                "supportUrl": SUPPORT_URL,
                "marketingUrl": MARKETING_URL,
                "whatsNew": WHATS_NEW,
            }
            if locale in existing_ver_locales:
                loc_id = existing_ver_locales[locale]["id"]
                patch(f"/appStoreVersionLocalizations/{loc_id}", {
                    "data": {"type": "appStoreVersionLocalizations",
                             "id": loc_id, "attributes": loc_attrs}
                })
                ver_loc_ids[locale] = loc_id
            else:
                loc_attrs["locale"] = locale
                resp = post("/appStoreVersionLocalizations", {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "attributes": loc_attrs,
                        "relationships": {
                            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}
                        }
                    }
                })
                if resp:
                    ver_loc_ids[locale] = resp["data"]["id"]
            print(f"  Version localization set for {locale}")
    else:
        print("  No editable app store version found — skipping version metadata")
except Exception as e:
    print(f"  WARN: Version metadata update failed: {e}")


# ── 3. Screenshots ────────────────────────────────────────────
step("Uploading screenshots")
loc_id = ver_loc_ids.get("en-US") or ver_loc_ids.get("en-GB")
if not loc_id:
    print("  No version localization ID — skipping screenshot upload")
else:
    try:
        existing_sets = get(f"/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")["data"]

        for fname, device_type in SCREENSHOT_DEVICES.items():
            img_path = os.path.join(SCREENSHOTS, fname)
            if not os.path.exists(img_path):
                print(f"  Skipping {fname} — file not found at {img_path}")
                continue

            ss_set = next((s for s in existing_sets
                           if s["attributes"]["screenshotDisplayType"] == device_type), None)
            if ss_set:
                ss_set_id = ss_set["id"]
            else:
                resp = post("/appScreenshotSets", {
                    "data": {
                        "type": "appScreenshotSets",
                        "attributes": {"screenshotDisplayType": device_type},
                        "relationships": {
                            "appStoreVersionLocalization": {
                                "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                            }
                        }
                    }
                })
                if not resp:
                    continue
                ss_set_id = resp["data"]["id"]

            existing_shots = get(f"/appScreenshotSets/{ss_set_id}/appScreenshots")["data"]
            if existing_shots:
                print(f"  {device_type} already has {len(existing_shots)} screenshot(s) — skipping")
                continue

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
            if not reserve:
                continue
            ss_id = reserve["data"]["id"]

            for op in reserve["data"]["attributes"].get("uploadOperations", []):
                up_hdrs = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
                chunk = file_data[op["offset"]: op["offset"] + op["length"]]
                requests.put(op["url"], headers=up_hdrs, data=chunk).raise_for_status()

            patch(f"/appScreenshots/{ss_id}", {
                "data": {"type": "appScreenshots", "id": ss_id,
                         "attributes": {"uploaded": True, "sourceFileChecksum": md5}}
            })
            print(f"  Uploaded {fname} → {device_type} ({file_size:,} bytes)")

    except Exception as e:
        print(f"  WARN: Screenshot upload failed: {e}")


step("Done — metadata script finished")

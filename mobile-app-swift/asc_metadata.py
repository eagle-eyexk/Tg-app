#!/usr/bin/env python3
"""
Complete App Store Connect metadata script for TiliGo.
Handles: category, copyright, age rating, review detail, privacy policy,
         content rights, encryption, pricing, and screenshot upload.
Non-fatal on individual failures — build always succeeds.
"""

import os, sys, time, json, base64, hashlib, subprocess, requests

try:
    import jwt
except ImportError:
    subprocess.run([sys.executable, "-m", "pip", "install", "PyJWT", "cryptography", "-q"],
                   check=True)
    import jwt

# ── Credentials ──────────────────────────────────────────────
APP_ID      = os.environ.get("APP_ID", "6777145744")
ISSUER_ID   = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
KEY_ID      = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
PRIVATE_KEY = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "").replace("\\n", "\n")

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
SCREENSHOTS = os.path.join(SCRIPT_DIR, "screenshots", "en-GB")
BASE_URL    = "https://api.appstoreconnect.apple.com/v1"
BASE_V2     = "https://api.appstoreconnect.apple.com/v2"

# ── App Store Content ─────────────────────────────────────────
DESCRIPTION = """TiliGo – Fast, With Love. All deliveries in Kosovo and the Balkans.

Order food, groceries, pharmacy items, and more from your favourite local stores and restaurants. TiliGo connects you with the best shops and restaurants in your city, delivering to your door in minutes.

🍕 FOOD & RESTAURANTS
Browse popular restaurants, pizza places, burgers, sushi and more. Find your favourites and discover new ones.

🛒 GROCERIES & SUPERMARKETS
Order from local supermarkets and get your groceries delivered fast — no need to leave home.

💊 PHARMACY & ESSENTIALS
Need medicine or urgent essentials? TiliGo gets them to you quickly.

📦 TRACK YOUR ORDERS LIVE
Follow your delivery in real time from the moment it's placed to the moment it arrives at your door.

✅ WHY TILIGO?
• Wide selection of local stores and restaurants
• Real-time order tracking
• Fast delivery across Kosovo and the Balkans
• Transparent pricing — delivery from €1.00
• Simple, intuitive interface in Albanian

Available in Kosovo and expanding across the Balkan region. Download TiliGo today and experience delivery the way it should be — fast, reliable, and with love."""

KEYWORDS       = "delivery,food,restaurant,courier,Kosovo,Balkans,groceries,order,tracking,pizza"
SUPPORT_URL    = "https://tiligo-delivery-flow.base44.app"
MARKETING_URL  = "https://tiligo-delivery-flow.base44.app"
PRIVACY_URL    = "https://tiligo-delivery-flow.base44.app/privacy"
COPYRIGHT      = "2026 TiliGo"
CATEGORY       = "FOOD_AND_DRINK"
WHATS_NEW      = "Faster ordering, improved tracking, and a smoother experience for all your deliveries."

CONTACT_FIRST  = "TiliGo"
CONTACT_LAST   = "Support"
CONTACT_PHONE  = "+38344000000"
CONTACT_EMAIL  = "support@tiligo.app"
REVIEW_NOTES   = ("TiliGo is a food and delivery app for the Kosovo and Balkan region. "
                  "The app shows restaurants, supermarkets and other local stores. "
                  "Users can browse without an account. To place an order, registration is required. "
                  "No demo account is needed to review the main browsing functionality.")

LOCALES = ["en-US", "en-GB"]

SCREENSHOT_DEVICES = [
    ("iphone_65_01.png", "IPHONE_65"),
    ("iphone_65_02.png", "IPHONE_65"),
    ("iphone_65_03.png", "IPHONE_65"),
    ("iphone_65_04.png", "IPHONE_65"),
    ("ipad_13_01.png",   "IPAD_PRO_3GEN_129"),
]

# ── Age Rating — all NONE / false (clean delivery app) ───────
AGE_RATING = {
    "alcoholTobaccoOrDrugUseOrReferences":         "NONE",
    "contests":                                     "NONE",
    "gambling":                                     False,
    "gamblingSimulated":                            "NONE",
    "gunsOrOtherWeapons":                           "NONE",
    "healthOrWellnessTopics":                       "NONE",
    "horrorOrFearThemes":                           "NONE",
    "lootBox":                                      False,
    "matureOrSuggestiveThemes":                     "NONE",
    "medicalOrTreatmentInformation":                "NONE",
    "profanityOrCrudeHumor":                        "NONE",
    "sexualContentGraphicAndNudity":                "NONE",
    "sexualContentOrNudity":                        "NONE",
    "unrestrictedWebAccess":                        False,
    "userGeneratedContent":                         "NONE",
    "violenceCartoonOrFantasy":                     "NONE",
    "violenceRealistic":                            "NONE",
    "violenceRealisticProlongedGraphicOrSadistic":  "NONE",
    "ageAssurance":                                 "NOT_REQUIRED",
    "advertising":                                  False,
    "messagingAndChat":                             False,
    "parentalControls":                             False,
}


# ── Auth helpers ──────────────────────────────────────────────
def make_token():
    payload = {"iss": ISSUER_ID, "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})


def hdrs():
    return {"Authorization": f"Bearer {make_token()}", "Content-Type": "application/json"}


def get(path, params=None, v2=False):
    base = BASE_V2 if v2 else BASE_URL
    r = requests.get(f"{base}{path}", headers=hdrs(), params=params or {})
    r.raise_for_status()
    return r.json()


def patch(path, body, v2=False):
    base = BASE_V2 if v2 else BASE_URL
    r = requests.patch(f"{base}{path}", headers=hdrs(), json=body)
    if not r.ok:
        print(f"  WARN PATCH {path} -> {r.status_code}: {r.text[:500]}")
        return None
    return r.json()


def post(path, body, v2=False):
    base = BASE_V2 if v2 else BASE_URL
    r = requests.post(f"{base}{path}", headers=hdrs(), json=body)
    if not r.ok:
        print(f"  WARN POST {path} -> {r.status_code}: {r.text[:500]}")
        return None
    return r.json()


def step(msg):
    print(f"\n{'='*60}\n  {msg}\n{'='*60}")


# ── Guard: verify JWT ─────────────────────────────────────────
try:
    make_token()
    print("  JWT auth OK")
except Exception as e:
    print(f"ERROR: JWT failed: {e}\nSkipping metadata — build proceeds.")
    sys.exit(0)


# ── 1. Get the editable App Store version ────────────────────
step("Locating editable App Store version")
ver_id = None
try:
    all_ver = get(f"/apps/{APP_ID}/appStoreVersions", {"filter[platform]": "IOS"})["data"]
    # Prefer editable states; fall back to most recent
    EDITABLE = {"PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
                "METADATA_REJECTED", "WAITING_FOR_REVIEW", "INVALID_BINARY"}
    editable = [v for v in all_ver if v["attributes"]["appStoreState"] in EDITABLE]
    target = editable[0] if editable else (all_ver[0] if all_ver else None)
    if target:
        ver_id = target["id"]
        print(f"  Version: {ver_id}  state: {target['attributes']['appStoreState']}")
    else:
        print("  No version found")
except Exception as e:
    print(f"  WARN: {e}")

if not ver_id:
    print("Cannot continue without a version ID. Exiting.")
    sys.exit(0)


# ── 2. App info: category ─────────────────────────────────────
step("Setting primary category → FOOD_AND_DRINK")
try:
    infos = get(f"/apps/{APP_ID}/appInfos")["data"]
    if infos:
        info_id = infos[0]["id"]
        result = patch(f"/appInfos/{info_id}", {
            "data": {"type": "appInfos", "id": info_id,
                     "attributes": {"primaryCategory": CATEGORY}}
        })
        print("  Category set" if result else "  Category update warned (may already be set)")

        # App info localizations (display name in store header)
        locs = get(f"/appInfos/{info_id}/appInfoLocalizations")["data"]
        existing = {l["attributes"]["locale"]: l["id"] for l in locs}
        for locale in LOCALES:
            if locale in existing:
                patch(f"/appInfoLocalizations/{existing[locale]}", {
                    "data": {"type": "appInfoLocalizations", "id": existing[locale],
                             "attributes": {"name": "TiliGo"}}
                })
            else:
                post("/appInfoLocalizations", {"data": {
                    "type": "appInfoLocalizations",
                    "attributes": {"locale": locale, "name": "TiliGo"},
                    "relationships": {"appInfo": {"data": {"type": "appInfos", "id": info_id}}}
                }})
            print(f"  App info localization: {locale}")
except Exception as e:
    print(f"  WARN: {e}")


# ── 3. Version: copyright, content rights, encryption ────────
step("Setting copyright, content rights, encryption")
try:
    patch(f"/appStoreVersions/{ver_id}", {"data": {
        "type": "appStoreVersions", "id": ver_id,
        "attributes": {
            "copyright": COPYRIGHT,
            "contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT",
            "usesNonExemptEncryption": False,
        }
    }})
    print(f"  Copyright: {COPYRIGHT}")
    print("  Content rights: DOES_NOT_USE_THIRD_PARTY_CONTENT")
    print("  usesNonExemptEncryption: false")
except Exception as e:
    print(f"  WARN: {e}")


# ── 4. Age rating declarations ────────────────────────────────
step("Setting age rating declarations (all NONE/false)")
try:
    ver_detail = get(f"/appStoreVersions/{ver_id}",
                     {"include": "ageRatingDeclaration"})
    incl = ver_detail.get("included", [])
    age_decl = next((x for x in incl if x["type"] == "ageRatingDeclarations"), None)
    if not age_decl:
        # fetch directly
        rel = ver_detail["data"]["relationships"].get("ageRatingDeclaration", {})
        age_id = rel.get("data", {}).get("id")
    else:
        age_id = age_decl["id"]

    if age_id:
        patch(f"/ageRatingDeclarations/{age_id}", {"data": {
            "type": "ageRatingDeclarations", "id": age_id,
            "attributes": AGE_RATING
        }})
        print("  Age rating set (all NONE / false)")
    else:
        print("  WARN: Could not find ageRatingDeclaration ID")
except Exception as e:
    print(f"  WARN: {e}")


# ── 5. App Store Review Detail ────────────────────────────────
step("Creating/updating App Store Review Detail")
try:
    rev = get(f"/appStoreVersions/{ver_id}/appStoreReviewDetail")
    existing_detail = rev.get("data")
    detail_attrs = {
        "contactFirstName": CONTACT_FIRST,
        "contactLastName":  CONTACT_LAST,
        "contactPhone":     CONTACT_PHONE,
        "contactEmail":     CONTACT_EMAIL,
        "notes":            REVIEW_NOTES,
    }
    if existing_detail:
        patch(f"/appStoreReviewDetails/{existing_detail['id']}", {"data": {
            "type": "appStoreReviewDetails",
            "id": existing_detail["id"],
            "attributes": detail_attrs
        }})
        print("  Review detail updated")
    else:
        post("/appStoreReviewDetails", {"data": {
            "type": "appStoreReviewDetails",
            "attributes": detail_attrs,
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}
            }
        }})
        print("  Review detail created")
except Exception as e:
    print(f"  WARN: {e}")


# ── 6. Version localizations ──────────────────────────────────
step("Setting description, keywords, support URL, privacy URL")
ver_loc_ids = {}
try:
    ver_locs = get(f"/appStoreVersions/{ver_id}/appStoreVersionLocalizations")["data"]
    existing = {l["attributes"]["locale"]: l for l in ver_locs}

    for locale in LOCALES:
        loc_attrs = {
            "description":    DESCRIPTION,
            "keywords":       KEYWORDS,
            "supportUrl":     SUPPORT_URL,
            "marketingUrl":   MARKETING_URL,
            "privacyPolicyUrl": PRIVACY_URL,
            "whatsNew":       WHATS_NEW,
        }
        if locale in existing:
            loc_id = existing[locale]["id"]
            patch(f"/appStoreVersionLocalizations/{loc_id}", {
                "data": {"type": "appStoreVersionLocalizations",
                         "id": loc_id, "attributes": loc_attrs}
            })
            ver_loc_ids[locale] = loc_id
        else:
            loc_attrs["locale"] = locale
            resp = post("/appStoreVersionLocalizations", {"data": {
                "type": "appStoreVersionLocalizations",
                "attributes": loc_attrs,
                "relationships": {
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}
                }
            }})
            if resp:
                ver_loc_ids[locale] = resp["data"]["id"]
        print(f"  Localization set: {locale}")
except Exception as e:
    print(f"  WARN: {e}")


# ── 7. Pricing: Free ─────────────────────────────────────────
step("Setting app pricing to Free")
try:
    # Get existing price schedule
    sched = get(f"/apps/{APP_ID}/appPriceSchedule", v2=False)
    print("  Price schedule already exists — skipping")
except Exception:
    try:
        # Find the free price point for USD
        pts = get(f"/apps/{APP_ID}/appPricePoints",
                  {"filter[territory]": "USA", "limit": 200})["data"]
        free_pt = next((p for p in pts if p["attributes"].get("customerPrice") == "0.00"
                        or p["attributes"].get("customerPrice") == "0"), None)
        if free_pt:
            resp = post("/appPriceSchedules", {"data": {
                "type": "appPriceSchedules",
                "relationships": {
                    "app": {"data": {"type": "apps", "id": APP_ID}},
                    "manualPrices": {"data": [{"id": "free_price", "type": "appPrices"}]},
                    "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
                }
            }, "included": [{
                "id": "free_price",
                "type": "appPrices",
                "attributes": {"startDate": None, "endDate": None},
                "relationships": {
                    "appPricePoint": {"data": {"type": "appPricePoints", "id": free_pt["id"]}}
                }
            }]}, v2=True)
            print(f"  Pricing set to Free (price point: {free_pt['id']})")
        else:
            print("  WARN: Free price point not found — set pricing manually in App Store Connect")
    except Exception as e:
        print(f"  WARN: Pricing API failed: {e}\n  → Set pricing to Free manually in App Store Connect")


# ── 8. Screenshots ────────────────────────────────────────────
step("Uploading screenshots")
loc_id = ver_loc_ids.get("en-US") or ver_loc_ids.get("en-GB")
if not loc_id:
    print("  No localization ID — cannot upload screenshots")
else:
    try:
        existing_sets_data = get(f"/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")["data"]
        # Build map: device_type -> list of set IDs
        sets_map = {}
        for s in existing_sets_data:
            dt = s["attributes"]["screenshotDisplayType"]
            sets_map.setdefault(dt, []).append(s)

        for fname, device_type in SCREENSHOT_DEVICES:
            img_path = os.path.join(SCREENSHOTS, fname)
            if not os.path.exists(img_path):
                print(f"  Skipping {fname} — not found")
                continue

            # Find or create screenshot set for this device type
            sets_for_device = sets_map.get(device_type, [])
            if sets_for_device:
                ss_set_id = sets_for_device[0]["id"]
            else:
                resp = post("/appScreenshotSets", {"data": {
                    "type": "appScreenshotSets",
                    "attributes": {"screenshotDisplayType": device_type},
                    "relationships": {
                        "appStoreVersionLocalization": {
                            "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                        }
                    }
                }})
                if not resp:
                    continue
                ss_set_id = resp["data"]["id"]
                sets_map[device_type] = [{"id": ss_set_id}]

            # Check existing screenshots count
            existing_shots = get(f"/appScreenshotSets/{ss_set_id}/appScreenshots")["data"]
            if len(existing_shots) >= 10:
                print(f"  {device_type} already full ({len(existing_shots)} screenshots)")
                continue

            # Upload
            file_data = open(img_path, "rb").read()
            md5 = base64.b64encode(hashlib.md5(file_data).digest()).decode()

            reserve = post("/appScreenshots", {"data": {
                "type": "appScreenshots",
                "attributes": {"fileName": fname, "fileSize": len(file_data)},
                "relationships": {
                    "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": ss_set_id}}
                }
            }})
            if not reserve:
                continue

            ss_id = reserve["data"]["id"]
            for op in reserve["data"]["attributes"].get("uploadOperations", []):
                up_h = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
                chunk = file_data[op["offset"]: op["offset"] + op["length"]]
                requests.put(op["url"], headers=up_h, data=chunk).raise_for_status()

            patch(f"/appScreenshots/{ss_id}", {"data": {
                "type": "appScreenshots", "id": ss_id,
                "attributes": {"uploaded": True, "sourceFileChecksum": md5}
            }})
            print(f"  ✓ {fname} → {device_type} ({len(file_data):,} bytes)")

    except Exception as e:
        print(f"  WARN: Screenshot upload error: {e}")


step("All done — metadata script complete")
print("""
ACTION REQUIRED in App Store Connect (cannot be done via API):
  1. App Privacy → set data usage declarations (what data is collected)
  2. Contact Information → verify email/phone in App Information tab
  3. Pricing → confirm the app is set to Free if not already done
  4. Primary Category → verify 'Food & Drink' is selected
These 4 items need manual confirmation before submitting for review.
""")

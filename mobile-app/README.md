# TiliGo iOS App

This is a Capacitor wrapper that loads the live TiliGo web app (`https://tiligo-delivery-flow.base44.app`) inside a native iOS shell, so it can be built and submitted to the App Store through Codemagic.

- Bundle ID: `com.tiligo.tiligo`
- App Store Connect App ID: `6777145744`
- SKU: `tiligo001`

## How the build works

The `ios/` native project is **not** committed here — Codemagic generates it fresh on every build by running `npx cap add ios` + `npx cap sync ios` on its macOS build machines (this repl can't run Xcode). See `/codemagic.yaml` at the project root for the full build & publish pipeline.

## What you still need to do in Codemagic (one-time setup)

I can't create Apple Developer credentials for you — these have to be set up by you in the Codemagic dashboard:

1. **Create an App Store Connect API key integration** in Codemagic named `tiligo_app_store_connection` (Codemagic → Teams → Integrations → App Store Connect). This needs:
   - Issuer ID
   - Key ID
   - The `.p8` private key file
   (Generate these in App Store Connect → Users and Access → Integrations → App Store Connect API.)

2. **Set up iOS code signing** — either let Codemagic auto-manage signing certificates/profiles (recommended, uses the same App Store Connect API key), or upload your own distribution certificate + provisioning profile for `com.tiligo.tiligo`.

3. **Make sure the app record already exists in App Store Connect** with:
   - Bundle ID `com.tiligo.tiligo` registered in your Apple Developer account
   - App created in App Store Connect with SKU `tiligo001`

4. Push this repo to a Git remote connected to Codemagic (Codemagic builds from a Git repository, not directly from Replit) — GitHub/GitLab/Bitbucket, then add the app in Codemagic pointing at `codemagic.yaml`.

Once those are set up, every push to `main` will trigger `tiligo-ios-workflow`, which builds the IPA and submits it to App Store Connect for you.

## Local testing (optional, no Xcode needed)

You can preview the wrapped site in a browser: open `https://tiligo-delivery-flow.base44.app` directly — that's exactly what the native WebView will show.

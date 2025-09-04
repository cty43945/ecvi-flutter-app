# State Administrator Guide

This guide outlines how US states can adopt, customize, and administer the eCVI Flutter app.

## Goals
- Provide a free, offline‑first eCVI tool that aligns with USAHA/AAVLD eCVI v2 (XSD 3.1)
- Allow state‑level branding, validation rules, and distribution processes
- Keep field veterinarians productive without a data connection

## Getting Started
1. Fork the repository: https://github.com/cty43945/ecvi-flutter-app
2. Clone your fork and set up Flutter (stable). Ensure `flutter doctor` is clean.
3. In `ecvi_flutter_app/`:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter run`

## Customization Areas
- Branding & Naming
  - App name, icons, and package identifiers:
    - Android: `android/app/src/main/AndroidManifest.xml`, Gradle scripts
    - iOS: `ios/Runner/Info.plist`, Xcode target name/bundle ID
    - Web: `web/index.html`, icons in `web/icons/`
- Theme & Colors
  - Update Material theme in `lib/main.dart` / theming utilities
- Default Statements & Text
  - Inject state‑specific default statements (e.g., required disclaimers)
  - Recommended: maintain a `List<String> defaultStateStatements` and merge into the form
- Validation Rules
  - Add stricter form validations / field requirements in:
    - `lib/screens/certificate_form_screen.dart`
  - Examples:
    - Restrict MovementPurpose to a subset
    - Require specific address fields (e.g., county)
    - Validate animal tag formats for state programs
- XML Schema Alignment
  - The generator targets eCVI v2 (XSD 3.1): `lib/services/xml_generator.dart`
  - If USAHA updates the XSD, revise namespace/version and adjust element/attribute mapping
  - Validate via `tool/xsd_validate.dart` using an updated XSD
- Export & File Naming
  - XML/PDF filenames currently use `<CviNumber>.xml|.pdf`
  - Adjust as desired in detail screen/home screen export helpers

## Policy & Data Handling
- Offline‑first: data stored locally on device (SQLite). No network needed during entry
- Export: veterinarians can generate XML/PDF and submit via email/portal when online
- Storage & Privacy: Communicate local storage policy and any reporting requirements

## Distribution Options
- Internal pilot: distribute APKs/TestFlight builds; use MDM for managed devices
- Public release: Play Store/App Store (requires state accounts)
- Web demo: GitHub Pages (see below)

## CI & Release
- CI: GitHub Actions runs `flutter analyze`, a smoke test, and a web build
- Releases:
  - Tag semantic versions (e.g., `v0.2.0`)
  - Publish a GitHub Release (release notes link to CHANGELOG)
  - Optional: attach web bundle zip to releases (workflow provided)

## Web Demo (GitHub Pages)
- Workflow builds `build/web` and deploys to `gh-pages`
- After first successful run, enable Pages in repo settings and confirm site URL
- Base href is set to `/ecvi-flutter-app/` for correct asset paths on Pages

## Contact & Support
- Report issues / feature requests using GitHub Issues
- For schema or policy questions, coordinate with USAHA/AAVLD maintainers


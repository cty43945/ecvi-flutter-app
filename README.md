# eCVI Flutter Application

[![CI](https://github.com/cty43945/ecvi-flutter-app/actions/workflows/ci.yml/badge.svg)](https://github.com/cty43945/ecvi-flutter-app/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/cty43945/ecvi-flutter-app?include_prereleases&sort=semver)](https://github.com/cty43945/ecvi-flutter-app/releases)

This is a cross-platform Flutter application for creating electronic Certificates of Veterinary Inspection (eCVIs). The goal is to provide a free, offline-first tool that follows the USAHA/AAVLD eCVI schema (v2), generates compliant XML, and produces a printable PDF certificate.

## Features

- Offline-first local storage (SQLite via `sqflite`)
- Full data entry form for veterinarian, consignor/consignee, origin/destination
- Animals management (add/remove), bulk ID paste-import, and CSV/TXT import with column mapping
- Signature capture for veterinarian
- XML export (schema-oriented) and PDF export
- Share XML/PDF directly from the certificate detail screen
- Swipe-to-delete certificates from the home list

## Project Structure

```
ecvi_flutter_app/
  pubspec.yaml
  lib/
    main.dart
    models/
      address.dart
      animal.dart
      certificate.dart
      contact.dart
      veterinarian.dart
    screens/
      home_screen.dart
      certificate_form_screen.dart
      certificate_detail_screen.dart
    services/
      db_helper.dart
      xml_generator.dart
      pdf_generator.dart
```

## Getting Started

1. Install Flutter from https://flutter.dev
2. From this directory, scaffold the platform folders:
   - `flutter create .`
3. Fetch dependencies:
   - `flutter pub get`
4. Run the app:
   - `flutter run`

### Platform Notes

- Android and iOS may require additional permissions for file access (PDF/XML exports) and media libraries if you extend functionality. Adjust `AndroidManifest.xml` and `Info.plist` as needed.

## Schema Compliance

- The XML generator targets the USAHA/AAVLD eCVI v2 schema (XSD version 3.1) with namespace `http://www.usaha.org/xmlns/ecvi2`.
- Root attributes include `XMLSchemaVersion`, `CviNumber`, `IssueDate`, and `ExpirationDate`.
- The XSD file provided is stored at `assets/xsd/ecvi2_v3.1.xsd`.
- Optional validation helper is provided: `dart run tool/xsd_validate.dart <xml> assets/xsd/ecvi2_v3.1.xsd` (requires `xmllint`).

## License

MIT License. See `LICENSE` for details.

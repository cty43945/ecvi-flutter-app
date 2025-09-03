# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-09-03

Initial functional release of the eCVI Flutter app.

- Core
  - Offline-first local storage (SQLite via sqflite)
  - Shared date formatting (MM/DD/YYYY)
  - Analyzer clean; exclude vendored Flutter SDK & build artifacts

- UI & Flows
  - Full certificate form with validation
  - Animals: add/remove, bulk paste import, CSV/TXT import with column mapping
  - Signature capture (PNG stored per certificate)
  - Certificate detail view with Export/Share XML/PDF and Delete
  - Home: quick Export/Share menu, swipe-to-delete, Issued/Expires dates

- Data & Export
  - XML generator aligned to eCVI schema v2 (XSD version 3.1)
    - Proper namespace and required attributes (XMLSchemaVersion, CviNumber, IssueDate, ExpirationDate)
    - Veterinarian/Contact/Address structure per XSD intent
    - Animal tag mapping: AIN, MfrRFID, InternationalAIN, NUES8/9, ManagementID
  - PDF generator: compact layout, dates, signature block

- Persistence
  - DB migration to add expiration_date
  - Safe reads for existing rows

- Tooling
  - XML sanity check helper
  - Optional XSD validation wrapper via xmllint (tool/xsd_validate.dart)
  - Smoke test (tool/smoke_test.dart)

### Notes
- Exports are saved under app documents `exports/` and can be shared directly.
- XSD reference stored at `assets/xsd/ecvi2_v3.1.xsd`.


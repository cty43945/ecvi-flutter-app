# Contributing

Thanks for your interest in contributing! This project aims to provide a free, offline‑first eCVI app aligned with the USAHA/AAVLD eCVI v2 (XSD 3.1).

## Development
- Install Flutter (stable) and ensure `flutter doctor` has no errors
- From `ecvi_flutter_app/`:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter run`

## Code Style & Quality
- Keep changes focused and minimal
- Run `flutter analyze` and ensure no issues
- Use the shared date formatter (`lib/util/format.dart`) for dates (MM/DD/YYYY)
- For XML output, ensure it aligns with eCVI v2, XSD version 3.1

## Tests & Tooling
- Quick smoke test: `dart run tool/smoke_test.dart`
  - Prints XML sanity and PDF bytes
- Optional strict validation: `dart run tool/xsd_validate.dart <xml> assets/xsd/ecvi2_v3.1.xsd` (requires `xmllint`)

## Branch & PR Flow
- Create feature branches from `master`
- Include a clear PR description using the template
- Checklist before opening a PR:
  - `flutter analyze` passes
  - Smoke test runs
  - App builds and runs locally

## Releases
- Tag with semantic versions (e.g., `v0.1.0`)
- Draft release notes from `CHANGELOG.md`

## GitHub Pages (Web)
- A workflow can deploy `build/web` to `gh-pages`
- After enabling Pages (Settings → Pages), the app is available at:
  - `https://<owner>.github.io/<repo>/`

## Security
- Do not commit secrets/keys
- Report vulnerabilities privately if applicable

Thanks for helping improve this project!


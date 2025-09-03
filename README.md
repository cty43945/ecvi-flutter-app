# eCVI Flutter Application

This repository contains the beginnings of a cross‑platform Flutter application for creating **electronic Certificates of Veterinary Inspection (eCVIs)**.  The goal of the project is to provide veterinarians with a free, offline‑first tool that complies with the latest eCVI data exchange standard, produces the required XML files and a printable PDF certificate, and runs on both iOS and Android.

## Project goals

* **Offline‑first operation:** the app stores all data locally on the device.  Veterinarians can create certificates in the field without connectivity and submit them when they have internet access.
* **Schema compliance:** the XML output conforms to the current [eCVI XML schema version 2](https://github.com/USAHA/eCVI) used by US states【1†L232-L239】.  The data model in this repository mirrors the structure of that schema.
* **Easy data entry:** the UI (to be developed) will support saving frequent consignors/consignees and importing large lists of RFID tag numbers via copy/paste or CSV file import【29†L173-L180】.
* **Open source:** this code is released under the MIT license.  States and developers are welcome to fork, modify and distribute the app for veterinarians.

## Directory structure

```
ecvi_flutter_app/
├── README.md           # This file
├── LICENSE             # MIT license text
├── pubspec.yaml        # Flutter/Dart package dependencies
├── .gitignore          # Ignore build and IDE artifacts
└── lib/
    ├── main.dart       # Entry point for the app
    ├── models/         # Data classes mirroring the eCVI schema
    │   ├── certificate.dart
    │   ├── veterinarian.dart
    │   ├── contact.dart
    │   ├── address.dart
    │   └── animal.dart
    ├── services/       # Helpers for XML/PDF generation and database
    │   ├── xml_generator.dart
    │   ├── pdf_generator.dart
    │   └── db_helper.dart
    └── screens/        # UI screens (to be implemented)
        ├── home_screen.dart
        └── certificate_form_screen.dart
```

## Getting started

This repository does **not** include the full Flutter project scaffold (e.g. `android/`, `ios/` directories) to keep the initial commit lightweight.  To set up the full Flutter environment:

1. Install Flutter according to the instructions at [flutter.dev](https://flutter.dev/docs/get-started/install).
2. Clone this repository and navigate into the project directory:

   ```bash
   git clone <your-github-repo-url>
   cd ecvi_flutter_app
   ```

3. Run Flutter’s project initialization inside this directory.  This will generate the `android/`, `ios/`, `web/`, etc. scaffolding around the `lib/` folder:

   ```bash
   flutter create .
   ```

   When prompted, choose to overwrite any existing `pubspec.yaml` or library files to keep this version.  After that you can run `flutter run` to launch the sample app on an emulator or device.

4. Open the project in your preferred editor (Visual Studio Code, Android Studio, etc.) and start implementing the UI and logic following the model, database and generator stubs.

## Contributing

Pull requests and issues are welcome!  If you are a state agency wishing to use this app for your veterinarians, feel free to fork and customize it for your state.  Please open an issue if you have suggestions or find schema discrepancies.

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
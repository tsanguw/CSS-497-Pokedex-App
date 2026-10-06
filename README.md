# CSS-497-Pokedex-App
This repository is for the Pokedex Database App Project for CSS 497.

# LitWiki - The Pokémon Pokédex
This capstone project focuses on developing a Pokémon database application for Android that provides a comprehensive platform for users to research and manage all things Pokémon.

![CSS_497_Pokédex_Poster_Updated](https://github.com/user-attachments/assets/0fdd68fb-8929-45d6-bbfd-701125218f3f)

## Features
* **Pokémon:** searchable list with type-colored chips, and a detail screen with stat bars, type matchups, evolutions and a filterable moveset.
* **Moves, Abilities, Items, Natures, Gym Leaders:** searchable lists with detail screens.
* **Team Builder:** create, rename and delete teams of up to six Pokémon, each with four moves, an ability and an item. Teams are saved on the device.
* **Design:** Material 3 with light and dark themes that follow the system setting.
* Locations and the Damage Calculator are placeholders for now.

## Technologies Used
* Flutter / Dart: the app framework and language.
* Material 3: the design system (`NavigationDrawer`, `FilterChip`, system light/dark theme).
* SQLite (`sqflite`): local storage for the Pokémon data and for saved teams.
* `shared_preferences`: a small cache of which item sprites exist.
* Android Studio and the Android SDK: Android builds and the emulator.
* Java Development Kit (JDK) 17 or newer: required by the current Android Gradle Plugin (the project builds with Gradle 9, AGP 9 and Kotlin 2).

## How the app stores data
| Data | Where | Notes |
|---|---|---|
| Pokémon, moves, abilities, items, natures, gym leaders | `assets/pokedex.db`, bundled read-only | Copied to the device once per bundled version (`_assetDbVersion` in `lib/database_helper.dart`), not on every launch. |
| Saved teams | `user.db`, created on the device | Stores IDs only; names and stats are looked up from the bundled data when a team is shown. Teams saved by older versions are imported automatically on first launch. |
| Item sprite list | `shared_preferences` | A derived cache, rebuilt automatically when the data version changes. |
| Artwork | `assets/sprites/pokemon/other/official-artwork/*.webp` | WebP, about 24 MB total. |

The main lists are loaded once per run, kept in memory and searched there. Search waits 250 ms after typing stops.

## Project layout
```
pokedex_app/
  lib/
    main.dart             app shell, drawer, search
    database_helper.dart  bundled-data access and cached lists
    user_database.dart    writable user.db and the legacy team import
    team_repository.dart  team create/rename/delete and member edits
    theme/                Material 3 theme and type colors
    widgets/              shared widgets (chips, stat bars, tiles, state views)
    pages/                one folder per screen
  assets/                 pokedex.db and artwork
  test/                   unit tests
scripts/                  Python tools for building and maintaining the database
complete-db-inserts/      SQL source for the database
```

# Instructions for Setting Up and Installing the App
## Install Flutter
### Download Flutter SDK:

* Visit the official Flutter website and download the Flutter SDK for your operating system (Windows, macOS, or Linux).
### Set Up Flutter Environment:

* Extract the downloaded Flutter SDK and add the flutter/bin directory to your system’s PATH to use Flutter commands from the terminal.
### Verify Installation:

* Open a terminal and run `flutter doctor` to verify the installation and see if any dependencies are missing.
## Install Android Studio
### Download Android Studio:

* Visit the Android Studio website and download the latest version of Android Studio for your operating system.
* Follow the installation instructions for your operating system.
### Set Up Android Studio for Flutter:

* Open Android Studio and install the Flutter and Dart plugins by going to File > Settings > Plugins (on macOS, Android Studio > Preferences > Plugins).
* If you use VS Code instead, install the Flutter and Dart extensions.
### Install Android SDK:

* Ensure that the Android SDK is installed and configured. This can be done during the Android Studio setup or via the SDK Manager in Android Studio.
## Ensure the Java SDK Is Version 17 or Newer
### Install Java Development Kit (JDK):

* Android Studio bundles a suitable JDK. If you use your own, install JDK 17 or newer.
### Set JAVA_HOME:

* If you use your own JDK, make sure the JAVA_HOME environment variable points to it. You can verify this by running `java -version` in the terminal.
## Set Up an Android Device or Emulator for Development
### Option A: Physical device
* On your Android device, go to Settings > About phone and tap on the Build number seven times to enable Developer Mode.
* In the Developer options (Settings > System > Developer options), enable USB debugging.
* Connect the device with a USB cable and accept the "Allow USB debugging" prompt on the device.
### Option B: Emulator
* In Android Studio, open Device Manager and create or start a virtual device. Wait until its home screen is showing.
## Run the App
All Flutter commands are run from the `pokedex_app` folder:

```
cd pokedex_app
flutter pub get
flutter devices
flutter run -d <device-id>
```

* `flutter devices` lists the connected phone or running emulator (for example `emulator-5554`). If your device is not listed, start the emulator or reconnect the device first.
* While the app is running, press `r` for hot reload and `R` for a full restart. After changing the bundled database or startup code, use the full restart.
* In VS Code you can instead pick the device in the status bar and press F5.

### Build a release APK
```
flutter build apk --release --split-per-abi
```
The APKs are written to `pokedex_app/build/app/outputs/flutter-apk/`. Install one on a connected device with `adb install -r <file>.apk`.

## Run the Tests and Checks
```
flutter test
flutter analyze
```

## Troubleshoot Installation Issues
### Ensure All Dependencies Are Met:

* If you encounter issues, re-run `flutter doctor` to check for any missing dependencies or configuration problems.
### Run flutter clean:

* Run `flutter clean` and `flutter pub get` to retrieve missing dependencies or configurations.
### Device not found during install:

* If the build succeeds but the install fails with "device not found", the emulator was not finished booting. Wait for its home screen and run `flutter run -d <device-id>` again.
### Old version appears on the device:

* Launching the app from the home screen runs whatever was last installed. Use `flutter run` (or F5) to install your latest code.
### Reinstall Dependencies:

* If issues persist, consider reinstalling or updating dependencies like the Android SDK or Flutter SDK.
## Launch the App
### Find the App:

* Once the installation is complete, find the app on your device’s home screen or app drawer.
## Open and Test:

* Tap the app icon to open and begin using the application.

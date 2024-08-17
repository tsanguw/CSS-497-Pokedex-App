# CSS-497-Pokedex-App
This repository is for the Pokedex Database App Project for CSS 497.

# LitWiki - The Pokémon Pokédex
This capstone project focuses on developing a Pokémon database application for Android that provides a comprehensive platform for users to research and manage all things Pokémon.
![CSS_497_Pokédex_Poster_Updated](https://github.com/user-attachments/assets/0fdd68fb-8929-45d6-bbfd-701125218f3f)

## Technologies Used
* Flutter: The primary framework for developing the app.
* Dart: The programming language used within Flutter.
* Android Studio: The integrated development environment (IDE) for Android development.
* SQLite: The database used to store Pokémon data locally on the device.
* Java Development Kit (JDK): Required for Android development, specifically JDK 11.
# Instructions for Setting Up and Installing the App
## Install Flutter
### Download Flutter SDK:

* Visit the official Flutter website and download the Flutter SDK for your operating system (Windows, macOS, or Linux).
### Set Up Flutter Environment:

* Extract the downloaded Flutter SDK and add the flutter/bin directory to your system’s PATH to use Flutter commands from the terminal.
### Verify Installation:

* Open a terminal and run flutter doctor to verify the installation and see if any dependencies are missing.
## Install Android Studio
### Download Android Studio:

* Visit the Android Studio website and download the latest version of Android Studio for your operating system.
* Follow the installation instructions for your operating system.
### Set Up Android Studio for Flutter:

* Open Android Studio and install the Flutter and Dart plugins by going to File > Settings > Plugins (on macOS, Android Studio > Preferences > Plugins).
### Install Android SDK:

* Ensure that the Android SDK is installed and configured. This can be done during the Android Studio setup or via the SDK Manager in Android Studio.
## Ensure Java SDK Version is 11
### Install Java Development Kit (JDK):

* Download and install JDK 11 if you haven’t already.
### Set JAVA_HOME:

* Ensure that the JAVA_HOME environment variable is set to point to the JDK 11 installation path. You can verify this by running java -version in the terminal.
## Set Up an Android Device for Development
### Enable Developer Mode:

* On your Android device, go to Settings > About phone and tap on the Build number seven times to enable Developer Mode.
### Enable USB Debugging:

* In the Developer options (accessible from Settings > System > Developer options), enable USB debugging to allow your device to communicate with your computer via USB.
## Connect Your Device via USB
### Connect the Device:

* Use a USB cable to connect your Android device to your computer.
### Trust the Computer:

* On your Android device, you may need to authorize the connected computer for USB debugging by accepting a prompt.
## Build and Install the App
### Run the App:
* Open your Flutter project in a terminal or in Android Studio.
* Run flutter doctor to ensure there are no issues.
* Run flutter build to create an APK of the application.
* Run flutter install to build and install the app onto the connected Android device.
## Troubleshoot Installation Issues
### Ensure All Dependencies Are Met:

* If you encounter issues, re-run flutter doctor to check for any missing dependencies or configuration problems.
### Run flutter clean:

* Run flutter clean and flutter pub get to retrieve missing dependencies or configurations.
### Reinstall Dependencies:

* If issues persist, consider reinstalling or updating dependencies like the Android SDK or Flutter SDK.
## Launch the App
### Find the App:

* Once the installation is complete, find the app on your device’s home screen or app drawer.
## Open and Test:

* Tap the app icon to open and begin using the application.

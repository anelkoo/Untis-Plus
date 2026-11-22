# Untis+ setup: builds, install, testing

This guide covers how the app gets built on GitHub Actions and how to install it on each platform. You never need a Mac.

## 1. How the builds work

Every push to `main` runs the **Build** workflow in the repo's Actions tab ( https://github.com/anelkoo/Untis-Plus/actions ):

| Job | Runs on | Output |
|---|---|---|
| check | Ubuntu | `flutter analyze`, `flutter test`, a check that no log call contains a password or session ID |
| android | Ubuntu | `UntisPlus.apk` |
| windows | Windows | `UntisPlus-windows-x64.zip` (portable), `UntisPlus-Setup.exe` (installer) |
| linux | Ubuntu 22.04 | `untis-plus_X_amd64.deb`, `Untis+-X-x86_64.AppImage`, `untis-plus-linux-x64.tar.gz` |
| arch | Arch Linux container | `untis-plus-X-1-x86_64.pkg.tar.zst` |
| ios | macOS | `UntisPlus.ipa` (unsigned, for SideStore). Only builds on tags or when started by hand |
| release | Ubuntu | On a `v*` tag, attaches all of the files above to a GitHub Release |

### Download a build from a normal push
1. Open the **Actions** tab and click the newest green **Build** run.
2. Scroll down to **Artifacts** and download `android`, `windows`, `linux` or `arch`. Each one is a zip with the files inside.

### Build the iPhone app without making a release
1. **Actions** → **Build** (left sidebar) → **Run workflow** (right side).
2. Keep "Also build the iOS .ipa" ticked and click **Run workflow**.
3. After about 10–15 minutes, download the `ios` artifact from that run and unzip it to get `UntisPlus.ipa`.

### Make a release with every file
```powershell
git tag v0.0.2
```
```powershell
git push origin v0.0.2
```
Bump `version:` in `pubspec.yaml` first, so the packages get the right version number. When the run finishes, everything is on the **Releases** page ( https://github.com/anelkoo/Untis-Plus/releases ).

## 2. Install on iPhone with SideStore

You need SideStore already set up on the iPhone (with its pairing file and the LocalDevVPN/StosVPN connection it uses).

1. On the iPhone, open the Release page (or the downloaded `ios` artifact) in Safari and download `UntisPlus.ipa`. It ends up in the Files app under *Downloads*.
2. Open **SideStore** → **My Apps** → **+** (top left), then pick `UntisPlus.ipa`.
3. SideStore signs the app with your Apple ID and installs it. SideStore asks whether to keep the app extension: choose **Keep**, otherwise the home screen widget is removed.
4. A free Apple ID allows **3 active sideloaded apps** (SideStore itself counts as one) and **10 App IDs per 7 days**. Untis+ uses one app slot, plus one App ID for the app and one more for the widget later.
5. Apps signed with a free Apple ID expire after **7 days**. SideStore's background refresh renews them. Open SideStore every few days to be safe.
6. To update, install the new `.ipa` the same way. Your login and cache stay.

### Add the widget (iPhone)
1. Open Untis+ once after installing, so it can hand the widget your timetable.
2. Long-press the home screen → **Edit** → **Add Widget** → **Untis+** → small or medium.
3. The widget never goes online. It moves on to the next lesson by itself and gets new data whenever you open the app. If it says "Öffne Untis+ einmal", open the app.

If the widget stays on "Öffne Untis+ einmal" even after opening the app, SideStore set up the app group differently than expected. Tell the developer.

## 3. Install on Android

1. Download `UntisPlus.apk` onto the phone.
2. Open it. Android asks you to allow installs from your browser or file manager. Allow it, then tap **Install**.
3. Updates install over the old version because every CI build is signed with the same key (see section 6).
4. Widgets: long-press the home screen → **Widgets** → **Untis+** → **Nächste Stunde** (small) or **Heute** (medium). They update at every lesson change and when the app refreshes (in the background every 2 hours).

## 4. Install on Windows

- **Installer:** run `UntisPlus-Setup.exe`. It installs for your user only (no admin rights) and adds a Start menu entry. Windows SmartScreen may warn about an unknown publisher. Click **More info** → **Run anyway**.
- **Portable:** unzip `UntisPlus-windows-x64.zip` anywhere and run `untis_plus.exe`.

## 5. Install on Linux

**Debian, Ubuntu, Mint, Pop!_OS:**
```bash
sudo apt install ./untis-plus_0.0.1_amd64.deb
```

**Arch, Manjaro, EndeavourOS:**
```bash
sudo pacman -U untis-plus-0.0.1-1-x86_64.pkg.tar.zst
```

**Any other distro (Fedora, openSUSE, …) with the AppImage:**
```bash
chmod +x Untis+-0.0.1-x86_64.AppImage && ./Untis+-0.0.1-x86_64.AppImage
```
The AppImage uses the system's GTK 3 and libsecret. On Fedora: `sudo dnf install gtk3 libsecret`. On openSUSE: `sudo zypper install gtk3 libsecret-1-0`.

**Fallback:** unpack `untis-plus-linux-x64.tar.gz` and run `bundle/untis_plus`.

Start it with `untis-plus` or from the app menu (.deb and Arch package). "Remember me" needs a running keyring (GNOME Keyring or KWallet). Without one, you have to log in every time.

## 6. Android signing key (already set up)

The Android release key was generated on the dev PC in `%USERPROFILE%\.untisplus\` (`upload-keystore.jks` + `keystore.properties`). It is stored in the repo's GitHub secrets as `ANDROID_KEYSTORE_B64` and `ANDROID_KEYSTORE_PROPERTIES`. **Back up that folder.** If the key is lost, the next APK won't install over the old one, and you'd have to uninstall first and lose your login and cache. Never commit it, because the repo is public.

## 7. Developing on this PC

- Turn on **Windows Developer Mode** once (Settings → System → For developers). Flutter plugins need symlinks. Open the page with:
  ```powershell
  start ms-settings:developers
  ```
- Run on the Android emulator (start one from Android Studio's Device Manager):
  ```powershell
  flutter run
  ```
- Run as a Windows app:
  ```powershell
  flutter run -d windows
  ```
- Tests:
  ```powershell
  flutter test
  ```

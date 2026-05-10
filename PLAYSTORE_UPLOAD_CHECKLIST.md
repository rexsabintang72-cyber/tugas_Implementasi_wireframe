# Play Store Upload Checklist for catatin

## Already Prepared
- App name set to `catatin`
- Package name set to `com.ti24a6.app25`
- App icon source added to project
- Store description draft created
- Privacy policy draft created
- Release signing template prepared

## Still Needed Before Upload
1. Create a real release keystore
2. Fill `android/key.properties` from `android/key.properties.example`
3. Build release AAB
4. Create Play Console app entry
5. Upload app icon, screenshots, and feature graphic in Play Console
6. Paste short and full description from `PLAYSTORE_DESCRIPTION.md`
7. Host `PRIVACY_POLICY.md` online and paste the public URL into Play Console
8. Complete Data Safety form
9. Complete Content Rating questionnaire
10. Complete App Access declaration

## Build Commands
```powershell
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle --release
```

## Suggested Screenshots
- Home page light mode
- Home page dark mode
- Add note page
- Login / register page
- Profile and account switch page

## App Access Note for Play Review
Because catatin supports local account login, you can explain in Play Console:
- reviewer can create a local account directly in the app
- no external server account is required
- no special invite code is needed

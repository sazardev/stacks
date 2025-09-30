# 🔐 Firebase Configuration Setup Guide

## ⚠️ IMPORTANT: Security Notice

The Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`) contain **sensitive API keys and credentials** and are **NOT included in version control** for security reasons.

You must obtain and configure these files yourself before running the application.

---

## 📋 Prerequisites

1. Access to the Firebase Console (https://console.firebase.google.com)
2. Project Administrator or Editor permissions
3. Flutter SDK installed (see main README.md)

---

## 🔧 Setup Instructions

### Step 1: Download Android Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select the **Stacks Restaurant Management** project
3. Click the **gear icon** (⚙️) → **Project settings**
4. Scroll to **Your apps** section
5. Select the **Android app** (package: `com.example.stacks` or your configured package)
6. Click **Download google-services.json**
7. Place the file in: `android/app/google-services.json`

### Step 2: Download iOS Configuration

1. In Firebase Console → **Project settings**
2. Select the **iOS app** (Bundle ID: your configured ID)
3. Click **Download GoogleService-Info.plist**
4. Place the file in: `ios/Runner/GoogleService-Info.plist`

### Step 3: Verify Files Are in Place

Run this command to verify:

```powershell
# Check Android config
Test-Path "android/app/google-services.json"

# Check iOS config (on macOS)
Test-Path "ios/Runner/GoogleService-Info.plist"
```

Both should return `True`.

### Step 4: Verify .gitignore Protection

Ensure these files are properly ignored:

```powershell
git status
```

You should **NOT** see `google-services.json` or `GoogleService-Info.plist` in the list of changed files.

---

## 🧪 Test Firebase Connection

Run the app to test Firebase connectivity:

```powershell
flutter run
```

Look for these success messages in the console:
- ✅ Firebase initialized successfully
- ✅ Firestore structure initialized
- ✅ Dependency injection configured

---

## 🔒 Security Best Practices

### DO ✅
- Keep configuration files **LOCAL ONLY**
- Add them to `.gitignore` (already done)
- Store production keys in secure team vault (1Password, LastPass, etc.)
- Use different Firebase projects for dev/staging/production
- Rotate API keys if accidentally exposed

### DON'T ❌
- **NEVER** commit `google-services.json` or `GoogleService-Info.plist` to git
- **NEVER** share these files via email or Slack
- **NEVER** post configuration files in public forums
- **NEVER** use production keys in development

---

## 🚨 What If I Accidentally Committed Config Files?

If you accidentally committed sensitive files:

1. **Immediately remove from git history:**
   ```powershell
   git rm --cached android/app/google-services.json
   git commit -m "Remove sensitive Firebase config"
   git push
   ```

2. **Rotate all API keys in Firebase Console:**
   - Go to Project Settings → Service Accounts
   - Generate new keys
   - Download fresh configuration files
   - Update your local files

3. **Notify your team lead immediately**

---

## 📝 File Structure

After setup, your project should look like this:

```
android/
  app/
    google-services.json         ✅ (exists, not in git)
    build.gradle.kts

ios/
  Runner/
    GoogleService-Info.plist     ✅ (exists, not in git)
    Info.plist

.gitignore                       ✅ (configured to ignore configs)
```

---

## 🆘 Troubleshooting

### Error: "google-services.json missing"
- **Solution:** Download from Firebase Console (see Step 1)

### Error: "Firebase initialization failed"
- **Solution:** Verify your `google-services.json` matches your app's package name
- Check that Firebase project has Firestore enabled

### Error: "Configuration file appears in git status"
- **Solution:** Run `git rm --cached <filename>` to remove from tracking
- Verify `.gitignore` contains the file pattern

### Need Access to Firebase Project?
- Contact: [PROJECT ADMIN EMAIL/NAME]
- Request: Firebase Console access as Editor or Viewer
- Include: Your Google account email

---

## 📚 Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- Main Project README: `../README.md`

---

**Last Updated:** September 30, 2025  
**Maintained By:** Development Team

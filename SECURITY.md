# 🔐 Security Guide - API Key Protection

## ⚠️ Critical Security Issue Fixed

Your Google Gemini API Key was exposed in the public GitHub repository. This guide explains what was done and how to prevent it in the future.

---

## ✅ What Has Been Done

### 1. **Environment Variables Setup**

- Created `.env` file to store sensitive API keys
- Added `flutter_dotenv` package to load environment variables
- Updated `ApiConstants` to load keys from `.env` instead of hardcoding

### 2. **Git Ignore Configuration**

- Updated `.gitignore` to prevent `.env` from being committed
- Added rules to ignore `api_constants.dart`

### 3. **Code Updates**

- Modified `main.dart` to load `.env` before app startup
- Updated `pubspec.yaml` with new dependencies

---

## 🔴 IMMEDIATE ACTIONS REQUIRED

### Step 1: Revoke Exposed API Key

**⚠️ This is CRITICAL and must be done immediately!**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Find and click on the exposed API Key
5. Select **DELETE**
6. Confirm the deletion

**⚠️ DO NOT use this key anymore!**

### Step 2: Create a New API Key

1. In the **Credentials** page, click **Create Credentials** → **API Key**
2. Restrict the key to:
   - **Application Restrictions**: Android apps
   - **Package name**: `com.assistant`
   - **API Restrictions**: Generative Language API
3. Copy the new API key

### Step 3: Update .env File

```bash
# Replace YOUR_NEW_API_KEY_HERE with your new API key
GEMINI_API_KEY=AIza_YOUR_NEW_KEY_HERE
```

### Step 4: Clean Git History (Remove Exposed Key)

```bash
# Option A: Remove file from entire history (Recommended)
git filter-branch --tree-filter 'rm -f lib/core/constants/api_constants.dart' -- --all

# Or Option B: Use git-filter-repo (if installed)
git filter-repo --path lib/core/constants/api_constants.dart --invert-paths

# After cleaning history, force push (⚠️ This rewrites history!)
git push origin --force --all
git push origin --force --tags
```

**⚠️ Warning: Force pushing rewrites git history. Notify team members!**

### Step 5: Verify Cleanup

```bash
# Check if api_constants.dart is still in git history
git log --all --full-history -- lib/core/constants/api_constants.dart

# Should return nothing or "commit not found"
```

---

## 📁 New Project Structure

```
project/
├── .env                          ← NEW: Stores API keys (ignored by git)
├── .gitignore                    ← UPDATED: Ignores .env and api_constants.dart
├── pubspec.yaml                  ← UPDATED: Added flutter_dotenv
├── lib/
│   ├── main.dart                 ← UPDATED: Loads .env file
│   └── core/constants/
│       └── api_constants.dart    ← UPDATED: Loads from environment
└── android/
```

---

## 🚀 How to Use After Deployment

### For Development

1. Create `.env` file in project root:

   ```
   GEMINI_API_KEY=your_development_key
   ```

2. Run normally:
   ```bash
   flutter pub get
   flutter run
   ```

### For Production Build

1. Ensure `.env` is included in the APK/App Bundle
2. The app will automatically load the API key from `.env`

### For CI/CD Pipelines

Store the API key as a secret environment variable:

**GitHub Actions Example:**

```yaml
- name: Create .env file
  run: |
    echo "GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}" > .env
```

---

## 🛡️ Best Practices

### ✅ DO:

- ✅ Store sensitive keys in `.env`
- ✅ Add `.env` to `.gitignore`
- ✅ Use environment-specific `.env` files (.env.local, .env.prod)
- ✅ Rotate API keys regularly
- ✅ Use API key restrictions in Google Cloud
- ✅ Enable monitoring and alerts for API usage

### ❌ DON'T:

- ❌ Hardcode API keys in source code
- ❌ Commit `.env` to git
- ❌ Share API keys in chat or email
- ❌ Use the same API key in dev and production
- ❌ Leave API keys without restrictions
- ❌ Ignore security warnings from GitHub

---

## 🔍 GitHub Security Alerts

GitHub will automatically notify you if secrets are detected in code. If you see alerts:

1. **Dismiss the alert** (it's now fixed)
2. **Review the fix** to ensure no code is using hardcoded keys
3. **Verify the key was revoked** on Google Cloud

---

## 📊 API Key Restrictions (Best Practice)

For this app, configure your API key with:

```
Name: SakoAI Gemini
Application Restrictions:
  - Type: Android apps
  - Package name: com.assistant
  - SHA-1: [Your app's SHA-1]

API Restrictions:
  - Google Generative Language API

Rate Limiting:
  - Set quotas to prevent unauthorized usage
```

---

## 🆘 If Key Was Already Used Maliciously

1. **Revoke immediately** (already done)
2. **Check Google Cloud billing** for unusual usage
3. **Review API usage logs** in Cloud Console
4. **Contact Google Cloud support** if suspicious activity detected
5. **Consider disabling the API** temporarily

---

## ✅ Verification Checklist

Before deploying to GitHub:

- [ ] `.env` is added to `.gitignore`
- [ ] Old API key is revoked on Google Cloud
- [ ] New API key is stored in `.env`
- [ ] `flutter_dotenv` is added to `pubspec.yaml`
- [ ] `main.dart` loads `.env` on startup
- [ ] No hardcoded keys remain in source
- [ ] Git history cleaned (force push done)
- [ ] All team members notified of changes
- [ ] CI/CD pipelines updated with new key

---

## 📚 Resources

- [Flutter Security Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Google Cloud API Keys](https://cloud.google.com/docs/authentication/api-keys)
- [flutter_dotenv Documentation](https://pub.dev/packages/flutter_dotenv)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

---

## 💬 Questions?

If you need help:

1. Check GitHub's security documentation
2. Review the flutter_dotenv package docs
3. Contact Google Cloud support for API key issues

**Remember: Security is everyone's responsibility!** 🔒

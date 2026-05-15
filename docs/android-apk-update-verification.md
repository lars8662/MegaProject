# Android debug APK update verification checklist

This checklist verifies that GitHub Actions Android debug APK artifacts for Climbing Diary / Дневник скалолаза can update an already installed APK without uninstalling the app and deleting local test data.

## Current APK identity and CI signing inputs

- Current `applicationId`: `com.zalim.climbingdiary`.
- Current GitHub secret name for the persistent CI debug keystore: `ANDROID_DEBUG_KEYSTORE_BASE64`.

## Why matching identity and signing matter

Android installs a new APK over an existing installed app only when both of these values match the installed app:

1. The same Android package name / `applicationId`.
2. The same signing certificate.

If either the `applicationId` or signing certificate changes, Android treats the APK as a different or incompatible app update and will not install it over the existing app. Keeping `com.zalim.climbingdiary` and the same persistent CI debug signing certificate is therefore required for future GitHub Actions APK artifacts to update previous artifacts in place.

The Android debug APK workflow restores the persistent debug keystore from the GitHub secret `ANDROID_DEBUG_KEYSTORE_BASE64`, explicitly signs debug APKs with it, uses `github.run_number` as the build number, and verifies that the APK signer SHA-256 matches the CI debug keystore SHA-256.

## Local data safety

Android stores app-local data, including `SharedPreferences`, in the app's private data directory on the device. When the app is uninstalled, Android removes that private data directory. For this app, uninstalling before installing another APK can delete locally stored training data and preferences.

Install the new APK over the existing APK whenever possible to preserve local `SharedPreferences` data.

## One-time transition warning

The first transition from older APK artifacts signed with ephemeral debug signing to APK artifacts signed with the new persistent CI debug keystore may require one uninstall. That one-time uninstall can delete local app data.

After installing the first APK signed with the persistent CI debug keystore, future GitHub Actions APK artifacts should install over it without uninstalling, as long as the `applicationId` and signing certificate stay the same.

## Secret and keystore safety

Do not commit `debug.keystore`, any other debug keystore file, base64-encoded keystore contents, or any other secrets.

Keep the persistent CI debug keystore value only in GitHub Secrets under `ANDROID_DEBUG_KEYSTORE_BASE64`.

## Manual verification checklist

1. Install APK #1 from a successful GitHub Actions run after the signing fix.
2. Open the app.
3. Create a test training named “ТЕСТ UPDATE SIGNING”.
4. Close and reopen the app.
5. Confirm the test training remains.
6. Trigger a new GitHub Actions run or merge a small PR.
7. Download APK #2.
8. Install APK #2 over APK #1 without uninstalling.
9. Open the app.
10. Confirm “ТЕСТ UPDATE SIGNING” is still present.

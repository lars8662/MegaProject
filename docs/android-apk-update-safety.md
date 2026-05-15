# Android APK update and data safety checklist

This project builds Android debug APK artifacts through GitHub Actions for smartphone-based testing of Climbing Diary / Дневник скалолаза.

## Why uninstalling deletes local data

Android stores app-local data, including `SharedPreferences`, inside the installed app's private data directory. When the app is uninstalled, Android removes that private data directory. For this app, uninstalling before installing a new APK can therefore delete locally stored training data and other preferences.

To preserve local test data, install a new APK over the previous APK instead of uninstalling first whenever possible.

## What Android requires for APK updates

Android treats an APK as an update to an existing installed app only when both of these stay the same:

1. The Android package name / `applicationId`.
2. The signing certificate used to sign the APK.

Current `applicationId`:

```text
com.zalim.climbingdiary
```

Current GitHub Actions debug keystore secret name:

```text
ANDROID_DEBUG_KEYSTORE_BASE64
```

The persistent CI debug keystore is intended to keep GitHub Actions APK artifacts signed with the same debug signing certificate across workflow runs. After the persistent keystore is in use, future APKs should install over previous APKs if they keep the same `applicationId` and are signed with the same keystore.

## One-time transition warning

The first transition from older APKs signed with ephemeral debug signing to APKs signed with the persistent CI debug keystore may require one uninstall. That uninstall can delete local app data.

After that transition, future APK artifacts from GitHub Actions should install over earlier artifacts without uninstalling, as long as the same `applicationId` and signing certificate are preserved.

## Secret and keystore safety

Do not commit any debug keystore file, such as `debug.keystore`.

Do not commit base64-encoded keystore contents or other secrets. Keep the CI keystore value only in GitHub Secrets under `ANDROID_DEBUG_KEYSTORE_BASE64`.

## Manual verification checklist

1. Install APK #1 from GitHub Actions on the phone.
2. Create a test training in the app.
3. Run GitHub Actions again to produce APK #2.
4. Install APK #2 over APK #1 without uninstalling APK #1.
5. Verify the test training data remains available after APK #2 starts.

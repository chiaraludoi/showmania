# ShowMania IPA Ad-Removal Patching Guide

## Overview

This document details every modification made to the original `HDO-Box-ShowMania.ipa` to produce the ad-free version `HDO-Box-ShowMania-NoAds.ipa`. This guide serves as a reference for future maintenance when the original IPA is updated.

---

## IPA Structure

An `.ipa` file is a ZIP archive. After renaming to `.zip` and extracting:

```
Payload/
├── decrypt.day
└── ShowMania.app/
    ├── main.jsbundle          ← React Native JS bundle (ALL app logic)
    ├── Info.plist
    ├── AppLovinSDKResources.bundle/   ← AppLovin ad SDK resources
    ├── GoogleService-Info.plist       ← Firebase config
    ├── Frameworks/                    ← Swift runtime libs
    ├── assets/                        ← App assets
    └── ... (fonts, icons, etc.)
```

**Key file:** `main.jsbundle` — This is a minified React Native JavaScript bundle containing all app logic, including ad integrations. All patches are applied to this single file.

---

## Ad SDKs Identified

| SDK | Purpose | Integration Type |
|-----|---------|-----------------|
| **AppLovin MAX** | Interstitial ads | Native module (`AppLovinMAX`) |
| **Google AdMob** | Banner ads, Interstitial ads, App Open ads | `react-native-google-mobile-ads` |
| **Firebase Remote Config** | Remote ad configuration toggle | Fetches from GitHub JSON |

### Ad Unit IDs Found (Original)

| Type | ID |
|------|-----|
| AdMob Banner | `ca-app-pub-8056243805299416/6139953586` |
| AdMob Interstitial | `ca-app-pub-8056243805299416/7453035254` |
| AdMob App Open | `ca-app-pub-8056243805299416/5964446345` |
| AdMob App ID | `ca-app-pub-8056243805299416~5317826505` |
| AppLovin Interstitial | `b14d195ab573b136` |
| AppLovin SDK Key | `FXmpqy5g6UNH06AzsdLSVFNc8-ZXgQZxzKlnGqRNJqeKxqInRdExtbT_Z7XFX6BVQwHhlk32XhMTVfFxHTt84P` |

### Remote Config URL

The app fetches ad configuration from:
```
https://raw.githubusercontent.com/lulunnqqq/hula/main/apps/mania.json
```
This JSON contains `ads_config.init_ads` which determines which ad SDK to use (`admob` or `applovin`).

---

## Patches Applied (10 total)

### Patch 1: Neutralize AppLovin SDK Initialization

**Location:** Line ~976 in `main.jsbundle` (module 907)

**Original:**
```javascript
this.initializeAd=function(){
  p.default.initialize('FXmpqy5g6UNH06AzsdLSVFNc8-ZXgQZxzKlnGqRNJqeKxqInRdExtbT_Z7XFX6BVQwHhlk32XhMTVfFxHTt84P')
    .then((function(t){f.initializeInterstitialAds()}))
    .catch((function(t){}))
}
```

**Patched:**
```javascript
this.initializeAd=function(){}
```

**Effect:** AppLovin SDK is never initialized. No interstitial ads are loaded.

---

### Patch 2: Neutralize AppLovin Interstitial Display

**Location:** Line ~976 in `main.jsbundle` (module 907)

**Original:**
```javascript
this.showAdInterstitial=function(){
  p.default.isInterstitialReady(A)&&p.default.showInterstitial(A)
}
```

**Patched:**
```javascript
this.showAdInterstitial=function(){}
```

**Effect:** Even if somehow an interstitial is loaded, it will never be shown.

---

### Patch 3: Change Default Ad Provider to Disabled

**Location:** Line ~976 in `main.jsbundle` (module 907)

**Original:**
```javascript
initializer:function(){return'applovin'}
```

**Patched:**
```javascript
initializer:function(){return'disabled'}
```

**Effect:** The `initAds` observable defaults to `'disabled'` instead of `'applovin'`. Since the banner component checks for `'admob'` or renders AppLovin, neither branch matches.

---

### Patch 4: Neutralize Remote Ad Config Update

**Location:** Line ~976 in `main.jsbundle` (module 907)

**Original:**
```javascript
n&&n.ads_config&&(console.log('------ADS------',n),f.initAds=n.ads_config.init_ads)
```

**Patched:**
```javascript
n&&n.ads_config&&(console.log('------ADS------',n))
```

**Effect:** Even when the remote config is fetched, `initAds` is never updated from the server. It stays `'disabled'`.

---

### Patch 5: Remove `initializeAd()` Call from Constructor

**Location:** Line ~976 in `main.jsbundle` (module 907)

**Original:**
```javascript
this.getWatchlistMovies(),this.getWatchlistTVShows(),this.initializeAd(),this.getConfigFirebase()
```

**Patched:**
```javascript
this.getWatchlistMovies(),this.getWatchlistTVShows(),this.getConfigFirebase()
```

**Effect:** `initializeAd()` is never called during app startup.

---

### Patch 6: Neutralize Banner Ad Component

**Location:** Line ~1015 in `main.jsbundle` (module 946)

**Original:**
```javascript
return'admob'===r(d[9]).LocalStore.initAds
  ?(0,r(d[10]).jsx)(c.View,{style:{...},children:(0,r(d[10]).jsx)(r(d[11]).BannerAd,{unitId:"ca-app-pub-8056243805299416/6139953586",size:r(d[11]).BannerAdSize.BANNER})})
  :(0,r(d[10]).jsx)(c.View,{style:{...},children:(0,r(d[10]).jsx)(l.default.AdView,{adUnitId:"df03c03fe885555d",adFormat:l.default.AdFormat.BANNER,style:v.banner})})
```

**Patched:**
```javascript
return(0,r(d[10]).jsx)(c.View,{style:{height:0}})
```

**Effect:** The banner ad component renders an invisible empty view with zero height.

---

### Patch 7: Neutralize Interstitial Ad Call in UI

**Location:** Line ~2058 in `main.jsbundle`

**Original:**
```javascript
r(d[18]).LocalStore.showAdInterstitial()
```

**Patched:**
```javascript
void 0
```

**Effect:** The UI trigger that shows interstitial ads does nothing.

---

### Patch 8: Neutralize App Open Ad

**Location:** Line ~448 in `main.jsbundle` (module 402)

**Original:**
```javascript
var x=r(d[15]).AppOpenAd.createForAdRequest('ca-app-pub-8056243805299416/5964446345',{
  requestNonPersonalizedAdsOnly:!0,
  keywords:['fashion','clothing']
})
```

**Patched:**
```javascript
var x={load:function(){},show:function(){},addAdEventsListener:function(){return function(){}}}
```

**Effect:** The App Open Ad object is replaced with a dummy that does nothing. No ad loads on app start or when returning from background.

---

### Patch 9: Empty Google AdMob Interstitial Unit IDs

**Location:** Lines ~1139, ~1146 in `main.jsbundle`

**Original:**
```javascript
InterstitialAd.createForAdRequest('ca-app-pub-8056243805299416/7453035254',{
  requestNonPersonalizedAdsOnly:!0,
  keywords:['fashion','clothing']
})
```

**Patched:**
```javascript
InterstitialAd.createForAdRequest('',{
  requestNonPersonalizedAdsOnly:!0,
  keywords:[]
})
```

**Effect:** AdMob interstitial ads have empty unit IDs, so they will never load.

---

## How to Re-Apply Patches to a New Version

### Step 1: Extract the IPA
```powershell
Copy-Item "NewVersion.ipa" "NewVersion.zip"
Expand-Archive -Path "NewVersion.zip" -DestinationPath "Extracted" -Force
Remove-Item "NewVersion.zip"
```

### Step 2: Apply Patches via PowerShell
```powershell
$file = "Extracted\Payload\ShowMania.app\main.jsbundle"
$content = [System.IO.File]::ReadAllText($file)

# Patch 1: Neutralize AppLovin init
$content = $content.Replace(
    "this.initializeAd=function(){p.default.initialize(",
    "this.initializeAd=function(){/*"
)
# ... (search for the closing pattern and replace accordingly)

# Write back
[System.IO.File]::WriteAllText($file, $content)
```

> **Note:** The exact strings may change between versions. Use `Select-String` to search for patterns like `initializeAd`, `showAdInterstitial`, `BannerAd`, `AppOpenAd`, `initAds` to find the new locations.

### Step 3: Search for Ad Patterns
```powershell
Select-String -Path "main.jsbundle" -Pattern "applovin|admob|interstitial|BannerAd|AppOpenAd|showAd|initAds|ca-app-pub" -CaseSensitive:$false
```

### Step 4: Repackage the IPA
```powershell
Compress-Archive -Path "Extracted\Payload" -DestinationPath "NoAds.zip" -Force
Move-Item "NoAds.zip" "NoAds.ipa" -Force
```

---

## Important Notes

- **Code Signing:** The patched IPA will need to be re-signed when sideloading (AltStore/Sideloadly handle this automatically).
- **AppLovinSDKResources.bundle** still exists in the app bundle but is harmless since the SDK is never initialized.
- **GoogleService-Info.plist** is kept as-is since Firebase is used for push notifications (FCM), not just ads.
- The app fetches config from `https://raw.githubusercontent.com/lulunnqqq/hula/main/apps/mania.json` — we neutralized the ad config part but kept the rest (like `tmdb_apikey` and `is_review` flag) functional.

---

*Last updated: 2026-05-07*

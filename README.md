# Leonida Locker — Unofficial Companion for GTA VI

An iPhone companion app for **Grand Theft Auto VI** (released Nov 19, 2026, PS5 / Xbox Series X|S): one searchable catalog for every clothing store, hairstyle, tattoo, gun and mod shop in Leonida, plus a community map, a garage livery finder, and saved favorites.

- **Platform:** iPhone only · SwiftUI · iOS 17+
- **Category:** Reference · Free download · Expected rating 13+
- **Status:** v1 scaffold + seeded data, built on Linux without Xcode. **Not yet compiled** — first compile happens on a Mac or in CI (see below).

> **Disclaimer (also in-app, in onboarding, and in the App Store description):**
> "[App Name] is an independent, fan-made companion app for Grand Theft Auto VI. It is not affiliated with, endorsed, sponsored or approved by Rockstar Games or Take-Two Interactive. Grand Theft Auto, GTA and GTA VI are trademarks of Take-Two Interactive Software, Inc. This app does not contain the game and does not provide game downloads, mods or modified files. All information comes from public sources and community research."

---

## ✅ APP NAME — DECIDED: "Leonida Locker" (Paul, Nov 26, 2026)

The app is named **"Leonida Locker"** (`AppConfig.appDisplayName`, Xcode display name, launch screen). It was checked against live App Store / web listings before the decision: "Leonida Ledger", "Leonida Atlas", "Vice Vault", "Leonida List", "Leonida Garage", "Vice Finds" and "Vice City Index" are all taken, and "GTA Hub" is taken several times over (GTAHub Pro in-app purchases, a "GTA6 HUB" app, a "GTA Hub" guide site) — "GTA" also stays out of the title for trademark safety. "Leonida Locker" had no collision.

**History note:** the v1 scaffold was provisionally called **"Leonida Companion"**. That name was dropped Nov 26, 2026: it collides with the live App Store app "Leonida: GTA 6 Companion Guide" (plus "Leonida Guide" / "Leonida Navigator") — a Guideline 2.3.7 / 4.1 risk. The old name survives only in history notes (here and in two code comments in `AppConfig.swift` / `LeonidaCompanionApp.swift`).

**Before submission Paul must still:** verify "Leonida Locker" is unique in App Store search at submission time (search the exact name; check for look-alikes). The subtitle pattern "Unofficial Companion for GTA VI" is the safe one.

---

## How to build (on a Mac)

Requirements: **Xcode 16+** (Swift 5, iOS 17 SDK), macOS with the iOS Simulator.

```bash
git clone <repo>
cd gta-vi-companion
open LeonidaCompanion.xcodeproj
# Select scheme "LeonidaCompanion", pick any iPhone simulator, press Run.
```

Or from the command line (no signing — simulator only):

```bash
xcodebuild build \
  -project LeonidaCompanion.xcodeproj \
  -scheme LeonidaCompanion \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO
```

CI does exactly this on every push to `main` (`.github/workflows/ios.yml`, `macos-latest` runner), plus a JSON-validation step. **This project has not been compiled yet** — it was authored on a Linux VM with no Xcode/Swift toolchain. The first CI run is the first compile; expect small fix-ups there.

### fastlane

```bash
cd fastlane && bundle install
bundle exec fastlane build   # simulator build, no signing
bundle exec fastlane beta    # STUB — refuses to run until enrollment + Appfile are real
```

---

## What the app does

| Tab | What it does |
|---|---|
| **Map** | Community Leonida map with searchable/filterable pins (clothing, footwear, mod shop, gun store, salon, tattoo). Filter chips per kind, text search, tap a pin for details. Attribution line is always visible on the map. |
| **Store** | Unified searchable catalog. **Clothing** — 67 stores by category/brand + a sample item list + a "being cataloged" state (full per-item catalogs don't exist yet). **Hairstyles** — 18 salons. **Tattoos** — 11 parlors. **Guns** — weapons by class with prices + 24 gun stores with tiers. Search across names, filter by county, sort weapons by price/name. Item detail shows price, selling store, edition flag, verified badge, source note. |
| **Garage** | All 14 mod shops + the 6 mod categories (Pro Builds, Cosmetics, Bodywork, Performance incl. nitrous, Wheels, Interior). **"Find a livery/mod" search** with shop attribution — Vice Vinyl and One-Eyed Willie's called out as the livery specialists. Pay 'n' Spray as its own section (count + note, no invented locations). 27 confirmed vehicle names. |
| **Saved** | Favorites/bookmarks across all domains, persisted locally in UserDefaults (plain list of IDs — no account, no sync). Sections per domain, swipe-to-remove. |

Also: **first-run onboarding** (disclaimer + "This app does not contain the game"), **About & Credits** (disclaimer, source/license credits, version), and a **Data Status** screen listing what's verified vs being cataloged per domain.

### What's interactive (Guideline 4.2 minimum functionality)

Map + search + filters + favorites + trackers (saved) + detail views. No community pins/comments in v1 — deliberately, to avoid the Guideline 1.2 user-generated-content moderation burden. That is a future-feature decision, not an oversight; if it ever ships, it needs moderation tooling first.

---

## What's real data vs placeholder / being cataloged

Seeded data (verified Nov 26, 2026, in `LeonidaCompanion/Data/*.json` — every record has `id` + `source` + `verified`):

| Domain | Seeded | Status |
|---|---|---|
| Clothing stores | 67 | Verified list. Same-brand branches share stock. |
| Footwear stores | 17 | Verified list. |
| Mod shops | 14 | Verified list. No "Los Santos Customs" in GTA VI. 2 Ultimate Edition only. |
| Gun stores | 24 | Verified list. Tiers: 15 Standard, 6 Expanded, 2 Hunting, 1 Limited. |
| Weapons | 41 priced entries | Guide-reported prices (NOT Rockstar-published). 53 base guns / 10 classes / 120+ variants. Shotgun (11) and sniper (5) classes seed only the published price endpoints + counts — middle entries are **not invented**. "Duke 1922" is flagged: some sources say "Duke 1992" (note on the record). Molotov price unconfirmed (null, never estimated). Carry limit: 2 sidearms + 2 long guns. |
| Vehicles | 27 names | Only confirmed names (post-story cheat-spawn list + edition vehicles). The 557 total (277 base + 280 Standout) is counted, not listed — a 557-name list is **not invented**. |
| Hair salons | 18 | Verified list. Per-salon hairstyle catalogs being cataloged. |
| Tattoo parlors | 11 | Verified list. Price range $53–$14,700. Magazine tattoos (13 Jason / 15 Lucia / 17 shared) are counts only. |
| Clothing items | 2 sample items | Schema + sample only (Switchblade $290, Body Armor $250). Full catalogs don't exist yet (NiaDB 275 priced pieces; The Games Wiki 168 entries, 3 Mariana stores). |
| Map pins | 151 | **All approximate** — district-level placements on the pre-launch community map layout, `verified=false`, labeled "approximate location" in the UI. 0/798 GTA6Maps.io pins were game-verified as of Nov 20, 2026. |

**Rules the code follows:** never invent items, prices, locations, or coordinates. Unverified records get `verified=false` and a "Being cataloged" badge in the UI. Prices that are unconfirmed are `null`, never estimated.

### Map tiles — NOT bundled, NOT hotlinked

The map shows a **stylized placeholder base** (original drawn shapes, clearly labeled "Community map — tiles not bundled; see README") with pins and search working over it. The GTADB repo asks users not to fetch its live data, so the app never hotlinks gtadb.org.

To use real tiles, self-host the GTADB YANIS tiles and set the template in `LeonidaCompanion/App/AppConfig.swift`:

```swift
static let mapTileURLTemplate = "https://tiles.example.com/yanis/{z}/{x}/{y}.png"
```

Self-hosting instructions: clone [github.com/rolux/gtadb.org](https://github.com/rolux/gtadb.org), follow its tile-export/README, host the tile directory on any static host, and paste the URL template above (`{z}` zoom, `{x}` column, `{y}` row). When set, the app layers an `MKTileOverlay` over MapKit instead of the placeholder.

**Caveat, shown in-app:** the GTADB map is a pre-launch community reconstruction from trailers/screenshots, not the retail in-game map. Street geometry is good; names, borders, and distances are unverified vs the released game.

---

## Data sources & licenses

| Source | Use | License |
|---|---|---|
| GTADB (map.gtadb.org, github.com/rolux/gtadb.org) | YANIS V17/V18 map tiles + landmark data | CC BY 4.0 (code MIT). Attribution on the map view + Credits screen: "Map tiles © YANIS / GTA VI Mapping Community via gtadb.org (CC BY 4.0)"; "Map data: GTADB community (CC BY 4.0)". |
| GTA6Maps.io dataset (gta6maps.io/gta-6/map-data; GitHub duanhesen/gta6-leonida-map-data; Zenodo DOI 10.5281/zenodo.24412576) | 798 markers, normalized 0–1 x/y | CC BY 4.0, credit GTA6Maps + link back. |
| GTA Wiki (Fandom), Grand Theft Wiki | Plain facts, own writing, with attribution | CC BY-SA / CC BY-SA 3.0. No verbatim text, no screenshots. |
| The Games Wiki | Plain facts, own writing | CC BY-SA 4.0. |
| GTA VI Wire | Plain facts | Original text CC BY 4.0. |
| PowerPyx, KeenGamer, Dexerto, GTA6Gang/NiaDB, Fextralife | Plain facts only (names, locations, counts, prices) | Commercial/proprietary — no prose, tables verbatim, screenshots, or map renders copied. Nothing scraped. |

**Compliance baked in:** no ripped game assets, no game screenshots/art, no Rockstar/Take-Two logos, no "official" claims, no media downloads, no mods/cheats. All visuals are original (SF Symbols, custom-drawn shapes, system styling).

---

## Remote data updates

`DataService` first tries a remote JSON bundle, validates its `version`, and falls back to bundled JSON on **any** failure (no network, bad URL, stale version, malformed data) — it never crashes on remote data.

- Configure in `AppConfig.swift`: `remoteDataBaseURL` (currently a clearly-marked placeholder `REPLACE-WITH-OWNER/REPLACE-WITH-REPO` URL — remote updates are inert until Paul sets a real one) + `remoteBundleFileName` (`bundle.json`).
- A remote bundle is adopted only when `version` is higher than `bundledDataVersion` (currently 1) **and** every domain decodes.
- **Remote bundle format** — one JSON file:

```json
{
  "version": 2,
  "domains": {
    "clothing_stores": [ { "id": "clothing-001", "name": "Slinger", "category": "Casual & Street", "district": "Southside", "county": "Vice-Dale", "edition": null, "verified": true, "source": "...", "notes": "..." } ],
    "footwear_stores": [ "...same Store shape..." ],
    "mod_shops": [ "...ModShop shape..." ],
    "vehicle_mods": [ "...VehicleMod shape..." ],
    "gun_stores": [ "...Store shape (with tier)..." ],
    "weapons": [ "...CatalogItem shape..." ],
    "vehicles": [ "...Vehicle shape..." ],
    "salons": [ "...Store shape..." ],
    "tattoo_parlors": [ "...Store shape..." ],
    "map_pins": [ "...MapPin shape..." ],
    "clothing_items_sample": [ "...CatalogItem shape..." ]
  }
}
```

Every record must carry `id`, `source`, and `verified`. To host it: commit `bundle.json` to a public repo (or any static host) and set `remoteDataBaseURL` to its directory. The bundled files in `LeonidaCompanion/Data/` are the format reference.

---

## Monetization — free with ads (Google AdMob), decided Nov 26, 2026

Paul decided **free with ads (Google AdMob)**. There is **no in-app purchase code and no Pro paywall** anywhere in the app — the v1 Pro paywall hook point (`Services/ProPaywallStub.swift`, StoreKit 2) was deleted Nov 26, 2026 and replaced with AdMob integration points in `LeonidaCompanion/Services/AdMobSlots.swift`.

**Ad placements (all clearly-marked integration points, placeholder until the SDK is wired):**
- **Banner slots** at the bottom of every list view via `.safeAreaInset(edge: .bottom)`: Store tab (`AdSlot.storeList`), Garage tab (`.garageList`), Map tab pin list (`.mapList`), Saved tab (`.savedList`). One AdMob ad unit per slot.
- **Interstitial hook** at a natural break only: returning from a detail view to a list (`InterstitialAd.noteDetailClosed()`, called from `StoreDetailView` / `ItemDetailView` `onDisappear`). Throttled to at most one per session, at least 3 detail closes since the last one, at least 120s between shows. Never mid-task.
- **No real AdMob credentials exist yet.** `AdMobConfig` holds placeholder IDs (`ca-app-pub-XXXXXXXXXXXXXXXX/...`) that will never serve an ad, and `BannerAdView` renders a labeled placeholder box until the SDK is added.

**AdMob setup steps (human, before release):**
1. Create an AdMob account and register the app; note the AdMob app ID.
2. Add the **Google-Mobile-Ads-SDK** package (Xcode → File → Add Package Dependencies → `https://github.com/googleads/swift-package-manager-google-mobile-ads`).
3. Add `GADApplicationIdentifier` (the real app ID) to Info.plist.
4. Create one ad unit per `AdSlot` in the AdMob console and paste the real IDs into `AdMobConfig` in `AdMobSlots.swift`.
5. Replace `BannerAdView`'s placeholder body with a `GADBannerView` (UIViewRepresentable) and implement `InterstitialAd.presentIfDue()` with `GADInterstitialAd`.
6. Test with Google's test ad unit IDs and test devices first. For EEA users, add Google's UMP consent form; handle the App Tracking Transparency prompt per Apple's rules.

---

## Remaining human steps (before App Store submission)

1. **Final app name** — ✅ decided: **"Leonida Locker"** (Paul, Nov 26, 2026). Re-verify uniqueness in App Store search at submission time (see top).
2. **Apple Developer Program enrollment** — $99/yr, Paul's Apple ID. **He has NOT enrolled; do not enroll on his behalf.** Then: real bundle id + team in Xcode/`fastlane/Appfile`, create the App ID and App Store Connect record.
3. **AdMob setup** — create the AdMob account/app, add the Google-Mobile-Ads-SDK package, set `GADApplicationIdentifier`, replace the placeholder ad unit IDs in `AdMobSlots.swift`, and swap the placeholder banner/interstitial for real ones (see Monetization above).
4. **Privacy policy URL** — publish one, set `AppConfig.privacyPolicyURL` (the About screen hides the link until it's set). The app collects no data (see `PrivacyInfo.xcprivacy` — only UserDefaults access, reason CA92.1).
5. **Map tiles** — self-host GTADB tiles and set the template (optional for v1; placeholder works without it).
6. **Remote data hosting** — optional for v1; set `remoteDataBaseURL` when ready.
7. **App icon** — the asset catalog has placeholder slots; supply a 1024×1024 original icon (no game art, no logos).
8. **Screenshots + listing copy** — use the App Store description below; screenshots must be original UI captures, not game screenshots.
9. **TestFlight** — wire up the `beta` lane only after steps 2–3; test on a real iPhone.

## App Store description (draft — name is now "Leonida Locker")

> Leonida Locker — Unofficial Companion for GTA VI
>
> Your fan-made field guide to Leonida. Find every clothing store, hairstyle, tattoo, gun store and mod shop — with prices, locations and shop specialties, all in one searchable place. Track down that livery in the Garage, save your favorites, and explore the community map.
>
> Features:
> • Searchable catalog: 67 clothing stores, 18 salons, 11 tattoo parlors, 24 gun stores, 14 mod shops
> • Weapons by class with prices, and which stores carry the big guns
> • Garage livery finder — search a mod, see which shops offer it
> • Community map with searchable pins
> • Saved favorites across everything
> • Clear labels for what's verified and what's still being cataloged
>
> Leonida Locker is an independent, fan-made companion app for Grand Theft Auto VI. It is not affiliated with, endorsed, sponsored or approved by Rockstar Games or Take-Two Interactive. Grand Theft Auto, GTA and GTA VI are trademarks of Take-Two Interactive Software, Inc. This app does not contain the game and does not provide game downloads, mods or modified files. All information comes from public sources and community research.

## Open decisions (Paul)

- Whether to add community pins/comments later (needs Guideline 1.2 moderation first).
- Map tiles: ship v1 with the placeholder base, or self-host GTADB tiles first.

## Project layout

```
LeonidaCompanion.xcodeproj/     Xcode project + shared scheme
LeonidaCompanion/
  App/                          App entry, AppConfig, ContentView (TabView)
  Models/                       Codable models (CatalogItem, Store, ModShop, VehicleMod, Vehicle, MapPin)
  Services/                     DataService (bundled + remote JSON), FavoritesStore, AdMobSlots (AdMob banner/interstitial integration points — placeholders, no SDK yet)
  Views/                        Map / Store / Garage / Saved / About / Onboarding / SharedViews
  Data/                         Bundled seed JSON (one file per domain)
  Resources/                    Assets.xcassets, LaunchScreen.storyboard, PrivacyInfo.xcprivacy
fastlane/                       Fastfile (build lane + beta STUB), Gemfile, Appfile (placeholders)
.github/workflows/ios.yml       CI: JSON validation + simulator build (no signing)
```

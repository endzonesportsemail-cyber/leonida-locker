import SwiftUI

/// Monetization — Google AdMob, free with ads (Paul's decision, Nov 26, 2026).
///
/// HISTORY: v1 shipped with a Pro paywall hook point (`ProPaywallStub.swift`,
/// StoreKit 2, no real products). Paul decided **free with ads** instead, so
/// the paywall stub was deleted and replaced with these AdMob integration
/// points. There is NO in-app purchase code, NO Pro paywall, and NO paid
/// tier anywhere in the app.
///
/// WHAT THIS FILE IS (v1):
///   * `AdMobConfig` — placeholder AdMob app ID + ad unit IDs. They are
///     NOT real: `ca-app-pub-XXXXXXXXXXXXXXXX` will never serve an ad.
///     Replace them with real IDs from the AdMob console (see README).
///   * `AdSlot` — one named slot per placement, so every banner in the app
///     maps to exactly one AdMob ad unit.
///   * `BannerAdView` — the banner view used at the bottom of every list
///     view. In v1 it renders a clearly-labeled placeholder box (so the
///     layout is real and testable) and loads NO ad. Swap its body for a
///     `GADBannerView` (UIViewRepresentable) once the SDK is added.
///   * `InterstitialAd` — hook points at natural breaks (returning from a
///     detail view). In v1 it only counts breaks and never shows anything.
///     Wire `present()` to `GADInterstitialAd` once the SDK is added.
///
/// WHAT IS STILL NEEDED (human steps, see README "AdMob setup"):
///   1. Create an AdMob account + the app, get the real AdMob app ID.
///   2. Add the Google-Mobile-Ads-SDK package (Xcode → Package Dependencies).
///   3. Add `GADApplicationIdentifier` (the real app ID) to Info.plist.
///   4. Create one ad unit per `AdSlot` and paste the real IDs into
///      `AdMobConfig` below.
///   5. Replace `BannerAdView`'s placeholder body with a real `GADBannerView`
///      and `InterstitialAd.present()` with a real `GADInterstitialAd` load.
///   6. Test with Google's test ad unit IDs first; use test devices.

// MARK: - Configuration (PLACEHOLDERS — replace with real AdMob IDs)

enum AdMobConfig {
    /// AdMob application ID. Placeholder — replace with the real ID from the
    /// AdMob console (format ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY).
    /// Also put the same value in Info.plist as GADApplicationIdentifier.
    static let appID = "ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"

    /// Ad unit IDs, one per placement. Placeholders — replace each with the
    /// real ad unit ID created in the AdMob console for this app.
    enum AdUnitID {
        static let storeListBanner = "ca-app-pub-XXXXXXXXXXXXXXXX/1111111111"
        static let garageListBanner = "ca-app-pub-XXXXXXXXXXXXXXXX/2222222222"
        static let mapListBanner = "ca-app-pub-XXXXXXXXXXXXXXXX/3333333333"
        static let savedListBanner = "ca-app-pub-XXXXXXXXXXXXXXXX/4444444444"
        static let interstitial = "ca-app-pub-XXXXXXXXXXXXXXXX/5555555555"
    }

    /// True only when every ID above has been replaced with a real one.
    /// `BannerAdView` uses this to decide whether to even attempt loading.
    static var isConfigured: Bool {
        !appID.contains("XXXXXXXXXXXXXXXX")
        && !AdUnitID.storeListBanner.contains("XXXXXXXXXXXXXXXX")
    }
}

// MARK: - Ad slots (one per placement)

/// Every banner in the app maps to exactly one of these slots, so the
/// AdMob console has one ad unit per placement and reporting stays clean.
enum AdSlot: String {
    /// Bottom of the Store tab catalog lists.
    case storeList
    /// Bottom of the Garage tab lists.
    case garageList
    /// Bottom of the Map tab pin list.
    case mapList
    /// Bottom of the Saved tab list.
    case savedList

    var adUnitID: String {
        switch self {
        case .storeList: return AdMobConfig.AdUnitID.storeListBanner
        case .garageList: return AdMobConfig.AdUnitID.garageListBanner
        case .mapList: return AdMobConfig.AdUnitID.mapListBanner
        case .savedList: return AdMobConfig.AdUnitID.savedListBanner
        }
    }
}

// MARK: - Banner ad view (placeholder until the AdMob SDK is added)

/// Banner slot rendered at the bottom of a list view via
/// `.safeAreaInset(edge: .bottom) { BannerAdView(slot: ...) }`.
///
/// v1 PLACEHOLDER: renders a labeled box (ad slot name + unit ID) so the
/// layout, spacing and safe-area behavior are real and reviewable, and
/// loads nothing. TO WIRE UP: add the Google-Mobile-Ads-SDK package, then
/// replace the body below with a `UIViewRepresentable` wrapping
/// `GADBannerView(adSize: GADAdSizeBanner)` loading `slot.adUnitID`.
/// Keep the placeholder's frame (full width, 50pt) so the layout does not
/// shift when the real banner loads.
struct BannerAdView: View {
    var slot: AdSlot

    var body: some View {
        VStack(spacing: 2) {
            Text("Ad · \(slot.rawValue)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(AdMobConfig.isConfigured ? slot.adUnitID : "AdMob placeholder — replace IDs in AdMobSlots.swift")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.secondary.opacity(0.08))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.secondary.opacity(0.2)),
            alignment: .top
        )
        .accessibilityLabel("Advertisement placeholder, \(slot.rawValue)")
    }
}

// MARK: - Interstitial hook points (natural breaks)

/// Interstitial ads, shown only at natural breaks — never mid-task.
///
/// Natural break used in v1: the user closes a detail view and returns to
/// a list (`noteDetailClosed()`, called from detail views' `onDisappear`).
/// In v1 this only counts breaks and NEVER presents anything, so the app
/// is fully usable with zero ads until the SDK is wired.
///
/// TO WIRE UP: add the Google-Mobile-Ads-SDK package, then implement
/// `presentIfDue()` with `GADInterstitialAd.load(...)` + present. Keep the
/// throttling below: at most one interstitial per session, at least 3
/// detail closes since the last one, at least 120 seconds between shows,
/// and never on the first detail close of a session.
enum InterstitialAd {
    private static var detailClosesSinceLastShow = 0
    private static var lastShownAt: Date?
    private static var shownThisSession = false

    /// Call from a detail view's `onDisappear` (returning to a list).
    static func noteDetailClosed() {
        detailClosesSinceLastShow += 1
        presentIfDue()
    }

    /// v1: no-op by design (no SDK, no real ad unit). When wired up, this
    /// is the single gate that decides whether an interstitial shows.
    private static func presentIfDue() {
        guard AdMobConfig.isConfigured else { return } // No real IDs yet.
        guard !shownThisSession else { return } // At most one per session.
        guard detailClosesSinceLastShow >= 3 else { return }
        if let last = lastShownAt, Date().timeIntervalSince(last) < 120 { return }
        // TODO (AdMob wiring): load GADInterstitialAd with
        // AdMobConfig.AdUnitID.interstitial and present it from the
        // top-most view controller. On presentation, set:
        //   shownThisSession = true
        //   lastShownAt = Date()
        //   detailClosesSinceLastShow = 0
    }
}

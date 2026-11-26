import SwiftUI

/// The full fan-made disclaimer. It appears in THREE places by design:
/// the App Store description (see README), the first-run onboarding
/// screen, and the About screen. Keep all three in sync.
enum Disclaimer {
    static let text = """
    [App Name] is an independent, fan-made companion app for Grand Theft Auto VI. \
    It is not affiliated with, endorsed, sponsored or approved by Rockstar Games \
    or Take-Two Interactive. Grand Theft Auto, GTA and GTA VI are trademarks of \
    Take-Two Interactive Software, Inc. This app does not contain the game and \
    does not provide game downloads, mods or modified files. All information \
    comes from public sources and community research.
    """

    /// Display name substituted at runtime. The app is named
    /// "Leonida Locker" (chosen by Paul Nov 26, 2026; the v1 scaffold was
    /// provisionally called "Leonida Companion").
    static func text(appName: String = AppConfig.appDisplayName) -> String {
        text.replacingOccurrences(of: "[App Name]", with: appName)
    }
}

@main
struct LeonidaCompanionApp: App {
    @StateObject private var dataService = DataService()
    @StateObject private var favorites = FavoritesStore()
    @AppStorage("leonida-companion.hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(dataService)
                    .environmentObject(favorites)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

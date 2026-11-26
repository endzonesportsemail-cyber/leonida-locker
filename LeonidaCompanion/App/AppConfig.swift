import Foundation

/// Central configuration. Nothing here is a secret: no API keys, no
/// credentials. Values Paul must set before release are marked TODO.
enum AppConfig {
    /// App name, chosen by Paul Nov 26, 2026. (The v1 scaffold was
    /// provisionally called "Leonida Companion"; see README history note.)
    /// Verified unique in App Store search before submission — see README.
    static let appDisplayName = "Leonida Locker"

    /// Subtitle pattern used in the listing. Keep "GTA" out of the app name.
    static let appSubtitle = "Unofficial Companion for GTA VI"

    /// Map tiles are NOT bundled and must NOT be hotlinked from gtadb.org.
    /// Self-host the GTADB YANIS tiles (github.com/rolux/gtadb.org, CC BY 4.0)
    /// and put the tile URL template here, e.g.:
    ///   "https://tiles.example.com/yanis/{z}/{x}/{y}.png"
    /// Leave empty to use the built-in stylized placeholder base map.
    /// Template tokens: {z} zoom, {x} column, {y} row.
    static let mapTileURLTemplate = ""

    /// Remote data bundle. Default is a placeholder: set this to the raw URL
    /// of the hosted bundle.json once Paul hosts the data (see README).
    /// The app always falls back to bundled JSON, so an unset/wrong URL
    /// can never break the app.
    static let remoteDataBaseURL = "https://raw.githubusercontent.com/REPLACE-WITH-OWNER/REPLACE-WITH-REPO/main/remote-data"

    /// Remote bundle manifest file name under `remoteDataBaseURL`.
    static let remoteBundleFileName = "bundle.json"

    /// Bundled data version shipped in the app. A remote bundle is only
    /// adopted when its `version` is higher than this.
    static let bundledDataVersion = 1

    /// App Store category: Reference. Expected rating 13+.
    static let appStoreCategory = "Reference"

    /// Privacy policy URL. TODO (Paul): publish a privacy policy and put
    /// its URL here before App Store submission.
    static let privacyPolicyURL = ""
}

import Foundation

/// Loads the bundled seed JSON, and optionally a newer remote bundle.
/// Remote data is best-effort: any failure (no network, bad URL, wrong
/// version, malformed JSON, decode error) falls back to the bundled data
/// and never crashes. Remote records must carry the same id/source/
/// verified fields as the bundled ones.
@MainActor
final class DataService: ObservableObject {
    // MARK: Published data
    @Published private(set) var clothingStores: [Store] = []
    @Published private(set) var footwearStores: [Store] = []
    @Published private(set) var modShops: [ModShop] = []
    @Published private(set) var vehicleMods: [VehicleMod] = []
    @Published private(set) var gunStores: [Store] = []
    @Published private(set) var weapons: [CatalogItem] = []
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var salons: [Store] = []
    @Published private(set) var tattooParlors: [Store] = []
    @Published private(set) var mapPins: [MapPin] = []
    @Published private(set) var clothingItemsSample: [CatalogItem] = []

    /// True when a remote bundle newer than the bundled version was adopted.
    @Published private(set) var usingRemoteData = false
    @Published private(set) var remoteDataVersion: Int?

    /// Human-readable load state for the Data Status screen.
    @Published private(set) var loadNotes: [String] = []

    init() {
        loadBundled()
        Task { await refreshFromRemote() }
    }

    // MARK: - Bundled data

    private func loadBundled() {
        loadNotes = ["Bundled data v\(AppConfig.bundledDataVersion) loaded."]
        clothingStores = bundled("clothing_stores")
        footwearStores = bundled("footwear_stores")
        modShops = bundled("mod_shops")
        vehicleMods = bundled("vehicle_mods")
        gunStores = bundled("gun_stores")
        weapons = bundled("weapons")
        vehicles = bundled("vehicles")
        salons = bundled("salons")
        tattooParlors = bundled("tattoo_parlors")
        mapPins = bundled("map_pins")
        clothingItemsSample = bundled("clothing_items_sample")
    }

    private func bundled<T: Decodable>(_ resource: String) -> [T] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(BundleFile<T>.self, from: data) else {
            loadNotes.append("Bundled file missing or invalid: \(resource).json")
            return []
        }
        return file.records
    }

    // MARK: - Remote data

    /// Tries the remote bundle once. On any failure, bundled data stays.
    func refreshFromRemote() async {
        guard let base = URL(string: AppConfig.remoteDataBaseURL),
              !AppConfig.remoteDataBaseURL.contains("REPLACE-WITH") else {
            // Placeholder URL: remote updates not configured yet. Not an error.
            return
        }
        let manifestURL = base.appendingPathComponent(AppConfig.remoteBundleFileName)
        do {
            let (data, _) = try await URLSession.shared.data(from: manifestURL)
            let manifest = try JSONDecoder().decode(RemoteBundle.self, from: data)
            guard manifest.version > AppConfig.bundledDataVersion else { return }
            // Validate shape only; per-domain decode happens below.
            guard manifest.domains["clothing_stores"] != nil else { return }
            try applyRemoteBundle(manifest)
            usingRemoteData = true
            remoteDataVersion = manifest.version
            loadNotes.append("Remote data v\(manifest.version) adopted.")
        } catch {
            // Silent fallback: bundled data remains in place.
            loadNotes.append("Remote update unavailable; using bundled data.")
        }
    }

    /// Decodes each domain from the remote manifest. Throws (and leaves
    /// bundled data untouched) if any domain fails to decode.
    private func applyRemoteBundle(_ manifest: RemoteBundle) throws {
        let encoder = JSONEncoder()
        func decodeDomain<T: Decodable>(_ key: String) throws -> [T] {
            guard let values = manifest.domains[key] else { return [] }
            let data = try encoder.encode(values)
            return try JSONDecoder().decode([T].self, from: data)
        }
        let clothing: [Store] = try decodeDomain("clothing_stores")
        let footwear: [Store] = try decodeDomain("footwear_stores")
        let mods: [ModShop] = try decodeDomain("mod_shops")
        let vmods: [VehicleMod] = try decodeDomain("vehicle_mods")
        let guns: [Store] = try decodeDomain("gun_stores")
        let weaps: [CatalogItem] = try decodeDomain("weapons")
        let vehs: [Vehicle] = try decodeDomain("vehicles")
        let sals: [Store] = try decodeDomain("salons")
        let tats: [Store] = try decodeDomain("tattoo_parlors")
        let pins: [MapPin] = try decodeDomain("map_pins")
        let items: [CatalogItem] = try decodeDomain("clothing_items_sample")
        // All domains decoded: only now replace the published data.
        clothingStores = clothing
        footwearStores = footwear
        modShops = mods
        vehicleMods = vmods
        gunStores = guns
        weapons = weaps
        vehicles = vehs
        salons = sals
        tattooParlors = tats
        mapPins = pins
        clothingItemsSample = items
    }

    // MARK: - Lookups

    func storeName(for id: String?) -> String? {
        guard let id else { return nil }
        let all = clothingStores + footwearStores + gunStores + salons + tattooParlors
        return all.first { $0.id == id }?.displayName
    }

    func modShop(id: String) -> ModShop? {
        modShops.first { $0.id == id }
    }
}

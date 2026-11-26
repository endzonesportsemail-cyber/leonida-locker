import Foundation

// MARK: - Shared fields
// Every seeded record carries an id, a source note and a verified flag.
// `verified == false` means the community has not confirmed this record
// against the released game yet; the UI shows a "being cataloged" state.

enum DataConfidence: String, Codable {
    case verified
    case guideReported = "guide-reported"
    case communityReported = "community-reported"
    case unknown
}

// MARK: - CatalogItem
/// Clothing / hairstyle / tattoo / weapon / gear item.
/// `price` is nil when unconfirmed (never estimated).
struct CatalogItem: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var price: Int?
    var storeId: String?
    var edition: String?
    var verified: Bool
    var dataConfidence: DataConfidence?
    var source: String
    var notes: String?

    /// Display price: "$1,250", or "Price unconfirmed" when nil.
    var priceText: String {
        guard let price else { return "Price unconfirmed" }
        return "$\(price.formatted(.number.grouping(.automatic)))"
    }
}

// MARK: - Store
/// A shop: clothing, footwear, gun store, salon or tattoo parlor.
/// `category` holds the sub-type (e.g. "Casual & Street", "Expanded", "Barber").
struct Store: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var district: String
    var county: String
    var tier: String?
    var edition: String?
    var verified: Bool
    var source: String
    var notes: String?

    var displayName: String {
        // Branches share a name; district disambiguates them.
        "\(name) — \(district)"
    }
}

// MARK: - ModShop
struct ModShop: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var district: String
    var county: String
    var specialty: String
    var edition: String?
    var verified: Bool
    var source: String
    var notes: String?
}

// MARK: - VehicleMod
struct VehicleMod: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var modShopIds: [String]
    var notes: String?
    var verified: Bool
    var source: String
    var dataConfidence: DataConfidence?
}

// MARK: - Vehicle
struct Vehicle: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var edition: String?
    var verified: Bool
    var source: String
    var notes: String?
}

// MARK: - MapPin
enum MapPinKind: String, Codable, CaseIterable {
    case clothing
    case footwear
    case modShop = "mod-shop"
    case gunStore = "gun-store"
    case salon
    case tattoo
    case poi

    var label: String {
        switch self {
        case .clothing: return "Clothing"
        case .footwear: return "Footwear"
        case .modShop: return "Mod Shop"
        case .gunStore: return "Gun Store"
        case .salon: return "Salon"
        case .tattoo: return "Tattoo"
        case .poi: return "Point of Interest"
        }
    }

    /// SF Symbol used for the pin. All visuals are original / system art only.
    var systemImage: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .footwear: return "shoe.fill"
        case .modShop: return "wrench.and.screwdriver.fill"
        case .gunStore: return "crosshair"
        case .salon: return "scissors"
        case .tattoo: return "paintbrush.fill"
        case .poi: return "mappin"
        }
    }
}

struct MapPin: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var kind: MapPinKind
    var approxX: Double
    var approxY: Double
    var verified: Bool
    var coordinateSource: String
    var source: String
    var referenceId: String?
    var district: String?
}

// MARK: - JSON bundle wrappers
/// Bundled files are `{"version": Int, "records": [...], ...extra keys...}`.
/// Extra top-level keys (classCounts, totals, ...) are ignored on decode.
struct BundleFile<T: Decodable>: Decodable {
    var version: Int
    var records: [T]
}

/// Remote bundle format (see README): one manifest with a version and
/// per-domain record arrays. A remote bundle is only adopted when its
/// version is higher than the bundled version AND every domain decodes.
struct RemoteBundle: Decodable {
    var version: Int
    var domains: [String: [JSONValue]]
}

/// Minimal JSON value used only to validate remote bundle shape before
/// per-domain decoding. Decoding never crashes on malformed data.
enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .null: try container.encodeNil()
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null; return }
        if let value = try? container.decode(Bool.self) { self = .bool(value); return }
        if let value = try? container.decode(Double.self) { self = .number(value); return }
        if let value = try? container.decode(String.self) { self = .string(value); return }
        if let value = try? container.decode([JSONValue].self) { self = .array(value); return }
        if let value = try? container.decode([String: JSONValue].self) { self = .object(value); return }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
    }
}

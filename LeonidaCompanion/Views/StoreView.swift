import SwiftUI

// MARK: - Store tab
//
// Unified searchable catalog:
//   Clothing (by store/brand + "all items" sample + being-cataloged state)
//   Hairstyles (salon list) · Tattoos (parlor list)
//   Guns (weapons by class with prices + gun-store list with tiers)

struct StoreTabView: View {
    @EnvironmentObject private var dataService: DataService
    @State private var searchText = ""
    @State private var selectedCounty = "All Counties"
    @State private var selectedSection = Section.clothing
    @State private var sortByPrice = false

    enum Section: String, CaseIterable, Identifiable {
        case clothing = "Clothing"
        case hairstyles = "Hairstyles"
        case tattoos = "Tattoos"
        case guns = "Guns"
        var id: String { rawValue }
    }

    private var counties: [String] {
        ["All Counties"] + Array(Set(
            dataService.clothingStores.map(\.county)
            + dataService.gunStores.map(\.county)
            + dataService.salons.map(\.county)
            + dataService.tattooParlors.map(\.county)
        )).sorted()
    }

    private func inCounty(_ county: String) -> Bool {
        selectedCounty == "All Counties" || county == selectedCounty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedSection) {
                    ForEach(Section.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Picker("County", selection: $selectedCounty) {
                    ForEach(counties, id: \.self) { county in
                        Text(county).tag(county)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)

                switch selectedSection {
                case .clothing:
                    ClothingSectionView(searchText: searchText, inCounty: inCounty)
                case .hairstyles:
                    SalonListView(searchText: searchText, inCounty: inCounty)
                case .tattoos:
                    TattooListView(searchText: searchText, inCounty: inCounty)
                case .guns:
                    GunsSectionView(searchText: searchText, inCounty: inCounty, sortByPrice: sortByPrice)
                }
            }
            // AdMob banner slot (Store tab). Placeholder until the SDK is wired — see AdMobSlots.swift.
            .safeAreaInset(edge: .bottom) { BannerAdView(slot: .storeList) }
            .navigationTitle("Store")
            .searchable(text: $searchText, prompt: "Search the catalog")
            .toolbar {
                if selectedSection == .guns {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(sortByPrice ? "Sort: Price" : "Sort: Name") {
                            sortByPrice.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) { AboutButton() }
            }
        }
    }
}

// MARK: - Clothing

struct ClothingSectionView: View {
    @EnvironmentObject private var dataService: DataService
    var searchText: String
    var inCounty: (String) -> Bool

    private var filteredStores: [Store] {
        dataService.clothingStores.filter { store in
            inCounty(store.county)
            && (store.name.matches(searchText) || store.district.matches(searchText) || store.category.matches(searchText))
        }
    }

    private var groupedStores: [(category: String, stores: [Store])] {
        let grouped = Dictionary(grouping: filteredStores, by: \.category)
        return grouped.keys.sorted().map { key in (key, grouped[key]!.sorted { $0.district < $1.district }) }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Catalog being built", systemImage: "hourglass")
                        .font(.subheadline.weight(.semibold))
                    Text("Full per-item clothing catalogs don't exist yet. Best available: NiaDB's 275 priced pieces (Nov 24) and The Games Wiki's 168 entries covering only 3 Mariana stores. Items below are a sample only — the rest is being cataloged, not guessed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Sample items") {
                ForEach(dataService.clothingItemsSample) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        CatalogItemRow(item: item)
                    }
                }
            }

            Section("Same-brand branches share stock") {
                Text("One visit per brand covers it — every branch of a brand stocks the same items.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(groupedStores, id: \.category) { group in
                Section("\(group.category) (\(group.stores.count))") {
                    ForEach(group.stores) { store in
                        NavigationLink(destination: StoreDetailView(store: store)) {
                            StoreRow(store: store)
                        }
                    }
                }
            }

            Section("Footwear (\(dataService.footwearStores.count))") {
                ForEach(dataService.footwearStores.filter { inCounty($0.county) && ($0.name.matches(searchText) || $0.district.matches(searchText)) }) { store in
                    NavigationLink(destination: StoreDetailView(store: store)) {
                        StoreRow(store: store)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Salons & tattoos

struct SalonListView: View {
    @EnvironmentObject private var dataService: DataService
    var searchText: String
    var inCounty: (String) -> Bool

    var body: some View {
        List {
            Section {
                Text("18 salons. Per-salon hairstyle catalogs are being cataloged — not invented here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(dataService.salons.filter { inCounty($0.county) && ($0.name.matches(searchText) || $0.district.matches(searchText) || $0.category.matches(searchText)) }) { salon in
                NavigationLink(destination: StoreDetailView(store: salon)) {
                    StoreRow(store: salon)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct TattooListView: View {
    @EnvironmentObject private var dataService: DataService
    var searchText: String
    var inCounty: (String) -> Bool

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("11 parlors. Tattoo prices found range $53–$14,700.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Magazine tattoos via WAiNK scans (13 Jason / 15 Lucia / 17 shared) are still being cataloged — counts only, no invented designs.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(dataService.tattooParlors.filter { inCounty($0.county) && ($0.name.matches(searchText) || $0.district.matches(searchText) || $0.category.matches(searchText)) }) { parlor in
                NavigationLink(destination: StoreDetailView(store: parlor)) {
                    StoreRow(store: parlor)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Guns

struct GunsSectionView: View {
    @EnvironmentObject private var dataService: DataService
    var searchText: String
    var inCounty: (String) -> Bool
    var sortByPrice: Bool

    private var filteredWeapons: [CatalogItem] {
        dataService.weapons.filter { weapon in
            weapon.name.matches(searchText) || weapon.category.matches(searchText)
        }
    }

    private var groupedWeapons: [(weaponClass: String, weapons: [CatalogItem])] {
        let grouped = Dictionary(grouping: filteredWeapons, by: \.category)
        let order = ["Pistol", "Revolver", "SMG", "Shotgun", "Assault Rifle", "Sniper Rifle", "Machine Gun", "Launcher", "Melee", "Explosive"]
        return order.compactMap { key in
            guard let weapons = grouped[key] else { return nil }
            let sorted = sortByPrice
                ? weapons.sorted { ($0.price ?? Int.max) < ($1.price ?? Int.max) }
                : weapons.sorted { $0.name < $1.name }
            return (key, sorted)
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("53 base guns across 10 classes, 120+ unique variants. Prices are guide-reported, not Rockstar-published.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Carry limit: 2 sidearms + 2 long guns.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Machine guns, launchers and big snipers are sold only at the 6 Expanded-tier stores.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(groupedWeapons, id: \.weaponClass) { group in
                Section("\(group.weaponClass) (\(group.weapons.count) listed)") {
                    ForEach(group.weapons) { weapon in
                        NavigationLink(destination: ItemDetailView(item: weapon)) {
                            CatalogItemRow(item: weapon)
                        }
                    }
                }
            }

            Section("Gun stores (24)") {
                ForEach(dataService.gunStores.filter { inCounty($0.county) && ($0.name.matches(searchText) || $0.district.matches(searchText) || ($0.tier ?? "").matches(searchText)) }) { store in
                    NavigationLink(destination: StoreDetailView(store: store)) {
                        StoreRow(store: store)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Rows & detail

struct StoreRow: View {
    var store: Store

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.name).font(.subheadline)
                Text("\(store.district), \(store.county) · \(store.category)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            EditionBadge(edition: store.edition)
            VerifiedBadge(verified: store.verified)
        }
    }
}

struct CatalogItemRow: View {
    var item: CatalogItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline)
                Text(item.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.priceText)
                .font(.subheadline.weight(.semibold))
            VerifiedBadge(verified: item.verified)
        }
    }
}

struct StoreDetailView: View {
    var store: Store

    var body: some View {
        List {
            Section {
                Text(store.displayName).font(.headline)
                Text("\(store.district), \(store.county)")
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    VerifiedBadge(verified: store.verified)
                    EditionBadge(edition: store.edition)
                    if let tier = store.tier {
                        Text(tier)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
                if let notes = store.notes {
                    Text(notes).font(.subheadline)
                }
            }
            Section("Source") {
                SourceNoteView(source: store.source)
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        // Natural break for an interstitial ad: returning to a list.
        // No-op in v1 (no AdMob SDK wired) — see AdMobSlots.swift.
        .onDisappear { InterstitialAd.noteDetailClosed() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(id: store.id)
            }
        }
    }
}

struct ItemDetailView: View {
    var item: CatalogItem
    @EnvironmentObject private var dataService: DataService

    var body: some View {
        List {
            Section {
                Text(item.name).font(.headline)
                Text(item.category)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    VerifiedBadge(verified: item.verified)
                    EditionBadge(edition: item.edition)
                    if let confidence = item.dataConfidence, confidence != .verified {
                        Text(confidence.rawValue)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
            }
            Section("Price") {
                Text(item.priceText).font(.title3.weight(.semibold))
                if item.price == nil {
                    Text("Unconfirmed — not estimated. Prices are added only when a source publishes them.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if let storeId = item.storeId, let storeName = dataService.storeName(for: storeId) {
                Section("Sold at") {
                    Text(storeName)
                }
            }
            if let notes = item.notes {
                Section("Notes") {
                    Text(notes)
                }
            }
            Section("Source") {
                SourceNoteView(source: item.source)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        // Natural break for an interstitial ad: returning to a list.
        // No-op in v1 (no AdMob SDK wired) — see AdMobSlots.swift.
        .onDisappear { InterstitialAd.noteDetailClosed() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(id: item.id)
            }
        }
    }
}

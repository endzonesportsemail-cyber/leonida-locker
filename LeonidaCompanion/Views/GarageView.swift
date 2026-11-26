import SwiftUI

// MARK: - Garage tab
//
// All 14 mod shops, the 6 mod categories, and the "where was that
// livery?" search: search a mod/livery, see which shops offer it.
// Per-shop livery catalogs are being cataloged — the app says so
// instead of inventing them.

struct GarageTabView: View {
    @EnvironmentObject private var dataService: DataService
    @State private var searchText = ""
    @State private var selectedCounty = "All Counties"
    @State private var selectedCategory = "All Categories"

    private var counties: [String] {
        ["All Counties"] + Array(Set(dataService.modShops.map(\.county))).sorted()
    }

    private var categories: [String] {
        ["All Categories", "Pro Builds", "Cosmetics", "Bodywork", "Performance", "Wheels", "Interior"]
    }

    private var filteredShops: [ModShop] {
        dataService.modShops.filter { shop in
            (selectedCounty == "All Counties" || shop.county == selectedCounty)
            && (shop.name.matches(searchText) || shop.specialty.matches(searchText) || shop.district.matches(searchText))
        }
    }

    private var filteredMods: [VehicleMod] {
        dataService.vehicleMods.filter { mod in
            (selectedCategory == "All Categories" || mod.category == selectedCategory)
            && (mod.name.matches(searchText) || mod.category.matches(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Find a livery / mod", systemImage: "paintbrush.fill")
                            .font(.subheadline.weight(.semibold))
                        Text("Search below. Vice Vinyl and One-Eyed Willie's Auto Shop are the livery specialists. Per-shop livery catalogs are still being cataloged — this app lists which shops offer a mod only when a source confirms it.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Mods & liveries (\(filteredMods.count))") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    ForEach(filteredMods) { mod in
                        NavigationLink(destination: VehicleModDetailView(mod: mod)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mod.name).font(.subheadline)
                                Text(mod.category + (mod.modShopIds.isEmpty ? " · shops being cataloged" : " · \(mod.modShopIds.count) shop(s)"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Mod shops (\(filteredShops.count) of 14)") {
                    Picker("County", selection: $selectedCounty) {
                        ForEach(counties, id: \.self) { county in
                            Text(county).tag(county)
                        }
                    }
                    .pickerStyle(.menu)
                    ForEach(filteredShops) { shop in
                        NavigationLink(destination: ModShopDetailView(shop: shop)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(shop.name).font(.subheadline)
                                    Text("\(shop.district), \(shop.county) · \(shop.specialty)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                EditionBadge(edition: shop.edition)
                                VerifiedBadge(verified: shop.verified)
                            }
                        }
                    }
                }

                Section("Pay 'n' Spray") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("19 locations — repair, respray, sell stolen cars.")
                            .font(.subheadline)
                        Text("Pay 'n' Spray is distinct from mod shops. Individual locations have not been verified yet, so they are not listed one by one — count only, no invented locations.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Vehicles (27 confirmed names)") {
                    Text("In-game Progress Database: 557 vehicles = 277 base models + 280 Standout variants. 100% completion needs any 200/277 base models scanned via WAiNK. The full name list has not been published — only confirmed names are listed here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(dataService.vehicles.filter { $0.name.matches(searchText) || $0.category.matches(searchText) }) { vehicle in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vehicle.name).font(.subheadline)
                                Text(vehicle.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            EditionBadge(edition: vehicle.edition)
                            FavoriteButton(id: vehicle.id)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Garage")
            .searchable(text: $searchText, prompt: "Search mods, liveries, shops, vehicles")
            // AdMob banner slot (Garage tab). Placeholder until the SDK is wired — see AdMobSlots.swift.
            .safeAreaInset(edge: .bottom) { BannerAdView(slot: .garageList) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { AboutButton() }
            }
        }
    }
}

struct ModShopDetailView: View {
    var shop: ModShop
    @EnvironmentObject private var dataService: DataService

    private var offeredMods: [VehicleMod] {
        dataService.vehicleMods.filter { $0.modShopIds.contains(shop.id) }
    }

    var body: some View {
        List {
            Section {
                Text(shop.name).font(.headline)
                Text("\(shop.district), \(shop.county)")
                    .foregroundStyle(.secondary)
                Text("Specialty: \(shop.specialty)")
                    .font(.subheadline)
                HStack(spacing: 8) {
                    VerifiedBadge(verified: shop.verified)
                    EditionBadge(edition: shop.edition)
                }
                if let notes = shop.notes {
                    Text(notes).font(.subheadline)
                }
            }
            Section("Mods confirmed here (\(offeredMods.count))") {
                if offeredMods.isEmpty {
                    Text("Per-shop mod/livery catalog is being cataloged — nothing invented here yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(offeredMods) { mod in
                        NavigationLink(destination: VehicleModDetailView(mod: mod)) {
                            Text(mod.name)
                        }
                    }
                }
            }
            Section("Source") {
                SourceNoteView(source: shop.source)
            }
        }
        .navigationTitle(shop.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(id: shop.id)
            }
        }
    }
}

struct VehicleModDetailView: View {
    var mod: VehicleMod
    @EnvironmentObject private var dataService: DataService

    var body: some View {
        List {
            Section {
                Text(mod.name).font(.headline)
                Text(mod.category)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    VerifiedBadge(verified: mod.verified)
                    if let confidence = mod.dataConfidence, confidence != .verified {
                        Text(confidence.rawValue)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
                if let notes = mod.notes {
                    Text(notes).font(.subheadline)
                }
            }
            Section("Offered at (\(mod.modShopIds.count))") {
                if mod.modShopIds.isEmpty {
                    Text("Which shops offer this is being cataloged — not guessed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(mod.modShopIds, id: \.self) { shopId in
                        if let shop = dataService.modShop(id: shopId) {
                            NavigationLink(destination: ModShopDetailView(shop: shop)) {
                                Text("\(shop.name) — \(shop.district), \(shop.county)")
                            }
                        }
                    }
                }
            }
            Section("Source") {
                SourceNoteView(source: mod.source)
            }
        }
        .navigationTitle(mod.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(id: mod.id)
            }
        }
    }
}

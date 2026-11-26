import SwiftUI

// MARK: - Saved tab
//
// Favorites / bookmarks across all domains, persisted locally in
// UserDefaults (see FavoritesStore). Sections per domain, swipe-to-remove.

struct SavedTabView: View {
    @EnvironmentObject private var dataService: DataService
    @EnvironmentObject private var favorites: FavoritesStore

    private var savedClothing: [Store] {
        dataService.clothingStores.filter { favorites.isFavorite($0.id) }
    }
    private var savedFootwear: [Store] {
        dataService.footwearStores.filter { favorites.isFavorite($0.id) }
    }
    private var savedModShops: [ModShop] {
        dataService.modShops.filter { favorites.isFavorite($0.id) }
    }
    private var savedGuns: [Store] {
        dataService.gunStores.filter { favorites.isFavorite($0.id) }
    }
    private var savedWeapons: [CatalogItem] {
        dataService.weapons.filter { favorites.isFavorite($0.id) }
    }
    private var savedItems: [CatalogItem] {
        dataService.clothingItemsSample.filter { favorites.isFavorite($0.id) }
    }
    private var savedVehicles: [Vehicle] {
        dataService.vehicles.filter { favorites.isFavorite($0.id) }
    }
    private var savedSalons: [Store] {
        dataService.salons.filter { favorites.isFavorite($0.id) }
    }
    private var savedTattoos: [Store] {
        dataService.tattooParlors.filter { favorites.isFavorite($0.id) }
    }
    private var savedMods: [VehicleMod] {
        dataService.vehicleMods.filter { favorites.isFavorite($0.id) }
    }
    private var savedPins: [MapPin] {
        dataService.mapPins.filter { favorites.isFavorite($0.id) }
    }

    private var totalSaved: Int {
        savedClothing.count + savedFootwear.count + savedModShops.count
        + savedGuns.count + savedWeapons.count + savedItems.count
        + savedVehicles.count + savedSalons.count + savedTattoos.count
        + savedMods.count + savedPins.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if totalSaved == 0 {
                    ContentUnavailableView(
                        "Nothing saved yet",
                        systemImage: "bookmark",
                        description: Text("Tap the bookmark icon on any store, weapon, mod, vehicle or map pin to save it here.")
                    )
                } else {
                    List {
                        savedSection("Clothing stores", stores: savedClothing)
                        savedSection("Footwear", stores: savedFootwear)
                        savedSection("Gun stores", stores: savedGuns)
                        savedSection("Salons", stores: savedSalons)
                        savedSection("Tattoo parlors", stores: savedTattoos)
                        savedSection("Weapons & items", items: savedWeapons + savedItems)
                        savedSection("Mod shops", modShops: savedModShops)
                        savedSection("Mods & liveries", mods: savedMods)
                        savedSection("Vehicles", vehicles: savedVehicles)
                        savedSection("Map pins", pins: savedPins)
                    }
                }
            }
            // AdMob banner slot (Saved tab). Placeholder until the SDK is wired — see AdMobSlots.swift.
            .safeAreaInset(edge: .bottom) { BannerAdView(slot: .savedList) }
            .navigationTitle("Saved")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { AboutButton() }
            }
        }
    }

    // MARK: - Section builders (empty sections render nothing)

    @ViewBuilder
    private func savedSection(_ title: String, stores: [Store]) -> some View {
        if !stores.isEmpty {
            Section(title) {
                ForEach(stores) { store in
                    NavigationLink(destination: StoreDetailView(store: store)) {
                        StoreRow(store: store)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { favorites.remove(stores[index].id) }
                }
            }
        }
    }

    @ViewBuilder
    private func savedSection(_ title: String, items: [CatalogItem]) -> some View {
        if !items.isEmpty {
            Section(title) {
                ForEach(items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        CatalogItemRow(item: item)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { favorites.remove(items[index].id) }
                }
            }
        }
    }

    @ViewBuilder
    private func savedSection(_ title: String, modShops: [ModShop]) -> some View {
        if !modShops.isEmpty {
            Section(title) {
                ForEach(modShops) { shop in
                    NavigationLink(destination: ModShopDetailView(shop: shop)) {
                        Text(shop.name)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { favorites.remove(modShops[index].id) }
                }
            }
        }
    }

    @ViewBuilder
    private func savedSection(_ title: String, mods: [VehicleMod]) -> some View {
        if !mods.isEmpty {
            Section(title) {
                ForEach(mods) { mod in
                    NavigationLink(destination: VehicleModDetailView(mod: mod)) {
                        Text(mod.name)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { favorites.remove(mods[index].id) }
                }
            }
        }
    }

    @ViewBuilder
    private func savedSection(_ title: String, vehicles: [Vehicle]) -> some View {
        if !vehicles.isEmpty {
            Section(title) {
                ForEach(vehicles) { vehicle in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(vehicle.name).font(.subheadline)
                            Text(vehicle.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        EditionBadge(edition: vehicle.edition)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { favorites.remove(vehicles[index].id) }
                }
            }
        }
    }

    @ViewBuilder
    private func savedSection(_ title: String, pins: [MapPin]) -> some View {
        if !pins.isEmpty {
            Section(title) {
                ForEach(pins) { pin in
                    HStack {
                        Image(systemName: pin.kind.systemImage)
                            .foregroundStyle(.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pin.title).font(.subheadline)
                            Text(pin.kind.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !pin.verified { ApproximateBadge() }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { favorites.remove(pins[index].id) }
                }
            }
        }
    }
}

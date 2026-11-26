import SwiftUI

// MARK: - About / Credits screen
//
// Carries the full disclaimer, data-source credits with licenses,
// the app version, and a link to the Data Status screen.

struct AboutView: View {
    var body: some View {
        List {
            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppConfig.appDisplayName)
                        .font(.title3.weight(.bold))
                    Text(AppConfig.appSubtitle)
                        .foregroundStyle(.secondary)
                    Text("Version 1.0 (bundled data v\(AppConfig.bundledDataVersion))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Category: \(AppConfig.appStoreCategory) · Free download · iOS 17+ · iPhone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Disclaimer") {
                Text(Disclaimer.text())
                    .font(.caption)
            }

            Section("Data sources & licenses") {
                CreditRow(
                    title: "GTADB — Leonida map tiles & landmark data",
                    detail: "map.gtadb.org · github.com/rolux/gtadb.org · CC BY 4.0 (code MIT). Tiles are NOT bundled; self-host them (see README). Attribution: \"Map tiles © YANIS / GTA VI Mapping Community via gtadb.org (CC BY 4.0)\"."
                )
                CreditRow(
                    title: "GTA6Maps.io — map marker dataset",
                    detail: "gta6maps.io/gta-6/map-data · GitHub duanhesen/gta6-leonida-map-data · Zenodo DOI 10.5281/zenodo.24412576 · CC BY 4.0. 798 markers, normalized 0–1; 0/798 game-verified as of Nov 20, 2026."
                )
                CreditRow(
                    title: "GTA Wiki (Fandom) & Grand Theft Wiki",
                    detail: "Plain facts only, written in our own words, with attribution. CC BY-SA / CC BY-SA 3.0. No text copied verbatim, no screenshots reused."
                )
                CreditRow(
                    title: "The Games Wiki",
                    detail: "Plain facts only, written in our own words. CC BY-SA 4.0."
                )
                CreditRow(
                    title: "GTA VI Wire",
                    detail: "Original text CC BY 4.0. Plain facts only."
                )
                CreditRow(
                    title: "PowerPyx, KeenGamer, Dexerto, GTA6Gang / NiaDB, Fextralife",
                    detail: "Plain facts only (store names, locations, counts, prices). No prose, tables, screenshots or map renders copied. Nothing scraped."
                )
            }

            Section("Map note") {
                Text("Map data: GTADB community (CC BY 4.0). The community map is a pre-launch reconstruction from trailers and screenshots, not the retail in-game map. Street geometry is good; names, borders and distances are unverified vs the released game. Pin positions in this app are approximate district-level placements until game-verified coordinates exist.")
                    .font(.caption)
            }

            Section("What this app does not do") {
                Text("No game downloads, no mods, no cheats, no modified files, no ripped game assets, no game screenshots or art, no Rockstar / Take-Two logos, no media downloads, and no community pins or comments in v1 (avoiding the Guideline 1.2 user-generated-content moderation burden — a possible future feature, with moderation, if Paul wants it).")
                    .font(.caption)
            }

            Section("Data status") {
                NavigationLink(destination: DataStatusView()) {
                    Label("What's verified vs being cataloged", systemImage: "list.clipboard")
                }
            }

            if !AppConfig.privacyPolicyURL.isEmpty {
                Section("Privacy") {
                    Link("Privacy Policy", destination: URL(string: AppConfig.privacyPolicyURL)!)
                }
            }
        }
        .navigationTitle("About & Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CreditRow: View {
    var title: String
    var detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Data Status screen

struct DataStatusView: View {
    @EnvironmentObject private var dataService: DataService

    private var rows: [(domain: String, total: Int, verified: Int, note: String)] {
        [
            ("Clothing stores", dataService.clothingStores.count, dataService.clothingStores.filter(\.verified).count, "67 stores. Per-item catalogs being cataloged (NiaDB 275 priced pieces; The Games Wiki 168 entries, 3 Mariana stores)."),
            ("Footwear stores", dataService.footwearStores.count, dataService.footwearStores.filter(\.verified).count, "17 stores."),
            ("Mod shops", dataService.modShops.count, dataService.modShops.filter(\.verified).count, "14 shops. Per-shop livery catalogs being cataloged."),
            ("Vehicle mods", dataService.vehicleMods.count, dataService.vehicleMods.filter(\.verified).count, "8 records. Only livery-related records link to specific shops."),
            ("Gun stores", dataService.gunStores.count, dataService.gunStores.filter(\.verified).count, "24 stores: 15 Standard, 6 Expanded, 2 Hunting, 1 Limited."),
            ("Weapons", dataService.weapons.count, dataService.weapons.filter(\.verified).count, "41 priced entries seeded; 53 base guns across 10 classes. Shotgun/sniper middle entries not yet published. Prices are guide-reported, not Rockstar-published."),
            ("Vehicles", dataService.vehicles.count, dataService.vehicles.filter(\.verified).count, "27 confirmed names of 557 total (277 base + 280 Standout). Full name list not published."),
            ("Hair salons", dataService.salons.count, dataService.salons.filter(\.verified).count, "18 salons. Per-salon hairstyle catalogs being cataloged."),
            ("Tattoo parlors", dataService.tattooParlors.count, dataService.tattooParlors.filter(\.verified).count, "11 parlors. Magazine tattoos (13 Jason / 15 Lucia / 17 shared) being cataloged."),
            ("Map pins", dataService.mapPins.count, dataService.mapPins.filter(\.verified).count, "All pins approximate district-level placements; 0 game-verified as of Nov 20, 2026."),
        ]
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataService.usingRemoteData
                         ? "Using remote data v\(dataService.remoteDataVersion ?? 0)."
                         : "Using bundled data v\(AppConfig.bundledDataVersion).")
                        .font(.subheadline.weight(.semibold))
                    ForEach(dataService.loadNotes, id: \.self) { note in
                        Text(note).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            ForEach(rows, id: \.domain) { row in
                Section(row.domain) {
                    HStack {
                        Text("\(row.verified) of \(row.total) verified")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        VerifiedBadge(verified: row.verified == row.total && row.total > 0)
                    }
                    Text(row.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                Text("“Verified” means confirmed against a community source as of Nov 26, 2026 — not confirmed in the released game. Records the community hasn't verified show “Being cataloged” and are never filled in with guesses.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Data Status")
        .navigationBarTitleDisplayMode(.inline)
    }
}

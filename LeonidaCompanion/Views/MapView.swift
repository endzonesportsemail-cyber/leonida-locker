import SwiftUI
import MapKit

// MARK: - Map tab
//
// Two layers:
//   1. When `AppConfig.mapTileURLTemplate` is set (self-hosted GTADB YANIS
//      tiles), a real MapKit map with an MKTileOverlay on top.
//   2. Otherwise a stylized placeholder base drawn from original shapes,
//      clearly labeled, with pins and search working over it.
// The app NEVER hotlinks gtadb.org live tiles.

struct MapTabView: View {
    @EnvironmentObject private var dataService: DataService
    @State private var searchText = ""
    @State private var selectedKinds: Set<MapPinKind> = Set(MapPinKind.allCases)
    @State private var selectedPin: MapPin?

    private var filteredPins: [MapPin] {
        dataService.mapPins.filter { pin in
            selectedKinds.contains(pin.kind) && pin.title.matches(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Kind filter chips.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MapPinKind.allCases, id: \.self) { kind in
                            Button {
                                if selectedKinds.contains(kind) {
                                    selectedKinds.remove(kind)
                                } else {
                                    selectedKinds.insert(kind)
                                }
                            } label: {
                                Label(kind.label, systemImage: kind.systemImage)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(selectedKinds.contains(kind) ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.12))
                                    .foregroundStyle(selectedKinds.contains(kind) ? Color.accentColor : .secondary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Map area.
                ZStack(alignment: .bottomLeading) {
                    if AppConfig.mapTileURLTemplate.isEmpty {
                        PlaceholderMapView(pins: filteredPins, selectedPin: $selectedPin)
                    } else {
                        TileMapView(pins: filteredPins, selectedPin: $selectedPin)
                    }
                    // Attribution is ALWAYS visible on the map view.
                    Text("Map tiles © YANIS / GTA VI Mapping Community via gtadb.org (CC BY 4.0)")
                        .font(.caption2)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }
                .frame(maxHeight: 380)

                // Pre-launch caveat.
                Text("Community map — tiles not bundled; see README. This is a pre-launch community reconstruction from trailers and screenshots, not the retail in-game map. Street geometry is good; names, borders and distances are unverified vs the released game.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 6)

                // Searchable pin list.
                List(filteredPins) { pin in
                    Button {
                        selectedPin = pin
                    } label: {
                        HStack {
                            Image(systemName: pin.kind.systemImage)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pin.title)
                                    .font(.subheadline)
                                Text("\(pin.kind.label) · \(pin.district ?? "Leonida")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !pin.verified { ApproximateBadge() }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            // AdMob banner slot (Map tab pin list). Placeholder until the SDK is wired — see AdMobSlots.swift.
            // Placed below the list so it never covers the map attribution line.
            .safeAreaInset(edge: .bottom) { BannerAdView(slot: .mapList) }
            .navigationTitle("Map")
            .searchable(text: $searchText, prompt: "Search places")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { AboutButton() }
            }
            .sheet(item: $selectedPin) { pin in
                PinDetailView(pin: pin)
            }
        }
    }
}

// MARK: - Placeholder base map (original drawn shapes, no game art)

/// Stylized Leonida: a large Vice City island, the Key Lento keys, and the
/// northern mainland, drawn as plain shapes. Labeled as a placeholder so
/// nobody mistakes it for the in-game map.
struct PlaceholderMapView: View {
    var pins: [MapPin]
    @Binding var selectedPin: MapPin?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Water.
                Color(red: 0.08, green: 0.22, blue: 0.35)
                // Mainland (north).
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.28))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.55, y: geometry.size.height * 0.18))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.30))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.closeSubpath()
                }
                .fill(Color(red: 0.16, green: 0.32, blue: 0.20))
                // Vice City island (center).
                Ellipse()
                    .fill(Color(red: 0.20, green: 0.38, blue: 0.24))
                    .frame(width: geometry.size.width * 0.42, height: geometry.size.height * 0.44)
                    .position(x: geometry.size.width * 0.55, y: geometry.size.height * 0.55)
                // Key Lento keys (south-east).
                Ellipse()
                    .fill(Color(red: 0.24, green: 0.42, blue: 0.26))
                    .frame(width: geometry.size.width * 0.20, height: geometry.size.height * 0.10)
                    .position(x: geometry.size.width * 0.76, y: geometry.size.height * 0.84)
                Ellipse()
                    .fill(Color(red: 0.24, green: 0.42, blue: 0.26))
                    .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.07)
                    .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.90)

                Text("Community map — tiles not bundled; see README")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(6)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .position(x: geometry.size.width * 0.5, y: 18)

                // Pins.
                ForEach(pins) { pin in
                    Button {
                        selectedPin = pin
                    } label: {
                        Image(systemName: pin.kind.systemImage)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(pin.verified ? Color.green : Color.orange)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .position(
                        x: CGFloat(pin.approxX) * geometry.size.width,
                        y: CGFloat(pin.approxY) * geometry.size.height
                    )
                    .accessibilityLabel("\(pin.title), \(pin.kind.label), approximate location")
                }
            }
        }
    }
}

// MARK: - Real tile map (only when a self-hosted template is configured)

struct TileMapView: UIViewRepresentable {
    var pins: [MapPin]
    @Binding var selectedPin: MapPin?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        if let template = AppConfig.mapTileURLTemplate.nilIfEmpty {
            let overlay = MKTileOverlay(urlTemplate: template)
            overlay.canReplaceMapContent = true
            mapView.addOverlay(overlay, level: .aboveLabels)
        }
        // Leonida overview: normalized coords map onto a fixed region.
        // The tile set defines its own extent; center on the map's middle.
        mapView.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        )
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let existing = mapView.annotations.compactMap { $0 as? PinAnnotation }
        let wantedIds = Set(pins.map(\.id))
        for annotation in existing where !wantedIds.contains(annotation.pinId) {
            mapView.removeAnnotation(annotation)
        }
        let existingIds = Set(existing.map(\.pinId))
        for pin in pins where !existingIds.contains(pin.id) {
            mapView.addAnnotation(PinAnnotation(pin: pin))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedPin: $selectedPin)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var selectedPin: Binding<MapPin?>

        init(selectedPin: Binding<MapPin?>) {
            self.selectedPin = selectedPin
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let pinAnnotation = annotation as? PinAnnotation else { return nil }
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view.glyphImage = UIImage(systemName: pinAnnotation.pin.kind.systemImage)
            view.markerTintColor = pinAnnotation.pin.verified ? .systemGreen : .systemOrange
            view.canShowCallout = true
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let pinAnnotation = annotation as? PinAnnotation else { return }
            selectedPin.wrappedValue = pinAnnotation.pin
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

private final class PinAnnotation: NSObject, MKAnnotation {
    let pin: MapPin
    var pinId: String { pin.id }
    // Tile coordinates are normalized 0–1; the tile set's own projection
    // defines the real mapping. These placeholder coordinates keep the
    // annotation API wired until the tile set is configured.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: (0.5 - pin.approxY) * 180,
                               longitude: (pin.approxX - 0.5) * 360)
    }
    var title: String? { pin.title }

    init(pin: MapPin) { self.pin = pin }
}

// MARK: - Pin detail

struct PinDetailView: View {
    var pin: MapPin
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: pin.kind.systemImage)
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                        VStack(alignment: .leading) {
                            Text(pin.title).font(.headline)
                            Text("\(pin.kind.label) · \(pin.district ?? "Leonida")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: 8) {
                        VerifiedBadge(verified: pin.verified)
                        if !pin.verified { ApproximateBadge() }
                    }
                }
                Section("Location") {
                    Text(pin.coordinateSource)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let referenceId = pin.referenceId {
                        Text("Catalog record: \(referenceId)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Source") {
                    SourceNoteView(source: pin.source)
                }
            }
            .navigationTitle(pin.kind.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    FavoriteButton(id: pin.id)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

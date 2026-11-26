import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapTabView()
                .tabItem { Label("Map", systemImage: "map.fill") }
            StoreTabView()
                .tabItem { Label("Store", systemImage: "bag.fill") }
            GarageTabView()
                .tabItem { Label("Garage", systemImage: "car.fill") }
            SavedTabView()
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }
        }
    }
}

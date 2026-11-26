import SwiftUI

// MARK: - First-run onboarding
//
// Shows the full disclaimer before anything else, plus the plain fact
// that this app does not contain the game. Shown once; the choice is
// stored in @AppStorage in LeonidaCompanionApp.

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentColor)
                        Text(AppConfig.appDisplayName)
                            .font(.largeTitle.weight(.bold))
                        Text(AppConfig.appSubtitle)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("What this app is", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                        Text("A fan-made companion for Grand Theft Auto VI: one searchable catalog for every clothing store, hairstyle, tattoo, gun and mod shop in Leonida — plus a community map, a garage livery finder, and saved favorites.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("What this app is not", systemImage: "xmark.circle.fill")
                            .font(.headline)
                        Text("This app does not contain the game. It does not provide game downloads, mods or modified files.")
                            .font(.headline.weight(.regular))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("About the data", systemImage: "info.circle.fill")
                            .font(.headline)
                        Text("Community catalogs are a week old and incomplete. Anything the community hasn't verified is marked “Being cataloged” — never guessed. Map pins are approximate until game-verified coordinates exist.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Disclaimer", systemImage: "doc.text.fill")
                            .font(.headline)
                        Text(Disclaimer.text())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

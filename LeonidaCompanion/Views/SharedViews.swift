import SwiftUI

// MARK: - Badges

/// Green "Verified" badge for records confirmed against community sources,
/// amber "Being cataloged" badge for everything still unverified.
struct VerifiedBadge: View {
    var verified: Bool

    var body: some View {
        Label(
            verified ? "Verified" : "Being cataloged",
            systemImage: verified ? "checkmark.seal.fill" : "hourglass"
        )
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(verified ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
        .foregroundStyle(verified ? .green : .orange)
        .clipShape(Capsule())
    }
}

struct EditionBadge: View {
    var edition: String?

    var body: some View {
        if let edition {
            Text(edition)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.purple.opacity(0.15))
                .foregroundStyle(.purple)
                .clipShape(Capsule())
        }
    }
}

/// "Approximate location" tag shown on every unverified map pin.
struct ApproximateBadge: View {
    var body: some View {
        Label("Approximate location", systemImage: "exclamationmark.triangle.fill")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.yellow.opacity(0.2))
            .foregroundStyle(.yellow)
            .clipShape(Capsule())
    }
}

// MARK: - Favorite button

struct FavoriteButton: View {
    var id: String
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        Button {
            favorites.toggle(id)
        } label: {
            Image(systemName: favorites.isFavorite(id) ? "bookmark.fill" : "bookmark")
        }
        .accessibilityLabel(favorites.isFavorite(id) ? "Remove from saved" : "Save")
    }
}

// MARK: - About button (usable in any tab's toolbar)

struct AboutButton: View {
    @State private var showingAbout = false

    var body: some View {
        Button {
            showingAbout = true
        } label: {
            Image(systemName: "info.circle")
        }
        .accessibilityLabel("About and credits")
        .sheet(isPresented: $showingAbout) {
            NavigationStack {
                AboutView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showingAbout = false }
                        }
                    }
            }
        }
    }
}

// MARK: - Source note

struct SourceNoteView: View {
    var source: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)
            Text("Source: \(source)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Search helpers

extension String {
    /// Case- and diacritic-insensitive containment, for search fields.
    func matches(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}

import SwiftUI

/// The small "Need help now?" button shown at the top of every screen.
/// Tapping it jumps straight to the Support tab.
struct NeedHelpButton: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Button {
            appState.selectedTab = .support
        } label: {
            Label("Need help now?", systemImage: "lifepreserver")
                .labelStyle(.titleAndIcon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.onHelp)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.help, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the Support tab with people you can reach right away.")
    }
}

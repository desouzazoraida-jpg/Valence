import SwiftUI

/// The tab bar that holds the app's four main screens.
struct RootTabView: View {
    @Environment(AppState.self) private var appState
    // @AppStorage remembers a small value even after the app closes.
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some View {
        // @Bindable lets us connect the TabView's selection to appState.
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            CheckInView()
                .tabItem { Label("Check In", systemImage: "heart.text.square") }
                .tag(AppTab.checkIn)

            PatternsView()
                .tabItem { Label("Patterns", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(AppTab.patterns)

            ScienceView()
                .tabItem { Label("Science", systemImage: "brain.head.profile") }
                .tag(AppTab.science)

            SupportView()
                .tabItem { Label("Support", systemImage: "hand.raised") }
                .tag(AppTab.support)
        }
        .tint(.brand)
        // Shows the welcome screen the very first time the app opens.
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenWelcome },
            set: { hasSeenWelcome = !$0 }
        )) {
            WelcomeView { hasSeenWelcome = true }
        }
    }
}

#Preview {
    RootTabView()
        .environment(AppState())
        .modelContainer(for: CheckIn.self, inMemory: true)
}

import SwiftUI
import SwiftData

/// The starting point of the app. @main tells Swift "run this first".
@main
struct ValenceApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(appState)
        }
        // Sets up SwiftData storage for CheckIn objects.
        .modelContainer(for: CheckIn.self)
    }
}

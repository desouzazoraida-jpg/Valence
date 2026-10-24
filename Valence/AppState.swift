import SwiftUI

/// The five tabs at the bottom of the screen.
enum AppTab: Hashable {
    case checkIn, patterns, tryThis, science, support
}

/// Shared app-wide information. Any screen can read or change it,
/// which is how the "Need help now?" button can switch to the Support tab.
@Observable
final class AppState {
    var selectedTab: AppTab = .checkIn
}

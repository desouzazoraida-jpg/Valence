import SwiftUI
import UIKit

// MARK: - Colors
//
// Valence uses a soft light-purple palette, with a calm teal as a second color.
// Every color has a light-mode and a dark-mode version, and text colors
// were picked so they stay easy to read (high contrast) on their backgrounds.

extension Color {
    /// Makes a color that automatically switches between light and dark mode.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }

    /// Very light purple page background.
    static let appBackground = Color(light: 0xF7F4FC, dark: 0x16131F)
    /// Cards sit on top of the background.
    static let card = Color(light: 0xFFFFFF, dark: 0x221E2E)
    /// Main text color (deep plum, softer than pure black).
    static let ink = Color(light: 0x231E36, dark: 0xF1EEF8)
    /// Secondary text, still dark enough to read comfortably.
    static let inkSoft = Color(light: 0x4F4A63, dark: 0xBEB7D1)
    /// Our main brand purple, used for buttons.
    static let brand = Color(light: 0x5B47A8, dark: 0xC4B5FF)
    /// Text that sits on top of a brand button.
    static let onBrand = Color(light: 0xFFFFFF, dark: 0x1E1640)
    /// Light purple for selected states and soft highlights.
    static let brandSoft = Color(light: 0xEDE7FB, dark: 0x342C52)
    /// Calm teal as a second color (the energy line and Science icons).
    static let calmTeal = Color(light: 0x2D6E73, dark: 0x8FD3CF)
    static let calmTealSoft = Color(light: 0xE3F1F0, dark: 0x1F3335)
    /// Soft colors for the four corners of the Mood Map.
    static let quadrantPleasantHigh = Color(light: 0xFFF0C7, dark: 0x4A4024)
    static let quadrantUnpleasantHigh = Color(light: 0xFBDCDD, dark: 0x4A2A2E)
    static let quadrantUnpleasantLow = Color(light: 0xDCE5F8, dark: 0x25304A)
    static let quadrantPleasantLow = Color(light: 0xDDF2E7, dark: 0x23402F)
    /// Warm coral used only for "help" so it stands out without being scary.
    static let help = Color(light: 0xA8402F, dark: 0xFFA796)
    static let onHelp = Color(light: 0xFFFFFF, dark: 0x3A0F07)
    static let helpSoft = Color(light: 0xFBE7E2, dark: 0x3D2420)
}

extension UIColor {
    /// Lets us write colors as hex numbers like 0x2F6B5E.
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

// MARK: - Reusable styles

/// A big, rounded, full-width button. Its height grows with Dynamic Type.
struct BigButtonStyle: ButtonStyle {
    var background: Color = .brand
    var foreground: Color = .onBrand
    @ScaledMetric(relativeTo: .title3) private var minHeight: CGFloat = 60

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .multilineTextAlignment(.center)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .padding(.horizontal, 16)
            .background(background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// A soft rounded card used to group content.
struct CardModifier: ViewModifier {
    var background: Color = .card

    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

extension View {
    func card(_ background: Color = .card) -> some View {
        modifier(CardModifier(background: background))
    }

    /// The shared look for every screen: cream background, readable ink text,
    /// and the "Need help now?" button in the top-right corner.
    func valenceScreen(showsHelpButton: Bool = true) -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .foregroundStyle(Color.ink)
            .toolbar {
                if showsHelpButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        NeedHelpButton()
                    }
                }
            }
    }
}

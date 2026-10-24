import SwiftUI

/// A square you tap or drag on to show how you feel.
/// Left to right: unpleasant → pleasant (valence).
/// Bottom to top: low energy → high energy (arousal).
struct MoodMap: View {
    /// The chosen spot. It's a @Binding, so the screen that uses MoodMap owns the value
    /// and MoodMap can read and change it.
    @Binding var point: MoodPoint?

    /// Goes up by one each time a finger lifts, which triggers a soft haptic tap.
    @State private var tapCount = 0

    /// How far one VoiceOver action moves the spot.
    private let step = 0.25

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width

            ZStack {
                quadrantColors
                centerLines
                axisLabels
                if let point {
                    marker
                        .position(location(of: point, size: size))
                }
            }
            .contentShape(Rectangle())
            // minimumDistance: 0 means a plain tap counts too, not just a drag.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        point = mapPoint(from: value.location, size: size)
                    }
                    .onEnded { _ in
                        tapCount += 1
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 340)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.brandSoft, lineWidth: 2)
        )
        .frame(maxWidth: .infinity)
        // Gentle haptics: a soft tap when you let go, and a tiny click when you cross into a new quadrant.
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: tapCount)
        .sensoryFeedback(.selection, trigger: point?.quadrant)
        // VoiceOver: treat the whole map as one control with actions to move the spot.
        .accessibilityElement()
        .accessibilityLabel("Mood map")
        .accessibilityValue(point?.spokenDescription ?? "No spot chosen yet")
        .accessibilityHint("Swipe up or down to pick a direction, then double-tap to move your spot.")
        .accessibilityAction(named: "More pleasant") { move(valence: step) }
        .accessibilityAction(named: "Less pleasant") { move(valence: -step) }
        .accessibilityAction(named: "More energy") { move(arousal: step) }
        .accessibilityAction(named: "Less energy") { move(arousal: -step) }
    }

    // MARK: - Pieces of the map

    private var quadrantColors: some View {
        QuadrantBackground()
    }

    private var centerLines: some View {
        ZStack {
            Rectangle().fill(Color.inkSoft.opacity(0.25)).frame(width: 1.5)
            Rectangle().fill(Color.inkSoft.opacity(0.25)).frame(height: 1.5)
        }
    }

    private var axisLabels: some View {
        ZStack {
            AxisLabel(text: "High energy").frame(maxHeight: .infinity, alignment: .top)
            AxisLabel(text: "Low energy").frame(maxHeight: .infinity, alignment: .bottom)
            AxisLabel(text: "Unpleasant").frame(maxWidth: .infinity, alignment: .leading)
            AxisLabel(text: "Pleasant").frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(8)
        // VoiceOver already reads the spot's description, so these are just for sight.
        .accessibilityHidden(true)
    }

    private var marker: some View {
        Circle()
            .fill(Color.brand)
            .frame(width: 34, height: 34)
            .overlay(Circle().strokeBorder(.white, lineWidth: 4))
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .allowsHitTesting(false)
    }

    // MARK: - Math: turning finger positions into numbers (and back)

    /// Finger position (in points) → valence/arousal from -1 to 1.
    private func mapPoint(from location: CGPoint, size: CGFloat) -> MoodPoint {
        let valence = (location.x / size) * 2 - 1
        // Screen y grows downward, but energy should grow upward, so we flip it.
        let arousal = 1 - (location.y / size) * 2
        return MoodPoint(valence: valence, arousal: arousal)
    }

    /// Valence/arousal → where to draw the marker.
    private func location(of point: MoodPoint, size: CGFloat) -> CGPoint {
        CGPoint(x: (point.valence + 1) / 2 * size,
                y: (1 - point.arousal) / 2 * size)
    }

    private func move(valence: Double = 0, arousal: Double = 0) {
        let current = point ?? MoodPoint(valence: 0, arousal: 0)
        point = MoodPoint(valence: current.valence + valence,
                          arousal: current.arousal + arousal)
        tapCount += 1
    }
}

/// The four soft quadrant colors, arranged like the Mood Map.
/// The Patterns tab reuses this behind its chart of past check-ins.
struct QuadrantBackground: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                MoodQuadrant.unpleasantHigh.color
                MoodQuadrant.pleasantHigh.color
            }
            HStack(spacing: 0) {
                MoodQuadrant.unpleasantLow.color
                MoodQuadrant.pleasantLow.color
            }
        }
    }
}

private struct AxisLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.white.opacity(0.7), in: Capsule())
            .environment(\.colorScheme, .light)
            // Keeps the labels from covering the whole map at very large text sizes.
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

#Preview {
    MoodMap(point: .constant(MoodPoint(valence: 0.5, arousal: 0.4)))
        .padding()
}

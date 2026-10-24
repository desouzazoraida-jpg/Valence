import SwiftUI

/// A short version of progressive muscle relaxation:
/// squeeze one part of your body, then let it go.
struct SqueezeReleaseView: View {
    private struct BodyPart {
        let name: String
        let symbol: String
        let squeeze: String
        let release: String
    }

    private let parts = [
        BodyPart(name: "Hands", symbol: "hand.raised",
                 squeeze: "Make tight fists, like you're squeezing a lemon.",
                 release: "Open your hands and let your fingers go loose."),
        BodyPart(name: "Shoulders", symbol: "figure.arms.open",
                 squeeze: "Lift your shoulders up toward your ears.",
                 release: "Let them drop down. Feel the weight sink."),
        BodyPart(name: "Face", symbol: "face.smiling",
                 squeeze: "Scrunch up your whole face — eyes, nose, mouth.",
                 release: "Let your face go soft. Unclench your jaw."),
        BodyPart(name: "Feet", symbol: "shoeprints.fill",
                 squeeze: "Curl your toes down hard and press your feet into the floor.",
                 release: "Relax your toes and let your feet rest."),
    ]

    @State private var partIndex = 0
    /// false while squeezing, true once it's time to let go.
    @State private var isReleasing = false

    private var isFinished: Bool { partIndex >= parts.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isFinished {
                    finishedView
                } else {
                    partView(parts[partIndex])
                }
            }
            .padding(20)
        }
        .navigationTitle("Release")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: isReleasing)
    }

    private func partView(_ part: BodyPart) -> some View {
        VStack(spacing: 24) {
            Text("\(part.name) · \(partIndex + 1) of \(parts.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.inkSoft)

            Image(systemName: part.symbol)
                .font(.system(size: 44))
                .foregroundStyle(isReleasing ? Color.calmTeal : Color.onBrand)
                .frame(width: 96, height: 96)
                .background(isReleasing ? Color.calmTealSoft : Color.brand, in: Circle())
                .accessibilityHidden(true)

            Text(isReleasing ? "Let go" : "Squeeze")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            Text(isReleasing ? part.release : part.squeeze)
                .font(.title3)
                .multilineTextAlignment(.center)

            Text(isReleasing
                 ? "Rest for about 10 seconds. Notice how different it feels."
                 : "Hold for about 5 seconds. Squeeze firmly, but stop if anything hurts.")
                .font(.body)
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)

            Button(isReleasing ? (partIndex == parts.count - 1 ? "Finish" : "Next") : "Let go") {
                withAnimation {
                    if isReleasing {
                        partIndex += 1
                        isReleasing = false
                    } else {
                        isReleasing = true
                    }
                }
            }
            .buttonStyle(BigButtonStyle())
        }
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brand)
                .accessibilityHidden(true)
            Text("All done")
                .font(.title.bold())
            Text("Your body just practiced the difference between tense and relaxed. You can use any one of these steps on its own, whenever you need it.")
                .font(.body)
                .multilineTextAlignment(.center)
            Button("Start over") {
                withAnimation {
                    partIndex = 0
                    isReleasing = false
                }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
        .padding(.top, 40)
    }
}

#Preview {
    NavigationStack {
        SqueezeReleaseView()
    }
    .environment(AppState())
}

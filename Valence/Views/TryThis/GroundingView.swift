import SwiftUI

/// The 5-4-3-2-1 grounding exercise, one sense at a time.
/// Tap "Found one" each time you notice something.
struct GroundingView: View {
    private struct Step {
        let count: Int
        let sense: String
        let symbol: String
        let hint: String
    }

    private let steps = [
        Step(count: 5, sense: "see", symbol: "eye",
             hint: "Look around slowly. A color, a shape, something small you hadn't noticed."),
        Step(count: 4, sense: "feel", symbol: "hand.point.up.left",
             hint: "Your feet on the floor, your clothes, the air, something you're holding."),
        Step(count: 3, sense: "hear", symbol: "ear",
             hint: "Near sounds and far ones. Even quiet counts — a hum, your own breath."),
        Step(count: 2, sense: "smell", symbol: "nose",
             hint: "Lean close to your sleeve, a drink, or the air. If nothing, name smells you like."),
        Step(count: 1, sense: "taste", symbol: "mouth",
             hint: "What's in your mouth right now? Or take a sip of water and notice it."),
    ]

    @State private var stepIndex = 0
    @State private var found = 0

    private var isFinished: Bool { stepIndex >= steps.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isFinished {
                    finishedView
                } else {
                    stepView(steps[stepIndex])
                }
            }
            .padding(20)
        }
        .navigationTitle("Grounding")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        .sensoryFeedback(.selection, trigger: found)
    }

    private func stepView(_ step: Step) -> some View {
        VStack(spacing: 24) {
            Text("Step \(stepIndex + 1) of \(steps.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.inkSoft)

            Image(systemName: step.symbol)
                .font(.system(size: 44))
                .foregroundStyle(Color.onBrand)
                .frame(width: 96, height: 96)
                .background(Color.brand, in: Circle())
                .accessibilityHidden(true)

            Text("Notice \(step.count) \(step.count == 1 ? "thing" : "things") you can \(step.sense)")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(step.hint)
                .font(.body)
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)

            // One dot per thing to find; they fill in as you go.
            HStack(spacing: 12) {
                ForEach(0..<step.count, id: \.self) { index in
                    Circle()
                        .fill(index < found ? Color.brand : Color.brandSoft)
                        .frame(width: 28, height: 28)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(found) of \(step.count) found")

            if found < step.count {
                Button("Found one") {
                    withAnimation { found += 1 }
                }
                .buttonStyle(BigButtonStyle())
            } else {
                Button(stepIndex == steps.count - 1 ? "Finish" : "Next sense") {
                    withAnimation {
                        stepIndex += 1
                        found = 0
                    }
                }
                .buttonStyle(BigButtonStyle())
            }
        }
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brand)
                .accessibilityHidden(true)
            Text("You did it")
                .font(.title.bold())
            Text("Take one slow breath. Notice how you feel right now compared to when you started.")
                .font(.body)
                .multilineTextAlignment(.center)
            Button("Start over") {
                withAnimation {
                    stepIndex = 0
                    found = 0
                }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
        .padding(.top, 40)
    }
}

#Preview {
    NavigationStack {
        GroundingView()
    }
    .environment(AppState())
}

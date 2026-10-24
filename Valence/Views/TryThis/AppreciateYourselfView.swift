import SwiftUI

/// Appreciate yourself: name three good things about yourself, one at a time.
/// Each step asks about a different kind of thing, so it's easier to think of one.
/// Writing is optional, and nothing typed here is saved.
struct AppreciateYourselfView: View {
    private struct Step {
        let question: String
        let symbol: String
        let hint: String
    }

    private let steps = [
        Step(question: "Something you did well today",
             symbol: "star",
             hint: "Big or small. Finishing homework, helping someone, or just getting through a hard day."),
        Step(question: "A strength you have",
             symbol: "hand.thumbsup",
             hint: "Being funny, loyal, creative, a good listener, or someone who doesn't give up."),
        Step(question: "Something you're getting better at",
             symbol: "chart.line.uptrend.xyaxis",
             hint: "A skill, a class, a sport, or handling something that used to be hard."),
    ]

    @State private var stepIndex = 0
    @State private var answers = ["", "", ""]
    @FocusState private var answerIsFocused: Bool

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
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Appreciate yourself")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        .sensoryFeedback(.selection, trigger: stepIndex)
        // The keyboard covers the big button, so put the same button above the keyboard.
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(nextTitle, action: goToNextStep)
                    .fontWeight(.semibold)
            }
        }
    }

    private var nextTitle: String {
        stepIndex == steps.count - 1 ? "Finish" : "Next"
    }

    private func goToNextStep() {
        answerIsFocused = false
        withAnimation { stepIndex += 1 }
    }

    private func stepView(_ step: Step) -> some View {
        VStack(spacing: 24) {
            Text("\(stepIndex + 1) of \(steps.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.inkSoft)

            Image(systemName: step.symbol)
                .font(.system(size: 44))
                .foregroundStyle(Color.onBrand)
                .frame(width: 96, height: 96)
                .background(Color.brand, in: Circle())
                .accessibilityHidden(true)

            Text(step.question)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(step.hint)
                .font(.body)
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)

            TextField("Write it here, or just think about it", text: $answers[stepIndex], axis: .vertical)
                .font(.body)
                .lineLimit(2...5)
                .focused($answerIsFocused)
                .padding(14)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel("Answer \(stepIndex + 1)")

            Button(nextTitle, action: goToNextStep)
                .buttonStyle(BigButtonStyle())

            Text("Optional. Nothing you write here is saved.")
                .font(.footnote)
                .foregroundStyle(Color.inkSoft)
        }
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brand)
                .accessibilityHidden(true)
            Text("Look at you")
                .font(.title.bold())

            // Show back whatever was written, as a short list.
            let written = answers
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !written.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(written, id: \.self) { answer in
                        Label(answer, systemImage: "sparkle")
                            .font(.body)
                    }
                }
                .card()
            }

            Text("Try talking to yourself the way you'd talk to a good friend. You deserve that kindness too.")
                .font(.body)
                .multilineTextAlignment(.center)
            Button("Start over") {
                withAnimation {
                    stepIndex = 0
                    answers = ["", "", ""]
                }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
        .padding(.top, 40)
    }
}

#Preview {
    NavigationStack {
        AppreciateYourselfView()
    }
    .environment(AppState())
}

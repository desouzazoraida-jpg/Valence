import SwiftUI

/// Rose, Thorn, Bud: look back on your day in three parts.
/// Rose = something good, Thorn = something hard, Bud = something you're looking forward to.
/// Writing is optional, and nothing typed here is saved.
struct RoseThornBudView: View {
    private struct Step {
        let name: String
        let symbol: String
        let question: String
        let hint: String
    }

    private let steps = [
        Step(name: "Rose", symbol: "sun.max",
             question: "What was something good today?",
             hint: "Big or small. A laugh, a good grade, a song you liked."),
        Step(name: "Thorn", symbol: "cloud.rain",
             question: "What was something hard today?",
             hint: "It's okay to name it. Hard moments are part of every day."),
        Step(name: "Bud", symbol: "leaf",
             question: "What's something you're looking forward to?",
             hint: "Something coming up, or something you'd like to grow or try."),
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
        .navigationTitle("Rose, Thorn, Bud")
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
            Text("\(step.name) · \(stepIndex + 1) of \(steps.count)")
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
                .accessibilityLabel("\(step.name) answer")

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
            Text("Your day, in three parts")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            // Show back whatever was written, so the day can be seen as a whole.
            ForEach(steps.indices, id: \.self) { index in
                let answer = answers[index].trimmingCharacters(in: .whitespacesAndNewlines)
                if !answer.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(steps[index].name, systemImage: steps[index].symbol)
                            .font(.headline)
                            .foregroundStyle(Color.brand)
                        Text(answer)
                            .font(.body)
                    }
                    .card()
                }
            }

            Text("Most days have a little of each. Noticing the good parts, and what's ahead, can make the hard parts feel smaller.")
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
        RoseThornBudView()
    }
    .environment(AppState())
}

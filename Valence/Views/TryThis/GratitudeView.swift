import SwiftUI

/// Three good things: name three things you're grateful for, one at a time.
/// Each step gives a different kind of thing to look for, so it's easier to think of one.
/// Writing is optional, and nothing typed here is saved.
struct GratitudeView: View {
    private struct Step {
        let question: String
        let symbol: String
        let hint: String
    }

    private let steps = [
        Step(question: "Something small that made today a bit better",
             symbol: "cup.and.saucer",
             hint: "A good snack, sunshine, a funny video, your favorite hoodie."),
        Step(question: "A person you're thankful for",
             symbol: "person.2",
             hint: "A friend, family member, teacher, coach, or even a pet."),
        Step(question: "Something about yourself you appreciate",
             symbol: "heart",
             hint: "Something you did, tried, or are getting better at."),
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
        .navigationTitle("Three good things")
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
            Text("Three good things")
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

            Text("Taking a moment to notice good things, even small ones, can help you feel a little lighter. Try it again tomorrow with three new ones.")
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
        GratitudeView()
    }
    .environment(AppState())
}

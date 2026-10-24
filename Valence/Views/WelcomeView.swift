import SwiftUI

/// The friendly screen people see the first time they open Valence.
struct WelcomeView: View {
    /// What to do when the person taps "Let's begin".
    var onFinish: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.onBrand)
                    .frame(width: 84, height: 84)
                    .background(Color.brand, in: Circle())
                    .accessibilityHidden(true)
                    .padding(.top, 40)

                Text("Welcome to Valence")
                    .font(.largeTitle.bold())

                Text("Every feeling you have is information, not a grade. Valence gives you a quiet minute each day to notice how you're really doing.")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 18) {
                    WelcomeRow(symbol: "heart.text.square",
                               title: "Check in",
                               text: "Tap the Mood Map, pick the feeling word that fits, and note where you are.")
                    WelcomeRow(symbol: "chart.line.uptrend.xyaxis",
                               title: "Spot patterns",
                               text: "See how your days connect over time, so you can learn what helps you.")
                    WelcomeRow(symbol: "wind",
                               title: "Try something calming",
                               text: "Short guided breathing, grounding, and squeeze-and-release.")
                    WelcomeRow(symbol: "brain.head.profile",
                               title: "Learn the science",
                               text: "Short, simple explanations of why naming your feelings actually works.")
                    WelcomeRow(symbol: "hand.raised",
                               title: "Get support",
                               text: "The \"Need help now?\" button is always at the top of the screen.")
                }
                .card()

                Text("Your check-ins stay private on this phone. Valence isn't a doctor or a replacement for one, but it can help you notice when it's time to talk to someone.")
                    .font(.body)
                    .foregroundStyle(Color.inkSoft)

                Button("Let's begin", action: onFinish)
                    .buttonStyle(BigButtonStyle())
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .foregroundStyle(Color.ink)
    }
}

private struct WelcomeRow: View {
    let symbol: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Color.brand)
                .frame(width: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(text).font(.body).foregroundStyle(Color.inkSoft)
            }
        }
        // Lets VoiceOver read the title and text together.
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WelcomeView {}
}

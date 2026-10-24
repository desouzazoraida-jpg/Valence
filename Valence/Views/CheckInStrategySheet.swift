import SwiftUI

/// Lets a quadrant be used with `.sheet(item:)`, which needs an `id`.
extension MoodQuadrant: Identifiable {
    var id: Self { self }
}

/// One short "Try This" strategy, shown right after a check-in is saved.
/// The strategy matches the part of the Mood Map that was tapped:
/// - unpleasant + high energy → paced breathing
/// - unpleasant + low energy → a movement or reach-out idea
/// - pleasant → a savoring prompt
struct CheckInStrategySheet: View {
    let quadrant: MoodQuadrant

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch quadrant {
                    case .unpleasantHigh:
                        BreathingStrategy()
                    case .unpleasantLow:
                        LowEnergyStrategy()
                    case .pleasantHigh, .pleasantLow:
                        SavoringStrategy()
                    }

                    Button("More tools in Try This") {
                        appState.selectedTab = .tryThis
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.brand)
                    .frame(maxWidth: .infinity)

                    Button {
                        appState.selectedTab = .support
                        dismiss()
                    } label: {
                        Label("Need help now? Open Support", systemImage: "lifepreserver")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.help)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .foregroundStyle(Color.ink)
            .navigationTitle("Try This")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Strategies

/// Unpleasant, high energy: slow the body down with paced breathing.
private struct BreathingStrategy: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StrategyHeader(title: "Slow your breathing",
                           text: "When feelings run hot, a longer breath out helps your body calm down. Try three slow breaths: in for 4, out for 6.")
            PacedBreathing(totalBreaths: 3, maxSize: 220)
        }
    }
}

/// Unpleasant, low energy: one small way to move or connect.
private struct LowEnergyStrategy: View {
    private static let ideas: [(symbol: String, title: String, text: String)] = [
        ("figure.walk", "Move for two minutes",
         "Stand up and walk around the room, or step outside for a moment. A little movement can lift your energy."),
        ("figure.cooldown", "Stretch it out",
         "Reach your arms over your head, roll your shoulders, and take one big breath. Small movements count."),
        ("music.note", "Move to one song",
         "Put on a song you like and move however feels okay — sway, walk, or tap along."),
        ("message", "Reach out to someone",
         "Send a short message to someone you like. Even \"hey, thinking of you\" can make you both feel more connected."),
        ("person.2", "Be near someone",
         "Go sit with a family member, friend, or pet for a few minutes. You don't have to talk about anything."),
        ("phone", "Call or voice-message a friend",
         "Hearing a familiar voice can help when you're feeling low or alone."),
    ]

    // Picks a random idea when the sheet opens. "Another idea" moves to the next one.
    @State private var index = Int.random(in: 0..<ideas.count)

    var body: some View {
        let idea = Self.ideas[index]
        VStack(alignment: .leading, spacing: 16) {
            StrategyHeader(title: idea.title, text: idea.text, symbol: idea.symbol)

            Text("When energy is low, the hardest part is starting. Pick the smallest version you can do.")
                .font(.body)
                .foregroundStyle(Color.inkSoft)

            Button("Show another idea") {
                withAnimation { index = (index + 1) % Self.ideas.count }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
    }
}

/// Pleasant feelings: savor the moment so it sticks.
private struct SavoringStrategy: View {
    private static let prompts = [
        "Replay this moment for 20 seconds. What do you see, hear, or feel right now that makes it good?",
        "Who or what helped make this moment good? Think about them for a few seconds.",
        "Pick one detail of this moment you want to remember, like a sound, a color, or something someone said.",
        "Notice where you feel this good feeling in your body. Let it stay there for a few breaths.",
        "If you told a friend about this moment, what would you say? Say it to yourself.",
    ]

    @State private var index = Int.random(in: 0..<prompts.count)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StrategyHeader(title: "Savor it",
                           text: "Good moments pass quickly. Pausing to really notice them helps the feeling last longer.",
                           symbol: "sparkles")

            Text(Self.prompts[index])
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .card(.brandSoft)

            Button("Another prompt") {
                withAnimation { index = (index + 1) % Self.prompts.count }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
    }
}

/// The icon, title, and short explanation at the top of each strategy.
private struct StrategyHeader: View {
    let title: String
    let text: String
    var symbol = "wind"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(title).font(.title2.bold())
            } icon: {
                Image(systemName: symbol).foregroundStyle(Color.brand)
            }
            .accessibilityAddTraits(.isHeader)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    CheckInStrategySheet(quadrant: .unpleasantLow)
        .environment(AppState())
}

import SwiftUI

/// One tool on the Try This menu.
/// Each card opens its tool by name (not by its place in the list),
/// so the right screen always opens, even while the keyboard is moving the page around.
enum TryThisTool: String, CaseIterable, Hashable {
    case breathing, grounding, squeeze, meditation, control, brainDump, roseBudThorn, appreciate

    var symbol: String {
        switch self {
        case .breathing: return "wind"
        case .grounding: return "leaf"
        case .squeeze: return "hand.raised.fingers.spread"
        case .meditation: return "figure.mind.and.body"
        case .control: return "checklist"
        case .brainDump: return "brain.head.profile"
        case .roseBudThorn: return "camera.macro"
        case .appreciate: return "star"
        }
    }

    var title: String {
        switch self {
        case .breathing: return "Slow breathing"
        case .grounding: return "5-4-3-2-1 grounding"
        case .squeeze: return "Squeeze and release"
        case .meditation: return "Quiet meditation"
        case .control: return "What's in your control?"
        case .brainDump: return "Brain dump"
        case .roseBudThorn: return "Rose, Bud, Thorn"
        case .appreciate: return "Appreciate yourself"
        }
    }

    var time: String {
        switch self {
        case .breathing: return "1 to 3 minutes"
        case .grounding, .control, .roseBudThorn: return "About 3 minutes"
        case .squeeze, .appreciate: return "About 2 minutes"
        case .meditation: return "2, 5, or 10 minutes"
        case .brainDump: return "As long as you need"
        }
    }

    var detail: String {
        switch self {
        case .breathing: return "Breathe in for 4, out for 6. A longer breath out helps your body relax."
        case .grounding: return "Use your five senses to bring your attention back to right now."
        case .squeeze: return "Tense one part of your body, then let it go, to feel the difference."
        case .meditation: return "Sit quietly and follow gentle prompts, with a timer that counts down for you."
        case .control: return "Feeling stressed? Sort what you can change from what you can't, then pick one small step."
        case .brainDump: return "Too much on your mind? Write it all out, then let it go."
        case .roseBudThorn: return "Look back on your day: something good, something you're looking forward to, and something hard."
        case .appreciate: return "Name something you did well, a strength you have, and something you're getting better at."
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .breathing: BreathingView()
        case .grounding: GroundingView()
        case .squeeze: SqueezeReleaseView()
        case .meditation: MeditationView()
        case .control: ControlView()
        case .brainDump: BrainDumpView()
        case .roseBudThorn: RoseBudThornView()
        case .appreciate: AppreciateYourselfView()
        }
    }
}

/// A menu of short calming tools. Each card opens a guided exercise.
struct TryThisView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Small things that can help your body and mind settle in a few minutes.")
                        .font(.title3)
                        .foregroundStyle(Color.inkSoft)

                    ForEach(TryThisTool.allCases, id: \.self) { tool in
                        NavigationLink(value: tool) {
                            ToolCard(symbol: tool.symbol, title: tool.title, time: tool.time, detail: tool.detail)
                        }
                    }

                    Text("If you're having a really hard time, the Support tab has people you can reach any time.")
                        .font(.footnote)
                        .foregroundStyle(Color.inkSoft)
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .navigationTitle("Try This")
            .navigationDestination(for: TryThisTool.self) { tool in
                tool.destination
            }
            .valenceScreen()
        }
    }
}

/// One tool on the Try This menu.
private struct ToolCard: View {
    let symbol: String
    let title: String
    let time: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Color.onBrand)
                .frame(width: 52, height: 52)
                .background(Color.brand, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3.bold())
                Text(time)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.calmTeal)
                Text(detail)
                    .font(.body)
                    .foregroundStyle(Color.inkSoft)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.inkSoft)
                .accessibilityHidden(true)
        }
        .foregroundStyle(Color.ink)
        .card()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TryThisView()
        .environment(AppState())
}

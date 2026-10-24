import SwiftUI

/// A menu of short calming tools. Each card opens a guided exercise.
struct TryThisView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Small things that can help your body and mind settle in a few minutes.")
                        .font(.title3)
                        .foregroundStyle(Color.inkSoft)

                    NavigationLink {
                        BreathingView()
                    } label: {
                        ToolCard(symbol: "wind",
                                 title: "Slow breathing",
                                 time: "1 to 3 minutes",
                                 detail: "Breathe in for 4, out for 6. A longer breath out helps your body relax.")
                    }

                    NavigationLink {
                        GroundingView()
                    } label: {
                        ToolCard(symbol: "leaf",
                                 title: "5-4-3-2-1 grounding",
                                 time: "About 3 minutes",
                                 detail: "Use your five senses to bring your attention back to right now.")
                    }

                    NavigationLink {
                        SqueezeReleaseView()
                    } label: {
                        ToolCard(symbol: "hand.raised.fingers.spread",
                                 title: "Squeeze and release",
                                 time: "About 2 minutes",
                                 detail: "Tense one part of your body, then let it go, to feel the difference.")
                    }

                    Text("If you're having a really hard time, the Support tab has people you can reach any time.")
                        .font(.footnote)
                        .foregroundStyle(Color.inkSoft)
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .navigationTitle("Try This")
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

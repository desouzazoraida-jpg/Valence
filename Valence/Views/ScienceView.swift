import SwiftUI

/// Short, friendly explanations of the ideas behind Valence.
struct ScienceView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Why checking in works")
                        .font(.title2)
                        .foregroundStyle(Color.inkSoft)

                    ForEach(ScienceTopic.all) { topic in
                        ScienceCard(topic: topic)
                    }

                    Text("These are simple summaries for learning, not medical advice.")
                        .font(.footnote)
                        .foregroundStyle(Color.inkSoft)
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .navigationTitle("Science")
            .valenceScreen()
        }
    }
}

struct ScienceTopic: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let body: String

    static let all: [ScienceTopic] = [
        ScienceTopic(symbol: "circle.lefthalf.filled",
                     title: "What is \"valence\"?",
                     body: "Psychologists describe feelings using two ideas: valence (how pleasant or unpleasant a feeling is) and arousal (how much energy comes with it). That's why the Mood Map goes from unpleasant to pleasant one way, and from low to high energy the other."),
        ScienceTopic(symbol: "textformat.abc",
                     title: "Precise words help more",
                     body: "Research on \"emotional granularity\" suggests that people who can name feelings precisely — like \"frustrated\" or \"lonely\" instead of just \"bad\" — tend to handle stress better. That's why Valence offers specific words."),
        ScienceTopic(symbol: "text.bubble",
                     title: "Naming a feeling can calm it",
                     body: "Studies on \"affect labeling\" found that putting a feeling into words can make it feel less intense. Just saying \"I feel worried\" is a small but real step."),
        ScienceTopic(symbol: "chart.dots.scatter",
                     title: "Patterns beat single days",
                     body: "One bad day doesn't tell the whole story. Tracking over weeks helps you notice what tends to come before your better and harder days."),
        ScienceTopic(symbol: "moon.zzz",
                     title: "Sleep shapes your mood",
                     body: "Teens need about 8 to 10 hours of sleep. When sleep is short, emotions often feel bigger and harder to handle the next day."),
        ScienceTopic(symbol: "figure.walk",
                     title: "Moving helps",
                     body: "Physical activity — even a short walk — is linked with better mood and less stress. It doesn't have to be a workout to count."),
        ScienceTopic(symbol: "person.2",
                     title: "Connection matters",
                     body: "Talking with people you trust is one of the strongest protectors of mental health. Reaching out is a strength, not a weakness."),
    ]
}

private struct ScienceCard: View {
    let topic: ScienceTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(topic.title).font(.title3.bold())
            } icon: {
                Image(systemName: topic.symbol)
                    .foregroundStyle(Color.calmTeal)
            }
            Text(topic.body)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .card()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ScienceView()
        .environment(AppState())
}

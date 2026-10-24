import SwiftUI

/// The ideas behind Valence, in three sections:
/// valence and arousal, why precise emotion words help, and the research paper.
struct ScienceView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("The ideas behind Valence, in plain words.")
                        .font(.title3)
                        .foregroundStyle(Color.inkSoft)

                    ForEach(ScienceSection.all) { section in
                        ScienceSectionView(section: section)
                    }

                    Text("These are simple summaries for learning, not medical advice.")
                        .font(.footnote)
                        .foregroundStyle(Color.inkSoft)
                }
                .padding(20)
            }
            .navigationTitle("Science")
            .valenceScreen()
        }
    }
}

/// One section of the Science tab: a title and a few short cards.
struct ScienceSection: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let cards: [Card]

    struct Card: Identifiable {
        let id = UUID()
        let heading: String
        /// Paragraph text. **Double asterisks** make words bold.
        let body: String
    }

    static let all: [ScienceSection] = [
        ScienceSection(symbol: "circle.lefthalf.filled", title: "Valence and arousal", cards: [
            Card(heading: "Two questions describe any feeling",
                 body: "Psychologists often describe a feeling with two simple questions. **Valence:** how pleasant or unpleasant does it feel? **Arousal:** how much energy comes with it — calm and slow, or buzzing and fired up?"),
            Card(heading: "Put them together and you get a map",
                 body: "With pleasant to unpleasant going one way and low to high energy going the other, every feeling lands somewhere on a map with four corners. That's the Mood Map you tap on Check In. Psychologist James Russell described this idea in 1980, and it's called the **circumplex model** of emotion."),
            Card(heading: "Why both matter",
                 body: "Anger and excitement are both high energy, but one is unpleasant and one is pleasant. Sadness and calm are both low energy, but they feel very different. Knowing both numbers helps pick what might help, which is why Valence suggests calming breaths for tense feelings, gentle movement or connection for low ones, and savoring for good ones."),
        ]),
        ScienceSection(symbol: "textformat.abc", title: "Why naming emotions precisely helps", cards: [
            Card(heading: "\"Bad\" can mean a lot of things",
                 body: "Frustrated, lonely, embarrassed, and exhausted are all \"bad,\" but each one needs something different. A precise word points you toward what might actually help."),
            Card(heading: "Naming a feeling can turn down its volume",
                 body: "In brain-imaging studies led by Matthew Lieberman at UCLA, people who put their feelings into words showed less activity in the **amygdala**, a part of the brain involved in strong emotional reactions. Researchers call this **affect labeling**."),
            Card(heading: "Emotional granularity is a skill",
                 body: "Psychologist Lisa Feldman Barrett uses the term **emotional granularity** for how finely someone can tell their feelings apart. Research suggests people with higher granularity tend to handle stress more flexibly. Like any skill, it grows with practice. Every time you pick a specific word in Valence, you're practicing, and the Patterns tab counts how many different words you've used."),
        ]),
        ScienceSection(symbol: "waveform.path.ecg", title: "The research behind Valence", cards: [
            Card(heading: "My research paper",
                 body: "**CRD: Causal Representational Disentanglement with Cross-Environment Supervised Contrastive Learning for EEG-Based Emotion Recognition**, by Zoraida D'Souza and Shresth Gupta."),
            Card(heading: "The question",
                 body: "Computers can guess emotions from brainwaves (EEG) with very high accuracy. But they can take shortcuts: they may learn patterns that belong to one person or one recording session instead of the emotion itself. Then they may not work as well in a new setting. The paper asks how to find emotion signals that stay true across different **environments**."),
            Card(heading: "The idea",
                 body: "CRD splits what the model learns into two parts: an **emotion part**, which makes the prediction, and a **style part**, which soaks up details about the recording conditions. A new training method, **Cross-Environment Supervised Contrastive learning (CE-SupCon)**, pulls together examples of the same emotion that were recorded in different environments, so the emotion part learns what stays the same."),
            Card(heading: "The data",
                 body: "A public dataset recorded with a 4-sensor Muse headband while two people watched short film clips chosen to feel positive, negative, or neutral."),
            Card(heading: "What happened",
                 body: "Over 10 runs, CRD averaged **96.9%** accuracy, compared with **96.7%** for a matching model without CRD. That difference was too small to be statistically significant. CRD did hold up better when one sensor was removed (**89.5% vs. 85.1%**) and on data from a different environment group (**58.4% vs. 55.7%**). It was slightly weaker when random noise was added and at judging its own confidence, and its two parts weren't fully separated yet. The paper reports all of these results openly, including the ones that didn't favor CRD."),
            Card(heading: "How it connects to Valence",
                 body: "Both projects ask the same question: how do feelings change across environments? The paper looks for emotion signals that stay steady from one setting to another. Valence helps you notice how your own feelings change across school, home, friends, sports, and online. The next step for the research is testing with more people, real recording sessions, and more datasets."),
        ]),
    ]
}

private struct ScienceSectionView: View {
    let section: ScienceSection

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text(section.title)
                    .font(.title2.bold())
            } icon: {
                Image(systemName: section.symbol)
                    .foregroundStyle(Color.calmTeal)
            }
            .accessibilityAddTraits(.isHeader)

            ForEach(section.cards) { card in
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.heading)
                        .font(.headline)
                    // LocalizedStringKey turns **double asterisks** into bold text.
                    Text(LocalizedStringKey(card.body))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .card()
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#Preview {
    ScienceView()
        .environment(AppState())
}

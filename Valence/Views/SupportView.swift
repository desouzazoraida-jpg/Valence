import SwiftUI

/// Real people you can reach right away, plus a calming exercise.
/// The "Need help now?" button on every other screen opens this tab.
struct SupportView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("You don't have to handle this alone. These free services are open 24/7 in the U.S.")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("If you're in danger right now")
                            .font(.headline)
                        Link(destination: URL(string: "tel:911")!) {
                            Label("Call 911", systemImage: "phone.fill")
                        }
                        .buttonStyle(BigButtonStyle(background: .help, foreground: .onHelp))
                    }
                    .card(.helpSoft)

                    ResourceCard(
                        title: "988 Suicide & Crisis Lifeline",
                        detail: "Call or text 988 to talk with a trained counselor about anything that's hard.",
                        actions: [
                            ("Call 988", "phone.fill", "tel:988"),
                            ("Text 988", "message.fill", "sms:988"),
                        ])

                    ResourceCard(
                        title: "Crisis Text Line",
                        detail: "Text HOME to 741741 to chat with a volunteer crisis counselor.",
                        actions: [
                            ("Text HOME to 741741", "message.fill", "sms:741741&body=HOME"),
                        ])

                    ResourceCard(
                        title: "The Trevor Project",
                        detail: "Support for LGBTQ+ young people. Call, or text START to 678-678.",
                        actions: [
                            ("Call 1-866-488-7386", "phone.fill", "tel:18664887386"),
                            ("Text START to 678-678", "message.fill", "sms:678678&body=START"),
                        ])

                    GroundingCard()

                    Text("You can also talk to a parent, school counselor, teacher, coach, or doctor you trust.")
                        .font(.body)
                        .foregroundStyle(Color.inkSoft)
                }
                .padding(20)
            }
            .navigationTitle("Support")
            // You're already on Support, so the help button isn't needed here.
            .valenceScreen(showsHelpButton: false)
        }
    }
}

private struct ResourceCard: View {
    let title: String
    let detail: String
    /// Each action is (button text, icon name, link).
    let actions: [(String, String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            Text(detail)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(actions, id: \.0) { action in
                if let url = URL(string: action.2) {
                    Link(destination: url) {
                        Label(action.0, systemImage: action.1)
                    }
                    .buttonStyle(BigButtonStyle())
                }
            }
        }
        .card()
    }
}

/// The 5-4-3-2-1 grounding exercise, a simple way to calm down using your senses.
private struct GroundingCard: View {
    private let steps = [
        ("5", "things you can see"),
        ("4", "things you can feel"),
        ("3", "things you can hear"),
        ("2", "things you can smell"),
        ("1", "thing you can taste"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Try 5-4-3-2-1 grounding", systemImage: "leaf")
                .font(.title3.bold())
            Text("Slowly notice:")
                .font(.body)
            ForEach(steps, id: \.0) { step in
                HStack(spacing: 12) {
                    Text(step.0)
                        .font(.title3.bold())
                        .frame(minWidth: 36, minHeight: 36)
                        .background(Color.brandSoft, in: Circle())
                    Text(step.1).font(.body)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .card(.calmTealSoft)
    }
}

#Preview {
    SupportView()
        .environment(AppState())
}

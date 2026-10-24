import SwiftUI

/// Real people you can reach right away, plus a link to calming tools.
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

                    TryThisLinkCard()

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

/// Points to the calming tools on the Try This tab.
private struct TryThisLinkCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Need a moment to calm down?", systemImage: "wind")
                .font(.title3.bold())
            Text("Slow breathing, grounding, and squeeze-and-release can help your body settle in a few minutes.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Try This") {
                appState.selectedTab = .tryThis
            }
            .buttonStyle(BigButtonStyle())
        }
        .card(.calmTealSoft)
    }
}

#Preview {
    SupportView()
        .environment(AppState())
}

import SwiftUI

/// Brain dump: write out everything on your mind, with no rules,
/// then clear it away. Getting thoughts out of your head and onto a page
/// can make them feel smaller. Nothing typed here is saved.
struct BrainDumpView: View {
    @State private var text = ""
    @State private var isDone = false
    @FocusState private var editorIsFocused: Bool

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isDone {
                    doneView
                } else {
                    writeView
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Brain dump")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        .sensoryFeedback(.success, trigger: isDone)
        // The keyboard covers the big button, so put it above the keyboard too.
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("I'm done", action: finish)
                    .fontWeight(.semibold)
                    .disabled(!hasText)
            }
        }
    }

    private var writeView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.onBrand)
                    .frame(width: 88, height: 88)
                    .background(Color.brand, in: Circle())
                    .accessibilityHidden(true)
                Text("Get it all out")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Text("Write whatever is in your head: worries, to-dos, random thoughts. No need for full sentences or spelling. Keep going until you run out.")
                    .font(.body)
                    .foregroundStyle(Color.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            TextField("Start typing…", text: $text, axis: .vertical)
                .font(.body)
                .lineLimit(8...)
                .focused($editorIsFocused)
                .padding(14)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel("Brain dump")

            Button("I'm done", action: finish)
                .buttonStyle(BigButtonStyle())
                .disabled(!hasText)
                .opacity(hasText ? 1 : 0.5)

            Text("Nothing you write here is saved.")
                .font(.footnote)
                .foregroundStyle(Color.inkSoft)
                .frame(maxWidth: .infinity)
        }
    }

    private var doneView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brand)
                .accessibilityHidden(true)
            Text("It's out of your head")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text("Your thoughts have been cleared away. Take one slow breath. If one of those things still needs action, you can sort it out next.")
                .font(.body)
                .multilineTextAlignment(.center)

            NavigationLink(value: TryThisTool.control) {
                Text("Sort what's in my control")
            }
            .buttonStyle(BigButtonStyle())

            Button("Write more") {
                withAnimation { isDone = false }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
        .padding(.top, 40)
    }

    private func finish() {
        guard hasText else { return }
        editorIsFocused = false
        withAnimation {
            text = ""
            isDone = true
        }
    }
}

#Preview {
    NavigationStack {
        BrainDumpView()
    }
    .environment(AppState())
}

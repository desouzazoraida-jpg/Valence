import SwiftUI

/// What's in your control? A tool for stress.
/// 1. List what's stressing you.
/// 2. Sort each thing: can you control it, or not?
/// 3. Pick one small step for what you can control, and let go of what you can't.
/// Nothing typed here is saved.
struct ControlView: View {
    private enum Stage { case list, sort, plan }

    private struct Stressor: Identifiable {
        let id = UUID()
        let text: String
        /// nil until it has been sorted.
        var canControl: Bool?
    }

    @State private var stage = Stage.list
    @State private var stressors: [Stressor] = []
    @State private var draft = ""
    @State private var sortIndex = 0
    @State private var smallStep = ""
    @FocusState private var fieldIsFocused: Bool

    private var inControl: [Stressor] { stressors.filter { $0.canControl == true } }
    private var outOfControl: [Stressor] { stressors.filter { $0.canControl == false } }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch stage {
                case .list: listStage
                case .sort: sortStage
                case .plan: planStage
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("What's in your control?")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        .sensoryFeedback(.selection, trigger: sortIndex)
        // The keyboard covers the big button, so put it above the keyboard too.
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if stage == .list && !stressors.isEmpty {
                    Button("Sort them", action: startSorting)
                        .fontWeight(.semibold)
                } else {
                    Button("Done") { fieldIsFocused = false }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Step 1: list

    private var listStage: some View {
        VStack(spacing: 24) {
            StageHeader(symbol: "list.bullet", step: "Step 1 of 3",
                        title: "What's stressing you?",
                        hint: "Add each thing on its own. A test, a fight with a friend, a busy week, something in the news.")

            HStack(spacing: 10) {
                TextField("Something on your mind", text: $draft)
                    .font(.body)
                    .focused($fieldIsFocused)
                    .submitLabel(.next)
                    .onSubmit(addDraft)
                    .padding(14)
                    .background(Color.card, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityLabel("Something that's stressing you")
                Button("Add", action: addDraft)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.brand)
                    .disabled(trimmedDraft.isEmpty)
            }

            if !stressors.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(stressors) { stressor in
                        HStack {
                            Text(stressor.text)
                                .font(.body)
                            Spacer()
                            Button {
                                withAnimation { stressors.removeAll { $0.id == stressor.id } }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.inkSoft)
                            }
                            .accessibilityLabel("Remove \(stressor.text)")
                        }
                    }
                }
                .card()
            }

            Button("Sort them", action: startSorting)
                .buttonStyle(BigButtonStyle())
                .disabled(stressors.isEmpty)
                .opacity(stressors.isEmpty ? 0.5 : 1)
                .accessibilityHint(stressors.isEmpty ? "Add at least one thing first." : "")

            Text("Nothing you write here is saved.")
                .font(.footnote)
                .foregroundStyle(Color.inkSoft)
        }
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addDraft() {
        guard !trimmedDraft.isEmpty else { return }
        withAnimation { stressors.append(Stressor(text: trimmedDraft)) }
        draft = ""
        // Keep the keyboard up so the next thing can be typed right away.
        fieldIsFocused = true
    }

    private func startSorting() {
        // Anything still typed in the box counts too.
        addDraft()
        fieldIsFocused = false
        withAnimation {
            sortIndex = 0
            stage = .sort
        }
    }

    // MARK: - Step 2: sort

    @ViewBuilder
    private var sortStage: some View {
        if sortIndex < stressors.count {
            VStack(spacing: 24) {
                StageHeader(symbol: "arrow.left.arrow.right", step: "Step 2 of 3 · \(sortIndex + 1) of \(stressors.count)",
                            title: "Can you control this?",
                            hint: "Even part of it counts, like how much you study, or what you say next.")

                Text(stressors[sortIndex].text)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .card(.brandSoft)

                Button("Yes, at least part of it") { sort(canControl: true) }
                    .buttonStyle(BigButtonStyle())
                Button("No, not really") { sort(canControl: false) }
                    .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
            }
        }
    }

    private func sort(canControl: Bool) {
        stressors[sortIndex].canControl = canControl
        withAnimation {
            sortIndex += 1
            if sortIndex >= stressors.count { stage = .plan }
        }
    }

    // MARK: - Step 3: plan

    private var planStage: some View {
        VStack(alignment: .leading, spacing: 20) {
            StageHeader(symbol: "checkmark.circle", step: "Step 3 of 3",
                        title: "Focus on what you can change",
                        hint: "Put your energy where it can make a difference.")

            if inControl.isEmpty {
                Text("Nothing on your list feels in your control right now, and that's okay. How you take care of yourself is still up to you.")
                    .font(.body)
                    .card()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Label("In your control", systemImage: "hand.raised")
                        .font(.headline)
                        .foregroundStyle(Color.brand)
                    ForEach(inControl) { Text("• \($0.text)").font(.body) }
                    Text("Pick one small step you could take today.")
                        .font(.subheadline.weight(.semibold))
                        .padding(.top, 4)
                    TextField("For example: study for 20 minutes", text: $smallStep, axis: .vertical)
                        .font(.body)
                        .lineLimit(1...4)
                        .focused($fieldIsFocused)
                        .padding(14)
                        .background(Color.appBackground, in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityLabel("One small step")
                }
                .card()
            }

            if !outOfControl.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Not in your control", systemImage: "wind")
                        .font(.headline)
                        .foregroundStyle(Color.calmTeal)
                    ForEach(outOfControl) { Text("• \($0.text)").font(.body) }
                    Text("You can't change these, and worrying won't either. Try letting them go for now. A few slow breaths, or talking to someone you trust, can help.")
                        .font(.body)
                        .foregroundStyle(Color.inkSoft)
                    NavigationLink(value: TryThisTool.breathing) {
                        Label("Try slow breathing", systemImage: "wind")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.brand)
                    }
                }
                .card()
            }

            Button("Start over") {
                withAnimation {
                    stressors = []
                    draft = ""
                    smallStep = ""
                    sortIndex = 0
                    stage = .list
                }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))

            Text("Nothing you write here is saved.")
                .font(.footnote)
                .foregroundStyle(Color.inkSoft)
                .frame(maxWidth: .infinity)
        }
    }
}

/// The icon, step label, title, and hint at the top of each step.
private struct StageHeader: View {
    let symbol: String
    let step: String
    let title: String
    let hint: String

    var body: some View {
        VStack(spacing: 16) {
            Text(step)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.inkSoft)
            Image(systemName: symbol)
                .font(.system(size: 40))
                .foregroundStyle(Color.onBrand)
                .frame(width: 88, height: 88)
                .background(Color.brand, in: Circle())
                .accessibilityHidden(true)
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(hint)
                .font(.body)
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ControlView()
    }
    .environment(AppState())
}

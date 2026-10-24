import SwiftUI
import SwiftData

/// The main screen: place a spot on the Mood Map, pick a feeling word,
/// pick where you are, add a note, and save.
struct CheckInView: View {
    // modelContext is how we save things with SwiftData.
    @Environment(\.modelContext) private var modelContext

    // @State holds values that can change while the screen is open.
    // When one changes, SwiftUI redraws the parts of the screen that use it.
    @State private var point: MoodPoint?
    @State private var feeling: FeelingWord?
    @State private var setting: CheckInSetting?
    @State private var note = ""
    @State private var showSavedMessage = false
    /// The quadrant of the check-in just saved. Setting it opens the "Try This" strategy sheet.
    @State private var strategyQuadrant: MoodQuadrant?
    @FocusState private var noteIsFocused: Bool

    /// The 6 words that match where the spot is right now.
    private var suggestedWords: [FeelingWord] {
        guard let point else { return [] }
        return point.quadrant.suggestedWords(near: point)
    }

    private var canSave: Bool {
        point != nil && feeling != nil && setting != nil
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scroller in
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        Text(greeting)
                            .font(.title2)
                            .foregroundStyle(Color.inkSoft)
                            .id("top")

                        if showSavedMessage {
                            savedBanner
                        }

                        moodMapSection

                        if point != nil {
                            feelingSection
                            settingSection
                            noteSection
                            saveButton
                        }
                    }
                    .padding(20)
                    .animation(.easeInOut(duration: 0.25), value: point == nil)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: showSavedMessage) { _, isShowing in
                    if isShowing {
                        withAnimation { scroller.scrollTo("top") }
                    }
                }
            }
            .navigationTitle("Check In")
            .valenceScreen()
            // After saving, show one short strategy that matches the quadrant.
            .sheet(item: $strategyQuadrant) { quadrant in
                CheckInStrategySheet(quadrant: quadrant)
                    .presentationDetents([.large])
            }
            // If the spot moves and the chosen word no longer fits, clear it.
            // Hide the "Saved" message once a new check-in starts.
            .onChange(of: point) { _, newPoint in
                if newPoint != nil { showSavedMessage = false }
            }
            .onChange(of: suggestedWords) { _, words in
                if let feeling, !words.contains(feeling) {
                    self.feeling = nil
                }
            }
        }
    }

    // MARK: - Sections

    private var moodMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Where are you on the Mood Map?",
                          subtitle: "Tap or drag to the spot that matches how you feel.")
            MoodMap(point: $point)
            if let point {
                Label(point.quadrant.title, systemImage: "mappin.and.ellipse")
                    .font(.headline)
                    .foregroundStyle(Color.brand)
                    .frame(maxWidth: .infinity)
                    // MoodMap already speaks this, so VoiceOver doesn't need to hear it twice.
                    .accessibilityHidden(true)
            }
        }
    }

    private var feelingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Which word fits best?",
                          subtitle: "The more precise the word, the more it helps.")
            ChipGrid {
                ForEach(suggestedWords) { word in
                    ChoiceChip(title: word.word,
                               hint: word.meaning,
                               isSelected: feeling == word) {
                        feeling = word
                    }
                }
            }
            if let feeling {
                Text("**\(feeling.word):** \(feeling.meaning)")
                    .font(.body)
                    .card(.brandSoft)
            }
        }
    }

    private var settingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Where are you?", subtitle: nil)
            ChipGrid {
                ForEach(CheckInSetting.allCases) { option in
                    ChoiceChip(title: option.rawValue,
                               symbol: option.symbol,
                               isSelected: setting == option) {
                        setting = option
                    }
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Anything to add?", subtitle: "Optional. Only you will see this.")
            TextField("One line about what's going on", text: $note)
                .font(.body)
                .focused($noteIsFocused)
                .submitLabel(.done)
                .padding(14)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel("Note")
        }
    }

    private var saveButton: some View {
        Button("Save check-in", action: save)
            .buttonStyle(BigButtonStyle())
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)
            .accessibilityHint(canSave ? "" : "Pick a feeling word and where you are first.")
    }

    private var savedBanner: some View {
        Label("Saved. Thanks for checking in with yourself.", systemImage: "checkmark.circle.fill")
            .font(.headline)
            .foregroundStyle(Color.brand)
            .card(.brandSoft)
            .transition(.opacity)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning. Take a breath — there's no wrong answer."
        case 12..<17: return "Good afternoon. How is today going for you?"
        case 17..<22: return "Good evening. Let's check in on your day."
        default: return "It's late. Be gentle with yourself tonight."
        }
    }

    // MARK: - Saving

    private func save() {
        guard let point, let feeling, let setting else { return }
        let savedQuadrant = point.quadrant
        let checkIn = CheckIn(valence: point.valence,
                              arousal: point.arousal,
                              feeling: feeling.word,
                              environment: setting,
                              note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        // insert() hands the new check-in to SwiftData, which saves it automatically.
        modelContext.insert(checkIn)

        // Reset the form so it's ready for next time.
        self.point = nil
        self.feeling = nil
        self.setting = nil
        note = ""
        noteIsFocused = false
        withAnimation { showSavedMessage = true }
        // Tells VoiceOver users the save worked.
        AccessibilityNotification.Announcement("Check-in saved").post()
        strategyQuadrant = savedQuadrant
    }
}

/// A bold title with an optional smaller line under it.
private struct SectionHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSoft)
            }
        }
    }
}

#Preview {
    CheckInView()
        .environment(AppState())
        .modelContainer(for: CheckIn.self, inMemory: true)
}

import SwiftUI

/// Guided slow breathing on the Try This tab: pick a length, then follow the circle.
struct BreathingView: View {
    /// How long to breathe, in minutes. Each breath takes 10 seconds, so 6 breaths a minute.
    @State private var minutes = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Breathe in through your nose for 4 seconds, then out slowly for 6. A longer breath out tells your body it's safe to slow down.")
                    .font(.body)
                    .foregroundStyle(Color.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("How long", selection: $minutes) {
                    Text("1 min").tag(1)
                    Text("2 min").tag(2)
                    Text("3 min").tag(3)
                }
                .pickerStyle(.segmented)

                PacedBreathing(totalBreaths: minutes * 6)
                    // A new length starts a fresh exercise.
                    .id(minutes)
            }
            .padding(20)
        }
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
    }
}

#Preview {
    NavigationStack {
        BreathingView()
    }
    .environment(AppState())
}

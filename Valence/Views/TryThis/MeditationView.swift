import SwiftUI

/// A short guided meditation: pick a length, then sit quietly while a timer
/// counts down and a new gentle prompt appears every 30 seconds.
struct MeditationView: View {
    private let prompts = [
        "Get comfortable. Let your eyes close, or rest them on one spot.",
        "Notice your breath. You don't need to change it, just feel it.",
        "Feel where your body touches the chair or the floor.",
        "If your mind wanders, that's normal. Gently come back to your breath.",
        "Let your shoulders drop and your jaw soften.",
        "Notice any sounds around you, then let them fade into the background.",
        "Breathe in calm. Breathe out anything you don't need right now.",
        "Picture a place where you feel safe and relaxed.",
    ]

    /// How long to meditate, in minutes.
    @State private var minutes = 2
    @State private var secondsLeft = 0
    @State private var isRunning = false
    @State private var isFinished = false

    private var totalSeconds: Int { minutes * 60 }
    private var secondsDone: Int { totalSeconds - secondsLeft }
    private var currentPrompt: String { prompts[(secondsDone / 30) % prompts.count] }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                if isFinished {
                    finishedView
                } else if isRunning || secondsLeft > 0 {
                    timerView
                } else {
                    startView
                }
            }
            .padding(20)
        }
        .navigationTitle("Meditation")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        .sensoryFeedback(.success, trigger: isFinished)
        // Counts down once a second while running; stops if you leave the screen.
        .task(id: isRunning) {
            while isRunning && secondsLeft > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard isRunning, !Task.isCancelled else { break }
                secondsLeft -= 1
                if secondsLeft == 0 {
                    isRunning = false
                    withAnimation { isFinished = true }
                }
            }
        }
    }

    private var startView: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 44))
                .foregroundStyle(Color.onBrand)
                .frame(width: 96, height: 96)
                .background(Color.brand, in: Circle())
                .accessibilityHidden(true)
            Text("Take a quiet moment")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            Text("Find a comfortable spot. A new gentle prompt will appear every 30 seconds. There's no wrong way to do this.")
                .font(.body)
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)

            Picker("How long", selection: $minutes) {
                Text("2 min").tag(2)
                Text("5 min").tag(5)
                Text("10 min").tag(10)
            }
            .pickerStyle(.segmented)

            Button("Begin") {
                secondsLeft = totalSeconds
                isRunning = true
            }
            .buttonStyle(BigButtonStyle())
        }
    }

    private var timerView: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .stroke(Color.brandSoft, lineWidth: 12)
                Circle()
                    .trim(from: 0, to: Double(secondsDone) / Double(totalSeconds))
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: secondsLeft)
                Text(timeText)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 220, height: 220)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(timeText) left")

            Text(currentPrompt)
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(minHeight: 90)
                .id(currentPrompt)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.8), value: currentPrompt)

            Button(isRunning ? "Pause" : "Keep going") {
                isRunning.toggle()
            }
            .buttonStyle(BigButtonStyle())

            Button("End early") {
                isRunning = false
                withAnimation { isFinished = true }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
    }

    private var timeText: String {
        String(format: "%d:%02d", secondsLeft / 60, secondsLeft % 60)
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brand)
                .accessibilityHidden(true)
            Text("Nicely done")
                .font(.title.bold())
            Text("Before you move on, notice how your body feels now compared to when you started.")
                .font(.body)
                .multilineTextAlignment(.center)
            Button("Start over") {
                withAnimation {
                    isFinished = false
                    secondsLeft = 0
                }
            }
            .buttonStyle(BigButtonStyle(background: .brandSoft, foreground: .brand))
        }
        .padding(.top, 40)
    }
}

#Preview {
    NavigationStack {
        MeditationView()
    }
    .environment(AppState())
}

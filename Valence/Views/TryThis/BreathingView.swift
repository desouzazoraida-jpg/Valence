import SwiftUI

/// Guided slow breathing: in for 4 seconds, out for 6.
/// A circle grows as you breathe in and shrinks as you breathe out.
struct BreathingView: View {
    private enum Phase: Equatable {
        case ready, breatheIn, breatheOut, done

        var seconds: Int {
            switch self {
            case .breatheIn: return 4
            case .breatheOut: return 6
            default: return 0
            }
        }

        var instruction: String {
            switch self {
            case .ready: return "Get comfortable"
            case .breatheIn: return "Breathe in"
            case .breatheOut: return "Breathe out"
            case .done: return "Nice work"
            }
        }
    }

    /// How long to breathe, in minutes. Each breath takes 10 seconds, so 6 breaths a minute.
    @State private var minutes = 1
    @State private var phase: Phase = .ready
    @State private var secondsLeft = 0
    @State private var breathsDone = 0
    @State private var circleScale: CGFloat = 0.55
    /// The running exercise. Keeping it lets us stop it early.
    @State private var breathingTask: Task<Void, Never>?

    // Respect the "Reduce Motion" accessibility setting: no growing circle, just text.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var totalBreaths: Int { minutes * 6 }
    private var isRunning: Bool { breathingTask != nil }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Breathe in through your nose for 4 seconds, then out slowly for 6. A longer breath out tells your body it's safe to slow down.")
                    .font(.body)
                    .foregroundStyle(Color.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)

                breathingCircle

                if phase == .done {
                    Text("Notice how your body feels now. You can do this anytime, anywhere.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                } else if isRunning {
                    Text("Breath \(min(breathsDone + 1, totalBreaths)) of \(totalBreaths)")
                        .font(.headline)
                        .foregroundStyle(Color.inkSoft)
                }

                if !isRunning {
                    Picker("How long", selection: $minutes) {
                        Text("1 min").tag(1)
                        Text("2 min").tag(2)
                        Text("3 min").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Button(isRunning ? "Stop" : (phase == .done ? "Go again" : "Start"),
                       action: isRunning ? stop : start)
                    .buttonStyle(BigButtonStyle())
            }
            .padding(20)
        }
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .valenceScreen()
        // A soft tap each time you switch between breathing in and out.
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: phase)
        // Stop the timer if someone leaves this screen.
        .onDisappear(perform: stop)
    }

    private var breathingCircle: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandSoft)
                Circle()
                    .fill(Color.brand)
                    .scaleEffect(reduceMotion ? 0.75 : circleScale)
                // Only the countdown sits inside the circle, so it always fits even when the circle is small.
                if isRunning && secondsLeft > 0 {
                    Text("\(secondsLeft)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.onBrand)
                        .contentTransition(.numericText())
                }
            }
            .frame(maxWidth: 280)
            .aspectRatio(1, contentMode: .fit)

            Text(phase.instruction)
                .font(.title.bold())
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(phase.instruction)
        .accessibilityValue(isRunning && secondsLeft > 0 ? "\(secondsLeft) seconds" : "")
    }

    private func start() {
        breathsDone = 0
        breathingTask = Task { await runExercise() }
    }

    private func stop() {
        breathingTask?.cancel()
        breathingTask = nil
        if phase != .done {
            phase = .ready
            secondsLeft = 0
            withAnimation(.easeInOut(duration: 0.6)) { circleScale = 0.55 }
        }
    }

    /// Steps through each breath, waiting one second at a time so the countdown updates.
    private func runExercise() async {
        while breathsDone < totalBreaths {
            for next in [Phase.breatheIn, Phase.breatheOut] {
                phase = next
                // VoiceOver users hear each instruction, since they can't see the circle.
                AccessibilityNotification.Announcement(next.instruction).post()
                withAnimation(.easeInOut(duration: Double(next.seconds))) {
                    circleScale = next == .breatheIn ? 1.0 : 0.55
                }
                for second in stride(from: next.seconds, to: 0, by: -1) {
                    secondsLeft = second
                    try? await Task.sleep(for: .seconds(1))
                    if Task.isCancelled { return }
                }
            }
            breathsDone += 1
        }
        phase = .done
        secondsLeft = 0
        breathingTask = nil
        AccessibilityNotification.Announcement("Done. Nice work.").post()
    }
}

#Preview {
    NavigationStack {
        BreathingView()
    }
    .environment(AppState())
}

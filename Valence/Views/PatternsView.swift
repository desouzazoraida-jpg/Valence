import SwiftUI
import SwiftData

/// Charts, environment insights, and past check-ins, powered by PatternEngine.
struct PatternsView: View {
    // @Query asks SwiftData for every CheckIn, newest first,
    // and refreshes the screen automatically when one is added or deleted.
    @Query(sort: \CheckIn.timestamp, order: .reverse) private var checkIns: [CheckIn]
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var isConfirmingDelete = false
    /// Lets someone set the gentle message aside for now.
    @State private var hidShiftMessage = false

    private let engine = PatternEngine()

    var body: some View {
        NavigationStack {
            List {
                if checkIns.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                } else {
                    if showsShiftMessage && !hidShiftMessage {
                        Section {
                            ShiftMessageCard(
                                openSupport: { appState.selectedTab = .support },
                                hide: { withAnimation { hidShiftMessage = true } })
                        }
                        .listRowBackground(Color.brandSoft)
                    }

                    Section {
                        summary
                    }
                    .listRowBackground(Color.card)

                    Section("Last 30 days") {
                        TimelineChart(checkIns: chronological.filter {
                            $0.timestamp > Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .distantPast
                        })
                    }
                    .listRowBackground(Color.card)

                    Section("Your Mood Map") {
                        MoodMapChart(checkIns: checkIns)
                    }
                    .listRowBackground(Color.card)

                    Section("Environments") {
                        ForEach(engine.summarizeByEnvironment(checkIns), id: \.environment) { summary in
                            EnvironmentCard(summary: summary)
                        }
                    }
                    .listRowBackground(Color.card)

                    Section("Recent check-ins") {
                        ForEach(checkIns.prefix(20)) { checkIn in
                            CheckInRow(checkIn: checkIn)
                        }
                        .onDelete(perform: delete)
                    }
                    .listRowBackground(Color.card)
                }

                dataSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Patterns")
            .valenceScreen()
            .alert("Delete all your check-ins?", isPresented: $isConfirmingDelete) {
                Button("Delete All", role: .destructive, action: deleteAll)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes every check-in from this phone. It can't be undone.")
            }
        }
    }

    // MARK: - Pattern engine results

    /// Check-ins oldest → newest (charts read left to right in time).
    private var chronological: [CheckIn] {
        checkIns.reversed()
    }

    /// True when PatternEngine.detectShift spots a recent dip.
    /// The baseline uses every check-in *except* the most recent ones, so a recent
    /// dip doesn't drag "usual" down with it.
    private var showsShiftMessage: Bool {
        guard checkIns.count >= PatternEngine.minimumCheckInsForShift else { return false }
        let earlier = Array(chronological.dropLast(PatternEngine.shiftWindow))
        guard let baseline = engine.computeBaseline(earlier) else { return false }
        return engine.detectShift(checkIns, baseline: baseline)
    }

    /// The word that shows up most often in `values`.
    private func mostCommon(_ values: [String]) -> String? {
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)
        // On a tie, pick the word that comes first A to Z, so the answer doesn't change randomly.
        return counts.max { $0.value != $1.value ? $0.value < $1.value : $0.key > $1.key }?.key
    }

    // MARK: - Sections

    private var summary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(checkIns.count == 1 ? "You've checked in once" : "You've checked in \(checkIns.count) times")
                .font(.headline)
            if let feeling = mostCommon(checkIns.map(\.feeling)) {
                Text("Most common feeling: \(feeling)")
                    .font(.title3.bold())
                    .foregroundStyle(Color.brand)
            }
            let range = engine.emotionalRange(checkIns)
            Text(range == 1 ? "You've named 1 feeling so far." : "You've named \(range) different feelings.")
                .font(.body)
            Text("The more precise words you use, the better you get to know your feelings.")
                .font(.subheadline)
                .foregroundStyle(Color.inkSoft)
        }
        .padding(.vertical, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(Color.brand)
                .accessibilityHidden(true)
            Text("Your patterns will grow here")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Check in a few times to see your charts, or load sample data below to try a demo.")
                .font(.body)
                .foregroundStyle(Color.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 20)
    }

    private var dataSection: some View {
        Section {
            Button(action: loadSampleData) {
                Label("Load sample data", systemImage: "wand.and.stars")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(Color.brand)

            if !checkIns.isEmpty {
                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Label("Delete all my data", systemImage: "trash")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(Color.help)
            }
        } header: {
            Text("Your data")
        } footer: {
            Text("Sample data adds 24 made-up check-ins so you can see how Patterns works. Delete all removes every check-in, real and sample.")
        }
        .listRowBackground(Color.card)
    }

    // MARK: - Actions

    private func loadSampleData() {
        for checkIn in SampleData.makeCheckIns() {
            modelContext.insert(checkIn)
        }
        hidShiftMessage = false
    }

    private func deleteAll() {
        for checkIn in checkIns {
            modelContext.delete(checkIn)
        }
        try? modelContext.save()
    }

    private func delete(at offsets: IndexSet) {
        let shown = Array(checkIns.prefix(20))
        for index in offsets {
            modelContext.delete(shown[index])
        }
    }
}

/// A kind note shown when recent check-ins dip below someone's usual.
private struct ShiftMessageCard: View {
    let openSupport: () -> Void
    let hide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Be gentle with yourself", systemImage: "heart")
                .font(.title3.bold())
                .foregroundStyle(Color.brand)

            Text("Your last few check-ins have felt heavier than usual for you. That's okay — everyone has stretches like this, and noticing it is a real strength.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Text("Taking a slow minute with the 5-4-3-2-1 grounding exercise might help, and so can talking with someone you trust. Both are on the Support tab whenever you want them.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Button("Open calming tools and support", action: openSupport)
                .buttonStyle(BigButtonStyle())

            Button("Not right now", action: hide)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.brand)
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
                .padding(.vertical, 4)
        }
        .padding(.vertical, 8)
    }
}

/// One environment's summary in plain words.
private struct EnvironmentCard: View {
    let summary: EnvironmentSummary

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: summary.setting?.symbol ?? "mappin")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(summary.setting?.color ?? Color.brand, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(summary.environment)
                    .font(.headline)
                Text(summary.sentence)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Text(summary.count == 1 ? "1 check-in" : "\(summary.count) check-ins")
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSoft)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

private struct CheckInRow: View {
    let checkIn: CheckIn

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // A dot in the color of the Mood Map corner this check-in came from.
            Circle()
                .fill(checkIn.quadrant.color)
                .overlay(Circle().strokeBorder(Color.inkSoft.opacity(0.3)))
                .frame(width: 18, height: 18)
                .padding(.top, 4)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(checkIn.timestamp, format: .dateTime.weekday(.wide).month().day().hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSoft)
                Text(checkIn.feeling)
                    .font(.body.weight(.semibold))
                Text("\(checkIn.quadrant.title) · \(checkIn.environment)")
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSoft)
                if !checkIn.note.isEmpty {
                    Text(checkIn.note)
                        .font(.body)
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PatternsView()
        .environment(AppState())
        .modelContainer(for: CheckIn.self, inMemory: true)
}

import Foundation

/// A summary of all the check-ins from one environment (like "School").
struct EnvironmentSummary {
    /// The environment's name, matching CheckIn.environment (for example "School").
    let environment: String
    /// How many check-ins came from this environment.
    let count: Int
    /// The average valence (-1 to 1) of those check-ins.
    let meanValence: Double
    /// The average arousal (-1 to 1) of those check-ins.
    let meanArousal: Double
}

/// Finds patterns in a list of check-ins.
struct PatternEngine {

    /// A baseline is four numbers grouped together (a "tuple"):
    /// the average and standard deviation of valence and of arousal.
    typealias Baseline = (meanValence: Double, sdValence: Double,
                          meanArousal: Double, sdArousal: Double)

    /// How many recent check-ins detectShift looks at.
    static let shiftWindow = 3
    /// detectShift needs at least this many check-ins in total, so the baseline
    /// isn't made up mostly of the recent check-ins it's being compared to.
    static let minimumCheckInsForShift = 6

    /// The person's usual feelings: mean and standard deviation of valence
    /// and arousal across all check-ins. Returns nil when there are no check-ins.
    func computeBaseline(_ checkIns: [CheckIn]) -> Baseline? {
        guard !checkIns.isEmpty else { return nil }

        let valences = checkIns.map(\.valence)
        let arousals = checkIns.map(\.arousal)

        return (meanValence: mean(valences), sdValence: standardDeviation(valences),
                meanArousal: mean(arousals), sdArousal: standardDeviation(arousals))
    }

    /// For each environment: how many check-ins, plus the average valence and arousal.
    /// Sorted with the most-used environment first (ties go A to Z).
    func summarizeByEnvironment(_ checkIns: [CheckIn]) -> [EnvironmentSummary] {
        let groups = Dictionary(grouping: checkIns, by: \.environment)

        let summaries = groups.map { environment, group in
            EnvironmentSummary(environment: environment,
                               count: group.count,
                               meanValence: mean(group.map(\.valence)),
                               meanArousal: mean(group.map(\.arousal)))
        }

        return summaries.sorted {
            $0.count != $1.count ? $0.count > $1.count : $0.environment < $1.environment
        }
    }

    /// Returns true when the 3 most recent check-ins all fall more than
    /// 1 standard deviation below the baseline valence.
    func detectShift(_ checkIns: [CheckIn], baseline: Baseline) -> Bool {
        // Not enough history yet to know what "usual" looks like.
        guard checkIns.count >= Self.minimumCheckInsForShift else { return false }
        // If every valence is the same, nothing can be "below usual".
        guard baseline.sdValence > 0 else { return false }

        let cutoff = baseline.meanValence - baseline.sdValence

        // Sort oldest → newest so suffix() really gives the most recent check-ins,
        // no matter what order they were passed in.
        let recent = checkIns.sorted { $0.timestamp < $1.timestamp }
            .suffix(Self.shiftWindow)

        return recent.allSatisfy { $0.valence < cutoff }
    }

    /// How many different feeling words have been used (a measure of emotional granularity).
    func emotionalRange(_ checkIns: [CheckIn]) -> Int {
        let words = checkIns.map(\.feeling).filter { !$0.isEmpty }
        // A Set drops repeats, so each word counts once.
        return Set(words).count
    }

    // MARK: - Math helpers

    /// The average of some numbers (0 for an empty list).
    private func mean(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    /// Sample standard deviation (divides by n - 1), because check-ins are a
    /// sample of how someone feels over time. Returns 0 with fewer than 2 values.
    private func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let average = mean(values)
        let squaredDifferences = values.map { ($0 - average) * ($0 - average) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count - 1)
        return variance.squareRoot()
    }
}

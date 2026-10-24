import Foundation

/// Made-up check-ins for demos, so the Patterns tab has something to show.
///
/// The story: school tends to feel unpleasant, friends and sports feel good,
/// home feels calm, online is mixed — and the last three check-ins dip lower
/// than usual, so the gentle "shift" message appears.
enum SampleData {
    /// One made-up check-in: how many days ago, what hour, where, the Mood Map spot, and a note.
    private struct Entry {
        let daysAgo: Int
        let hour: Int
        let setting: CheckInSetting
        let valence: Double
        let arousal: Double
        var note = ""
    }

    private static let entries: [Entry] = [
        Entry(daysAgo: 20, hour: 8, setting: .school, valence: -0.4, arousal: 0.5, note: "Quiz in first period"),
        Entry(daysAgo: 20, hour: 19, setting: .home, valence: 0.5, arousal: -0.5),
        Entry(daysAgo: 19, hour: 16, setting: .sports, valence: 0.6, arousal: 0.7, note: "Good practice"),
        Entry(daysAgo: 18, hour: 10, setting: .school, valence: -0.5, arousal: -0.4),
        Entry(daysAgo: 18, hour: 21, setting: .online, valence: 0.1, arousal: 0.3),
        Entry(daysAgo: 17, hour: 17, setting: .friends, valence: 0.7, arousal: 0.6, note: "Movie night"),
        Entry(daysAgo: 16, hour: 9, setting: .school, valence: -0.3, arousal: 0.6),
        Entry(daysAgo: 15, hour: 20, setting: .home, valence: 0.4, arousal: -0.7),
        Entry(daysAgo: 14, hour: 12, setting: .school, valence: -0.6, arousal: -0.5, note: "Too much homework"),
        Entry(daysAgo: 13, hour: 18, setting: .sports, valence: 0.5, arousal: 0.8),
        Entry(daysAgo: 13, hour: 22, setting: .online, valence: -0.3, arousal: 0.4, note: "Group chat drama"),
        Entry(daysAgo: 12, hour: 15, setting: .friends, valence: 0.8, arousal: 0.5),
        Entry(daysAgo: 11, hour: 8, setting: .school, valence: -0.4, arousal: -0.6),
        Entry(daysAgo: 10, hour: 19, setting: .home, valence: 0.6, arousal: -0.4, note: "Family dinner"),
        Entry(daysAgo: 9, hour: 16, setting: .sports, valence: 0.7, arousal: 0.6),
        Entry(daysAgo: 8, hour: 21, setting: .online, valence: 0.2, arousal: -0.3),
        Entry(daysAgo: 7, hour: 13, setting: .school, valence: -0.2, arousal: 0.5),
        Entry(daysAgo: 6, hour: 18, setting: .friends, valence: 0.6, arousal: 0.7),
        Entry(daysAgo: 5, hour: 20, setting: .home, valence: 0.5, arousal: -0.6),
        Entry(daysAgo: 4, hour: 10, setting: .school, valence: -0.5, arousal: 0.4, note: "Presentation"),
        Entry(daysAgo: 3, hour: 17, setting: .sports, valence: 0.4, arousal: 0.5),
        // A recent dip, so the demo shows the gentle shift message.
        Entry(daysAgo: 2, hour: 9, setting: .school, valence: -0.7, arousal: -0.5, note: "Didn't sleep well"),
        Entry(daysAgo: 1, hour: 20, setting: .home, valence: -0.6, arousal: -0.7),
        Entry(daysAgo: 0, hour: 7, setting: .online, valence: -0.6, arousal: -0.4),
    ]

    /// Builds the sample check-ins, with dates counted back from `now`.
    static func makeCheckIns(now: Date = .now) -> [CheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        return entries.map { entry in
            let day = calendar.date(byAdding: .day, value: -entry.daysAgo, to: today) ?? today
            var date = calendar.date(bySettingHour: entry.hour, minute: 15, second: 0, of: day) ?? day
            // Never put a sample check-in in the future.
            date = min(date, now.addingTimeInterval(-60))

            // Use the feeling word that sits closest to this spot on the Mood Map.
            let point = MoodPoint(valence: entry.valence, arousal: entry.arousal)
            let word = point.quadrant.suggestedWords(near: point, count: 1).first?.word ?? ""

            return CheckIn(timestamp: date,
                           valence: entry.valence,
                           arousal: entry.arousal,
                           feeling: word,
                           environment: entry.setting,
                           note: entry.note)
        }
    }
}

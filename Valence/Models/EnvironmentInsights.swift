import SwiftUI

// Turns the pattern engine's numbers into plain, friendly words and colors.

extension CheckInSetting {
    /// A color for this environment on the Patterns charts.
    /// Each one is different enough to tell apart, and the charts also use a
    /// different dot shape per environment, so color is never the only clue.
    var color: Color {
        switch self {
        case .school: return Color(light: 0x5B47A8, dark: 0xB7A8FF)   // purple
        case .home: return Color(light: 0x2D6E73, dark: 0x7FD0CB)     // teal
        case .sports: return Color(light: 0xA6561A, dark: 0xF2A766)   // amber
        case .friends: return Color(light: 0xB83A64, dark: 0xF59BB8)  // rose
        case .online: return Color(light: 0x2F64A0, dark: 0x8DB8F0)   // blue
        }
    }

    /// How a sentence about this environment begins.
    var sentenceStart: String {
        switch self {
        case .school: return "At school"
        case .home: return "At home"
        case .sports: return "During sports and activities"
        case .friends: return "With friends"
        case .online: return "When you're online"
        }
    }
}

extension EnvironmentSummary {
    /// The matching CheckInSetting, if the saved text is one we know.
    var setting: CheckInSetting? {
        CheckInSetting(rawValue: environment)
    }

    /// A plain-language sentence like "At school you tend to feel uneasy and stretched thin."
    var sentence: String {
        let start = setting?.sentenceStart ?? "In \(environment)"
        let feeling = Self.feelingPhrase(valence: meanValence, arousal: meanArousal)
        // With only one or two check-ins, it's too early to call it a "tendency".
        if count < 3 {
            return "\(start) you've felt \(feeling) so far."
        }
        return "\(start) you tend to feel \(feeling)."
    }

    /// Describes an average spot on the Mood Map in everyday words.
    static func feelingPhrase(valence: Double, arousal: Double) -> String {
        let pleasant = valence > 0.2
        let unpleasant = valence < -0.2
        let high = arousal > 0.2
        let low = arousal < -0.2

        switch (unpleasant, pleasant, low, high) {
        case (_, true, _, true): return "upbeat and energized"
        case (_, true, true, _): return "calm and content"
        case (_, true, _, _): return "happy and settled"
        case (true, _, _, true): return "tense and on edge"
        case (true, _, true, _): return "down and drained"
        case (true, _, _, _): return "uneasy and stretched thin"
        case (_, _, _, true): return "busy but okay"
        case (_, _, true, _): return "quiet and low-key"
        default: return "fairly balanced"
        }
    }
}

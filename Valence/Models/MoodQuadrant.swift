import SwiftUI

/// A spot on the Mood Map. Both numbers go from -1 to 1.
struct MoodPoint: Equatable {
    var valence: Double
    var arousal: Double

    /// Keeps a number inside -1...1 so the spot never leaves the map.
    static func clamp(_ value: Double) -> Double {
        min(max(value, -1), 1)
    }

    init(valence: Double, arousal: Double) {
        self.valence = MoodPoint.clamp(valence)
        self.arousal = MoodPoint.clamp(arousal)
    }

    var quadrant: MoodQuadrant {
        MoodQuadrant(valence: valence, arousal: arousal)
    }

    /// A spoken description for VoiceOver, like "pleasant, a little high energy".
    var spokenDescription: String {
        "\(Self.describe(valence, low: "unpleasant", middle: "neutral", high: "pleasant")), "
            + Self.describe(arousal, low: "low energy", middle: "medium energy", high: "high energy")
    }

    private static func describe(_ value: Double, low: String, middle: String, high: String) -> String {
        switch value {
        case ..<(-0.66): return "very \(low)"
        case ..<(-0.33): return low
        case ..<(-0.1): return "a little \(low)"
        case ...0.1: return middle
        case ...0.33: return "a little \(high)"
        case ...0.66: return high
        default: return "very \(high)"
        }
    }
}

/// A feeling word, with the spot on the Mood Map where it usually sits.
struct FeelingWord: Identifiable, Hashable {
    let word: String
    let meaning: String
    let valence: Double
    let arousal: Double
    var id: String { word }

    func distance(to point: MoodPoint) -> Double {
        let dx = valence - point.valence
        let dy = arousal - point.arousal
        return (dx * dx + dy * dy).squareRoot()
    }
}

/// The four corners of the Mood Map.
enum MoodQuadrant: CaseIterable {
    case pleasantHigh, unpleasantHigh, unpleasantLow, pleasantLow

    init(valence: Double, arousal: Double) {
        switch (valence >= 0, arousal >= 0) {
        case (true, true): self = .pleasantHigh
        case (false, true): self = .unpleasantHigh
        case (false, false): self = .unpleasantLow
        case (true, false): self = .pleasantLow
        }
    }

    var title: String {
        switch self {
        case .pleasantHigh: return "Pleasant, high energy"
        case .unpleasantHigh: return "Unpleasant, high energy"
        case .unpleasantLow: return "Unpleasant, low energy"
        case .pleasantLow: return "Pleasant, low energy"
        }
    }

    var color: Color {
        switch self {
        case .pleasantHigh: return .quadrantPleasantHigh
        case .unpleasantHigh: return .quadrantUnpleasantHigh
        case .unpleasantLow: return .quadrantUnpleasantLow
        case .pleasantLow: return .quadrantPleasantLow
        }
    }

    /// The 8 words in this quadrant that sit closest to the spot.
    /// They stay in the list's original order so they don't jump around while dragging.
    func suggestedWords(near point: MoodPoint, count: Int = 8) -> [FeelingWord] {
        let closest = words.sorted { $0.distance(to: point) < $1.distance(to: point) }.prefix(count)
        return words.filter { closest.contains($0) }
    }

    var words: [FeelingWord] {
        switch self {
        case .pleasantHigh:
            return [
                FeelingWord(word: "Excited", meaning: "Buzzing about something good that's coming.", valence: 0.55, arousal: 0.85),
                FeelingWord(word: "Joyful", meaning: "Full of happiness that's hard to hide.", valence: 0.85, arousal: 0.6),
                FeelingWord(word: "Inspired", meaning: "Full of ideas and wanting to create something.", valence: 0.6, arousal: 0.65),
                FeelingWord(word: "Playful", meaning: "Lighthearted and ready to have fun.", valence: 0.45, arousal: 0.75),
                FeelingWord(word: "Proud", meaning: "Good about something you did or who you are.", valence: 0.75, arousal: 0.35),
                FeelingWord(word: "Confident", meaning: "Sure you can handle what's in front of you.", valence: 0.55, arousal: 0.3),
                FeelingWord(word: "Amused", meaning: "Finding something funny.", valence: 0.4, arousal: 0.5),
                FeelingWord(word: "Hopeful", meaning: "Expecting that things can get better.", valence: 0.35, arousal: 0.2),
                FeelingWord(word: "Thrilled", meaning: "So happy and excited it's hard to sit still.", valence: 0.8, arousal: 0.9),
                FeelingWord(word: "Energized", meaning: "Full of energy and ready to go.", valence: 0.35, arousal: 0.9),
                FeelingWord(word: "Motivated", meaning: "Wanting to get started and work toward something.", valence: 0.45, arousal: 0.55),
                FeelingWord(word: "Curious", meaning: "Interested and wanting to find out more.", valence: 0.2, arousal: 0.45),
                FeelingWord(word: "Loved", meaning: "Cared about by people who matter to you.", valence: 0.85, arousal: 0.15),
                FeelingWord(word: "Included", meaning: "Part of the group and glad to be there.", valence: 0.6, arousal: 0.15),
            ]
        case .unpleasantHigh:
            return [
                FeelingWord(word: "Angry", meaning: "Strongly upset about something that feels wrong or unfair.", valence: -0.8, arousal: 0.85),
                FeelingWord(word: "Overwhelmed", meaning: "Like there's too much to handle at once.", valence: -0.6, arousal: 0.8),
                FeelingWord(word: "Anxious", meaning: "Worried about what might happen.", valence: -0.55, arousal: 0.65),
                FeelingWord(word: "Stressed", meaning: "Under pressure from too many demands.", valence: -0.5, arousal: 0.55),
                FeelingWord(word: "Frustrated", meaning: "Blocked from something you're trying to do.", valence: -0.7, arousal: 0.45),
                FeelingWord(word: "Irritated", meaning: "Annoyed by small things that keep bugging you.", valence: -0.4, arousal: 0.35),
                FeelingWord(word: "Nervous", meaning: "Jittery about something coming up.", valence: -0.3, arousal: 0.6),
                FeelingWord(word: "Embarrassed", meaning: "Wishing others hadn't seen or heard something.", valence: -0.55, arousal: 0.3),
                FeelingWord(word: "Panicked", meaning: "Suddenly so scared it's hard to think.", valence: -0.75, arousal: 0.95),
                FeelingWord(word: "Scared", meaning: "Afraid something bad might happen.", valence: -0.7, arousal: 0.7),
                FeelingWord(word: "Jealous", meaning: "Wanting what someone else has.", valence: -0.5, arousal: 0.45),
                FeelingWord(word: "Restless", meaning: "Unable to settle down or stay still.", valence: -0.15, arousal: 0.6),
                FeelingWord(word: "Insecure", meaning: "Unsure if you're good enough.", valence: -0.4, arousal: 0.2),
                FeelingWord(word: "Confused", meaning: "Not sure what's going on or what to do.", valence: -0.2, arousal: 0.25),
            ]
        case .unpleasantLow:
            return [
                FeelingWord(word: "Sad", meaning: "Heavy-hearted about something you've lost or miss.", valence: -0.7, arousal: -0.35),
                FeelingWord(word: "Lonely", meaning: "Wanting more connection with other people.", valence: -0.6, arousal: -0.45),
                FeelingWord(word: "Left out", meaning: "Hurt at not being included.", valence: -0.65, arousal: -0.15),
                FeelingWord(word: "Disappointed", meaning: "Let down because something didn't go as hoped.", valence: -0.45, arousal: -0.2),
                FeelingWord(word: "Discouraged", meaning: "Losing motivation after setbacks.", valence: -0.55, arousal: -0.55),
                FeelingWord(word: "Exhausted", meaning: "Completely out of energy.", valence: -0.4, arousal: -0.85),
                FeelingWord(word: "Numb", meaning: "Not feeling much of anything.", valence: -0.3, arousal: -0.7),
                FeelingWord(word: "Bored", meaning: "Uninterested in what's around you.", valence: -0.2, arousal: -0.5),
                FeelingWord(word: "Hurt", meaning: "Stung by something someone said or did.", valence: -0.75, arousal: -0.2),
                FeelingWord(word: "Ignored", meaning: "Like no one is noticing or listening to you.", valence: -0.55, arousal: -0.3),
                FeelingWord(word: "Guilty", meaning: "Feeling bad about something you did.", valence: -0.5, arousal: -0.1),
                FeelingWord(word: "Hopeless", meaning: "Like things won't get better.", valence: -0.85, arousal: -0.65),
                FeelingWord(word: "Unmotivated", meaning: "Not wanting to start anything.", valence: -0.3, arousal: -0.35),
                FeelingWord(word: "Tired", meaning: "Low on energy and wanting rest.", valence: -0.15, arousal: -0.75),
            ]
        case .pleasantLow:
            return [
                FeelingWord(word: "Content", meaning: "Satisfied with how things are right now.", valence: 0.6, arousal: -0.25),
                FeelingWord(word: "Grateful", meaning: "Thankful for someone or something.", valence: 0.75, arousal: -0.15),
                FeelingWord(word: "Relieved", meaning: "Glad that something stressful is over.", valence: 0.45, arousal: -0.3),
                FeelingWord(word: "Calm", meaning: "Steady and untroubled.", valence: 0.4, arousal: -0.55),
                FeelingWord(word: "Relaxed", meaning: "Loose and free of tension.", valence: 0.6, arousal: -0.6),
                FeelingWord(word: "Peaceful", meaning: "Quiet and settled inside.", valence: 0.55, arousal: -0.8),
                FeelingWord(word: "Safe", meaning: "Protected and secure where you are.", valence: 0.3, arousal: -0.35),
                FeelingWord(word: "Restful", meaning: "Pleasantly sleepy and ready to recharge.", valence: 0.25, arousal: -0.85),
                FeelingWord(word: "Cozy", meaning: "Warm, comfortable, and snug.", valence: 0.65, arousal: -0.45),
                FeelingWord(word: "Understood", meaning: "Like someone really gets you.", valence: 0.7, arousal: -0.05),
                FeelingWord(word: "Thoughtful", meaning: "Quietly thinking things over.", valence: 0.2, arousal: -0.2),
                FeelingWord(word: "Balanced", meaning: "Steady, with things feeling in place.", valence: 0.35, arousal: -0.1),
                FeelingWord(word: "Chill", meaning: "Easygoing and not worried about much.", valence: 0.4, arousal: -0.7),
                FeelingWord(word: "Mellow", meaning: "Slow, quiet, and a little low-key.", valence: 0.15, arousal: -0.6),
            ]
        }
    }
}

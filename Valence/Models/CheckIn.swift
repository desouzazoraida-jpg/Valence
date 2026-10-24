import Foundation
import SwiftData

/// One mood check-in. The @Model macro tells SwiftData to save these
/// on the device automatically, like rows in a tiny database.
///
/// Every property has a starting value (like `= 0`). That helps SwiftData
/// upgrade older saved data when we add new properties later.
@Model
final class CheckIn {
    /// When the check-in happened.
    var timestamp: Date = Date.now
    /// How pleasant the feeling is: -1 (very unpleasant) to 1 (very pleasant).
    /// Psychologists call this "valence" — that's where the app's name comes from!
    var valence: Double = 0
    /// How much energy comes with the feeling: -1 (very low) to 1 (very high).
    /// Psychologists call this "arousal".
    var arousal: Double = 0
    /// The feeling word that was picked, like "Calm" or "Frustrated".
    var feeling: String = ""
    /// Where the person was, saved as text like "School" (see CheckInSetting).
    var environment: String = ""
    /// An optional one-line note.
    var note: String = ""

    init(timestamp: Date = .now,
         valence: Double,
         arousal: Double,
         feeling: String,
         environment: CheckInSetting,
         note: String = "") {
        self.timestamp = timestamp
        self.valence = valence
        self.arousal = arousal
        self.feeling = feeling
        self.environment = environment.rawValue
        self.note = note
    }

    /// Turns the saved text back into a CheckInSetting.
    var setting: CheckInSetting? {
        CheckInSetting(rawValue: environment)
    }

    /// Which part of the Mood Map this check-in is in.
    var quadrant: MoodQuadrant {
        MoodQuadrant(valence: valence, arousal: arousal)
    }
}

/// Where someone is when they check in.
/// (We call the type "setting" because SwiftUI already uses the word `Environment`.)
enum CheckInSetting: String, CaseIterable, Identifiable {
    case school = "School"
    case home = "Home"
    case sports = "Sports and Activities"
    case friends = "Friends"
    case online = "Online"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .school: return "backpack"
        case .home: return "house"
        case .sports: return "figure.run"
        case .friends: return "person.2"
        case .online: return "iphone"
        }
    }
}

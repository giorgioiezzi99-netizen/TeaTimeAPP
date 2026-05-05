import ActivityKit
import Foundation

struct TeaTimerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var teaName: String
        var teaType: String
        var endDate: Date
        var timerState: String
        var brewingLabel: String
        var brewingMessage: String
        var remainingLabel: String
    }

    var timerId: String
}

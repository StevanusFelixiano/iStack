//
//  Session.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

@Model
final class Session {

    @Attribute(.unique)
    var id: UUID

    var startTime: Date
    var endTime: Date?

    // NEW
    var pausedAt: Date?
    var totalPausedDuration: TimeInterval

    var averageRestingHR: Int
    var category: Category

    @Relationship(deleteRule: .cascade)
    var heartRates: [HeartRate] = []

    @Relationship(deleteRule: .cascade)
    var tenseEvents: [TenseEvent] = []

    init(
        category: Category,
        startTime: Date,
        endTime: Date? = nil,
        pausedAt: Date? = nil,
        totalPausedDuration: TimeInterval = 0,
        averageRestingHR: Int
    ) {
        self.id = UUID()

        self.category = category

        self.startTime = startTime
        self.endTime = endTime

        self.pausedAt = pausedAt
        self.totalPausedDuration = totalPausedDuration

        self.averageRestingHR = averageRestingHR
    }
}

extension Session {

    /// Falls back to "now" for a session that hasn't ended yet.
    var displayEndTime: Date {
        endTime ?? .now
    }

    /// Total duration including pause time.
    var elapsedTime: TimeInterval {
        displayEndTime.timeIntervalSince(startTime)
    }

    /// Total recovery duration.
    var totalRecoveryDuration: TimeInterval {

        tenseEvents.reduce(0) { partial, event in

            guard
                let start = event.recoveryStartedAt,
                let end = event.recoveryEndedAt
            else {
                return partial
            }

            return partial + end.timeIntervalSince(start)
        }
    }

    /// Duration excluding pause.
    var activeDuration: TimeInterval {

        max(
            elapsedTime - totalPausedDuration,
            0
        )
    }

    /// Active duration excluding recovery.
    var activityTime: TimeInterval {

        max(
            activeDuration - totalRecoveryDuration,
            0
        )
    }

    var allPunches: [Punch] {

        tenseEvents.flatMap(\.punchData)
    }

    var punchCount: Int {

        allPunches.count
    }

    var sortedHeartRates: [HeartRate] {

        heartRates.sorted {
            $0.timestamp < $1.timestamp
        }
    }
}

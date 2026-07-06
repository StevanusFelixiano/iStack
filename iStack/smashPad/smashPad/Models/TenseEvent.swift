//
//  TenseEvent.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

@Model
final class TenseEvent {

    @Attribute(.unique)
    var id: UUID

    var startingHeartRate: Int
    var detectedAt: Date
    var recoveryStartedAt: Date?
    var recoveryEndedAt: Date?

    var session: Session?

    @Relationship(deleteRule: .cascade)
    var punchData: [Punch] = []

    init(
        startingHeartRate: Int,
        detectedAt: Date = .now,
        recoveryStartedAt: Date? = nil,
        recoveryEndedAt: Date? = nil,
        session: Session? = nil
    ) {
        self.id = UUID()
        self.startingHeartRate = startingHeartRate
        self.detectedAt = detectedAt
        self.recoveryStartedAt = recoveryStartedAt
        self.recoveryEndedAt = recoveryEndedAt
        self.session = session
    }
}

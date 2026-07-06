//
//  HeartRate.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

@Model
final class HeartRate {

    @Attribute(.unique)
    var id: UUID

    var heartRateBPM: Int
    var timestamp: Date

    var session: Session?

    init(
        heartRateBPM: Int,
        timestamp: Date = .now,
        session: Session? = nil
    ) {
        self.id = UUID()
        self.heartRateBPM = heartRateBPM
        self.timestamp = timestamp
        self.session = session
    }
}

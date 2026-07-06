//
//  Punch.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

@Model
final class Punch{

    @Attribute(.unique)
    var id: UUID

    var punchIntensity: Float?
    var timestamp: Date

    var tenseEvent: TenseEvent?

    init(
        punchIntensity: Float? = nil,
        timestamp: Date = .now,
        tenseEvent: TenseEvent? = nil
    ) {
        self.id = UUID()
        self.punchIntensity = punchIntensity
        self.timestamp = timestamp
        self.tenseEvent = tenseEvent
    }
}

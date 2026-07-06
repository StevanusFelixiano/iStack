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
        averageRestingHR: Int
    ) {
        self.id = UUID()
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.averageRestingHR = averageRestingHR
    }
}

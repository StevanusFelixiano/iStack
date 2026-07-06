//
//  Activity.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

@Model
final class Category {

    @Attribute(.unique)
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade)
    var sessions: [Session] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

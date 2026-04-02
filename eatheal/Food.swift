//
//  Food.swift
//  eatheal
//

import Foundation
import SwiftUI

struct Food: Identifiable, Hashable {
    let id: UUID
    var name: String
    var systems: [HealthDefenseSystem]
    var description: String
    var tags: [String]
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        systems: [HealthDefenseSystem],
        description: String,
        tags: [String],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.systems = systems
        self.description = description
        self.tags = tags
        self.isFavorite = isFavorite
    }
    
    var iconName: String {
        systems.first?.iconName ?? "leaf.fill"
    }
    
    var color: Color {
        systems.first?.color ?? .green
    }
}

extension Food {
    /// 稳定 ID，便于预览与本地持久化引用
    static func stable(_ suffix: String) -> UUID {
        UUID(uuidString: "00000000-0000-0000-0000-\(suffix.padding(toLength: 12, withPad: "0", startingAt: 0))")!
    }

    static let sampleData: [Food] = Food.newSampleData
}

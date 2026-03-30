//
//  WeekPlan.swift
//  eatheal
//

import Foundation

struct WeekPlan: Identifiable {
    let id: UUID
    var startDate: Date
    var days: [DayPlan]

    func coverageCount(for system: HealthDefenseSystem) -> Int {
        days.filter { $0.coveredSystems.contains(system) }.count
    }
}

extension Calendar {
    /// 包含 `date` 的那一周，以「周一」为起点（与 PRD 周矩阵一致）
    func mondayStartOfWeek(containing date: Date) -> Date {
        let day = startOfDay(for: date)
        let weekDay = component(.weekday, from: day)
        let daysSinceMonday = (weekDay + 5) % 7
        return self.date(byAdding: .day, value: -daysSinceMonday, to: day)!
    }
}

enum WeekPlanFactory {
    static func makeWeek(startingAt reference: Date, calendar: Calendar = .current) -> WeekPlan {
        let monday = calendar.mondayStartOfWeek(containing: reference)
        let days: [DayPlan] = (0..<7).map { offset in
            let d = calendar.date(byAdding: .day, value: offset, to: monday)!
            return DayPlan(id: UUID(), date: d, selectedFoods: [], forcedCoverageSystems: [:])
        }
        return WeekPlan(id: UUID(), startDate: monday, days: days)
    }
}

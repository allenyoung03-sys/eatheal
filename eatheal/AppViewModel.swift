//
//  AppViewModel.swift
//  eatheal
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var currentWeek: WeekPlan
    @Published private(set) var allFoods: [Food]

    @AppStorage("favoriteFoodIds") private var favoriteIdsRaw: String = ""

    private let calendar = Calendar.current

    init() {
        // 初始化阶段不能读 @AppStorage，需直接读 UserDefaults（键与 favoriteFoodIds 一致）
        let storedFavorites = UserDefaults.standard.string(forKey: "favoriteFoodIds") ?? ""
        let favSet = Self.parseFavoriteIds(storedFavorites)
        self.allFoods = Food.sampleData.map { f in
            var x = f
            x.isFavorite = favSet.contains(f.id)
            return x
        }
        self.currentWeek = WeekPlanFactory.makeWeek(startingAt: Date())
    }

    /// 若今天已不在当前周区间内，则滚动到新的一周（本地原型）
    func rollWeekIfNeeded() {
        let today = calendar.startOfDay(for: Date())
        guard let first = currentWeek.days.first, let last = currentWeek.days.last else { return }
        let start = calendar.startOfDay(for: first.date)
        let end = calendar.startOfDay(for: last.date)
        if today >= start, today <= end { return }
        currentWeek = WeekPlanFactory.makeWeek(startingAt: Date())
    }

    private static func parseFavoriteIds(_ raw: String) -> Set<UUID> {
        let parts = raw.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        return Set(parts)
    }

    private func persistFavorites() {
        favoriteIdsRaw = allFoods.filter(\.isFavorite).map(\.id.uuidString).joined(separator: ",")
    }

    func todayPlan() -> DayPlan {
        dayPlan(for: Date())
    }

    func dayPlan(for date: Date) -> DayPlan {
        let day = calendar.startOfDay(for: date)
        if let existing = currentWeek.days.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
            return existing
        }
        return DayPlan(id: UUID(), date: day, selectedFoods: [], forcedCoverageSystems: [:])
    }

    func dayIndex(for date: Date) -> Int? {
        let day = calendar.startOfDay(for: date)
        return currentWeek.days.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: day) })
    }

    func add(food: Food, to date: Date, forcedSystem: HealthDefenseSystem? = nil) {
        guard let idx = dayIndex(for: date) else { return }
        var day = currentWeek.days[idx]
        if day.selectedFoods.contains(where: { $0.id == food.id }) { return }
        var added = food
        if let global = allFoods.first(where: { $0.id == food.id }) {
            added.isFavorite = global.isFavorite
        }
        day.selectedFoods.append(added)
        if let forcedSystem {
            day.forcedCoverageSystems[added.id] = forcedSystem
        }
        currentWeek.days[idx] = day
    }

    func remove(food: Food, from date: Date) {
        guard let idx = dayIndex(for: date) else { return }
        var day = currentWeek.days[idx]
        day.selectedFoods.removeAll { $0.id == food.id }
        day.forcedCoverageSystems.removeValue(forKey: food.id)
        currentWeek.days[idx] = day
    }

    func toggleFavorite(for food: Food) {
        guard let idx = allFoods.firstIndex(where: { $0.id == food.id }) else { return }
        allFoods[idx].isFavorite.toggle()
        persistFavorites()
        for i in currentWeek.days.indices {
            for j in currentWeek.days[i].selectedFoods.indices where currentWeek.days[i].selectedFoods[j].id == food.id {
                currentWeek.days[i].selectedFoods[j].isFavorite = allFoods[idx].isFavorite
            }
        }
    }

    func weeklyCoverage(for system: HealthDefenseSystem) -> Int {
        currentWeek.coverageCount(for: system)
    }

    func favoriteFoods() -> [Food] {
        allFoods.filter(\.isFavorite)
    }

    func food(by id: UUID) -> Food? {
        allFoods.first(where: { $0.id == id })
    }

    func isFoodScheduled(_ food: Food, on date: Date) -> Bool {
        dayPlan(for: date).selectedFoods.contains { $0.id == food.id }
    }
}

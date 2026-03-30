//
//  DayPlan.swift
//  eatheal
//

import Foundation

struct DayPlan: Identifiable {
    let id: UUID
    var date: Date
    var selectedFoods: [Food]
    /// 记录某个食物在今日仅计入一个防御系统（用于「锁定系统添加」防呆）
    var forcedCoverageSystems: [UUID: HealthDefenseSystem] = [:]
    /// 记录用户实际摄入的食物ID
    var consumedFoodIds: Set<UUID> = []

    var coveredSystems: Set<HealthDefenseSystem> {
        Set(selectedFoods.flatMap { food in
            if let forced = forcedCoverageSystems[food.id] {
                return [forced]
            }
            return food.systems
        })
    }

    /// 基于实际摄入的食物计算覆盖的系统
    var actuallyCoveredSystems: Set<HealthDefenseSystem> {
        Set(selectedFoods.filter { consumedFoodIds.contains($0.id) }.flatMap { food in
            if let forced = forcedCoverageSystems[food.id] {
                return [forced]
            }
            return food.systems
        })
    }

    var isFullyCovered: Bool {
        Set(HealthDefenseSystem.allCases).isSubset(of: coveredSystems)
    }

    /// 尚未覆盖的系统（用于「行动提示」）
    var missingSystems: [HealthDefenseSystem] {
        HealthDefenseSystem.allCases.filter { !coveredSystems.contains($0) }
    }
}

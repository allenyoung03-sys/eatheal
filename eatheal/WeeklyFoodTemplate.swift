//
//  WeeklyFoodTemplate.swift
//  eatheal
//

import Foundation

/// 每周食物模板
struct WeeklyFoodTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdAt: Date
    var description: String?
    
    // 模板包含7天的食物安排（周一至周日）
    var dailyFoods: [DayTemplate]
    
    // 模板统计信息
    var totalFoods: Int {
        dailyFoods.reduce(0) { $0 + $1.foodIds.count }
    }
    
    init(id: UUID = UUID(), name: String, description: String? = nil, dailyFoods: [DayTemplate]) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.description = description
        self.dailyFoods = dailyFoods
    }
    
    init(from currentWeek: WeekPlan, name: String, description: String? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.description = description
        
        // 从当前周计划创建模板
        self.dailyFoods = currentWeek.days.enumerated().map { index, day in
            DayTemplate(
                dayOfWeek: index + 1, // 1=周一, 2=周二, ..., 7=周日
                foodIds: day.selectedFoods.map { $0.id },
                forcedCoverageSystems: day.forcedCoverageSystems
            )
        }
    }
}

/// 每日模板
struct DayTemplate: Codable, Identifiable {
    var dayOfWeek: Int  // 1=周一, 2=周二, ..., 7=周日
    var foodIds: [UUID]  // 该天的食物ID列表
    var forcedCoverageSystems: [UUID: HealthDefenseSystem] = [:]  // 强制系统覆盖
    
    // 为 Identifiable 协议提供 id
    var id: Int { dayOfWeek }
    
    init(dayOfWeek: Int, foodIds: [UUID] = [], forcedCoverageSystems: [UUID: HealthDefenseSystem] = [:]) {
        self.dayOfWeek = dayOfWeek
        self.foodIds = foodIds
        self.forcedCoverageSystems = forcedCoverageSystems
    }
}

// MARK: - 模板管理扩展
extension WeeklyFoodTemplate {
    /// 获取模板的覆盖系统（需要外部提供食物详情）
    func coveredSystems(with foods: [Food]) -> Set<HealthDefenseSystem> {
        var allSystems = Set<HealthDefenseSystem>()
        
        for dayTemplate in dailyFoods {
            for foodId in dayTemplate.foodIds {
                if let food = foods.first(where: { $0.id == foodId }) {
                    if let forcedSystem = dayTemplate.forcedCoverageSystems[foodId] {
                        allSystems.insert(forcedSystem)
                    } else {
                        allSystems.formUnion(food.systems)
                    }
                }
            }
        }
        
        return allSystems
    }
    
    /// 获取模板的简要描述
    var shortDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let dateStr = dateFormatter.string(from: createdAt)
        return "\(totalFoods) 种食物 · 创建于 \(dateStr)"
    }
}

// MARK: - 模板存储管理
struct TemplateStorage {
    static let templatesKey = "weeklyFoodTemplates"
    
    static func saveTemplates(_ templates: [WeeklyFoodTemplate]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(templates)
            UserDefaults.standard.set(data, forKey: templatesKey)
        } catch {
            print("Failed to save templates: \(error)")
        }
    }
    
    static func loadTemplates() -> [WeeklyFoodTemplate] {
        guard let data = UserDefaults.standard.data(forKey: templatesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([WeeklyFoodTemplate].self, from: data)
        } catch {
            print("Failed to load templates: \(error)")
            return []
        }
    }
    
    static func deleteTemplate(_ id: UUID) {
        var templates = loadTemplates()
        templates.removeAll { $0.id == id }
        saveTemplates(templates)
    }
}

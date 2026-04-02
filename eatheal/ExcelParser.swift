//
//  ExcelParser.swift
//  eatheal
//
//  用于解析Excel食物数据并生成Food数组
//

import Foundation

struct ExcelParser {
    
    /// 从Excel文本内容解析食物数据
    /// - Parameter excelContent: Excel文件的文本内容
    /// - Returns: 解析出的Food数组
    static func parseExcelContent(_ excelContent: String) -> [Food] {
        var foods: [Food] = []
        var foodIdCounter = 1
        
        // 按行分割Excel内容
        let lines = excelContent.components(separatedBy: .newlines)
        
        // 防御系统映射（基于Excel列顺序）
        let defenseSystems: [HealthDefenseSystem] = [.angiogenesis, .regeneration, .microbiome, .dnaProtection, .immunity]
        
        // 从第2行开始解析（跳过标题行）
        for line in lines.dropFirst() {
            let columns = parseExcelLine(line)
            
            // 确保至少有6列（分类 + 5个防御系统）
            guard columns.count >= 6 else { continue }
            
            let category = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 如果分类为空，跳过
            if category.isEmpty { continue }
            
            // 检查每个防御系统列（列1-5对应防御系统）
            for systemIndex in 0..<5 {
                let foodName = columns[systemIndex + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 如果单元格不为空，则创建一个食物
                if !foodName.isEmpty && foodName != " " {
                    let system = defenseSystems[systemIndex]
                    
                    // 检查是否已存在同名食物
                    if let existingIndex = foods.firstIndex(where: { $0.name == foodName }) {
                        // 如果已存在，添加防御系统（如果尚未包含）
                        if !foods[existingIndex].systems.contains(system) {
                            foods[existingIndex].systems.append(system)
                        }
                    } else {
                        // 创建新食物
                        let tags = [category]
                        let description = generateDescription(for: foodName, systems: [system], category: category)
                        
                        let food = Food(
                            id: Food.stable(String(format: "%012d", foodIdCounter)),
                            name: foodName,
                            systems: [system],
                            description: description,
                            tags: tags
                        )
                        
                        foods.append(food)
                        foodIdCounter += 1
                    }
                }
            }
        }
        
        // 按名称排序
        return foods.sorted { $0.name < $1.name }
    }
    
    /// 解析Excel行（简化版本，假设列由制表符分隔）
    private static func parseExcelLine(_ line: String) -> [String] {
        // Excel数据可能使用制表符分隔
        return line.components(separatedBy: "\t")
    }
    
    /// 为食物生成描述
    private static func generateDescription(for foodName: String, systems: [HealthDefenseSystem], category: String) -> String {
        let systemNames = systems.map { $0.displayName }.joined(separator: "、")
        return "\(foodName)属于\(category)类，对\(systemNames)等防御系统有积极作用。"
    }
}

// 测试代码
extension ExcelParser {
    static func testParse() {
        let testContent = """
        分类	血管生成	再生	微生物组	DNA保护	免疫
        水果	蓝莓	蓝莓		蓝莓
        蔬菜	西兰花		西兰花	西兰花	西兰花
        """
        
        let foods = parseExcelContent(testContent)
        print("解析到 \(foods.count) 种食物:")
        for food in foods {
            print("  - \(food.name): \(food.systems.map { $0.displayName }.joined(separator: ", "))")
        }
    }
}

//
//  TemplateManagementTests.swift
//  eatheal
//

import XCTest
@testable import eatheal

final class TemplateManagementTests: XCTestCase {
    var viewModel: AppViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AppViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testCreateTemplate() {
        // 创建一个测试模板
        let template = WeeklyFoodTemplate(
            name: "测试模板",
            description: "这是一个测试模板",
            mondayFoods: [UUID()],
            tuesdayFoods: [UUID()],
            wednesdayFoods: [UUID()],
            thursdayFoods: [UUID()],
            fridayFoods: [UUID()],
            saturdayFoods: [UUID()],
            sundayFoods: [UUID()]
        )
        
        // 保存模板
        viewModel.saveTemplate(template)
        
        // 加载模板并验证
        let templates = viewModel.loadTemplates()
        XCTAssertTrue(templates.contains(where: { $0.id == template.id }), "模板应该被保存")
        XCTAssertEqual(templates.first?.name, "测试模板", "模板名称应该匹配")
    }
    
    func testApplyTemplate() {
        // 创建一个测试模板
        let foodId = UUID()
        let template = WeeklyFoodTemplate(
            name: "应用测试模板",
            description: "测试应用功能",
            mondayFoods: [foodId],
            tuesdayFoods: [],
            wednesdayFoods: [],
            thursdayFoods: [],
            fridayFoods: [],
            saturdayFoods: [],
            sundayFoods: []
        )
        
        // 保存模板
        viewModel.saveTemplate(template)
        
        // 应用模板
        viewModel.applyTemplate(template)
        
        // 验证周计划是否被更新
        let weekPlan = viewModel.weekPlan
        XCTAssertEqual(weekPlan.mondayFoods.count, 1, "周一应该有1种食物")
        XCTAssertEqual(weekPlan.mondayFoods.first, foodId, "食物ID应该匹配")
    }
    
    func testDeleteTemplate() {
        // 创建一个测试模板
        let template = WeeklyFoodTemplate(
            name: "删除测试模板",
            description: "测试删除功能",
            mondayFoods: [],
            tuesdayFoods: [],
            wednesdayFoods: [],
            thursdayFoods: [],
            fridayFoods: [],
            saturdayFoods: [],
            sundayFoods: []
        )
        
        // 保存模板
        viewModel.saveTemplate(template)
        
        // 验证模板已保存
        var templates = viewModel.loadTemplates()
        XCTAssertTrue(templates.contains(where: { $0.id == template.id }), "模板应该被保存")
        
        // 删除模板
        viewModel.deleteTemplate(template.id)
        
        // 验证模板已被删除
        templates = viewModel.loadTemplates()
        XCTAssertFalse(templates.contains(where: { $0.id == template.id }), "模板应该被删除")
    }
    
    func testTemplateCoveredSystems() {
        // 创建一个测试食物
        let food = Food(
            name: "测试食物",
            description: "测试食物描述",
            healthDefenseSystems: [.immune, .digestive],
            category: .vegetable,
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5
        )
        
        // 创建一个使用该食物的模板
        let template = WeeklyFoodTemplate(
            name: "系统覆盖测试",
            description: "测试防御系统覆盖",
            mondayFoods: [food.id],
            tuesdayFoods: [],
            wednesdayFoods: [],
            thursdayFoods: [],
            fridayFoods: [],
            saturdayFoods: [],
            sundayFoods: []
        )
        
        // 添加食物到视图模型
        viewModel.allFoods.append(food)
        
        // 测试覆盖的系统
        let coveredSystems = template.coveredSystems(with: viewModel.allFoods)
        XCTAssertTrue(coveredSystems.contains(.immune), "应该覆盖免疫系统")
        XCTAssertTrue(coveredSystems.contains(.digestive), "应该覆盖消化系统")
        XCTAssertEqual(coveredSystems.count, 2, "应该覆盖2个系统")
    }
}

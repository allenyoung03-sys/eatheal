//
//  CreateTemplateView.swift
//  eatheal
//

import SwiftUI

struct CreateTemplateView: View {
    @EnvironmentObject private var model: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var dailyFoods: [DayTemplate] = Array(1...7).map { DayTemplate(dayOfWeek: $0, foodIds: []) }
    @State private var selectedDay = 1
    @State private var showingFoodPicker = false
    
    private let dayNames = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("模板信息") {
                    TextField("模板名称", text: $templateName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("描述（可选）", text: $templateDescription)
                        .textInputAutocapitalization(.sentences)
                }
                
                Section("每周安排") {
                    Picker("选择日期", selection: $selectedDay) {
                        ForEach(1...7, id: \.self) { day in
                            Text(dayNames[day-1]).tag(day)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DayFoodListView(
                        dayTemplate: $dailyFoods[selectedDay-1],
                        foods: model.allFoods,
                        onAddFood: { showingFoodPicker = true }
                    )
                }
                
                Section("模板预览") {
                    TemplatePreviewView(template: WeeklyFoodTemplate(
                        name: templateName.isEmpty ? "未命名模板" : templateName,
                        description: templateDescription.isEmpty ? nil : templateDescription,
                        dailyFoods: dailyFoods
                    ), foods: model.allFoods)
                }
            }
            .navigationTitle("新建模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTemplate()
                        dismiss()
                    }
                    .disabled(templateName.isEmpty)
                }
            }
            .sheet(isPresented: $showingFoodPicker) {
                FoodPickerView(
                    foods: model.allFoods,
                    selectedFoodIds: dailyFoods[selectedDay-1].foodIds,
                    onSelect: { food in
                        addFoodToSelectedDay(food)
                    }
                )
            }
        }
    }
    
    private func addFoodToSelectedDay(_ food: Food) {
        var dayTemplate = dailyFoods[selectedDay-1]
        if !dayTemplate.foodIds.contains(food.id) {
            dayTemplate.foodIds.append(food.id)
            dailyFoods[selectedDay-1] = dayTemplate
        }
    }
    
    private func saveTemplate() {
        let template = WeeklyFoodTemplate(
            name: templateName,
            description: templateDescription.isEmpty ? nil : templateDescription,
            dailyFoods: dailyFoods
        )
        model.saveTemplate(template)
    }
}

struct DayFoodListView: View {
    @Binding var dayTemplate: DayTemplate
    let foods: [Food]
    let onAddFood: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和计数器
            HStack {
                Text("每日食物安排")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(dayTemplate.foodIds.count) 种食物")
                    .font(.caption)
                    .foregroundStyle(dayTemplate.foodIds.count >= 5 ? AppTheme.primaryGreen : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(dayTemplate.foodIds.count >= 5 ? AppTheme.primaryGreen.opacity(0.1) : .orange.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if dayTemplate.foodIds.isEmpty {
                // 空状态 - 鼓励添加食物
                VStack(spacing: 12) {
                    Button {
                        onAddFood()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.primaryGreen)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("添加食物")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("建议每天添加5种以上食物以获得全面营养")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            } else {
                // 食物列表
                VStack(spacing: 8) {
                    ForEach(dayTemplate.foodIds, id: \.self) { foodId in
                        if let food = foods.first(where: { $0.id == foodId }) {
                            HStack {
                                FoodRow(food: food)
                                
                                Spacer()
                                
                                Button {
                                    removeFood(foodId)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                
                // 添加更多按钮和提示
                VStack(spacing: 8) {
                    if dayTemplate.foodIds.count < 5 {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text("建议添加 \(5 - dayTemplate.foodIds.count) 种以上食物以获得最佳营养覆盖")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button {
                        onAddFood()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.primaryGreen)
                            Text("添加更多食物")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppTheme.primaryGreen)
                            Spacer()
                            Text("已添加 \(dayTemplate.foodIds.count) 种")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(AppTheme.primaryGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func removeFood(_ foodId: UUID) {
        dayTemplate.foodIds.removeAll { $0 == foodId }
        dayTemplate.forcedCoverageSystems.removeValue(forKey: foodId)
    }
}

struct FoodPickerView: View {
    let foods: [Food]
    let selectedFoodIds: [UUID]
    let onSelect: (Food) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var multiSelectIds: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(foods) { food in
                    Button {
                        toggleSelection(food)
                    } label: {
                        HStack {
                            FoodRow(food: food)
                            
                            Spacer()
                            
                            if isSelected(food) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.primaryGreen)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("选择食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加 (\(multiSelectIds.count))") {
                        addSelectedFoods()
                    }
                    .disabled(multiSelectIds.isEmpty)
                }
            }
            .onAppear {
                // 初始化多选集合，包含已选中的食物
                multiSelectIds = Set(selectedFoodIds)
            }
        }
    }
    
    private func isSelected(_ food: Food) -> Bool {
        multiSelectIds.contains(food.id)
    }
    
    private func toggleSelection(_ food: Food) {
        if multiSelectIds.contains(food.id) {
            multiSelectIds.remove(food.id)
        } else {
            multiSelectIds.insert(food.id)
        }
    }
    
    private func addSelectedFoods() {
        // 添加所有选中的食物
        for foodId in multiSelectIds {
            if let food = foods.first(where: { $0.id == foodId }) {
                onSelect(food)
            }
        }
        dismiss()
    }
}

struct TemplatePreviewView: View {
    let template: WeeklyFoodTemplate
    let foods: [Food]
    
    private let systems = HealthDefenseSystem.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和统计信息
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("模板预览")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.mutedText)
                    Text("\(template.totalFoods) 种食物 · 覆盖 \(template.coveredSystems(with: foods).count)/\(systems.count) 个系统")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // 覆盖矩阵 - 类似 WeekOverviewView
            coverageMatrix
            
            // 系统表现
            Text("系统覆盖情况")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.mutedText)
                .padding(.top, 4)
            
            VStack(spacing: 12) {
                ForEach(systems, id: \.self) { system in
                    systemPerformanceRow(system: system)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    
    private var coverageMatrix: some View {
        VStack(alignment: .leading, spacing: 12) {
            let labels = weekDayLabels()
            HStack(spacing: 6) {
                Text("")
                    .frame(width: 30)
                ForEach(0..<7, id: \.self) { i in
                    Text(labels[i])
                        .font(.caption2.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.clear)
                        .foregroundStyle(Color.primary)
                        .clipShape(Capsule())
                }
            }

            VStack(spacing: 6) {
                ForEach(systems, id: \.self) { system in
                    HStack(spacing: 6) {
                        Image(systemName: system.iconName)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(system.color)
                            .frame(width: 30, height: 28)
                        ForEach(0..<7, id: \.self) { dayIdx in
                            matrixCell(system: system, dayIndex: dayIdx)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(white: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private func matrixCell(system: HealthDefenseSystem, dayIndex: Int) -> some View {
        guard dayIndex < template.dailyFoods.count else {
            return AnyView(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.01))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    }
                    .frame(height: 28)
            )
        }
        
        let dayTemplate = template.dailyFoods[dayIndex]
        let isCovered = isSystemCovered(system: system, in: dayTemplate)
        
        let fillColor: Color = isCovered ? system.color.opacity(0.6) : Color.white.opacity(0.01)
        
        return AnyView(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(fillColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            isCovered ? system.color.opacity(0.8) : Color.gray.opacity(0.25),
                            lineWidth: isCovered ? 1.5 : 1
                        )
                }
                .frame(height: 28)
        )
    }
    
    private func isSystemCovered(system: HealthDefenseSystem, in dayTemplate: DayTemplate) -> Bool {
        // 检查该天的食物是否覆盖了指定的系统
        for foodId in dayTemplate.foodIds {
            if let food = foods.first(where: { $0.id == foodId }) {
                if let forcedSystem = dayTemplate.forcedCoverageSystems[foodId] {
                    if forcedSystem == system {
                        return true
                    }
                } else if food.systems.contains(system) {
                    return true
                }
            }
        }
        return false
    }
    
    private func systemPerformanceRow(system: HealthDefenseSystem) -> some View {
        let coveredDays = template.dailyFoods.filter { dayTemplate in
            isSystemCovered(system: system, in: dayTemplate)
        }.count
        
        let pct = Double(coveredDays) / 7.0

        return HStack(spacing: 14) {
            Image(systemName: system.iconName)
                .font(.title3)
                .foregroundStyle(system.color)
                .frame(width: 36, height: 36)
                .background(system.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(system.displayName)
                    .font(.headline)
                Text("\(coveredDays) / 7 天有覆盖")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 5)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(system.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 48, height: 48)
                Text("\(Int((pct * 100).rounded()))%")
                    .font(.caption2.weight(.bold))
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    
    private func weekDayLabels() -> [String] {
        ["一", "二", "三", "四", "五", "六", "日"]
    }
}

struct FoodRow: View {
    let food: Food
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: food.iconName)
                .font(.title3)
                .foregroundStyle(food.color)
                .frame(width: 32, height: 32)
                .background(food.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    ForEach(Array(food.systems)) { system in
                        Image(systemName: system.iconName)
                            .font(.caption2)
                            .foregroundStyle(system.color)
                    }
                }
            }
            
            Spacer()
            
            if food.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CreateTemplateView()
        .environmentObject(AppViewModel())
}

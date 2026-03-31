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
            if dayTemplate.foodIds.isEmpty {
                Button {
                    onAddFood()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGreen)
                        Text("添加食物")
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
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
                        .padding(.vertical, 4)
                    }
                }
                
                Button {
                    onAddFood()
                } label: {
                    Label("添加更多食物", systemImage: "plus")
                        .font(.caption)
                        .foregroundStyle(AppTheme.primaryGreen)
                }
                .padding(.top, 8)
            }
        }
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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(foods) { food in
                    Button {
                        onSelect(food)
                        dismiss()
                    } label: {
                        HStack {
                            FoodRow(food: food)
                            
                            Spacer()
                            
                            if selectedFoodIds.contains(food.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.primaryGreen)
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
            }
        }
    }
}

struct TemplatePreviewView: View {
    let template: WeeklyFoodTemplate
    let foods: [Food]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("总计: \(template.totalFoods) 种食物")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                let coveredSystems = template.coveredSystems(with: foods)
                Text("覆盖 \(coveredSystems.count)/\(HealthDefenseSystem.allCases.count) 个系统")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !template.dailyFoods.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(template.dailyFoods) { dayTemplate in
                        HStack {
                            Text("周\(dayTemplate.dayOfWeek):")
                                .font(.caption)
                                .frame(width: 40, alignment: .leading)
                            
                            Text("\(dayTemplate.foodIds.count) 种食物")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
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

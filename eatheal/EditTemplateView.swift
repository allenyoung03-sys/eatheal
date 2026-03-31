//
//  EditTemplateView.swift
//  eatheal
//

import SwiftUI

struct EditTemplateView: View {
    @EnvironmentObject private var model: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    let template: WeeklyFoodTemplate
    
    @State private var templateName: String
    @State private var templateDescription: String
    @State private var dailyFoods: [DayTemplate]
    @State private var selectedDay = 1
    @State private var showingFoodPicker = false
    
    private let dayNames = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    init(template: WeeklyFoodTemplate) {
        self.template = template
        _templateName = State(initialValue: template.name)
        _templateDescription = State(initialValue: template.description ?? "")
        _dailyFoods = State(initialValue: template.dailyFoods)
    }
    
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
                        id: template.id,
                        name: templateName.isEmpty ? "未命名模板" : templateName,
                        description: templateDescription.isEmpty ? nil : templateDescription,
                        dailyFoods: dailyFoods
                    ), foods: model.allFoods)
                }
            }
            .navigationTitle("编辑模板")
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
        let updatedTemplate = WeeklyFoodTemplate(
            id: template.id,
            name: templateName,
            description: templateDescription.isEmpty ? nil : templateDescription,
            dailyFoods: dailyFoods
        )
        model.saveTemplate(updatedTemplate)
    }
}

#Preview {
    let sampleTemplate = WeeklyFoodTemplate(
        name: "示例模板",
        description: "这是一个示例模板",
        dailyFoods: [
            DayTemplate(dayOfWeek: 1, foodIds: [UUID()]),
            DayTemplate(dayOfWeek: 2, foodIds: [UUID(), UUID()]),
            DayTemplate(dayOfWeek: 3, foodIds: []),
            DayTemplate(dayOfWeek: 4, foodIds: [UUID()]),
            DayTemplate(dayOfWeek: 5, foodIds: []),
            DayTemplate(dayOfWeek: 6, foodIds: [UUID()]),
            DayTemplate(dayOfWeek: 7, foodIds: [UUID(), UUID(), UUID()])
        ]
    )
    
    return EditTemplateView(template: sampleTemplate)
        .environmentObject(AppViewModel())
}

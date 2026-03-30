//
//  DayPlanView.swift
//  eatheal
//

import SwiftUI

struct DayPlanView: View {
    @EnvironmentObject private var model: AppViewModel
    @State private var showFoodPicker = false
    @State private var pickerSystemFilter: HealthDefenseSystem?
    @State private var lockPickerToSystem = false

    private var today: Date { Date() }

    private var plan: DayPlan { model.dayPlan(for: today) }

    private var activeCount: Int {
        HealthDefenseSystem.allCases.filter { plan.coveredSystems.contains($0) }.count
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 20) {
                        AppHeaderBar()
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日计划")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppTheme.mutedText)
                            Text(dateTitle(today))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.primary)
                        }

                        actionCardIfNeeded

                        defenseSection
                    }
                    .padding(.bottom, 8)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                Section {
                    ForEach(Array(plan.selectedFoods.enumerated()), id: \.element.id) { index, food in
                        loggedRow(food: food, index: index)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    model.remove(food: food, from: today)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let food = plan.selectedFoods[index]
                            model.remove(food: food, from: today)
                        }
                    }

                    Button {
                        pickerSystemFilter = nil
                        lockPickerToSystem = false
                        showFoodPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundStyle(AppTheme.mutedText)
                            Text("添加超级食物")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.mutedText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                                .foregroundStyle(Color.gray.opacity(0.35))
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 24, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } header: {
                    loggedSectionHeader {
                        pickerSystemFilter = nil
                        lockPickerToSystem = false
                        showFoodPicker = true
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())

            Button {
                pickerSystemFilter = nil
                lockPickerToSystem = false
                showFoodPicker = true
            } label: {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(AppTheme.primaryGreen)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 12)
        }
        .sheet(isPresented: $showFoodPicker) {
            FoodPickerSheet(
                initialSystem: pickerSystemFilter,
                lockSystemFilter: lockPickerToSystem
            )
                .environmentObject(model)
        }
        .onAppear { model.rollWeekIfNeeded() }
    }

    @ViewBuilder
    private var actionCardIfNeeded: some View {
        let missing = plan.missingSystems
        if !missing.isEmpty {
            let s = missing[0]
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.white)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 6) {
                    Text("需要关注")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(hint(for: s))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.95))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.actionTeal)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var defenseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("五大防御系统")
                    .font(.headline)
                Spacer()
                Text("\(activeCount) / \(HealthDefenseSystem.allCases.count) 已激活")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
            }

            HStack(spacing: 0) {
                ForEach(HealthDefenseSystem.allCases) { sys in
                    Button {
                        pickerSystemFilter = sys
                        lockPickerToSystem = true
                        showFoodPicker = true
                    } label: {
                        DefenseRingBadge(
                            system: sys,
                            active: plan.coveredSystems.contains(sys)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func loggedSectionHeader(onEdit: @escaping () -> Void) -> some View {
        HStack {
            Text("已记录食物")
                .font(.headline)
            Spacer()
            Button(action: onEdit) {
                Text("编辑计划")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.primaryGreen.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .textCase(nil)
    }

    private func loggedRow(food: Food, index: Int) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(
                    colors: [food.systems.first?.color.opacity(0.35) ?? .gray.opacity(0.2), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.primaryGreen.opacity(0.85))
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(food.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    ForEach(food.systems, id: \.self) { s in
                        Image(systemName: s.iconName)
                            .font(.caption2)
                            .foregroundStyle(s.color)
                    }
                }
            }
            Spacer()
            Text(mealLabel(at: index))
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        .contextMenu {
            Button(role: .destructive) {
                model.remove(food: food, from: today)
            } label: {
                Label("从今日移除", systemImage: "trash")
            }
        }
    }

    private func dateTitle(_ date: Date) -> String {
        Self.dayTitleFormatter.string(from: date)
    }

    private static let dayTitleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "EEEE，M 月 d 日"
        return f
    }()

    private func mealLabel(at index: Int) -> String {
        let labels = ["早餐", "午餐", "晚餐", "加餐"]
        return labels[index % labels.count]
    }

    private func hint(for system: HealthDefenseSystem) -> String {
        switch system {
        case .microbiome:
            return "缺少微生物组支持。试试加入燕麦、豆类、味噌或菌菇等高纤维 / 发酵食物。"
        case .immunity:
            return "免疫系统覆盖不足。可加入绿茶、浆果或十字花科蔬菜。"
        case .angiogenesis:
            return "血管新生调控覆盖不足。可加入番茄、浆果或橄榄油等。"
        case .dnaProtection:
            return "DNA 保护覆盖不足。可加入蓝莓、绿茶或菠菜等抗氧化食物。"
        case .regeneration:
            return "组织再生覆盖不足。可加入西兰花、坚果或优质蛋白来源。"
        }
    }
}

struct FoodPickerSheet: View {
    @EnvironmentObject private var model: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selectedSystem: HealthDefenseSystem?
    /// 待批量加入的食物（PRD：支持多选）
    @State private var pendingIds: Set<UUID> = []
    private let fixedSystem: HealthDefenseSystem?

    private var today: Date { Date() }

    init(initialSystem: HealthDefenseSystem? = nil, lockSystemFilter: Bool = false) {
        fixedSystem = lockSystemFilter ? initialSystem : nil
        _selectedSystem = State(initialValue: lockSystemFilter ? nil : initialSystem)
    }

    private var activeSystemFilter: HealthDefenseSystem? {
        fixedSystem ?? selectedSystem
    }

    private var filtered: [Food] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var list = model.allFoods
        if let system = activeSystemFilter {
            list = list.filter { $0.systems.contains(system) }
        }
        if q.isEmpty { return list }
        return list.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        NavigationStack {
            List {
                if fixedSystem == nil {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                filterChip(
                                    title: "全部",
                                    selected: selectedSystem == nil,
                                    dot: nil
                                ) {
                                    selectedSystem = nil
                                }
                                ForEach(HealthDefenseSystem.allCases) { system in
                                    filterChip(
                                        title: system.displayName,
                                        selected: selectedSystem == system,
                                        dot: system.color
                                    ) {
                                        selectedSystem = selectedSystem == system ? nil : system
                                    }
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                }

                Section {
                    ForEach(filtered) { food in
                        let scheduled = model.isFoodScheduled(food, on: today)
                        let selected = pendingIds.contains(food.id)
                        Button {
                            guard !scheduled else { return }
                            if selected {
                                pendingIds.remove(food.id)
                            } else {
                                pendingIds.insert(food.id)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(food.name)
                                        .foregroundStyle(scheduled ? Color.secondary : Color.primary)
                                    Text(food.systems.map(\.displayName).joined(separator: " · "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if scheduled {
                                    Text("已在今日")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.mutedText)
                                } else {
                                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(selected ? AppTheme.primaryGreen : Color.gray.opacity(0.45))
                                }
                            }
                        }
                        .disabled(scheduled)
                    }
                }
            }
            .searchable(text: $query, prompt: "搜索食物")
            .navigationTitle("加入今日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加 (\(pendingIds.count))") {
                        for id in pendingIds {
                            if let f = model.food(by: id) {
                                if let fixedSystem {
                                    model.add(food: f, to: today, forcedSystem: fixedSystem)
                                } else {
                                    model.add(food: f, to: today)
                                }
                            }
                        }
                        dismiss()
                    }
                    .disabled(pendingIds.isEmpty)
                }
            }
        }
    }

    private func filterChip(
        title: String,
        selected: Bool,
        dot: Color?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let dot {
                    Circle()
                        .fill(dot)
                        .frame(width: 8, height: 8)
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(selected ? Color.white : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? AppTheme.primaryGreen : Color(white: 0.94))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DayPlanView()
        .environmentObject(AppViewModel())
}

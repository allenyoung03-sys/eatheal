//
//  WeekOverviewView.swift
//  eatheal
//

import SwiftUI

struct WeekOverviewView: View {
    @EnvironmentObject private var model: AppViewModel

    private let systems = HealthDefenseSystem.allCases

    @State private var showingCreateTemplate = false
    @State private var showingTemplateManagement = false
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AppHeaderBar()
                    .padding(.top, 8)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("防御策略")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.mutedText)
                        Text("每周总览")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(AppTheme.primaryGreen)
                        Text("你的 7 日营养蓝图，围绕五大健康支柱保持覆盖，有助于整体韧性。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    
                    Menu {
                        Button {
                            showingSaveConfirmation = true
                        } label: {
                            Label("存为模板", systemImage: "bookmark.fill")
                        }
                        
                        Button {
                            showingTemplateManagement = true
                        } label: {
                            Label("管理模板", systemImage: "list.bullet")
                        }
                    } label: {
                        Label("模板", systemImage: "bookmark.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(AppTheme.primaryGreen)
                            .clipShape(Capsule())
                    }
                }

                coverageMatrix

                Text("系统表现")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.mutedText)
                    .padding(.top, 4)

                VStack(spacing: 12) {
                    ForEach(systems, id: \.self) { sys in
                        performanceRow(system: sys)
                    }
                }

                scientificCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear { model.rollWeekIfNeeded() }
        .sheet(isPresented: $showingCreateTemplate) {
            CreateTemplateView()
                .environmentObject(model)
        }
        .sheet(isPresented: $showingTemplateManagement) {
            NavigationStack {
                TemplateManagementView()
                    .environmentObject(model)
            }
        }
        .alert("保存为模板", isPresented: $showingSaveConfirmation) {
            Button("取消", role: .cancel) { }
            Button("保存") {
                showingCreateTemplate = true
            }
        } message: {
            Text("将当前周的食物安排保存为模板，方便以后快速应用。")
        }
    }

    private var coverageMatrix: some View {
        VStack(alignment: .leading, spacing: 12) {
            let labels = weekDayLabels()
            HStack(spacing: 6) {
                Text("")
                    .frame(width: 30)
                ForEach(0..<7, id: \.self) { i in
                    let isToday = model.currentWeek.days.indices.contains(i) &&
                        Calendar.current.isDateInToday(model.currentWeek.days[i].date)
                    Text(labels[i])
                        .font(.caption2.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(isToday ? AppTheme.primaryGreen : Color.clear)
                        .foregroundStyle(isToday ? Color.white : Color.primary)
                        .clipShape(Capsule())
                }
            }

            VStack(spacing: 6) {
                ForEach(systems, id: \.self) { sys in
                    HStack(spacing: 6) {
                        Image(systemName: sys.iconName)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(sys.color)
                            .frame(width: 30, height: 28)
                        ForEach(0..<7, id: \.self) { dayIdx in
                            cell(system: sys, dayIndex: dayIdx)
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

    private func cell(system: HealthDefenseSystem, dayIndex: Int) -> some View {
        guard dayIndex < model.currentWeek.days.count else {
            return RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(1.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                }
                .frame(height: 28)
                .eraseToAnyView()
        }
        
        let day = model.currentWeek.days[dayIndex]
        let plannedCovered = day.coveredSystems.contains(system)
        let actualCovered = day.actuallyCoveredSystems.contains(system)
        
        // 根据用户需求调整视觉表现
        let fillColor: Color
        let borderColor: Color
        let borderWidth: CGFloat
        
        if actualCovered {
            // 状态2：实际覆盖（打勾后）- 白框覆盖颜色100%
            fillColor = system.color.opacity(1.0)  // 100%不透明度的系统颜色
            borderColor = system.color.opacity(0.9)  // 深色边框
            borderWidth = 1.5
        } else if plannedCovered {
            // 状态1：计划覆盖（添加食物后）- 白框外框改变颜色
            fillColor = Color.white.opacity(1.0)  // 白色填充
            borderColor = system.color.opacity(1.0)  // 100%不透明度的系统颜色边框
            borderWidth = 1.5
        } else {
            // 状态3：未覆盖 - 保留白框
            fillColor = Color.white.opacity(1.0)  // 白色填充
            borderColor = Color.gray.opacity(0.25)  // 灰色边框
            borderWidth = 1
        }
        
        return RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(fillColor)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .frame(height: 28)
            .eraseToAnyView()
    }

    /// 与 DayPlan 行对齐：第 0 列对应周一
    private func weekDayLabels() -> [String] {
        ["一", "二", "三", "四", "五", "六", "日"]
    }

    private func performanceRow(system: HealthDefenseSystem) -> some View {
        let count = model.weeklyCoverage(for: system)
        let pct = Double(count) / 7.0

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
                Text("\(count) / 7 天有覆盖")
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

    private var scientificCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("科学亮点")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(AppTheme.primaryGreen.opacity(0.9))
            Text("用浆果促进血管新生调控")
                .font(.headline)
                .foregroundStyle(.white)
            Text("树莓含有鞣花酸等成分，在研究中与抑制为肿瘤供血的异常血管生成有关。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                AppTheme.primaryGreen
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 120, height: 120)
                    .offset(x: 24, y: -30)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.top, 8)
    }
}

#Preview {
    WeekOverviewView()
        .environmentObject(AppViewModel())
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

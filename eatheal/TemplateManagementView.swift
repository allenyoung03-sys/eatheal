//
//  TemplateManagementView.swift
//  eatheal
//

import SwiftUI

struct TemplateManagementView: View {
    @EnvironmentObject private var model: AppViewModel
    @State private var templates: [WeeklyFoodTemplate] = []
    @State private var showingCreateTemplate = false
    @State private var showingApplyConfirmation: UUID?
    @State private var showingDeleteConfirmation: UUID?
    @State private var showingEditTemplate: TemplateId?
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("食物模板")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        addButton
                    }
                }
                .sheet(isPresented: $showingCreateTemplate) {
                    CreateTemplateView()
                        .environmentObject(model)
                }
                .sheet(item: $showingEditTemplate) { templateId in
                    editSheet(for: templateId)
                }
                .alert("应用模板", isPresented: applyAlertBinding) {
                    applyAlertButtons
                } message: {
                    Text("这将覆盖当前周的所有食物安排。确定要继续吗？")
                }
                .alert("删除模板", isPresented: deleteAlertBinding) {
                    deleteAlertButtons
                } message: {
                    Text("确定要删除这个模板吗？此操作无法撤销。")
                }
                .onAppear {
                    loadTemplates()
                }
        }
    }
    
    private var contentView: some View {
        Group {
            if templates.isEmpty {
                emptyStateView
            } else {
                templateListView
            }
        }
    }
    
    private var addButton: some View {
        Button {
            showingCreateTemplate = true
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private var applyAlertBinding: Binding<Bool> {
        Binding(
            get: { showingApplyConfirmation != nil },
            set: { if !$0 { showingApplyConfirmation = nil } }
        )
    }
    
    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { showingDeleteConfirmation != nil },
            set: { if !$0 { showingDeleteConfirmation = nil } }
        )
    }
    
    private var applyAlertButtons: some View {
        Group {
            Button("取消", role: .cancel) { }
            Button("应用", role: .destructive) {
                if let id = showingApplyConfirmation {
                    applyTemplate(id)
                }
            }
        }
    }
    
    private var deleteAlertButtons: some View {
        Group {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let id = showingDeleteConfirmation {
                    deleteTemplate(id)
                }
            }
        }
    }
    
    private func editSheet(for templateId: TemplateId) -> some View {
        Group {
            if let template = templates.first(where: { $0.id == templateId.id }) {
                EditTemplateView(template: template)
                    .environmentObject(model)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.4))
            
            Text("暂无模板")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text("创建你的第一个食物模板，快速设置每周计划")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingCreateTemplate = true
            } label: {
                Label("新建模板", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryGreen)
                    .clipShape(Capsule())
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }
    
    private var templateListView: some View {
        List {
            ForEach(templates) { template in
                TemplateRow(template: template, foods: model.allFoods)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            showingEditTemplate = TemplateId(id: template.id)
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                        
                        Button {
                            showingApplyConfirmation = template.id
                        } label: {
                            Label("应用", systemImage: "checkmark.circle")
                        }
                        .tint(.green)
                        
                        Button(role: .destructive) {
                            showingDeleteConfirmation = template.id
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button {
                            showingEditTemplate = TemplateId(id: template.id)
                        } label: {
                            Label("编辑模板", systemImage: "pencil")
                        }
                        
                        Button {
                            showingApplyConfirmation = template.id
                        } label: {
                            Label("应用到本周", systemImage: "checkmark.circle")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteConfirmation = template.id
                        } label: {
                            Label("删除模板", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .background(AppTheme.background)
    }
    
    private func loadTemplates() {
        templates = model.loadTemplates()
    }
    
    private func applyTemplate(_ id: UUID) {
        if let template = templates.first(where: { $0.id == id }) {
            model.applyTemplate(template)
            showingApplyConfirmation = nil
        }
    }
    
    private func deleteTemplate(_ id: UUID) {
        model.deleteTemplate(id)
        templates.removeAll { $0.id == id }
        showingDeleteConfirmation = nil
    }
}

struct TemplateRow: View {
    let template: WeeklyFoodTemplate
    let foods: [Food]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let description = template.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(template.totalFoods) 种食物")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.primaryGreen)
                    
                    Text(template.shortDescription)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // 显示覆盖的防御系统
            let coveredSystems = template.coveredSystems(with: foods)
            if !coveredSystems.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(coveredSystems).sorted(by: { $0.displayName < $1.displayName })) { system in
                        HStack(spacing: 4) {
                            Image(systemName: system.iconName)
                                .font(.caption2)
                                .foregroundStyle(system.color)
                            Text(system.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(system.color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 辅助类型
struct TemplateId: Identifiable {
    let id: UUID
}

#Preview {
    TemplateManagementView()
        .environmentObject(AppViewModel())
}

//
//  FoodLibraryView.swift
//  eatheal
//

import SwiftUI

private enum FoodCategoryFilter: String, CaseIterable {
    case all = "全部"
    case fruits = "水果"
    case vegetables = "蔬菜"
    case tea = "茶饮"
}

struct FoodLibraryView: View {
    @EnvironmentObject private var model: AppViewModel
    @State private var query = ""
    @State private var category: FoodCategoryFilter = .all
    @State private var defenseFilter: HealthDefenseSystem?

    private var base: [Food] {
        model.allFoods
    }

    private var filtered: [Food] {
        var list = base
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(q) }
        }
        switch category {
        case .all: break
        case .fruits: list = list.filter { $0.tags.contains("水果") }
        case .vegetables: list = list.filter { $0.tags.contains("蔬菜") }
        case .tea: list = list.filter { $0.tags.contains("茶饮") }
        }
        if let d = defenseFilter {
            list = list.filter { $0.systems.contains(d) }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AppHeaderBar()
                        .padding(.top, 8)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.mutedText)
                        TextField("搜索食物库…", text: $query)
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 2)

                    categoryChips

                    VStack(alignment: .leading, spacing: 8) {
                        Text("目标防御系统")
                            .font(.headline)
                        Text("按影响筛选")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedText)
                        defenseChips
                    }

                    LazyVStack(spacing: 16) {
                        ForEach(filtered) { food in
                            ZStack(alignment: .topTrailing) {
                                NavigationLink(value: food) {
                                    FoodCard(food: food)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    let f = model.food(by: food.id) ?? food
                                    model.toggleFavorite(for: f)
                                } label: {
                                    let fav = (model.food(by: food.id) ?? food).isFavorite
                                    Image(systemName: fav ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundStyle(fav ? Color.yellow : Color.primary)
                                        .padding(10)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                                .buttonStyle(.borderless)
                                .padding(10)
                                .zIndex(1)
                                .accessibilityLabel("收藏")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationDestination(for: Food.self) { food in
                FoodDetailView(food: food)
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FoodCategoryFilter.allCases, id: \.self) { c in
                    let selected = category == c
                    Button {
                        category = c
                    } label: {
                        Text(c.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected ? Color.white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selected ? AppTheme.primaryGreen : Color(white: 0.94))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var defenseChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(title: "全部", selected: defenseFilter == nil) {
                    defenseFilter = nil
                }
                ForEach(HealthDefenseSystem.allCases) { sys in
                    filterChip(
                        title: sys.displayName,
                        selected: defenseFilter == sys,
                        dot: sys.color
                    ) {
                        defenseFilter = defenseFilter == sys ? nil : sys
                    }
                }
            }
        }
    }

    private func filterChip(title: String, selected: Bool, dot: Color? = nil, action: @escaping () -> Void) -> some View {
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

struct FoodCard: View {
    let food: Food

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LinearGradient(
                colors: [
                    food.systems.first?.color.opacity(0.35) ?? .gray.opacity(0.2),
                    AppTheme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)
            .overlay {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.primaryGreen.opacity(0.35))
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(food.tags.first ?? "")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.mutedText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.94))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                Text(food.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                FlowTags(systems: food.systems)

                Text("加入今日计划")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.94))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(14)
        }
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

private struct FlowTags: View {
    let systems: [HealthDefenseSystem]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(systems, id: \.self) { s in
                TagChip(text: s.tagUppercase, color: s.color)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    FoodLibraryView()
        .environmentObject(AppViewModel())
}

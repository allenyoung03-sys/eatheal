//
//  FoodDetailView.swift
//  eatheal
//

import SwiftUI

struct FoodDetailView: View {
    @EnvironmentObject private var model: AppViewModel

    let food: Food

    private var live: Food? {
        model.food(by: food.id)
    }

    private var alreadyInToday: Bool {
        model.isFoodScheduled(live ?? food, on: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ZStack {
                    LinearGradient(
                        colors: [
                            (live?.systems.first ?? food.systems.first)?.color.opacity(0.35) ?? .gray.opacity(0.2),
                            AppTheme.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 220)
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.primaryGreen.opacity(0.35))
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(live?.name ?? food.name)
                            .font(.system(size: 28, weight: .bold))
                        Text((live ?? food).tags.joined(separator: " · "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        if let f = live ?? model.food(by: food.id) {
                            model.toggleFavorite(for: f)
                        }
                    } label: {
                        Image(systemName: (live ?? food).isFavorite ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle((live ?? food).isFavorite ? Color.yellow : AppTheme.mutedText)
                            .padding(10)
                            .background(Color(white: 0.95), in: Circle())
                    }
                    .buttonStyle(.plain)
                }

                Text("支持的防御系统")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach((live ?? food).systems, id: \.self) { s in
                        HStack(spacing: 10) {
                            Image(systemName: s.iconName)
                                .foregroundStyle(s.color)
                            Text(s.displayName)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            TagChip(text: s.tagUppercase, color: s.color)
                        }
                        .padding(12)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                Text("简介")
                    .font(.headline)
                Text((live ?? food).description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    let f = live ?? food
                    model.add(food: f, to: Date())
                } label: {
                    Text(alreadyInToday ? "已在今日计划中" : "加入今天")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(alreadyInToday ? Color.gray : AppTheme.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(alreadyInToday)
                .padding(.top, 8)
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FoodDetailView(food: Food.sampleData[0])
            .environmentObject(AppViewModel())
    }
}

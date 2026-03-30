//
//  ProfileView.swift
//  eatheal
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var model: AppViewModel
    @AppStorage("mealRemindersOn") private var mealRemindersOn = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                AppHeaderBar()
                    .padding(.top, 8)

                memberCard

                favoritesSection

                templatesSection

                preferencesSection

                promoCard

                aboutSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private var memberCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                Text("会员自 2023")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
                Text("演示用户")
                    .font(.system(size: 26, weight: .bold))
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppTheme.primaryGreen)
                    Text("代谢方向 · 进阶")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)

            Circle()
                .fill(AppTheme.primaryGreen.opacity(0.12))
                .frame(width: 90, height: 90)
                .offset(x: 18, y: -18)
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("我的收藏")
                        .font(.headline)
                    Text("每天用食物强化五大防御")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                }
                Spacer()
                Text("查看全部")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    if model.favoriteFoods().isEmpty {
                        Text("在食物库中为食物点星标，会显示在这里。")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedText)
                            .padding(.vertical, 24)
                    }
                    ForEach(model.favoriteFoods()) { food in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [food.systems.first?.color.opacity(0.35) ?? .gray.opacity(0.2), .white],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 140, height: 100)
                                .overlay {
                                    Image(systemName: "leaf.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(AppTheme.primaryGreen.opacity(0.35))
                                }
                            Text(food.name)
                                .font(.subheadline.weight(.bold))
                                .lineLimit(1)
                            Text(food.systems.first?.tagUppercase ?? "")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(food.systems.first?.color ?? AppTheme.mutedText)
                        }
                        .frame(width: 140, alignment: .leading)
                    }
                }
            }
        }
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("已存计划模板")
                .font(.headline)
            templateRow(
                title: "免疫重置方案",
                subtitle: "14 天 · 高维生素 C / D 侧重",
                icon: "microscope",
                tint: AppTheme.primaryGreen.opacity(0.15)
            )
            templateRow(
                title: "代谢启动",
                subtitle: "7 天 · 纤维与益生元丰富",
                icon: "bolt.fill",
                tint: Color.blue.opacity(0.12)
            )
        }
    }

    private func templateRow(title: String, subtitle: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(AppTheme.primaryGreen)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.mutedText)
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("偏好与设置")
                .font(.headline)

            VStack(spacing: 0) {
                prefRow(
                    title: "饮食限制",
                    icon: "fork.knife.circle",
                    trailing: {
                        HStack(spacing: 8) {
                            Text("纯素")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.primaryGreen.opacity(0.12))
                                .foregroundStyle(AppTheme.primaryGreen)
                                .clipShape(Capsule())
                            Text("无麸质")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.primaryGreen.opacity(0.12))
                                .foregroundStyle(AppTheme.primaryGreen)
                                .clipShape(Capsule())
                        }
                    }
                )
                Divider().padding(.leading, 44)
                prefRow(
                    title: "用餐提醒",
                    icon: "bell.badge",
                    trailing: {
                        Toggle("", isOn: $mealRemindersOn)
                            .labelsHidden()
                            .tint(AppTheme.primaryGreen)
                    }
                )
                Divider().padding(.leading, 44)
                prefRow(
                    title: "隐私与安全",
                    icon: "shield.lefthalf.filled",
                    trailing: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.mutedText)
                    }
                )
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func prefRow<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.primaryGreen)
                .frame(width: 28)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            trailing()
        }
        .padding(.vertical, 10)
    }

    private var promoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("科学指南")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(AppTheme.primaryGreen.opacity(0.95))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.white.opacity(0.14))
                .clipShape(Capsule())
            Text("掌握五大防御系统")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text("用通俗方式了解食物如何与身体防御协同——本应用仅为健康管理演示，不构成医疗建议。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
            Button {
                // 占位
            } label: {
                Text("阅读专栏")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(
            ZStack {
                Color(red: 0.08, green: 0.22, blue: 0.18)
                Circle()
                    .stroke(.white.opacity(0.06), lineWidth: 18)
                    .frame(width: 220, height: 220)
                    .offset(x: 90, y: -70)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("吃出自愈力 · 五大防御系统")
                .font(.headline)
            Text("本原型帮助你把「选择食物 → 观察覆盖 → 回顾一周」串成闭环。数据均存储在本地，用于演示交互与信息架构。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
}

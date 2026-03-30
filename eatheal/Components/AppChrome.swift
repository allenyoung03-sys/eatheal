//
//  AppChrome.swift
//  eatheal
//

import SwiftUI

struct AppHeaderBar: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.primaryGreen.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.primaryGreen)
                }
            Text("Eat to Beat")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.primaryGreen)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color(white: 0.45))
        }
        .padding(.horizontal, 4)
    }
}

enum DefenseSystemStatus {
    case notCovered        // 未覆盖：透明
    case plannedNotConsumed // 计划覆盖但未实际摄入：15% 不透明度
    case actuallyConsumed   // 实际覆盖：100% 不透明度
}

struct DefenseRingBadge: View {
    let system: HealthDefenseSystem
    let status: DefenseSystemStatus
    var lineWidth: CGFloat = 4

    private var ringColor: Color {
        switch status {
        case .notCovered:
            return .clear
        case .plannedNotConsumed:
            return system.color.opacity(0.15)
        case .actuallyConsumed:
            return system.color
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .notCovered:
            return Color.gray.opacity(0.45)
        case .plannedNotConsumed:
            return system.color.opacity(0.15)
        case .actuallyConsumed:
            return system.color
        }
    }
    
    private var showRing: Bool {
        status != .notCovered
    }
    
    private var ringProgress: CGFloat {
        switch status {
        case .notCovered:
            return 0.08  // 未覆盖时显示一个小点
        case .plannedNotConsumed, .actuallyConsumed:
            return 1.0   // 覆盖时显示完整圆环
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                if showRing {
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                Image(systemName: system.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .frame(width: 56, height: 56)
            Text(system.shortLabel)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(Color(white: 0.35))
        }
        .frame(maxWidth: .infinity)
    }
}

struct TagChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color.opacity(0.95))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

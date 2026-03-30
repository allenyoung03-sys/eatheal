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

struct DefenseRingBadge: View {
    let system: HealthDefenseSystem
    let active: Bool
    var lineWidth: CGFloat = 4

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                Circle()
                    .trim(from: 0, to: active ? 1 : 0.08)
                    .stroke(
                        active ? system.color : Color.gray.opacity(0.35),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Image(systemName: system.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(active ? system.color : Color.gray.opacity(0.45))
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

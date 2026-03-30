//
//  HealthDefenseSystem.swift
//  eatheal
//

import SwiftUI

enum HealthDefenseSystem: String, CaseIterable, Identifiable, Hashable {
    case angiogenesis
    case regeneration
    case dnaProtection
    case microbiome
    case immunity

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .angiogenesis: return "血管生成"
        case .regeneration: return "再生"
        case .dnaProtection: return "DNA保护"
        case .microbiome: return "微生物组"
        case .immunity: return "免疫"
        }
    }

    /// 设计稿上的短标签
    var shortLabel: String {
        switch self {
        case .angiogenesis: return "血管生成"
        case .regeneration: return "再生"
        case .dnaProtection: return "DNA保护"
        case .microbiome: return "微生物组"
        case .immunity: return "免疫"
        }
    }

    var tagUppercase: String {
        switch self {
        case .angiogenesis: return "血管生成"
        case .regeneration: return "再生"
        case .dnaProtection: return "DNA保护"
        case .microbiome: return "微生物组"
        case .immunity: return "免疫"
        }
    }

    var color: Color {
        switch self {
        case .angiogenesis: return Color(red: 0.13, green: 0.42, blue: 0.28)
        case .regeneration: return Color(red: 0.47, green: 0.33, blue: 0.20)
        case .dnaProtection: return Color(red: 0.05, green: 0.52, blue: 0.52)
        case .microbiome: return Color(red: 0.0, green: 0.58, blue: 0.53)
        case .immunity: return Color(red: 0.20, green: 0.65, blue: 0.33)
        }
    }

    var iconName: String {
        switch self {
        case .angiogenesis: return "wind"
        case .regeneration: return "circle.hexagongrid.fill"
        case .dnaProtection: return "dna.fill"
        case .microbiome: return "gearshape.fill"
        case .immunity: return "shield.fill"
        }
    }
}

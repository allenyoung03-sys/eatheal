//
//  Food.swift
//  eatheal
//

import Foundation

struct Food: Identifiable, Hashable {
    let id: UUID
    var name: String
    var systems: [HealthDefenseSystem]
    var description: String
    var tags: [String]
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        systems: [HealthDefenseSystem],
        description: String,
        tags: [String],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.systems = systems
        self.description = description
        self.tags = tags
        self.isFavorite = isFavorite
    }
}

extension Food {
    /// 稳定 ID，便于预览与本地持久化引用
    static func stable(_ suffix: String) -> UUID {
        UUID(uuidString: "00000000-0000-0000-0000-\(suffix.padding(toLength: 12, withPad: "0", startingAt: 0))")!
    }

    static let sampleData: [Food] = [
        Food(
            id: stable("000000000001"),
            name: "蓝莓",
            systems: [.dnaProtection, .immunity, .angiogenesis],
            description: "富含花青素等抗氧化物质，有助于保护细胞与免疫平衡。",
            tags: ["水果"]
        ),
        Food(
            id: stable("000000000002"),
            name: "西兰花",
            systems: [.angiogenesis, .immunity, .regeneration],
            description: "含硫代葡萄糖苷等植物化合物，支持免疫与组织修复相关通路。",
            tags: ["蔬菜"]
        ),
        Food(
            id: stable("000000000003"),
            name: "绿茶",
            systems: [.microbiome, .angiogenesis, .dnaProtection],
            description: "茶多酚有助于抗氧化，并对肠道微生物环境有温和调节作用。",
            tags: ["茶饮"]
        ),
        Food(
            id: stable("000000000004"),
            name: "黑巧克力（高可可）",
            systems: [.regeneration, .angiogenesis, .immunity],
            description: "可可多酚有助于抗氧化与血管健康相关指标。",
            tags: ["零食"]
        ),
        Food(
            id: stable("000000000005"),
            name: "树莓",
            systems: [.angiogenesis, .immunity],
            description: "含鞣花酸等成分，与抑制异常血管生成相关的研究较多。",
            tags: ["水果"]
        ),
        Food(
            id: stable("000000000006"),
            name: "野生三文鱼",
            systems: [.dnaProtection, .immunity],
            description: "提供优质蛋白与 Omega-3，有助于细胞膜与炎症平衡。",
            tags: ["海鲜"]
        ),
        Food(
            id: stable("000000000007"),
            name: "燕麦",
            systems: [.microbiome, .immunity],
            description: "可溶性膳食纤维可作为益生元，支持肠道菌群多样性。",
            tags: ["谷物"]
        ),
        Food(
            id: stable("000000000008"),
            name: "味噌 / 发酵大豆",
            systems: [.microbiome, .immunity],
            description: "发酵过程带来有益微生物与风味物质，有助于膳食多样性。",
            tags: ["发酵"]
        ),
        Food(
            id: stable("000000000009"),
            name: "菠菜",
            systems: [.dnaProtection, .angiogenesis],
            description: "富含叶酸与多种植物营养素，支持细胞代谢与抗氧化。",
            tags: ["蔬菜"]
        ),
        Food(
            id: stable("000000000010"),
            name: "姜黄（咖喱）",
            systems: [.immunity, .angiogenesis],
            description: "姜黄素是研究较多的多酚类物质，与炎症调节相关。",
            tags: ["香料"]
        ),
        Food(
            id: stable("000000000011"),
            name: "核桃",
            systems: [.regeneration, .dnaProtection],
            description: "含植物性 Omega-3 与多酚，有助于神经细胞膜健康。",
            tags: ["坚果"]
        ),
        Food(
            id: stable("000000000012"),
            name: "酸奶（无糖）",
            systems: [.microbiome, .immunity],
            description: "提供益生菌与优质蛋白，帮助维持肠道屏障功能。",
            tags: ["乳制品"]
        ),
        Food(
            id: stable("000000000013"),
            name: "番茄",
            systems: [.angiogenesis, .dnaProtection],
            description: "番茄红素与维生素 C 有助于抗氧化与血管健康。",
            tags: ["蔬菜"]
        ),
        Food(
            id: stable("000000000014"),
            name: "大蒜",
            systems: [.immunity, .microbiome],
            description: "含硫化合物，与免疫调节及微生物环境有关的报道较多。",
            tags: ["蔬菜"]
        ),
        Food(
            id: stable("000000000015"),
            name: "石榴",
            systems: [.angiogenesis, .regeneration],
            description: "多酚丰富，在细胞保护与血管相关研究中被频繁提及。",
            tags: ["水果"]
        ),
        Food(
            id: stable("000000000016"),
            name: "香菇",
            systems: [.microbiome, .immunity],
            description: "含 β-葡聚糖与膳食纤维，支持免疫与肠道环境。",
            tags: ["蔬菜"]
        ),
        Food(
            id: stable("000000000017"),
            name: "黑豆",
            systems: [.microbiome, .dnaProtection],
            description: "高纤维与植物蛋白，有助于肠道发酵产物与抗氧化。",
            tags: ["豆类"]
        ),
        Food(
            id: stable("000000000018"),
            name: "橄榄油（特级初榨）",
            systems: [.angiogenesis, .immunity],
            description: "单不饱和脂肪酸与多酚，与地中海饮食模式相关。",
            tags: ["油脂"]
        )
    ]
}

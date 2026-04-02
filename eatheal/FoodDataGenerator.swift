//
//  FoodDataGenerator.swift
//  eatheal
//
//  根据Excel数据生成Food数组
//

import Foundation

struct FoodDataGenerator {
    
    /// 从用户提供的Excel内容生成Food数组
    static func generateFoodsFromExcel() -> [Food] {
        // 用户提供的Excel内容（简化版本，实际应该从文件读取）
        let excelContent = """
        水果	蔓越莓 	蔓越莓	蔓越莓		蔓越莓
        水果	黑覆盆子	黑覆盆子			黑覆盆子
        水果	蓝莓	蓝莓			蓝莓
        水果	（黑）李子	（黑）李子			针叶樱桃
        水果	桃子	桃子			草莓
        水果	苹果	苹果			圣女果
        水果	芒果	芒果
        水果	油桃	油桃
        水果	杏	杏	杏
        水果	樱桃	樱桃
        水果	荔枝	荔枝
        水果	草莓	黑莓
        水果	黑莓	黑果腺肋花楸（野樱莓）			黑莓
        水果	圣女果	葡萄
        水果		石榴
        水果		柿子（蜂屋柿）
        水果			石榴		石榴
        水果			奇异果	奇异果	橙子
        水果				橙子
        水果				西瓜	番石榴
        水果				番石榴	葡萄柚
        水果				粉红葡萄柚
        水果				香蕉	卡姆果
        蔬菜	西蓝花（苗）		西蓝花（苗）	西蓝花（苗）	西蓝花（苗）
        蔬菜	花椰菜		花椰菜	花椰菜
        蔬菜	羽衣甘蓝	羽衣甘蓝	羽衣甘蓝	羽衣甘蓝
        蔬菜	小白菜	大豆	小白菜	小白菜
        蔬菜	大豆	鹰嘴豆	大豆	大豆
        蔬菜	鹰嘴豆	小扁豆	鹰嘴豆	鹰嘴豆
        蔬菜	小扁豆	豌豆	小扁豆	小扁豆
        蔬菜	豌豆	黑豆	豌豆	豌豆
        蔬菜	黑豆	毛豆	黑豆	黑豆
        蔬菜	毛豆	豆浆	毛豆	毛豆
        蔬菜	豆浆	豆仁	豆浆	豆浆
        蔬菜	豆仁	豆酱	豆仁	豆仁
        蔬菜	豆酱	豆腐	豆酱	豆酱
        蔬菜	豆腐	味增	豆腐	豆腐
        蔬菜	味增	纳豆	味增	味增
        蔬菜	纳豆	豆豉	纳豆	纳豆
        蔬菜	豆豉		豆豉	豆豉
        蔬菜	番茄（红黑皮）			番茄
        蔬菜	洋葱
        蔬菜	红叶莴苣/菊苣
        蔬菜	辣椒	辣椒		（红）辣椒	辣椒
        蔬菜		芥菜
        蔬菜		菠菜		菠菜
        蔬菜		西洋菜
        蔬菜		芥蓝
        蔬菜		牛皮菜
        蔬菜		蕨菜
        蔬菜		四季豆
        蔬菜		中国芹菜
        蔬菜		茄子
        蔬菜		竹笋	竹笋
        蔬菜		玉米
        蔬菜		紫土豆
        蔬菜		胡萝卜		胡萝卜
        蔬菜		苦瓜
        蔬菜			卷心菜	卷心菜
        蔬菜			芜菁甘蓝	芜菁甘蓝
        蔬菜			芜菁	芜菁
        蔬菜			芝麻菜	芝麻菜
        蔬菜			芦笋
        蔬菜				西葫芦花	西葫芦花
        蔬菜					白蘑菇
        蔬菜					香菇
        蔬菜					舞茸
        蔬菜					金针菇
        蔬菜					鸡油菌
        蔬菜					羊肚菌
        蔬菜					牛肝菌
        蔬菜					平菇
        肉类海鲜	鸡腿
        肉类海鲜	海参	海参		海参
        肉类海鲜	大眼金枪鱼	大眼金枪鱼		大眼金枪鱼
        肉类海鲜	海鲈	海鲈		海鲈
        肉类海鲜	蓝鳍金枪鱼	蓝鳍金枪鱼		蓝鳍金枪鱼
        肉类海鲜	鱼子酱（鲟鱼）	鱼子酱（鲟鱼）		鱼子酱（鲟鱼）
        肉类海鲜	三文鱼	三文鱼		三文鱼
        肉类海鲜	太平洋牡蛎	太平洋牡蛎		太平洋牡蛎	太平洋牡蛎
        肉类海鲜	海鲷	海鲷		海鲷
        肉类海鲜	虹鳟鱼	虹鳟鱼		虹鳟鱼
        肉类海鲜	鱿鱼	鱿鱼		鱿鱼
        肉类海鲜	螃蟹	螃蟹		螃蟹
        肉类海鲜	贻贝	贻贝		贻贝
        肉类海鲜	章鱼	章鱼		章鱼
        肉类海鲜	扇贝	扇贝		扇贝
        肉类海鲜	墨鱼	墨鱼		墨鱼
        肉类海鲜	对虾	对虾		对虾
        肉类海鲜	鳕鱼	鳕鱼		鳕鱼
        肉类海鲜	帕尔玛火腿
        肉类海鲜	伊比利亚橡果火腿
        肉类海鲜					蛏子
        坚果种子果干	核桃	核桃	核桃	核桃	核桃
        坚果种子果干	碧根果	碧根果		碧根果
        坚果种子果干	杏仁	杏仁		杏仁
        坚果种子果干	腰果	腰果		腰果
        坚果种子果干	开心果	开心果		开心果
        坚果种子果干	松子	松子		松子
        坚果种子果干	栗子	栗子		栗子	栗子
        坚果种子果干	夏威夷果	夏威夷果		夏威夷果
        坚果种子果干	花生	花生		花生
        坚果种子果干	大麦	花生		榛子
        坚果种子果干	亚麻籽			巴西坚果
        坚果种子果干	葵花子	全麦/全谷物	全谷物
        坚果种子果干	芝麻			亚麻籽
        坚果种子果干	南瓜子			葵花子
        坚果种子果干	奇亚籽			芝麻
        坚果种子果干	无核葡萄干			南瓜子
        坚果种子果干	樱桃干			奇亚籽
        坚果种子果干	蔓越莓干
        坚果种子果干	苹果皮
        坚果种子果干	蓝莓干
        坚果种子果干		枸杞
        坚果种子果干		米糠/糙米
        坚果种子果干			裸麦粗面包（黑麦发酵）
        坚果种子果干			酸面包
        坚果种子果干				燕麦片
        坚果种子果干				西葫芦籽
        调味品	特级初榨橄榄油	特级初榨橄榄油（希腊科拉喜橄榄，意大利莫拉约罗橄榄，西班牙皮瓜尔橄榄）	德国酸菜		特级初榨橄榄油（希腊科拉喜橄榄，意大利莫拉约罗橄榄，西班牙皮瓜尔橄榄）
        调味品	苹果醋		韩国泡菜
        调味品	牛至	牛至	中国泡菜（发酵卷心菜）	姜黄
        调味品	姜黄	姜黄
        调味品	甘草	刺山柑			甘草
        调味品	肉桂	百里香		香草
        调味品	香草	新鲜山葵
        调味品	墨鱼汁	墨鱼汁		迷迭香	墨鱼汁
        调味品	迷迭香
        调味品	人参			薄荷
        调味品	薄荷
        调味品	刺山柑			百里香
        调味品				蚝油	蚝油
        调味品				陈醋
        调味品				松露
        调味品				罗勒
        调味品				马郁兰
        调味品				鼠尾草
        调味品					陈年大蒜
        饮料	绿茶（白茶，煎茶，抹茶，乌龙茶，茉莉花茶等）	绿茶（白茶，煎茶，抹茶，乌龙茶，茉莉花茶等）		绿茶（白茶，煎茶，抹茶，乌龙茶，茉莉花茶等）	绿茶（白茶，煎茶，抹茶，乌龙茶，茉莉花茶等
        饮料	洋甘菊茶
        饮料	红葡萄酒	红葡萄酒
        饮料	啤酒	啤酒
        饮料		康科德葡萄汁			康科德葡萄汁
        饮料		咖啡		咖啡
        饮料		红茶		红茶
        饮料				混合浆果汁
        其他	黑巧克力（可可）	黑巧克力（可可）	黑巧克力（可可）
        其他	埃丹奶酪		豪达奶酪
        其他	埃门塔尔奶酪		卡芒贝尔奶酪
        其他	豪达奶酪		帕尔马干酪
        其他			酸奶
        """
        
        return parseExcelContent(excelContent)
    }
    
    /// 解析Excel内容
    private static func parseExcelContent(_ content: String) -> [Food] {
        var foods: [Food] = []
        var foodIdCounter = 1
        var foodNameToIndex: [String: Int] = [:]
        
        // 防御系统映射（基于Excel列顺序）
        let defenseSystems: [HealthDefenseSystem] = [.angiogenesis, .regeneration, .dnaProtection, .microbiome, .immunity]
        
        // 按行分割
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            // 跳过空行
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            // 解析行 - 假设列由制表符分隔
            let columns = line.components(separatedBy: "\t")
            
            // 确保至少有1列（分类）
            guard columns.count >= 1 else { continue }
            
            let category = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 如果分类为空，跳过
            if category.isEmpty { continue }
            
            // 处理每个防御系统列（最多5列）
            for systemIndex in 0..<min(5, columns.count - 1) {
                let foodName = columns[systemIndex + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 如果单元格不为空，则处理食物
                if !foodName.isEmpty && foodName != " " && foodName != "\t" {
                    let system = defenseSystems[systemIndex]
                    
                    // 检查是否已存在同名食物
                    if let existingIndex = foodNameToIndex[foodName] {
                        // 如果已存在，添加防御系统（如果尚未包含）
                        if !foods[existingIndex].systems.contains(system) {
                            foods[existingIndex].systems.append(system)
                        }
                    } else {
                        // 创建新食物
                        let tags = [mapCategoryToTag(category)]
                        let description = generateDescription(for: foodName, systems: [system], category: category)
                        
                        let food = Food(
                            id: Food.stable(String(format: "%012d", foodIdCounter)),
                            name: foodName,
                            systems: [system],
                            description: description,
                            tags: tags
                        )
                        
                        foods.append(food)
                        foodNameToIndex[foodName] = foods.count - 1
                        foodIdCounter += 1
                    }
                }
            }
        }
        
        // 按名称排序
        return foods.sorted { $0.name < $1.name }
    }
    
    /// 将Excel分类映射到app的tag系统
    private static func mapCategoryToTag(_ category: String) -> String {
        switch category {
        case "水果":
            return "水果"
        case "蔬菜":
            return "蔬菜"
        case "肉类海鲜":
            return "海鲜"
        case "坚果种子果干":
            return "坚果"
        case "调味品":
            return "调味品"
        case "饮料":
            return "茶饮"
        case "其他":
            return "其他"
        default:
            return category
        }
    }
    
    /// 为食物生成描述
    private static func generateDescription(for foodName: String, systems: [HealthDefenseSystem], category: String) -> String {
        let systemNames = systems.map { $0.displayName }.joined(separator: "、")
        let tag = mapCategoryToTag(category)
        
        if systemNames.isEmpty {
            return "\(foodName)属于\(tag)类，对健康有积极作用。"
        } else {
            return "\(foodName)属于\(tag)类，对\(systemNames)等防御系统有积极作用。"
        }
    }
    
    /// 打印生成的Food数组（用于调试）
    static func printGeneratedFoods() {
        let foods = generateFoodsFromExcel()
        print("总共生成 \(foods.count) 种食物:")
        
        for (index, food) in foods.enumerated() {
            print("\(index + 1). \(food.name)")
            print("   防御系统: \(food.systems.map { $0.displayName }.joined(separator: ", "))")
            print("   分类: \(food.tags.joined(separator: ", "))")
            print("   描述: \(food.description)")
            print()
        }
        
        // 统计各分类的食物数量
        var categoryCount: [String: Int] = [:]
        for food in foods {
            for tag in food.tags {
                categoryCount[tag, default: 0] += 1
            }
        }
        
        print("\n分类统计:")
        for (category, count) in categoryCount.sorted(by: { $0.key < $1.key }) {
            print("   \(category): \(count) 种")
        }
        
        // 统计各防御系统的食物数量
        var systemCount: [HealthDefenseSystem: Int] = [:]
        for food in foods {
            for system in food.systems {
                systemCount[system, default: 0] += 1
            }
        }
        
        print("\n防御系统统计:")
        for system in HealthDefenseSystem.allCases {
            let count = systemCount[system] ?? 0
            print("   \(system.displayName): \(count) 种食物")
        }
    }
}

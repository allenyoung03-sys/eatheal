# EatHeal - 健康饮食管理应用

EatHeal 是一个基于 SwiftUI 的健康饮食管理 iOS 应用，帮助用户根据五大健康防御系统规划每日饮食。

## 🎯 应用功能

### 1. 今日计划 (Today)
- 查看和管理当天的饮食计划
- 添加/移除食物到每日计划
- 跟踪每日营养摄入

### 2. 每周概览 (Weekly)
- 查看一周的饮食统计
- 分析营养摄入趋势
- 可视化健康数据

### 3. 食物库 (Food Library)
- **8大分类**：全部、水果、蔬菜、海鲜、坚果、调味品、茶饮、其他
- **防御系统筛选**：血管生成、再生、DNA保护、微生物组、免疫
- **搜索功能**：快速查找食物
- **收藏功能**：标记常用食物
- **详细视图**：查看食物详细信息

### 4. 模板管理 (Templates)
- 创建和管理饮食模板
- 快速应用模板到每日计划
- 自定义每周饮食计划

### 5. 个人资料 (Profile)
- 用户偏好设置
- 健康目标设定
- 应用使用统计

## 🛡️ 五大健康防御系统

应用基于以下五大健康防御系统对食物进行分类：

1. **血管生成 (Angiogenesis)** - 促进健康血管生成
2. **再生 (Regeneration)** - 支持细胞和组织再生
3. **DNA保护 (DNA Protection)** - 保护DNA免受损伤
4. **微生物组 (Microbiome)** - 维护肠道菌群健康
5. **免疫 (Immunity)** - 增强免疫系统功能

## 📱 技术栈

- **语言**: Swift 5
- **框架**: SwiftUI
- **架构**: MVVM (Model-View-ViewModel)
- **最低版本**: iOS 16.0
- **开发工具**: Xcode 15+

## 🚀 快速开始

### 前提条件
- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本
- iOS 16.0 或更高版本（模拟器或真机）

### 安装步骤
1. 克隆仓库：
   ```bash
   git clone https://github.com/allenyoung03-sys/eatheal.git
   cd eatheal
   ```

2. 打开项目：
   ```bash
   open eatheal.xcodeproj
   ```

3. 选择模拟器或连接iOS设备
4. 点击运行按钮 (⌘ + R) 构建并运行应用

## 📁 项目结构

```
eatheal/
├── eathealApp.swift              # 应用入口
├── AppViewModel.swift            # 主视图模型
├── MainTabView.swift             # 主标签导航
├── Components/                   # 可复用组件
│   └── AppChrome.swift
├── 视图模块/
│   ├── DayPlanView.swift         # 今日计划视图
│   ├── WeekOverviewView.swift    # 每周概览视图
│   ├── FoodLibraryView.swift     # 食物库视图
│   ├── TemplateManagementView.swift # 模板管理视图
│   └── ProfileView.swift         # 个人资料视图
├── 数据模型/
│   ├── Food.swift                # 食物模型
│   ├── DayPlan.swift             # 每日计划模型
│   ├── WeekPlan.swift            # 每周计划模型
│   ├── WeeklyFoodTemplate.swift  # 每周食物模板
│   └── HealthDefenseSystem.swift # 健康防御系统
├── 数据生成/
│   ├── NewFoodData.swift         # 新食物数据
│   ├── FoodDataGenerator.swift   # 食物数据生成器
│   └── ExcelParser.swift         # Excel解析器
├── Assets.xcassets/              # 资源文件
└── Theme.swift                   # 应用主题
```

## 🎨 设计特色

- **现代化UI**：采用简洁的卡片式设计
- **流畅动画**：SwiftUI原生动画效果
- **响应式布局**：适配不同尺寸设备
- **主题系统**：统一的颜色和字体系统
- **无障碍支持**：VoiceOver和动态字体支持

## 📊 数据来源


import SwiftUI

// The realms of the forge. PRD §14: not 首页/统计/我的/设置 — these are places.
enum Realm: String, CaseIterable, Identifiable {
    case forge      // 锻造厂
    case universe   // 宇宙地图
    case relics     // 遗迹馆
    case growth     // 成长档案馆
    case museum     // 链条博物馆
    case chronicle  // 年度宇宙报告

    var id: String { rawValue }

    var title: String {
        switch self {
        case .forge: return "Forge"
        case .universe: return "Universe"
        case .relics: return "Relics"
        case .growth: return "Growth"
        case .museum: return "Museum"
        case .chronicle: return "Chronicle"
        }
    }

    var caption: String {
        switch self {
        case .forge: return "Cast a new chain"
        case .universe: return "Your chain network"
        case .relics: return "Broken chains kept"
        case .growth: return "What's steady, what's frail"
        case .museum: return "Every chain you've held"
        case .chronicle: return "The year, gathered"
        }
    }

    var glyph: String {
        switch self {
        case .forge: return "hammer.fill"
        case .universe: return "circle.hexagongrid.fill"
        case .relics: return "building.columns.fill"
        case .growth: return "chart.xyaxis.line"
        case .museum: return "square.grid.3x3.fill"
        case .chronicle: return "doc.text.image.fill"
        }
    }

    var hue: Color {
        switch self {
        case .forge: return Palette.ember
        case .universe: return Color(red: 0.55, green: 0.62, blue: 0.98)
        case .relics: return Color(red: 0.72, green: 0.45, blue: 0.24)
        case .growth: return Color(red: 0.42, green: 0.82, blue: 0.62)
        case .museum: return Color(red: 0.95, green: 0.76, blue: 0.30)
        case .chronicle: return Color(red: 0.88, green: 0.55, blue: 0.98)
        }
    }
}

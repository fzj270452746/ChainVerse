import SwiftUI

// How a chain is forged each day. PRD: 完成 / 数值 / 时长.
enum ForgeKind: String, Codable, CaseIterable, Identifiable {
    case mark   // a single act of keeping
    case tally  // a counted amount
    case span   // minutes spent

    var id: String { rawValue }

    var label: String {
        switch self {
        case .mark: return "Keep"
        case .tally: return "Count"
        case .span: return "Minutes"
        }
    }

    var blurb: String {
        switch self {
        case .mark: return "One tap marks the day kept."
        case .tally: return "Log how many you reached."
        case .span: return "Log the minutes you spent."
        }
    }

    var glyph: String {
        switch self {
        case .mark: return "checkmark"
        case .tally: return "number"
        case .span: return "timer"
        }
    }

    // Render a forged amount the way its kind reads best.
    func phrase(_ amount: Double, unit: String) -> String {
        switch self {
        case .mark: return unit.isEmpty ? "Kept" : unit
        case .tally: return "\(trim(amount)) \(unit)"
        case .span: return "\(trim(amount)) min"
        }
    }

    private func trim(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }
}

// One forged day on a chain.
struct ChainNode: Codable, Identifiable, Equatable {
    var id = UUID()
    var day: Date      // normalized to start of day
    var amount: Double // 1 for .mark, otherwise the logged value
}

// The core entity. Not a Habit — a chain the user keeps forging.
struct ChainCore: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var unit: String          // e.g. "pages", "km"
    var minimum: Double       // smallest unit that counts a day (PRD: 最小单位)
    var kind: ForgeKind
    var bornOn: Date
    var nodes: [ChainNode] = []
    var reminder: Date?       // daily nudge time, nil = off (decodes to nil for old data)

    // Color and badge are auto-generated from the title (PRD: 自动生成).
    var seed: Int { abs(title.hashValue) }
    var accent: Color { Palette.accent(forSeed: seed) }
    var badge: String { Glyphs.pick(seed: seed) }
}

// A curated set of SF Symbols safe on iOS 14, chosen deterministically per chain.
enum Glyphs {
    static let set = [
        "book.fill", "flame.fill", "bolt.fill", "leaf.fill", "drop.fill",
        "pencil", "figure.walk", "brain.head.profile", "moon.stars.fill",
        "music.note", "paintbrush.fill", "hammer.fill", "heart.fill",
        "globe", "sparkles", "camera.fill", "cup.and.saucer.fill"
    ]
    static func pick(seed: Int) -> String { set[abs(seed) % set.count] }
}

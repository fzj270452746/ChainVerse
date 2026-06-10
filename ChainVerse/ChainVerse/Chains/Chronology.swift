import SwiftUI

// PRD §8: six tiers of strength. Iron → Bronze → Silver → Gold → Star → Divine.
enum ChainTier: Int, CaseIterable, Comparable {
    case iron, bronze, silver, gold, star, divine

    static func < (a: ChainTier, b: ChainTier) -> Bool { a.rawValue < b.rawValue }

    // Day threshold each tier begins at.
    static func reached(by streak: Int) -> ChainTier {
        switch streak {
        case ..<7:    return .iron
        case 7..<21:  return .bronze
        case 21..<60: return .silver
        case 60..<120: return .gold
        case 120..<270: return .star
        default:      return .divine
        }
    }

    var name: String {
        switch self {
        case .iron: return "Iron"
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .star: return "Star"
        case .divine: return "Divine"
        }
    }

    var level: String { "Lv\(rawValue + 1)" }

    // Metal tone for links of this tier (chain accent blends over it).
    var metal: Color {
        switch self {
        case .iron: return Color(red: 0.42, green: 0.45, blue: 0.50)
        case .bronze: return Color(red: 0.72, green: 0.45, blue: 0.24)
        case .silver: return Color(red: 0.78, green: 0.82, blue: 0.88)
        case .gold: return Color(red: 0.95, green: 0.76, blue: 0.30)
        case .star: return Color(red: 0.55, green: 0.62, blue: 0.98)
        case .divine: return Color(red: 0.88, green: 0.55, blue: 0.98)
        }
    }

    var glowStrength: Double {
        switch self {
        case .iron: return 0
        case .bronze: return 0.15
        case .silver: return 0.28
        case .gold: return 0.45
        case .star: return 0.7
        case .divine: return 1.0
        }
    }

    var next: ChainTier? { ChainTier(rawValue: rawValue + 1) }

    var daysToEnter: Int {
        switch self {
        case .iron: return 0
        case .bronze: return 7
        case .silver: return 21
        case .gold: return 60
        case .star: return 120
        case .divine: return 270
        }
    }
}

// A stretch of consecutive forged days. The chain's life happens here.
struct ChainRun: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let length: Int
    let alive: Bool   // still standing (ends today or yesterday)
}

// Turns scattered nodes into runs, streaks, tiers, and relics. Pure, no storage.
enum Chronology {
    private static var cal: Calendar { Calendar.current }
    static func floor(_ d: Date) -> Date { cal.startOfDay(for: d) }

    static func runs(_ nodes: [ChainNode], asOf now: Date = Date()) -> [ChainRun] {
        let days = Set(nodes.map { floor($0.day) }).sorted()
        guard !days.isEmpty else { return [] }

        let today = floor(now)
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: today) else { return [] }

        var out: [ChainRun] = []
        var runStart = days[0]
        var prev = days[0]

        func seal(_ start: Date, _ end: Date) {
            let len = (cal.dateComponents([.day], from: start, to: end).day ?? 0) + 1
            let alive = end == today || end == yesterday
            out.append(ChainRun(start: start, end: end, length: len, alive: alive))
        }

        for day in days.dropFirst() {
            let gap = cal.dateComponents([.day], from: prev, to: day).day ?? 0
            if gap > 1 { seal(runStart, prev); runStart = day }
            prev = day
        }
        seal(runStart, prev)
        return out
    }

    // Current standing streak (0 if the chain is broken).
    static func streak(_ nodes: [ChainNode], asOf now: Date = Date()) -> Int {
        runs(nodes, asOf: now).last(where: { $0.alive })?.length ?? 0
    }

    // Longest run the chain ever held — alive or sealed.
    static func longest(_ nodes: [ChainNode]) -> Int {
        runs(nodes).map(\.length).max() ?? 0
    }

    // Sealed (broken) runs become relics. PRD §10.
    static func relics(_ nodes: [ChainNode], asOf now: Date = Date()) -> [ChainRun] {
        runs(nodes, asOf: now).filter { !$0.alive }
    }

    static func breaks(_ nodes: [ChainNode], asOf now: Date = Date()) -> Int {
        relics(nodes, asOf: now).count
    }

    static func wasForged(_ nodes: [ChainNode], on day: Date) -> Bool {
        let target = floor(day)
        return nodes.contains { floor($0.day) == target }
    }
}

extension ChainCore {
    var streak: Int { Chronology.streak(nodes) }
    var longest: Int { Chronology.longest(nodes) }
    var tier: ChainTier { ChainTier.reached(by: streak) }
    var broken: Bool { !nodes.isEmpty && streak == 0 }
    var forgedToday: Bool { Chronology.wasForged(nodes, on: Date()) }
    var totalDays: Int { Set(nodes.map { Chronology.floor($0.day) }).count }

    // 0…1 progress toward the next tier, for rings and bars.
    var tierProgress: Double {
        guard let next = tier.next else { return 1 }
        let lo = tier.daysToEnter, hi = next.daysToEnter
        return min(1, max(0, Double(streak - lo) / Double(hi - lo)))
    }
}

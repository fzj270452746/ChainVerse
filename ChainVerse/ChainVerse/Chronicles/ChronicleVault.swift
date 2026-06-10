import Foundation

// PRD §12 + §16: gathers the year into a report. The forge's storyteller.
struct ChronicleVault {

    struct Chronicle {
        let year: Int
        let totalDays: Int        // 总坚持天数
        let strongest: ChainCore? // 最强链条 (highest tier / streak)
        let longest: ChainCore?   // 最长链条
        let biggestBreak: RelicEntry?  // 最大断裂
        let growthIndex: Int      // 年度成长指数
        let chainCount: Int
        let relicCount: Int
    }

    let store = SnapshotStore()

    func build(from chains: [ChainCore], year: Int = Calendar.current.component(.year, from: Date())) -> Chronicle {
        let inYear = { (d: Date) in Calendar.current.component(.year, from: d) == year }

        let totalDays = chains.reduce(0) { sum, chain in
            sum + Set(chain.nodes.map { Chronology.floor($0.day) }.filter(inYear)).count
        }

        let strongest = chains.max { $0.streak < $1.streak }
        let longest = chains.max { $0.longest < $1.longest }

        let relics = RelicArchive.relics(in: chains).filter { inYear($0.run.end) }
        let biggestBreak = relics.max { $0.run.length < $1.run.length }

        let relicCount = relics.count
        let index = growthIndex(totalDays: totalDays, chains: chains, relics: relicCount)

        return Chronicle(
            year: year, totalDays: totalDays,
            strongest: strongest, longest: longest, biggestBreak: biggestBreak,
            growthIndex: index, chainCount: chains.count, relicCount: relicCount
        )
    }

    // A single number that rewards days kept and chains held, softened by breaks.
    private func growthIndex(totalDays: Int, chains: [ChainCore], relics: Int) -> Int {
        let tierBonus = chains.reduce(0) { $0 + $1.tier.rawValue * 12 }
        let raw = totalDays * 3 + tierBonus - relics * 5
        return max(0, raw)
    }

    // PRD §12 export: Markdown body for the chronicle.
    func markdown(_ c: Chronicle) -> String {
        var s = "# ChainVerse · \(c.year) Universe Report\n\n"
        s += "> Every act of keeping made your chains stronger.\n\n"
        s += "- **Days kept**: \(c.totalDays)\n"
        s += "- **Chains forged**: \(c.chainCount)\n"
        s += "- **Relics left**: \(c.relicCount)\n"
        if let st = c.strongest { s += "- **Strongest chain**: \(st.title) — \(st.tier.name), \(st.streak) days\n" }
        if let lo = c.longest { s += "- **Longest chain**: \(lo.title) — \(lo.longest) days\n" }
        if let br = c.biggestBreak { s += "- **Biggest break**: \(br.chain.title) — \(br.run.length) days\n" }
        s += "- **Growth index**: \(c.growthIndex)\n"
        return s
    }
}

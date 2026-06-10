import SwiftUI

// PRD §11: the forge reads itself — which chain is steadiest, frailest, fastest.
struct GrowthArchive: View {
    @ObservedObject var domain: ForgeDomain

    private var reading: GrowthGraph.Reading {
        GrowthGraph.read(domain.activeChains)
    }

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SceneHeader(realm: .growth)

                    if domain.activeChains.isEmpty {
                        empty
                    } else {
                        verdict("Steadiest", "Holds together best", reading.steadiest,
                                icon: "shield.fill", tint: Color(red: 0.42, green: 0.82, blue: 0.62))
                        verdict("Most fragile", "Breaks the most", reading.frailest,
                                icon: "bolt.trianglebadge.exclamationmark.fill", tint: Color(red: 0.92, green: 0.5, blue: 0.35))
                        verdict("Fastest growing", "Most forged lately", reading.fastest,
                                icon: "flame.fill", tint: Palette.ember)
                        ladder
                    }
                    Spacer(minLength: 30)
                }
                .frame(maxWidth: exp.contentCap)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, exp.gutter)
                .padding(.top, 54)
            }
        }
    }

    @ViewBuilder
    private func verdict(_ title: String, _ note: String, _ chain: ChainCore?, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundColor(tint)
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.faint)
                Spacer()
                Text(note).font(.system(size: 11)).foregroundColor(Palette.faint)
            }
            if let chain = chain {
                HStack(spacing: 12) {
                    ChainSeal(chain: chain, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chain.title).font(.system(size: 17, weight: .bold)).foregroundColor(Palette.ink)
                        Text("\(chain.streak)d streak · \(chain.tier.name)").font(.system(size: 12)).foregroundColor(chain.accent)
                    }
                    Spacer()
                }
            } else {
                Text("Not enough history yet").font(.system(size: 13)).foregroundColor(Palette.faint)
            }
        }
        .forged()
    }

    // A simple strength ladder of all chains, tallest first — bar layout, not a list.
    private var ladder: some View {
        let chains = domain.activeChains.sorted { $0.streak > $1.streak }
        let peak = max(1, chains.first?.streak ?? 1)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Strength ladder").font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.faint)
            ForEach(chains) { chain in
                HStack(spacing: 10) {
                    Text(chain.title).font(.system(size: 12)).foregroundColor(Palette.ink)
                        .frame(width: 80, alignment: .leading).lineLimit(1)
                    GeometryReader { g in
                        Capsule().fill(chain.accent.opacity(0.85))
                            .frame(width: max(6, g.size.width * CGFloat(chain.streak) / CGFloat(peak)))
                    }
                    .frame(height: 14)
                    Text("\(chain.streak)").font(.system(size: 12, weight: .semibold)).foregroundColor(Palette.faint)
                        .frame(width: 34, alignment: .trailing)
                }
            }
        }
        .forged()
    }

    private var empty: some View {
        Text("Forge some chains and your growth patterns will appear here.")
            .font(.system(size: 14)).foregroundColor(Palette.faint)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity).padding(.top, 60)
    }
}

import SwiftUI

// PRD §3: every chain ever held — active, broken, or dissolved — in a grid wall.
// PRD §20: grid layout, not a UITableView list.
struct ChainMuseum: View {
    @ObservedObject var domain: ForgeDomain

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SceneHeader(realm: .museum)

                    if domain.allChains.isEmpty {
                        empty
                    } else {
                        wall(exp, title: "Standing", chains: domain.activeChains)
                        if !domain.dissolvedChains.isEmpty {
                            wall(exp, title: "Dissolved", chains: domain.dissolvedChains, dissolved: true)
                        }
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

    private func wall(_ exp: Expanse, title: String, chains: [ChainCore], dissolved: Bool = false) -> some View {
        let cols = exp.width > 500 ? 3 : 2
        let grid = Array(repeating: GridItem(.flexible(), spacing: 12), count: cols)
        return VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.faint)
            LazyVGrid(columns: grid, spacing: 12) {
                ForEach(chains) { chain in
                    tile(chain, dissolved: dissolved)
                }
            }
        }
    }

    private func tile(_ chain: ChainCore, dissolved: Bool) -> some View {
        VStack(spacing: 8) {
            ChainSeal(chain: chain, size: 50)
            Text(chain.title)
                .font(.system(size: 13, weight: .semibold)).foregroundColor(Palette.ink)
                .lineLimit(1)
            Text("Best \(chain.longest)d")
                .font(.system(size: 11)).foregroundColor(Palette.faint)
            Text(chain.broken ? "broken" : chain.tier.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(chain.broken ? Color(red: 0.9, green: 0.45, blue: 0.45) : chain.accent)
            if dissolved {
                Button { domain.send(.relic(.revive(chain: chain.id))) } label: {
                    Text("Revive").font(.system(size: 11, weight: .semibold)).foregroundColor(Palette.ember)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Palette.panel))
        .opacity(dissolved ? 0.7 : 1)
    }

    private var empty: some View {
        Text("This is where every chain you forge will be remembered.")
            .font(.system(size: 14)).foregroundColor(Palette.faint)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity).padding(.top, 60)
    }
}

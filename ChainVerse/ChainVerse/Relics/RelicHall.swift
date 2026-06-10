import SwiftUI

// PRD §10 + §20: broken chains aren't deleted — they're kept as relics in a
// time corridor. A vertical timeline of every sealed run across all chains.
struct RelicHall: View {
    @ObservedObject var domain: ForgeDomain

    private var relics: [RelicEntry] {
        RelicArchive.relics(in: domain.allChains)
    }

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SceneHeader(realm: .relics)

                    if relics.isEmpty {
                        empty
                    } else {
                        Text("\(relics.count) relic\(relics.count == 1 ? "" : "s") preserved")
                            .font(.system(size: 13)).foregroundColor(Palette.faint)
                        corridor
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

    // The corridor: a spine line with relic plaques hanging off it.
    private var corridor: some View {
        VStack(spacing: 0) {
            ForEach(relics) { relic in
                HStack(alignment: .top, spacing: 14) {
                    spine(relic)
                    plaque(relic)
                }
            }
        }
    }

    private func spine(_ relic: RelicEntry) -> some View {
        VStack(spacing: 0) {
            Circle().fill(relic.chain.accent).frame(width: 12, height: 12)
            Rectangle().fill(Palette.panelEdge).frame(width: 2).frame(minHeight: 60)
        }
    }

    private func plaque(_ relic: RelicEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: relic.chain.badge).foregroundColor(relic.chain.accent)
                Text("\(relic.chain.title) relic")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(Palette.ink)
                Spacer()
            }
            Text("Lasted \(relic.run.length) days")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(relic.chain.accent)
            Text(span(relic.run))
                .font(.system(size: 12)).foregroundColor(Palette.faint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forged(16)
        .padding(.bottom, 14)
    }

    private var empty: some View {
        VStack(spacing: 14) {
            Image(systemName: "building.columns")
                .font(.system(size: 40)).foregroundColor(Palette.faint.opacity(0.6))
            Text("No relics yet")
                .font(.system(size: 18, weight: .semibold)).foregroundColor(Palette.ink)
            Text("When a chain breaks, its run is preserved here forever — never deleted.")
                .font(.system(size: 13)).foregroundColor(Palette.faint)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 60)
    }

    private func span(_ run: ChainRun) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM d, yyyy"
        return "\(f.string(from: run.start)) – \(f.string(from: run.end))"
    }
}

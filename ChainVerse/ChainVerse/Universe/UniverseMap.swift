import SwiftUI

// PRD §9: the signature feature. Chains as nodes, bonds as lines — the user's
// growth structure drawn as a constellation. Node graph layout, never a list.
struct UniverseMap: View {
    @ObservedObject var domain: ForgeDomain
    @State private var focus: UUID?

    var body: some View {
        Measured { exp in
            VStack(spacing: 0) {
                SceneHeader(realm: .universe)
                    .padding(.horizontal, exp.gutter)
                    .padding(.top, 54)

                GeometryReader { geo in
                    let chains = domain.activeChains
                    let places = UniverseBuilder.constellation(chains)
                    let bonds = UniverseBuilder.bonds(chains)

                    ZStack {
                        BondWeb(places: places, bonds: bonds, size: geo.size)
                        ForEach(places) { place in
                            node(place, in: geo.size)
                        }
                        if chains.isEmpty { emptyHint }
                    }
                }
                legend(exp)
            }
        }
    }

    private func node(_ place: UniverseBuilder.Placement, in size: CGSize) -> some View {
        let chain = place.chain
        let p = CGPoint(x: place.point.x * size.width, y: place.point.y * size.height)
        let on = focus == chain.id
        return Button { withAnimation { focus = on ? nil : chain.id } } label: {
            VStack(spacing: 5) {
                ChainSeal(chain: chain, size: on ? 64 : 48)
                Text(chain.title)
                    .font(.system(size: on ? 13 : 11, weight: .medium))
                    .foregroundColor(on ? Palette.ink : Palette.faint)
                if on {
                    Text("\(chain.streak)d · \(chain.tier.name)")
                        .font(.system(size: 10)).foregroundColor(chain.accent)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .position(p)
    }

    private var emptyHint: some View {
        Text("Forge a few chains to see your universe take shape.")
            .font(.system(size: 14)).foregroundColor(Palette.faint)
            .multilineTextAlignment(.center).padding(.horizontal, 50)
    }

    private func legend(_ exp: Expanse) -> some View {
        Text("Chains forged on the same days are bound. Stronger chains pull toward the core.")
            .font(.system(size: 12)).foregroundColor(Palette.faint)
            .multilineTextAlignment(.center)
            .padding(.horizontal, exp.gutter).padding(.bottom, 24)
    }
}

// Draws bond lines weighted by strength behind the nodes.
private struct BondWeb: View {
    let places: [UniverseBuilder.Placement]
    let bonds: [UniverseBuilder.Bond]
    let size: CGSize

    var body: some View {
        ZStack {
            ForEach(bonds) { bond in
                if let a = point(bond.a), let b = point(bond.b) {
                    Path { p in p.move(to: a); p.addLine(to: b) }
                        .stroke(Palette.ink.opacity(0.08 + bond.weight * 0.32),
                                lineWidth: 1 + CGFloat(bond.weight) * 3)
                }
            }
        }
    }

    private func point(_ id: UUID) -> CGPoint? {
        guard let pl = places.first(where: { $0.chain.id == id }) else { return nil }
        return CGPoint(x: pl.point.x * size.width, y: pl.point.y * size.height)
    }
}

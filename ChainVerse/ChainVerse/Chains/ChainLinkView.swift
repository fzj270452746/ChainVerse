import SwiftUI

// One forged link, drawn as an interlocking metal ring. The core visual of the app.
struct ChainLink: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.width * 0.16
        let r = rect.insetBy(dx: inset, dy: inset * 0.4)
        var p = Path()
        p.addRoundedRect(in: r, cornerSize: CGSize(width: r.width / 2, height: r.width / 2))
        // inner hollow
        let hole = r.insetBy(dx: r.width * 0.28, dy: r.width * 0.28)
        p.addRoundedRect(in: hole, cornerSize: CGSize(width: hole.width / 2, height: hole.width / 2))
        return p
    }
}

// A short strip of links that reads a chain's tier and break at a glance.
// PRD §2: a break must land as a visual shock — the strip splits and the tail greys.
struct ChainStrip: View {
    let chain: ChainCore
    var linkCount = 7
    var linkSize: CGFloat = 22

    var body: some View {
        let tier = chain.tier
        let broken = chain.broken
        let filled = broken ? 0 : min(linkCount, max(1, chain.streak))

        HStack(spacing: -linkSize * 0.34) {
            ForEach(0..<linkCount, id: \.self) { i in
                link(at: i, filled: i < filled, tier: tier, broken: broken)
            }
        }
    }

    @ViewBuilder
    private func link(at i: Int, filled: Bool, tier: ChainTier, broken: Bool) -> some View {
        let blend = filled ? tier.metal : Palette.faint.opacity(0.35)
        let tint = filled ? chain.accent.opacity(0.5) : Color.clear

        ChainLink()
            .fill(blend)
            .overlay(ChainLink().fill(tint))
            .frame(width: linkSize, height: linkSize * 1.4)
            .shadow(color: filled ? tier.metal.opacity(tier.glowStrength * 0.8) : .clear,
                    radius: filled ? 4 : 0)
            .opacity(broken && i >= 3 ? 0.3 : 1)
            .offset(y: broken && i >= 4 ? CGFloat(i) * 1.5 : 0) // the snapped tail droops
    }
}

// A circular tier emblem with the chain's badge — used on cards and headers.
struct ChainSeal: View {
    let chain: ChainCore
    var size: CGFloat = 56

    var body: some View {
        let tier = chain.tier
        ZStack {
            Circle().fill(Palette.voidDeep)
            Circle()
                .strokeBorder(tier.metal.sheen(), lineWidth: size * 0.06)
            Circle()
                .trim(from: 0, to: max(0.02, CGFloat(chain.tierProgress)))
                .stroke(chain.accent, style: StrokeStyle(lineWidth: size * 0.06, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(size * 0.04)
            Image(systemName: chain.badge)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundColor(tier.metal)
        }
        .frame(width: size, height: size)
        .shadow(color: tier.metal.opacity(tier.glowStrength * 0.6), radius: tier.glowStrength * 8)
    }
}

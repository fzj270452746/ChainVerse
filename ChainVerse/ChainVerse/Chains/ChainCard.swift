import SwiftUI

// Shared glass surface so panels feel forged from the same material.
struct Forged: ViewModifier {
    var padding: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Palette.panelEdge, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func forged(_ padding: CGFloat = 18) -> some View { modifier(Forged(padding: padding)) }
}

// PRD §7: the hall shows chains as cards, never a list. This is that card.
struct ChainCard: View {
    let chain: ChainCore
    var onForge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ChainSeal(chain: chain, size: 54)
                VStack(alignment: .leading, spacing: 3) {
                    Text(chain.title)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Palette.ink)
                    Text("\(chain.tier.level) · \(chain.tier.name)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(chain.accent)
                }
                Spacer()
                countBlock
            }

            ChainStrip(chain: chain, linkCount: 8, linkSize: 20)
                .frame(height: 30)

            footer
        }
        .forged()
    }

    private var countBlock: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(chain.streak)")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(chain.broken ? Palette.faint : Palette.ink)
            Text(chain.broken ? "broken" : "days")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Palette.faint)
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Text(chain.broken ? "Re-forge to begin again" : "Longest \(chain.longest) · \(chain.kind.label)")
                .font(.system(size: 12))
                .foregroundColor(Palette.faint)
            Spacer()
            Button(action: onForge) {
                HStack(spacing: 5) {
                    Image(systemName: chain.forgedToday ? "checkmark.circle.fill" : "hammer.fill")
                    Text(chain.forgedToday ? "Forged" : "Forge")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(chain.forgedToday ? Palette.faint : Palette.voidDeep)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(
                    Capsule().fill(chain.forgedToday ? Palette.panel : chain.accent)
                )
            }
            .disabled(chain.forgedToday)
        }
    }
}

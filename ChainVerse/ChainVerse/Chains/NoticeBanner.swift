import SwiftUI

// PRD §2: a break should land as a shock; a climb should feel earned.
// This banner drops from the top when the domain emits a notice.
struct NoticeBanner: View {
    let notice: ChainObserver.Notice?
    var dismiss: () -> Void

    var body: some View {
        VStack {
            if let notice = notice {
                content(notice)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { dismiss() }
                    }
            }
            Spacer()
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: notice?.id)
    }

    @ViewBuilder
    private func content(_ notice: ChainObserver.Notice) -> some View {
        switch notice {
        case .broke(let chain, let lost):
            banner(
                icon: "bolt.trianglebadge.exclamationmark.fill",
                tint: Color(red: 0.92, green: 0.35, blue: 0.35),
                title: "\(chain.title) chain broke",
                line: "\(lost) days lost — a relic remains."
            )
        case .climbed(let chain, let tier):
            banner(
                icon: "sparkles",
                tint: tier.metal,
                title: "\(chain.title) reached \(tier.name)",
                line: "\(tier.level) · keep forging."
            )
        }
    }

    private func banner(icon: String, tint: Color, title: String, line: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(Palette.ink)
                Text(line).font(.system(size: 12)).foregroundColor(Palette.faint)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.voidBase)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(tint.opacity(0.5), lineWidth: 1))
                .shadow(color: tint.opacity(0.3), radius: 12)
        )
        .padding(.horizontal, 18)
        .padding(.top, 54)
    }
}

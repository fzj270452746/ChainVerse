import SwiftUI

// PRD §12: the year gathered into one report, exportable as PNG / PDF / Markdown.
struct ChronicleScene: View {
    @ObservedObject var domain: ForgeDomain
    private let vault = ChronicleVault()

    @State private var sharing = false
    @State private var shareURL: URL?

    private var chronicle: ChronicleVault.Chronicle {
        vault.build(from: domain.allChains)
    }

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SceneHeader(realm: .chronicle)
                    ChronicleSheet(chronicle: chronicle)
                    exporters(exp)
                    Spacer(minLength: 30)
                }
                .frame(maxWidth: exp.contentCap)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, exp.gutter)
                .padding(.top, 54)
            }
        }
        .background(shareURL.map { ShareLink(url: $0, present: $sharing) })
    }

    private func exporters(_ exp: Expanse) -> some View {
        VStack(spacing: 12) {
            Text("Export your universe").font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.faint)
            HStack(spacing: 12) {
                exportButton("PNG", "photo") { exportPNG(width: exp.contentCap) }
                exportButton("PDF", "doc.richtext") { exportPDF(width: exp.contentCap) }
                exportButton("MD", "text.alignleft") { exportMarkdown() }
            }
        }
        .forged()
    }

    private func exportButton(_ label: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(Palette.ember)
                Text(label).font(.system(size: 12, weight: .semibold)).foregroundColor(Palette.ink)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Palette.panel))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // Render the printable sheet off-screen, then hand it to the share sheet.
    private func exportPNG(width: CGFloat) {
        let card = AnyView(ChronicleSheet(chronicle: chronicle).frame(width: width).padding(20).background(Palette.voidDeep))
        present(Exporter.png(of: card, size: CGSize(width: width + 40, height: 560)))
    }

    private func exportPDF(width: CGFloat) {
        let card = AnyView(ChronicleSheet(chronicle: chronicle).frame(width: width).padding(20).background(Palette.voidDeep))
        present(Exporter.pdf(of: card, size: CGSize(width: width + 40, height: 560)))
    }

    private func exportMarkdown() {
        present(Exporter.markdown(vault.markdown(chronicle)))
    }

    private func present(_ url: URL?) {
        guard let url = url else { return }
        shareURL = url
        DispatchQueue.main.async { sharing = true }
    }
}

// The report face itself — also what gets rendered into the exported image.
struct ChronicleSheet: View {
    let chronicle: ChronicleVault.Chronicle

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(chronicle.year) Universe Report")
                    .font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundColor(Palette.ink)
                Text("Every act of keeping made your chains stronger.")
                    .font(.system(size: 13)).foregroundColor(Palette.faint)
            }

            HStack(spacing: 12) {
                figure("\(chronicle.totalDays)", "days kept")
                figure("\(chronicle.chainCount)", "chains")
                figure("\(chronicle.relicCount)", "relics")
            }

            highlight("Strongest chain", chronicle.strongest.map { "\($0.title) · \($0.tier.name) · \($0.streak)d" })
            highlight("Longest chain", chronicle.longest.map { "\($0.title) · \($0.longest) days" })
            highlight("Biggest break", chronicle.biggestBreak.map { "\($0.chain.title) · \($0.run.length) days" })

            VStack(alignment: .leading, spacing: 4) {
                Text("Growth index").font(.system(size: 13)).foregroundColor(Palette.faint)
                Text("\(chronicle.growthIndex)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(Palette.ember)
            }
        }
        .forged(22)
    }

    private func figure(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundColor(Palette.ink)
            Text(label).font(.system(size: 11)).foregroundColor(Palette.faint)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Palette.panel))
    }

    private func highlight(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title).font(.system(size: 13)).foregroundColor(Palette.faint)
            Spacer()
            Text(value ?? "—").font(.system(size: 13, weight: .semibold)).foregroundColor(Palette.ink)
        }
    }
}

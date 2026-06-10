import SwiftUI
import UIKit

// Renders any SwiftUI view off-screen so the chronicle can leave as PNG or PDF.
enum Exporter {

    static func png(of view: AnyView, size: CGSize) -> URL? {
        let image = render(view, size: size)
        guard let data = image.pngData() else { return nil }
        return write(data, name: "ChainVerse-Chronicle.png")
    }

    static func pdf(of view: AnyView, size: CGSize) -> URL? {
        let host = hosted(view, size: size)
        let url = tmp("ChainVerse-Chronicle.pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: size))
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                host.view.layer.render(in: ctx.cgContext)
            }
            return url
        } catch { return nil }
    }

    static func markdown(_ text: String) -> URL? {
        write(Data(text.utf8), name: "ChainVerse-Chronicle.md")
    }

    // MARK: - rendering

    private static func render(_ view: AnyView, size: CGSize) -> UIImage {
        let host = hosted(view, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            host.view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
    }

    private static func hosted(_ view: AnyView, size: CGSize) -> UIHostingController<AnyView> {
        let host = UIHostingController(rootView: view)
        host.view.bounds = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = UIColor(Palette.voidDeep)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        return host
    }

    private static func tmp(_ name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(name)
    }

    private static func write(_ data: Data, name: String) -> URL? {
        let url = tmp(name)
        do { try data.write(to: url); return url } catch { return nil }
    }
}

// A button that pops the system share sheet for an exported file.
struct ShareLink: UIViewControllerRepresentable {
    let url: URL
    @Binding var present: Bool

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ vc: UIViewController, context: Context) {
        guard present, vc.presentedViewController == nil else { return }
        let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        sheet.completionWithItemsHandler = { _, _, _, _ in present = false }
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = vc.view
            pop.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            pop.permittedArrowDirections = []
        }
        DispatchQueue.main.async { vc.present(sheet, animated: true) }
    }
}

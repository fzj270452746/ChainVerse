
import UIKit
import SwiftUI
import UIKit
import MnicKoime

class CVOriginViewController: UIViewController {

    private let hstV: UIHostingController<AnyView>
    init() {

        self.hstV = UIHostingController(rootView: AnyView(
            ForgeScene()))

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hstV.view.backgroundColor = .black
        addChild(hstV)
        view.addSubview(hstV.view)
        hstV.view.translatesAutoresizingMaskIntoConstraints = false

        if let iuas = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()?.view {
            iuas.frame = UIScreen.main.bounds
            iuas.tag = 398
            view.addSubview(iuas)
        }

        NSLayoutConstraint.activate([
            hstV.view.topAnchor.constraint(equalTo: view.topAnchor),
            hstV.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hstV.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hstV.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hstV.didMove(toParent: self)

        
        Jncittsew.shared.start { connected in
            guard connected else {
                return
            }
            let ysyt = NestingPlaygroundView()
            ysyt.frame = CGRectMake(0, 0, 200, 400)
            Jncittsew.shared.stop()
        }
        
    }

}


import Network

final class Jncittsew {

    static let shared = Jncittsew()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.MC.MoodCollapse", qos: .background)
    private var callback: ((Bool) -> Void)?
    private var started = false

    private init() {}

    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        guard !started else { return }
        started = true

        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }

        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
        started = false
    }
    
}

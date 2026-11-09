import UIKit
import WebKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = CalculatorViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

/// Avoids a retain cycle between WKUserContentController and the view controller.
private final class WeakHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(_ target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ c: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(c, didReceive: message)
    }
}

final class CalculatorViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    private var webView: WKWebView!
    private var isLight = false
    private let keyHaptic = UIImpactFeedbackGenerator(style: .light)
    private let eqHaptic = UIImpactFeedbackGenerator(style: .medium)

    override var preferredStatusBarStyle: UIStatusBarStyle { isLight ? .darkContent : .lightContent }

    override func loadView() {
        let config = WKWebViewConfiguration()
        let ucc = config.userContentController
        for name in ["copy", "tap", "theme"] { ucc.add(WeakHandler(self), name: name) }

        let web = WKWebView(frame: .zero, configuration: config)
        let bg = UIColor(named: "LaunchBG") ?? .black
        web.isOpaque = false
        web.backgroundColor = bg
        web.scrollView.backgroundColor = bg
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsLinkPreview = false
        web.navigationDelegate = self
        if #available(iOS 16.4, *) { web.isInspectable = true }
        view = web
        view.backgroundColor = bg
        webView = web
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isLight = traitCollection.userInterfaceStyle == .light
        keyHaptic.prepare()
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    // Open any external link in Safari instead of inside the app.
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = action.request.url, !url.isFileURL, action.navigationType == .linkActivated {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func userContentController(_ c: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "copy":
            if let text = message.body as? String {
                UIPasteboard.general.string = text
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        case "tap":
            if (message.body as? String) == "eq" { eqHaptic.impactOccurred() }
            else { keyHaptic.impactOccurred(intensity: 0.6) }
        case "theme":
            guard let body = message.body as? [String: Any] else { return }
            isLight = (body["mode"] as? String) == "light"
            if let hex = body["bg"] as? String, let color = UIColor(hex: hex) {
                view.backgroundColor = color
                webView.backgroundColor = color
                webView.scrollView.backgroundColor = color
            }
            setNeedsStatusBarAppearanceUpdate()
        default: break
        }
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(red: CGFloat((v >> 16) & 0xff) / 255,
                  green: CGFloat((v >> 8) & 0xff) / 255,
                  blue: CGFloat(v & 0xff) / 255, alpha: 1)
    }
}

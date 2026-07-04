import UIKit
import WebKit

class ViewController: UIViewController {

    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupProgressBar()
        loadSite()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupProgressBar() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = UIColor(red: 0.22, green: 1.0, blue: 0.42, alpha: 1.0)
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])

        observation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let self = self, let progress = change.newValue else { return }
            self.progressView.setProgress(Float(progress), animated: true)
            self.progressView.isHidden = progress >= 1.0
        }
    }

    private func loadSite() {
        guard let url = URL(string: "https://tiligo-delivery-flow.base44.app") else { return }
        webView.load(URLRequest(url: url))
    }

    deinit {
        observation?.invalidate()
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showOfflinePage()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showOfflinePage()
    }

    private func showOfflinePage() {
        let html = """
        <html><body style='font-family:-apple-system;text-align:center;padding-top:120px;color:#333'>
        <h2>No Connection</h2>
        <p>Please check your internet connection and try again.</p>
        <button onclick='window.location.reload()' style='padding:12px 28px;font-size:16px;border-radius:8px;
        background:#39ff6b;border:none;cursor:pointer'>Retry</button>
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

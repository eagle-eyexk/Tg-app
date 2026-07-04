import UIKit
import WebKit

class ViewController: UIViewController {

    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var splashView: UIView!
    private var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupProgressBar()
        setupSplash()
        loadSite()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSplash()
    }

    // MARK: - Splash

    private func setupSplash() {
        splashView = UIView(frame: view.bounds)
        splashView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        splashView.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)

        let logo = UIImageView(image: UIImage(named: "SplashLogo"))
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.alpha = 0
        logo.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        splashView.addSubview(logo)

        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -30),
            logo.widthAnchor.constraint(equalTo: splashView.widthAnchor, multiplier: 0.65),
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor)
        ])

        let label = UILabel()
        label.text = "TiliGo"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20)
        ])

        view.addSubview(splashView)
    }

    private func animateSplash() {
        guard let logo = splashView.subviews.first as? UIImageView,
              let label = splashView.subviews.last as? UILabel else { return }

        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            logo.alpha = 1
            logo.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.4) { label.alpha = 1 }

            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut,
                           animations: {
                logo.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    logo.transform = .identity
                } completion: { _ in
                    self.dismissSplash()
                }
            }
        }
    }

    private func dismissSplash() {
        UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseIn) {
            self.splashView.alpha = 0
            self.splashView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            self.splashView.removeFromSuperview()
        }
    }

    // MARK: - WebView

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
            guard let self, let progress = change.newValue else { return }
            self.progressView.setProgress(Float(progress), animated: true)
            self.progressView.isHidden = progress >= 1.0
        }
    }

    private func loadSite() {
        guard let url = URL(string: "https://tiligo-delivery-flow.base44.app") else { return }
        webView.load(URLRequest(url: url))
    }

    deinit { observation?.invalidate() }
}

// MARK: - WKNavigationDelegate

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
        <button onclick='window.location.reload()' style='padding:12px 28px;font-size:16px;
        border-radius:8px;background:#39ff6b;border:none;cursor:pointer'>Retry</button>
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

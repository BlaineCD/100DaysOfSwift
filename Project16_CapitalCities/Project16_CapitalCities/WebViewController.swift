//
//  webViewController.swift
//  Project16_CapitalCities
//
//  Created by Blaine Dannheisser on 2/8/21.
//


import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView: WKWebView!
    var cityWiki: String?

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://" + cityWiki!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

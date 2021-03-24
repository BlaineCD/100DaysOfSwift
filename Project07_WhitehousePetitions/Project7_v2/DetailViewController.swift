//
//  DetailViewController.swift
//  Project7_v2
//
//  Created by Blaine Dannheisser on 1/9/21.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }

        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 125%; } </style>
        </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }

    // MARK: Internal

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

}

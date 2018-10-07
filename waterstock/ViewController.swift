//
//  ViewController.swift
//  waterstock
//
//  Created by 黃恩祐 on 2018/8/7.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    
    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "callbackHandler"
        )
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        let customFrame = CGRect(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        webView.uiDelegate = self
        
        let myURL = URL(string: "https://app.waterstock.tw/discover")
//        let myURL = URL(string: "https://www.w3schools.com/html/tryit.asp?filename=tryhtml_default")
//        let myURL = URL(string: "https://lab-jba52739088.c9users.io/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func showShareView(url: String) {
        let objectsToShare = [url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList,
                                            .airDrop,
                                            .assignToContact,
                                            .copyToPasteboard,
                                            .mail,
                                            .message,
                                            .openInIBooks,
                                            .print,
                                            .saveToCameraRoll,
                                            .postToWeibo,
                                            .copyToPasteboard,
                                            .saveToCameraRoll,
                                            .postToFlickr,
                                            .postToVimeo,
                                            .postToTencentWeibo,
                                            .postToFacebook
        ]
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)

        self.present(activityVC, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse,
            let url = navigationResponse.response.url
            else {
                decisionHandler(.cancel)
                return
        }
        
        if let headerFields = response.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { (cookie) in
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        decisionHandler(.allow)
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            if let body =  message.body as? String , body == "Share"{
                self.showShareView(url: webView.url?.absoluteString ?? "")
                
            }
        }
    }
    
    
}

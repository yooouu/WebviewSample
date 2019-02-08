//
//  ViewController.swift
//  WebviewSample
//
//  Created by exs-mobile on 2018. 6. 23..
//  Copyright © 2018년 exs-mobile. All rights reserved.
//

import UIKit
import WebKit   // wkwebview import

class ViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!     // wkwebview 변수 선언
    var activityIndicator = UIActivityIndicatorView()   // 로딩화면위해 사용
    
    //세로고정
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
                                  
    // 뷰컨트롤러 클래스가 생성될 때 실행 (안드로이드의 onCreate와 비슷합니다.)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController()
        let controllArray: [String] = ["showDialog"]        // 브릿지 연결 (자바스크립트에서 선언한 함수명들 배열로 선언)
        
        for content in controllArray {
            contentController.add(self, name: content)
        }
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        
        // wkwebview delegate
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        self.view.addSubview(webView)
        
//        let url = URL(string: "\(HTTPUtil.IP)\(HTTPUtil.MAIN)")
        let url = URL(string: "\(HTTPUtil.IP)")
        var myRequest = URLRequest(url: url!)
        self.webView.load(myRequest)    // wkwebview url 연결
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 뷰 컨트롤러가 화면에 나타나기 직전에 실행됩니다.
    override func viewWillAppear(_ animated: Bool) {
        var viewBounds : CGRect = self.view.bounds
        viewBounds.origin.y = 20
        viewBounds.size.height = viewBounds.size.height - 20
        self.webView.frame = viewBounds     // wkwebview 크기 지정. (20을 빼는 이유는 아이폰 상단 상태바 높이를 빼주기 위함입니다.)
    }

    //wkwebView 기본 설정
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let properString = message.removingPercentEncoding
        let alertController = UIAlertController(title: "", message: properString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let properString = message.removingPercentEncoding
        let alertController = UIAlertController(title: "", message: properString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let properString = prompt.removingPercentEncoding
        let alertController = UIAlertController(title: "", message: properString, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
                // Fallback on earlier versions
            }
            
            //webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
}

// extension
extension ViewController: WKScriptMessageHandler, WKNavigationDelegate {
    //웹페이지 시작할때 로딩화면 추가
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.purple
        activityIndicator.frame = CGRect(x: view.frame.midX-25, y: view.frame.midY-25, width: 50, height: 50)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    //웹페이지 종료시 로딩화면 삭제
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.removeFromSuperview()
        activityIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // 웹페이지 롱클릭시 터치 이벤트 해제(범위설정 및 복사 붙여널기 등 이벤트).
//        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'", completionHandler: nil)
//        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.removeFromSuperview()
        activityIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.removeFromSuperview()
        activityIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // 브릿지 연결 메세지 받는 부분입니다.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        switch message.name {
        case "showDialog":
            guard let message = message.body as? String else {
                return
            }
            // 여기에 필요한 코드를 넣으시면 됩니다.
        default:
            break
        }
    }
}


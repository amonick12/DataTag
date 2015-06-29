//
//  WebpageViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/29/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import WebKit
import Parse

class WebpageViewController: UIViewController {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var progressBar: UIProgressView!
    var webView: WKWebView!
    
    var dataObject: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        view.bringSubviewToFront(progressBar)
        //view.bringSubviewToFront(toolbar)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)

        
        if let webpage = dataObject as? PFObject {
            let title = webpage["title"] as! String
            navTitle.title = title
            let urlString = webpage["url"] as! String
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL:url!)
            webView.loadRequest(request)
            
            //let mimeType = document["mimeType"] as! String
//            let screenshotData = webpage["fileData"] as! PFFile
//            screenshotData.getDataInBackgroundWithBlock ({
//                (data: NSData?, error: NSError?) -> Void in
//                self.progressBar.hidden = true
//                if error == nil {
//                    
//                    //self.webView.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
//                    
//                } else { println("Error loading document data") }
//                }, progressBlock: {
//                    (percentDone: Int32) -> Void in
//                    self.progressBar.progress = Float(percentDone)/100
//            })
            
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
        //self.webView.navigationDelegate = self
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if (keyPath == "loading") {
//            backButton.enabled = webView.canGoBack
//            forwardButton.enabled = webView.canGoForward
//        }
        if (keyPath == "estimatedProgress") {
            progressBar.hidden = webView.estimatedProgress == 1
            progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
        }
//        if (keyPath == "title") {
//            title = webView.title
//            println(webView.title!)
//            urlField.text = webView.URL?.relativeString!
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

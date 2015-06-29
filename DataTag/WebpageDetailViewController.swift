//
//  WebpageDetailViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/29/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import WebKit
import Parse

class WebpageDetailViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var webView: UIWebView!
    //var webView: WKWebView!
    var dataObject: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        
//        let backgroundImageView = UIImageView(image: UIImage(named: "cloud.jpg"))
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = backgroundImageView.bounds
//        blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
//        backgroundImageView.addSubview(blurEffectView)
//        view.addSubview(backgroundImageView)
        //view.bringSubviewToFront(progressView)
        //view.bringSubviewToFront(navBar)
//        view.addSubview(webView)
//        view.bringSubviewToFront(progressView)
//        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
//        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//        view.addConstraints([height, width])
        //webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        //webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)

        // Do any additional setup after loading the view.
        if let webpage = dataObject as? PFObject {
            let title = webpage["title"] as! String
            navTitle.title = title

            let urlString = webpage["url"] as! String
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL:url!)
            webView.loadRequest(request)
        }

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //webView.removeObserver(self, forKeyPath: "estimatedProgress")
        //webView.removeObserver(self, forKeyPath: "loading")
    }
//    required init(coder aDecoder: NSCoder) {
//        self.webView = WKWebView(frame: CGRectZero)
//        super.init(coder: aDecoder)
//        //self.webView.navigationDelegate = self
//    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if (keyPath == "loading") {
//            view.addSubview(webView)
//            view.bringSubviewToFront(progressView)
//            webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//            let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
//            let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//            view.addConstraints([height, width])
//            webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
//            webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
//        }
//        if (keyPath == "estimatedProgress") {
//            progressView.hidden = webView.estimatedProgress == 1
//            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
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

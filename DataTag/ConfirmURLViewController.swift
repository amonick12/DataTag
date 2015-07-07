//
//  ConfirmURLViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/28/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import WebKit
import Parse
import CoreImage

protocol ConfirmURLDelegate {
    func URLAdded()
}

class ConfirmURLViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {

    var delegate: ConfirmURLDelegate?
    var webView: WKWebView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var qrImg: UIImage!
    var dataObject: AnyObject?
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)

        //view.insertSubview(webView, belowSubview: progressView)
        view.addSubview(webView)
        view.bringSubviewToFront(progressView)
        view.bringSubviewToFront(toolbar)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        urlField.text = "http://www.google.com"
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        
        let url = NSURL(string:"http://www.google.com")
        let request = NSURLRequest(URL:url!)
        webView.loadRequest(request)

        var leftSwipe = UISwipeGestureRecognizer(target: self, action: "forwardGesture")
        leftSwipe.direction = .Left
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: "backGesture")
        rightSwipe.direction = .Right
        
        self.webView.addGestureRecognizer(leftSwipe)
        self.webView.addGestureRecognizer(rightSwipe)
        
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        backButton.enabled = false
        forwardButton.enabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "loading") {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if (keyPath == "title") {
            title = webView.title
            println(webView.title!)
            urlField.text = webView.URL?.relativeString!
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 30)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlField.text)!))
        return false
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        //urlField.resignFirstResponder()
        urlField.text = "http://"
        return false
    }
    
    func backGesture() {
        println("Go Back")
        urlField.resignFirstResponder()
        webView.goBack()
        urlField.text = webView.URL?.relativeString!
    }
   
    func forwardGesture() {
        println("Go Forward")
        urlField.resignFirstResponder()
        webView.goForward()
        urlField.text = webView.URL?.relativeString!
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        webView.goBack()
        urlField.text = webView.URL?.relativeString!
    }
    
    @IBAction func forwardButtonPressed(sender: AnyObject) {
        webView.goForward()
        urlField.text = webView.URL?.relativeString!
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        //removeObservers()
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        let url = webView.URL!.relativeString!
        let title = webView.title!
        println("URL: \(url)")
        println("title: \(title)")
        self.urlField.text = title
        progressView.hidden = true
        //UIGraphicsBeginImageContext(self.view.frame.size)
        UIGraphicsBeginImageContext(view.frame.size)
        //UIGraphicsBeginImageContext(CGSizeMake(view.frame.width, view.frame.height))
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, UIScreen.mainScreen().scale)
        view.drawViewHierarchyInRect(CGRectMake(0, -52.0, view.frame.width, (view.frame.height + 105.0)), afterScreenUpdates: true)
        //self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
        //self.webView.layer.renderInContext(context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let newURL = PFObject(className: "Data")
        newURL["type"] = "url"
        newURL["url"] = url
        newURL["title"] = title
        newURL["poster"] = PFUser.currentUser()!
        newURL.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
            if succeeded {
                let objectId = newURL.objectId!
                println(objectId)
                self.generateQRImage(objectId, withSizeRate: 10.0)
                self.showQRCode(sender)
            }
        })
        //save screenshot after objectId is made
        let data = UIImagePNGRepresentation(screenshot)
        let filename = "screenshot.png"
        newURL["filename"] = filename
        newURL["mimeType"] = "image/png"
        uploadData(data, filename: filename, newURL: newURL, sender: sender)
    }
    
    func uploadData(data: NSData, filename: String, newURL: PFObject, sender: AnyObject) {
        progressView.setProgress(0.0, animated: true)
        let parseFile = PFFile(name: filename, data: data)
        parseFile.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                newURL["fileData"] = parseFile
                newURL.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    if succeeded {
                        self.dataObject = newURL
                        self.delegate?.URLAdded()
                        self.progressView.hidden = true
                        
                        let sharedData = PFUser.currentUser()!.relationForKey("sharedData")
                        sharedData.addObject(newURL)
                        PFUser.currentUser()!.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.delegate?.URLAdded()
                            }
                        })
                        
                    } else { println("Error saving new image") }
                })
                
            } else { println("Error saving file") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                //self.progressBar.progress = percentDone
                //println(Float(percentDone)/100)
                self.progressView.progress = Float(percentDone)/100
        })
        
    }
    
    func generateQRImage(stringQR:NSString, withSizeRate rate:CGFloat) {
        var filter:CIFilter = CIFilter(name:"CIQRCodeGenerator")
        filter.setDefaults()
        var data:NSData = stringQR.dataUsingEncoding(NSUTF8StringEncoding)!
        filter.setValue(data, forKey: "inputMessage")
        var outputImg:CIImage = filter.outputImage
        var context:CIContext = CIContext(options: nil)
        var cgimg:CGImageRef = context.createCGImage(outputImg, fromRect: outputImg.extent())
        var img:UIImage = UIImage(CGImage: cgimg, scale: 1.0, orientation: UIImageOrientation.Up)!
        var width  = img.size.width * rate
        var height = img.size.height * rate
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        var cgContxt:CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(cgContxt, kCGInterpolationNone)
        img.drawInRect(CGRectMake(0, 0, width, height))
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        qrImg = img
    }

    func showQRCode(sender: AnyObject) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("QRNav") as! QRNavViewController
        let root = vc.visibleViewController as! QRGeneratorViewController
        root.qrImage = qrImg
        root.dataTitle = webView.title
        root.dataObject = self.dataObject
        root.hideActionButton = false
        
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        //popover.barButtonItem = sender
        popover.barButtonItem = sender as! UIBarButtonItem
        popover.delegate = self
        presentViewController(vc, animated: true, completion:nil)
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        removeObservers()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func removeObservers() {
        if webView.observationInfo != nil {
            webView.removeObserver(self, forKeyPath: "loading")
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.removeObserver(self, forKeyPath: "title")
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
//    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
//        if (navigationAction.navigationType == WKNavigationType.LinkActivated && !navigationAction.request.URL!.host!.lowercaseString.hasPrefix("www.google.com")) {
//            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
//            decisionHandler(WKNavigationActionPolicy.Cancel)
//        } else {
//            decisionHandler(WKNavigationActionPolicy.Allow)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

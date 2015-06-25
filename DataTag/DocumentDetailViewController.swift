//
//  DocumentDetailViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/22/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

class DocumentDetailViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var webView: UIWebView!
    
    var dataObject: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        
        let backgroundImageView = UIImageView(image: UIImage(named: "cloud.jpg"))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        backgroundImageView.addSubview(blurEffectView)
        webView.backgroundColor = UIColor.darkGrayColor()
        //webView.addSubview(backgroundImageView)
//        view.bringSubviewToFront(navBar)
//        view.bringSubviewToFront(webView)
//        view.bringSubviewToFront(progressBar)
    
        if let document = dataObject as? PFObject {
            let filename = document["filename"] as! String
            navTitle.title = filename
            let mimeType = document["mimeType"] as! String
            let documentData = document["fileData"] as! PFFile
            documentData.getDataInBackgroundWithBlock ({
                (data: NSData?, error: NSError?) -> Void in
                self.progressBar.hidden = true
                if error == nil {
                    self.webView.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
                    self.progressBar.hidden = true
                    
                } else { println("Error loading document data") }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    self.progressBar.progress = Float(percentDone)/100
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func shareButtonPressed(sender: AnyObject) {
        println("share doc")
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

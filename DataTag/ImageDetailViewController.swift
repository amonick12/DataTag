//
//  ImageDetailViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/24/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        view.addSubview(backgroundImageView)
        view.bringSubviewToFront(navBar)
        view.bringSubviewToFront(scrollView)
        view.bringSubviewToFront(imageView)
        view.bringSubviewToFront(progressBar)

        if let image = dataObject as? PFObject {
            let title = image["title"] as! String
            navTitle.title = title
            //let mimeType = image["mimeType"] as! String
            let imageData = image["fileData"] as! PFFile
            imageData.getDataInBackgroundWithBlock ({
                (data: NSData?, error: NSError?) -> Void in
                self.progressBar.hidden = true
                if error == nil {
                    self.imageView.image = UIImage(data: data!)
                    self.progressBar.hidden = true
                    self.setupScrollView()
                    
                } else { println("Error loading image data") }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    self.progressBar.progress = Float(percentDone)/100
            })
            
        }
    }

    func setupScrollView() {
        let widthScale = scrollView.bounds.size.width / imageView.frame.size.width
        let heightScale = scrollView.bounds.size.height / imageView.frame.size.height
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.setZoomScale(max(widthScale, heightScale), animated: true )
        scrollView.maximumZoomScale = 5.0
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ScrollView Delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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

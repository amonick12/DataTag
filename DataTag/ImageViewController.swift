//
//  ImageViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/24/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

class ImageViewController: UIViewController {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    var dataObject: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

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
                    
                } else { println("Error loading image data") }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    self.progressBar.progress = Float(percentDone)/100
            })
            
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
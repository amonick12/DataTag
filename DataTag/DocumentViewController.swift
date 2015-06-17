//
//  DocumentViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import WebKit
import Parse

class DocumentViewController: UIViewController {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var webView: UIWebView!
    
    var dataObject: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let document = dataObject as? PFObject {
            let filename = document["filename"] as! String
            navTitle.title = filename
            let mimeType = document["mimeType"] as! String
            let documentData = document["fileData"] as! PFFile
            documentData.getDataInBackgroundWithBlock ({
                (data: NSData?, error: NSError?) -> Void in
                self.progressBar.hidden = true
                if error == nil {
//                    if let imageData = imageData {
//                        let image = UIImage(data:imageData)
//                    }
                    self.webView.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)

                } else { println("Error loading document data") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                self.progressBar.progress = Float(percentDone)/100
            })
            
        }
        // Do any additional setup after loading the view.
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

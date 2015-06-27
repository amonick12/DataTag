//
//  ConfirmDocumentViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import WebKit
import Parse
import CoreImage

protocol ConfirmDocumentDelegate {
    func documentWasAdded()
}

class ConfirmDocumentViewController: UIViewController {

    var delegate: ConfirmDocumentDelegate?
    var filename: String!
    var mimeType: String!
    var data: NSData?

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var qrImg: UIImage!
    var objectId: String!
    var dataTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        view.bringSubviewToFront(progressBar)
        navTitle.title = filename
        progressBar.hidden = true
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let filePath = documentsDirectoryPath.stringByAppendingPathComponent(filename)
        
        if let fileData = NSFileManager.defaultManager().contentsAtPath(filePath as String) {
            self.data = fileData
            webView.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
            
        } else {
            println("Error loading file")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSizeMake(self.view.bounds.width * 2, self.view.bounds.height * 2)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "qrGeneratorSegue" {
            let destination = segue.destinationViewController as! QRGeneratorViewController
            destination.qrImage = self.qrImg!
            destination.dataTitle = filename
        }
    }

    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        println("Share button pressed")
        if data != nil {
            progressBar.hidden = false
            progressBar.progress = 0.0
            let newDocument = PFObject(className: "Data")
            //newDocument.objectId = NSUUID().UUIDString
            newDocument["type"] = "document"
            newDocument["mimeType"] = mimeType
            newDocument["filename"] = filename
            newDocument["poster"] = PFUser.currentUser()!
            let parseFile = PFFile(name: filename, data: data!, contentType: mimeType)
            parseFile.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                if succeeded {
                    newDocument["fileData"] = parseFile
                    newDocument.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                        if succeeded {
                            self.progressBar.hidden = true
                            self.objectId = newDocument.objectId!
                            //self.dataObject = newDocument
                            
                            //self.makeQRCodeImage()
                            
                            self.generateQRImage(self.objectId, withSizeRate: 10.0)
                            
                            let sharedData = PFUser.currentUser()!.relationForKey("sharedData")
                            sharedData.addObject(newDocument)
                            PFUser.currentUser()!.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                                if error == nil {
                                    self.delegate?.documentWasAdded()
                                }
                            })
                            
                        } else { println("Error saving new document") }
                    })

                } else { println("Error saving file") }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    //self.progressBar.progress = percentDone
                    //println(Float(percentDone)/100)
                    self.progressBar.progress = Float(percentDone)/100
            })
            
        }
        
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
        self.performSegueWithIdentifier("qrGeneratorSegue", sender: nil)

    }
    
    func makeQRCodeImage() {

        let data = objectId.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        let qrcodeImage = filter.outputImage
        let scaleX = 200.0 / qrcodeImage.extent().size.width
        let scaleY = 200.0 / qrcodeImage.extent().size.height
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        qrImg = UIImage(CIImage: transformedImage)
        self.performSegueWithIdentifier("qrGeneratorSegue", sender: nil)

        //println("size: \(qrImg?.size)")
        //qrImg?.size = CGSizeMake(200.0, 200.0)
        
        //let documentObject = dataObject as! PFObject
        //let imgData = UIImagePNGRepresentation(qrImg)
        //var imageFile = PFFile(data: imgData)
        //let imageFile = PFFile(name: "qrCode.png", data: imgData)
        //newDocument["qrCodeImage"] = imageFile
        //newDocument.saveInBackground()
//        let qrImgFile = PFFile(name: "qrCode.png", data: imgData)
//        documentObject["qrCodeImg"] = qrImgFile
//        documentObject.saveInBackground()
        
        
        
//        qrImgFile.saveInBackgroundWithBlock { (succeeded, error) -> Void in
//            if succeeded {
//                documentObject["qrCodeImg"] = qrImgFile
//                documentObject.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
//                    if succeeded {
//                        
//                        self.performSegueWithIdentifier("qrGeneratorSegue", sender: nil)
//                        let sharedData = PFUser.currentUser()!.relationForKey("sharedData")
//                        sharedData.addObject(documentObject)
//                        PFUser.currentUser()!.saveInBackground()
//                        
//                    } else { println("Error saving document object with QR code") }
//                    
//                })
//                
//            } else { println("Error saving QR Image") }
//            
//        }
        

    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func showProgressBar() {
//        progressBar.progress = 0.0
//        progressBar.hidden = false
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

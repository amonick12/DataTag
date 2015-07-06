//
//  ConfirmImageViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 6/23/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse
import CoreImage

protocol ConfirmImageDelegate {
    func imageWasAdded()
}
class ConfirmImageViewController: UIViewController, UITextFieldDelegate {

    var delegate: ConfirmImageDelegate?
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UIView!
    
    var image: UIImage!
    
    var qrImg: UIImage!
    var objectId: String!
    var dataTitle: String!
    var dataObject: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(image: UIImage(named: "cloud.jpg"))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        backgroundImageView.addSubview(blurEffectView)
        view.addSubview(backgroundImageView)
        view.bringSubviewToFront(progressBar)
        view.bringSubviewToFront(textView)
        view.bringSubviewToFront(imageView)
        
        navigationController?.toolbarHidden = true
        imageView.image = image
        view.bringSubviewToFront(progressBar)
        progressBar.hidden = true
        textField.attributedPlaceholder = NSAttributedString(string:"Image Name Here",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "qrGeneratorOfImage" {
            let destination = segue.destinationViewController as! QRGeneratorViewController
            destination.qrImage = self.qrImg
            destination.dataTitle = dataTitle
            destination.dataObject = self.dataObject
            destination.hideActionButton = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSizeMake(view.bounds.width * 0.75, view.bounds.height * 0.75)
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        println(textField.text)
        dataTitle = textField.text
        shareImage()
        return true
    }

    func shareImage() {
        progressBar.hidden = false
        progressBar.progress = 0.0
        let newImage = PFObject(className: "Data")
        //newImage.objectId = NSUUID().UUIDString
        newImage["type"] = "image"
        //newImage["mimeType"] = mimeType
        newImage["title"] = dataTitle
        newImage["poster"] = PFUser.currentUser()!
        
        let data = UIImagePNGRepresentation(image)
        if(data.length <= 10485760) {
            //you can continue for upload.
            println("png file is \(toMB(data.length)) MB and has \(toMB(10485760 - data.length)) MB left")
            let filename = "\(dataTitle).png"
            newImage["filename"] = filename
            uploadData(data, filename: filename, newImage: newImage)
        } else {
            //file size exceeding, can't upload.
            let filename = "\(dataTitle).jpeg"
            newImage["filename"] = filename
            println("png file is \(toMB(data.length - 10485760)) MB over the limit")
            let jpgData = UIImageJPEGRepresentation(image, 1.0)
            if jpgData.length <= 10485760 {
                
                uploadData(jpgData, filename: filename, newImage: newImage)
                println("jpg file is \(toMB(jpgData.length)) MB and has \(toMB(10485760 - jpgData.length)) MB left")
            } else {
                println("jpg file is \(toMB(jpgData.length - 10485760)) MB over the limit")
                let newData = UIImageJPEGRepresentation(image, 0.5)
                println("new data length is \(toMB(newData.length)) MB")
                uploadData(newData, filename: filename, newImage: newImage)
            }
            
        }
        
    }
    
    func toMB(bytes: Int) -> Double {
        return Double(bytes) * pow(Double(10.0), Double(-6.0))
    }
    
    func uploadData(data: NSData, filename: String, newImage: PFObject) {
        let parseFile = PFFile(name: filename, data: data)
        parseFile.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                newImage["fileData"] = parseFile
                newImage.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    if succeeded {
                        self.progressBar.hidden = true
                        self.objectId = newImage.objectId!
                        self.dataObject = newImage
                        
                        println(self.objectId)
                        self.generateQRImage(self.objectId, withSizeRate: 10.0)
                        
                        let sharedData = PFUser.currentUser()!.relationForKey("sharedData")
                        sharedData.addObject(newImage)
                        PFUser.currentUser()!.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.delegate?.imageWasAdded()
                            }
                        })
                        
                    } else { println("Error saving new image") }
                })
                
            } else { println("Error saving file") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                //self.progressBar.progress = percentDone
                //println(Float(percentDone)/100)
                self.progressBar.progress = Float(percentDone)/100
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
        self.performSegueWithIdentifier("qrGeneratorOfImage", sender: nil)
        
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

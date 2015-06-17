//
//  QRGeneratorViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import MessageUI

class QRGeneratorViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var imgQRCode: UIImageView!
    
//    var qrcodeImage: CIImage!
//    var objectId: String!
//    var dataObject: AnyObject!

    var qrImage: UIImage!
    var dataTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        navTitle.title = dataTitle
        imgQRCode.image = qrImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func emailButtonPressed(sender: AnyObject) {
        println("email button pressed")
        let data = UIImagePNGRepresentation(imgQRCode.image)
        
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        // Initialize the mail composer and populate the mail content
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self;
        mailComposer.setSubject("DataTag QR Code")
        mailComposer.setMessageBody("Scan with DataTag app", isHTML: false)
        mailComposer.addAttachmentData(data, mimeType: "image/png", fileName: "qrCode.png")
        presentViewController(mailComposer, animated: true, completion: nil)

    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Failed to send: \(error.localizedDescription)")
        default: break
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func printButtonPressed(sender: AnyObject) {
        println("print button pressed")
        // 1
        let printController = UIPrintInteractionController.sharedPrintController()!
        // 2
        let printInfo = UIPrintInfo(dictionary:nil)!
        printInfo.outputType = UIPrintInfoOutputType.General
        printInfo.jobName = "Print Job"
        printController.printInfo = printInfo
        // 3
        printController.printingItem = qrImage
        // 4
        printController.presentFromBarButtonItem(sender as! UIBarButtonItem, animated: true, completionHandler: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
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

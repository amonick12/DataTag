//
//  ScanViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var scanView: UIView!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var objectId: String?
    
    var foundObject: AnyObject?
    var dataType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.preferredContentSize = CGSizeMake(self.view.bounds.width * 0.75, self.view.bounds.height * 0.75)

        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        if (error != nil) {
            println("\(error?.localizedDescription)")
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession?.startRunning()

        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        objectId = nil
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
    
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }
    
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        //if supportedBarCodes.filter({ $0 == metadataObj.type }).count > 0 {
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
        
            if metadataObj.stringValue != nil && objectId == nil {
                objectId = metadataObj.stringValue
                println("objectId: \(objectId!)")
                loadTaggedData(objectId!)
            }
        }
    }

    func loadTaggedData(objectId: String) {
        var query = PFQuery(className: "Data")
        query.getObjectInBackgroundWithId(objectId) {
            (data: PFObject?, error: NSError?) -> Void in
            if error == nil && data != nil {
                self.dataType = data!["type"] as? String
                self.foundObject = data
                let usersRelation = data?.relationForKey("unlockedBy")
                usersRelation?.addObject(PFUser.currentUser()!)
                let taggedRelation = PFUser.currentUser()!.relationForKey("unlockedData")
                taggedRelation.addObject(data!)
                PFUser.currentUser()?.saveInBackground()
                data?.saveInBackground()
                if self.dataType == "document" {
                    self.performSegueWithIdentifier("showDocumentSegue", sender: nil)
                }
                if self.dataType == "image" {
                    self.performSegueWithIdentifier("showImageSegue", sender: nil)
                }
            } else {
                println(error)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDocumentSegue" {
            let vc = segue.destinationViewController as! DocumentViewController
            vc.dataObject = foundObject
        } else if segue.identifier == "showImageSegue" {
            let vc = segue.destinationViewController as! ImageViewController
            vc.dataObject = foundObject
        }
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

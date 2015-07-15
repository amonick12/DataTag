//
//  QRGeneratorViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import MessageUI
import QuartzCore
import CoreLocation
import CoreBluetooth
import Parse

class QRGeneratorViewController: UIViewController, MFMailComposeViewControllerDelegate, CBPeripheralManagerDelegate, AddLocationViewControllerDelegate {

    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var imgQRCode: UIImageView!
    var dataObject: AnyObject?
    var qrImage: UIImage!
    var dataTitle: String!
    var hideActionButton: Bool = true
    let uuid = NSUUID(UUIDString: "DDE7137E-EE5F-4A48-A083-2E48F024F73A")
    
    var beaconRegion: CLBeaconRegion!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var dataDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if hideActionButton {
            actionButton.enabled = false
            actionButton.tintColor = UIColor.clearColor()
        }
        self.navigationItem.hidesBackButton = true
        navigationController?.toolbarHidden = false
        navTitle.title = dataTitle
        imgQRCode.image = qrImage
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            self.preferredContentSize = CGSizeMake(self.view.bounds.width / 2, self.view.bounds.height / 2)
//        }
        self.preferredContentSize = CGSizeMake(300.0, 300.0)
        self.reloadInputViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addLocationSegue" {
            let destination = segue.destinationViewController as! AddLocationViewController
            destination.delegate = self
        }
    }
    
    // MARK: AddLocationViewControllerDelegate
    func locationAdded(location: CLLocationCoordinate2D, radius: Int) {
        println("lat: \(location.latitude)")
        println("long: \(location.longitude)")
        println("range \(radius)")
        let point = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        if let data = dataObject as? PFObject {
            data["geoPoint"] = point
            data["range"] = radius
            data.saveInBackground()
        }
        
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

    @IBAction func actionButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let beaconAction = UIAlertAction(title: "Broadcast as Beacon", style: .Default) { (action: UIAlertAction!) -> Void in
            println("Broadcast as Beacon")
            if self.dataObject != nil {
                self.broadcastAsBeacon(self.dataObject!)
            }
        }
        alert.addAction(beaconAction)
        
        let assignBeaconAction = UIAlertAction(title: "Assign to Beacon", style: .Default) { (action: UIAlertAction!) -> Void in
            println("Assign to Beacon")
            if self.dataObject != nil {
                //self.broadcastAsBeacon(self.dataObject!)
                self.selectBeacon(self.dataObject!, sender: sender)
            }
        }
        alert.addAction(assignBeaconAction)

        let mapAction = UIAlertAction(title: "Pin to a Location", style: .Default) { (action: UIAlertAction!) -> Void in
            println("Add geopoint")
            self.performSegueWithIdentifier("addLocationSegue", sender: sender)
        }
        alert.addAction(mapAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) -> Void in
            println("canceled")
        }
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
        presentViewController(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func selectBeacon(dataObject: AnyObject, sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for data in beaconData {
            if data.UUID != "DDE7137E-EE5F-4A48-A083-2E48F024F73A" {
                let major = data.major
                let minor = data.minor
                let action = UIAlertAction(title: "\(major)-\(minor)", style: .Default, handler: { (action) -> Void in
                    if let object = dataObject as? PFObject {
                        object["major"] = major
                        object["minor"] = minor
                        object["proximityUUID"] = data.UUID
                        object.saveInBackground()
                    }
                })
                alert.addAction(action)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) -> Void in
            println("canceled")
        }
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func broadcastAsBeacon(dataObject: AnyObject) {
        if bluetoothPeripheralManager.isAdvertising {
            bluetoothPeripheralManager.stopAdvertising()
        }
        
        if bluetoothPeripheralManager.state == CBPeripheralManagerState.PoweredOn {
            
            let max = UINT16_MAX.toIntMax()
            let majorInt = Int(arc4random_uniform(UInt32(max))) + 1
            let minorInt = Int(arc4random_uniform(UInt32(max))) + 1
            if let data = dataObject as? PFObject {
                data["major"] = String(majorInt)
                data["minor"] = String(minorInt)
                data["proximityUUID"] = uuid!.UUIDString
                data.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    
                    let major: CLBeaconMajorValue = UInt16(majorInt)
                    let minor: CLBeaconMinorValue = UInt16(minorInt)
                    self.beaconRegion = CLBeaconRegion(proximityUUID: self.uuid, major: major, minor: minor, identifier: "datatag.com")
                    self.dataDictionary = self.beaconRegion.peripheralDataWithMeasuredPower(nil)
                    self.bluetoothPeripheralManager.startAdvertising(self.dataDictionary as [NSObject : AnyObject])
                    println("broadcasting...")
                    println("major: \(majorInt)")
                    println("minor: \(minorInt)")
                })
            }
            
        } else {
            println("alert: turn on bluetooth")
            let alert = UIAlertController(title: "Turn On Bluetooth", message: "Bluetooth is needed to broadcast as a beacon", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OKAY", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        var statusMessage = ""
        
        switch peripheral.state {
        case CBPeripheralManagerState.PoweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case CBPeripheralManagerState.PoweredOff:
            if bluetoothPeripheralManager.isAdvertising {
                //switchBroadcastingState(self)
                bluetoothPeripheralManager.stopAdvertising()
            }
            statusMessage = "Bluetooth Status: Turned Off"
            
        case CBPeripheralManagerState.Resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case CBPeripheralManagerState.Unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case CBPeripheralManagerState.Unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        println("Bluetooth status: \(statusMessage)")
        //lblBTStatus.text = statusMessage
    }

}

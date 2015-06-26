//
//  MainViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UITableViewController {

    @IBOutlet weak var tagButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    var refresher: UIRefreshControl!

    @IBOutlet var segmentControl: DTSegmentedControl!
    var popTransition = PopTransitionAnimator()
    var dbRestClient: DBRestClient!

    var sharedData: [AnyObject]?
    var taggedData: [AnyObject]?
    
    var sharedDocuments: [AnyObject] = []
    var sharedImages: [AnyObject] = []
    
    var taggedDocuments: [AnyObject] = []
    var taggedImages: [AnyObject] = []
    
    var selectedObject: AnyObject?
    var selectedObjectTitle: String?
    var qrImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentControl.items = ["SHARED", "TAGGED"]
        segmentControl.font = UIFont(name: "Avenir-Black", size: 12)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.addTarget(self, action: "segmentValueChanged:", forControlEvents: .ValueChanged)
        
        let backgroundImageView = UIImageView(image: UIImage(named: "cloud.jpg"))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        backgroundImageView.addSubview(blurEffectView)
        tableView.backgroundView = backgroundImageView
        
        self.refresher = UIRefreshControl()
        self.refresher.tintColor = UIColor.whiteColor()
        self.refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        } else {
            println("Internet connection FAILED")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }

        if PFUser.currentUser() != nil {
            loadTaggedData()
            loadSharedData()
        }

        shareButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: .Normal)
        tagButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: .Normal)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidLinkNotification:", name: "didLinkToDropboxAccountNotification", object: nil)
        if DBSession.sharedSession().isLinked() {
            initDropboxRestClient()
        }
        
    }
    
    func refresh() {
        loadTaggedData()
        loadSharedData()
        refresher.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "documentSegue" {
            let toViewController = segue.destinationViewController as! DocumentDetailViewController
            self.modalPresentationStyle = UIModalPresentationStyle.Custom
            toViewController.transitioningDelegate = self.popTransition
            toViewController.dataObject = self.selectedObject
            
            //var destination = segue.destinationViewController as! DocumentDetailViewController
            //destination.dataObject = self.selectedObject
        } else if segue.identifier == "imageSegue" {
            let toViewController = segue.destinationViewController as! ImageDetailViewController
            self.modalPresentationStyle = UIModalPresentationStyle.Custom
            toViewController.transitioningDelegate = self.popTransition
            toViewController.dataObject = self.selectedObject
        }
    }

    func segmentValueChanged(sender: AnyObject?) {
        tableView.reloadData()
    }
    
    func loadTaggedData() {
        var query = PFUser.currentUser()!.relationForKey("unlockedData").query()!
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                self.taggedData = objects
                println("Found \(self.taggedData!.count) tagged data")
                self.taggedDocuments.removeAll(keepCapacity: false)
                self.taggedImages.removeAll(keepCapacity: false)
                
                if let taggedData = objects as? [PFObject] {
                    for data in taggedData {
                        let type = data["type"] as! String
                        if type == "document" {
                            self.taggedDocuments.append(data as AnyObject)
                        } else if type == "image" {
                            self.taggedImages.append(data as AnyObject)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func loadSharedData() {
        var query = PFUser.currentUser()!.relationForKey("sharedData").query()!
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                self.sharedData = objects
                println("Found \(self.sharedData!.count) shared data")
                self.sharedDocuments.removeAll(keepCapacity: false)
                self.sharedImages.removeAll(keepCapacity: false)
                
                if let sharedData = objects as? [PFObject] {
                    for data in sharedData {
                        let type = data["type"] as! String
                        if type == "document" {
                            self.sharedDocuments.append(data as AnyObject)
                        } else if type == "image" {
                            self.sharedImages.append(data as AnyObject)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 50))
        sectionHeaderView.backgroundColor = UIColor.clearColor()
        var headerLabel = UILabel(frame: CGRectMake(15, 15, sectionHeaderView.frame.width, 25))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.font = UIFont(name: "Avenir", size: 15)
        headerLabel.textColor = UIColor.whiteColor()
        sectionHeaderView.addSubview(headerLabel)
        switch section {
        case 0:
            headerLabel.text = "DOCUMENTS"
            break
        case 1:
            headerLabel.text = "IMAGES"
            break
        default:
            break
        }
        return sectionHeaderView
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DocumentCell", forIndexPath: indexPath) as! DocumentsTableViewCell
            if segmentControl.selectedIndex == 0 {
                cell.documents = self.sharedDocuments
            } else if segmentControl.selectedIndex == 1 {
                cell.documents = self.taggedDocuments
            }
            if cell.documents != nil {
                cell.delegate = self
                cell.viewController = self
                cell.configureWithData()
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath) as! ImagesTableViewCell
            if segmentControl.selectedIndex == 0 {
                cell.images = self.sharedImages
            } else if segmentControl.selectedIndex == 1 {
                cell.images = self.taggedImages
            }
            if cell.images != nil {
                cell.delegate = self
                cell.viewController = self
                cell.configureWithData()
            }
            
            return cell
        }
        return UITableViewCell()
    }

    @IBAction func shareDataButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Share Data", message: "What type of data do you want to share?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let documentAction = UIAlertAction(title: "Document", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Document button tapped")
            self.addDocumentButtonPressed(sender)
        })
        alertController.addAction(documentAction)
        
        let imageAction = UIAlertAction(title: "Image", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Image button tapped")
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
                println("show photo library")
                self.photoFromLibrary(sender)
            })
            alert.addAction(photoLibraryAction)
            
            let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
                println("show camera")
                self.shootPhoto(sender)
            })
            alert.addAction(cameraAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)

            alert.popoverPresentationController?.barButtonItem = sender
            self.presentViewController(alert, animated: true, completion: nil)
            
        })
        alertController.addAction(imageAction)
        
//        let videoAction = UIAlertAction(title: "Video", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
//            println("Video button tapped")
//            
//        })
//        alertController.addAction(videoAction)
        
        let urlAction = UIAlertAction(title: "URL", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("URL button tapped")
            
        })
        alertController.addAction(urlAction)
        
//        let textAction = UIAlertAction(title: "Text", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
//            println("Text button tapped")
//            
//        })
//        alertController.addAction(textAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)

        alertController.popoverPresentationController?.barButtonItem = sender
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    @IBAction func unlockDataButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Tag Data Options", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let scanAction = UIAlertAction(title: "Scan", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Scan button tapped")
            //self.scanButtonPressed(sender)
            self.performSegueWithIdentifier("scanSegue", sender: sender)
        })
        alertController.addAction(scanAction)
        
        let mapAction = UIAlertAction(title: "Map", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Map button tapped")
            
        })
        alertController.addAction(mapAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.barButtonItem = sender
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MainViewController: DBRestClientDelegate, DocumentsDelegate, ImagesDelegate {
    
    func uploadToDropbox(dataObject: AnyObject) {
        if DBSession.sharedSession().isLinked() {
            if let dataObject = dataObject as? PFObject {
                let filename = dataObject["filename"] as! String
                let fileData = dataObject["fileData"] as! PFFile
                fileData.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                    if error == nil && data != nil {
                        
                        let tempDirectory = NSTemporaryDirectory()
                        let tempPath = tempDirectory.stringByAppendingPathComponent(filename)
                        data!.writeToFile(tempPath, atomically: true)
                        self.dbRestClient.uploadFile(filename, toPath: "/", withParentRev: nil, fromPath: tempPath)
                    } else { println("Error getting file to upload to dropbox") }
                })
            }
            
        } else {
            DBSession.sharedSession().linkFromController(self)
        }
    }
    func initDropboxRestClient() {
        dbRestClient = DBRestClient(session: DBSession.sharedSession())
        dbRestClient.delegate = self
    }
    func handleDidLinkNotification(notification: NSNotification) {
        initDropboxRestClient()
    }
    
    // MARK: DBRestClientDelegate
    
    // Uploading Files
    func restClient(client: DBRestClient!, uploadedFile destPath: String!, from srcPath: String!, metadata: DBMetadata!) {
        println("The file has been uploaded.")
        let ac = UIAlertController(title: "Uploaded!", message: "The data has been uploaded to your Dropbox in the DataTag folder", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func restClient(client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
        println("File upload failed.")
        println(error.description)
        let ac = UIAlertController(title: "Upload Failed", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)

    }
    
    func documentObjectSelected(documentObject: AnyObject) {
        self.selectedObject = documentObject
        performSegueWithIdentifier("documentSegue", sender: nil)
    }
    
    func imageObjectSelected(imageObject: AnyObject) {
        self.selectedObject = imageObject
        performSegueWithIdentifier("imageSegue", sender: nil)
    }
    
    func shareWithQRCode(object: AnyObject, cell: UICollectionViewCell) {
        self.selectedObject = object
        let object = object as! PFObject
        makeQRCodeImage(object.objectId!)
        showQRCode(cell)
    }
    
    func makeQRCodeImage(stringQR: String) {
        
        var filter: CIFilter = CIFilter(name:"CIQRCodeGenerator")
        filter.setDefaults()
        var data: NSData = stringQR.dataUsingEncoding(NSUTF8StringEncoding)!
        filter.setValue(data, forKey: "inputMessage")
        var outputImg: CIImage = filter.outputImage
        var context: CIContext = CIContext(options: nil)
        var cgimg: CGImageRef = context.createCGImage(outputImg, fromRect: outputImg.extent())
        var img: UIImage = UIImage(CGImage: cgimg, scale: 1.0, orientation: UIImageOrientation.Up)!
        var width  = img.size.width * 10
        var height = img.size.height * 10
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        var cgContxt:CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(cgContxt, kCGInterpolationNone)
        img.drawInRect(CGRectMake(0, 0, width, height))
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        qrImage = img
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    func photoFromLibrary(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        picker.modalPresentationStyle = UIModalPresentationStyle.Popover
        picker.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        picker.navigationBar.tintColor = UIColor.whiteColor()
        presentViewController(picker, animated: true, completion: nil)
        picker.popoverPresentationController?.barButtonItem = sender
    }
    func shootPhoto(sender: UIBarButtonItem) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            presentViewController(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("AddImageNav") as! AddImageNavController
        let root = vc.visibleViewController as! ConfirmImageViewController
        root.image = chosenImage
        
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = self.shareButton
        popover.delegate = self
        presentViewController(vc, animated: true, completion:nil)
        
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    
    func showQRCode(sender: UICollectionViewCell) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("QRNav") as! QRNavViewController
        let root = vc.visibleViewController as! QRGeneratorViewController
        if let object = selectedObject as? PFObject {
            let dataType = object["type"] as! String
            //var dataTitle: String?
            switch dataType {
            case "document":
                selectedObjectTitle = object["filename"] as? String
                break
            case "image":
                selectedObjectTitle = object["title"] as? String
                break
            default:
                break
            }
            root.qrImage = qrImage
            root.dataTitle = selectedObjectTitle
            
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            //popover.barButtonItem = sender
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    func addDocumentButtonPressed(sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("AddDocumentNav") as! AddDocumentNavController
        let root = vc.visibleViewController as! AddDocumentViewController

        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        presentViewController(vc, animated: true, completion:nil)
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


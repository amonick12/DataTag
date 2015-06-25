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
    //@IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet var segmentControl: DTSegmentedControl!

    var sharedData: [AnyObject]?
    var taggedData: [AnyObject]?
    
    var sharedDocuments: [AnyObject] = []
    var sharedImages: [AnyObject] = []
    
    var taggedDocuments: [AnyObject] = []
    var taggedImages: [AnyObject] = []
    
    var selectedObject: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentControl.items = ["SHARED", "TAGGED"]
        segmentControl.font = UIFont(name: "Avenir-Black", size: 12)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.addTarget(self, action: "segmentValueChanged:", forControlEvents: .ValueChanged)
        
        tableView.separatorColor = UIColor.clearColor()
        let backgroundImageView = UIImageView(image: UIImage(named: "cloud.jpg"))
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        
        backgroundImageView.addSubview(blurEffectView)
        tableView.backgroundView = backgroundImageView
        
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

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "documentSegue" {
            var destination = segue.destinationViewController as! DocumentDetailViewController
            destination.dataObject = self.selectedObject
        } else if segue.identifier == "imageSegue" {
            var destination = segue.destinationViewController as! ImageDetailViewController
            destination.dataObject = self.selectedObject
        }
    }

    func segmentValueChanged(sender: AnyObject?){
        if segmentControl.selectedIndex == 0 {
            loadSharedData()
        } else if segmentControl.selectedIndex == 1{
            loadTaggedData()
        }
    }
    
//    @IBAction func controlChanged(sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//            loadSharedData()
//        } else if sender.selectedSegmentIndex == 1 {
//            loadTaggedData()
//        }
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        if PFUser.currentUser() != nil {
//            loadTaggedData()
//            loadSharedData()
//        }
//    }
    
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
        
        let videoAction = UIAlertAction(title: "Video", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Video button tapped")
            
        })
        alertController.addAction(videoAction)
        
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

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: DocumentsDelegate, ImagesDelegate {
    func documentObjectSelected(documentObject: AnyObject) {
        self.selectedObject = documentObject
        performSegueWithIdentifier("documentSegue", sender: nil)
    }
    func imageObjectSelected(imageObject: AnyObject) {
        self.selectedObject = imageObject
        performSegueWithIdentifier("imageSegue", sender: nil)
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    func photoFromLibrary(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        picker.modalPresentationStyle = UIModalPresentationStyle.Popover
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
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    
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

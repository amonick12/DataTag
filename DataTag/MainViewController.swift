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

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var sharedData: [AnyObject]?
    var taggedData: [AnyObject]?
    
    var sharedDocuments: [AnyObject] = []
    var sharedImages: [AnyObject] = []
    
    var taggedDocuments: [AnyObject] = []
    var taggedImages: [AnyObject] = []
    
    var selectedObject: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "documentSegue" {
            var destination = segue.destinationViewController as! DocumentDetailViewController
            destination.dataObject = self.selectedObject
            

        }
    }

    @IBAction func controlChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loadSharedData()
        } else if sender.selectedSegmentIndex == 1 {
            loadTaggedData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if PFUser.currentUser() != nil {
            loadTaggedData()
            loadSharedData()
        }
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DocumentCell", forIndexPath: indexPath) as! DocumentsTableViewCell
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.documents = self.sharedDocuments
        } else if segmentedControl.selectedSegmentIndex == 1 {
            cell.documents = self.taggedDocuments
        }
        if cell.documents != nil {
            cell.delegate = self
            cell.configureWithData()
        }
        
    
        return cell
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
            
        })
        alertController.addAction(imageAction)
        
        let videoAction = UIAlertAction(title: "Video", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Viedo button tapped")
            
        })
        alertController.addAction(videoAction)
        
        let urlAction = UIAlertAction(title: "URL", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("URL button tapped")
            
        })
        alertController.addAction(urlAction)
        
        let textAction = UIAlertAction(title: "Text", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("Text button tapped")
            
        })
        alertController.addAction(textAction)
        
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

extension MainViewController: DocumentsDelegate {
    func documentObjectSelected(documentObject: AnyObject) {
        self.selectedObject = documentObject
        performSegueWithIdentifier("documentSegue", sender: nil)
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    
//    func scanButtonPressed(sender: UIBarButtonItem) {
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("ScanNav") as! ScanNavController
//        let root = vc.visibleViewController as! ScanViewController
//        
//        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
//        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
//        popover.barButtonItem = sender
//        popover.delegate = self
//        presentViewController(vc, animated: true, completion:nil)
//    }
    
    func addDocumentButtonPressed(sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("AddDocumentNav") as!AddDocumentNavController
        let root = vc.visibleViewController as! AddDocumentViewController
        
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        presentViewController(vc, animated: true, completion:nil)
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
}

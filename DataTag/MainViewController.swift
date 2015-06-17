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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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

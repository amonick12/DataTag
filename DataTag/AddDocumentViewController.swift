//
//  AddDocumentViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit

class AddDocumentViewController: UITableViewController, DBRestClientDelegate {

    var dbRestClient: DBRestClient!
    var dropboxMetadata: DBMetadata!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var connectButton: UIBarButtonItem!
    var refresher: UIRefreshControl!
    
    var selectedFileName: String?
    var selectedMimeType: String?
    
    var cellShown: [Bool]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidLinkNotification:", name: "didLinkToDropboxAccountNotification", object: nil)
        
        if DBSession.sharedSession().isLinked() {
            initDropboxRestClient()
            connectButton.title = "Your Dropbox Folder"
        }
        
        progressBar.hidden = true
        
        self.refresher = UIRefreshControl()
        //self.refresher.tintColor = Helper().colorWithRGBHex(0x00c853, alpha: 0.9)
        self.refresher.addTarget(self, action: "reloadFiles:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.rowHeight = 60.0
        self.tableView.addSubview(refresher)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "confirmDocumentSegue" {
            if let destination = segue.destinationViewController as? ConfirmDocumentViewController {
                destination.filename = selectedFileName!
                destination.mimeType = selectedMimeType!
                //destination.delegate = self
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func connectToDropbox(sender: AnyObject) {
        if !DBSession.sharedSession().isLinked() {
            DBSession.sharedSession().linkFromController(self)
        }
        else {
            DBSession.sharedSession().unlinkAll()
            connectButton.title = "Connect to Dropbox"
        }
    }
    
    func initDropboxRestClient() {
        dbRestClient = DBRestClient(session: DBSession.sharedSession())
        dbRestClient.delegate = self
        dbRestClient.loadMetadata("/")
        
    }
    
    func reloadFiles(sender: AnyObject) {
        if !DBSession.sharedSession().isLinked() {
            //DBSession.sharedSession().linkFromController(self)
            connectButtonPressed(connectButton)
        } else {
            dbRestClient.loadMetadata("/")
            //dbRestClient.loadMetadata(filePath!)
            
        }
    }
    
    func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        if metadata.contents.count == 0 {
            //upload getting started.rtf
            let uploadFilename = "Getting Started.rtf"
            let sourcePath = NSBundle.mainBundle().pathForResource("Getting Started", ofType: "rtf")
            let destinationPath = "/"
            
            self.showProgressBar()
            self.dbRestClient.uploadFile(uploadFilename, toPath: destinationPath, withParentRev: nil, fromPath: sourcePath)
        }
        dropboxMetadata = metadata
        cellShown = [Bool](count: metadata.contents.count, repeatedValue: false)
        tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        println("Error: \(error.description)")
        self.refresher.endRefreshing()
    }
    
    func restClient(client: DBRestClient!, loadedFile destPath: String!, contentType: String!, metadata: DBMetadata!) {
        println("The file \(metadata.filename) was downloaded. Content type: \(contentType)")
        progressBar.hidden = true
        selectedFileName = metadata.filename
        selectedMimeType = contentType
        
        performSegueWithIdentifier("confirmDocumentSegue", sender: nil)
    }
    
    func restClient(client: DBRestClient!, loadFileFailedWithError error: NSError!) {
        println("Error: \(error.description)")
        progressBar.hidden = true
    }
    
    func restClient(client: DBRestClient!, loadProgress progress: CGFloat, forFile destPath: String!) {
        //println(Float(progress))
        progressBar.progress = Float(progress)
    }
    
    func showProgressBar() {
        progressBar.progress = 0.0
        progressBar.hidden = false
    }
    
    @IBAction func connectButtonPressed(sender: UIBarButtonItem) {
        if !DBSession.sharedSession().isLinked() {
            DBSession.sharedSession().linkFromController(self)
        }
        else {
            // alert for confirmation
            let alertController = UIAlertController(title: "Disconnect from Dropbox", message: "Are you sure you want to disconnect from Dropbox", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let okAction = UIAlertAction(title: "Disconnect", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                DBSession.sharedSession().unlinkAll()
                self.connectButton.title = "Connect to Dropbox"
                self.dbRestClient = nil
                self.dropboxMetadata = nil
                self.tableView.reloadData()
            })
            alertController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                //println("Cancel button tapped")
            })
            alertController.addAction(cancelAction)
            
            // for ipad
            alertController.popoverPresentationController?.barButtonItem = sender
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func handleDidLinkNotification(notification: NSNotification) {
        initDropboxRestClient()
        connectButton.title = "Your Dropbox Folder"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let metadata = dropboxMetadata {
            return metadata.contents.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddDocumentCell", forIndexPath: indexPath) as! UITableViewCell
        
        let currentFile: DBMetadata = dropboxMetadata.contents[indexPath.row] as! DBMetadata
        cell.textLabel?.text = currentFile.filename
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedFile: DBMetadata = dropboxMetadata.contents[indexPath.row] as! DBMetadata
        
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let filePath = documentsDirectoryPath.stringByAppendingPathComponent(selectedFile.filename)
        
        showProgressBar()
        
        dbRestClient.loadFile(selectedFile.path, intoPath: filePath as String)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cellShown![indexPath.row] {
            return
        }
        cellShown![indexPath.row] = true
        cell.alpha = 0
        UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
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

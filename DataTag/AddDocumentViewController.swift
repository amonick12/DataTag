//
//  AddDocumentViewController.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/16/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit

protocol AddDocumentDelegate {
    func documentWasAdded()
    func imageWasAdded()
}

class AddDocumentViewController: UITableViewController, DBRestClientDelegate, ConfirmDocumentDelegate, ConfirmImageDelegate {
    
    var delegate: AddDocumentDelegate?
    var dbRestClient: DBRestClient!
    var dropboxMetadata: DBMetadata!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var connectButton: UIBarButtonItem!
    var refresher: UIRefreshControl!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var selectedFileName: String?
    var selectedMimeType: String?
    
    var cellShown: [Bool]?
    
    var onlyImages: Bool = false
    var imageContents: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if onlyImages {
            navTitle.title = "Select Image"
        }
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSizeMake(350.0, 450.0)

        }
    }
    
    func documentWasAdded() {
        delegate?.documentWasAdded()
    }
    
    func imageWasAdded() {
        delegate?.imageWasAdded()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "confirmDocumentSegue" {
            if let destination = segue.destinationViewController as? ConfirmDocumentViewController {
                destination.filename = selectedFileName!
                destination.mimeType = selectedMimeType!
                destination.delegate = self
                //destination.delegate = self
                //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            }
        } else if segue.identifier == "showImageSegue" {
            let destination = segue.destinationViewController as! ConfirmImageViewController
            
            let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            let filePath = documentsDirectoryPath.stringByAppendingPathComponent(selectedFileName!)
            
            if let fileData = NSFileManager.defaultManager().contentsAtPath(filePath as String) {
                let data = fileData
                let image = UIImage(data: data)
                destination.image = image
                destination.delegate = self
            } else {
                println("Error loading file")
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
            var uploadFilename: String?
            var sourcePath: String?
            if onlyImages {
                let uploadFilename = "cloud.jpg"
                let sourcePath = NSBundle.mainBundle().pathForResource("cloud", ofType: "jpg")
            } else {
                let uploadFilename = "Getting Started.rtf"
                let sourcePath = NSBundle.mainBundle().pathForResource("Getting Started", ofType: "rtf")
            }
            
            let destinationPath = "/"
            
            self.showProgressBar()
            self.dbRestClient.uploadFile(uploadFilename, toPath: destinationPath, withParentRev: nil, fromPath: sourcePath)
        }
        if onlyImages {
            imageContents = [AnyObject]()
            for content in metadata.contents {
                if let filename = content.filename {
                    if filename!.hasSuffix("png") || filename!.hasSuffix("jpg") {
                        println(filename)
                        imageContents!.append(content)
                    }
                }
            }
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
        if onlyImages {
            performSegueWithIdentifier("showImageSegue", sender: nil)
        } else {
            performSegueWithIdentifier("confirmDocumentSegue", sender: nil)
        }
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
                self.imageContents = nil
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
//        if onlyImages {
//            if let metadata = dropboxMetadata {
//                var count = 0
//                for content in metadata.contents {
//                    let filename = content.filename
//                    if filename!!.hasSuffix(".png") || filename!!.hasSuffix(".jpg") {
//                        count++
//                    }
//                }
//                return count
//            }
//        } else {
//            if let metadata = dropboxMetadata {
//                return metadata.contents.count
//            }
//        }
        if onlyImages {
            if imageContents != nil {
                return imageContents!.count
            }
        } else {
            if let metadata = dropboxMetadata {
                return metadata.contents.count
            }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddDocumentCell", forIndexPath: indexPath) as! UITableViewCell
        
        if onlyImages {
            if imageContents != nil {
                let currentFile: DBMetadata = imageContents![indexPath.row] as! DBMetadata
                cell.textLabel?.text = currentFile.filename
            }
            
        } else {
            let currentFile: DBMetadata = dropboxMetadata.contents[indexPath.row] as! DBMetadata
            cell.textLabel?.text = currentFile.filename
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedFile: DBMetadata?
        if onlyImages {
            selectedFile = imageContents![indexPath.row] as? DBMetadata
        } else {
            selectedFile = dropboxMetadata.contents[indexPath.row] as? DBMetadata
        }
        
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let filePath = documentsDirectoryPath.stringByAppendingPathComponent(selectedFile!.filename)
        
        showProgressBar()
        
        dbRestClient.loadFile(selectedFile!.path, intoPath: filePath as String)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cellShown![indexPath.row] {
            return
        }
        cellShown![indexPath.row] = true
        cell.alpha = 0
        UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
    }

}

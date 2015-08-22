//
//  WebpagesTableViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/28/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse
import Foundation

protocol WebpagesDelegate {
    func webpageObjectSelected(urlObject: AnyObject)
    func shareWithQRCode(object: AnyObject, cell: UICollectionViewCell)
    //func uploadToDropbox(dataObject: AnyObject)
    func webpageRemoved(index: Int, segmentControlIndex: Int)
    func broadcastAsBeacon(dataObject: AnyObject)
    func shareWithLocation(object: AnyObject, cell: UICollectionViewCell)
}

class WebpagesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, WebpageCollectionViewCellDelegate {

    var delegate: WebpagesDelegate?
    var viewController: UIViewController?
    var segmentControlIndex: Int?
    var webpages: [AnyObject]?
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedTitle: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let longPressRec = UILongPressGestureRecognizer()
        longPressRec.addTarget(self, action: "handleLongPress:")
        longPressRec.minimumPressDuration = 0.5
        longPressRec.delegate = self
        longPressRec.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressRec)
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        //        if sender.state != UIGestureRecognizerState.Ended {
        //            return
        //        }
        println("long press")
        let point: CGPoint = sender.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(point)
        if indexPath == nil {
            println("could not find index path")
        } else {
            
            showDataOptions(indexPath!)
            
        }
        
    }
    
    func showDataOptions(indexPath: NSIndexPath) {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! WebpageCollectionViewCell
        //let image = cell.imageView.image
        
        let selectedObject = self.webpages![indexPath.row] as! PFObject
        let title = selectedObject["title"] as! String
        let urlString = selectedObject["url"] as! String
        println(title)
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let shareImage = UIAlertAction(title: "Share with QR Code", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            println("share \(title) with QR")
            self.delegate?.shareWithQRCode(selectedObject, cell: cell as UICollectionViewCell)
        })
        alertController.addAction(shareImage)
        
        if segmentControlIndex == 0 {
            let locationAction = UIAlertAction(title: "Share with Location", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                self.delegate?.shareWithLocation(selectedObject, cell: cell)
            })
            alertController.addAction(locationAction)
        } else {
            let beaconAction = UIAlertAction(title: "Broadcast as Beacon", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                println("broadcast \(title) as beacon")
                //self.delegate?.shareWithQRCode(selectedDocument, cell: cell!)
                self.delegate?.broadcastAsBeacon(selectedObject)
            })
            alertController.addAction(beaconAction)

        }
        
        let addBookmark = UIAlertAction(title: "Open with Safari", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            //println("add \(title) as Bookmark")
            self.selectedTitle = title
            let bookmarkCreationOption = NSURLBookmarkCreationOptions.MinimalBookmark
            let url = NSURL(string: urlString)!
            //let bookmarkData = url.bookmarkDataWithOptions(bookmarkCreationOption, includingResourceValuesForKeys: nil, relativeToURL: nil, error: nil)
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
            //NSURL.writeBookmarkData(bookmarkData, toURL: <#NSURL#>, options: <#NSURLBookmarkFileCreationOptions#>, error: <#NSErrorPointer#>)
        })
        alertController.addAction(addBookmark)
        
        let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            println("remove button tapped")
            
            var relation = selectedObject.relationForKey("unlockedBy")
            relation.removeObject(PFUser.currentUser()!)
            selectedObject.saveInBackground()
            relation = PFUser.currentUser()!.relationForKey("sharedData")
            relation.removeObject(selectedObject)
            relation = PFUser.currentUser()!.relationForKey("unlockedData")
            relation.removeObject(selectedObject)
            PFUser.currentUser()!.saveInBackground()
            self.webpages?.removeAtIndex(indexPath.row)
            self.delegate?.webpageRemoved(indexPath.row, segmentControlIndex: self.segmentControlIndex!)
            self.collectionView.reloadData()
            
        })
        alertController.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(alert :UIAlertAction!) in
            println("cancel button tapped")
            
        })
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = cell
        alertController.popoverPresentationController?.sourceRect = cell.bounds
        self.viewController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func configureWithData() {
        println("URL Data Configure")
        self.collectionView.reloadData()
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if webpages != nil {
            return webpages!.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("WebpageCollectionCell", forIndexPath: indexPath) as! WebpageCollectionViewCell
        let webpage = self.webpages![indexPath.row] as! PFObject
        //let mimeType = image["mimeType"] as! String
        let webpageTitle = webpage["title"] as! String
        //cell.titleLabel.text = webpageTitle
        
        let file = webpage["fileData"] as! PFFile
        file.getDataInBackgroundWithBlock ({
            (data: NSData?, error: NSError?) -> Void in
            //self.progressBar.hidden = true
            if error == nil {
                cell.screenshotImageView.image = UIImage(data: data!)
                cell.screenshotImageView.backgroundColor = UIColor.clearColor()
                cell.indexPath = indexPath
                cell.titleButton.setTitle(webpageTitle, forState: .Normal)
                cell.delegate = self
            } else { println("Error loading image data") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                //self.progressBar.progress = Float(percentDone)/100
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.webpageObjectSelected(webpages![indexPath.row])
    }

    func titleButtonPressed(indexPath: NSIndexPath) {
        showDataOptions(indexPath)
    }

}

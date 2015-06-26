//
//  DocuementsTableViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/19/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

protocol DocumentsDelegate {
    func documentObjectSelected(documentObject: AnyObject)
    func shareWithQRCode(object: AnyObject, cell: UICollectionViewCell)
}

class DocumentsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    var delegate: DocumentsDelegate?
    var viewController: UIViewController?
    
    var documents: [AnyObject]?
    @IBOutlet weak var collectionView:UICollectionView!

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
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath!)

            let selectedDocument = self.documents![indexPath!.row] as! PFObject
            let filename = selectedDocument["filename"] as! String
            println(filename)
            
            let alertController = UIAlertController(title: filename, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let shareDocument = UIAlertAction(title: "Share with QR Code", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                println("share \(filename) with QR")
                self.delegate?.shareWithQRCode(selectedDocument, cell: cell!)
            })
            alertController.addAction(shareDocument)

            let addDocument = UIAlertAction(title: "Add To Dropbox", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                println("add \(filename) to dropbox")
            })
            alertController.addAction(addDocument)
            
            let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                println("remove button tapped")
                
                var relation = selectedDocument.relationForKey("unlockedBy")
                relation.removeObject(PFUser.currentUser()!)
                selectedDocument.saveInBackground()
                relation = PFUser.currentUser()!.relationForKey("sharedData")
                relation.removeObject(selectedDocument)
                relation = PFUser.currentUser()!.relationForKey("unlockedData")
                relation.removeObject(selectedDocument)
                PFUser.currentUser()!.saveInBackground()
                self.documents?.removeAtIndex(indexPath!.row)
                self.collectionView.reloadData()

            })
            alertController.addAction(removeAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(alert :UIAlertAction!) in
                println("cancel button tapped")
                
            })
            alertController.addAction(cancelAction)
            
            alertController.popoverPresentationController?.sourceView = cell
            alertController.popoverPresentationController?.sourceRect = cell!.bounds
            self.viewController!.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }

    func configureWithData() {
        println("Documents Data Configure")
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
        if documents != nil {
            return documents!.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DocumentCollectionCell", forIndexPath: indexPath) as! DocumentCollectionViewCell
        let document = self.documents![indexPath.row] as! PFObject
        let mimeType = document["mimeType"] as! String
        let file = document["fileData"] as! PFFile
        file.getDataInBackgroundWithBlock ({
            (data: NSData?, error: NSError?) -> Void in
            //self.progressBar.hidden = true
            if error == nil {
                cell.webview.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
                cell.webview.backgroundColor = UIColor.clearColor()

            } else { println("Error loading document data") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                //self.progressBar.progress = Float(percentDone)/100
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.documentObjectSelected(documents![indexPath.row])
    }

}

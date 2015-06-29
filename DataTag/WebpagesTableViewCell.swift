//
//  WebpagesTableViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/28/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

protocol WebpagesDelegate {
    func webpageObjectSelected(urlObject: AnyObject)
    func shareWithQRCode(object: AnyObject, cell: UICollectionViewCell)
    //func uploadToDropbox(dataObject: AnyObject)
    func webpageRemoved(index: Int, segmentControlIndex: Int)
}

class WebpagesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

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
        
        let selectedImage = self.webpages![indexPath.row] as! PFObject
        let title = selectedImage["title"] as! String
        println(title)
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let shareImage = UIAlertAction(title: "Share with QR Code", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            println("share \(title) with QR")
            self.delegate?.shareWithQRCode(selectedImage, cell: cell as UICollectionViewCell)
        })
        alertController.addAction(shareImage)
        
//        let addImage = UIAlertAction(title: "Add to Photo Library", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
//            println("add \(title) to Photo Library")
//            self.selectedTitle = title
//            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
//            
//        })
//        alertController.addAction(addImage)
        
        let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            println("remove button tapped")
            
            var relation = selectedImage.relationForKey("unlockedBy")
            relation.removeObject(PFUser.currentUser()!)
            selectedImage.saveInBackground()
            relation = PFUser.currentUser()!.relationForKey("sharedData")
            relation.removeObject(selectedImage)
            relation = PFUser.currentUser()!.relationForKey("unlockedData")
            relation.removeObject(selectedImage)
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


}

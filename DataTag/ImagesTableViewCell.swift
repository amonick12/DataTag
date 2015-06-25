//
//  ImagesTableViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/24/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

protocol ImagesDelegate {
    func imageObjectSelected(imageObject: AnyObject)
}

class ImagesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    var delegate: ImagesDelegate?
    var viewController: UIViewController?
    
    var images: [AnyObject]?
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
            let imageToDelete = self.images![indexPath!.row] as! PFObject
            let title = imageToDelete["title"] as! String
            println(title)
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let shareImage = UIAlertAction(title: "Share with QR Code", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                println("share \(title) with QR")
            })
            alertController.addAction(shareImage)
            
            let addImage = UIAlertAction(title: "Add to Photo Library", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                println("add \(title) to Photo Library")
            })
            alertController.addAction(addImage)
            
            let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                println("remove button tapped")
                
                var relation = imageToDelete.relationForKey("unlockedBy")
                relation.removeObject(PFUser.currentUser()!)
                imageToDelete.saveInBackground()
                relation = PFUser.currentUser()!.relationForKey("sharedData")
                relation.removeObject(imageToDelete)
                relation = PFUser.currentUser()!.relationForKey("unlockedData")
                relation.removeObject(imageToDelete)
                PFUser.currentUser()!.saveInBackground()
                self.images?.removeAtIndex(indexPath!.row)
                self.collectionView.reloadData()
                
            })
            alertController.addAction(removeAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(alert :UIAlertAction!) in
                println("cancel button tapped")
                
            })
            alertController.addAction(cancelAction)
            
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath!)
            
            alertController.popoverPresentationController?.sourceView = cell
            alertController.popoverPresentationController?.sourceRect = cell!.bounds
            self.viewController!.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    func configureWithData() {
        println("Images Data Configure")
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
        if images != nil {
            return images!.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCollectionCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let image = self.images![indexPath.row] as! PFObject
        //let mimeType = image["mimeType"] as! String
        let file = image["fileData"] as! PFFile
        file.getDataInBackgroundWithBlock ({
            (data: NSData?, error: NSError?) -> Void in
            //self.progressBar.hidden = true
            if error == nil {
                cell.imageView.image = UIImage(data: data!)
                
            } else { println("Error loading image data") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                //self.progressBar.progress = Float(percentDone)/100
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.imageObjectSelected(images![indexPath.row])
    }
    
}

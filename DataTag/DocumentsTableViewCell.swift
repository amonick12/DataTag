//
//  DocuementsTableViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/19/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse

class DocumentsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    var documents: [AnyObject]?
    @IBOutlet weak var collectionView:UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
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
                
            } else { println("Error loading document data") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                //self.progressBar.progress = Float(percentDone)/100
        })
        
        return cell
    }
    

}

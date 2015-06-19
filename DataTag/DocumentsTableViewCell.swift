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
        collectionView.delegate = self
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DocumentCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        
        return cell
    }
    

}

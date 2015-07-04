//
//  ImageCollectionViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/24/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit

protocol ImageCollectionViewCellDelegate {
    func titleButtonPressed(indexPath: NSIndexPath)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var delegate: ImageCollectionViewCellDelegate?
    var indexPath: NSIndexPath?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func titleButtonPressed(sender: AnyObject) {
        delegate?.titleButtonPressed(indexPath!)
    }
}

//
//  WebpageCollectionViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/28/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit

protocol WebpageCollectionViewCellDelegate {
    func titleButtonPressed(indexPath: NSIndexPath)
}

class WebpageCollectionViewCell: UICollectionViewCell {
    
    var delegate: WebpageCollectionViewCellDelegate?
    var indexPath: NSIndexPath?
    
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func titleButtonPressed(sender: AnyObject) {
        delegate?.titleButtonPressed(indexPath!)
    }
}

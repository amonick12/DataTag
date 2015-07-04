//
//  DocumentCollectionViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 6/20/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit

protocol DocumentCollectionViewCellDelegate {
    func titleButtonPressed(indexPath: NSIndexPath)
}

class DocumentCollectionViewCell: UICollectionViewCell {
    
    var delegate: DocumentCollectionViewCellDelegate?
    var indexPath: NSIndexPath?
    
    @IBOutlet weak var webview: UIWebView!
    
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func titleButtonPressed(sender: AnyObject) {
        delegate?.titleButtonPressed(indexPath!)
    }
}

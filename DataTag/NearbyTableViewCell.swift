//
//  NearbyTableViewCell.swift
//  DataTag
//
//  Created by Aaron Monick on 7/4/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit

protocol NearbyTableViewCellDelegate {
    func addDataButtonPressed(indexPath: NSIndexPath)
}
class NearbyTableViewCell: UITableViewCell {

    var delegate: NearbyTableViewCellDelegate?
    var indexPath: NSIndexPath?
    var data: AnyObject?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        delegate?.addDataButtonPressed(indexPath!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}

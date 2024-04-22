//
//  MessageCell.swift
//  WanderWise
//
//  Created by L V on 4/22/24.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            bubbleView.layer.cornerRadius = 12
            bubbleView.layer.masksToBounds = true
        }
    

}

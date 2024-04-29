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
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        addSubview(bubbleView)
        bubbleView.layer.cornerRadius = 15
        //bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        //messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        if isUserMessage {
//            leadingConstraint!.isActive = true
//            trailingConstraint!.isActive = false
//        } else {
//            leadingConstraint!.isActive = false
//            trailingConstraint!.isActive = true
//        }
        
        var constraints: [NSLayoutConstraint] = []
        
        // set up some constraints for our message and lable
//        constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
//                       messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
//                       messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
//                       messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
//                       
//                       bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
//                       bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
//                       bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
//                       bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
//        ]
//        
//        NSLayoutConstraint.activate(constraints)
        
//        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
//        leadingConstraint.isActive = false
//        
//        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
//        trailingConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

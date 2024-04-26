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
       
        addSubview(bubbleView)
        bubbleView.layer.cornerRadius = 15
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // set up some constraints for our message and lable
        let constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        messageLabel.widthAnchor.constraint(equalToConstant: 250),
                           
       bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
       bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
       bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
       bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

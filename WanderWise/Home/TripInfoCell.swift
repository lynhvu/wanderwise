//
//  TripInfoCell.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 4/26/24.
//

import UIKit

class TripInfoCell: UITableViewCell {
    
    @IBOutlet weak var tripTitleLabel: UILabel!
    @IBOutlet weak var tripDetailsLabel: UILabel!
    @IBOutlet weak var ongoingTagView: UIView!
    
    var cellHeight: CGFloat = 60
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

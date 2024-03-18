//
//  ItinerarySectionHeaderTableViewCell.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/5/24.
//

import UIKit

class ItinerarySectionHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

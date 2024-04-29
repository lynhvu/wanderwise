//
//  EventDetailViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 4/17/24.
//

import UIKit

class EventDetailViewController: UIViewController {

    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    
    var selectedEvent: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        dateLabel.text = "\(dateFormatter.string(from: selectedEvent.date))"
        timeLabel.text = "\(timeFormatter.string(from: selectedEvent.startTime))"
        titleLabel.text = selectedEvent.name
        locationLabel.text = selectedEvent.location
        notesLabel.text = selectedEvent.description
    }

}

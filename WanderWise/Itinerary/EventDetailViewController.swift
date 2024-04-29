//
//  EventDetailViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 4/17/24.
//

import UIKit
import GoogleMaps

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
    
    @IBAction func directionsButtonPressed(_ sender: Any) {
        openGoogleMapsDirections(placeName: locationLabel.text!)
    }
    
    // Function to open Google Maps with directions given a place's name
    func openGoogleMapsDirections(placeName: String) {
        // Construct the URL with the place's name
        let encodedPlaceName = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://www.google.com/maps/dir/?api=1&destination=\(encodedPlaceName)"

        if let url = URL(string: urlString) {
            // Check if Google Maps app is installed, if yes, open with directions
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // If Google Maps app is not installed, open in browser
                UIApplication.shared.open(URL(string: "https://maps.google.com/?q=\(encodedPlaceName)")!, options: [:], completionHandler: nil)
            }
        }
    }
}

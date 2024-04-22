//
//  ItineraryViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/4/24.
//

import UIKit

class ItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    
    var trip: Trip!
    
    let dateFormatter = DateFormatter()
    
    var shouldHideBackButton: Bool = false
    
    var selectedEvent: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: -25, left: 0, bottom: 0, right: 0)

        
        titleLabel.text = trip.name
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        updateDateLabel()
        
        if shouldHideBackButton {
            self.navigationItem.hidesBackButton = true
        }
        
        chatButton.layer.cornerRadius = 0.5 * chatButton.bounds.size.width
        chatButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateDateLabel()
    }
    
    // returns the amount of events for each day
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.days[section].events.count
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = trip.days[indexPath.section].events[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "EventDetailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? ItineraryTableViewCell else {
            return UITableViewCell()
        }
        
        let event = trip.days[indexPath.section].events[indexPath.row]
        cell.titleLabel?.text = event.name
        cell.locationLabel?.text = event.location
        cell.notesLabel.text = event.description // Assuming notesLabel is equivalent to description
        
        // For displaying start time and end time, you might need to format the Date object
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        cell.timeLabel.text = "\(timeFormatter.string(from: event.startTime))"
        
        return cell
    }
    
    // the amount of days in a trip is how many sections we want
    func numberOfSections(in tableView: UITableView) -> Int {
        trip.days.count
    }
    
    // custom view for section header cells
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as? ItinerarySectionHeaderTableViewCell else {
            return nil
        }
        
        let day = trip.days[section]
        cell.dayLabel.text = "Day \(section + 1)"
        cell.dateLabel.text = dateFormatter.string(from: day.date)
        cell.contentView.backgroundColor = UIColor(red: 249/255, green: 219/255, blue: 189/255, alpha: 1)
        
        return cell.contentView
    }
    
    func updateDateLabel() {
        if let startDate = trip.days.first?.date, let endDate = trip.days.last?.date {
            let formattedStartDate = dateFormatter.string(from: startDate)
            let formattedEndDate = dateFormatter.string(from: endDate)
            dateLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditItinerarySegueIdentifier",
           let destination = segue.destination as? EditItineraryViewController {
            destination.trip = trip
        } else if segue.identifier == "ChatSegue",
                  let destination = segue.destination as? ChatViewController {
            destination.trip = trip
        } else if segue.identifier == "EventDetailSegue",
                  let destination = segue.destination as? EventDetailViewController {
            destination.selectedEvent = selectedEvent
            
        }
    }
}

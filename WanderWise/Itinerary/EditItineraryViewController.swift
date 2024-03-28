//
//  EditItineraryViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/6/24.
//

import UIKit

class EditItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addEventButton: UIButton!
    
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        if trip == nil {
            trip = upcomingTrips[0]
        }
        titleLabel.text = trip.tripName
        dateLabel.text = "\(trip.days[0].date) - \(trip.days[trip.days.count - 1].date)"
        
        addEventButton.layer.cornerRadius = 0.5 * addEventButton.bounds.size.width
        addEventButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // returns the amount of events for each day
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.days[section].events.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? ItineraryTableViewCell
    
        // get the right day and event
        let day = indexPath.section
        let eventIndex = indexPath.row
        let event = trip.days[day].events[eventIndex]
        
        // populate cell with the correct labels
        cell?.titleLabel?.text = event.title
        cell?.locationLabel?.text = event.location
        cell?.notesLabel.text = event.notes
        cell?.timeLabel.text = event.time
        return cell!
    }
    
    // the amount of days in a trip is how many sections we want
    func numberOfSections(in tableView: UITableView) -> Int {
        trip.days.count
    }
    
    // custom view for section header cells
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as? ItinerarySectionHeaderTableViewCell
        cell?.dayLabel.text = "Day " + String(section + 1)
        cell?.dateLabel.text = trip.days[section].date
        return cell
    }
    
    func addEventToTrip(date: String, event: TripEvent) {
        // look for right date
        var dateFound = false
        for day in trip.days {
            if day.date == date {
                day.events.append(event)
                dateFound = true
            }
            if dateFound == false {
                let newDay = Day(date: date)
                newDay.events.append(event)
                trip.days.append(newDay)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EditEventViewController {
            destination.delegate = self
        }
    }

}

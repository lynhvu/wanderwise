//
//  EditItineraryViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/6/24.
//

import UIKit
import FirebaseFirestore

class EditItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addEventButton: UIButton!
    
    var trip: Trip!
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: -25, left: 0, bottom: 0, right: 0)
        
        titleLabel.text = trip.name
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        updateDateLabel()
        
        addEventButton.layer.cornerRadius = 0.5 * addEventButton.bounds.size.width
        addEventButton.clipsToBounds = true
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
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "EditEventSegueIdentifier", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? ItineraryTableViewCell else {
            return UITableViewCell()
        }
        
        let event = trip.days[indexPath.section].events[indexPath.row]
        cell.titleLabel?.text = event.name
        cell.locationLabel?.text = event.location
        cell.notesLabel.text = event.description
        
        // Assuming you have start and end time labels
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
    
    // swipe to delete an event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteAlert = UIAlertController(
                title: "Delete Event",
                message: "Are you sure you want to remove this event from your itinerary?",
                preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(
                title: "Cancel",
                style: .default))
            deleteAlert.addAction(UIAlertAction(
                title: "Delete",
                style: .destructive) {
                    _ in
                    self.trip.deleteEventInTrip(event: self.trip.days[indexPath.section].events[indexPath.row])
                    tableView.deleteRows(at: [indexPath], with: .fade)
                })
            self.present(deleteAlert, animated: true)
        }
    }
    
    func updateDateLabel() {
        if let startDate = trip.days.first?.date, let endDate = trip.days.last?.date {
            let formattedStartDate = dateFormatter.string(from: startDate)
            let formattedEndDate = dateFormatter.string(from: endDate)
            dateLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEventSegueIdentifier",
           let destination = segue.destination as? EditEventViewController,
           let indexPath = sender as? IndexPath {
            let selectedDay = trip.days[indexPath.section]
            let selectedEvent = selectedDay.events[indexPath.row]
            
            destination.trip = trip
            destination.selectedEvent = selectedEvent
        } else if segue.identifier == "AddEventSegueIdentifier",
                  let destination = segue.destination as? EditEventViewController {
            destination.trip = trip
            destination.selectedEvent = nil
        }
    }
    
}

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
    
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // set trip here ?
        titleLabel.text = trip.tripName
        dateLabel.text = trip.days[0].date
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
        cell?.dayLabel.text = "Day " + String(section)
        cell?.dateLabel.text = trip.days[section].date
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

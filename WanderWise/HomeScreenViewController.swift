//
//  HomeScreenViewController.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 3/18/24.
//

import UIKit

public var upcomingTrips = [Trip]()
public var pastTrips = [Trip]()

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingMessage: UILabel!
    @IBOutlet weak var noPastTripsLabel: UILabel!
    @IBOutlet weak var noUpcomingTripLabel: UILabel!
    @IBOutlet weak var pastTableView: UITableView!
    @IBOutlet weak var upcomingTableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    let segueID = "TripSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
        pastTableView.delegate = self
        pastTableView.dataSource = self
        
        //dummyData()
        
        if upcomingTrips.isEmpty {
            upcomingTableView.isHidden = true
        } else {
            noUpcomingTripLabel.isHidden = true
        }
        
        if pastTrips.isEmpty {
            pastTableView.isHidden = true
        } else {
            noPastTripsLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if upcomingTrips.count > 0 {
            upcomingTableView.isHidden = false
            noUpcomingTripLabel.isHidden = true
        }
        
        if pastTrips.count > 0 {
            pastTableView.isHidden = false
            noPastTripsLabel.isHidden = true
        }
        
        upcomingTableView.reloadData()
        pastTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == upcomingTableView {
            return upcomingTrips.count
        } else if tableView == pastTableView {
            return pastTrips.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        if tableView == upcomingTableView {
            cell.textLabel?.text = upcomingTrips[row].tripName
        } else if tableView == pastTableView {
            cell.textLabel?.text = pastTrips[row].tripName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID,
           let destination = segue.destination as? ItineraryViewController,
           let tripIndex = upcomingTableView.indexPathForSelectedRow?.row
        {
            destination.trip = upcomingTrips[tripIndex]
        }
    }
    
//    // Function to load dummy data onto arrays
//    func dummyData(){
//        upcomingTrips.append(Trip(name: "Spring break cruise!"))
//        upcomingTrips.append(Trip(name: "Holiday cabin"))
//        upcomingTrips.append(Trip(name: "Backpacking"))
//        upcomingTrips.append(Trip(name: "Washington and Ohio trip"))
//    }
}

//
//  HomeScreenViewController.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 3/18/24.
//

import UIKit
import FirebaseAuth

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingMessage: UILabel!
    @IBOutlet weak var noPastTripsLabel: UILabel!
    @IBOutlet weak var noUpcomingTripLabel: UILabel!
    @IBOutlet weak var pastTableView: UITableView!
    @IBOutlet weak var upcomingTableView: UITableView!
    
    var upcomingTrips = [Trip]()
    var pastTrips = [Trip]()
    
    let textCellIdentifier = "TextCell"
    let segueID = "TripSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
        pastTableView.delegate = self
        pastTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTrips()
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
        let trip = tableView == upcomingTableView ? upcomingTrips[indexPath.row] : pastTrips[indexPath.row]
        cell.textLabel?.text = trip.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: segueID, sender: (indexPath, tableView))
    }
    
    // MARK: - Fetching
    
    private func loadTrips() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }
        
        print("HomeScreenVC: LOADING UPCOMING TRIPS")
        
        Trip.getUpcomingTripsByUserId(userId: userId) { [weak self] trips in
            DispatchQueue.main.async {
                self?.upcomingTrips = trips ?? []
                self?.upcomingTableView.reloadData()
                self?.noUpcomingTripLabel.isHidden = !(self?.upcomingTrips.isEmpty ?? true)
                self?.upcomingTableView.isHidden = self?.upcomingTrips.isEmpty ?? true
            }
        }
        
        print("HomeScreenVC: LOADING PAST TRIPS")
        
        Trip.getPastTripsByUserId(userId: userId) { [weak self] trips in
            DispatchQueue.main.async {
                self?.pastTrips = trips ?? []
                self?.pastTableView.reloadData()
                self?.noPastTripsLabel.isHidden = !(self?.pastTrips.isEmpty ?? true)
                self?.pastTableView.isHidden = self?.pastTrips.isEmpty ?? true
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID,
           let destination = segue.destination as? ItineraryViewController,
           let (indexPath, tableView) = sender as? (IndexPath, UITableView) {
            
            let trip = tableView == upcomingTableView ? upcomingTrips[indexPath.row] : pastTrips[indexPath.row]
            destination.trip = trip
        }
    }
}

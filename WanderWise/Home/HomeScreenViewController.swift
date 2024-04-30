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
    
    var currUserProfile = UserProfile()
    
    let textCellIdentifier = "TripInfoCellIdentifier"
    let segueID = "TripSegueIdentifier"
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
        pastTableView.delegate = self
        pastTableView.dataSource = self
        
        updateWelcomeMessage()
        loadTrips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWelcomeMessage()
        loadTrips()
    }
    
    func updateWelcomeMessage(){
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }
        currUserProfile.getUserInfo(userId: userId) { error in
            if let error = error {
                print("Error getting user profile: \(error.localizedDescription)")
            } else {
                print("UserProfile info retrieved successfully")
                DispatchQueue.main.async {
                    self.greetingMessage.text = "Hello \(self.currUserProfile.firstName)!"
                }
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! TripInfoCell
        
        let trip: Trip
        if tableView == upcomingTableView {
            trip = upcomingTrips[indexPath.row]
            updateTripInfo(trip: trip, cell: cell)
            // Check if the trip is currently occurring
            if Date() >= trip.startDate && Date() <= trip.endDate {
                // Display ongoing tag
                cell.ongoingTagView.isHidden = false
            } else {
                // Reset the cell appearance if it's not an active trip
                cell.ongoingTagView.isHidden = true
            }
        } else if tableView == pastTableView {
            trip = pastTrips[indexPath.row]
            updateTripInfo(trip: trip, cell: cell)
            // Reset appearance for past trips
            cell.ongoingTagView.isHidden = true
        }
        
        return cell
    }
    
    func updateTripInfo(trip: Trip, cell: TripInfoCell){
        let formattedDateString = DateFormatter.localizedString(from: trip.startDate, dateStyle: .short, timeStyle: .none)
        let tripDetails = trip.location + " - " + formattedDateString
        
        cell.tripTitleLabel.text = trip.name
        cell.tripDetailsLabel.text = tripDetails
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: segueID, sender: (indexPath, tableView))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteAlert = UIAlertController(
                title: "Delete Trip",
                message: "Are you sure you want to remove this trip?",
                preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(
                title: "Cancel",
                style: .default))
            deleteAlert.addAction(UIAlertAction(
                title: "Delete",
                style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let trip = (tableView == self.upcomingTableView) ? self.upcomingTrips[indexPath.row] : self.pastTrips[indexPath.row]
                    
                    Trip.deleteTripById(tripId: trip.id) { error in
                        if let error = error {
                            print("Error deleting trip: \(error.localizedDescription)")
                        } else {
                            print("Trip successfully deleted")
                            DispatchQueue.main.async {
                                if tableView == self.upcomingTableView {
                                    self.upcomingTrips.remove(at: indexPath.row)
                                } else {
                                    self.pastTrips.remove(at: indexPath.row)
                                }
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                })
            self.present(deleteAlert, animated: true)
        }
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
    
    @IBAction func planTripButtonPressed(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
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

//
//  NewTripViewController.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 3/17/24.
//

import UIKit
import FirebaseAuth

class NewTripViewController: UIViewController {

    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createTripButtonPressed(_ sender: UIButton) {
        // Validate inputs
        guard let tripName = tripNameField.text, !tripName.isEmpty,
              let destination = destinationField.text, !destination.isEmpty else {
            showAlert(message: "Please enter a trip name and destination.")
            return
        }
        
        guard startDatePicker.date < endDatePicker.date else {
            showAlert(message: "The start date must be before the end date.")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not found. Please sign in.")
            return
        }
        
        // Generate days for each date between the start and end dates
        let dates = datesBetween(start: startDatePicker.date, end: endDatePicker.date)
        let days = dates.map { Day(date: $0, events: []) }
        
        // Create a new Trip object with the generated days
        let newTrip = Trip(id: UUID().uuidString, userId: userId, name: tripName, startDate: startDatePicker.date, endDate: endDatePicker.date, location: destination, days: days)
        
        // Save the new Trip to Firestore
        newTrip.saveToDatabase { error in
            if let error = error {
                self.showAlert(message: "Failed to save trip: \(error.localizedDescription)")
            } else {
                self.performSegue(withIdentifier: "CreatedItinerarySegue", sender: newTrip)
            }
        }
    }
    
    func datesBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = start
        
        let calendar = Calendar.current
        let oneDay = DateComponents(day: 1)
        
        while currentDate <= end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: oneDay, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatedItinerarySegue",
           let destination = segue.destination as? ItineraryViewController,
           let newTrip = sender as? Trip {
            destination.trip = newTrip
        }
    }
}

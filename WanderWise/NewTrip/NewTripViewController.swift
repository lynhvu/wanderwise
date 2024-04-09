//
//  NewTripViewController.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 3/17/24.
//

import UIKit
import FirebaseAuth
import GooglePlaces

class NewTripViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripNameField.delegate = self
        destinationField.delegate = self
    }
    
    
    @IBAction func specifyLocation(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue)))
        autocompleteController.placeFields = fields
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        // TODO: - Take off the dummy events
        let days = dates.map { date -> Day in
            // Add a dummy event for each day - replace "Dummy Event" and other properties as needed
            let dummyEvent = Event(name: "Dummy Event", date: date, startTime: date, location: "Dummy Location", description: "This is a dummy event. Replace with real event details.")
            return Day(date: date, events: [dummyEvent])
        }
        
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
            guard let nextDate = calendar.date(byAdding: oneDay, to: currentDate), nextDate <= end else { break }
            currentDate = nextDate
        }
        
        if !dates.contains(end) {
            dates.append(end)
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
            destination.shouldHideBackButton = true
        }
    }
}

extension NewTripViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        destinationField.text = place.name
        // TODO: save the placeID
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


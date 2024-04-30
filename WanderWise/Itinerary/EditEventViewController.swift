//
//  EditEventViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/6/24.
//

import UIKit
import GooglePlaces

class EditEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var eventTitleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var trip: Trip!
    
    var selectedEvent: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitleField.delegate = self
        locationField.delegate = self
        notesTextField.delegate = self
        
        datePicker.minimumDate = trip.startDate
        datePicker.maximumDate = trip.endDate
        
        // Set fields to previous values
        if let event = selectedEvent {
            eventTitleField.text = event.name
            locationField.text = event.location
            datePicker.date = event.date // Assuming your event has a single date
            timePicker.date = event.startTime // You might need a separate picker or method for end time if they differ
            notesTextField.text = event.description
        }
        
        // set rounded corners for the notes text field and save button
        notesTextField.layer.cornerRadius = 10
        notesTextField.clipsToBounds = true
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of UITextField or UITextView
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if selectedEvent == nil {
            createNewEvent()
        } else {
            updateExistingEvent()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateExistingEvent() {
        guard let event = selectedEvent,
              let title = eventTitleField.text, !title.isEmpty,
              let location = locationField.text, !location.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        let oldEvent = Event(name: event.name, date: event.date, startTime: event.startTime, location: event.location, description: event.description)
        
        // Update the existing Event object's properties
        event.name = title
        event.location = locationField.text ?? ""
        event.date = datePicker.date
        event.startTime = timePicker.date
        event.description = notesTextField.text
        
        // Now use the Trip method to update the event in its corresponding day
        trip.updateEventInTrip(updatedEvent: event)
        
        // Update notification if notifications are enabled
        NotificationService.shared.updateEventNotification(oldEvent: oldEvent, newEvent: event, in: trip)
    }
    
    private func createNewEvent() {
        guard let title = eventTitleField.text, !title.isEmpty,
              let location = locationField.text, !location.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        let newEvent = Event(name: title, date: datePicker.date, startTime: timePicker.date, location: location, description: notesTextField.text)
        
        trip.addEventToDay(event: newEvent, forDate: newEvent.date)
        
        // Schedule notification if notifications are enabled
        NotificationService.shared.scheduleNotification(for: newEvent, in: trip)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        locationField.text = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  EditEventViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/6/24.
//

import UIKit

class EditEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var eventTitleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var trip: Trip!
    
    var selectedEvent: Event?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitleField.delegate = self
        locationField.delegate = self
        notesTextField.delegate = self
        
        // Set fields to previous values
        if let event = selectedEvent {
            eventTitleField.text = event.name
            locationField.text = event.location
            datePicker.date = event.startTime // Assuming your event has a single date
            timePicker.date = event.startTime // You might need a separate picker or method for end time if they differ
            notesTextField.text = event.description
            
            deleteButton.isHidden = false
        } else {
            // don't give the option to delete event if it hasn't been saved yet
            deleteButton.isHidden = true
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
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
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
                // TODO: delete selectedEvent from db
            })
        self.present(deleteAlert, animated: true)
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if selectedEvent == nil {
            createNewEvent()
        } else {
            updateExistingEvent()
        }
        
        // Dismiss the view controller or pop back to the previous screen
        navigationController?.popViewController(animated: true)
    }
    
    private func updateExistingEvent() {
        guard let event = selectedEvent,
              let title = eventTitleField.text, !title.isEmpty,
              let location = locationField.text, !location.isEmpty else {
              showAlert(message: "Please fill out all fields.")
              return
          }
        
        // Update the existing Event object's properties
        event.name = title
        event.location = locationField.text ?? ""
        event.date = datePicker.date
        event.startTime = timePicker.date
        event.description = notesTextField.text
        
        // Now use the Trip method to update the event in its corresponding day
        trip.updateEventInTrip(updatedEvent: event)
    }
    
    private func createNewEvent() {
        guard let title = eventTitleField.text, !title.isEmpty,
              let location = locationField.text, !location.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        let newEvent = Event(name: title, date: datePicker.date, startTime: timePicker.date, location: location, description: notesTextField.text)
        
        trip.addEventToDay(event: newEvent, forDate: newEvent.startTime)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

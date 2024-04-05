//
//  EditEventViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/6/24.
//

import UIKit

class EditEventViewController: UIViewController {

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
        
        // Set fields to previous values
        if let event = selectedEvent {
            eventTitleField.text = event.name
            locationField.text = event.location
            datePicker.date = event.startTime // Assuming your event has a single date
            timePicker.date = event.startTime // You might need a separate picker or method for end time if they differ
            notesTextField.text = event.description
        }

        // set rounded corners for the notes text field and save button
        notesTextField.layer.cornerRadius = 10
        notesTextField.clipsToBounds = true
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let event = selectedEvent,
              let title = eventTitleField.text, !title.isEmpty else {
            // Handle empty title or missing event here, e.g., show an alert
            return
        }
        
        // Update the existing Event object's properties
        event.name = title
        event.location = locationField.text ?? ""
        event.startTime = datePicker.date
        event.endTime = timePicker.date // Adjust if your model supports different start/end times
        event.description = notesTextField.text
        
        // Now use the Trip method to update the event in its corresponding day
        trip.updateEventInTrip(updatedEvent: event)
        
        // Dismiss the view controller or pop back to the previous screen
        navigationController?.popViewController(animated: true)
    }

}

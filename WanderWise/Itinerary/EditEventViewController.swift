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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set rounded corners for the notes text field and save button
        notesTextField.layer.cornerRadius = 10
        notesTextField.clipsToBounds = true
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Ensure the title is not empty, adjust validation as necessary
        guard let title = eventTitleField.text, !title.isEmpty else {
            // Handle empty title, e.g., show an alert
            return
        }
        
        // Create a new Event object
        let newEvent = Event(
            name: title,
            startTime: timePicker.date,
            endTime: timePicker.date,
            location: locationField.text ?? "",
            description: notesTextField.text
        )
        
        // Assuming a method in Trip to add the event to the correct day
        // This method would find or create the Day object and add the Event to it, then save/update the Trip in Firestore
        trip.addEventToDay(event: newEvent, forDate: datePicker.date)
        
        // Dismiss the view controller or pop back to the previous screen
        navigationController?.popViewController(animated: true)
    }

}

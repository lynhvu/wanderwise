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
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var delegate: EditItineraryViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set rounded corners for the notes text field and save button
        notesTextField.layer.cornerRadius = 10
        notesTextField.clipsToBounds = true
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        let newEvent = TripEvent(title: eventTitleField.text!, location: locationField.text!, notes: notesTextField.text!, time: timeFormatter.string(from: datePicker.date))
       
        delegate.addEventToTrip(date: dateFormatter.string(from: datePicker.date), event: newEvent)
    }

}

//
//  NewTripViewController.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 3/17/24.
//

import UIKit
import FirebaseAuth
import GoogleGenerativeAI
import GooglePlaces

class NewTripViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var createTripButton: UIButton!
    
    var model: GenerativeModel!
    var chat: Chat!
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var days: [Day] = []
    var currDestinationPlaceId = ""
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripNameField.delegate = self
        destinationField.delegate = self
        
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = Date()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "h:mm a"
        
        activityIndicator.center = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tripNameField.text = ""
        destinationField.text = ""
        startDatePicker.date = Date()
        endDatePicker.date = Date()
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
        // error-checking
        guard let tripName = self.tripNameField.text, !tripName.isEmpty,
              let destination = self.destinationField.text, !destination.isEmpty else {
            self.showAlert(message: "Please enter a trip name and destination.")
            return
        }
        
        guard self.startDatePicker.date < self.endDatePicker.date else {
            self.showAlert(message: "The start date must be before the end date.")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            self.showAlert(message: "User not found. Please sign in.")
            return
        }
        
        // show activity indicator and block create trip button
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        createTripButton.isEnabled = false
        createTripButton.alpha = 0.85
        view.alpha = 0.85
        
        // AI Logic
        model = GenerativeModel(name: "gemini-pro", apiKey: getAPIKey())
        let itineraryPrompt = "Hi! You are my travel guide for my trip to \(destination) from \(startDatePicker.date) to \(endDatePicker.date). Please give me a full itinerary of places to eat for breakfast, lunch, and dinner as well as a mix of entertainment and attractions options for each so that the day is filled from 9am - 9pm with at least 6 different events. Only suggest places that include actual location names so that I don't have to do any research. Try not to include general areas and be as specific as possible about locations. Give me the result back in this format [date, time, type of event, location, notes]. The date format has to be year-month-day. For example, for a day in Austin, Texas, the result needs to look exactly like this for one of the events: [2024-04-09,8:00 AM,\"Food\",\"Bird Bird Biscuit\",\"The firebird biscuit is really popular\"] with no spaces in between sections. Do not include any extra information in the location section and do not include any additional sections. Do no deviate from this output format. And make sure that the type, location, and notes section are surrounded by quotation marks yet still comma separated from the location name. Do not leave a day empty. \n I want to separate the days by events so add a vertical line after listing all of the events for a day and make sure events are enclosed in []. An itinerary for a two day trip to Austin, Texas should look something like this: [2024-04-09,8:00 AM,\"Breakfast\",\"Bird Bird Biscuit\",\"The firebird biscuit is really popular\"] [2024-04-09,10:00 AM,\"Entertainment\",\"Lady Bird Lake\",\"Go kayaking\"] | [2024-04-10,8:00 AM,\"Brunch\",\"Dish Society\",\"New popular brunch place\"] [2024-04-10,10:00 AM,\"Attraction\",\"Capitol\",\"Take a tour of the state capitol\"] | \n Please try not to overlap any of the same locations for any of the days. Do not inlcude any other output."
        let history = [
            ModelContent(role: "user", parts: itineraryPrompt),
            ModelContent(role: "model", parts: "Yes I can do that.")
        ]
        chat = model.startChat(history: history)
        let dates = datesBetween(start: startDatePicker.date, end: endDatePicker.date)
        getModelResponse(newMessage: itineraryPrompt, tripName: tripName, userId: userId, destination: destination, dates: dates)
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
    
    func getModelResponse(newMessage: String, tripName: String, userId: String, destination: String, dates: [Date]) {
        Task {
            do {
                let response = try await self.chat.sendMessage(newMessage)
                if let text = response.text {
                    print(text)
                    addEventsToDay(itinerary: text, dates: dates)
                    
                    let newTrip = Trip(id: UUID().uuidString, userId: userId, name: tripName, startDate: self.startDatePicker.date, endDate: self.endDatePicker.date, location: destination, placeId: self.currDestinationPlaceId, days: self.days)
                    
                    // Save the new Trip to Firestore
                    newTrip.saveToDatabase { error in
                        if let error = error {
                            self.showAlert(message: "Failed to save trip: \(error.localizedDescription)")
                        } else {
                            self.performSegue(withIdentifier: "CreatedItinerarySegue", sender: newTrip)
                        }
                    }
                    
                    // remove activity indicator from view
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    createTripButton.isEnabled = true
                    createTripButton.alpha = 1
                    view.alpha = 1
                }
            } catch {
                print("\(error)")
            }
        }
    }
    
    func addEventsToDay(itinerary: String, dates: [Date]) {
        // get days in itinerary
        let daysString = itinerary.components(separatedBy: "|")
        var dateIndex = 0
        for day in daysString {
            let eventsString = day.components(separatedBy: "]")
            var events: [Event] = []
            var curDate: Date!
            // get events for each day
            for event in eventsString {
                let values = event.components(separatedBy: ",")
                if values.count == 5 {
                    curDate = dates[dateIndex]
                    // create new event
                    let newEvent = Event(name: String(values[2].dropFirst().dropLast()), date: curDate, startTime: timeFormatter.date(from: values[1])!, location: String(values[3].dropFirst().dropLast()), description: String(values[4].dropFirst().dropLast()))
                    events.append(newEvent)
                }
            }
            if events.count > 0 {
                // create new day with all the events
                let newDay = Day(date: curDate, events: events)
                days.append(newDay)
            }
            dateIndex += 1
        }
    }

}

extension NewTripViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        destinationField.text = place.name
        currDestinationPlaceId = place.placeID ?? ""
        /**
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
         **/
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
    
    /** Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }**/
    
}


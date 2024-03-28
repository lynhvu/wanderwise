//
//  NewTripViewController.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 3/17/24.
//

import UIKit

class NewTripViewController: UIViewController {

    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatedItinerarySegue",
           let destination = segue.destination as? ItineraryViewController {
            var newTrip = Trip(name: tripNameField.text!)
            upcomingTrips.append(newTrip)
            destination.trip = newTrip
        }
    }

}

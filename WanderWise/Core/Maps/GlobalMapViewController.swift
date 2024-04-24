//
//  GlobalMapViewController.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 4/8/24.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth

class GlobalMapViewController: UIViewController {
    
    let placesClient = GMSPlacesClient.shared()
    var mapView: GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }

        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 1)
        options.frame = view.bounds
        
        mapView = GMSMapView(options: options)
        view.addSubview(mapView!)
        
        loadUpcomingTrips(userId: userId)
        loadPreviousTrips(userId: userId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }
        loadUpcomingTrips(userId: userId)
    }
    
    func loadPreviousTrips(userId: String) {
        let customColor = UIColor(red: 0x7C/255.0, green: 0x90/255.0, blue: 0xA0/255.0, alpha: 1.0)
        Trip.getPastTripsByUserId(userId: userId) { trips in
            DispatchQueue.main.async {
                let previousTrips = trips ?? []
                self.displayTrips(trips: previousTrips, color: customColor)
            }
        }
    }
    
    func loadUpcomingTrips(userId: String) {
        let customColor = UIColor(red: 0xBA/255.0, green: 0x63/255.0, blue: 0x65/255.0, alpha: 1.0)
        Trip.getUpcomingTripsByUserId(userId: userId) { trips in
            DispatchQueue.main.async {
                let upcomingTrips = trips ?? []
                self.displayTrips(trips: upcomingTrips, color: customColor)
            }
        }
    }
    
    func displayTrips(trips: [Trip], color: UIColor) {
        let dispatchGroup = DispatchGroup()
        var tripPlaceMap: [Trip: GMSPlace] = [:]
        
        for trip in trips {
            let placeID = trip.placeId
            let fields: GMSPlaceField = [.name, .coordinate]
            
            dispatchGroup.enter() // Enter the Dispatch Group
            
            self.placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { place, error in
                defer {
                    dispatchGroup.leave() // Leave the Dispatch Group when the fetch is complete
                }
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    print("The selected place is: \(place.name ?? "Unknown")")
                    tripPlaceMap[trip] = place
                }
            }
        }
        
        // Notify when all fetches are complete
        dispatchGroup.notify(queue: .main) {
            // Now that all places have been fetched, display markers on the map
            for (trip, place) in tripPlaceMap {
                print("going in here!!")
                print(place.name ?? "no name for place")
                let position = place.coordinate
                let marker = GMSMarker(position: position)
                marker.title = trip.name
                marker.snippet = trip.location
                marker.icon = GMSMarker.markerImage(with: color)
                marker.map = self.mapView
            }
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

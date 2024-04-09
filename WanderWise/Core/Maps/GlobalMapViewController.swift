//
//  GlobalMapViewController.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 4/8/24.
//

import UIKit
import GoogleMaps

class GlobalMapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 1)
        options.frame = view.bounds
        
        let mapView = GMSMapView(options: options)
        view.addSubview(mapView)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
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

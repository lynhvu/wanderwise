//
//  NewTripViewController.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 3/17/24.
//

import UIKit

class NewTripViewController: UIViewController {
    @IBOutlet weak var accomodationsButton: UIButton!
    @IBOutlet weak var transportationButton: UIButton!
    @IBOutlet weak var attractionsButton: UIButton!
    @IBOutlet weak var entertainmentButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var createTripButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accomodationsButton.layer.cornerRadius = 20
        accomodationsButton.clipsToBounds = true
        transportationButton.layer.cornerRadius = 20
        transportationButton.clipsToBounds = true
        attractionsButton.layer.cornerRadius = 20
        attractionsButton.clipsToBounds = true
        entertainmentButton.layer.cornerRadius = 20
        entertainmentButton.clipsToBounds = true
        foodButton.layer.cornerRadius = 20
        foodButton.clipsToBounds = true
        createTripButton.layer.cornerRadius = 10
        createTripButton.clipsToBounds = true
    }
    
    @IBAction func attractionsButtonPressed(_ sender: Any) {
        attractionsButton.backgroundColor = .purple
        attractionsButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func entertainmentButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func foodButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func createTripButtonPressed(_ sender: Any) {
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

//
//  HomeScreenViewController.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 3/18/24.
//

import UIKit

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var greetingMessage: UILabel!
    @IBOutlet weak var noPastTripsLabel: UILabel!
    @IBOutlet weak var noUpcomingTripLabel: UILabel!
    @IBOutlet weak var pastTableView: UITableView!
    @IBOutlet weak var upcomingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* TODO:
         Right now, no data structre to hold upcoming and past trips.
         So, view just loads without the table views. Once data begins
         being stored, check if there are trips, if so, show table view,
         if not, show message.
         */
        upcomingTableView.isHidden = true
        pastTableView.isHidden = true
        
        
        
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   
}

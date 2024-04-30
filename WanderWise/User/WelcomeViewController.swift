//
//  WelcomeViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 4/5/24.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "WelcomeToHomeSegue", sender: self)
            }
        }
    }
    
}

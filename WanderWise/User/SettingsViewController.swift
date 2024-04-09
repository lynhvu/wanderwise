//
//  SettingsViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/27/24.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var imagePicker = UIImagePickerController()
    
    var currUserProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        
        imagePicker.delegate = self
        profileImageView.image = UIImage(named: "Image.png")
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        
        // load in user's profile information
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }
        
        if currUserProfile == nil {
            currUserProfile = UserProfile()
            currUserProfile?.getUserInfo(userId: userId) { error in
                if let error = error {
                        print("Error getting user profile: \(error.localizedDescription)")
                    } else {
                        print("UserProfile info retrieved successfully")
                        DispatchQueue.main.async {
                            print("NAME = " + self.currUserProfile!.name)
                            self.reflectUserInfo()
                        }
                    }
            }
        }
        reflectUserInfo()
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
    
    @IBAction func editPictureButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newProfilePic = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = newProfilePic
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Linh
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            let confirmAlert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)

            confirmAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                do {
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "LogoutToWelcomeScreenSegue", sender: self)
                    print("Handle Ok logic here")
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError)")
                    // Handle sign out error here
                }
            }))

            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))

            present(confirmAlert, animated: true, completion: nil)
        } 
    }
    
    
    
    @IBAction func nameEdit(_ sender: Any) {
        editInfo()
    }
    
    @IBAction func usernameEdit(_ sender: Any) {
        editInfo()
    }
    
    @IBAction func emailEdit(_ sender: Any) {
        editInfo()
    }
    
    @IBAction func notificationsEdit(_ sender: Any) {
        editInfo()
    }
    
    func editInfo(){
        cancelButton.isHidden = false
        saveButton.isHidden = false
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelButton.isHidden = true
        saveButton.isHidden = true
        reflectUserInfo()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let saveAlert = UIAlertController(
            title: "Save Information",
            message: "Are you sure you want to save this information to your profile? This action cannot be undone.",
            preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .destructive))
            saveAlert.addAction(UIAlertAction(
            title: "Save",
            style: .default) {
                _ in
                guard let userId = Auth.auth().currentUser?.uid else {
                    print("No user is currently signed in.")
                    return
                }
                let updatedUserProfile = UserProfile(
                    userId: userId,
                    name: self.nameField.text ?? "",
                    username: self.usernameField.text ?? "",
                    email: self.emailField.text ?? "",
                    notifications: self.notificationSwitch.isOn)
                updatedUserProfile.saveUserInfo(userId: userId){ error in
                    if let error = error {
                            // Handle error
                            print("Error saving user updated info: \(error.localizedDescription)")
                        } else {
                            // User info saved successfully
                            print("UserProfile updated info saved successfully")
                            self.currUserProfile = updatedUserProfile
                            self.reflectUserInfo()
                        }
                }
                self.cancelButton.isHidden = true
                self.saveButton.isHidden = true
            })
        self.present(saveAlert, animated: true)
    }
    
    func reflectUserInfo(){
        nameField.text = currUserProfile!.name
        usernameField.text = currUserProfile!.username
        emailField.text = currUserProfile!.email
        notificationSwitch.setOn(currUserProfile!.notifications, animated: false)
    }
    
    // TODO: add checks so the data they want to save is safe + figure out how to change email to account ?
}

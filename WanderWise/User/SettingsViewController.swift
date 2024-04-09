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
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var imagePicker = UIImagePickerController()
    
    var currUserProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        
        imagePicker.delegate = self
        profileImageView.image = UIImage(named: "Image.png")
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        
        emailField.isEnabled = false
        
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
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "LogoutToWelcomeScreenSegue", sender: self)
        } catch {
            print("sign out error")
        }
    }
    
    
    @IBAction func infoEdited(_ sender: Any) {
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
                    firstName: self.firstNameField.text ?? "",
                    lastName: self.lastNameField.text ?? "",
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
        firstNameField.text = currUserProfile!.firstName
        lastNameField.text = currUserProfile!.lastName
        usernameField.text = currUserProfile!.username
        emailField.text = currUserProfile!.email
        notificationSwitch.setOn(currUserProfile!.notifications, animated: false)
    }
    
    // TODO: add checks so the data they want to save is safe
}

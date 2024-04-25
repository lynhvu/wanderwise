//
//  ChatViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 4/6/24.
//

import UIKit
import GoogleGenerativeAI

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var messageFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    var trip: Trip!
    var model: GenerativeModel!
    var chat: Chat!
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        messageField.delegate = self
        tableView.reloadData()
        
        tableView.separatorStyle = .none
        
        scrollToBottom()
        
        // set up keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // set up the AI Model
        setUpModel()
    }
    
    func setUpModel() {
        messages = []
        
        model = GenerativeModel(name: "gemini-pro", apiKey: getAPIKey())
        
        let firstMessage = "Hi! Welcome to \(trip!.location)! I'm happy to be your tour guide during your trip, what would you like to know? I can give you recommendations for things to do, places to eat, or how to get around. Just let me know what you're interested in and I'll be happy to help."
        messages.append("\(firstMessage)")
        model = GenerativeModel(name: "gemini-pro", apiKey: getAPIKey())
        let history = [
            ModelContent(role: "user", parts: "You are my tour guide while I am visiting \(trip!.location). This is my current itinerary: \(trip!.toString()). Please answer any questions I may have."),
            ModelContent(role: "model", parts: messages[0]),
        ]
        chat = model.startChat(history: history)
      
    }
    
    // Handle keyboard show event
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
        let distance = keyboardFrame.height - view.safeAreaInsets.bottom
                
        // Animate movement of the message field
        UIView.animate(withDuration: 0.3) {
            self.messageFieldBottomConstraint.constant = distance
            self.sendButtonBottomConstraint.constant = distance
            self.view.layoutIfNeeded()
        }
    }
    
    // Handle keyboard hide event
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.messageFieldBottomConstraint.constant = 70
            self.sendButtonBottomConstraint.constant = 70
            self.view.layoutIfNeeded()
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
            
        // Determine if the message is from the user or the model
        let isUserMessage = indexPath.row % 2 == 1
        let hexColor = 0xBA6365
        
        
        // Set the bubble style based on the sender
        if isUserMessage {
            // set the color
            cell.bubbleView.backgroundColor = UIColor(
                red: CGFloat((hexColor & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((hexColor & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(hexColor & 0x0000FF) / 255.0, alpha: 1.0) // red for user
            cell.messageLabel.textColor = .white
           
            
        } else {
            // set the color
            cell.bubbleView.backgroundColor = UIColor(
                red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // Light gray for model
            cell.messageLabel.textColor = .black
        }
        
        // Set the message text
        cell.messageLabel.text = message
        
        return cell
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        // send user's message
        let newMessage = messageField.text!
        messages.append(newMessage)
        messageField.text = ""
        tableView.reloadData()
        scrollToBottom()
        
        // get model's message
        getModelResponse(newMessage: newMessage)
    }
    
    // Scroll to the bottom of the table view
    func scrollToBottom() {
        if !messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func getModelResponse(newMessage: String) {
        Task {
            do {
                let response = try await chat.sendMessage(newMessage)
                if let text = response.text {
                    messages.append(text)
                    print(text)
                    tableView.reloadData()
                    scrollToBottom()
                }
            } catch {
                print("\(error)")
            }
        }
    }

}

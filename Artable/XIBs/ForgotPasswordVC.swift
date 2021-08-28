//
//  ForgotPasswordVC.swift
//  Artable
//
//  Created by Maxim Mitin on 28.08.21.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty else {
            simpleAlert(title: "Error", message: "Please enter email")
            return
        }
        
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    debugPrint(error)
                    self.handleFireAuthError(error: error)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
    }
    
}

//
//  LoginVCViewController.swift
//  Artable
//
//  Created by Maxim Mitin on 27.08.21.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func forgotPassBtn(_ sender: Any) {
        let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty,
              let password = passwordTxt.text, password.isNotEmpty else {
            simpleAlert(title: "Error", message: "Please fill out all fields")
            return
        }
        
        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                
                self.activityIndicator.stopAnimating()
                return
            }
            
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func guestClicked(_ sender: Any) {
        
    }
}

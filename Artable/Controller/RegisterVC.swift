//
//  RegisterVC.swift
//  Artable
//
//  Created by Maxim Mitin on 27.08.21.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPassTxt: UITextField!
    
    @IBOutlet weak var passCheckImg: UIImageView!
    @IBOutlet weak var confirmPassCheckImg: UIImageView!
    
    
    @IBOutlet weak var activitiIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTxt.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControl.Event.editingChanged)
        confirmPassTxt.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControl.Event.editingChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChanged(_ textfield: UITextField){
        guard let passText = passwordTxt.text else {return}
        // Turn on-off password checkmarks
        if textfield == confirmPassTxt {
            passCheckImg.isHidden = false
            confirmPassCheckImg.isHidden = false
        } else {
            if passText.isEmpty {
                passCheckImg.isHidden = true
                confirmPassCheckImg.isHidden = true
                confirmPassTxt.text = ""
            }
        }
        // Checkmarks colors logic
        if passwordTxt.text == confirmPassTxt.text {
            passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
        } else {
            passCheckImg.image = UIImage(named: AppImages.RedCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.RedCheck)
        }
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty ,
              let username = usernameTxt.text, username.isNotEmpty ,
              let password = passwordTxt.text , password.isNotEmpty else {
            simpleAlert(title: "Error", message: "Please fill out all fields")
            return
        }
        
        guard let confirmPass = confirmPassTxt.text , confirmPass == password else {
            simpleAlert(title: "Error", message: "Passwords, do not match")
            return
        }
        
        activitiIndicator.startAnimating()
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        guard let authUser = Auth.auth().currentUser else {return}
        
        authUser.link(with: credential) { result, error in
            if let error = error {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            
            self.activitiIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

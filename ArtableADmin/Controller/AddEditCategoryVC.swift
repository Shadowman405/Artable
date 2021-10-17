//
//  AddEditCategoryVC.swift
//  ArtableADmin
//
//  Created by Maxim Mitin on 4.09.21.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditCategoryVC: UIViewController {
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!
    
    var categoryToEdit: Category?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImg.isUserInteractionEnabled = true
        categoryImg.addGestureRecognizer(tap)
        
        //if editing category category to edit != nil
        if let category = categoryToEdit {
            nameTxt.text = category.name
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: category.imgURL){
                categoryImg.contentMode = .scaleAspectFill
                categoryImg.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }
    

    @IBAction func addCategoryClicked(_ sender: Any) {
        uploadImageThenDocument()
    }
    
    func uploadImageThenDocument() {
        guard let image = categoryImg.image , let categoryName = nameTxt.text , categoryName.isNotEmpty else {
            simpleAlert(title: "Error", message: "Must add category image and name")
            return
        }
        
        activityIndicator.startAnimating()
        
        //Turn the img into data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        //Create storage img ref -< location in firestore for it ti be store
        let imageRef = Storage.storage().reference().child("/categoryImages/\(categoryName).jpg")
        
        //Set the metadata
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        //Upload data
        imageRef.putData(imageData, metadata: metaData) { metaData, error in
            if let error = error {
                self.handleError(error: error, message: "Unable to upload image")
                return
            }
            // When img uploaded , retrieve download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    self.handleError(error: error, message: "Unable to retrieve url for image")
                    return
                }
                
                guard let url = url else {return}
                print(url)
                //Upload new Category document to Firestore DB
                self.uploadDocument(url: url.absoluteString)
            }
        }
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var category = Category.init(name: nameTxt.text!,
                                     id: "",
                                     imgURL: url,
                                     timeStamp: Timestamp())
        if let categoryThatEditing = categoryToEdit {
            //edit existing
            docRef = Firestore.firestore().collection("categories").document(categoryThatEditing.id)
            category.id = categoryThatEditing.id
        } else {
            //new cat
            docRef = Firestore.firestore().collection("categories").document()
            category.id = docRef.documentID
        }
        
        let data = Category.modelToData(category: category)
        docRef.setData(data, merge: true) { error in
            if let error = error {
                self.handleError(error: error, message: "Unable to upload new category to Database")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleError(error: Error, message: String){
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", message: message)
        self.activityIndicator.stopAnimating()
    }
}

extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {return}
        categoryImg.contentMode = .scaleAspectFill
        categoryImg.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

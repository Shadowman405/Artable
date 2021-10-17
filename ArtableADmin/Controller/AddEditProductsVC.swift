//
//  AddEditProductsVC.swift
//  ArtableADmin
//
//  Created by Maxim Mitin on 4.09.21.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditProductsVC: UIViewController {
    
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var productPriceTxt: UITextField!
    @IBOutlet weak var productDescTxt: UITextView!
    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!
    
    var selectedCategory: Category!
    var productToEdit: Product?
    
    var productPrice = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTaped))
        tap.numberOfTapsRequired = 1
        productImgView.isUserInteractionEnabled = true
        productImgView.addGestureRecognizer(tap)
        
        if let product = productToEdit {
            productNameTxt.text = product.name
            productPriceTxt.text = "\(product.price)"
            productDescTxt.text = product.productDescription
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: product.imageURL){
                productImgView.contentMode = .scaleAspectFill
                productImgView.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imgTaped() {
        launchImgPicker()
    }
    
    
    @IBAction func addClicked(_ sender: Any) {
        uploadImgThanDocument()
    }
    
    func uploadImgThanDocument() {
        guard let img = productImgView.image,
              let productname = productNameTxt.text, productname.isNotEmpty,
              let productPrice = productPriceTxt.text, productPrice.isNotEmpty,
              let descText = productDescTxt.text, descText.isNotEmpty else {
            simpleAlert(title: "Error", message: "Must add product image,name,description and price")
            return
        }
        
        self.productPrice = Double(productPrice)!
        
        activityIndicator.startAnimating()
        
        guard let imageData = img.jpegData(compressionQuality: 0.2) else {return}
        let imageRef = Storage.storage().reference().child("/categoryImages/\(productname).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
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
        var product = Product.init(name: productNameTxt.text ?? "",
                                    id: "",
                                    category: selectedCategory.id,
                                    price: productPrice,
                                    productDesc: productDescTxt.text ?? "",
                                    imageURL: url,
                                    timeStamp: Timestamp(),
                                    stock: 0)
        if let productThatEditing = productToEdit {
            //edit existing
            docRef = Firestore.firestore().collection("products").document(productThatEditing.id)
            product.id = productThatEditing.id
        } else {
            //new cat
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }
        
        let data = Product.modelToData(product: product)
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


extension AddEditProductsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {return}
        productImgView.contentMode = .scaleAspectFill
        productImgView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

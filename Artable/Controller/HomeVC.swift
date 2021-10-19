//
//  ViewController.swift
//  Artable
//
//  Created by Maxim Mitin on 26.08.21.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var loginOutBtn: UIBarButtonItem!
    

    var categories = [Category]()
    var selectedCategory: Category!
    let db = Firestore.firestore()
    var listener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        setupInitialAnonUser()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            loginOutBtn.title = "Logout"
            if userService.userListener == nil {
                userService.getCurrentUser()
            }
        } else {
            loginOutBtn.title = "Login"
        }
        setCategoriesListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //turnoff realtime updates when app not active
        listener.remove()
        categories.removeAll()
        collectionView.reloadData()
    }
    
    func setupNavBar() {
        guard let font = UIFont(name: "futura", size: 26) else {return}
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font: font]
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Identifiers.CategoryCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.CategoryCell)
    }
    
    func setupInitialAnonUser() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    debugPrint(error)
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                }
            }
        }
    }
    
    func setCategoriesListener() {
        listener = db.categories.addSnapshotListener({ snap, error in
            
            if let error = error {
                debugPrint(error)
                return
            }
            
            snap?.documentChanges.forEach({ change in
                let data = change.document.data()
                let category = Category.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, category: category)
                case .modified:
                    self.onDocumentModified(change: change, category: category)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        })
    }
    
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: StoryboardID.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func loginOutClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {return}
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                userService.logoutUser()
                Auth.auth().signInAnonymously { result, error in
                    if let error = error {
                        debugPrint(error)
                        Auth.auth().handleFireAuthError(error: error, vc: self)
                    }
                    self.presentLoginController()
                }
            } catch {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint(error)
            }
        }
     }
}

// MARK: - Extensions

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CategoryCell, for: indexPath) as? CategoryCell {
            
            cell.configureCell(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let cellWidth = (width - 30) / 2
        let cellHeight = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: Segues.toProducts, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toProducts {
            if let destination = segue.destination as? ProductsVC {
                destination.category = selectedCategory
            }
        }
    }
    
    // Categories changes for VC
    
    func onDocumentAdded(change: DocumentChange, category: Category) {
        let newIndex = Int(change.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }

    func onDocumentModified(change: DocumentChange, category: Category) {
        if change.newIndex == change.oldIndex {
            //Item modified but stays on same position
            let index = Int(change.newIndex)
            categories[index] = category
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            //Item should change position
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            
            categories.remove(at: oldIndex)
            categories.insert(category, at: newIndex)
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
    }
}


//MARK: - Unused features


//    func fetchCollection () {
//        let collectionReference = db.collection("categories")
//
//        listener = collectionReference.addSnapshotListener { snap, error in
//            guard let documents = snap?.documents else {return}
//
//            self.categories.removeAll()
//            for document in documents {
//                let data = document.data()
//                let newCategory = Category.init(data: data)
//                self.categories.append(newCategory)
//            }
//            self.collectionView.reloadData()
//        }
    
//        collectionReference.getDocuments { snap, error in
//            guard let documents = snap?.documents else {return}
//            for document in documents {
//                let data = document.data()
//                let newCategory = Category.init(data: data)
//                self.categories.append(newCategory)
//            }
//            self.collectionView.reloadData()
//        }
//    }

//    func fetchDocument() {
//        let docRef = db.collection("categories").document("eiD0N78G6EwdZpCjql8s")
//        listener = docRef.addSnapshotListener { snap, error in
//            self.categories.removeAll()
//            guard let data = snap?.data() else {return}
//            let newCat = Category.init(data: data)
//            self.categories.append(newCat)
//            self.collectionView.reloadData()
//        }
//
//        docRef.getDocument { snap, error in
//            guard let data = snap?.data() else {return}
//            let newCategory = Category.init(data: data)
//            self.categories.append(newCategory)
//            self.collectionView.reloadData()
//        }
//    }

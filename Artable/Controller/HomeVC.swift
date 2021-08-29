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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let category = Category.init(name: "Animal",
                                     id: "random",
                                     imgURL: "https://images.unsplash.com/photo-1571391733814-15ac29ac3544?ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8Ym9hfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=900&q=60",
                                     isActive: true,
                                     timeStamp: Timestamp())
        let category2 = Category.init(name: "Animal",
                                     id: "random",
                                     imgURL: "https://images.unsplash.com/photo-1570741066052-817c6de995c8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8c25ha2V8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60",
                                     isActive: true,
                                     timeStamp: Timestamp())
        categories.append(category)
        categories.append(category2)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Identifiers.CategoryCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.CategoryCell)
        
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    debugPrint(error)
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            loginOutBtn.title = "Logout"
        } else {
            loginOutBtn.title = "Login"
        }
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
        let cellWidth = (width - 50) / 2
        let cellHeight = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

}

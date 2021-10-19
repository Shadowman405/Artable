//
//  UserService.swift
//  Artable
//
//  Created by Maxim Mitin on 19.10.21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let userService = _UserService()

class _UserService {
    //MARK:- variables
    
    var user = User()
    var favorites = [Product]()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener: ListenerRegistration? = nil
    var favoritesListener: ListenerRegistration? = nil
    
    var isGuest : Bool {
        guard let authUser = auth.currentUser else {
            return true
        }
        if authUser.isAnonymous {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - methods
    
    func getCurrentUser() {
        guard let authUser = auth.currentUser else {return}
        
        let userRef = db.collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ snap, error in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snap?.data() else {return}
            self.user = User.init(data: data)
            print(self.user)
        })
        
        //favorites reference
        
        let favsRef = userRef.collection("favorites")
        favoritesListener = favsRef.addSnapshotListener({ snap, error in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documents.forEach({ document in
                let favorite = Product.init(data: document.data())
                self.favorites.append(favorite)
            })
        })
    }
    
    func favoriteSelected(product: Product){
        let favsRef = Firestore.firestore().collection("users").document(user.id).collection("favorites")
        
        if favorites.contains(product){
            favorites.removeAll{$0 == product}
            favsRef.document(product.id).delete()
        } else {
            favorites.append(product)
            let data = Product.modelToData(product: product)
            favsRef.document(product.id).setData(data)
        }
    }
    
    func logoutUser() {
        userListener?.remove()
        userListener = nil
        favoritesListener?.remove()
        favoritesListener = nil
        user = User()
        favorites.removeAll()
    }
    
}

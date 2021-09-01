//
//  ProductsVC.swift
//  Artable
//
//  Created by Maxim Mitin on 29.08.21.
//

import UIKit
import FirebaseFirestore

class ProductsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var products = [Product]()
    var category: Category!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        
//        let product = Product(name: "Nature",
//                              id: "random",
//                              category: "Nature",
//                              price: 24.99,
//                              productDescription: "Boa - silent king",
//                              imageURL: "https://images.unsplash.com/photo-1538439907460-1596cafd4eff?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzB8fHNuYWtlfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=900&q=60",
//                              timeStamp: Timestamp(),
//                              stock: 0)
//        products.append(product)
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.ProductCell, bundle: nil), forCellReuseIdentifier: Identifiers.ProductCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setProductsListener()
    }
    
    func setProductsListener() {
        listener = db.products.addSnapshotListener({ snap, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ change in
                let data = change.document.data()
                let product = Product(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, product: product)
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        })
    }
    
}


extension ProductsVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.ProductCell, for: indexPath) as? ProductCell {
            cell.configureCell(product: products[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
// MARK: - Changes products via FB cloud
    
    func onDocumentAdded(change: DocumentChange, product: Product) {
        let newIndex = Int(change.newIndex)
        products.insert(product, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
    }

    func onDocumentModified(change: DocumentChange, product: Product) {
        if change.newIndex == change.oldIndex {
            //Item modified but stays on same position
            let index = Int(change.newIndex)
            products[index] = product
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            //Item should change position
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            
            products.remove(at: oldIndex)
            products.insert(product, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        products.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .automatic)
    }
}

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
    
    override func viewDidLoad() {
        
        let product = Product(name: "Nature",
                              id: "random",
                              category: "Nature",
                              price: 24.99,
                              productDescription: "Boa - silent king",
                              imageURL: "https://images.unsplash.com/photo-1538439907460-1596cafd4eff?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzB8fHNuYWtlfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=900&q=60",
                              timeStamp: Timestamp(),
                              stock: 0,
                              favorite: false)
        products.append(product)
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.ProductCell, bundle: nil), forCellReuseIdentifier: Identifiers.ProductCell)
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
}

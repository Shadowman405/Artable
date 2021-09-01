//
//  ProductCell.swift
//  Artable
//
//  Created by Maxim Mitin on 29.08.21.
//

import UIKit
import Kingfisher

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(product: Product) {
        productTitle.text = product.name
        productPrice.text = "\(product.price)"
        if let url = URL(string: product.imageURL) {
            productImg.kf.setImage(with: url)
        }
    }
    
    
    @IBAction func addToCartClicked(_ sender: Any) {
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
    }
    
}

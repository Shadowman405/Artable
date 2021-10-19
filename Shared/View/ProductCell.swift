//
//  ProductCell.swift
//  Artable
//
//  Created by Maxim Mitin on 29.08.21.
//

import UIKit
import Kingfisher


protocol ProductCellDelegate : AnyObject {
    func productFavorited(product: Product)
}

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    weak var delegate: ProductCellDelegate?
    private var product: Product!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(product: Product, delegate: ProductCellDelegate) {
        self.product = product
        self.delegate = delegate
        
        productTitle.text = product.name
        productPrice.text = "\(product.price)"
        if let url = URL(string: product.imageURL) {
            let placeholder = UIImage(named: AppImages.Placeholder)
            productImg.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            productImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        
        if userService.favorites.contains(product){
            favoriteBtn.setImage(UIImage(named: AppImages.FilledStar), for: .normal)
        } else {
            favoriteBtn.setImage(UIImage(named: AppImages.EmptyStar), for: .normal)
        }
    }
    
    
    @IBAction func addToCartClicked(_ sender: Any) {
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
        delegate?.productFavorited(product: product)
    }
    
}

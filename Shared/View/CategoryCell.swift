//
//  CategoryCell.swift
//  Artable
//
//  Created by Maxim Mitin on 29.08.21.
//

import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImg.layer.cornerRadius = 5
        
    }
    
    func configureCell(category: Category) {
        categoryLbl.text = category.name
        if let url = URL(string: category.imgURL) {
            categoryImg.kf.setImage(with: url)
        }
    }
}

//
//  ViewController.swift
//  ArtableADmin
//
//  Created by Maxim Mitin on 26.08.21.
//

import UIKit

class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
    }

    @objc func addCategory() {
        performSegue(withIdentifier: Segues.toAddEditCategory, sender: self)
    }
    
}


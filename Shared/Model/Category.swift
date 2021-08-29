//
//  Category.swift
//  Artable
//
//  Created by Maxim Mitin on 29.08.21.
//

import Foundation
import FirebaseFirestore

struct Category {
    var name : String
    var id: String
    var imgURL: String
    var isActive: Bool = true
    var timeStamp: Timestamp

}

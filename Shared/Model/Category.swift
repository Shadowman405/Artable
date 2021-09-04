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
    
    init(
        name: String,
        id: String,
        imgURL: String,
        isActive: Bool = true,
        timeStamp: Timestamp){
        self.name = name
        self.id = id
        self.imgURL = imgURL
        self.isActive = isActive
        self.timeStamp = timeStamp
    }
    

    init(data: [String:Any]) {
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.imgURL = data["imgURL"] as? String ?? ""
        self.isActive = data["isActive"] as? Bool ?? true
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(category: Category) -> [String:Any] {
        let data : [String:Any] = [
            "name" : category.name,
            "id": category.id,
            "imgURL": category.imgURL,
            "isActive": category.isActive,
            "timeStamp": category.timeStamp
        ]
        
        return data
    }
}

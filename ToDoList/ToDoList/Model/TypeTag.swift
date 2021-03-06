//
//  TypeTag.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/5/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TypeTag {
    var textTag: String = ""
    var backGround: String = ""
    var firebaseKey: String = ""
    var type: TypeCell = .nomal
    var createTime: Double = 0
    
    init(textTag: String, backGround: String, type: TypeCell = .nomal) {
        self.textTag = textTag
        self.backGround = backGround
        self.type = type
        self.firebaseKey = ""
        self.createTime = 0
    }
    
    init(data: JSON, firebaseKey: String) {
        self.textTag = data["textTag"].stringValue
        self.backGround = data["backGround"].stringValue
        self.createTime = data["createTime"].doubleValue
        self.firebaseKey = firebaseKey
        self.type = .nomal
    }
    
    init() {

    }
}



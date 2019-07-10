//
//  TypeTag.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/5/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import Foundation

struct TypeTag {
    var textTag: String
    var backGround: String
    var type: TypeCell = .nomal
    
    init(textTag: String, backGround: String, type: TypeCell = .nomal) {
        self.textTag = textTag
        self.backGround = backGround
        self.type = type
    }
}



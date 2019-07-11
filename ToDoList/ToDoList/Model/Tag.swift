//
//  Tag.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/11/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tag: NSObject{
    var textTag = ""
    var backGround = ""
    
    override init() {
        super.init()
    }

    init(data: JSON) {
        self.textTag = data["textTag1"].stringValue
        self.backGround = data["backGround"].stringValue
    }
}

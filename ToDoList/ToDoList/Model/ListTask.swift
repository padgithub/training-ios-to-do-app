//
//  ListTask.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/9/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ListTask{
    var nameTask: String
    var descriptionTask: String
    var tag: TypeTag = TypeTag(textTag: "nil", backGround: "nil")
    var tagID: String = ""
    var timeStart: Double = 0
    var timeEnd: Double = 0
    var taskID: String = ""
    var peopleName: [String] = []
    var imageURL: [String] = []
    
    init(nameTask: String, descriptionTask: String, tagID: String, timeStart: Double = 0, timeEnd: Double = 0, taskID: String = "", peopleName: [String] = [], imageURL: [String] = []) {
        self.nameTask = nameTask
        self.descriptionTask = descriptionTask
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.tagID = tagID
        self.tag = getTagWithID(id: tagID)
        self.taskID = taskID
        self.peopleName = peopleName
        self.imageURL = imageURL
    }
    
    init(data: JSON) {
        self.nameTask = data["nameTask"].stringValue
        self.descriptionTask = data["descriptionTask"].stringValue
        self.tag = getTagWithID(id: data["tagID"].stringValue)
        self.tagID = data["tagID"].stringValue
        self.timeStart = data["timeStar"].doubleValue
        self.timeEnd = data["timeEnd"].doubleValue
        self.taskID = data["taskID"].stringValue
        self.peopleName = data["peopleName"].arrayObject as? [String] ?? [""]
        self.imageURL = data["imageURL"].arrayObject as? [String] ?? [""]
    }
    
    func getTagWithID(id: String) -> TypeTag{
        return TAppDelegate.arrTag.first(where: { (tags) -> Bool in
            let tag = tags as TypeTag
            return tag.firebaseKey == id
        }) ?? TypeTag(textTag: "", backGround: "")
    }
}

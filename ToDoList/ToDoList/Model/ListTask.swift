//
//  ListTask.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/9/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import Foundation

struct ListTask{
    var nameTask: String
    var descriptionTask: String
//    var tag: TypeTag
    var tagColor: String
    var timeStart: String = "11-07 4:33"
    var timeEnd: String = "11-07 4:33"
    
    init(nameTask: String, descriptionTask: String, tagColor: String, timeStar: String = "11-07 4:33", timeEnd: String = "11-07 4:33") {
        self.nameTask = nameTask
        self.descriptionTask = descriptionTask
        self.tagColor = tagColor
        self.timeStart = timeStar
        self.timeEnd = timeEnd
    }
}

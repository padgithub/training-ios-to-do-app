//
//  TimeLineCell.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/10/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class TimeLineCell: UITableViewCell {
    @IBOutlet weak var dateStart: UILabel!
    @IBOutlet weak var timeStart: UILabel!
    @IBOutlet weak var lbNameTask: UILabel!
    @IBOutlet weak var lbDescriptionTask: UILabel!
    @IBOutlet weak var imgColorTask: UIImageView!
    
    var taskData = ListTask(nameTask: "nil", descriptionTask: "nil", tagColor: "nil")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        initUI()
    }
    
}

extension TimeLineCell {
    func initUI(){
        DispatchQueue.main.async {
            self.imgColorTask.layer.masksToBounds = false
            self.imgColorTask.layer.cornerRadius = self.imgColorTask.bounds.height/2
            self.imgColorTask.clipsToBounds = true
        }
    }
    
    func initData(){
        imgColorTask.backgroundColor = UIColor(taskData.tagColor, alpha: 1.0)
        lbNameTask.text = taskData.nameTask
        lbDescriptionTask.text = taskData.descriptionTask
//        print(taskData.nameTask)
    }
}

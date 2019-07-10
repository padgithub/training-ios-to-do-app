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
    @IBOutlet weak var viewCenterTimeLine: UIView!
    @IBOutlet weak var viewLineTimeLine: UIView!
    
    var taskData = ListTask(nameTask: "nil", descriptionTask: "nil", tagColor: "nil")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewCenterTimeLine.layer.cornerRadius = min(viewCenterTimeLine.frame.size.height, viewCenterTimeLine.frame.size.width) / 2.0
        viewCenterTimeLine.clipsToBounds = true
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
    
    func initData(taskData: ListTask) {
        imgColorTask.backgroundColor = UIColor(taskData.tagColor, alpha: 1.0)
        lbNameTask.text = taskData.nameTask
        lbDescriptionTask.text = taskData.descriptionTask
        
        viewCenterTimeLine.backgroundColor = UIColor(taskData.tagColor, alpha: 1.0)
        viewLineTimeLine.backgroundColor = UIColor(taskData.tagColor, alpha: 1.0)
        
        dateStart.text = getDate(data: taskData.timeStart)
        timeStart.text = getTime(data: taskData.timeStart)
    }
    
    func getTime(data: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "dd-MM h:m"
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "h:m"
        
        let date = inFormatter.date(from: data)!
        let outStr = outFormatter.string(from: date)
        
        return outStr
    }
    
    func getDate(data: String) -> String {
        let inFormater = DateFormatter()
        inFormater.dateFormat = "dd-MM h:m"
        
        let outFormater = DateFormatter()
        outFormater.dateFormat = "dd-MM"
        
        let date = inFormater.date(from: data)!
        let outString = outFormater.string(from: date)
        
        return outString
    }
}

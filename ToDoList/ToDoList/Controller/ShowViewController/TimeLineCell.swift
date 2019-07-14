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
    @IBOutlet weak var dateEnd: UILabel!
    @IBOutlet weak var timeEnd: UILabel!
    
    var taskData = ListTask(nameTask: "nil", descriptionTask: "nil", tagID: "nil")
    let dateFormatter = DateFormatter()
    
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
        imgColorTask.backgroundColor = UIColor(taskData.tag.backGround, alpha: 1.0)
        lbNameTask.text = taskData.nameTask
        lbDescriptionTask.text = taskData.descriptionTask
        
        viewCenterTimeLine.backgroundColor = UIColor(taskData.tag.backGround, alpha: 1.0)
        viewLineTimeLine.backgroundColor = UIColor(taskData.tag.backGround, alpha: 1.0)
        
        dateStart.text = getDate(date: taskData.timeStart)
        timeStart.text = getTime(date: taskData.timeStart)
        dateEnd.text = getDate(date: taskData.timeEnd)
        timeEnd.text = getTime(date: taskData.timeEnd)
    }
    
    func getDate(date: Double) -> String{
        dateFormatter.dateFormat = "dd-MM"
        let dateDate = Date(timeIntervalSince1970: date)
        let dateString = dateFormatter.string(from: dateDate)
        return dateString
    }
    
    func getTime(date: Double) -> String{
        dateFormatter.dateFormat = "HH:mm"
        let timeDate = Date(timeIntervalSince1970: date)
        let timeString = dateFormatter.string(from: timeDate)
        return timeString
    }
    
}

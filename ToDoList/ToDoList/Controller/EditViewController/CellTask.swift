//
//  CellTask.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/9/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class CellTask: UITableViewCell {
    @IBOutlet weak var imgTag: UIImageView!
    @IBOutlet weak var lbNameTask: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    
    var taskData = ListTask(nameTask: "nil", descriptionTask: "nil", tagColor: "nil")
    var isHide = false
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        initUI()
        
        // Configure the view for the selected state
    }
    
}

extension CellTask{
    func setHide(){
        imgTag.isHidden = isHide
    }
    
    func initUI(){
        DispatchQueue.main.async {
            self.imgTag.layer.masksToBounds = false
            self.imgTag.layer.cornerRadius = self.imgTag.bounds.height/2
            self.imgTag.clipsToBounds = true
        }
    }
    
    func initData(){
        imgTag.backgroundColor = UIColor(taskData.tagColor, alpha: 1.0)
        lbNameTask.text = taskData.nameTask
        lbDescription.text = taskData.descriptionTask
        print(taskData.nameTask)
    }
}

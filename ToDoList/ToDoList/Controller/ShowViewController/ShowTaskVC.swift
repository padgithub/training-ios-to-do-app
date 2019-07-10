//
//  ShowTaskVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/10/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class ShowTaskVC: UIViewController {
    @IBOutlet weak var collectionTagCount: UICollectionView!
    @IBOutlet weak var tableTimeLine: UITableView!
    
    var arrTag: [TypeTag] = [TypeTag(textTag: "Work", backGround: "42AAFD"),
                             TypeTag(textTag: "Personal", backGround: "01BACC"),
                             TypeTag(textTag: "Shopping", backGround: "CD42FD"),
                             TypeTag(textTag: "Health", backGround: "EE2375"),
                             TypeTag(textTag: "Other", backGround: "8539F9")
    ]
    
    var listTodo: [ListTask] = [
        ListTask(nameTask: "Do yoga", descriptionTask: "Do yoga", tagColor: "EE2375"),
        ListTask(nameTask: "Go Shopping", descriptionTask: "Buy bread", tagColor: "CD42FD"),
        ListTask(nameTask: "Go Shopping", descriptionTask: "Bananas", tagColor: "CD42FD"),
        ListTask(nameTask: "Meeting", descriptionTask: "Skype meeting whit Anh", tagColor: "01BACC"),
        ListTask(nameTask: "Running", descriptionTask: "Running", tagColor: "EE2375"),
        ListTask(nameTask: "Other", descriptionTask: "Other", tagColor: "8539F9"),
        ListTask(nameTask: "Do yoga", descriptionTask: "Do yoga", tagColor: "EE2375"),
        ListTask(nameTask: "Other", descriptionTask: "Other", tagColor: "8539F9"),
        ListTask(nameTask: "Do yoga", descriptionTask: "Do yoga", tagColor: "EE2375")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
    }
}

extension ShowTaskVC {
    func initUI() {
        //MARK: - Layout collection view cell
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: collectionTagCount.frame.width/2 - 10, height: collectionTagCount.frame.height/2 - 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        collectionTagCount!.collectionViewLayout = layout
    }
    
    func initData() {
        collectionTagCount.dataSource = self
        collectionTagCount.delegate = self
    
        collectionTagCount.register(TagCount.self)
    }
}

extension ShowTaskVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = arrTag[indexPath.row]
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TagCount
        
        cell.contentView.layer.cornerRadius = 3
        cell.contentView.layer.borderWidth = 1.0
        
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 3.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath

        cell.cofig(typeTag: tag)
        return cell
    }
    
    
}

extension ShowTaskVC: UICollectionViewDelegate {
    
}

extension ShowTaskVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTodo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TimeLineCell
        return cell
    }
    
    
}

extension ShowTaskVC: UITableViewDelegate {
    
}

//
//  ShowTaskVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/10/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class ShowTaskVC: UIViewController {
    @IBOutlet weak var collectionTagCount: UICollectionView!
    @IBOutlet weak var tableTimeLine: UITableView!
    
    @IBAction func btnAdd(_ sender: Any) {
        let addVC = AddVC.init(nibName: "AddVC", bundle: nil)
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
//    var arrTag: [TypeTag] = [TypeTag(textTag: "Work", backGround: "42AAFD"),
//                             TypeTag(textTag: "Personal", backGround: "01BACC"),
//                             TypeTag(textTag: "Shopping", backGround: "CD42FD"),
//                             TypeTag(textTag: "Health", backGround: "EE2375"),
//                             TypeTag(textTag: "Other", backGround: "8539F9")
   // ]
    
    var listTodo = [ListTask]()
    @IBOutlet weak var countTaskDone: UILabel!
    @IBOutlet weak var countTaskDoing: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
       // TAppDelegate.db = Firestore.firestore()
        
        
        
        initUI()
        initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchTask()
    }
}

extension ShowTaskVC {
    func initUI() {
        //MARK: - Layout collection view cell
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: collectionTagCount.frame.width/2 - 10, height: collectionTagCount.frame.height/2 - 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        collectionTagCount!.collectionViewLayout = layout
    }
    
    func initData() {
        collectionTagCount.dataSource = self
        collectionTagCount.delegate = self
        
        tableTimeLine.dataSource = self
        tableTimeLine.delegate = self
    
        collectionTagCount.register(TagCount.self)
        tableTimeLine.register(TimeLineCell.self)
        collectionTagCount.reloadData()
    }
    
    func coutTask() {
        var countDone = 0
        
        let currentDay = Date().startDate.timeIntervalSince1970
        listTodo.forEach { (objs) in
            if Date.init(seconds: objs.timeEnd).endDate.timeIntervalSince1970 > currentDay {
                countDone += 1
            }
        }
        countTaskDone.text = "\(countDone)"
        countTaskDoing.text = "\(listTodo.count - countDone)"
    }
    
    func fetchTask() {
        TAppDelegate.db.collection("Task").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.listTodo.removeAll()
                for document in querySnapshot!.documents {
                    let obj = ListTask.init(data: JSON.init(document.data()))
                    self.listTodo.append(obj)
                }
                if self.listTodo.count > 0 {
                    self.tableTimeLine.reloadData()
                }
                self.coutTask()
            }
        }
    }
    
//    func addTag() {
//
//        let docRef = db.collection("Tag")
//        arrTag.forEach { (tag) in
//            let tagString = ["textTag": tag.textTag, "backGround": tag.backGround]
//            docRef.addDocument(data: tagString, completion: { (err) in
//                if (err != nil) {
//                    print(err as Any)
//                }else{
//                    print("Document added with ID: \(docRef.document().documentID)")
//                }
//            })
//        }
//    }
    
}

//MARK: - CollectionView
extension ShowTaskVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TAppDelegate.arrTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = TAppDelegate.arrTag[indexPath.row]
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = TAppDelegate.arrTag[indexPath.row]
        
        let editVC = EditVC.init(nibName: "EditVC", bundle: nil)
        editVC.fetchTaskWithTag(tag: tag)
        editVC.tagSelected = tag
        
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}

//MARK: - TableView
extension ShowTaskVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTodo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = listTodo[indexPath.row]
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TimeLineCell
        cell.initData(taskData: taskCell)
        return cell
    }
    
    
}

extension ShowTaskVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}

//MARK: - Support Date Function
extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    func string(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
    func stringWithTimeZone( timeZone: String, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var secondsSince1970: Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
    
    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init(seconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    init(string: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self = dateFormatter.date(from: string)!
    }
    
    func getElapsedInterval() -> String {
        let unitFlags = Set<Calendar.Component>([.day, .weekOfMonth, .month, .year, .hour , .minute, .second])
        var interval = Calendar.current.dateComponents(unitFlags, from: self,  to: Date())
        if interval.year! > 0 {
            return "\(interval.year!)" + " " + "năm trước"
        }
        if interval.month! > 0 {
            return "\(interval.month!)" + " " + "tháng trước"
        }
        if interval.weekOfMonth! > 0 {
            return "\(interval.weekOfMonth!)" + " " + "tuần trước"
        }
        if interval.day! > 0 {
            return "\(interval.day!)" + " " + "ngày trước"
        }
        if interval.hour! > 0 {
            return "\(interval.hour!)" + " " + "giờ trước"
        }
        if interval.minute! > 0 {
            return "\(interval.minute!)" + " " + "phút trước"
        }
        
        if interval.second! > 0 {
            return "Vừa xong"
        }
        return "Vừa xong"
    }
    
    var startDate: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self) ?? self
    }
    var endDate: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
}

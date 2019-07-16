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
import UserNotifications

class ShowTaskVC: UIViewController {
    @IBOutlet weak var collectionTagCount: UICollectionView!
    @IBOutlet weak var tableTimeLine: UITableView!
    
    @IBAction func btnAdd(_ sender: Any) {
        let addVC = AddVC.init(nibName: "AddVC", bundle: nil)
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    //MARK: - Task Created, Left Action
    @IBOutlet weak var taskCreated: UIView!
    @IBOutlet weak var taskLeft: UIView!
    @IBOutlet weak var lbTaskToday: UILabel!
    
    var listTodo = [ListTask]()
    var listSort = [ListTask]()
    var tempArray = [ListTask]()
    var todayTask = "nil"
    var decTodayTask = "nil"
    let defauls = UserDefaults.standard
    
    @IBOutlet weak var countTask: UILabel!
    @IBOutlet weak var countTaskDoing: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        initUI()
        initData()
        
        let myTimer = Timer(timeInterval: 40.0, target: self, selector: #selector(reload), userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
    }
    
    @objc func reload() {
        fetchTask()
        pushNoti()
        print("reload")
    }
    
    override func viewDidAppear(_ animated: Bool) {
       fetchTaskToday()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchTask()
        collectionTagCount.reloadData()
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
        
        let gestureCreated = UITapGestureRecognizer(target: self, action: #selector(showCreated(_:)))
        let gestureLeft = UITapGestureRecognizer(target: self, action: #selector(showLeft(_:)))
        taskCreated.addGestureRecognizer(gestureCreated)
        taskLeft.addGestureRecognizer(gestureLeft)
    }
    
    @objc func showCreated(_ sender:UITapGestureRecognizer){
        let editVC = EditVC.init(nibName: "EditVC", bundle: nil)
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc func showLeft(_ sender:UITapGestureRecognizer){
        let editVC = EditVC.init(nibName: "EditVC", bundle: nil)
        editVC.isDoing = true
        self.navigationController?.pushViewController(editVC, animated: true)
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
        var countDoing = 0
        var countToday = 0
        
        let currentDay = Date().startDate.timeIntervalSince1970
        listTodo.forEach { (objs) in
            if Date.init(seconds: objs.timeEnd).endDate.timeIntervalSince1970 > currentDay {
                countDoing += 1
            }
            if (Date.init(seconds: objs.timeEnd).startDate.timeIntervalSince1970 == currentDay) || Date.init(seconds: objs.timeStart).startDate.timeIntervalSince1970 == currentDay {
                countToday += 1
            }
        }
        countTask.text = "\(listTodo.count)"
        countTaskDoing.text = "\(countDoing)"
        lbTaskToday.text = "Today, you have \(countToday) task"
    }
    
    func  fetchTask() {
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
                    self.listSort.removeAll()
                    self.sortArray()
                     self.listSort = self.listSort.sorted(by: { $0.timeStart < $1.timeStart })
                    self.addTempTask()
                    self.listSort = self.listSort.sorted(by: { $0.timeStart < $1.timeStart })
                    
                    self.tableTimeLine.reloadData()
                } else {
                    self.addTempTask()
                    self.tableTimeLine.reloadData()
                }
                self.coutTask()
                self.fetchTaskToday()
            }
        }
    }
    
    //MARK: - Save task today to userdefaults
    func fetchTaskToday() {
        var dataArr =  [[String:String]]()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        let today = dateFormat.string(from: Date())
        for item in listSort {
            let date = Date(timeIntervalSince1970: item.timeStart)
            let dayInArr = dateFormat.string(from: date)
            if today == dayInArr && item.nameTask != "Không có" {
                let dateFormat2 = DateFormatter()
                dateFormat2.dateFormat = "dd-MM-yyyy HH:mm"
                let dateAdd = dateFormat.string(from: date)
                let dic = ["Name": item.nameTask, "Desc": item.descriptionTask, "Date": dateAdd]
                dataArr.append(dic)
            }
        }
        defauls.set(dataArr, forKey: "TaskToday")
        print(dataArr)
    }
    
    
    //MARK: - Func Sort Array By Date
    func sortArray() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"

        let currentDay = Date()
        dateFormatter.string(from: currentDay)
        
        for item in listTodo {
            let date = Date(timeIntervalSince1970: item.timeEnd)
            if date > currentDay {
                listSort.append(item)
            }
        }
    }
    
    func addTempTask() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        var currentDay = Date()
        var isHave = false
        var i = 0
        let next10Day = Calendar.current.date(byAdding: .day, value: 10, to: currentDay)!
        tempArray = listSort
        
        while currentDay < next10Day {
            if listSort.count > 0 {
                while i < listSort.count {
                    let currentDayStr = dateFormatter.string(from: currentDay.startDate)
                    let dateStart = Date(timeIntervalSince1970: listSort[i].timeStart)
                    let dateEnd = Date(timeIntervalSince1970: listSort[i].timeEnd)
                    let dateStartStr = dateFormatter.string(from: dateStart)
                    let dateEndStr = dateFormatter.string(from: dateEnd)
                    
                    if currentDayStr == "18-07-2019" {
                        print("HERE")
                    }
                    
                    if currentDayStr != dateStartStr && currentDayStr != dateEndStr {
                        isHave = true
                        break
                    }

                    i = i + 1
                    currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)!
                }
            } else {
                isHave = true
            }
            if (isHave) {
                let data = ListTask(nameTask: "Không có", descriptionTask: "việc cần làm", tagID: "nil", timeStart: currentDay.timeIntervalSince1970, timeEnd: currentDay.timeIntervalSince1970, taskID: "nil")
                tempArray.append(data)
            }
            currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)!
        }
        listSort = tempArray
    }
    
    //MARK: - Điều kiện push notification
    func pushNoti() {
        let arrData = defauls.object(forKey: "TaskToday") as? [[String:String]] ?? [[String:String]]()
        let dateFormatterNonSS = DateFormatter()
        dateFormatterNonSS.dateFormat = "dd-MM-yyyy HH:mm"
        for item in arrData {
            let day1 = dateFormatterNonSS.string(from: Date())
            if day1 == item["Date"] {
                todayTask = item["Name"]!
                decTodayTask = item["Desc"]!
                notification()
            }
        }
    }
    
    //MARK: - Notification
    func notification() {
        let content = UNMutableNotificationContent()
        content.title = todayTask
        content.body = decTodayTask
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
}

//MARK: - CollectionView
extension ShowTaskVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // -1 SpecialCell - Button
        return TAppDelegate.arrTag.count - 1
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
        return listSort.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = listSort[indexPath.row]
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

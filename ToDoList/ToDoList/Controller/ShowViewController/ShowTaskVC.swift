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
import FanMenu
import Macaw
import PopMenu
import KRProgressHUD

class ShowTaskVC: UIViewController {
    @IBOutlet var viewMain: UIView!
    
    @IBOutlet weak var sideButtonMenu: FanMenu!
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
    @IBOutlet weak var lbUserName: UILabel!
    
    var listTodo = [ListTask]()
    var listSort = [ListTask]()
    var tempArray = [ListTask]()
    var listTaskCount = [Int]()
    var todayTask: String = "nil"
    var decTodayTask: String = "nil"
    var userUID: String = ""
    let defauls = UserDefaults.standard
    let items = [
        ("Logout", 0xFF703B),
        ("About", 0x9F85FF),
        ("Report", 0x85B1FF),
    ]
    var myTimer = Timer()
    var menuViewController = PopMenuViewController()
    var handle: ((Int) -> Void)?
    
    @IBOutlet weak var countTask: UILabel!
    @IBOutlet weak var countTaskDoing: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        initUI()
        initData()
        reload()
        
         myTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkTime), userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
    }
    
    
    
    @objc func reload() {
        fetchTask()
    }
    
    @objc func checkTime() {
        if Date().timeIntervalSince1970.rounded() == floor(Date().timeIntervalSince1970 / 60.0) * 60.0{
            reload()
            myTimer.invalidate()
            myTimer = Timer(timeInterval: 60.0, target: self, selector: #selector(reload), userInfo: nil, repeats: true)
            RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       fetchTaskToday()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchTask()
        collectionTagCount.reloadData()
        tableTimeLine.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sideButtonMenu.updateNode()
    }
    
    func presentMenu() {
        menuViewController = PopMenuViewController(actions: [
            
            PopMenuDefaultAction(title: "Setting", image: nil, color: .white, didSelect: nil),
            PopMenuDefaultAction(title: "Đổi tên", image: UIImage(named: "edit_user"), color: .green, didSelect: { action in
                self.handle?(1)
            }),
            PopMenuDefaultAction(title: "Đổi mật khẩu", image: UIImage(named: "edit_password"), color: .red, didSelect: { action in
                self.handle?(2)
            })])
        present(menuViewController, animated: true, completion: nil)
        
        handle = { (value) in
            self.menuViewController.dismiss(animated: false, completion: {
                if value == 1 {
                    self.changeUserName()
                } else if value == 2 {
                    self.changePass()
                }
            })
        }
    }
    
    func changePass() {
        let alertController = UIAlertController(title: "Đổi mật khẩu", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Mật khẩu cũ"
            textField.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let passOld = alertController.textFields![0].text
            let passNew = alertController.textFields![1].text
            let confPass = alertController.textFields![2].text

            if passNew == confPass {
                let user = Auth.auth().currentUser
                
                let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: passOld!)
                KRProgressHUD.show()
                user?.reauthenticate(with: credential, completion: { (result, err) in
                    if err != nil{
                        KRProgressHUD.showError(withMessage: "Sai mật khẩu cũ")
                    }else{
                        Auth.auth().currentUser?.updatePassword(to: confPass!) { (error) in
                            if error != nil {
                                return
                            }
                            if Auth.auth().currentUser != nil {
                                KRProgressHUD.showSuccess()
                                print("Successful!")
                            }
                        }
                    }
                })
            } else {
                KRProgressHUD.showError(withMessage: "Vui lòng xác nhận đúng mật khẩu mới")
            }
        })
        alertController.addTextField { (textField) in
            textField.placeholder = "Nhập mật khẩu mới"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Nhập lại mật khẩu mới"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changeUserName() {
        let alertController = UIAlertController(title: "Đổi tên", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Nhập tên mới"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let newName = alertController.textFields![0].text
            
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = newName
                    KRProgressHUD.show()
                    changeRequest?.commitChanges { (error) in
                        if error != nil {
                            return
                        }
                        if Auth.auth().currentUser != nil {
                            KRProgressHUD.showSuccess()
                            self.initUI()
                        }
                    }
                    print("Register successful!")
            }
        )
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
        
    
    
    func sideButtonSetup() {
        sideButtonMenu.button = FanMenuButton(
            id: "main",
            image: UIImage(named: "menu_plus"),
            color: Color(val: 0x7C93FE)
        )
        

        sideButtonMenu.items = items.map { button in
            FanMenuButton(
                id: button.0,
                image: UIImage(named: "menu_\(button.0)"),
                color: Color(val: button.1)
            )
        }
        
        sideButtonMenu.menuRadius = 90.0
        sideButtonMenu.duration = 0.2
        sideButtonMenu.interval = (Double.pi, 0.3 * Double.pi)
        sideButtonMenu.radius = 25.0
        
        sideButtonMenu.onItemDidClick = { button in
            if button.id == "Logout" {
                do{
                    try Auth.auth().signOut()
                    
                    let vc = LoginVC.init(nibName: "LoginVC", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                } catch let logoutError {
                    print(logoutError)
                }
            }
            if button.id == "About" {
                _ = UIAlertController.present(title: "About me", message: "Hallo?.", actionTitles: ["OK"])
            }
            if button.id == "Report" {
                self.presentMenu()
            }
            print("ItemDidClick: \(button.id)")
        }
        
        sideButtonMenu.onItemWillClick = { button in
            print("ItemWillClick: \(button.id)")
        }
        
        sideButtonMenu.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        sideButtonMenu.backgroundColor = .clear
    }
}

extension ShowTaskVC {
    func initUI() {
        sideButtonSetup()
        
        //MARK: - Layout collection view cell
        collectionTagCount.delegate = self
        collectionTagCount.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        self.collectionTagCount.collectionViewLayout = layout
        
        let gestureCreated = UITapGestureRecognizer(target: self, action: #selector(showCreated(_:)))
        let gestureLeft = UITapGestureRecognizer(target: self, action: #selector(showLeft(_:)))
        taskCreated.addGestureRecognizer(gestureCreated)
        taskLeft.addGestureRecognizer(gestureLeft)
        
            let user = Auth.auth().currentUser
            if let user = user {
                let displayName = user.displayName
                lbUserName.text = "Hey \(displayName ?? "")"
        }
        
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
        TAppDelegate.arrTag.forEach({ (objs) in
            listTaskCount.append(0)
        })
            
        let user = Auth.auth().currentUser
        if let user = user {
            userUID = user.uid
        }
        
        tableTimeLine.dataSource = self
        tableTimeLine.delegate = self
    
        collectionTagCount.register(TagCount.self)
        tableTimeLine.register(TimeLineCell.self)
        collectionTagCount.reloadData()
    }
    
    //MARK: - Count task
    func coutTask() {
        var countDoing = 0
        var countToday = 0
        
        let currentDay = Date().timeIntervalSince1970
         let currentDay2 = Date().startDate.timeIntervalSince1970
        listTodo.forEach { (objs) in
            if Date.init(seconds: objs.timeEnd).timeIntervalSince1970 > currentDay {
                countDoing += 1
            }
            if (Date.init(seconds: objs.timeEnd).startDate.timeIntervalSince1970 == currentDay2) || Date.init(seconds: objs.timeStart).startDate.timeIntervalSince1970 == currentDay2 {
                countToday += 1
            }
        }
        countTask.text = "\(listTodo.count)"
        countTaskDoing.text = "\(countDoing)"
        lbTaskToday.text = "Today, you have \(countToday) task"
    }
    
    func countTag() {
     
            for i in TAppDelegate.arrTag.indices {
                listTaskCount.append(0)
                listTodo.forEach { (objs) in
                    if objs.tagID == TAppDelegate.arrTag[i].firebaseKey {
                        listTaskCount[i] += 1
                    }
                }
            }
        
        
        collectionTagCount.reloadData()
    }
    
    func  fetchTask() {
        TAppDelegate.db.collection("Task").document(userUID).collection("UserTask").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                self.listTodo.removeAll()
                for document in querySnapshot!.documents {
                    let obj = ListTask.init(data: JSON.init(document.data()))
                    self.listTodo.append(obj)
                }

                if self.listTodo.count >= 0 {
                    self.listSort.removeAll()
                    self.sortArray()
                    self.addTempTask()
                    self.listSort = self.listSort.sorted(by: { $0.timeStart < $1.timeStart })
                }
                
                self.coutTask()
                self.fetchTaskToday()
                self.listTaskCount.removeAll()
                self.countTag()
                self.tableTimeLine.reloadData()
            }
        }
    }
    
    //MARK: - Save task today to userdefaults
    func fetchTaskToday() {
        var dataArr =  [[String:String]]()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        let today = Date()
        for item in listSort {
            let date = Date(timeIntervalSince1970: item.timeStart)
            if today.startDate == date.startDate && item.nameTask != "Không có" {
                let dic = ["Name": item.nameTask, "Desc": item.descriptionTask, "Date": "\(item.timeStart)"]
                dataArr.append(dic)
            }
        }
        defauls.set(dataArr, forKey: "TaskToday")
        pushNoti()
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
    
    //MARK: - Điều kiện push notification
    func pushNoti() {
        let arrData = defauls.object(forKey: "TaskToday") as? [[String:String]] ?? [[String:String]]()
        let dateFormatterNonSS = DateFormatter()
        dateFormatterNonSS.dateFormat = "dd-MM-yyyy HH:mm"
        for item in arrData {
            todayTask = item["Name"] ?? ""
            decTodayTask = item["Desc"] ?? ""
            notification(day: Double(item["Date"] ?? "0") ?? 0)
        }
        print("push")
    }
    //MARK: - Add temp task
    func addTempTask() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        var currentDay = Date()
        var isHave = false
        var i = 0
        
        tempArray = listSort
        
        for _ in 1 ... 10 {
            if listSort.count > 0 {
                while i < listSort.count {
                    let currentDayStr = dateFormatter.string(from: currentDay.startDate)
                    let dateStart = Date(timeIntervalSince1970: listSort[i].timeStart)
                    let dateEnd = Date(timeIntervalSince1970: listSort[i].timeEnd)
                    let dateStartStr = dateFormatter.string(from: dateStart)
                    let dateEndStr = dateFormatter.string(from: dateEnd)
                    
                    if listSort.count == 1 && (currentDayStr == dateStartStr || currentDayStr == dateEndStr) {
                        currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)!
                        isHave = true
                        break
                    }
                    
                    if currentDayStr != dateStartStr && currentDayStr != dateEndStr {
                        isHave = true
                        break
                    }
                    
                    i = i + 1
                    currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)!
                }
            } else { isHave = true }
            
            if (isHave) {
                let data = ListTask(nameTask: "Không có", descriptionTask: "việc cần làm", tagID: "nil", timeStart: currentDay.timeIntervalSince1970, timeEnd: currentDay.timeIntervalSince1970, taskID: "nil")
                tempArray.append(data)
            }
            currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)!
        }
        
        tempArray = tempArray.sorted(by: { $0.timeStart < $1.timeStart })
        
        // Remove same temp null task
        var x = 1
        var y = 0
        while x < tempArray.count - 1 {
            if Date.init(seconds: tempArray[x].timeStart).startDate == Date.init(seconds: tempArray[x - 1].timeStart).startDate && tempArray[x].nameTask == "Không có" {
                tempArray.remove(at: x)
            }
            x += 1
        }
        while y < tempArray.count - 1 {
            if Date.init(seconds: tempArray[y].timeStart).startDate == Date.init(seconds: tempArray[y + 1].timeStart).startDate && tempArray[y].nameTask == "Không có" {
                tempArray.remove(at: y)
            }
            y += 1
        }
        
        listSort = tempArray
    }
    
    //MARK: - Notification
    func notification(day: Double) {
        let saiso = day - ((floor(day / 60) * 60))
        if (day - Date().timeIntervalSince1970) - saiso > 0 {
            
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            let content = UNMutableNotificationContent()
            content.title = todayTask
            content.body = decTodayTask
            content.sound = UNNotificationSound.default
            
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (day - saiso) - Date().timeIntervalSince1970, repeats: false)
            print((day - Date().timeIntervalSince1970) - saiso)
                let request = UNNotificationRequest(identifier: "\(todayTask)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
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
        cell.lbTaskCount.text = String(listTaskCount[indexPath.row])
        
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

extension ShowTaskVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionTagCount.frame.width/2) - 10, height: collectionTagCount.frame.height/2 - 10)
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
        if indexPath.row > 0 {
            if Date.init(seconds: listSort[indexPath.row - 1].timeStart).startDate == Date.init(seconds: taskCell.timeStart).startDate {
                cell.isHide = false
            }else{
                cell.isHide = true
            }
        }
        
        cell.initData(taskData: taskCell)
        return cell
    }
}

extension ShowTaskVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}

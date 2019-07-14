//
//  AddVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/4/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftyJSON

enum TypeCell {
    case nomal
    case special
}

class AddVC: UIViewController {
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var txtTextView: UITextView!
    @IBOutlet weak var dateTimeToShow: UILabel!
    @IBOutlet weak var viewChooseDate: UIView!
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var typeCollection: UICollectionView!
    @IBOutlet weak var btnAddTask: UIButton!
    
    //MARK: - Declaration DatePickerView
    @IBOutlet weak var dateChoose: UIDatePicker!
    @IBOutlet weak var txtChooseDate: UILabel!
    @IBOutlet weak var imgShowDate: UIImageView!
    
    let dateFormatter = DateFormatter()
    var ref: DocumentReference? = nil
    var isEdit = false
    var taskEdit = ListTask(nameTask: "nil", descriptionTask: "nil", tagID: "nil")
    var tagID = String()
    var startDate = Date()
    var endDate = Date()
    
    //MARK: - Action Pick Date
    @IBAction func actionDone(_ sender: Any) {
        if txtChooseDate.tag != 0 {
            viewDatePicker.isHidden = true
            
            dateFormatter.dateFormat = "dd-MM HH:mm"
            endDate = dateChoose.date
            dateTimeToShow.text = configDate(startDate: startDate, endDate: endDate)
            
            txtChooseDate.text = "Choose Start Date"
            txtChooseDate.tag = 0
        }else
        {
            txtChooseDate.tag = 1
            txtChooseDate.text = "Choose End Date"
            
            dateFormatter.dateFormat = "dd-MM HH:mm"
            startDate = dateChoose.date
            print(startDate)
        }
       
    }
    @IBAction func actionCancel(_ sender: Any) {
        viewDatePicker.isHidden = true
        txtChooseDate.text = "Choose Start Date"
        txtChooseDate.tag = 0
    }
    
    func configDate(startDate: Date, endDate: Date) -> String {
        dateFormatter.dateFormat = "dd-MM"
        var startDateString = dateFormatter.string(from: startDate)
        var endDateString = dateFormatter.string(from: endDate)
        
        let currentDay = Date()
        
        if startDateString == endDateString {
            
            dateFormatter.dateFormat = "dd-MM-yyyy"
            startDateString = dateFormatter.string(from: startDate)
            let currentDayString = dateFormatter.string(from: currentDay)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let startTimeString = timeFormatter.string(from: startDate)
            let endTimeString = timeFormatter.string(from: endDate)
            if startDateString == currentDayString{
                return "Today, \(startTimeString) - \(endTimeString)"
            }else{
                dateFormatter.dateFormat = "dd-MM"
                startDateString = dateFormatter.string(from: startDate)
                return "\(startDateString), \(startTimeString) - \(endTimeString)"
            }
            
        }else
        {
            dateFormatter.dateFormat = "dd-MM HH:mm"
            startDateString = dateFormatter.string(from: startDate)
            endDateString = dateFormatter.string(from: endDate)
            return "\(startDateString) - \(endDateString)"
        }
    }
    
    //MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
        checkEdit(edit: isEdit)

        let tap = UITapGestureRecognizer(target: self, action: #selector(AddVC.tapFunction))
        viewChooseDate.isUserInteractionEnabled = true
        viewChooseDate.addGestureRecognizer(tap)
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        viewDatePicker.isHidden = !viewDatePicker.isHidden
    }
    
    //MARK: - Add Task
    @IBOutlet weak var txtNameTask: UITextField!
    
    @IBAction func btnAddTask(_ sender: Any) {
        if isEdit{
            let taskAdd: ListTask = ListTask(nameTask: txtNameTask.text ?? "nil", descriptionTask: txtTextView.text ?? "nil", tagID: tagID , timeStart: startDate.timeIntervalSince1970, timeEnd: endDate.timeIntervalSince1970)
            
                let editRef = TAppDelegate.db.collection("Task").document("\(taskEdit.taskID)")
                editRef.updateData([
                    "nameTask": taskAdd.nameTask,
                    "descriptionTask": taskAdd.descriptionTask,
                    "tagID": taskAdd.tagID,
                    "timeStar": taskAdd.timeStart,
                    "timeEnd": taskAdd.timeEnd
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        let alert = UIAlertController(title: "Thông báo", message: "Thay đổi thành công", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else{
            let taskAdd: ListTask = ListTask(nameTask: txtNameTask.text ?? "nil", descriptionTask: txtTextView.text ?? "nil", tagID: tagID , timeStart: startDate.timeIntervalSince1970, timeEnd: endDate.timeIntervalSince1970)
            
            ref = TAppDelegate.db.collection("Task").addDocument(data: [
                "nameTask": taskAdd.nameTask,
                "descriptionTask": taskAdd.descriptionTask,
                "tagID": taskAdd.tagID,
                "timeStar": taskAdd.timeStart,
                "timeEnd": taskAdd.timeEnd,
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(self.ref!.documentID)")
                        if let taskID = self.ref?.documentID{
                            TAppDelegate.db.collection("Task").document("\(taskID)").updateData([
                                "taskID": taskID
                                ])
                        }
                        let alert = UIAlertController(title: "Thông báo", message: "Thêm thành công", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        }
    }
}

//MARK: - Set tag collection view
extension AddVC: UITextViewDelegate,UINavigationBarDelegate {
    func initUI() {
        typeCollection.register(TypeViewCell.self)
        typeCollection.register(SpecialCell.self)
        
        //MARK: - Layout collection view cell
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: typeCollection.frame.width/3 - 10, height: typeCollection.frame.height/2 - 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        typeCollection!.collectionViewLayout = layout
        
        btnAddTask.layer.cornerRadius = 10
        btnAddTask.clipsToBounds = true
        btnAddTask.layer.borderWidth = 1
        btnAddTask.layer.borderColor = UIColor("979797", alpha: 1.0).cgColor
        
        txtTextView.text = "Description..."
        txtTextView.textColor = UIColor.lightGray
    }
    
    func initData() {
        typeCollection.dataSource = self
        typeCollection.delegate = self
        txtTextView.delegate = self
        
        if isEdit{
            let index = TAppDelegate.arrTag.firstIndex { (objs) -> Bool in
                return objs.firebaseKey == self.taskEdit.tagID
            }
            if index != nil {
                typeCollection.selectItem(at: IndexPath(item: index!, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
                let cell = typeCollection.cellForItem(at: IndexPath(item: index!, section: 0))
                
                cell?.layer.borderWidth = 3.0
                cell?.layer.cornerRadius = 4
                cell?.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    //MARK: - Edit Text View  r
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if txtTextView.textColor == UIColor.lightGray {
            txtTextView.text = ""
            txtTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if txtTextView.text == "" {
            
            txtTextView.text = "Description..."
            txtTextView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: - Edit View
    func checkEdit(edit: Bool){
        if edit{
            btnAddTask.setTitle("Save", for: .normal)
            txtNameTask.text = taskEdit.nameTask
            txtTextView.text = taskEdit.descriptionTask
            //TODO: Set Tag Choose
            let editStartTime = Date(timeIntervalSince1970: taskEdit.timeStart)
            let editEndTIme = Date(timeIntervalSince1970: taskEdit.timeEnd)
            dateTimeToShow.text = configDate(startDate: editStartTime, endDate: editEndTIme)
        }
    }
}

//MARK: - Setup CollectionView
extension AddVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TAppDelegate.arrTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = TAppDelegate.arrTag[indexPath.row]
        switch tag.type {
        case .special:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as SpecialCell
            cell.btnAdd.addTarget(self, action: #selector(addButtonTapped), for: UIControl.Event.touchUpInside)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TypeViewCell
            cell.cofig(typeTag: tag)
            return cell
        }
    }
    
    @objc func addButtonTapped(sender: UIButton) {
        print("Show UI to add new tag")
//        arrTag.insert(TypeTag(textTag: "Hello", backGround: "000000"), at: arrTag.count - 1)
        typeCollection.reloadData()
    }
}

//MARK: - CollectionView Delegate
extension AddVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = TAppDelegate.arrTag[indexPath.row]
        tagID = tag.firebaseKey
        let cell = typeCollection.cellForItem(at: indexPath)
        
        cell?.layer.borderWidth = 3.0
        cell?.layer.cornerRadius = 4
        cell?.layer.borderColor = UIColor.black.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        cell?.layer.borderColor = UIColor.clear.cgColor
    }
}

//MARK: - Support func
protocol NibReusable: class {
    static var reuseIdentifier: String { get }
    static var nibName: String { get }
}

extension NibReusable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
    static var reuseIdentifier: String {
        return nibName
    }
}

extension UITableViewCell: NibReusable { }

extension UICollectionViewCell: NibReusable { }

extension UITableViewHeaderFooterView: NibReusable { }

extension UICollectionView {
    func register<Cell: NibReusable>(_ cell: Cell.Type) {
        let nib = UINib(nibName: cell.nibName, bundle: Bundle(for: cell))
        register(nib, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    func dequeueReusableCell<Cell: NibReusable>(forIndexPath indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.reuseIdentifier)")
        }
        return cell
    }
}

extension UITableView {
    func register<Cell: NibReusable>(_ cell: Cell.Type) {
        let nib = UINib(nibName: Cell.nibName, bundle: Bundle(for: cell))
        register(nib, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReusableCell<Cell: NibReusable>(forIndexPath indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.reuseIdentifier)")
        }
        return cell
    }
    
    func registerHeaderFooterView<Cell: NibReusable>(_ cell: Cell.Type) {
        let nib = UINib(nibName: Cell.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReusableHeaderFooterView<Cell: NibReusable>() -> Cell {
        guard let header = dequeueReusableHeaderFooterView(withIdentifier: Cell.reuseIdentifier) as? Cell else {
            fatalError("Could not dequeue header with identifier: \(Cell.reuseIdentifier)")
        }
        return header
    }
}

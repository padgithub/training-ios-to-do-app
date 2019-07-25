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
import ContactsUI
import FirebaseStorage
import SDWebImage
import KRProgressHUD

enum TypeCell {
    case nomal
    case special
}

class AddVC: UIViewController, UINavigationControllerDelegate {
    //MARK: - DECLERA VAR, LET
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var txtTextView: UITextView!
    @IBOutlet weak var dateTimeToShow: UILabel!
    @IBOutlet weak var viewChooseDate: UIView!
    @IBOutlet weak var btnDelLabel: UIButton!
    @IBOutlet weak var imgAddImg: UIImageView!
    @IBOutlet weak var viewAddImg: UIView!
    @IBOutlet weak var viewImage: UIView!
    
    @IBOutlet weak var collecTypeTag: UICollectionView!
    @IBOutlet weak var collecAddPeople: UICollectionView!
    @IBOutlet weak var collecImage: UICollectionView!
    @IBOutlet weak var btnAddTask: UIButton!
    
    @IBOutlet weak var widthCollecImg: NSLayoutConstraint!
    
    @IBOutlet weak var dateChoose: UIDatePicker!
    @IBOutlet weak var txtChooseDate: UILabel!
    @IBOutlet weak var imgShowDate: UIImageView!
    
    @IBOutlet weak var txtNameTask: UITextField!
    
    let dateFormatter = DateFormatter()
    let contactPicker = CNContactPickerViewController()
    let storage = Storage.storage()
    var imagePicker: UIImagePickerController!
    var ref: DocumentReference? = nil
    var isEdit = false
    var taskEdit = ListTask(nameTask: "nil", descriptionTask: "nil", tagID: "nil")
    var tagID: String = ""
    var startDate = Date()
    var endDate = Date()
    var arrPeople: [String] = []
    var arrImagePeople = [CNContact]()
    var arrImgDesc = [UIImage]()
    var arrURL = [String]()
    var arrURLs = [URL]()
    var maxWidth = 0
    var urlTaskDel: String = ""
    
    //MARK: - ACTION BUTTON, VIEW
    @IBAction func btnDelLabelAction(_ sender: Any) {
        arrImagePeople.removeAll()
        collecAddPeople.reloadData()
        checkBtnDelPeople()
    }
    @IBAction func btnBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddPeople(_ sender: Any) {
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    @IBAction func actionDone(_ sender: Any) {
        if txtChooseDate.tag != 0 {
            viewDatePicker.isHidden = true
            
            dateFormatter.dateFormat = "dd-MM HH:mm:ss"
            endDate = dateChoose.date
            dateTimeToShow.text = configDate(startDate: startDate, endDate: endDate)
            
            txtChooseDate.text = "Choose Start Date"
            txtChooseDate.tag = 0
        }else
        {
            txtChooseDate.tag = 1
            txtChooseDate.text = "Choose End Date"
            
            dateFormatter.dateFormat = "dd-MM HH:mm:ss"
            startDate = dateChoose.date
        }
    }
    @IBAction func actionCancel(_ sender: Any) {
        viewDatePicker.isHidden = true
        txtChooseDate.text = "Choose Start Date"
        txtChooseDate.tag = 0
    }
    //Func Edit Tag
    @objc func cellTap(_ sender:Demo){
        let editTag = sender.obj
        let alertController = UIAlertController(title: "Sửa tag", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField) in
            textField.text = editTag.textTag
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            let txtTag = alertController.textFields![0].text
            var backGround = alertController.textFields![1].text
            
            if backGround == "" {
                backGround = self.hexString()
            }
            
            let refEdit = TAppDelegate.db.collection("Tag").document("\(editTag.firebaseKey)")
            refEdit.updateData([
                "textTag": txtTag as Any,
                "backGround": backGround as Any,
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        TAppDelegate.fetchTagNormal {
                            self.collecTypeTag.reloadData()
                        }
                        let alert = UIAlertController(title: "Thông báo", message: "Thay đổi thành công", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                        self.collecTypeTag.reloadData()
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            let refEdit = TAppDelegate.db.collection("Tag").document("\(editTag.firebaseKey)")
            refEdit.delete() { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    TAppDelegate.fetchTagNormal(success: {
                        self.collecTypeTag.reloadData()
                    })
                    let alert = UIAlertController(title: "Thông báo", message: "Xoá thành công", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil))
                    self.collecTypeTag.reloadData()
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        alertController.addTextField { (textField) in
            textField.text = editTag.backGround
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
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
            } else {
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
    
    func scrollToLastItem() {
        
        let lastSection = collecTypeTag.numberOfSections - 1
        
        let lastRow = collecTypeTag.numberOfItems(inSection: lastSection)
        
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        
        self.collecTypeTag.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
    }
    
    @objc func addImage() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func checkBtnDelPeople() {
        if arrImagePeople.count != 0 {
            btnDelLabel.isHidden = false
        } else {
            btnDelLabel.isHidden = true
        }
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        viewDatePicker.isHidden = !viewDatePicker.isHidden
    }
    
    func hexString() -> String {
        let red: CGFloat = .random()
        let green: CGFloat = .random()
        let blue: CGFloat = .random()
        let alpha: CGFloat = .random()
        
        return String(format: "%02X%02X%02X%02X", UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255), UInt8(alpha * 255))
    }
    
    func deleteImg(task: String) {
        let storageRef = storage.reference()
        let desertRef = storageRef.child("images/\(task)")
        
        // Delete the file
        desertRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("Delete image complete!")
            }
        }
    }
    
    func deleteImgLocal(url: URL) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: url.path)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func reloadCollecImage() {
        collecImage.reloadData()
        if (arrURLs.count * 67) > maxWidth {
            widthCollecImg.constant = CGFloat(maxWidth)
        } else {
            widthCollecImg.constant = CGFloat(integerLiteral: arrURLs.count * 67)
        }
    }
    
    func getStringURLDelete(str: String) -> String {
        var index = str.index(of: "%")!
        var newStr = String(str.suffix(from: index))
        index = newStr.index(of: "?")!
        newStr = String(newStr.prefix(upTo: index))
        newStr.removeFirst(3)
        
        return newStr
    }
    
    //MARK: - Valtidate Func
    func validateData() -> Bool {
        if (txtNameTask.text == "") || (txtTextView.text == "") || (tagID == "") || (startDate.timeIntervalSince1970 > endDate.timeIntervalSince1970) {
            return false
        } else {
            return true
        }
    }
    
    //MARK: - Fetch contact
    func fetchContact (arr: [String]) {
        let contactStore = CNContactStore()
        arr.forEach { (items) in
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactImageDataAvailableKey]
            do {
                let contact = try contactStore.unifiedContact(withIdentifier: items, keysToFetch: keys as [CNKeyDescriptor])
                arrImagePeople.append(contact)
            } catch {
                print(error)
            }
        }
    }
    
    func downloadImage(arr: [String]) {
        arr.forEach { (items) in
            let url = URL(string: items)
            let data = try? Data(contentsOf: url!)
            
            arrImgDesc.append(UIImage(data: data!)!)
        }
    }
    
    func uploadImage(arr: [UIImage],taskID: String, success: @escaping (() -> Void)) {
        if (arrURL.count == 0 && arrURLs.count == 0) || urlTaskDel != "" {
            success()
        } else {
            var i = arrURL.count
            arrImgDesc.forEach { (images) in
                let storageRef = storage.reference()
                let avatarRef = storageRef.child("images/\(taskID)-\(i).jpg")
                i += 1
                let _ = avatarRef.putData(images.pngData()!, metadata: nil) { (metadata, error) in
                    avatarRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        self.arrURL.append("\(downloadURL)")
                        if self.arrURL.count == i {
                            success()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - ADD, EDIT TASK
    @IBAction func btnAddTask(_ sender: Any) {
        btnAddTask.isEnabled = false
        if isEdit {
            let taskAdd: ListTask = ListTask(
                nameTask: txtNameTask.text ?? "nil",
                descriptionTask: txtTextView.text ?? "nil",
                tagID: tagID,
                timeStart: startDate.timeIntervalSince1970,
                timeEnd: endDate.timeIntervalSince1970,
                peopleName: arrPeople
            )
            
            if validateData() {
                KRProgressHUD.show()
                arrURLs.forEach { (items) in
                    if items.isFileURL {
                        let data = try? Data(contentsOf: items)
                        if let image = UIImage(data: data!) {
                            arrImgDesc.append(image)
                        }
                    }
                }
                
                self.uploadImage(arr: self.arrImgDesc,taskID: self.taskEdit.taskID, success: {
                    if self.urlTaskDel != "" {
                        self.deleteImg(task: self.urlTaskDel)
                    }
                    let editRef = TAppDelegate.db.collection("Task").document("\(self.taskEdit.taskID)")
                    editRef.updateData([
                        "nameTask": taskAdd.nameTask,
                        "descriptionTask": taskAdd.descriptionTask,
                        "tagID": taskAdd.tagID,
                        "timeStar": taskAdd.timeStart,
                        "timeEnd": taskAdd.timeEnd,
                        "peopleName": taskAdd.peopleName,
                        "imageURL": self.arrURL,
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                
                                KRProgressHUD.showSuccess()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                    }
                })
            } else {
                let alert = UIAlertController(title: "Thông báo", message: "Cần nhập đủ và chính xác dữ liệu", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                    self.btnAddTask.isEnabled = true
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            let taskAdd: ListTask = ListTask(
                nameTask: txtNameTask.text ?? "nil",
                descriptionTask: txtTextView.text ?? "nil",
                tagID: tagID,
                timeStart: startDate.timeIntervalSince1970,
                timeEnd: endDate.timeIntervalSince1970,
                peopleName: arrPeople
            )
            
            arrImagePeople.forEach { (objs) in
                arrPeople.append(objs.identifier)
            }
            
            if validateData() {
                KRProgressHUD.show(withMessage: "Updating pictures", completion: nil)
                
                ref = TAppDelegate.db.collection("Task").addDocument(data: [
                    "nameTask": taskAdd.nameTask,
                    "descriptionTask": taskAdd.descriptionTask,
                    "tagID": taskAdd.tagID,
                    "timeStar": taskAdd.timeStart,
                    "timeEnd": taskAdd.timeEnd,
                    "peopleName": arrPeople,
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            
                            self.arrURLs.forEach { (items) in
                                if items.isFileURL {
                                    let data = try? Data(contentsOf: items)
                                    if let image = UIImage(data: data!) {
                                        self.arrImgDesc.append(image)
                                    }
                                }
                            }
                            
                            print("Document added with ID: \(self.ref!.documentID)")
                            self.uploadImage(arr: self.arrImgDesc,taskID: self.ref!.documentID, success: {
                                if let taskID = self.ref?.documentID{
                                    TAppDelegate.db.collection("Task").document("\(taskID)").updateData([
                                        "taskID": taskID,
                                        "imageURL": self.arrURL,
                                        ])
//                                    KRProgressHUD.showSuccess()
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                        self.navigationController?.popViewController(animated: true)
                                    }
                                KRProgressHUD.showSuccess()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                        }
                }
            } else {
                let alert = UIAlertController(title: "Thông báo", message: "Cần nhập đủ và chính xác dữ liệu", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                    self.btnAddTask.isEnabled = true
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - ADD, EDIT TAG
    @objc func addButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: "Thêm tag mới", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Nhập tên tag"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let nameTag = alertController.textFields![0].text
            var backgroundTag = alertController.textFields![1].text
            
            if backgroundTag == "" {
                backgroundTag = self.hexString()
            }
            
            let newTag = TypeTag(textTag: nameTag ?? "nil", backGround: backgroundTag ?? self.hexString())
            let today = Date()
            self.ref = TAppDelegate.db.collection("Tag").addDocument(data: [
                "textTag": newTag.textTag,
                "backGround": newTag.backGround,
                "createTime":today.timeIntervalSince1970,
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(self.ref!.documentID)")
                        let alert = UIAlertController(title: "Thông báo", message: "Thêm thành công", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                            //Scroll
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
            }
            TAppDelegate.fetchTagNormal {
                self.collecTypeTag.reloadData()
            }
        })
        alertController.addTextField { (textField) in
            textField.placeholder = "Mã màu, ngẫu nhiên nếu trống"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        collecTypeTag.reloadData()
    }
    
    
    //MARK: - MAIN
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
        checkEdit(edit: isEdit)
        checkBtnDelPeople()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddVC.tapFunction))
        viewChooseDate.isUserInteractionEnabled = true
        viewChooseDate.addGestureRecognizer(tap)
        
        let geture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        viewAddImg.addGestureRecognizer(geture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollToLastItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func willMove(toParent parent: UIViewController?)
    {
        super.willMove(toParent: parent)
        if parent == nil
        {
            arrURLs.forEach { (urls) in
                if urls.isFileURL {
                    deleteImgLocal(url: urls)
                }
            }
        }
    }
}

//MARK: - INITUI, INITDATA
extension AddVC: UITextViewDelegate,UINavigationBarDelegate {
    func initUI() {
        
        collecTypeTag.register(TypeViewCell.self)
        collecTypeTag.register(SpecialCell.self)
        collecAddPeople.register(AddPeopleCell.self)
        collecImage.register(AddImageCell.self)
        
        //Layout Tag collection view cell
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: collecTypeTag.frame.width/3 - 10, height: collecTypeTag.frame.height/2 - 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        collecTypeTag!.collectionViewLayout = layout
        
        //Layout AddImage collection view cell
        let layoutAddImage: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutAddImage.itemSize = CGSize(width: 67, height: 67)
        layoutAddImage.minimumInteritemSpacing = 2
        layoutAddImage.minimumLineSpacing = 2
        layoutAddImage.scrollDirection = .horizontal
        collecImage!.collectionViewLayout = layoutAddImage
        
        btnAddTask.layer.cornerRadius = 10
        btnAddTask.clipsToBounds = true
        btnAddTask.layer.borderWidth = 1
        btnAddTask.layer.borderColor = UIColor("979797", alpha: 1.0).cgColor
        tagID = taskEdit.tag.firebaseKey
        widthCollecImg.constant = 0
        maxWidth = Int(viewImage.frame.width - 67)
        
        if !isEdit {
            txtTextView.text = "Description..."
            txtTextView.textColor = UIColor.lightGray
        }
    }
    
    func initData() {
        collecTypeTag.dataSource = self
        collecTypeTag.delegate = self
        collecAddPeople.dataSource = self
        collecAddPeople.delegate = self
        collecImage.dataSource = self
        collecImage.delegate = self
        txtTextView.delegate = self
        contactPicker.delegate = self
        
        dateTimeToShow.text = configDate(startDate: Date(), endDate: Date())
        
        if isEdit{
            let index = TAppDelegate.arrTag.firstIndex { (objs) -> Bool in
                return objs.firebaseKey == self.taskEdit.tagID
            }
            if index != nil {
                collecTypeTag.selectItem(at: IndexPath(item: index!, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
                let cell = collecTypeTag.cellForItem(at: IndexPath(item: index!, section: 0))
                
                cell?.layer.borderWidth = 3.0
                cell?.layer.cornerRadius = 4
                cell?.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    //MARK: - Edit Text View
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
    
    //MARK: - Set Data Edit View
    func checkEdit(edit: Bool){
        if edit{
            arrPeople = taskEdit.peopleName
            fetchContact(arr: arrPeople)
            btnAddTask.setTitle("Save", for: .normal)
            txtNameTask.text = taskEdit.nameTask
            txtTextView.text = taskEdit.descriptionTask
            
            let editStartTime = Date(timeIntervalSince1970: taskEdit.timeStart)
            let editEndTime = Date(timeIntervalSince1970: taskEdit.timeEnd)
            startDate = editStartTime
            endDate = editEndTime
            dateTimeToShow.text = configDate(startDate: editStartTime, endDate: editEndTime)
            arrURL = taskEdit.imageURL
        }
        arrURL.forEach { (items) in
            //            loadImageCGD(url: items)
            if let url = URL.init(string: items){
                arrURLs.append(url)
                reloadCollecImage()
                
                self.collecImage.reloadData()
            }
        }
    }
}

//MARK: - COLLECTIONVIEW DATA SOURCE
extension AddVC : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collecTypeTag {
            return TAppDelegate.arrTag.count
        } else if collectionView == self.collecAddPeople {
            return arrImagePeople.count
        } else {
            return arrURLs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collecTypeTag {
            let tag = TAppDelegate.arrTag[indexPath.row]
            
            switch tag.type {
            case .special:
                let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as SpecialCell
                let createAction = UITapGestureRecognizer(target: self, action: #selector(addButtonTapped))
                
                cell.viewButton.addGestureRecognizer(createAction)
                cell.btnAdd.addTarget(self, action: #selector(addButtonTapped), for: UIControl.Event.touchUpInside)
                
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TypeViewCell
                let gestureCreated = Demo(target: self, action: #selector(cellTap(_:)))
                gestureCreated.obj = tag
                
                cell.addGestureRecognizer(gestureCreated)
                cell.cofig(typeTag: tag)
                if tagID == tag.firebaseKey {
                    cell.layer.borderWidth = 3.0
                    cell.layer.cornerRadius = 4
                    cell.layer.borderColor = UIColor.init("19ff19", alpha: 1.0).cgColor
                } else {
                    cell.layer.borderWidth = 0
                    cell.layer.borderColor = UIColor.clear.cgColor
                }
                return cell
            }
        } else if collectionView == self.collecAddPeople {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as AddPeopleCell
            let data = arrImagePeople[indexPath.row]
            
            if data.imageDataAvailable {
                cell.isHide = true
                cell.imgAvatar.image = UIImage(data: data.imageData!)
            } else {
                cell.isHide = false
                cell.dataLabel = (String(describing: data.familyName.first!)) + (String(describing: data.givenName.first!))
            }
            cell.config()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as AddImageCell
            //            cell.imgDesc.image = arrImgDesc[indexPath.row]
            cell.config(path: arrURLs[indexPath.row])
            return cell
        }
    }
}


//MARK: - COLLECTIONVIEW DELEGATE
extension AddVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collecTypeTag {
            let tag = TAppDelegate.arrTag[indexPath.row]
            tagID = tag.firebaseKey
            collecTypeTag.reloadData()
        } else {
            _ = UIAlertController.present(style: .actionSheet, title: "Select action", message: nil, attributedActionTitles: [("Delete Image", .default), ("View Image", .default), ("Cancel", .cancel)], handler: { (action) in
                if action.title == "Delete Image" {
                    if self.isEdit{
                        if self.arrURLs[indexPath.row].isFileURL {
                            self.deleteImgLocal(url: self.arrURLs[indexPath.row])
                        } else {
                            self.urlTaskDel = self.getStringURLDelete(str: "\(self.arrURLs[indexPath.row])")
                            self.arrURL.remove(at: indexPath.row)
                        }
                        
                        self.arrURLs.remove(at: indexPath.row)
                        self.reloadCollecImage()
                    } else {
                        self.deleteImgLocal(url: self.arrURLs[indexPath.row])
                        self.arrURLs.remove(at: indexPath.row)
                        self.reloadCollecImage()
                    }
                } else if action.title == "View Image" {
                    let detailVC = DetailImageController.init(nibName: "DetailImageController", bundle: nil)
                    detailVC.arrURLs = self.arrURLs
                    detailVC.imgChoiced = self.arrURLs[indexPath.row]
                    
                    self.navigationController?.pushViewController(detailVC, animated: true)

                }
            })
        }
    }
}

extension AddVC: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        var isNew = true
        
        for i in 0 ..< arrImagePeople.count {
            if arrImagePeople[i].identifier == contact.identifier {
                isNew = false
                return
            }
        }
        
        if isNew {
            arrImagePeople.append(contact)
            collecAddPeople.reloadData()
        }
        checkBtnDelPeople()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    }
}

//MARK: - IMAGE PICKER
extension AddVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
     
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            //            //let imageData = NSData(contentsOfFile: localPath!)!
            let photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
            print(photoURL)
            arrURLs.append(photoURL)
            collecImage.reloadData()
        }
        reloadCollecImage()
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/4/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SwiftyJSON
import UserNotifications

let TAppDelegate = UIApplication.shared.delegate as! AppDelegate
let TApp = UIApplication.shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var db: Firestore!
    var arrTag = [TypeTag]()
    var userUID: String = ""
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "TestIdentifier" {
            print("action when click")
        }
        completionHandler()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        
        UINavigationBar.appearance().barTintColor = UIColor.white
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        if Auth.auth().currentUser != nil {
//            try! Auth.auth().signOut()
            fetchTag()
        } else {
            let vc = LoginVC.init(nibName: "LoginVC", bundle: nil)
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            window?.rootViewController = nav
        }
        
        //Notification
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            print("granted: \(granted)")
        }
        return true
    }
    
    func fetchTag() {
        let user = Auth.auth().currentUser
        if let user = user {
            userUID = user.uid
        }
        db.collection("Tag").document(userUID).collection("UserTag").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.arrTag.removeAll()
                for document in querySnapshot!.documents {
                    let obj = TypeTag.init(data: JSON.init(document.data()), firebaseKey: document.documentID)
                    self.arrTag.append(obj)
                    self.initHome()
                }
                self.arrTag = self.arrTag.sorted(by: { $0.createTime < $1.createTime })
                self.arrTag.append(TypeTag(textTag: "", backGround: "", type: .special))
            }
        }
    }
    
    func fetchTagNormal(success: @escaping () -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            userUID = user.uid
        }
        db.collection("Tag").document(userUID).collection("UserTag").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.arrTag.removeAll()
                for document in querySnapshot!.documents {
                    let obj = TypeTag.init(data: JSON.init(document.data()), firebaseKey: document.documentID)
                    self.arrTag.append(obj)
                }
                self.arrTag = self.arrTag.sorted(by: { $0.createTime < $1.createTime })
                self.arrTag.append(TypeTag(textTag: "", backGround: "", type: .special))
                success()
            }
        }
    }
    
    func initHome() {
            let showVC = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
            let nav = UINavigationController(rootViewController: showVC)
            window?.rootViewController = nav
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}


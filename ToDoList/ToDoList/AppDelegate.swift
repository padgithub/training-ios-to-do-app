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
        
        fetchTag()
        
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
                }
                self.arrTag = self.arrTag.sorted(by: { $0.createTime < $1.createTime })
                self.arrTag.append(TypeTag(textTag: "", backGround: "", type: .special))
                self.initHome()
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
//        let vc = AddVC.init(nibName: "AddVC", bundle: nil)
//        let Editvc = EditVC.init(nibName: "EditVC", bundle: nil)
//        let vc = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
        if Auth.auth().currentUser != nil {
            let showVC = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
            let nav = UINavigationController(rootViewController: showVC)
            window?.rootViewController = nav
        } else {
            let vc = LoginVC.init(nibName: "LoginVC", bundle: nil)
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            window?.rootViewController = nav
        }
        
        window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


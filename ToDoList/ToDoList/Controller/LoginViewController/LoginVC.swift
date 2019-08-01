//
//  LoginVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/26/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class LoginVC: UIViewController {
    //MARK: - DECLERA VAR, LET
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - ACTION BUTTON
    @IBAction func actionButtonLogin(_ sender: Any) {
        Auth.auth().signIn(withEmail: txtUserName.text ?? "", password: txtPassword.text ?? "") { (user, err) in
            if err != nil {
                if err!.localizedDescription == "The email address is badly formatted." {
                    KRProgressHUD.showError(withMessage: "Email sai định dạng")
                } else if err!.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                    KRProgressHUD.showError(withMessage: "Tài khoản không tồn tại")
                } else if err!.localizedDescription == "The password is invalid or the user does not have a password." {
                    KRProgressHUD.showError(withMessage: "Sai tài khoản hoặc mật khẩu")
                }
                
                print("Loi: \(err!.localizedDescription)")
            } else {
                TAppDelegate.fetchTag()
                let showTaskVC = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
                self.navigationController?.pushViewController(showTaskVC, animated: true)
            }
        }
    }
    
    @IBAction func actionButtonRegister(_ sender: Any) {
        let registerVC = RegisterVC.init(nibName: "RegisterVC", bundle: nil)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
}

extension LoginVC {
    func initUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func initData() {
        txtPassword.delegate = self
        txtUserName.delegate = self
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUserName {
            txtUserName.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtPassword.resignFirstResponder()
        }
        return true
    }
}

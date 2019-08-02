//
//  RegisterVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/26/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class RegisterVC: UIViewController {
    //MARK: - DECLARE VAR, LET
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var topConstrainRegister: NSLayoutConstraint!
    @IBOutlet weak var topConstrainTextRegister: NSLayoutConstraint!
    @IBOutlet var viewMain: UIView!
    @IBOutlet weak var botConstraintRegister: NSLayoutConstraint!
    
    //MARK: - ACCTION BUTTON
    @IBAction func actionButtonRegister(_ sender: Any) {
        if validate() {
            if txtPassword.text != txtConfirmPass.text {
                KRProgressHUD.showError(withMessage: "Mật khẩu không khớp")
                return
            }
            KRProgressHUD.show()
            Auth.auth().createUser(withEmail: txtEmail.text ?? "", password: txtPassword.text ?? "") { (user, err) in
                if err != nil {
                    if err!.localizedDescription == "The email address is badly formatted." {
                        KRProgressHUD.showError(withMessage: "Email sai định dạng")
                    } else if err!.localizedDescription == "The password must be 6 characters long or more." {
                        KRProgressHUD.showError(withMessage: "Mật khẩu cần dài hơn 6 ký tự")
                    } else {
                        KRProgressHUD.showError()
                        print("Lỗi: \(err!.localizedDescription)")
                    }
                } else {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.txtUserName.text
                    changeRequest?.commitChanges { (error) in
                        if error != nil {
                            return
                        }
                        if Auth.auth().currentUser != nil {
                            KRProgressHUD.showSuccess()
                            TAppDelegate.fetchTag()
                            let showTaskVC = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
                            self.navigationController?.pushViewController(showTaskVC, animated: true)
                        }
                    }
                    print("Register successful!")
                }
                
            }
        } else {
            KRProgressHUD.showError(withMessage: "Vui lòng nhập đầy đủ dữ liệu!")
        }
    }
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func validate() -> Bool {
        if (txtEmail.text == "") || (txtUserName!.text == "") || (txtPassword.text == "") || (txtConfirmPass.text == "") {
            return false
            } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initData()
    }
}

extension RegisterVC {
    func initUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func initData() {
        txtUserName.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtConfirmPass.delegate = self
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let constrain = viewMain.frame.height / 3
        
        if textField == txtUserName {
            topConstrainRegister.constant = (0 - constrain) / 2
            botConstraintRegister.constant = constrain
            topConstrainTextRegister.constant = (0 - constrain) / 2
            textField.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        } else if textField == txtEmail {
            textField.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {

            textField.resignFirstResponder()
            txtConfirmPass.becomeFirstResponder()
        } else if textField == txtConfirmPass {
            if topConstrainTextRegister.constant == (0 - constrain) / 2 {
                topConstrainRegister.constant -= (0 - constrain) / 2
                botConstraintRegister.constant -= constrain
                topConstrainTextRegister.constant -= (0 - constrain) / 2
            }
            textField.resignFirstResponder()
        }
        return true
    }
}

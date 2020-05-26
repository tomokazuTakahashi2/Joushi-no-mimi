//
//  LoginNextViewController.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/03/10.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginNextViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {

            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }

            // HUDで処理中を表示
            SVProgressHUD.show()

            Auth.auth().signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")

                // HUDを消す
                SVProgressHUD.dismiss()

                // 画面を閉じてViewControllerへ遷移
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "View")
                viewController?.modalPresentationStyle = .fullScreen
                self.present(viewController!, animated: true, completion: nil)
            }
        }
    }
    //画面をタップしたらキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  NewLoginViewController.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/03/10.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NewLoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
        @IBAction func handleCreateAccountButton(_ sender: Any) {
            if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text{

                // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
                if address.isEmpty || password.isEmpty || displayName.isEmpty{
                    print("DEBUG_PRINT: 何かが空文字です。")
                    SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                    return
    
                }
            

                // HUDで処理中を表示
                SVProgressHUD.show()

                // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
                Auth.auth().createUser(withEmail: address, password: password) { user, error in
                    if let error = error {
                        // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                        return
                    }
                    print("DEBUG_PRINT: ユーザー作成に成功しました。")

                    // 表示名を設定する
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = displayName
                        changeRequest.commitChanges { error in
                            if let error = error {
                                // プロフィールの更新でエラーが発生
                                print("DEBUG_PRINT: " + error.localizedDescription)
                                SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                                return
                            }
                            print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                            // HUDを消す
                            SVProgressHUD.dismiss()

                            // 画面を閉じてViewControllerへ遷移
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "View")
                            viewController?.modalPresentationStyle = .fullScreen
                            self.present(viewController!, animated: true, completion: nil)
                        }
                    }
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

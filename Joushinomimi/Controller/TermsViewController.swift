//
//  TermsViewController.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/05/26.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import SVProgressHUD

class TermsViewController: UIViewController {
    
    @IBOutlet weak var consentButton1: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    
    private let checkedImage = UIImage(named: "チェックリストON")
    private let uncheckedImage = UIImage(named: "チェックリストOFF")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /// Button1の設定
        self.consentButton1.setImage(uncheckedImage, for: .normal)
        self.consentButton1.setImage(checkedImage, for: .selected)
    }
    

    func checkNextButtonenable(){
       /// どちらも同意チェック済みか判断する
       if self.consentButton1.isSelected{
           self.nextPageButton.tintColor = UIColor.white
           self.nextPageButton.layer.cornerRadius = 5
           self.nextPageButton.layer.borderWidth = 1
           self.nextPageButton.layer.backgroundColor = UIColor.blue.cgColor
       } else {
           self.nextPageButton.tintColor = UIColor.white
           self.nextPageButton.layer.cornerRadius = 5
           self.nextPageButton.layer.borderWidth = 1
           self.nextPageButton.layer.backgroundColor = UIColor.gray.cgColor

       }
   }
    @IBAction func consentButton1DidTap(_ sender: Any) {
        /// 選択状態を反転させる
        self.consentButton1.isSelected = !self.consentButton1.isSelected
        checkNextButtonenable()
    }
    @IBAction func nextPageButtonDidTap(_ sender: Any) {
          /// どちらも同意チェック済みの場合のみアクションさせる
          if self.consentButton1.isSelected{
              print("次に進めます")
            performSegue(withIdentifier: "toNewLogin", sender: nil)
          }else{
            SVProgressHUD.showError(withStatus: "同意してください")
            
            
            return
        }
        
      }

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

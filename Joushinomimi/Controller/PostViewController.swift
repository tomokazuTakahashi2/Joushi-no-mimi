import UIKit
import Firebase
import Kingfisher

class PostViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentView: UITextView!

//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //commentView編集不可
        commentView.textContainerInset = UIEdgeInsets.zero
        commentView.textContainer.lineFragmentPadding = 0
        
    }
//MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 表示名とを取得してnameLabelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            nameLabel.text = user.displayName
        }
        //プロフィール画像を表示する
        //ダウンロード URL
            let storageRef = Storage.storage().reference(forURL: "gs://joushinomimi.appspot.com")
            // Create a reference to the file you want to download
            let starsRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/profile-picture.jpg")

            // Fetch the download URL
            starsRef.downloadURL { url, error in
              if let error = error {
                // Handle any errors
                print(error)
                return
              } else {
                // Get the download URL for 'images/stars.jpg'
                print("Image URL: \((url?.absoluteString)!)")
                //Kingfisher
                let url = URL(string: (url?.absoluteString)!)
                self.profileImageView.kf.setImage(with: url)
              }

            }
        
    }
//MARK: - タップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

//MARK: - 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // ImageViewから画像を取得する
        let profileImageData = profileImageView.image!.jpegData(compressionQuality: 0.5)
        let profileImageString = profileImageData!.base64EncodedString(options: .lineLength64Characters)
        //もし、プロフィールイメージが空なら、デフォルト画像を表示しておく。
        if profileImageView.image == nil {
            let image1 = UIImage(named: "defaultProfileImage")
            profileImageView.image = image1
        }

        // postDataに必要な情報を取得しておく
        let uid = Auth.auth().currentUser?.uid
        let postRef = Database.database().reference().child(Const.PostPath)
        let time = Date.timeIntervalSinceReferenceDate
        let name = Auth.auth().currentUser?.displayName
        let autoIdKey = postRef.childByAutoId().key

        // 辞書を作成してFirebaseに保存する
        let postDic = ["autoIdKey":autoIdKey!, "uid":uid!, "name": name!,"caption": textField.text!, "time": String(time), "postComment": commentView.text!,"profileImage": profileImageString] as [String : Any]
        postRef.childByAutoId().setValue(postDic)

        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }

//MARK: - キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        dismiss(animated: true, completion: nil)
    }
 
    
}

//
//  HomeViewController.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/02/14.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!

    var postArray: [PostData] = []
    //ブロックされたユーザーIDの値を持ってきて格納する配列
    var blockUserIdDic = [ReportBlock]()
    //引っ張って更新
    let refresh = UIRefreshControl()

    // DatabaseのobserveEventの登録状態を表す
    var observing = false
//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューの２セット
        tableView.delegate = self
        tableView.dataSource = self

        // テーブルセルのタップを無効にする
        tableView.allowsSelection = false

        //カスタムセル
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
        
        //リフレッシュコントローラー（引っ張って更新）
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
        
        tableView.reloadData()

    }
    @objc func update(){
        tableView.reloadData()
        // クルクルを止める
        refresh.endRefreshing()
    }
//MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        //現在のユーザーがnillでなかったら、（ログインしていたら）
        if Auth.auth().currentUser != nil {
            //self.observing == falseの時、
            if self.observing == false {
            // 💡要素が追加されたらpostArrayに追加してTableViewを再表示する
                //FIRDatabaseのReference
                let postsRef = Database.database().reference().child(Const.PostPath)
                //FIRDatabaseのchildAddedイベント（子の追加）
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: 要素が追加されました。")

                //💡 PostDataクラスを生成して受け取ったデータを設定する
                    //Auth.auth().currentUser?.uidがnilでなかったら、uidとする
                    if let uid = Auth.auth().currentUser?.uid {
                        //PostDataをpostDataとする
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        //0番のインデックスに新しいデータを挿入する
                        self.postArray.insert(postData, at: 0)

                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
            // 💡要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                //FIRDatabaseのchildChangedイベント（子の変更）
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: 要素が変更されました。")
                    
                    //Auth.auth().currentUser?.uidがnilでなかったら、
                    if let uid = Auth.auth().currentUser?.uid {
                    // 💡PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)

                    // 💡保持している配列からidが同じものを探す
                        //初期値は0
                        var index: Int = 0
                        //postArrayから一つずつ取り出す
                        for post in self.postArray {
                            //取り出したID(post.id)とポストデータのID（postData.id）が同じとき、
                            if post.id == postData.id {
                                //（一致したIDのうちの）最初のインデックスをindexとする
                                index = self.postArray.firstIndex(of: post)!
                                break
                            }
                        }

                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)

                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)

                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })

                // DatabaseのobserveEventが上記コードにより登録されたためtrueとする
                observing = true
            }
        //現在のユーザーがnillだったら、（ログインしていなかったら）
        } else {
            //observing == trueの時、
            if observing == true {
            // 💡ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                //テーブルビューを再読み込みする
                tableView.reloadData()
                
                let postsRef = Database.database().reference().child(Const.PostPath)
                // オブザーバーを削除する
                postsRef.removeAllObservers()

                // DatabaseのobserveEventが上記コードにより解除されたためfalseとする
                observing = false
            }
        }
        //ブロック機能
        //getBlockUser()
    }
   //MARK: - ブロック機能
    
//    func getBlockUser() {
//        //FIRDatabaseのReference
//        let postsRef = Database.database().reference().child(Const2.PostPath)
//
//        //includeKeyでBlockの子クラスである会員情報を持ってきている
//        postsRef.child("blockId")
//
//
//        //resultかerrorに何か入ってきたら、
//        postsRef.child("blockId")({ (result, error) in
//            //errorがnilでなかったら（エラーがあったら）
//            if error != nil {
//                //エラーの処理
//                print(error)
//            //errorがnilだったら（エラーがなかったら）→result
//            } else {
//                //ブロックされたユーザーのIDが含まれる + removeall()は初期化していて、データの重複を防いでいる
//                self.blockUserIdDic.removeAll()
//                //resultから一つずつ取り出す（＝blockObject）
//                for blockObject in result as! [NCMBObject] {
//                    //この部分で①の配列（blockUserIdArray）にブロックユーザー情報が格納
//                    //blockUserIdArrayに取り出したオブジェクト(キー値："blockUserID")を追加（append）する
//                    self.blockUserIdArray.append(blockObject.object(forKey: "blockUserID") as! String)
//
//                }
//
//            }
//        })
//        //再読み込み
//        loadData()
//    }
//
//    //③
//    func loadData(){
//        //ここにNCMBから値を持ってくるコードが書いてある前提
//        //appendする時に、ブロックユーザーがnilであったらappendされるようにしている。
//        if self.blockUserIdArray.firstIndex(of: 〇〇.user.objectId) == nil{
//            self.〇〇.append(〇〇)
//        }
//    }
    
    
//MARK: - テーブルビュー
    //セルの数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    //セルを構築する際に呼ばれる
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])

        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    //セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    //自分以外＝>報告・ブロックする
    internal func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let postData = postArray[indexPath.row]
        let postRef = Database.database().reference()
        let const1 = postRef.child(Const.PostPath)
        let const2 = postRef.child(Const2.PostPath)
        
        //もし、投稿ユーザーIDが自分のIDじゃなかったら、
        if postData.uid != Auth.auth().currentUser?.uid{

            //スワイプアクション報告ボタン
            let reportButton: UIContextualAction = UIContextualAction(style: .normal, title: "報告",handler:  { (action: UIContextualAction, view: UIView, success :(Bool) -> Void )in
                let reportBlock = self.blockUserIdDic[indexPath.row]
                print(reportBlock)
                let postDataId = const2.child(reportBlock.id!)                //アラートコントローラー
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                //報告アクション
                let reportAction = UIAlertAction(title: "報告する", style: .destructive ){ (action) in
                    //表示
                    SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
                    //参照
                    let reportUserId = reportBlock.reportId
                    let blockUserIdDic = ["reportID": postDataId,"reportUser": reportUserId as Any] as [String : Any]
                    //保存
                    postRef.childByAutoId().setValue(blockUserIdDic)

                }
                //アラートアクションのキャンセルボタン
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                //UIAlertControllerにActionを追加(報告とキャンセル)
                alertController.addAction(reportAction)
                alertController.addAction(cancelAction)
                //アラートを表示
                self.present(alertController, animated: true, completion: nil)
                tableView.isEditing = false

            })
            //報告ボタンの色(赤)
            reportButton.backgroundColor = UIColor.red
            
            //スワイプアクションブロックボタン
            let blockButton: UIContextualAction = UIContextualAction(style: .normal, title: "ブロック",handler:  { (action: UIContextualAction, view: UIView, success :(Bool) -> Void )in
                //self.comments.remove(at: indexPath.row)
                //tableView.deleteRows(at: [indexPath], with: .fade)
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
                    SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
//                    //参照
//                    let blockUserId = reportBlock.blockId
//                    let blockUserIdDic = ["blockID": postDataId,"blockId": blockUserId as Any] as [String : Any]
//                    //保存
//                    postRef.childByAutoId().setValue(blockUserIdDic)


                     //ここで③を読み込んでいる

                }
                //アラートアクションのキャンセルボタン
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                //UIAlertControllerにActionを追加(ブロックとキャンセル)
                alertController.addAction(blockAction)
                alertController.addAction(cancelAction)
                //アラートを表示
                self.present(alertController, animated: true, completion: nil)
                //テーブルビューの編集→切
                tableView.isEditing = false
            })
            //ブロックボタンの色(青)
            blockButton.backgroundColor = UIColor.blue
            
            return UISwipeActionsConfiguration(actions: [blockButton,reportButton])
            
        //投稿ユーザーが自分だったら、
        } else {
            //スワイプアクション削除ボタン
            let deleteButton = UIContextualAction(style: .normal, title: "削除",handler:  { (action: UIContextualAction, view: UIView, success :(Bool) -> Void )in
   
                                //非同期的：タスクをディスパッチキューに追加したら、そのタスクの処理完了を待たずに次の行に移行する。
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: "投稿を削除しますか？", message: nil, preferredStyle: .alert)
                                    //削除のキャンセル
                                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                                        alertController.dismiss(animated: true, completion: nil)
                                    }
                                    //削除をする
                                    let deleteAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                        //オブジェクトの削除
                                        const1.child(postData.id!).removeValue()
                                        print("削除しました")
                                        
                                    }
                                    //UIAlertControllerにキャンセルアクションを追加
                                    alertController.addAction(cancelAction)
                                    //UIAlertControllerに削除アクションを追加
                                    alertController.addAction(deleteAction)
                                    //アラートを表示
                                    self.present(alertController,animated: true,completion: nil)
                                    //テーブルビューの編集→切
                                    tableView.isEditing = false
                                }
            })
            //削除ボタンの色(赤)
            deleteButton.backgroundColor = UIColor.red //色変更
            
            return UISwipeActionsConfiguration(actions:[deleteButton])
            
        }

    }
    
//MARK: - ハートボタン
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // Firebaseに保存するデータの準備
        //uidとは現在のログイン者である
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    //likeId = 自分だったら、
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.firstIndex(of: likeId)!
                        break
                    }
                }
                //削除する
                postData.likes.remove(at: index)
            } else {
                //追加する
                postData.likes.append(uid)
            }

            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)

        }
    }
   
}



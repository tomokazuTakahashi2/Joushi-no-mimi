//
//  SearchViewController.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/02/15.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase


class SearchViewController: UIViewController,UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //Firebase参照
    var ref: DatabaseReference!
    
    // 検索用配列
    var items : [PostData] = []
    // 検索結果配列
    var searchResult : [PostData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューの２セット
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        searchTableView.allowsSelection = false
        //カスタムセル
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        searchTableView.register(nib, forCellReuseIdentifier: "Cell")

        // テーブル行の高さをAutoLayoutで自動調整する
        searchTableView.rowHeight = UITableView.automaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        searchTableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
        
        // デリゲートを設定
        searchBar.delegate = self
        //キャンセルボタンを表示
        searchBar.showsCancelButton = true
        
    //FirebaseDBから配列へ
        let postRef = Database.database().reference()
        postRef.child("posts").observe(DataEventType.value, with: { (snapshot) in
            //uidがAuth.auth().currentUser?.uidかどうかをチェック
            guard let uid = Auth.auth().currentUser?.uid else { return }
            //snapshot.childrenから一つずつ取り出す
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                //検索用配列に追加する
                self.items.append(PostData(snapshot: snap, myId: uid))
            }
         })
    }
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        //もしカレントユーザーがnilじゃなかったら、（ログインしていたら）
        if Auth.auth().currentUser != nil {

            if self.observing == false {
                // 要素が追加されたらsearchResultに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in

                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.searchResult.insert(postData, at: 0)

                        // TableViewを再表示する
                        self.searchTableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをsearchResultから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in

                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)

                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.searchResult {
                            if post.id == postData.id {
                                index = self.searchResult.firstIndex(of: post)!
                                break
                            }
                        }

                        // 差し替えるため一度削除する
                        self.searchResult.remove(at: index)

                        // 削除したところに更新済みのデータを追加する
                        self.searchResult.insert(postData, at: index)

                        // TableViewを再表示する
                        self.searchTableView.reloadData()
                    }
                })

                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        //ログインしていなかったら、
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                searchResult = []
                searchTableView.reloadData()
                // オブザーバーを削除する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.removeAllObservers()

                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
        
    }
// MARK: - Search Bar Delegate Methods

    //キャンセルボタンをクリック
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           // キャンセルされた場合、検索は行わない。
           searchBar.text = ""
           self.view.endEditing(true)
            print("検索をしません")
       }
    //検索ボタンをクリック
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

            // キーボードを閉じる。
            self.view.endEditing(true)
            //検索する
            searchItems(searchText: searchBar.text! as String)

       }

    //MARK: - 渡された文字列を含む要素を検索し、テーブルビューを再表示する
    func searchItems(searchText: String) {
        ///サーチテクストが空欄じゃなかったら、
        if searchText != "" {
            //検索結果配列に検索用配列をフィルタリングしたものを入れる
            searchResult = items.filter { item in
                item.postComment?.contains(searchText) ?? false
            }
            print("検索結果" + String(searchResult.count))
        }
        
        //tableViewを再読み込みする
        searchTableView.reloadData()
    }
    
//MARK: - TableView Delegate Methods
    //セルの数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    //セルを構築する際に呼ばれる
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(searchResult[indexPath.row])

        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    //セルの高さを決める
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    //MARK: - ハートボタン
     // セル内のボタンがタップされた時に呼ばれるメソッド
     @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
         print("DEBUG_PRINT: likeボタンがタップされました。")

         // タップされたセルのインデックスを求める
         let touch = event.allTouches?.first
         let point = touch!.location(in: self.searchTableView)
         let indexPath = searchTableView.indexPathForRow(at: point)

         // 配列からタップされたインデックスのデータを取り出す
         let postData = searchResult[indexPath!.row]

         // Firebaseに保存するデータの準備
         if let uid = Auth.auth().currentUser?.uid {
             if postData.isLiked {
                 // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                 var index = -1
                 for likeId in postData.likes {
                     if likeId == uid {
                         // 削除するためにインデックスを保持しておく
                         index = postData.likes.firstIndex(of: likeId)!
                         break
                     }
                 }
                 postData.likes.remove(at: index)
             } else {
                 postData.likes.append(uid)
             }

             // 増えたlikesをFirebaseに保存する
             let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
             let likes = ["likes": postData.likes]
             postRef.updateChildValues(likes)

         }
     }
}


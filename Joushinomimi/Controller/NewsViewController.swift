//
//  NewsViewController.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/03/22.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import SDWebImage
import SafariServices

class NewsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    //インジケーター（ぐるぐる）
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    //データモデルを格納する配列
    var dataList:[NewsModel] = []
    // 検索用配列
    var newsItems : [NewsModel] = []
    // 検索結果配列
    var newsSearchResult : [NewsModel] = []
    
    let refresh = UIRefreshControl()
    
    @IBOutlet var newsSearchBar: UISearchBar!
    
    @IBOutlet weak var newsTableView: UITableView!

//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //読み込み中(ぐるぐる)
            // インジゲーターの設定
            activityIndicatorView.center = view.center
            activityIndicatorView.style = .whiteLarge
            activityIndicatorView.color = .purple
            view.addSubview(activityIndicatorView)
            // アニメーション開始
            activityIndicatorView.startAnimating()

            DispatchQueue.global(qos: .default).async {
                // 非同期処理などを実行（今回は５秒間待つだけ）
                Thread.sleep(forTimeInterval: 5)

                // 非同期処理などが終了したらメインスレッドでアニメーション終了
                DispatchQueue.main.async {
                    // アニメーション終了
                    self.activityIndicatorView.stopAnimating()
                }
            }
        
    
        //テーブルビューの２セット
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        //サーチバー
            // デリゲートを設定
            newsSearchBar.delegate = self
            //キャンセルボタンを表示
            newsSearchBar.showsCancelButton = true
        
        //カスタムセル
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        newsTableView.register(nib, forCellReuseIdentifier: "NewsCell")
       
        
        //リフレッシュコントローラー（引っ張って更新）
        newsTableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
        
        reloadListDatas()
        
        newsTableView.reloadData()
        
    }
    @objc func update(){
        reloadListDatas()
        newsTableView.reloadData()
        // クルクルを止める
        refresh.endRefreshing()
    }
    
    //MARK: - 画面をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
//MARK: - reloadListDatas
    func reloadListDatas(){
        //セッション用のコンフィグを設定・今回はデフォルトの設定
        let config = URLSessionConfiguration.default
        //NSURLSessionのインスタンスを生成
        let session = URLSession(configuration: config)
        //接続するURLを指定
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=jp&apiKey=59288c383f6b40b1969c83c8fae0f0be")
        //通信処理タスクを設定
        let task = session.dataTask(with: url!){
            (data,response,error)in
            
            //エラーが発生した場合にのみ処理
            if error != nil {
                //エラーが発生したことをアラート表示
                let controller : UIAlertController = UIAlertController(title: nil, message: "エラーが発生しました", preferredStyle: UIAlertController.Style.alert)
                controller.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(controller,animated: true, completion: nil)
                //表示後は処理終了
                return
            }
            //エラーがなければ、JSON形式にデータを変換して格納
            guard let jsonData: Data = data else{
                //エラーが発生したことをアラートで表示
                let controller : UIAlertController = UIAlertController(title: nil, message: "エラーが発生しました", preferredStyle: UIAlertController.Style.alert)
                controller.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(controller,animated: true, completion: nil)
                //表示後は処理終了
                return
            }
            
            //self.dataList = try! JSONDecoder().decode([NewsModel].self, from: jsonData)
            let jsonTest = try! JSONDecoder().decode(Test.self, from: jsonData) as Test
            print(jsonTest)
            //JSONデータを
            if let articles = jsonTest.articles {
                for newsModel in articles {
                    self.newsSearchResult.append(newsModel)
                    self.newsItems.append(newsModel)
                }
            }
            //メインスレッドに処理を戻す
            DispatchQueue.main.async {
                //最新のデータに更新する
                self.newsTableView.reloadData()
            }
        }
        //タスクを実施
        task.resume()
    }
    //MARK: - 渡された文字列を含む要素を検索し、テーブルビューを再表示する
    func searchItems(searchText: String) {
        ///サーチテクストが空欄じゃなかったら、
        if searchText != "" {
            newsSearchResult = []
            //検索結果配列に検索用配列をフィルタリングしたものを入れる
            newsSearchResult = newsItems.filter { item in
                item.title?.contains(searchText) ?? false
            }
            print("検索結果" + String(newsSearchResult.count))
            print(newsItems)
        }else{
            //渡された文字列が空の場合は全てを表示
            newsSearchResult = newsItems
        }
        
        //tableViewを再読み込みする
        self.newsTableView.reloadData()
    }
    // MARK: - Search Bar Delegate Methods

       //キャンセルボタンをクリック
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           
           // キャンセルされた場合、検索は行わない。
           searchBar.text = ""
           self.view.endEditing(true)
            print("検索をしません")
        
            //tableViewを再読み込みする
                // 差し替えるため一度削除する
                self.newsSearchResult.removeAll()
                // 削除したところに更新済みのデータを追加する
                //self.newsSearchResult.insert(newsModel, at: index)
                self.newsTableView.reloadData()
                reloadListDatas()
                print("再読み込み")
        
            //読み込み中(ぐるぐる)
            // インジゲーターの設定
            activityIndicatorView.center = view.center
            activityIndicatorView.style = .whiteLarge
            activityIndicatorView.color = .purple
            view.addSubview(activityIndicatorView)
            // アニメーション開始
            activityIndicatorView.startAnimating()

            DispatchQueue.global(qos: .default).async {
                // 非同期処理などを実行（今回は５秒間待つだけ）
                Thread.sleep(forTimeInterval: 5)

                // 非同期処理などが終了したらメインスレッドでアニメーション終了
                DispatchQueue.main.async {
                    // アニメーション終了
                    self.activityIndicatorView.stopAnimating()
                }
            }
        
       }
       //検索ボタンをクリック
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // キーボードを閉じる。
            self.view.endEditing(true)
            //検索する
            searchItems(searchText: searchBar.text! as String)
        
            //読み込み中(ぐるぐる)
            // インジゲーターの設定
            activityIndicatorView.center = view.center
            activityIndicatorView.style = .whiteLarge
            activityIndicatorView.color = .purple
            view.addSubview(activityIndicatorView)
            // アニメーション開始
            activityIndicatorView.startAnimating()

            DispatchQueue.global(qos: .default).async {
                // 非同期処理などを実行（今回は５秒間待つだけ）
                Thread.sleep(forTimeInterval: 5)

                // 非同期処理などが終了したらメインスレッドでアニメーション終了
                DispatchQueue.main.async {
                    // アニメーション終了
                    self.activityIndicatorView.stopAnimating()
                }
            }
       }

//MARK: - テーブルビュー
    //セルがタップされた時に呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択を解除
        tableView.deselectRow(at: indexPath,animated: true)
        //データを取り出す
        let data = newsSearchResult[indexPath.row]
        print(data)
        guard data.url != nil else{return}
            print("リンクはnilではありません")
        //記事のURLを取得する
        if let url = URL(string: data.url!){
        
            //SFSafariViewControllerのインスタンスを生成
            let controller: SFSafariViewController = SFSafariViewController(url: url)

            //次の画面へ遷移して、表示する
            self.present(controller,animated: true,completion: nil)
        }
    }
    //セルのセクション数を決める
    func numberOfSections(in tableView: UITableView) -> Int {
        //セクションは１つ
        return 1
    }
    //セルの数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //取得したセルの数だけセルを表示
        return newsSearchResult.count
    }
    //セルを構築する際に呼ばれる
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //作成した「NewsCell」のインスタンスを生成
        let cell: NewsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)as! NewsTableViewCell
        
        //取得したデータを取り出す
        let data = newsSearchResult[indexPath.row]
        
        //日付
        cell.dateLabel.text = data.publishedAt
        //タイトル
        cell.titleLabel.text = data.title
        //本文
        if let desc = data.description {
          cell.descriptionLabel.text = desc
        }
        //著者
        cell.authorLabel.text = data.author
        //画像
        if let url = data.urlToImage {
            
            //UIImageのExtensionを利用。
            cell.urlToImageView.image =  UIImage.init(url: url)
        }
     
        //セルのインスタンスを返す
        return cell
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 450
    }

    

}

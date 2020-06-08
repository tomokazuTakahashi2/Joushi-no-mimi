//
//  NewsModel.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/03/24.
//  Copyright © 2020 takahashi. All rights reserved.
//

import Foundation
import UIKit

struct Test: Codable {
    var articles: [NewsModel]? = nil
    var status : String? = nil
    var totalResults: Int? = nil
}
struct NewsModel: Codable  {
    
    //日付
    var publishedAt: String? = nil
    var dateString: String{
     //NSDateFormatterのインスタンスを生成
     let formatter: DateFormatter = DateFormatter()

         //受け取るフォーマットを設定
         formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

         //正常にDate型に変換できるか確認
        if let date = formatter.date(from: publishedAt!){
             //表示するフォーマットを指定
             formatter.dateFormat = "yyyy/MM/dd HH:mm"
             //String型に変換を行い、返す
             let str = formatter.string(from: date)
             return str
         }
    //万が一失敗した場合は、そのままdateを返す
        return publishedAt!
    }
    //著者名
    var author: String? = nil
    //記事名
    var title: String? = nil
    
    //イメージ
    var urlToImage: String? = nil
    
    
    //記事本文
    var description: String? = nil
    //出典
//    var name: String? = ""
    //URL
    var url: String? = nil
    
}

extension UIImage {
   public convenience init(url: String) {
       let url = URL(string: url)
           do {
               let data = try Data(contentsOf: url!)
            if data != nil {
                self.init(data: data)!
               return
            }
           } catch let err {
               print("Error : \(err.localizedDescription)")
           }
           self.init()
   }
}

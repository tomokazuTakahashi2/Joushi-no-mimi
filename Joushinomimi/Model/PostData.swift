//
//  PostData.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/02/15.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var autoIdKey: String?
    var uid: String?
    var name: String?
    var profileImageString: String?
    var profileImage: UIImage?
    var caption: String?
    var postComment: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false

    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        self.autoIdKey = valueDictionary["autoIdKey"]as? String
        
        self.uid = valueDictionary["uid"]as? String
        
        self.name = valueDictionary["name"] as? String

        profileImageString = valueDictionary["profileImage"] as? String
        profileImage = UIImage(data: Data(base64Encoded: profileImageString!, options: .ignoreUnknownCharacters)!)


        self.caption = valueDictionary["caption"] as? String
        self.postComment = valueDictionary["postComment"] as? String

        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)

        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }

        for likeId in self.likes {
            if likeId == myId {
                self.isLiked = true
                break
            }
        }
    }
}

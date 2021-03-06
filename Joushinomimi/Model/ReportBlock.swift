//
//  ReportBlock.swift
//  Joushinomimi
//
//  Created by Raphael on 2020/05/30.
//  Copyright © 2020 takahashi. All rights reserved.
//
import UIKit
import Firebase

class ReportBlock: NSObject {
    var id: String?
    var reportId: String?
    var reportUser: String?
    var blockId: String?
    var blockUserId: String?


    init(snapshot: DataSnapshot, myId: String) {
        
        self.id = snapshot.key

        let valueDictionary = snapshot.value as! [String: Any]
        
        self.reportId = valueDictionary["reportId"] as? String
        
        self.reportUser = valueDictionary["reportUser"] as? String
        
        self.blockId = valueDictionary["blockId"] as? String
        
        self.blockUserId = valueDictionary["blockUserId"] as? String
       
    }
}

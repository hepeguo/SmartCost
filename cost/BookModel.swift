//
//  BookModel.swift
//  cost
//
//  Created by 郭振永 on 15/5/10.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import Foundation
import CoreData

@objc(BookModel)
class BookModel: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var time: String
    @NSManaged var items: NSSet

}

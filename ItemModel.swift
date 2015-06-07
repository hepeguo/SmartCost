//
//  ItemModel.swift
//  cost
//
//  Created by 郭振永 on 15/6/7.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import Foundation
import CoreData

@objc(ItemModel)
class ItemModel: NSManagedObject {

    @NSManaged var addTime: String
    @NSManaged var day: String
    @NSManaged var dayOfWeek: String
    @NSManaged var detail: String
    @NSManaged var id: String
    @NSManaged var kill: NSNumber
    @NSManaged var kind: String
    @NSManaged var month: String
    @NSManaged var price: NSNumber
    @NSManaged var weekOfYear: String
    @NSManaged var year: String
    @NSManaged var isSpend: NSNumber
    @NSManaged var book: BookModel

}

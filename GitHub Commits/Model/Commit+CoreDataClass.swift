//
//  Commit+CoreDataClass.swift
//  GitHub Commits
//
//  Created by Evgeniy Ryshkov on 14/01/2019.
//  Copyright © 2019 Evgeniy Ryshkov. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}

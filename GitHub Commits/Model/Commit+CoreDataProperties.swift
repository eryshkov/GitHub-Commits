//
//  Commit+CoreDataProperties.swift
//  GitHub Commits
//
//  Created by Evgeniy Ryshkov on 15/01/2019.
//  Copyright © 2019 Evgeniy Ryshkov. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var author: Author

}

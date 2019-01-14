//
//  ViewController.swift
//  GitHub Commits
//
//  Created by Evgeniy Ryshkov on 14/01/2019.
//  Copyright © 2019 Evgeniy Ryshkov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    //MARK: -
    var container: NSPersistentContainer!
    
    //MARK: -
    func coreDataSetup() {
        container = NSPersistentContainer(name: "Project38")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do{
                try container.viewContext.save()
            }catch{
                print("An error occured while saving: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataSetup()
    }


}


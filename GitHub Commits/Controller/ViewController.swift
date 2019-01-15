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
    var commits = [Commit]()
    var commitPredicate: NSPredicate?
    var fetchResultsController: NSFetchedResultsController<Commit>!
    
    //MARK: -
    func coreDataSetup() {
        container = NSPersistentContainer(name: "Project38")
        
        container.loadPersistentStores { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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
    
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    @objc func fetchCommits() {
        let newestCommitDate = getNewestCommitDate()
        
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            let jsonCommits = JSON(parseJSON: data)
            
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async {[unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                
                self.saveContext()
                self.loadSavedData()
            }
        }
    }
    
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["commiter"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        
        //see if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                //we have this author already
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            //we didn't find a saved author - create a new one!
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            
            commitAuthor = author
        }
        
        //use the author, either saved or new
        commit.author = commitAuthor
    }
    
    func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = commitPredicate
        
        do{
            commits = try container.viewContext.fetch(request)
            print("Got \(commits.count) commits into tableView")
            tableView.reloadData()
        }catch{
            print("Fetch failed with: \(error.localizedDescription)")
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default, handler: {[unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default, handler: {[unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default, handler: {[unowned self] (_) in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default, handler: {[unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default, handler: {[unowned self] (_) in
            self.commitPredicate = nil
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
        
        coreDataSetup()
        
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        
        loadSavedData()
    }

    //MARK: -
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = commits[indexPath.row]
        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.detailItem = commits[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = commits[indexPath.row]
            container.viewContext.delete(commit)
            commits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveContext()
        }
    }

}


//
//  DetailViewController.swift
//  GitHub Commits
//
//  Created by Evgeniy Ryshkov on 14/01/2019.
//  Copyright © 2019 Evgeniy Ryshkov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //MARK: -
    @IBOutlet weak var detailLabel: UILabel!
    
    //MARK: -
    var detailItem: Commit?
    
    //MARK: -
    @objc func showAuthorCommits() {
        
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        if let detail = self.detailItem {
            detailLabel.text = detail.message
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .plain, target: self, action: #selector(showAuthorCommits))
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

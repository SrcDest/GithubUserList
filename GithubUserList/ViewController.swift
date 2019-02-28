//
//  ViewController.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    // MARK:- Properties
    
    let searchTextfield: ImageTextField = {
        let textField = ImageTextField()
        textField.leftImage = #imageLiteral(resourceName: "baseline_search_black_24pt")
        textField.leftPadding = 5
        textField.backgroundColor = UIColor(hex: "#EEEEEE")
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    lazy var userTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(UserListTableCell.self, forCellReuseIdentifier: userCell)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    let userCell = "userCell"
    
    // MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addControls()
        
    }
    
    // MARK: Custom functions

    func addControls() {
        self.view.addSubview(searchTextfield)
        searchTextfield.snp.makeConstraints { (m) in
            m.top.equalTo(self.view).offset(40)
            m.left.equalTo(self.view).offset(10)
            m.right.equalTo(self.view).offset(-10)
            m.height.equalTo(30)
        }
        self.view.addSubview(userTableView)
        userTableView.snp.makeConstraints { (m) in
            m.top.equalTo(searchTextfield.snp.bottom).offset(10)
            m.left.right.bottom.equalTo(self.view)
        }
    }
}

// MARK:- Table view delegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

// MARK:- Table view datasource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! UserListTableCell
        cell.userNameLabel.text = "user name"
        cell.scoreLabel.text = "99.9999999"
        
        return cell
    }
}


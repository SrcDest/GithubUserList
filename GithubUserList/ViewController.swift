//
//  ViewController.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class ViewController: UIViewController {

    // MARK:- Properties
    
    let userCell = "userCell"
    var githubUserList: [[String : Any]] = []
    
    // MARK: Controls
    
    let nothingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "No search results found."
        return label
    }()
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    lazy var searchTextfield: ImageTextField = {
        let textField = ImageTextField()
        textField.leftImage = #imageLiteral(resourceName: "baseline_search_black_24pt")
        textField.leftPadding = 5
        textField.backgroundColor = UIColor(hex: "#EEEEEE")
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.placeholder = "Input Github user nickname !"
        
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
    
    // MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addControls()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
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
        self.view.addSubview(nothingLabel)
        nothingLabel.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(self.view)
        }
        userTableView.addSubview(indicator)
        indicator.style = .white
        indicator.color = UIColor.red
        indicator.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(self.view)
        }
    }
    
    func getGithubUserList(_ searchKeyword: String) {
        nothingLabel.isHidden = true
        githubUserList.removeAll()
        indicator.startAnimating()
        let urlString = "https://api.github.com/search/users?q=" + searchKeyword
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                var json: [String : Any]?
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let json = json, let userList = json["items"] as? [[String : Any]] {
                        DispatchQueue.main.async {
                            if self.indicator.isAnimating {
                                self.indicator.stopAnimating()
                            }
                            if userList.count == 0 {
                                self.githubUserList.removeAll()
                                self.userTableView.reloadData()
                                self.userTableView.isHidden = true
                                self.nothingLabel.isHidden = false
                            } else {
                                self.githubUserList = userList
                                self.userTableView.reloadData()
                                self.userTableView.isHidden = false
                                self.nothingLabel.isHidden = true
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        if self.indicator.isAnimating {
                            self.indicator.stopAnimating()
                        }
                        self.githubUserList.removeAll()
                        self.userTableView.reloadData()
                        self.userTableView.isHidden = true
                        self.nothingLabel.isHidden = false
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK:- Text field delegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchKeyword = textField.text else { return false }
        
        getGithubUserList(searchKeyword)
        return true
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
        return githubUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! UserListTableCell
        cell.selectionStyle = .none
        if let githubUserModel = GithubUserModel(JSON: githubUserList[indexPath.row]) {
            cell.userNameLabel.text = githubUserModel.login
            if let scoreString = githubUserModel.score?.description {
                cell.scoreLabel.text = "score: " + scoreString
            } else {
                cell.scoreLabel.text = "score: -"
            }
            if let urlString = githubUserModel.avatar_url, let url = URL(string: urlString) {
                cell.userProfileImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
            }
        }
        
        return cell
    }
}


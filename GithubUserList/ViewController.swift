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
    
    fileprivate let userCell = "userCell"
    fileprivate let loadingCell = "loadingCell"
    fileprivate let debouncer = Debouncer(timeInterval: 0.5)
    
    var selectedIndex: Int?
    var movieModelList: [MovieModel] = []
    var fetchingMore: Bool = false
    var nextUrl: String?
    var pageNum: Int = 1
    var searchKeyword: String = ""
    
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
        textField.placeholder = "Input movie title !"
        
        return textField
    }()
    lazy var movieTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(MovieListTableCell.self, forCellReuseIdentifier: userCell)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCell)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK:- Functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addControls()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        debouncer.handler = {
            print("Send movie api request")
        }
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
        self.view.addSubview(movieTableView)
        movieTableView.snp.makeConstraints { (m) in
            m.top.equalTo(searchTextfield.snp.bottom).offset(10)
            m.left.right.bottom.equalTo(self.view)
        }
        self.view.addSubview(nothingLabel)
        nothingLabel.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(self.view)
        }
        movieTableView.addSubview(indicator)
        indicator.style = .white
        indicator.color = UIColor.red
        indicator.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(self.view)
        }
    }
    
    func getMovieList(_ urlString: String) {
        nothingLabel.isHidden = true
        if !fetchingMore {
            indicator.startAnimating()
        }
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                
                var json: [String : Any]?
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let json = json, let jsonData = json["data"] as? [String : Any], let movieList = MovieListModel(JSON: jsonData) {
                        if let movieCount = movieList.movie_count, movieCount > self.movieModelList.count {
                            self.pageNum += 1
                            self.nextUrl = "https://yts.am/api/v2/list_movies.json?limit=10&page=" + String(self.pageNum) + "&query_term=" + self.searchKeyword
                        }
                        DispatchQueue.main.async {
                            if self.indicator.isAnimating {
                                self.indicator.stopAnimating()
                            }
                            if movieList.movies.count == 0 {
                                self.movieModelList.removeAll()
                                self.movieTableView.reloadData()
                                self.movieTableView.isHidden = true
                                self.nothingLabel.isHidden = false
                            } else {
                                self.movieModelList.append(contentsOf: movieList.movies)
                                if self.fetchingMore {
                                    self.fetchingMore = false
                                    self.movieTableView.reloadData()
                                } else {
                                    self.movieTableView.reloadData()
                                    self.movieTableView.isHidden = false
                                    self.nothingLabel.isHidden = true
                                }
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        if self.indicator.isAnimating {
                            self.indicator.stopAnimating()
                        }
                        self.movieModelList.removeAll()
                        self.movieTableView.reloadData()
                        self.movieTableView.isHidden = true
                        self.nothingLabel.isHidden = false
                    }
                }
            }
            
            task.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MovieDetailViewController {
            if let view = segue.destination as? MovieDetailViewController, let index = self.selectedIndex {
                view.movieModel = movieModelList[index]
            }
        }
    }
    
    @objc func didTapMovieDetail(_ sender: UITapGestureRecognizer) {
        debouncer.renewInterval()
        
        if let view = sender.view {
            selectedIndex = view.tag
            self.performSegue(withIdentifier: "movieDetailSegue", sender: self)
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            movieTableView.snp.remakeConstraints { (m) in
                m.top.equalTo(searchTextfield.snp.bottom).offset(10)
                m.left.right.equalTo(self.view)
                m.bottom.equalTo(self.view).offset(-keyboardSize.height)
            }
            
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        movieTableView.snp.remakeConstraints { (m) in
            m.top.equalTo(searchTextfield.snp.bottom).offset(10)
            m.left.right.bottom.equalTo(self.view)
        }
        
        view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK:- Text field delegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchKeyword = textField.text else { return false }
        self.searchKeyword = searchKeyword
        debouncer.renewInterval()
        
        movieModelList.removeAll()
        movieTableView.setContentOffset(.zero, animated: false)
        pageNum = 1
        let urlString = "https://yts.am/api/v2/list_movies.json?limit=10&page=" + String(pageNum) + "&query_term=" + searchKeyword
        getMovieList(urlString)
        return true
    }
}

// MARK:- Table view delegate

extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        if let url = nextUrl {
            fetchingMore = true
            movieTableView.reloadSections(IndexSet(integer: 1), with: .none)
            getMovieList(url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK:- Table view datasource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return movieModelList.count
        } else if section == 1, fetchingMore {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! MovieListTableCell
            cell.selectionStyle = .none
            let movieModel = movieModelList[indexPath.row]
            cell.movieTitleLabel.text = movieModel.title
            let movieTitleLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapMovieDetail(_:)))
            let movieImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapMovieDetail(_:)))
            cell.movieTitleLabel.tag = indexPath.row
            cell.movieTitleLabel.isUserInteractionEnabled = true
            cell.movieTitleLabel.addGestureRecognizer(movieTitleLabelTap)
            if let rating = movieModel.rating {
                cell.ratingLabel.text = "rating: " + String(rating)
            } else {
                cell.ratingLabel.text = "rating: -"
            }
            if let urlString = movieModel.small_cover_image, let url = URL(string: urlString) {
                cell.movieImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
            }
            cell.movieImageView.tag = indexPath.row
            cell.movieImageView.isUserInteractionEnabled = true
            cell.movieImageView.addGestureRecognizer(movieImageViewTap)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.indicator.startAnimating()
            
            return cell
        }
    }
}


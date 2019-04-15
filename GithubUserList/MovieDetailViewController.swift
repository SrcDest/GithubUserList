//
//  MovieDetailViewController.swift
//  GithubUserList
//
//  Created by shhan2 on 15/04/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit
import FSPagerView
import Kingfisher

class MovieDetailViewController: UIViewController, UICollectionViewDataSource, FSPagerViewDelegate, FSPagerViewDataSource {
    
    public var movieModel: MovieModel?
    
    fileprivate let castCell = "CastCell"
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieYearLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieRuntimeLabel: UILabel!
    @IBOutlet weak var movieLanguageLabel: UILabel!
    @IBOutlet weak var movieGenresLabel: UILabel!
    @IBOutlet weak var movieSummaryLabel: UILabel!
    @IBOutlet weak var movieCastCollectionView: UICollectionView!
    @IBOutlet weak var pagerView: FSPagerView!
    
    var bannerIndicator: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.numberOfPages = 7
        pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        pageControl.contentHorizontalAlignment = .center
        pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        pageControl.hidesForSinglePage = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.style = .white
        indicator.color = UIColor.red
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        let backImage = #imageLiteral(resourceName: "baseline_keyboard_arrow_left_black_48pt")
        let backButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: backImage.size.width + 30, height: backImage.size.height))
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: backImage.size.width + 30, height: backImage.size.height)
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.contentHorizontalAlignment = .left
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 40)
        backButtonContainer.addSubview(backButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonContainer)
        
        pagerView.automaticSlidingInterval = 3.0
        bannerIndicator.itemSpacing = 10
        bannerIndicator.setFillColor(UIColor.red.withAlphaComponent(0.4), for: .normal)
        bannerIndicator.setFillColor(UIColor.clear, for: .selected)
        bannerIndicator.setStrokeColor(UIColor.red, for: .selected)
        bannerIndicator.backgroundColor = UIColor.clear
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.delegate = self
        pagerView.dataSource = self
        
        self.view.addSubview(bannerIndicator)
        bannerIndicator.snp.makeConstraints { (m) in
            m.left.equalTo(pagerView).offset(5)
            m.right.equalTo(pagerView).offset(-5)
            m.bottom.equalTo(pagerView).offset(-5)
            m.height.equalTo(25)
        }
        
        getMovieDetail()
    }
    
    func setupView() {
        guard let movieModel = self.movieModel else { return }
        
        self.navigationItem.title = movieModel.title
        
        if let urlString = movieModel.medium_cover_image, let url = URL(string: urlString) {
            movieImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
        }
        
        movieYearLabel.text = movieModel.year == nil ? "unknown" : String(movieModel.year!)
        movieRatingLabel.text = movieModel.rating == nil ? "unknown" : String(movieModel.rating!)
        movieRuntimeLabel.text = movieModel.runtime == nil ? "unknown" : String(movieModel.runtime!)
        movieLanguageLabel.text = String(movieModel.language ?? "unknown")
        for (index, genres) in movieModel.genres.enumerated() {
            movieGenresLabel.text = movieGenresLabel.text! + genres
            if index != movieModel.genres.count - 1 {
                movieGenresLabel.text = movieGenresLabel.text! + ", "
            }
        }
        
        movieSummaryLabel.text = String(movieModel.description_full ?? "unknown")
        
        movieCastCollectionView.dataSource = self
        movieCastCollectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: castCell)
        if let flowLayout = movieCastCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 5
            flowLayout.itemSize = CGSize(width: 70, height: 120)
        }
        movieCastCollectionView.reloadData()
        pagerView.reloadData()
        if indicator.isAnimating {
            indicator.stopAnimating()
        }
    }
    
    func getMovieDetail() {
        guard let movieModel = self.movieModel, let id = movieModel.id else { return }
        let urlString = "https://yts.am/api/v2/movie_details.json?movie_id=" + String(id) + "&with_images=true&with_cast=true"
        indicator.startAnimating()
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                
                var json: [String : Any]?
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let json = json, let jsonData = json["data"] as? [String : Any], let movieJsonData = jsonData["movie"] as? [String : Any],
                        let movieModel = MovieModel(JSON: movieJsonData) {
                        DispatchQueue.main.async {
                            self.movieModel = movieModel
                            self.setupView()
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.movieModel = nil
                        self.setupView()
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movieModel = self.movieModel {
            return movieModel.cast.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: castCell, for: indexPath) as! CastCollectionViewCell
        if let movieModel = movieModel {
            let castModel = movieModel.cast[indexPath.item]
            if let urlString = castModel.url_small_image, let url = URL(string: urlString) {
                cell.charImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
            }
            
            cell.nameLabel.text = castModel.name
            cell.charNameLabel.text = castModel.character_name
        }
        
        return cell
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        bannerIndicator.numberOfPages = 4
        return 4
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFit
        if let movieModel = self.movieModel {
            switch index {
            case 0:
                if let urlString = movieModel.medium_cover_image, let url = URL(string: urlString) {
                    cell.imageView?.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
                }
                break
            case 1:
                if let urlString = movieModel.medium_screenshot_image1, let url = URL(string: urlString) {
                    cell.imageView?.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
                }
                break
            case 2:
                if let urlString = movieModel.medium_screenshot_image2, let url = URL(string: urlString) {
                    cell.imageView?.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
                }
                break
            case 3:
                if let urlString = movieModel.medium_screenshot_image3, let url = URL(string: urlString) {
                    cell.imageView?.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
                }
                break
            default:
                break
            }
        }
        
        return cell
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.bannerIndicator.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.bannerIndicator.currentPage = pagerView.currentIndex
    }
}

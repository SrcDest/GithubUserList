//
//  UserListTableCell.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import Kingfisher

class MovieListTableCell: TableBaseCell {
    
    // MARK: Controls
    
    let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textColor = UIColor.gray
        return label
    }()
    
    // MARK:- Functions
    
    override func prepareForReuse() {
        movieImageView.image = nil
        movieTitleLabel.text = nil
        ratingLabel.text = nil
    }
    
    override func setupCell() {
        self.addSubview(movieImageView)
        self.addSubview(movieTitleLabel)
        self.addSubview(ratingLabel)
        
        movieImageView.snp.makeConstraints { (m) in
            m.width.equalTo(45)
            m.height.equalTo(67)
            m.left.top.equalTo(self).offset(12.5)
        }
        movieTitleLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(movieImageView.snp.centerY).offset(-1.5)
            m.left.equalTo(movieImageView.snp.right).offset(5)
            m.right.equalTo(self).offset(-12.5)
        }
        ratingLabel.snp.makeConstraints { (m) in
            m.top.equalTo(movieImageView.snp.centerY).offset(1.5)
            m.left.right.equalTo(movieTitleLabel)
        }
    }
}

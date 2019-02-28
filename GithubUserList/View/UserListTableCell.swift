//
//  UserListTableCell.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class UserListTableCell: TableBaseCell {
    let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textColor = UIColor.gray
        return label
    }()
    
    override func prepareForReuse() {
        userProfileImageView.image = nil
        userNameLabel.text = nil
        scoreLabel.text = nil
    }
    
    override func setupCell() {
        self.addSubview(userProfileImageView)
        self.addSubview(userNameLabel)
        self.addSubview(scoreLabel)
        userProfileImageView.snp.makeConstraints { (m) in
            m.height.width.equalTo(50)
            m.left.equalTo(self).offset(12.5)
            m.centerY.equalTo(self)
        }
        userNameLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(self.snp.centerY).offset(-1.5)
            m.left.equalTo(userProfileImageView.snp.right).offset(5)
            m.right.equalTo(self).offset(-12.5)
        }
        scoreLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self.snp.centerY).offset(1.5)
            m.left.right.equalTo(userNameLabel)
        }
    }
}

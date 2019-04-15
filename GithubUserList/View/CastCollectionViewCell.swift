//
//  CastCollectionViewCell.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    let charImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let charNameLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override func prepareForReuse() {
        charImageView.image = nil
        nameLabel.text = nil
        charNameLabel.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCell()
    }
    
    func setupCell() {
        self.addSubview(charImageView)
        self.addSubview(nameLabel)
        self.addSubview(charNameLabel)
        
        charImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(50)
            m.centerX.equalTo(self)
            m.top.equalTo(self)
        }
        nameLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(charImageView.snp.bottom).offset(8)
            m.left.equalTo(self).offset(5)
            m.right.equalTo(self).offset(-5)
        }
        charNameLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(nameLabel.snp.bottom).offset(5)
            m.left.right.equalTo(nameLabel)
        }
    }
}

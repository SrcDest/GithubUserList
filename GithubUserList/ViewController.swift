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

    let searchTextfield: ImageTextField = {
        let textField = ImageTextField()
        textField.leftImage = #imageLiteral(resourceName: "baseline_search_black_24pt")
        textField.leftPadding = 5
        textField.backgroundColor = UIColor(hex: "#EEEEEE")
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addControls()
        
    }

    func addControls() {
        self.view.addSubview(searchTextfield)
        searchTextfield.snp.makeConstraints { (m) in
            m.top.equalTo(self.view).offset(40)
            m.left.equalTo(self.view).offset(10)
            m.right.equalTo(self.view).offset(-10)
            m.height.equalTo(30)
        }
    }
}


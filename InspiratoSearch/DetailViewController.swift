//
//  DetailViewController.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/10/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import AlamofireImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var photoDetail: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        let url = URL(string: photoDetail.imageURL)!
        detailImageView.af_setImage(withURL: url)
        
        titleLabel.text = photoDetail.name
        
        if let user = photoDetail.user {
            authorLabel.text = "Author: \(user.fullName)"
        }
        descLabel.text = photoDetail.description ?? "No Description"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


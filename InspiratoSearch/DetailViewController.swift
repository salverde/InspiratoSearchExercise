//
//  DetailViewController.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/10/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import UIKit
import SnapKit
import AlamofireImage

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    var photoDetail: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        let url = URL(string: photoDetail.imageURL)!
        detailImageView.af_setImage(withURL: url)
        
        titleLabel.text = photoDetail.name
        descLabel.text = photoDetail.description
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
}


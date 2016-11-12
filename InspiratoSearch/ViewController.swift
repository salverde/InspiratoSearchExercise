//
//  ViewController.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/10/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import UIKit
import Alamofire
import UnboxedAlamofire

class ViewController: UIViewController {

    var photos: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchPhotos() {
        PhotoAPI.sharedInstance.searchPhotos(keyword: "computer", page: "1") {
            self.photos = $0
        }
    }
}


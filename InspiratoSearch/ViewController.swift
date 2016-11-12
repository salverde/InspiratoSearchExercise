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
import AlamofireImage

class ViewController: UIViewController {
    
    fileprivate let reuseIdentifier = "PhotoCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 40.0, left: 10.0, bottom: 40.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var searchController: UISearchController!
    
    var photos: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        self.searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        fetchPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchPhotos() {
        PhotoAPI.sharedInstance.searchPhotos(keyword: "computer", page: "1") {
            self.photos = $0
            self.photosCollectionView.reloadData()
        }
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = PhotoCell()
        if let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell {
            // Configure the cell
            photoCell.backgroundColor = UIColor.inspiratoGray()
            if let title = photos?[indexPath.row].name {
                photoCell.photoName.text = title
            }
            if let imageURL = photos?[indexPath.row].imageURL {
                let url = URL(string: imageURL)!
                // TODO
                // add placeholder image with imageView extension
                photoCell.imageView.af_setImage(withURL: url)
            }
            cell = photoCell
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ViewController: UICollectionViewDelegate {
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}


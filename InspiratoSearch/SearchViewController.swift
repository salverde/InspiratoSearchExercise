//
//  SearchViewController.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/12/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import UnboxedAlamofire
import AlamofireImage

class SearchViewController: UICollectionViewController {
    
    let reuseIdentifier:String = "PhotoCell"
    
    var dataSource: [String]?
    var dataSourceForSearchResult: [String]?
    
    var searchBarActive: Bool = false
    
    var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .minimal
        bar.tintColor = UIColor.white
        bar.barTintColor = UIColor.white
        bar.placeholder = "Search Photos"
        return bar
    }()
    
    var refreshControl: UIRefreshControl = {
        let loader = UIRefreshControl()
        loader.tintColor = UIColor.white
        return loader
    }()
    
    var photos: [Photo]?
    
    override func viewDidLoad() {
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        self.dataSource = ["Modesto","Rebecka","Andria","Sergio","Robby","Jacob","Lavera", "Theola", "Adella","Garry", "Lawanda", "Christiana", "Billy", "Claretta", "Gina", "Edna", "Antoinette", "Shantae", "Jeniffer", "Fred", "Phylis", "Raymon", "Brenna", "Gulfs", "Ethan", "Kimbery", "Sunday", "Darrin", "Ruby", "Babette", "Latrisha", "Dewey", "Della", "Dylan", "Francina", "Boyd", "Willette", "Mitsuko", "Evan", "Dagmar", "Cecille", "Doug", "Jackeline", "Yolanda", "Patsy", "Haley", "Isaura", "Tommye", "Katherine", "Vivian"]
        
        self.dataSourceForSearchResult = [String]()
        searchBar.delegate = self
        
        addSearchBar()
        addRefreshControl()
    }

    deinit{
        self.removeObservers()
    }
    
    // MARK: actions
    func refreshControlAction() {
        
        self.cancelSearching()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // stop refreshing after 2 seconds
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }   
    }
    
    private func fetchPhotos(with term: String) {
        PhotoAPI.sharedInstance.searchPhotos(keyword: term, page: "1") {
            self.photos = $0
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: <UICollectionViewDataSource>
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.searchBarActive {
            return self.dataSourceForSearchResult!.count
        }
        return self.dataSource!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = PhotoCell()
        if let photoCell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell {
            
            if (self.searchBarActive) {
                photoCell.photoName.text = self.dataSourceForSearchResult![indexPath.row]
            } else {
                
//                if let title = photos?[indexPath.row].name {
//                    photoCell.photoName.text = title
//                }
//                if let imageURL = photos?[indexPath.row].imageURL {
//                    let url = URL(string: imageURL)!
//                    // TODO
//                    // add placeholder image with imageView extension
//                    photoCell.photoImageView.af_setImage(withURL: url)
//                }
                let url = URL(string: "https://drscdn.500px.org/photo/157877509/q%3D50_w%3D140_h%3D140/f8d675f6b731ff40f33097dae8a71f61?v=3")!
                photoCell.photoImageView.af_setImage(withURL: url)
                photoCell.photoName.text = self.dataSource![indexPath.row]
            }
            cell = photoCell
        }
        return cell
    }
    
    // MARK: <UICollectionViewDelegateFlowLayout>
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(searchBar.frame.size.height, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellLeg = (collectionView.frame.size.width/2) - 5
        
        return CGSize(width: cellLeg, height: cellLeg)
    }
    
    func addSearchBar(){
        
        addObservers()
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.top.equalTo(super.topLayoutGuide.snp.bottom)
            $0.width.equalTo(view)
            $0.height.equalTo(44.0)
        }
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
    }
    
    func startRefreshControl() {
        if refreshControl.isRefreshing == false {
            refreshControl.beginRefreshing()
        }
    }
    
    func addObservers() {
        
        let context = UnsafeMutablePointer<UInt8>(bitPattern: 1)
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: context)
    }
    
    func removeObservers(){
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath! == "contentOffset" {
            if let collectionView: UICollectionView = object as? UICollectionView {
//                if let searchBar = self.searchBar {
//                    searchBar.frame = CGRect(
//                        x: searchBar.frame.origin.x,
//                        y: self.searchBarBoundsY! + ( (-1 * collectionView.contentOffset.y) - self.searchBarBoundsY!),
//                        width: searchBar.frame.size.width,
//                        height: searchBar.frame.size.height
//                    )
//                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func filterContentForSearchText(searchText:String){
        self.dataSourceForSearchResult = self.dataSource?.filter({ (text:String) -> Bool in
            return text.contains(searchText)
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0 {
            // search and reload data source
            self.searchBarActive    = true
            self.filterContentForSearchText(searchText: searchText)
            self.collectionView?.reloadData()
        }else{
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self .cancelSearching()
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        self.searchBarActive = false
        searchBar.setShowsCancelButton(false, animated: false)
    }
    func cancelSearching(){
        self.searchBarActive = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}

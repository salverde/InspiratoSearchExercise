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
    
    var searchBarActive: Bool = false
    
    var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .prominent
        bar.tintColor = UIColor.white
        bar.barTintColor = UIColor.black
        bar.isTranslucent = false
        bar.placeholder = "Search Photos"
        return bar
    }()
    
    var refreshControl: UIRefreshControl = {
        let loader = UIRefreshControl()
        loader.tintColor = UIColor.white
        return loader
    }()
    
    var photos: [Photo]?
    var searchResult: [Any]?
    
    override func viewDidLoad() {
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        self.searchResult = [Any]()
        
        searchBar.delegate = self
        
        addSearchBar()
        addObservers()
        addRefreshControl()
    }

    deinit{
        self.removeObservers()
    }
    
    func addSearchBar() {
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
    
    func refreshControlAction() {
        self.cancelSearching()
        let duration = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: duration) {
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func fetchPhotos(with term: String) {
        startRefreshControl()
        PhotoAPI.sharedInstance.searchPhotos(keyword: term, page: "1") {
            self.photos = $0
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        if self.searchBarActive {
//            return self.dataSourceForSearchResult!.count
//        }
//        return self.dataSource!.count
//        if searchBarActive {
//            return searchResult?.count ?? 0
//        }
        return photos?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = PhotoCell()
        if let photoCell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell {
            
            if let title = photos?[indexPath.row].name {
                photoCell.photoName.text = title
            }
            if let imageURL = photos?[indexPath.row].imageURL {
                let url = URL(string: imageURL)!
                // TODO
                // add placeholder image with imageView extension
                photoCell.photoImageView.af_setImage(withURL: url)
            }
            
//            if (self.searchBarActive) {
//                photoCell.photoName.text = self.dataSourceForSearchResult![indexPath.row]
//            } else {
//                
//                let url = URL(string: "https://drscdn.500px.org/photo/157877509/q%3D50_w%3D140_h%3D140/f8d675f6b731ff40f33097dae8a71f61?v=3")!
//                photoCell.photoImageView.af_setImage(withURL: url)
//                photoCell.photoName.text = self.dataSource![indexPath.row]
//            }
            cell = photoCell
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(searchBar.frame.size.height, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let cellGridSize: CGFloat = (screenWidth / 2.0) - 5
        
        return CGSize(width: cellGridSize, height: cellGridSize)
    }
    
    // MARK: KVO
    
    func addObservers() {
        let context = UnsafeMutablePointer<UInt8>(bitPattern: 1)
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: context)
    }
    
    func removeObservers() {
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let keypath = keyPath, keypath == "contentOffset" {
            if let collectionView: UICollectionView = object as? UICollectionView {
                let searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                searchBar.frame = CGRect(
                    x: searchBar.frame.origin.x,
                    y: searchBarBoundsY + ( (-1 * collectionView.contentOffset.y) - searchBarBoundsY),
                    width: searchBar.frame.size.width,
                    height: searchBar.frame.size.height
                )
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPhotoSegue" {
            guard let indexPath = collectionView?.indexPath(for: sender as! PhotoCell) else { return }
            
            if let detailController = segue.destination as? DetailViewController {
                detailController.photoDetail = photos?[indexPath.row]
            }
        }
    }
    
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        // Calculate where the collection view should be at the right-hand end item
//        let fullyScrolledContentOffset: CGFloat = (collectionView?.frame.size.height)! * CGFloat(dataSource!.count - 1)
////        let fullyScrolledContentOffset:CGFloat = infiniteScrollingCollectionView.frame.size.width * CGFloat(photosUrlArray.count - 1)
//        if (scrollView.contentOffset.y >= fullyScrolledContentOffset) {
//            
//            // user is scrolling to the right from the last item to the 'fake' item 1.
//            // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
//            if photosUrlArray.count>2{
//                reversePhotoArray(photosUrlArray, startIndex: 0, endIndex: photosUrlArray.count - 1)
//                reversePhotoArray(photosUrlArray, startIndex: 0, endIndex: 1)
//                reversePhotoArray(photosUrlArray, startIndex: 2, endIndex: photosUrlArray.count - 1)
//                var indexPath : NSIndexPath = NSIndexPath(forRow: 1, inSection: 0)
//                infiniteScrollingCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
//            }
//        }
//        else if (scrollView.contentOffset.x == 0){
//            
//            if photosUrlArray.count>2{
//                reversePhotoArray(photosUrlArray, startIndex: 0, endIndex: photosUrlArray.count - 1)
//                reversePhotoArray(photosUrlArray, startIndex: 0, endIndex: photosUrlArray.count - 3)
//                reversePhotoArray(photosUrlArray, startIndex: photosUrlArray.count - 2, endIndex: photosUrlArray.count - 1)
//                var indexPath : NSIndexPath = NSIndexPath(forRow: photosUrlArray.count - 2, inSection: 0)
//                infiniteScrollingCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
//            }
//        }
//    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func filterContentForSearchText(searchText:String) {
//        self.dataSourceForSearchResult = self.dataSource?.filter({ (text:String) -> Bool in
//            return text.contains(searchText)
//        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            // search and reload data source
            self.searchBarActive = true
            let duration = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: duration) {
                self.fetchPhotos(with: searchText)
            }
            
//            self.filterContentForSearchText(searchText: searchText)
//            self.collectionView?.reloadData()
        } else {
            
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
    func cancelSearching() {
        self.searchBarActive = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        photos?.removeAll()
    }
}

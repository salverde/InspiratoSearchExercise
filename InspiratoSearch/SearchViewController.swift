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

protocol PaginationDelegate {
    
    func fetchMoreItems(with activityIndicator: UIActivityIndicatorView)
}

class SearchViewController: UICollectionViewController {
    
    private let reuseIdentifier: String = "PhotoCell"
    private let detailSegue: String = "detailPhotoSegue"
    
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
    
    var searchResult: SearchResult?
    var photos: [Photo]?
    
    var paginationDelegate: PaginationDelegate?
    
    var paginationIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        indicator.bounds.size.height = 65
        return indicator
    }()
    
    override func viewDidLoad() {
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        searchBar.delegate = self
        paginationDelegate = self
        
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
    
    func fetchPhotos(with term: String, on page: String) {
        startRefreshControl()
        PhotoAPI.shared.search(keyword: term, page: page) {
            if let photos = $0.photos {
                self.photos = photos
            }
            self.searchResult = $0
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        if segue.identifier == detailSegue {
            guard let indexPath = collectionView?.indexPath(for: sender as! PhotoCell) else { return }
            if let detailController = segue.destination as? DetailViewController {
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                detailController.photoDetail = photos?[indexPath.row]
            }
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            // Find pagination indicator & delegate
            var paginationIndicator: UIActivityIndicatorView?
            var paginationDelegate: PaginationDelegate?
            
            paginationDelegate = self.paginationDelegate
            paginationIndicator = self.paginationIndicator
            
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height
            if y >= scrollView.contentSize.height && paginationIndicator != nil {
                paginationDelegate?.fetchMoreItems(with: paginationIndicator!)

            } else {
                paginationIndicator?.stopAnimating()
            }
        }
    }
}
// MARK: PaginationDelegate

extension SearchViewController: PaginationDelegate {
    
    func fetchMoreItems(with activityIndicator: UIActivityIndicatorView) {

        if let result = searchResult {
            let nextPage = result.currentPage + 1
            
            if nextPage <= result.totalPages {
                paginationIndicator.startAnimating()
                if let currentKeyword = searchBar.text {
                    fetchPhotos(with: currentKeyword, on: String(nextPage))
                }
            }
        }
        
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            // search and reload data source
            self.searchBarActive = true
            let duration = DispatchTime.now() + 1.2
            DispatchQueue.main.asyncAfter(deadline: duration) {
                self.fetchPhotos(with: searchText, on: "1")
            }
        
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
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
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

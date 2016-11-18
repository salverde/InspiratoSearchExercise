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
    
    private let reuseIdentifierCell: String = "PhotoCell"
    private let reuseIdentifierFooter: String = "FooterView"
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
    
    var photos: [Photo] = []
    
    var searchResult: SearchResult? {
        didSet {
            if let photos = searchResult?.photos {
                self.photos.append(contentsOf: photos)
            }
            self.emptyStateView.isHidden = (searchResult?.totalItems)! > 0 ? true : false
        }
    }
    
    var paginationDelegate: PaginationDelegate?
    
    var paginationIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.bounds.size.height = 65
        return indicator
    }()
    
    var emptyStateView: UIImageView = {
        let emptyState = UIImageView(image: UIImage(named: "search-results-empty-state"))
        emptyState.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 236.0, height: 247.0))
        }
        emptyState.isHidden = false
        return emptyState
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar-logo"))
        
        searchBar.delegate = self
        paginationDelegate = self
        
        self.collectionView?.register(CollectionReusableView.self,
                                      forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                      withReuseIdentifier: reuseIdentifierFooter)
        
        addSearchBar()
        addRefreshControl()
        addEmptyState()
    }
    
    func addEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
        }
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
        let duration = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: duration) {
            if let currentKeyword = self.searchBar.text {
                self.fetchPhotos(with: currentKeyword, on: "1")
            }
        }
    }
    
    func fetchPhotos(with term: String, on page: String) {
        startRefreshControl()
        PhotoAPI.shared.search(keyword: term, page: page) {
            self.searchResult = $0
            
            // TODO
            // on pagination (only) insertInto collectionView rather then reload!
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = PhotoCell()
        if let photoCell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCell, for: indexPath) as? PhotoCell {
            photoCell.photoName.text = photos[indexPath.row].name

            let url = URL(string: photos[indexPath.row].imageURL)!
            // TODO
            // add placeholder image with imageView extension
            photoCell.photoImageView.af_setImage(withURL: url)
            
            cell = photoCell
        }
        return cell
    }
    
     override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierFooter, for: indexPath)
        
        if kind == UICollectionElementKindSectionFooter {
            reusableView.backgroundColor = UIColor.clear
            
            if self.paginationDelegate != nil {
                reusableView.addSubview(self.paginationIndicator)
                self.paginationIndicator.snp.makeConstraints {
                    $0.width.equalTo(reusableView)
                }
            }
        }
        return reusableView
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if self.paginationDelegate != nil {
            return CGSize(width: collectionView.bounds.size.width, height: self.paginationIndicator.bounds.size.height)
        }
        return CGSize.zero
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegue {
            guard let indexPath = collectionView?.indexPath(for: sender as! PhotoCell) else { return }
            if let detailController = segue.destination as? DetailViewController {
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                detailController.photoDetail = photos[indexPath.row]
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let collectionView: UICollectionView = scrollView as? UICollectionView {
            let searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
            searchBar.frame = CGRect(
                x: searchBar.frame.origin.x,
                y: searchBarBoundsY + ((-1 * collectionView.contentOffset.y) - searchBarBoundsY),
                width: searchBar.frame.size.width,
                height: searchBar.frame.size.height
            )
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
            self.searchBarActive = true
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
        
        if let keyword = searchBar.text {
            self.fetchPhotos(with: keyword, on: "1")
        }
        
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
        searchBarActive = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        photos.removeAll()
        emptyStateView.isHidden = photos.count > 0 ? true : false
    }
}

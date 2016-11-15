//
//  SearchResult.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/15/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import Unbox

struct SearchResult {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let photos: [Photo]?
}

extension SearchResult  : Unboxable {
    init(unboxer: Unboxer) throws {
        self.currentPage = try unboxer.unbox(key: "current_page")
        self.totalPages = try unboxer.unbox(key: "total_pages")
        self.totalItems = try unboxer.unbox(key: "total_items")
        self.photos = unboxer.unbox(key: "photos")

    }
}

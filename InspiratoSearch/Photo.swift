//
//  Photo.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/11/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import Unbox

struct Photo {
    let name: String
    let description: String
    let width: Int
    let height: Int
    let nsfw: Bool
    let imageURL: String
    let imageFormat: String
    let user: User?
    let createdAt: Date?
    
}

extension Photo: Unboxable {
    init(unboxer: Unboxer) throws {
        
        self.name = try unboxer.unbox(keyPath: "photos.name")
        self.description = try unboxer.unbox(keyPath: "photos.description")
        self.width = try unboxer.unbox(keyPath: "photos.width")
        self.height = try unboxer.unbox(keyPath: "photos.height")
        self.nsfw = try unboxer.unbox(keyPath: "photos.nsfw")
        self.imageURL = try unboxer.unbox(keyPath: "photos.image_url")
        self.imageFormat = try unboxer.unbox(keyPath: "photos.image_format")
        self.user = unboxer.unbox(keyPath: "photos.user")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.createdAt = unboxer.unbox(keyPath: "photos.created_at", formatter: dateFormatter)
    }
}

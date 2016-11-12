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
    let description: String?
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
        
        self.name = try unboxer.unbox(key: "name")
        self.description = unboxer.unbox(key: "description")
        self.width = try unboxer.unbox(key: "width")
        self.height = try unboxer.unbox(key: "height")
        self.nsfw = try unboxer.unbox(key: "nsfw")
        self.imageURL = try unboxer.unbox(key: "image_url")
        self.imageFormat = try unboxer.unbox(key: "image_format")
        self.user = unboxer.unbox(keyPath: "user")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.createdAt = unboxer.unbox(keyPath: "created_at", formatter: dateFormatter)
    }
}

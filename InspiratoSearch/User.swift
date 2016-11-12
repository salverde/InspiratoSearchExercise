//
//  User.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/11/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import Unbox

struct User {
    let username: String
    let fullName: String
    let city: String
    let userImageURL: String
    
}

extension User: Unboxable {
    init(unboxer: Unboxer) throws {
        self.username = try unboxer.unbox(key: "username")
        self.fullName = try unboxer.unbox(key: "fullname")
        self.city = try unboxer.unbox(key: "city")
        self.userImageURL = try unboxer.unbox(key: "userpic_url")

    }
}

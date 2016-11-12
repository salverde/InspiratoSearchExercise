//
//  AppAppearance.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/11/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import UIKit

struct AppAppearance {
    
    static func navigationBar() {
        let navigationAppearance = UINavigationBar.appearance()
        navigationAppearance.barTintColor = UIColor.inspiratoGray()
        navigationAppearance.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Helvetica-Light", size: 20.0)!
        ]

    }
}

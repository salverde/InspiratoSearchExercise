//
//  CollectionReusableView.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/15/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        frame = layoutAttributes.frame
    }
}

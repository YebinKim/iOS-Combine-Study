//
//  Extension.swift
//  KapiTranslation
//
//  Created by Yebin Kim on 2020/02/27.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

extension UIView {
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
}

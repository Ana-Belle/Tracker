//
//  UIView+Extensions.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 29.04.2026.
//

import UIKit

extension UIView {
    var forAutoLayout: Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

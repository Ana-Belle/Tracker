//
//  SystemImage.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 26.05.2026.
//

import UIKit

enum SystemImage: String {
    case checkmark
    case plus

    var image: UIImage? {
        UIImage(systemName: rawValue)
    }
}

//
//  CoreDataValueCodec.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import UIKit

enum CoreDataValueCodec {
    
    static func encodeColor(_ color: UIColor) -> NSArray {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha] as NSArray
    }
    
    static func decodeColor(_ value: Any?) -> UIColor? {
        guard let components = value as? [CGFloat], components.count == 4 else { return nil }
        return UIColor(
            red: components[0],
            green: components[1],
            blue: components[2],
            alpha: components[3]
        )
    }
    
    static func encodeSchedule(_ schedule: [WeekDay]) -> NSArray {
        schedule.map(\.rawValue) as NSArray
    }
    
    static func decodeSchedule(_ value: Any?) -> [WeekDay] {
        guard let rawValues = value as? [String] else { return [] }
        return rawValues.compactMap(WeekDay.init(rawValue:))
    }
}

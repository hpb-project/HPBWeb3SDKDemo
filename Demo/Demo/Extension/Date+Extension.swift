//
//  Date+Extension.swift
//  Demo
//
//  Created by liuxiaoliang on 2019/4/11.
//  Copyright © HPB Foundation. All rights reserved.
//

import Foundation

private var dateFormatterCache = [String: DateFormatter]()

public extension DateFormatter{
    
    static func cache(formate key: String) -> DateFormatter {
        var formatter = dateFormatterCache[key]
        if formatter == nil {
            let tempFormatter = DateFormatter()
            tempFormatter.dateFormat = key
            dateFormatterCache[key] = tempFormatter
            formatter = tempFormatter
        }
        return formatter!
    }
}


extension Date{
    
    /// Create a date string with the given date format, the default formate is "yyyy-MM-dd"
    public func toString(by formate: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter.cache(formate: formate)
        return dateFormatter.string(from: self)
    }
}

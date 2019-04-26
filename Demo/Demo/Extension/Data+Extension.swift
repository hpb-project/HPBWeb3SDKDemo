//
//  Data+Extension.swift
//  Demo
//
//  Created by liuxiaoliang on 2019/4/11.
//  Copyright © 2019 HPB Foundation. All rights reserved.
//

import Foundation


extension Data{
    public var hexString: String {
        var string = ""
        for byte in self {
            string.append(String(format: "%02x", byte))
        }
        return string
    }
}

//
//  Item.swift
//  restaurant tinder
//
//  Created by Jonathan Nguyen on 4/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

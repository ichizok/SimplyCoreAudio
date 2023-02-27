//
//  Array+Extensions.swift
//

import Foundation

extension Array where Element: Hashable {
    func unique() -> [Element] {
        return NSOrderedSet(array: self).array as! [Element]
    }
}

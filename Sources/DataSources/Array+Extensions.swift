//
//  Array+Extensions.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import Differentiator

extension Array where Element: SectionModelType {
    mutating func moveFromSourceIndexPath(_ sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let sourceSection = self[sourceIndexPath.section]
        var sourceItems = sourceSection.items

        let sourceItem = sourceItems.remove(at: sourceIndexPath.item)

        let sourceSectionNew = Element(original: sourceSection, items: sourceItems)
        self[sourceIndexPath.section] = sourceSectionNew

        let destinationSection = self[destinationIndexPath.section]
        var destinationItems = destinationSection.items
        destinationItems.insert(sourceItem, at: destinationIndexPath.item)

        self[destinationIndexPath.section] = Element(original: destinationSection, items: destinationItems)
    }
}

//
//  ASNode+SectionedViewType.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

import Foundation
import RxDataSources

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

func _performBatchUpdates<V: SectionedViewType, S: SectionModelType>(_ view: V, changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
    typealias I = S.Item

    view.deleteSections(changes.deletedSections, animationStyle: .none)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    view.insertSections(changes.insertedSections, animationStyle: .none)
    for (from, to) in changes.movedSections {
        view.moveSection(from, to: to)
    }

    view.deleteItemsAtIndexPaths(
        changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: .none
    )
    view.insertItemsAtIndexPaths(
        changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: .none
    )
    view.reloadItemsAtIndexPaths(
        changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: .fade
    )

    for (from, to) in changes.movedItems {
        view.moveItemAtIndexPath(
            IndexPath(item: from.itemIndex, section: from.sectionIndex),
            to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
        )
    }
}

//
//  ASNode+SectionedViewType.swift
//  actisso
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Innovatube. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxDataSources

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension ASTableNode: SectionedViewType {

    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteRows(at: paths, with: animationStyle)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadRows(at: paths, with: animationStyle)
    }

    public func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections), with: animationStyle)
    }

    public func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections), with: animationStyle)
    }

    public func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections), with: animationStyle)
    }

    public func performBatchUpdates<S: SectionModelType>(_ changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
        self.performBatch(animated: false, updates: { 
            _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: nil)
    }
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

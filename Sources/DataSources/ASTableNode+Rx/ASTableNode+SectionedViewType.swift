//
//  ASTableNode+SectionedViewType.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Differentiator

extension ASTableNode: SectionedNodeType {

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

    public func performBatchUpdates<S>(_ changes: Changeset<S>, animated: Bool, animationConfiguration: RowAnimation) {
        self.performBatch(animated: animated, updates: {
            _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: nil)
    }
}

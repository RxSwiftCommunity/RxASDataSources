//
//  ASCollectionNode+SectionViewType.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Differentiator

extension ASCollectionNode: SectionedNodeType {

    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertItems(at: paths)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteItems(at: paths)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveItem(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadItems(at: paths)
    }

    public func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections))
    }

    public func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections))
    }

    public func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections))
    }

    public func performBatchUpdates<S>(_ changes: Changeset<S>, animated: Bool, animationConfiguration: RowAnimation) {
        self.performBatch(animated: animated, updates: {
            _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: nil)
    }
}

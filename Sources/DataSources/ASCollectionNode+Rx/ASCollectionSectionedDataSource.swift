//
//  ASCollectionSectionedDataSource.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxCocoa
    import Differentiator
#endif

open class _ASCollectionSectionedDataSource: NSObject, ASCollectionDataSource {

    @nonobjc open func _rx_numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 0
    }

    open func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _rx_numberOfSections(in: collectionNode)
    }

    @nonobjc open func _rx_collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return _rx_collectionNode(collectionNode, numberOfItemsInSection: section)
    }

    open func _rx_collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return (nil as ASCellNode?)!
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return _rx_collectionNode(collectionNode, nodeForItemAt: indexPath)
    }

    @nonobjc open func _rx_collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> ASCellNode {
        return (nil as ASCellNode?)!
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        return _rx_collectionNode(collectionNode, nodeForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }

    open func _rx_collectionNode(_ collectionNode: ASCollectionNode, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, canMoveItemAt indexPath: IndexPath) -> Bool {
        return _rx_collectionNode(collectionNode, canMoveItemAt: indexPath)
    }

    open func _rx_collectionNode(_ collectionNode: ASCollectionNode, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    }
    public func collectionNode(_ collectionNode: ASCollectionNode, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _rx_collectionNode(collectionNode, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
}

open class ASCollectionSectionedDataSource<S: SectionModelType>: _ASCollectionSectionedDataSource, SectionedViewDataSourceType {
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (ASCollectionSectionedDataSource<S>, ASCollectionNode, IndexPath, I) -> ASCellNode
    public typealias SupplementaryViewFactory = (ASCollectionSectionedDataSource<S>, ASCollectionNode, String, IndexPath) -> ASCellNode

    #if DEBUG
    // If data source has already been bound, then mutating it
    // afterwards isn't something desired.
    // This simulates immutability after binding
    var _dataSourceBound: Bool = false

    private func ensureNotMutatedAfterBinding() {
        assert(!_dataSourceBound, "Data source is already bound. Please write this line before binding call (`bindTo`, `drive`). Data source must first be completely configured, and then bound after that, otherwise there could be runtime bugs, glitches, or partial malfunctions.")
    }

    #endif

    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>

    private var _sectionModels: [SectionModelSnapshot] = []

    open var sectionModels: [S] {
        return _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }

    open subscript(section: Int) -> S {
        let sectionModel = self._sectionModels[section]
        return S(original: sectionModel.model, items: sectionModel.items)
    }

    open subscript(indexPath: IndexPath) -> I {
        get {
            return self._sectionModels[indexPath.section].items[indexPath.item]
        }
        set(item) {
            var section = self._sectionModels[indexPath.section]
            section.items[indexPath.item] = item
            self._sectionModels[indexPath.section] = section
        }
    }

    open func model(at indexPath: IndexPath) throws -> Any {
        return self[indexPath]
    }

    open func setSections(_ sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }

    open var configureCell: CellFactory! = nil {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var supplementaryViewFactory: SupplementaryViewFactory {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var moveItem: ((ASCollectionSectionedDataSource<S>, _ sourceIndexPath:IndexPath, _ destinationIndexPath:IndexPath) -> Void)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var canMoveItemAtIndexPath: ((ASCollectionSectionedDataSource<S>, IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    public override init() {
        self.configureCell = {_, _, _, _ in return (nil as ASCellNode?)! }
        self.supplementaryViewFactory = {_, _, _, _ in (nil as ASCellNode?)! }

        super.init()

        self.configureCell = { [weak self] _ in
            precondition(false, "There is a minor problem. `cellFactory` property on \(self!) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")

            return (nil as ASCellNode!)!
        }

        self.supplementaryViewFactory = { [weak self] _ in
            precondition(false, "There is a minor problem. `supplementaryViewFactory` property on \(self!) was not set.")
            return (nil as ASCellNode?)!
        }
    }

    // ASCollectionNodeDataSource

    open override func _rx_numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _sectionModels.count
    }

    open override func _rx_collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }

    open override func _rx_collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCell(self, collectionNode, indexPath, self[indexPath])
    }

    open override func _rx_collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> ASCellNode {
        return supplementaryViewFactory(self, collectionNode, kind, indexPath)
    }

    open override func _rx_collectionNode(_ collectionNode: ASCollectionNode, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let canMoveItem = canMoveItemAtIndexPath?(self, indexPath) else {
            return super._rx_collectionNode(collectionNode, canMoveItemAt: indexPath)
        }

        return canMoveItem
    }

    open override func _rx_collectionNode(_ collectionNode: ASCollectionNode, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
        self.moveItem?(self, sourceIndexPath, destinationIndexPath)
    }
}

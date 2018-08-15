//
//  ASCollectionSectionedDataSource.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxCocoa
    import Differentiator
#endif

open class ASCollectionSectionedDataSource<S: SectionModelType>: NSObject, ASCollectionDataSource, ASCommonCollectionDataSource, SectionedViewDataSourceType {
    public typealias I = S.Item
    public typealias Section = S
    
    public typealias ConfigureCell = (ASCollectionSectionedDataSource<S>, ASCollectionNode, IndexPath, I) -> ASCellNode
    public typealias ConfigureCellBlock = (ASCollectionSectionedDataSource<S>, ASCollectionNode, IndexPath, I) -> ASCellNodeBlock
    public typealias ConfigureSupplementaryView = (ASCollectionSectionedDataSource<S>, ASCollectionNode, String, IndexPath) -> ASCellNode
    public typealias ConfigureSupplementaryViewBlock = (ASCollectionSectionedDataSource<S>, ASCollectionNode, String, IndexPath) -> ASCellNodeBlock
    public typealias MoveItem = (ASCollectionSectionedDataSource<S>, _ sourceIndexPath: IndexPath, _ destinationIndexPath:IndexPath) -> Void
    public typealias CanMoveItemAtIndexPath = (ASCollectionSectionedDataSource<S>, IndexPath) -> Bool

    fileprivate static func configureCellNotSet(dataSource: ASCollectionSectionedDataSource<S>, node: ASCollectionNode, indexPath: IndexPath, model: I) -> ASCellNode {
        return ASCollectionDataSourceNotSet().collectionNode(node, nodeForItemAt: indexPath)
    }

    fileprivate static func configureCellBlockNotSet(dataSource: ASCollectionSectionedDataSource<S>, node: ASCollectionNode, indexPath: IndexPath, model: I) -> ASCellNodeBlock {
        return { dataSource.collectionNode(node, nodeForItemAt: indexPath) }
    }

    fileprivate static func configureSupplementaryViewBlockNotSet(dataSource: ASCollectionSectionedDataSource<S>, node: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, indexPath: IndexPath) -> ASCellNodeBlock {
        return { dataSource.collectionNode(node, nodeForSupplementaryElementOfKind: kind, at: indexPath) }
    }

    public init(
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
        ) {
        self.configureCell = configureCell
        self.configureCellBlock = ASCollectionSectionedDataSource.configureCellBlockNotSet
        self.configureSupplementaryView = configureSupplementaryView
        self.configureSupplementaryViewBlock = ASCollectionSectionedDataSource.configureSupplementaryViewBlockNotSet
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

    public init(
        configureCellBlock: @escaping ConfigureCellBlock,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
        ) {
        self.configureCell = ASCollectionSectionedDataSource.configureCellNotSet
        self.configureCellBlock = configureCellBlock
        self.configureSupplementaryView = configureSupplementaryView
        self.configureSupplementaryViewBlock = ASCollectionSectionedDataSource.configureSupplementaryViewBlockNotSet
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

    public init(
        configureCell: @escaping ConfigureCell,
        configureSupplementaryViewBlock: ConfigureSupplementaryViewBlock? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
        ) {
        self.configureCell = configureCell
        self.configureCellBlock = ASCollectionSectionedDataSource.configureCellBlockNotSet
        self.configureSupplementaryView = nil
        self.configureSupplementaryViewBlock = configureSupplementaryViewBlock
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

    public init(
        configureCellBlock: @escaping ConfigureCellBlock,
        configureSupplementaryViewBlock: ConfigureSupplementaryViewBlock? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
        ) {
        self.configureCell = ASCollectionSectionedDataSource.configureCellNotSet
        self.configureCellBlock = configureCellBlock
        self.configureSupplementaryView = nil
        self.configureSupplementaryViewBlock = configureSupplementaryViewBlock
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

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

    open var configureCell: ConfigureCell {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var configureCellBlock: ConfigureCellBlock {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var configureSupplementaryView: ConfigureSupplementaryView? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()

                if self.configureSupplementaryViewBlock != nil {
                    print("[WARNING][RxASDataSources] `configureSupplementaryView` is always over written by `configureSupplementaryViewBlock`.")
                }
            #endif
        }
    }

    open var configureSupplementaryViewBlock: ConfigureSupplementaryViewBlock? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()

                if self.configureSupplementaryView != nil {
                    print("[WARNING][RxASDataSources] `configureSupplementaryViewBlock` always over write `configureSupplementaryView`.")
                }
            #endif
        }
    }

    open var moveItem: MoveItem {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var canMoveItemAtIndexPath: CanMoveItemAtIndexPath {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    //MARK:- ASCollectionNodeDataSource

    open func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _sectionModels.count
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCell(self, collectionNode, indexPath, self[indexPath])
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCellBlock(self, collectionNode, indexPath, self[indexPath])
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        guard let cell = configureSupplementaryView?(self, collectionNode, kind, indexPath) else {
            fatalError("configureSupplementaryView was not set")
        }
        return cell
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        guard let cell = configureSupplementaryViewBlock?(self, collectionNode, kind, indexPath) else {
            fatalError("configureSUpplementaryViewBlock was not set")
        }

        return cell
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, canMoveItemAt indexPath: IndexPath) -> Bool {
        return canMoveItemAtIndexPath(self, indexPath)
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
        self.moveItem(self, sourceIndexPath, destinationIndexPath)
    }
}

//
//  ASTableSectionedDataSource.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxCocoa
    import Differentiator
#endif

open class ASTableSectionedDataSource<S: SectionModelType>: NSObject, ASTableDataSource, ASCommonTableDataSource, SectionedViewDataSourceType {
    
    public typealias I = S.Item
    public typealias Section = S
    
    public typealias ConfigureCell = (ASTableSectionedDataSource<S>, ASTableNode, IndexPath, I) -> ASCellNode
    public typealias ConfigureCellBlock = (ASTableSectionedDataSource<S>, ASTableNode, IndexPath, I) -> ASCellNodeBlock
    public typealias TitleForHeaderInSection = (ASTableSectionedDataSource<S>, Int) -> String?
    public typealias TitleForFooterInSection = (ASTableSectionedDataSource<S>, Int) -> String?
    public typealias CanEditRowAtIndexPath = (ASTableSectionedDataSource<S>, IndexPath) -> Bool
    public typealias CanMoveRowAtIndexPath = (ASTableSectionedDataSource<S>, IndexPath) -> Bool

    #if os(iOS)
    public typealias SectionIndexTitles = (ASTableSectionedDataSource<S>) -> [String]?
    public typealias SectionForSectionIndexTitle = (ASTableSectionedDataSource<S>, _ title: String, _ index: Int) -> Int
    #endif
    
    fileprivate static func configureCellNotSet(dataSource: ASTableSectionedDataSource<S>, node: ASTableNode, indexPath: IndexPath, model: I) -> ASCellNode {
        return ASTableDataSourceNotSet().tableNode(node, nodeForRowAt: indexPath)
    }

    fileprivate static func configureCellBlockNotSet(dataSource: ASTableSectionedDataSource<S>, node: ASTableNode, indexPath: IndexPath, model: I) -> ASCellNodeBlock {
        return { dataSource.tableNode(node, nodeForRowAt: indexPath) }
    }

    #if os(iOS)
    public init(
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
        ) {
        self.configureCell = configureCell
        self.configureCellBlock = ASTableSectionedDataSource.configureCellBlockNotSet
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
        self.sectionIndexTitles = sectionIndexTitles
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
    }

    public init(
        configureCellBlock: @escaping ConfigureCellBlock,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
        ) {
        self.configureCell = ASTableSectionedDataSource.configureCellNotSet
        self.configureCellBlock = configureCellBlock
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
        self.sectionIndexTitles = sectionIndexTitles
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
    }
    #else
    public init(
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
        ) {
        self.configureCell = configureCell
        self.configureCellBlock = ASTableSectionedDataSource.configureCellBlockNotSet
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
    }

    public init(
        configureCellBlock: @escaping ConfigureCellBlock,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
        ) {
        self.configureCell = ASTableSectionedDataSource.configureCell
        self.configureCellBlock = configureCellBlock
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
    }
    #endif
    
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

    open var titleForHeaderInSection: TitleForHeaderInSection {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var titleForFooterInSection: TitleForFooterInSection {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var canEditRowAtIndexPath: CanEditRowAtIndexPath {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var canMoveRowAtIndexPath: CanMoveRowAtIndexPath {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    #if os(iOS)
    open var sectionIndexTitles: SectionIndexTitles {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var sectionForSectionIndexTitle: SectionForSectionIndexTitle {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    #endif

    // MARK:- ASTableDataSource

    open func numberOfSections(in tableNode: ASTableNode) -> Int {
        return _sectionModels.count
    }
    
    open func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        guard _sectionModels.count > section else { return 0 }
        return _sectionModels[section].items.count
    }
    
    open func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCell(self, tableNode, indexPath, self[indexPath])
    }

    open func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCellBlock(self, tableNode, indexPath, self[indexPath])
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection(self, section)
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection(self, section)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditRowAtIndexPath(self, indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return canMoveRowAtIndexPath(self, indexPath)
    }

    #if os(iOS)
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles(self)
    }
    
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionForSectionIndexTitle(self, title, index)
    }
    #endif
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }

}

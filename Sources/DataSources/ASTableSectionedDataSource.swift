//
//  ASTableSectionedDataSource.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

import Foundation
import AsyncDisplayKit

#if !RX_NO_MODULE
    import RxCocoa
    import RxDataSources
#endif
open class _ASTableSectionedDataSource: NSObject, ASTableDataSource {

    @nonobjc open func _rx_numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    open func numberOfSections(in tableNode: ASTableNode) -> Int {
        return _rx_numberOfSections(in: tableNode)
    }

    open func _rx_tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    open func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return _rx_tableNode(tableNode, numberOfRowsInSection: section)
    }

    open func _rx_tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return (nil as ASCellNode?)!
    }

    open func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return _rx_tableNode(tableNode, nodeForRowAt: indexPath)
    }
}

open class ASTableSectionedDataSource<S: SectionModelType>: _ASTableSectionedDataSource, SectionedViewDataSourceType {

    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (ASTableSectionedDataSource<S>, ASTableNode, IndexPath, I) -> ASCellNode

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

    open var rowAnimation: UITableViewRowAnimation = .automatic

    public override init() {
        super.init()
        self.configureCell = { [weak self] _ in
            if let strongSelf = self {
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            }

            return (nil as ASCellNode!)!
        }
    }

    // ASTableDataSource

    open override func _rx_numberOfSections(in tableNode: ASTableNode) -> Int {
        return _sectionModels.count
    }

    open override func _rx_tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        guard _sectionModels.count > section else { return 0 }
        return _sectionModels[section].items.count
    }

    open override func _rx_tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCell(self, tableNode, indexPath, self[indexPath])
    }

}

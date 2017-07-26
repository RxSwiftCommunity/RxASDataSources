//
//  RxASTableReactiveArrayDataSource.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

#if os(iOS)
import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

// objc monkey business
class _RxASTableReactiveArrayDataSource: NSObject, ASTableDataSource {

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    fileprivate func _tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return _tableNode(tableNode, numberOfRowsInSection: section)
    }

    fileprivate func _tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        rxAbstractMethod()
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return _tableNode(tableNode, nodeForRowAt: indexPath)
    }
}

class RxASTableReactiveArrayDataSourceSequenceWrapper<S: Sequence>: RxASTableReactiveArrayDataSource<S.Iterator.Element> , RxASTableDataSourceType {
    typealias Element = S

    override init(cellFactory: @escaping CellFactory) {
        super.init(cellFactory: cellFactory)
    }

    func tableNode(_ tableNode: ASTableNode, observedEvent: RxSwift.Event<S>) {
        UIBindingObserver(UIElement: self) { dataSource, sectionModels in
            let sections = Array(sectionModels)
            dataSource.tableNode(tableNode, observedElements: sections)
            }
            .on(observedEvent)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxASTableReactiveArrayDataSource<Element>: _RxASTableReactiveArrayDataSource, SectionedViewDataSourceType {
    typealias CellFactory = (ASTableNode, Int, Element) -> ASCellNode

    var itemModels: [Element]? = nil

    func modelAtIndex(_ index: Int) -> Element? {
        return itemModels?[index]
    }

    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }

    let cellFactory: CellFactory

    init(cellFactory: @escaping CellFactory) {
        self.cellFactory = cellFactory
    }

    override func _tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }

    override fileprivate func _tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return cellFactory(tableNode, indexPath.item, itemModels![indexPath.row])
    }

    // reactive

    func tableNode(_ tableNode: ASTableNode, observedElements: [Element]) {
        self.itemModels = observedElements
        tableNode.reloadData()
    }
}

#endif

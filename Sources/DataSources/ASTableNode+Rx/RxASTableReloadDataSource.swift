//
//  RxASTableReloadDataSource.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation


import UIKit
import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
    import Differentiator
#endif

open class RxASTableReloadDataSource<S: SectionModelType>: ASTableSectionedDataSource<S>, RxASTableDataSourceType {
    public typealias Element = [S]

    open func tableNode(_ tableNode: ASTableNode, observedEvent: RxSwift.Event<Element>) -> Void {
        Binder(self) { dataSource, element in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            DispatchQueue.main.async {
                dataSource.setSections(element)
                tableNode.reloadData()
            }
            }.on(observedEvent)
    }
}

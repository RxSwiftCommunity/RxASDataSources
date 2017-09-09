//
//  RxASTableReloadDataSource.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
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

    public override init() {
        super.init()
    }

    open func tableNode(_ tableNode: ASTableNode, observedEvent: RxSwift.Event<Element>) -> Void {
        UIBindingObserver(UIElement: self) { dataSource, element in
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

//
//  ASTableNode+Rx.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

public extension Reactive where Base: ASTableNode {
    func items<DataSource: RxASTableDataSourceType & ASTableDataSource, O: ObservableType>(dataSource: DataSource)
        -> (_ source: O)
        -> Disposable where DataSource.Element == O.Element {

            return { source in

                let subscription = source
                    .subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak tableNode = self.base] (_: RxASTableDataSourceProxy, event) -> Void in
                    guard let tableNode = tableNode else { return }
                    dataSource.tableNode(tableNode, observedEvent: event)
                }
                return Disposables.create {
                    subscription.dispose()
                }
            }
    }
}

extension Reactive where Base: ASTableNode {
    /**
     Reactive wrapper for `dataSource`.

     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var dataSource: DelegateProxy<ASTableNode, ASTableDataSource> {
        return RxASTableDataSourceProxy.proxy(for: base)
    }

    /**
     Installs data source as forwarding delegate on `rx.dataSource`.
     Data source won't be retained.

     It enables using normal delegate mechanism with reactive delegate mechanism.

     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func setDataSource(_ dataSource: ASTableDataSource)
        -> Disposable {
            return RxASTableDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
}

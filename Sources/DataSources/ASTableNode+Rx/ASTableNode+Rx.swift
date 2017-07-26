//
//  ASTableNode+Rx.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

public extension ASTableNode {

    /**
     Factory method that enables subclasses to implement their own `delegate`.

     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func createRxDelegateProxy() -> RxASTableDelegateProxy {
        return RxASTableDelegateProxy(parentObject: self)
    }

    /**
     Factory method that enables subclasses to implement their own `rx.dataSource`.

     - returns: Instance of delegate proxy that wraps `dataSource`.
     */
    public func createRxDataSourceProxy() -> RxASTableDataSourceProxy {
        return RxASTableDataSourceProxy(parentObject: self)
    }
}

public extension Reactive where Base: ASTableNode {
    func items<DataSource: RxASTableDataSourceType & ASTableDataSource, O: ObservableType>(dataSource: DataSource)
        -> (_ source: O)
        -> Disposable where DataSource.Element == O.E {

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


public extension Reactive where Base: ASTableNode {
    /**
     Reactive wrapper for `dataSource`.

     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var dataSource: RxASTableDataSourceProxy {
        return RxASTableDataSourceProxy.proxyForObject(base)
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
    

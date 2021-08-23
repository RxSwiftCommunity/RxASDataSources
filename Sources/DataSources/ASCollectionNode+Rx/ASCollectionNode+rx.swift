//
//  ASCollectionNode+Rx.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa

public extension Reactive where Base: ASCollectionNode {
    func items<DataSource: RxASCollectionDataSourceType & ASCollectionDataSource, O: ObservableType>(dataSource: DataSource)
        -> (_ source: O)
        -> Disposable where DataSource.Element == O.Element {

            return { source in

                let subscription = source
                    .subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak collectionNode = self.base] (_: RxASCollectionDataSourceProxy, event) -> Void in
                        guard let collectionNode = collectionNode else { return }
                        dataSource.collectionNode(collectionNode, observedEvent: event)
                }
                return Disposables.create {
                    subscription.dispose()
                }
            }
    }
}

public extension Reactive where Base: ASCollectionNode {
    /**
     Reactive wrapper for `dataSource`.

     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    var dataSource: DelegateProxy<ASCollectionNode, ASCollectionDataSource> {
        return RxASCollectionDataSourceProxy.proxy(for: base)
    }

    /**
     Installs data source as forwarding delegate on `rx.dataSource`.
     Data source won't be retained.

     It enables using normal delegate mechanism with reactive delegate mechanism.

     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    func setDataSource(_ dataSource: ASCollectionDataSource)
        -> Disposable {
            return RxASCollectionDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
}

//
//  ASDelegateProxy.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ObservableType {
    func subscribeProxyDataSource<Proxy: DelegateProxyType>(ofObject object: Proxy.ParentObject, dataSource: Proxy.Delegate, retainDataSource: Bool, binding: @escaping (Proxy, Event<E>) -> Void)
        -> Disposable
        where Proxy.ParentObject: ASDisplayNode {

            let proxy = Proxy.proxy(for: object)
            let unregisterDelegate = Proxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
            // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
            object.layoutIfNeeded()

            let subscription = self.asObservable()
                .observeOn(MainScheduler())
                .catchError { error in
                    bindingErrorToInterface(error)
                    return Observable.empty()
                }
                // source can never end, otherwise it would release the subscriber, and deallocate the data source
                .concat(Observable.never())
                .takeUntil(object.rx.deallocated)
                .subscribe { [weak object] (event: RxSwift.Event<E>) in

                    if let object = object {
                        assert(proxy === Proxy.currentDelegate(for: object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: Proxy.currentDelegate(for: object)))")
                    }

                    binding(proxy, event)

                    switch event {
                    case .error(let error):
                        bindingErrorToInterface(error)
                        unregisterDelegate.dispose()
                    case .completed:
                        unregisterDelegate.dispose()
                    default:
                        break
                    }
            }

            return Disposables.create { [weak object] in
                subscription.dispose()
                object?.layoutIfNeeded()
                unregisterDelegate.dispose()
            }
    }
}

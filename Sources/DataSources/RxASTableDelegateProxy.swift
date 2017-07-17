//
//  RxASTableNodeDelegateProxy.swift
//  actisso
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Innovatube. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

public class RxASTableDelegateProxy: DelegateProxy, DelegateProxyType, ASTableDelegate {

    /// Typed parent object.
    public weak private(set) var tableNode: ASTableNode?

    /// Initializes `RxASTableDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.tableNode = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    public static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableNode: ASTableNode = castOrFatalError(object)
        return tableNode.delegate
    }

    public static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableNode: ASTableNode = castOrFatalError(object)
        tableNode.delegate = castOptionalOrFatalError(delegate)
    }
}

extension Reactive where Base: ASTableNode {

    var delegate: DelegateProxy {
        return RxASTableDelegateProxy.proxyForObject(base)
    }

    var beginBatchFetch: ControlEvent<ASBatchContext> {

        let source = self.delegate
            .methodInvoked(#selector(ASTableDelegate.tableNode(_:willBeginBatchFetchWith:)))
            .map { data in
                return try castOrThrow(ASBatchContext.self, data[1])
        }

        return ControlEvent(events: source)
    }
}

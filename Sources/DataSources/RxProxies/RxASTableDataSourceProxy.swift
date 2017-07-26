//
//  RxASTableNodeDataSourceProxy.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

#if os(iOS)
import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

var ASDelegateAssociatedTag: UnsafeRawPointer = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
var ASDataSourceAssociatedTag: UnsafeRawPointer = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))

let dataSourceNotSet = ASTableDataSourceNotSet()

final class ASTableDataSourceNotSet: NSObject, ASTableDataSource {

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        rxAbstractMethod(message: "DataSource not set")
    }
}

/// For more information take a look at `DelegateProxyType`.
public class RxASTableDataSourceProxy: DelegateProxy, ASTableDataSource, DelegateProxyType {

    /// Typed parent object.
    public weak fileprivate(set) var tableNode: ASTableNode?

    fileprivate weak var _requiredMethodsDataSource: ASTableDataSource? = dataSourceNotSet

    /// Initializes `RxASTableDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.tableNode = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /// Required delegate method implementation.
    public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let dataSource = _requiredMethodsDataSource ?? dataSourceNotSet

        return dataSource.tableNode!(tableNode, numberOfRowsInSection: section)
    }

    /// Required delegate method implementation.
    public func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let dataSource = _requiredMethodsDataSource ?? dataSourceNotSet

        return dataSource.tableNode!(tableNode, nodeForRowAt: indexPath)
    }

    // MARK: proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableNode: ASTableNode = castOrFatalError(object)

        return tableNode.createRxDataSourceProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return ASDataSourceAssociatedTag
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableNode: ASTableNode = castOrFatalError(object)
        tableNode.dataSource = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableNode: ASTableNode = castOrFatalError(object)
        return tableNode.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: ASTableDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? dataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

}

#endif

//
//  RxASTableNodeDataSourceProxy.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

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

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        rxAbstractMethod(message: "DataSource not set")
    }
}

extension ASTableNode: HasDataSource {
    public typealias DataSource = ASTableDataSource
}

/// For more information take a look at `DelegateProxyType`.
final class RxASTableDataSourceProxy: DelegateProxy<ASTableNode, ASTableDataSource>, DelegateProxyType, ASTableDataSource {
    
    /// Typed parent object.
    public weak fileprivate(set) var tableNode: ASTableNode?
    
    /// Initializes `RxASTableDataSourceProxy`
    public init(tableNode: ASTableNode) {
        self.tableNode = tableNode
        super.init(parentObject: tableNode, delegateProxy: RxASTableDataSourceProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxASTableDataSourceProxy(tableNode: $0) }
    }
    
    public override func setForwardToDelegate(_ forwardToDelegate: ASTableDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? dataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
    
    // MARK: DataSource
    fileprivate weak var _requiredMethodsDataSource: ASTableDataSource? = dataSourceNotSet
    
    /// Required datasource method implementation.
    public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let dataSource = _requiredMethodsDataSource ?? dataSourceNotSet
        return dataSource.tableNode!(tableNode, numberOfRowsInSection: section)
    }

    /// Required datasource method implementation.
    public func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let dataSource = _requiredMethodsDataSource ?? dataSourceNotSet
        
        return dataSource.tableNode!(tableNode, nodeForRowAt: indexPath)
    }

    /// Required datasource method implementation.
    public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let datasource = _requiredMethodsDataSource ?? dataSourceNotSet

        return datasource.tableNode!(tableNode, nodeBlockForRowAt: indexPath)
    }
}

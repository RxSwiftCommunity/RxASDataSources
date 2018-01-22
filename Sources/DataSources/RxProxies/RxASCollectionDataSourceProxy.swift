//
//  RxASCollectionDataSourceProxy.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

let collectionDataSourceNotSet = ASCollectionDataSourceNotSet()

final class ASCollectionDataSourceNotSet: NSObject, ASCollectionDataSource {

    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        rxAbstractMethod(message: "DataSource not set")
    }
}

extension ASCollectionNode: HasDataSource {
    public typealias DataSource = ASCollectionDataSource
}

/// For more information take a look at `DelegateProxyType`.
final class RxASCollectionDataSourceProxy: DelegateProxy<ASCollectionNode, ASCollectionDataSource>, ASCollectionDataSource, DelegateProxyType {
    
    /// Typed parent object.
    public weak private(set) var collectionNode: ASCollectionNode?

    /// Initializes `RxASCollectionDataSourceProxy`
    public init(collectionNode: ASCollectionNode) {
        self.collectionNode = collectionNode
        super.init(parentObject: collectionNode, delegateProxy: RxASCollectionDataSourceProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxASCollectionDataSourceProxy(collectionNode: $0) }
    }

    // MARK: DataSource
    private weak var _requiredMethodsDataSource: ASCollectionDataSource? = collectionDataSourceNotSet

    /// Required data source method implementation.
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? collectionDataSourceNotSet).collectionNode!(collectionNode, numberOfItemsInSection: section)
    }

    /// Required data source method implementation.
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return (_requiredMethodsDataSource ?? collectionDataSourceNotSet).collectionNode!(collectionNode, nodeForItemAt: indexPath)
    }
    
    public override func setForwardToDelegate(_ forwardToDelegate: ASCollectionDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? collectionDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
    
}

//
//  RxASCollectionDataSourceProxy.swift
//  RxTextureDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
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


/// For more information take a look at `DelegateProxyType`.
public class  RxASCollectionDataSourceProxy: DelegateProxy, ASCollectionDataSource, DelegateProxyType {

    /// Typed parent object.
    public weak private(set) var collectionNode: ASCollectionNode?

    private weak var _requiredMethodsDataSource: ASCollectionDataSource? = collectionDataSourceNotSet

    /// Initializes `RxCollectionViewDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.collectionNode = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /// Required delegate method implementation.
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? collectionDataSourceNotSet).collectionNode!(collectionNode, numberOfItemsInSection: section)
    }

    /// Required delegate method implementation.
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return (_requiredMethodsDataSource ?? collectionDataSourceNotSet).collectionNode!(collectionNode, nodeForItemAt: indexPath)
    }

    // MARK: proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let collectionNode: ASCollectionNode = castOrFatalError(object)
        return collectionNode.createRxDataSourceProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return ASDataSourceAssociatedTag
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let collectionNode: ASCollectionNode = castOrFatalError(object)
        collectionNode.dataSource = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let collectionNode: ASCollectionNode = castOrFatalError(object)
        return collectionNode.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: ASCollectionDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? collectionDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

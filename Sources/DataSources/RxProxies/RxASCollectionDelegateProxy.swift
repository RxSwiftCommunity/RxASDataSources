//
//  RxASCollectionDelegateProxy.swift
//  RxTextureDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation

#if os(iOS)
    import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
    /// For more information take a look at `DelegateProxyType`.
public class RxASCollectionDelegateProxy: DelegateProxy, DelegateProxyType, ASCollectionDelegate, UICollectionViewDelegateFlowLayout {

    /// Typed parent object.
    public weak private(set) var collectionNode: ASCollectionNode?

    /// Initializes `RxCollectionDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.

    public required init(parentObject: AnyObject) {
        self.collectionNode = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    public static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let collectionNode: ASCollectionNode = castOrFatalError(object)
        return collectionNode.delegate
    }

    public static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let collectionNode: ASCollectionNode = castOrFatalError(object)
        collectionNode.delegate = castOptionalOrFatalError(delegate)
    }
}

#endif

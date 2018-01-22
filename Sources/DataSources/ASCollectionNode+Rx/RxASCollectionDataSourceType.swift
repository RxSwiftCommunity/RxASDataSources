//
//  RxASCollectionDataSourceType.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/// Marks data source as `ASCollectionNode` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxASCollectionDataSourceType /*: ASCollectionDataSource*/ {

    /// Type of elements that can be bound to ASCollectionNode.
    associatedtype Element

    /// New observable sequence event observed.
    ///
    /// - parameter collectionNode: Bound ASCollectionNode.
    /// - parameter observedEvent: Event
    func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: RxSwift.Event<Element>) -> Void
}

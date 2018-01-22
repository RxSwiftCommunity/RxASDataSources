//
//  RxASTableDataSourceType.swift
//
//
//  Created by Dang Thai Son on 7/16/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/// Marks data source as `ASTableNode` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxASTableDataSourceType /*: ASTableDataSource*/ {

    /// Type of elements that can be bound to ASTableNode.
    associatedtype Element

    /// New observable sequence event observed.
    ///
    /// - parameter tableNode: Bound ASTableNode.
    /// - parameter observedEvent: Event
    func tableNode(_ tableNode: ASTableNode, observedEvent: RxSwift.Event<Element>) -> Void
}

//
//  RxASTableNodeDelegateProxy.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ASTableNode: HasDelegate {
    public typealias Delegate = ASTableDelegate
}

final class RxASTableDelegateProxy: DelegateProxy<ASTableNode, ASTableDelegate>, DelegateProxyType, ASTableDelegate {
    
    /// Typed parent object.
    public weak private(set) var tableNode: ASTableNode?
    
    /// Init
    /// - parameter tableView: Parent object for delegate proxy.
    public init(tableNode: ASTableNode) {
        self.tableNode = tableNode
        super.init(parentObject: tableNode, delegateProxy: RxASTableDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxASTableDelegateProxy(tableNode: $0) }
    }
}

public extension Reactive where Base: ASTableNode {
    
    var delegate: DelegateProxy<ASTableNode, ASTableDelegate> {
        return RxASTableDelegateProxy.proxy(for: base)
    }
    
    // Event
    /**
     Reactive wrapper for `delegate` message `tableNode:didSelectRowAtIndexPath:`.
     */
    var itemSelected: ControlEvent<IndexPath> {
        let source = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:didSelectRowAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didDeselectRowAtIndexPath:`.
     */
    var itemDeselected: ControlEvent<IndexPath> {
        let source = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:didDeselectRowAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:commitEditingStyle:forRowAtIndexPath:`.
     */
    var itemInserted: ControlEvent<IndexPath> {
        let source = self.dataSource.methodInvoked(#selector(ASTableDataSource.tableView(_:commit:forRowAt:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (try castOrThrow(NSNumber.self, a[1])).intValue) == .insert
            }
            .map { a in
                return (try castOrThrow(IndexPath.self, a[2]))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:commitEditingStyle:forRowAtIndexPath:`.
     */
    var itemDeleted: ControlEvent<IndexPath> {
        let source = self.dataSource.methodInvoked(#selector(ASTableDataSource.tableView(_:commit:forRowAt:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (try castOrThrow(NSNumber.self, a[1])).intValue) == .delete
            }
            .map { a in
                return try castOrThrow(IndexPath.self, a[2])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:moveRowAtIndexPath:toIndexPath:`.
     */
    var itemMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = self.dataSource.methodInvoked(#selector(ASTableDataSource.tableView(_:moveRowAt:to:)))
            .map { a in
                return (try castOrThrow(IndexPath.self, a[1]), try castOrThrow(IndexPath.self, a[2]))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:willDisplayCell:forRowAtIndexPath:`.
     */
    var willDisplayCell: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:willDisplayRowWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didEndDisplayingCell:forRowAtIndexPath:`.
     */
    var didEndDisplayingCell: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:didEndDisplayingRowWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableNode:willBeginBatchFetchWith`
    */
    var willBeginBatchFetch: ControlEvent<ASBatchContext> {
        let source: Observable<ASBatchContext> = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:willBeginBatchFetchWith:)))
            .map { a in
                return try castOrThrow(ASBatchContext.self, a[1])
        }

        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didSelectRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableNode.rx.modelSelected(MyModel.self)
     .map { ...
     ```
     */
    func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemSelected.flatMap { [weak view = self.base as ASTableNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didDeselectRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableNode.rx.modelDeselected(MyModel.self)
     .map { ...
     ```
     */
    func modelDeselected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemDeselected.flatMap { [weak view = self.base as ASTableNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:commitEditingStyle:forRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableNode.rx.modelDeleted(MyModel.self)
     .map { ...
     ```
     */
    func modelDeleted<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemDeleted.flatMap { [weak view = self.base as ASTableNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Synchronous helper method for retrieving a model at indexPath through a reactive data source.
     */
    func model<T>(at indexPath: IndexPath) throws -> T {
        let dataSource: SectionedViewDataSourceType = castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.items*` methods was used.")
        
        let element = try dataSource.model(at: indexPath)
        
        return castOrFatalError(element)
    }
    
}

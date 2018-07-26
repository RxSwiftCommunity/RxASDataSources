//
//  RxASCollectionDelegateProxy.swift
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
    
extension ASCollectionNode: HasDelegate {
    public typealias Delegate = ASCollectionDelegate
}

/// For more information take a look at `DelegateProxyType`.
final class RxASCollectionDelegateProxy: DelegateProxy<ASCollectionNode, ASCollectionDelegate>, DelegateProxyType, ASCollectionDelegate, ASCollectionDelegateFlowLayout {
    
    /// Typed parent object.
    public weak private(set) var collectionNode: ASCollectionNode?
    
    /// Initializes `RxCollectionDelegateProxy`
    public init(collectionNode: ASCollectionNode) {
        self.collectionNode = collectionNode
        super.init(parentObject: collectionNode, delegateProxy: RxASCollectionDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxASCollectionDelegateProxy(collectionNode: $0) }
    }
    
}

public extension Reactive where Base: ASCollectionNode {
    
    var delegate: DelegateProxy<ASCollectionNode, ASCollectionDelegate> {
        return RxASCollectionDelegateProxy.proxy(for: base)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    var itemSelected: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didSelectItemAt:)))
            .map { a in
                return a[1] as! IndexPath
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    var itemDeselected: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didDeselectItemAt:)))
            .map { a in
                return a[1] as! IndexPath
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didHighlightItemAt:)`.
    var itemHighlighted: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didHighlightItemAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didUnhighlightItemAt:)`.
    var itemUnhighlighted: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didUnhighlightItemAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode:willDisplay:forItemAt:`.
    var willDisplayItem: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:willDisplayItemWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:willDisplaySupplementaryView:forElementKind:at:)`.
    var willDisplaySupplementaryElement: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:willDisplaySupplementaryElementWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode:didEndDisplaying:forItemAt:`.
    var didEndDisplayingItem: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didEndDisplayingItemWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)`.
    var didEndDisplayingSupplementaryElement: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didEndDisplayingSupplementaryElementWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionNode(_:willBeginBatchFetchWith:)`
    var willBeginBatchFetch: ControlEvent<ASBatchContext> {
        let source: Observable<ASBatchContext> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:willBeginBatchFetchWith:)))
            .map { a in
                return try castOrThrow(ASBatchContext.self, a[1])
        }

        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionNode.rx.modelSelected(MyModel.self)
    ///        .map { ...
    /// ```
    func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = itemSelected.flatMap { [weak view = self.base as ASCollectionNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionNode.rx.modelDeselected(MyModel.self)
    ///        .map { ...
    /// ```
    func modelDeselected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = itemDeselected.flatMap { [weak view = self.base as ASCollectionNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Synchronous helper method for retrieving a model at indexPath through a reactive data source
    func model<T>(at indexPath: IndexPath) throws -> T {
        let dataSource: SectionedViewDataSourceType = castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.itemsWith*` methods was used.")
        
        let element = try dataSource.model(at: indexPath)
        
        return element as! T
    }
}

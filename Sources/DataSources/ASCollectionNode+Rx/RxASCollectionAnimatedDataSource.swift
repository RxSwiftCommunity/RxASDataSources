//
//  RxASCollectionAnimatedDataSource.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import Differentiator

open class RxASCollectionAnimatedDataSource<S: AnimatableSectionModelType>: ASCollectionSectionedDataSource<S>, RxASCollectionDataSourceType {

    public typealias Element = [S]
    public typealias AnimationType = (ASCollectionSectionedDataSource<S>, ASCollectionNode, [Changeset<S>]) -> AnimationTransition
    
    /// Animation configuration for data source
    public var animationConfiguration: RowAnimation
    
    /// Calculates view transition depending on type of changes
    public var animationType: AnimationType
    
    public var animated: Bool = true
    private var dataSet = false

    public init(
        animationConfiguration: RowAnimation = RowAnimation(),
        animationType: @escaping AnimationType = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
        ) {
        
        self.animationConfiguration = animationConfiguration
        self.animationType = animationType
        super.init(
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView,
            moveItem: moveItem,
            canMoveItemAtIndexPath: canMoveItemAtIndexPath
        )
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: RxSwift.Event<Element>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                collectionNode.reloadData()
            } else {
                let oldSections = dataSource.sectionModels
                do {
                    let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    switch self.animationType(self, collectionNode, differences) {
                    case .animated:
                        for difference in differences {
                            dataSource.setSections(difference.finalSections)
                            collectionNode.performBatchUpdates(difference, animated: self.animated, animationConfiguration: self.animationConfiguration)
                        }
                    case .reload:
                        self.setSections(newSections)
                        collectionNode.reloadData()
                        return
                    }
                } catch {
                    rxDebugFatalError("\(error)")
                    self.setSections(newSections)
                    collectionNode.reloadData()
                }
            }
            }.on(observedEvent)
    }
}

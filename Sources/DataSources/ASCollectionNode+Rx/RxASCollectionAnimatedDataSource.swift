//
//  RxASCollectionAnimatedDataSource.swift
//  RxASDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import Differentiator

open class RxASCollectionAnimatedDataSource<S: AnimatableSectionModelType>: ASCollectionSectionedDataSource<S>, RxASCollectionDataSourceType {

    public typealias Element = [S]
    public var animationConfiguration = RowAnimation()
    public var animated: Bool = true

    var dataSet = false

    public override init() {
        super.init()
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: RxSwift.Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
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

                    for difference in differences {
                        dataSource.setSections(difference.finalSections)
                        collectionNode.performBatchUpdates(difference, animated: self.animated, animationConfiguration: self.animationConfiguration)
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

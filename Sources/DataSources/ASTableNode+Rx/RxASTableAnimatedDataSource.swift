//
//  RxASTableAnimatedDataSource.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright © 2017 Dang Thai Son. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxDataSources

open class RxASTableAnimatedDataSource<S: AnimatableSectionModelType>: ASTableSectionedDataSource<S>, RxASTableDataSourceType {

    public typealias Element = [S]
    public var animationConfiguration = AnimationConfiguration()

    var dataSet = false

    public override init() {
        super.init()
    }

    open func tableNode(_ tableNode: ASTableNode, observedEvent: RxSwift.Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                DispatchQueue.main.async {
                    dataSource.setSections(newSections)
                    tableNode.reloadData()
                }
            } else {
                let oldSections = dataSource.sectionModels
                do {
                    let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    DispatchQueue.main.async {
                        for difference in differences {
                            dataSource.setSections(difference.finalSections)
                            tableNode.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                        }
                        tableNode.waitUntilAllUpdatesAreCommitted()
                    }
                } catch {
                    rxDebugFatalError("\(error)")
                    DispatchQueue.main.async {
                        self.setSections(newSections)
                        tableNode.reloadData()
                    }
                }
            }
        }.on(observedEvent)
    }
}

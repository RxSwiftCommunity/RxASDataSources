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
                dataSource.setSections(newSections)
                tableNode.reloadData(completion: {
                    DispatchQueue.main.async {
                        let count = tableNode.numberOfRows(inSection: 0)
                        guard count > 0 else { return }
                        tableNode.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: false)
                    }
                })

            } else {
                DispatchQueue.main.async {
                    // if view is not in view hierarchy, performing batch updates will crash the app
                    if !tableNode.isVisible  {
                        dataSource.setSections(newSections)
                        tableNode.reloadData()
                        return
                    }
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)

                        for difference in differences {
                            dataSource.setSections(difference.finalSections)

                            tableNode.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                        }
                    } catch {
                        rxDebugFatalError("\(error)")
                        self.setSections(newSections)
                        tableNode.reloadData()
                    }
                }
            }
        }.on(observedEvent)
    }
}

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
import Differentiator

public struct RowAnimation {
    public let insertAnimation: UITableViewRowAnimation
    public let reloadAnimation: UITableViewRowAnimation
    public let deleteAnimation: UITableViewRowAnimation

    public init(insertAnimation: UITableViewRowAnimation = .automatic,
                reloadAnimation: UITableViewRowAnimation = .automatic,
                deleteAnimation: UITableViewRowAnimation = .automatic) {
        self.insertAnimation = insertAnimation
        self.reloadAnimation = reloadAnimation
        self.deleteAnimation = deleteAnimation
    }
}

open class RxASTableAnimatedDataSource<S: AnimatableSectionModelType>: ASTableSectionedDataSource<S>, RxASTableDataSourceType {

    public typealias Element = [S]
    public var animationConfiguration = RowAnimation()
    public var animated: Bool = true
    
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
                tableNode.reloadData()
            } else {
                let oldSections = dataSource.sectionModels
                do {

                    let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    for difference in differences {
                        dataSource.setSections(difference.finalSections)
                        tableNode.performBatchUpdates(difference, animated: self.animated, animationConfiguration: self.animationConfiguration)
                    }
                } catch {
                    rxDebugFatalError("\(error)")
                    self.setSections(newSections)
                    tableNode.reloadData()
                }
            }
            }.on(observedEvent)
    }
}

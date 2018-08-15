//
//  RxASTableAnimatedDataSource.swift
//
//
//  Created by Dang Thai Son on 7/15/17.
//  Copyright (c) 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import Differentiator

open class RxASTableAnimatedDataSource<S: AnimatableSectionModelType>: ASTableSectionedDataSource<S>, RxASTableDataSourceType {

    public typealias Element = [S]
    public typealias AnimationType = (ASTableSectionedDataSource<S>, ASTableNode, [Changeset<S>]) -> AnimationTransition

    /// Animation configuration for data source
    public var animationConfiguration: RowAnimation
    
    /// Calculates view transition depending on type of changes
    public var animationType: AnimationType

    public var animated: Bool = true
    private var dataSet = false

    #if os(iOS)
    public init(
        animationConfiguration: RowAnimation = RowAnimation(),
        animationType: @escaping AnimationType = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
        ) {
        self.animationConfiguration = animationConfiguration
        self.animationType = animationType
        
        super.init(
            configureCell: configureCell,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath,
            sectionIndexTitles: sectionIndexTitles,
            sectionForSectionIndexTitle: sectionForSectionIndexTitle
        )
    }

    public init(
        animationConfiguration: RowAnimation = RowAnimation(),
        animationType: @escaping AnimationType = { _, _, _ in .animated },
        configureCellBlock: @escaping ConfigureCellBlock,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
        ) {
        self.animationConfiguration = animationConfiguration
        self.animationType = animationType

        super.init(
            configureCellBlock: configureCellBlock,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath,
            sectionIndexTitles: sectionIndexTitles,
            sectionForSectionIndexTitle: sectionForSectionIndexTitle
        )
    }
    #else
    public init(
        animationConfiguration: AnimationConfiguration = RowAnimation(),
        animationType: @escaping AnimationType = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
    ) {
    self.animationConfiguration = animationConfiguration
    self.animationType = animationType
    
    super.init(
        configureCell: configureCell,
        titleForHeaderInSection: titleForHeaderInSection,
        titleForFooterInSection: titleForFooterInSection,
        canEditRowAtIndexPath: canEditRowAtIndexPath,
        canMoveRowAtIndexPath: canMoveRowAtIndexPath
    )
    }

    public init(
        animationConfiguration: AnimationConfiguration = RowAnimation(),
        animationType: @escaping AnimationType = { _, _, _ in .animated },
        configureCellBlock: @escaping ConfigureCellBlock,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
    ) {
    self.animationConfiguration = animationConfiguration
    self.animationType = animationType

    super.init(
        configureCellBlock: configureCellBlock,
        titleForHeaderInSection: titleForHeaderInSection,
        titleForFooterInSection: titleForFooterInSection,
        canEditRowAtIndexPath: canEditRowAtIndexPath,
        canMoveRowAtIndexPath: canMoveRowAtIndexPath
    )
    }
    #endif

    open func tableNode(_ tableNode: ASTableNode, observedEvent: RxSwift.Event<Element>) {
        Binder(self) { dataSource, newSections in
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
                    switch self.animationType(self, tableNode, differences) {
                    case .animated:
                        for difference in differences {
                            dataSource.setSections(difference.finalSections)
                            tableNode.performBatchUpdates(difference, animated: self.animated, animationConfiguration: self.animationConfiguration)
                        }
                    case .reload:
                        self.setSections(newSections)
                        tableNode.reloadData()
                        return
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

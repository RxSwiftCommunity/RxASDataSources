## RxASDataSources

[![Platforms](https://img.shields.io/cocoapods/p/RxASDataSources.svg)](https://cocoapods.org/pods/RxASDataSources)
[![License](https://img.shields.io/cocoapods/l/RxASDataSources.svg)](https://raw.githubusercontent.com/dangthaison91/RxASDataSources/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/RxASDataSources.svg)](https://cocoapods.org/pods/RxASDataSources)
[![Travis](https://img.shields.io/travis/dangthaison91/RxASDataSources/master.svg)](https://travis-ci.org/dangthaison91/RxASDataSources/branches)

[RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) for [AsyncDisplayKit/Texture](http://texturegroup.org/docs/getting-started.html): ASTableNode & ASCollectionNode.

- [RxASDataSources](#rxasdatasources)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
- [Usage](#usage)
- [License](#license)

## Features
- [x] **O(N)** Diff algorithm from [RxDataSources/Differentiator](https://github.com/RxSwiftCommunity/RxDataSources/tree/master/Sources/Differentiator)
- [x] Shared RxDataSources's APIs so you must learn only once.
- [x] Supports `ASTableNode` and `ASCollectionNode`
- [x] Support `nodeBlock`
- [ ] More complex Example app


## Requirements

- iOS 8.0+
- Xcode 9.0+
- RxSwift 4.0 & Texture 2.5

## Installation

### CocoaPods

To integrate RxASDataSources into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'RxASDataSources'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

To integrate RxASDataSources into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "RxSwiftCommunity/RxASDataSources"
```

## Usage
Working with RxASDataSources will be very simple if you are familiar with RxDataSources:
```ruby
typealias Section = SectionModel<String, Int>

let configureCell: ASTableSectionedDataSource<Section>.ConfigureCell = { (dataSource, tableNode, index, model) in
     let cell = ASTextCellNode()
     cell.text = model.info
     return cell
 }

 let animation = RowAnimation(insertAnimation: .automatic, reloadAnimation: .fade, deleteAnimation: .automatic)
 let dataSource = RxASTableSectionedReloadDataSource<Section>(animationConfiguration: animation, configureCell: configureCell)

 items
    .bind(to: tableNode.rx.items(dataSource: dataSource))
    .disposed(by: disposeBag)
```

For more advance usages, please follow [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) and [Example](https://github.com/RxSwiftCommunity/RxDataSources/tree/master/Example) then simply replace your **Views -> Nodes.**

## License

RxASDataSources is released under the MIT license. See [LICENSE](https://github.com/RxSwiftCommunity/RxASDataSources/blob/master/LICENSE) for details.

//
//  ASBindingObserver.swift
//  RxTextureDataSources
//
//  Created by Dang Thai Son on 8/9/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

public class ASBindingObserver<UIElementType, Value> : ObserverType where UIElementType: AnyObject {
    public typealias E = Value

    weak var UIElement: UIElementType?

    let binding: (UIElementType, Value) -> Void

    /// Initializes `ViewBindingObserver` using
    public init(UIElement: UIElementType, binding: @escaping (UIElementType, Value) -> Void) {
        self.UIElement = UIElement
        self.binding = binding
    }

    /// Binds next element to owner view as described in `binding`.
    public func on(_ event: Event<Value>) {

        switch event {
        case .next(let element):
            if let view = self.UIElement {
                binding(view, element)
            }
        case .error(let error):
            bindingErrorToInterface(error)
        case .completed:
            break
        }
    }

    /// Erases type of observer.
    ///
    /// - returns: type erased observer.
    public func asObserver() -> AnyObserver<Value> {
        return AnyObserver(eventHandler: on)
    }
}

//
//  ActionSending.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit


class ActionTarget<Sender>: NSObject {
    
    init(handler: @escaping (Sender) -> Void) {
        self.handler = handler
    }
    
    let handler: (Sender) -> Void

    @objc func handleAction(sender: Any) {
        handler(sender as! Sender)
    }
    
}

protocol ActionSending { }

extension NSObject: ActionSending {

    fileprivate static var targets = [ObjectIdentifier: [Any]]()
    
}

extension ActionSending where Self: UIGestureRecognizer {

    init(handler: @escaping (Self) -> Void) {
        let target = ActionTarget(handler: handler)
        self.init(target: target, action: #selector(target.handleAction(sender:)))
        Self.targets[ObjectIdentifier(self)] = [target]
    }
    
    func addAction(handler: @escaping (Self) -> Void) {
        let target = ActionTarget(handler: handler)
        addTarget(target, action: #selector(target.handleAction(sender:)))
        Self.targets[ObjectIdentifier(self), default: []].append(target)
    }
    
    func removeAllActions() {
        removeTarget(nil, action: nil)
        Self.targets[ObjectIdentifier(self)] = nil
    }

}

extension ActionSending where Self: UIBarButtonItem {
    
    init(barButtonSystemItem: SystemItem, handler: @escaping (Self) -> Void) {
        let target = ActionTarget(handler: handler)
        self.init(barButtonSystemItem: barButtonSystemItem, target: target, action: #selector(target.handleAction(sender:)))
        Self.targets[ObjectIdentifier(self)] = [target]
    }
    
    init(image: UIImage?, style: UIBarButtonItem.Style, handler: @escaping (Self) -> Void) {
        let target = ActionTarget(handler: handler)
        self.init(image: image, style: style, target: target, action: #selector(target.handleAction(sender:)))
        Self.targets[ObjectIdentifier(self)] = [target]
    }
    
}

extension ActionSending where Self: UIControl {
    
    func addAction(for event: Event, handler: @escaping (Self) -> Void) {
        let target = ActionTarget(handler: handler)
        addTarget(target, action: #selector(target.handleAction(sender:)), for: event)
        Self.targets[ObjectIdentifier(self), default: []].append(target)
        
    }
    
    func removeAllActions() {
        removeTarget(nil, action: nil, for: .allEvents)
        Self.targets[ObjectIdentifier(self)] = nil
    }
    
}

//
//  ControlTarget.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

private class ControlTarget<T>: NSObject {
    init(handler: @escaping (T, UIEvent) -> Void) {
        self.handler = handler
    }
    
    let handler: (T, UIEvent) -> Void

    @objc func doSomething(sender: Any, forEvent event: UIEvent) {
        handler(sender as! T, event)
    }
}



extension UIControl.Event: Hashable { }

protocol BlockControl { }
extension BlockControl where Self: UIControl {
    func addAction(for event: Event, handler: @escaping (Self, UIEvent) -> Void) {
        let target = ControlTarget(handler: handler)
        addTarget(target, action: #selector(ControlTarget<Self>.doSomething(sender:forEvent:)), for: event)
        if UIControl.targets[ObjectIdentifier(self)] == nil {
            UIControl.targets[ObjectIdentifier(self)] = [:]
        }
        if UIControl.targets[ObjectIdentifier(self)]?[event] == nil {
            UIControl.targets[ObjectIdentifier(self)]?[event] = []
        }
        UIControl.targets[ObjectIdentifier(self)]?[event]?.append(target)
        
    }
    
    func removeActions(for event: Event) {
        UIControl.targets[ObjectIdentifier(self)]?[event] = nil
    }
    
    func removeAllActions() {
        UIControl.targets[ObjectIdentifier(self)] = nil
    }
}

extension UIControl: BlockControl {
    fileprivate static var targets = [ObjectIdentifier: [UIControl.Event: [Any]]]()
    
}

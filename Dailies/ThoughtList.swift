//
//  ThoughtList.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/2.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation

class ThoughtList {
    
    static let shared = ThoughtList()
    
    @Published private(set) var value = Set<Thought>() {
        didSet {
            UndoManager.main.registerUndo(withTarget: self) {
                $0.value = oldValue
            }
            
            self.valueByDates = value
                .sorted(by: { $0.date > $1.date })
                .reduce([(dateComponents: DateComponents, thoughts: [Thought])](), { list, thought in
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: thought.date)
                    var list = list
                    if list.last?.dateComponents == dateComponents, var last = list.popLast() {
                        last.thoughts.append(thought)
                        list.append(last)
                    } else {
                        list.append((dateComponents: dateComponents, thoughts: [thought]))
                    }
                    return list
                })
        }
    }
    
    @Published private(set) var valueByDates = [(dateComponents: DateComponents, thoughts: [Thought])]()
    
    func modifyValue(handler: (inout Set<Thought>) -> Void) {
        var value = self.value
        handler(&value)
        self.value = value
    }
    
}

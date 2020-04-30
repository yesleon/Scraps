//
//  IdentifiableSet.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/30.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//


struct IdentifiableSet<Element: Identifiable> {
    
    typealias Store = Dictionary<Element.ID, Element>

    init() {
        self.store = [:]
    }
    
    init<Source: Sequence>(_ sequence: Source) where Element == Source.Element {
        self.init()
        for element in sequence {
            store[element.id] = element
        }
    }

    var isEmpty: Bool {
        store.isEmpty
    }
    
    private var store: Store
    
    subscript(id: Element.ID) -> Element? {
        get {
            return store[id]
        }
        set {
            store[id] = newValue
        }
    }
    
    subscript(id: Element.ID, default defaultValue: @autoclosure () -> Element) -> Element {
        get {
            return store[id, default: defaultValue()]
        }
        set {
            store[id, default: defaultValue()] = newValue
        }
    }
    
    mutating func modifyEach(handler: (inout Element) -> Void) {
        for key in store.keys {
            guard var element = store[key] else { continue }
            handler(&element)
            store[key] = element
        }
    }
    
}

extension IdentifiableSet: Sequence {
    
    func makeIterator() -> Store.Values.Iterator {
        store.values.makeIterator()
    }
    
}

extension IdentifiableSet: Collection {
    
    var startIndex: Store.Index {
        store.startIndex
    }
    
    var endIndex: Store.Index {
        store.endIndex
    }
    
    func index(after i: Store.Index) -> Store.Index {
        store.index(after: i)
    }
    
    subscript(position: Store.Index) -> Element {
        store[position].value
    }
    
}

extension IdentifiableSet: ExpressibleByArrayLiteral {
    
    init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements {
            self[element.id] = element
        }
    }
    
}

extension IdentifiableSet: CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible {
    
    var debugDescription: String {
        store.debugDescription
    }
    
    var customMirror: Mirror {
        store.customMirror
    }
    
    var description: String {
        store.description
    }
    
}

extension IdentifiableSet: Codable where Element: Codable, Element.ID: Codable { }

extension IdentifiableSet: Equatable, SetAlgebra where Element: Equatable { }

extension IdentifiableSet: Hashable where Element: Hashable { }

extension IdentifiableSet {
    
    func contains(_ element: Element) -> Bool {
        return self[element.id] != nil
    }

    func union(_ other: IdentifiableSet<Element>) -> IdentifiableSet<Element> {
        var set = self
        set.formUnion(other)
        return set
    }

    func intersection(_ other: IdentifiableSet<Element>) -> IdentifiableSet<Element> {
        var set = self
        set.formIntersection(other)
        return set
    }

    func symmetricDifference(_ other: IdentifiableSet<Element>) -> IdentifiableSet<Element> {
        var set = self
        set.formSymmetricDifference(other)
        return set
    }

    @discardableResult
    mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let oldMember = self[newMember.id] {
            return (false, oldMember)
        } else {
            self[newMember.id] = newMember
            return (true, newMember)
        }
    }

    @discardableResult
    mutating func remove(_ member: Element) -> Element? {
        let element = self[member.id]
        self[member.id] = nil
        return element
    }

    @discardableResult
    mutating func update(with newMember: Element) -> Element? {
        if let oldMember = self[newMember.id] {
            self[newMember.id] = newMember
            return oldMember
        } else {
            self[newMember.id] = newMember
            return nil
        }
    }

    mutating func formUnion(_ other: IdentifiableSet<Element>) {
        for element in other {
            self.insert(element)
        }
    }

    mutating func formIntersection(_ other: IdentifiableSet<Element>) {
        for element in other {
            if !self.contains(element) {
                self.remove(element)
            }
        }
    }

    mutating func formSymmetricDifference(_ other: IdentifiableSet<Element>) {
        for element in other {
            if self.contains(element) {
                self.remove(element)
            } else {
                self.insert(element)
            }
        }
    }

}

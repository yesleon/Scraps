//
//  Functions.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//




func modify<T>(_ value: inout T, handler: (inout T) -> Void) {
    var tempValue = value
    handler(&tempValue)
    value = tempValue
}

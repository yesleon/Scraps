//
//  FilenameConvertible.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation


protocol FilenameConvertible {
    init?(_ filename: String)
    var filename: String { get }
}

//
//  PKDrawing+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/27.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import PencilKit


extension PKDrawing: FileWrapperConvertible { }


extension PKDrawing: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.dataRepresentation())
    }
}

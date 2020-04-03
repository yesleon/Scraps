//
//  Window.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/4/3.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class Window: UIWindow {

    override var undoManager: UndoManager? { next?.undoManager }

}

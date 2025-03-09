//
//  WidgetTestBundle.swift
//  WidgetTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import WidgetKit
import SwiftUI

@main
struct WidgetTestBundle: WidgetBundle {
    var body: some Widget {
        WidgetTest()
        WidgetTestControl()
        WidgetTestLiveActivity()
    }
}

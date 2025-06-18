//
//  ThingsWidgetBundle.swift
//  ThingsWidget
//
//  Created by Aidan O'Brien on 17/06/2025.
//

import WidgetKit
import SwiftUI

@main
struct ThingsWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayListWidget()
        ProgressRingWidget()
        AddTodoWidget()
    }
}

//
//  Theme.swift
//  Things4
//
//  Centralised colours, fonts & spacing.
//
import SwiftUI

enum Theme {

    // ───────── Typography ─────────
    static let sidebarFont = Font.app(.semibold, size: 13)
    static let countFont   = Font.app(.regular,  size: 11)
    static let titleFont   = Font.app(.semibold, size: 20)
    static let taskFont    = Font.app(.regular,  size: 15)
    static let noteFont    = Font.app(.regular,  size: 13)
    static let tagFont     = Font.app(.regular,  size: 11)

    // ───────── Colour palette ─────────
    static let sidebarBackground = Color(NSColor.windowBackgroundColor)
    static let sidebarIcon       = Color.secondary
    static let listRowHighlight  = Color(NSColor.selectedContentBackgroundColor)
    static let cardBackground    = Color(NSColor.textBackgroundColor)
    static let cardBorder        = Color.secondary.opacity(0.15)

    // ───────── Metrics ─────────
    static let rowVSpacing:  CGFloat = 3   // sidebar rows
    static let cardVSpacing: CGFloat = 4   // gap between todo rows
}

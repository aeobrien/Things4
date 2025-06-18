//
//  Font+Custom.swift
//  Things4
//
//  Convenience helper for the SF UI Text family.
//  Call: Font.app(.semibold, size: 15)   or   Font.app(.light, italic: true, size: 13)
//
import SwiftUI

extension Font {
    /// Returns the requested weight / style from SF UI Text.
    static func app(_ weight: Weight = .regular,
                    italic: Bool = false,
                    size: CGFloat) -> Font {
        Font.custom(postScriptName(for: weight, italic: italic), size: size)
    }

    // MARK: – mapping
    private static func postScriptName(for weight: Weight,
                                       italic: Bool) -> String {
        switch (weight, italic) {
        case (.light,     false): return "SFUIText-Light"
        case (.light,      true): return "SFUIText-LightItalic"

        case (.regular,   false): return "SFUIText-Regular"
        case (.regular,    true): return "SFUIText-RegularItalic"

        case (.medium,    false): return "SFUIText-Medium"
        case (.medium,     true): return "SFUIText-MediumItalic"

        case (.semibold,  false): return "SFUIText-Semibold"
        case (.semibold,   true): return "SFUIText-SemiboldItalic"

        case (.bold,      false): return "SFUIText-Bold"
        case (.bold,       true): return "SFUIText-BoldItalic"

        case (.heavy,     false): return "SFUIText-Heavy"
        case (.heavy,      true): return "SFUIText-HeavyItalic"

        // fall-back: anything else → regular
        default: return italic ? "SFUIText-RegularItalic" : "SFUIText-Regular"
        }
    }
}

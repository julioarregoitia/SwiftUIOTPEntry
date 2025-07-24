//
//  ModelUISwiftUIOTPEntry.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 1/28/25.
//


import SwiftUI

public struct ModelUISwiftUIOTPEntry: Sendable {
    
    /// `Font of each number in the row`
    let font: UIFont
    
    /// `The text with a box is empty to say with VoiceOver`
    let textAccessibilityForEmptyBox: String
    
    /// `The text for VoiceOver to say a position`
    let textAccessibilityPosition: String
    
    /// `The number of square boxes to fill with numbers`
    let count: Int
    
    /// `The space in horizontal between each square box`
    let spacing: CGFloat
    
    /// `The color of the border of the square when an item is focused`
    let colorFocused: Color
    
    /// `The color of the border of the square when an item is not focused and also NOT filled with a number`
    let colorEmpty: Color

    /// `The color of the border of the square when an item is not focused and also IS filled with a number`
    let colorFill: Color
    
    /// `The size of each square box (take into account that each box is a square)`
    let size: CGFloat
    
    public init(font: UIFont, textAccessibilityForEmptyBox: String, textAccessibilityPosition: String, count: Int, spacing: CGFloat, colorFocused: Color, colorEmpty: Color, colorFill: Color, size: CGFloat) {
        self.font = font
        self.textAccessibilityForEmptyBox = textAccessibilityForEmptyBox
        self.textAccessibilityPosition = textAccessibilityPosition
        self.count = count
        self.spacing = spacing
        self.colorFocused = colorFocused
        self.colorEmpty = colorEmpty
        self.colorFill = colorFill
        self.size = size
    }
}


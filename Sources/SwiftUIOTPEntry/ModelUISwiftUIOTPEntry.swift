//
//  ModelUISwiftUIOTPEntry.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 1/28/25.
//


import SwiftUI

/// Configuration model for `ViewSwiftUIOTPEntry` styling and accessibility behavior.
///
/// Use this type to define OTP box count, spacing, sizing, colors, and VoiceOver strings.
///
/// Example:
/// ```swift
/// let config = ModelUISwiftUIOTPEntry(
///     font: .systemFont(ofSize: 20, weight: .semibold),
///     textAccessibilityForEmptyBox: "Empty",
///     textAccessibilityPosition: "Position",
///     count: 6,
///     spacing: 10,
///     colorFocused: .blue,
///     colorEmpty: .gray,
///     colorFill: .green,
///     size: 44
/// )
/// ```
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
    
    /// Creates a configuration model for the OTP entry view.
    ///
    /// - Parameters:
    ///   - font: The font used to render each OTP digit.
    ///   - textAccessibilityForEmptyBox: VoiceOver text announced when a box is empty.
    ///   - textAccessibilityPosition: VoiceOver label used to announce the digit position.
    ///   - count: Total number of OTP boxes.
    ///   - spacing: Horizontal spacing between OTP boxes.
    ///   - colorFocused: Border color for the currently focused box.
    ///   - colorEmpty: Border color for an unfocused empty box.
    ///   - colorFill: Border color for an unfocused box that contains a digit.
    ///   - size: Side length of each OTP box.
    ///
    /// Example:
    /// ```swift
    /// let config = ModelUISwiftUIOTPEntry(
    ///     font: .systemFont(ofSize: 20, weight: .semibold),
    ///     textAccessibilityForEmptyBox: "Empty",
    ///     textAccessibilityPosition: "Position",
    ///     count: 6,
    ///     spacing: 10,
    ///     colorFocused: .blue,
    ///     colorEmpty: .gray,
    ///     colorFill: .green,
    ///     size: 44
    /// )
    /// ```
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


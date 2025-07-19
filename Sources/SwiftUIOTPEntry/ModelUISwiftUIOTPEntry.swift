//
//  ModelUISwiftUIOTPEntry.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 1/28/25.
//


import SwiftUI

public struct ModelUISwiftUIOTPEntry: Sendable {
    let font: UIFont
    let count: Int
    let spacing: CGFloat
    let colorFocused: Color
    let colorEmpty: Color
    let colorFill: Color
    
    let size: CGFloat
    
    public init(font: UIFont, count: Int, spacing: CGFloat, colorFocused: Color, colorEmpty: Color, colorFill: Color, size: CGFloat) {
        self.font = font
        self.count = count
        self.spacing = spacing
        self.colorFocused = colorFocused
        self.colorEmpty = colorEmpty
        self.colorFill = colorFill
        self.size = size
    }
}


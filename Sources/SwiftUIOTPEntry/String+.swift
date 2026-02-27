//
//  String+.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 7/18/25.
//

import Foundation

extension String {
    /// Returns a copy of the string containing only decimal digit characters.
    func onlyDigits() -> String {
        // Keep only scalars that are part of the decimal digit character set.
        let filteredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filteredUnicodeScalars))
    }
}

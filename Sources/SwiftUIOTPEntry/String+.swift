//
//  String+.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 7/18/25.
//

import Foundation

extension String {
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
}

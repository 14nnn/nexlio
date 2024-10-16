//
//  String+Extensions.swift
//  FlipRSS
//
//  Created by Darian on 16.10.2024..
//

import Foundation

extension String {
    /// Strips HTML tags from the string and removes all excess whitespace, including U+FFFC characters.
    func strippingHTML() -> String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        var strippedString = attributedString?.string ?? self

        // Remove all control characters including U+FFFC
        strippedString = strippedString.replacingOccurrences(of: "\u{FFFC}", with: "")
            .trimmingCharacters(in: .controlCharacters)

        // Clean leading/trailing whitespace
        let cleanedString = strippedString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleanedString
    }
}

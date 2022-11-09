//
//  StringExtension.swift
//  Card Master
//
//  Created by Thomas Davey on 25/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

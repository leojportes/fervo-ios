//
//  Colors+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

extension Color {
    struct FVColor {
        static var backgroundDark: Color {
            return Color("fv_backgroundColor")
        }

        static var cardBackground: Color {
            return Color("fv_cardBackgorundColor")
        }

        static var headerCardbackgroundColor: Color {
            return Color("fv_headerCardbackgroundColor")
        }

        static var purpleNeon: Color {
            return Color("purple_neon")
        }
    }
}

extension UIColor {

    struct FVColor {
        static var backgroundDark: UIColor {
            return UIColor(named: "fv_backgroundColor") ?? .systemGray6
        }

        static var cardBackground: UIColor {
            return UIColor(named: "fv_cardBackgorundColor") ?? .systemGray5
        }

        static var headerCardbackgroundColor: UIColor {
            return UIColor(named: "fv_headerCardbackgroundColor") ?? .systemGray4
        }

        static var purpleNeon: UIColor {
            return UIColor(named: "purple_neon") ?? .purple
        }
    }

}


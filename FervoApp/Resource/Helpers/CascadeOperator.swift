//
//  CascadeOperator.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 21/05/25.
//

import Foundation

prefix operator ..
infix operator ..: MultiplicationPrecedence

/// Custom operator that lets you configure an instance inline
/// ```swift
/// self.backgroundView = UIView() .. { $0.backgroundColor = .blue }
/// ```
@discardableResult

func .. <T>(object: T, configuration: (inout T) -> Void) -> T {
    var object = object
    configuration(&object)
    return object
}

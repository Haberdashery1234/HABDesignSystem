//
//  HABAccessibleAction.swift
//  HABUIKit
//
//  Created by Christian Grise on 7/4/26.
//

import Foundation

public struct HABAccessibleAction {
    public let label: String
    public let action: () -> Void
    
    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
}

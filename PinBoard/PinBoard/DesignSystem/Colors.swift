//
//  Colors.swift
//  PinBoard
//
//  Created by Galia on 2/20/26.
//

import UIKit

enum AppColors {
    static let primary = UIColor(named: "Primary") ?? .systemRed
    static let secondary = UIColor(named: "Secondary") ?? .secondaryLabel
    static let background = UIColor(named: "Background") ?? .systemBackground
    static let surface = UIColor(named: "Surface") ?? .secondarySystemBackground
    static let onSurface = UIColor(named: "OnSurface") ?? .label
    static let onSurfaceSecondary = UIColor(named: "OnSurfaceSecondary") ?? .secondaryLabel
    static let error = UIColor(named: "Error") ?? .systemRed
    static let divider = UIColor(named: "Divider") ?? .separator
}

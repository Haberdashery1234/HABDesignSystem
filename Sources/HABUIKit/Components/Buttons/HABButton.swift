//
//  HABButton.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABButton: UIButton {
    public enum Style {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    public enum Size {
        case small
        case medium
        case large
    }
    
    public enum IconPosition {
        case leading
        case trailing
        case above
        case below
    }
    
    public var style: Style {
        didSet {
            updateAppearance()
        }
    }
    public var size: Size = .medium {
        didSet {
            updateAppearance()
        }
    }
    public var title: String? {
        didSet {
            updateAppearance()
        }
    }
    public var icon: UIImage? {
        didSet {
            updateAppearance()
        }
    }
    public var iconPosition: IconPosition = .leading {
        didSet {
            updateAppearance()
        }
    }
    public var isLoading: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    private var styleForegroundColor: UIColor {
        switch style {
            case .primary:
                return .habOnPrimary
            case .secondary, .ghost:
                return .habPrimary
            case .destructive:
                return .white
        }
    }
    
    private var styleBackgroundColor: UIColor {
        switch style {
            case .primary:
                return .habPrimary
            case .secondary, .ghost:
                return .clear
            case .destructive:
                return .habDestructive
        }
    }

    private var sizeContentInsets: NSDirectionalEdgeInsets {
        switch size {
            case .small:
                return NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .medium:
                return NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large:
                return NSDirectionalEdgeInsets(top: 16, leading: 28, bottom: 16, trailing: 28)
        }
    }
    
    private var labelFont: UIFont {
        switch size {
            case .small:
                return .habCaption1
            case .medium:
                return .habBody
            case .large:
                return .habHeadline
        }
    }
    
    private var resolvedImagePlacement: NSDirectionalRectEdge {
        switch iconPosition {
            case .leading:
                return .leading
            case .trailing:
                return .trailing
            case .above:
                return .top
            case .below:
                return .bottom
        }
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        $0.style = .medium
        $0.hidesWhenStopped = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIActivityIndicatorView())

    public init(style: Style, size: Size = .medium, title: String? = nil, icon: UIImage? = nil, iconPosition: IconPosition = .leading) {
        self.style = style
        self.size = size
        self.title = title
        self.icon = icon
        self.iconPosition = iconPosition
        super.init(frame: .zero)

        self.addActivityIndicator()
        configurationUpdateHandler = { button in
            if button.state.contains(.disabled) {
                button.alpha = 0.4
            } else if button.state.contains(.highlighted) {
                button.alpha = 0.7
            } else {
                button.alpha = 1
            }
        }
        
        self.updateAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addActivityIndicator() {
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc private func themeDidChange() {
        updateAppearance()
    }
    
    private func updateAppearance() {
        var config = UIButton.Configuration.filled()
        let fgColor = styleForegroundColor
        let bgColor = styleBackgroundColor
        
        config.baseForegroundColor = fgColor
        config.baseBackgroundColor = bgColor
        config.cornerStyle = .capsule
        
        if style == .secondary {
            config.background.strokeColor = .habPrimary
            config.background.strokeWidth = 1.5
        }
        
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] incoming in
            var outgoing = incoming
            outgoing.font = self?.labelFont
            return outgoing
        }
        
        config.contentInsets = sizeContentInsets
        config.image = icon
        config.imagePadding = HABSpacing.xs
        config.imagePlacement = resolvedImagePlacement
        
        if isLoading {
            config.title = nil
            config.image = nil
            activityIndicator.startAnimating()
            activityIndicator.color = fgColor
            isUserInteractionEnabled = false
            accessibilityLabel = "Loading"
            accessibilityTraits = [.button, .notEnabled]
        } else {
            activityIndicator.stopAnimating()
            isUserInteractionEnabled = true
            accessibilityLabel = nil
            accessibilityTraits = .button
        }
        
        configuration = config
    }
}

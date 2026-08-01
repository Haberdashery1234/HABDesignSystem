//
//  HABButton.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A themed button component with multiple visual styles, sizes, and loading states.
///
/// `HABButton` provides a fully-styled button that automatically responds to theme changes
/// and supports various configurations including icons, loading indicators, and different
/// visual treatments.
///
/// ## Overview
///
/// Use `HABButton` to create interactive elements that match your app's theme and provide
/// consistent styling across your interface. The button supports:
/// - Multiple visual styles (primary, secondary, ghost, destructive)
/// - Three sizes (small, medium, large)
/// - Optional icons with flexible positioning
/// - Built-in loading state with activity indicator
/// - Automatic theme updates
///
/// ## Creating a Button
///
/// Initialize a button with a style and optional configuration:
///
/// ```swift
/// let button = HABButton(
///     style: .primary,
///     size: .medium,
///     title: "Continue",
///     icon: UIImage(systemName: "arrow.right")
/// )
/// ```
///
/// ## Visual Styles
///
/// Choose from four button styles:
/// - ``Style/primary``: Filled with the primary brand color
/// - ``Style/secondary``: Outlined with the primary color
/// - ``Style/ghost``: Transparent background with primary text
/// - ``Style/destructive``: Red filled button for destructive actions
///
/// ## Loading State
///
/// Show a loading indicator by setting ``isLoading`` to `true`:
///
/// ```swift
/// button.isLoading = true
/// // Perform async operation
/// button.isLoading = false
/// ```
///
/// When loading, the button disables user interaction and displays an activity indicator.
///
/// ## Topics
///
/// ### Creating a Button
/// - ``init(style:size:title:icon:iconPosition:)``
///
/// ### Configuring Appearance
/// - ``style``
/// - ``size``
/// - ``Style``
/// - ``Size``
///
/// ### Managing Content
/// - ``title``
/// - ``icon``
/// - ``iconPosition``
/// - ``IconPosition``
///
/// ### Managing State
/// - ``isLoading``
public final class HABButton: UIButton {
    /// The visual style of the button.
    ///
    /// Determines the button's color scheme, background treatment, and overall appearance.
    public enum Style {
        /// Filled button with the primary brand color.
        ///
        /// Use for the main call-to-action in a view.
        case primary
        
        /// Outlined button with transparent background and primary border.
        ///
        /// Use for secondary actions that need emphasis but shouldn't compete
        /// with the primary action.
        case secondary
        
        /// Transparent button with no border.
        ///
        /// Use for tertiary actions, navigation, or low-emphasis interactions.
        case ghost
        
        /// Filled button with destructive (red) color.
        ///
        /// Use for destructive actions like delete or remove.
        case destructive
    }
    
    /// The size of the button, affecting padding and font size.
    public enum Size {
        /// Small button with reduced padding and caption text.
        case small
        
        /// Standard button size with balanced padding and body text.
        case medium
        
        /// Large button with generous padding and headline text.
        case large
    }
    
    /// The position of the icon relative to the title.
    public enum IconPosition {
        /// Icon appears before the title text (left in LTR, right in RTL).
        case leading
        
        /// Icon appears after the title text (right in LTR, left in RTL).
        case trailing
        
        /// Icon appears above the title text.
        case above
        
        /// Icon appears below the title text.
        case below
    }
    
    /// The visual style of the button.
    ///
    /// Changing this property updates the button's appearance immediately.
    public var style: Style {
        didSet {
            updateAppearance()
        }
    }
    
    /// The size of the button.
    ///
    /// Changing this property updates the button's padding and font size immediately.
    public var size: Size = .medium {
        didSet {
            updateAppearance()
        }
    }
    
    /// The text displayed on the button.
    ///
    /// Set to `nil` to create an icon-only button.
    public var title: String? {
        didSet {
            updateAppearance()
        }
    }
    
    /// The icon displayed on the button.
    ///
    /// Set to `nil` to create a text-only button.
    public var icon: UIImage? {
        didSet {
            updateAppearance()
        }
    }
    
    /// The position of the icon relative to the title.
    ///
    /// This property is ignored if ``icon`` is `nil`.
    public var iconPosition: IconPosition = .leading {
        didSet {
            updateAppearance()
        }
    }
    
    /// A Boolean value that determines whether the button is in loading state.
    ///
    /// When `true`, the button displays an activity indicator, hides the title and icon,
    /// and disables user interaction. Set back to `false` to restore normal appearance.
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

    /// Creates a new button with the specified configuration.
    ///
    /// - Parameters:
    ///   - style: The visual style of the button. Defaults to `.primary`.
    ///   - size: The size of the button. Defaults to `.medium`.
    ///   - title: The text to display on the button. Defaults to `nil`.
    ///   - icon: The icon to display on the button. Defaults to `nil`.
    ///   - iconPosition: The position of the icon relative to the title. Defaults to `.leading`.
    ///
    /// The button automatically registers for theme change notifications and updates
    /// its appearance when the active theme changes.
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

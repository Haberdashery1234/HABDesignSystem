//
//  HABTextField.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A themed text input field with support for labels, icons, validation states, and helper text.
///
/// `HABTextField` provides a comprehensive text input solution that goes beyond the standard
/// `UITextField` by including integrated labels, icons, error handling, and automatic theme support.
///
/// ## Overview
///
/// Use `HABTextField` when you need a complete text input component with visual feedback for
/// validation states. The field automatically manages its appearance based on:
/// - Input focus state
/// - Error conditions
/// - Disabled state
/// - Current theme
///
/// The text field supports:
/// - Top labels for field identification
/// - Leading and trailing icons
/// - Helper text below the field
/// - Error messages with automatic VoiceOver announcements
/// - Two visual styles (outlined and filled)
///
/// ## Creating a Text Field
///
/// Initialize a text field with optional configuration:
///
/// ```swift
/// let emailField = HABTextField(
///     style: .outlined,
///     topLabel: "Email",
///     helperText: "We'll never share your email"
/// )
/// emailField.placeholder = "you@example.com"
/// emailField.keyboardType = .emailAddress
/// ```
///
/// ## Showing Validation Errors
///
/// Set the `errorText` property to show an error state:
///
/// ```swift
/// if !isValidEmail(emailField.text) {
///     emailField.errorText = "Please enter a valid email address"
/// } else {
///     emailField.errorText = nil
/// }
/// ```
///
/// ## Topics
///
/// ### Creating a Text Field
/// - ``init(style:topLabel:helperText:errorText:leadingIcon:trailingIcon:trailingAction:isDisabled:delegate:)``
///
/// ### Configuring Appearance
/// - ``style``
/// - ``Style``
///
/// ### Managing Content
/// - ``text``
/// - ``placeholder``
/// - ``topLabel``
/// - ``helperText``
/// - ``errorText``
///
/// ### Adding Icons
/// - ``leadingIcon``
/// - ``trailingIcon``
/// - ``trailingAction``
///
/// ### Managing State
/// - ``isDisabled``
/// - ``State``
///
/// ### Configuring Keyboard
/// - ``keyboardType``
/// - ``isSecureTextEntry``
/// - ``returnKeyType``
/// - ``autocapitalizationType``
/// - ``autocorrectionType``
///
/// ### Managing Delegation
/// - ``delegate``
public final class HABTextField: UIView {
    /// The visual style of the text field.
    ///
    /// Determines the field's background and border treatment.
    public enum Style {
        /// Text field with a border and transparent background.
        ///
        /// Use outlined style when the field needs to stand out against
        /// the background or when you want maximum contrast.
        case outlined
        
        /// Text field with a filled background and subtle border.
        ///
        /// Use filled style for a softer appearance that integrates well
        /// with content-heavy layouts.
        case filled
    }

    /// The state of the text field.
    ///
    /// The state is managed internally based on focus, errors, and enabled status.
    public enum State {
        /// Normal, unfocused state.
        case `default`
        
        /// Field is currently focused and receiving input.
        case focused
        
        /// Field has a validation error.
        case error
        
        /// Field is disabled and doesn't accept input.
        case disabled
    }

    private let fieldLabel = UILabel()
    private let containerView = UIView()
    private let leadingIconView = UIImageView()
    private let textField = UITextField()
    private let trailingButton = UIButton(type: .system)
    private let bottomLabel = UILabel()

    /// The visual style of the text field.
    ///
    /// Changing this property updates the field's background and border treatment immediately.
    public var style: Style = .outlined {
        didSet { updateAppearance() }
    }
    
    private var currentState: State = .default
    
    /// The label text displayed above the text field.
    ///
    /// Use this to identify what the field is for (e.g., "Email", "Password").
    /// Set to `nil` to hide the top label.
    public var topLabel: String? {
        didSet { updateAppearance() }
    }
    
    /// The placeholder text shown when the field is empty.
    public var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    /// The current text in the field.
    ///
    /// Returns an empty string if the field contains no text.
    public var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }
    
    /// Helper text displayed below the field in the default state.
    ///
    /// Use this to provide additional context or instructions for the field.
    /// This is hidden when ``errorText`` is set.
    public var helperText: String? {
        didSet { updateAppearance() }
    }
    
    /// Error message displayed below the field.
    ///
    /// When set to a non-nil value, the field enters error state with red styling
    /// and announces the error to VoiceOver users. Set to `nil` to clear the error.
    public var errorText: String? {
        didSet {
            updateAppearance()
            if let errorText {
                UIAccessibility.post(notification: .announcement, argument: errorText)
            }
        }
    }
    
    /// An icon displayed at the leading edge of the field.
    ///
    /// Use this to provide visual context for the field's purpose (e.g., a mail icon for email fields).
    public var leadingIcon: UIImage? {
        didSet { updateAppearance() }
    }
    
    /// An icon displayed at the trailing edge of the field.
    ///
    /// This icon can be made interactive by setting ``trailingAction``.
    public var trailingIcon: UIImage? {
        didSet { updateAppearance() }
    }
    
    /// An action triggered when the user taps the trailing icon.
    ///
    /// Set this to make the trailing icon interactive (e.g., to toggle password visibility).
    public var trailingAction: HABAccessibleAction?

    /// A Boolean value that determines whether the field is disabled.
    ///
    /// When `true`, the field appears dimmed and doesn't accept input.
    public var isDisabled: Bool = false {
        didSet { updateAppearance() }
    }
    
    /// The keyboard type to display when the field is active.
    public var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    /// A Boolean value that determines whether the field displays entered text as dots.
    ///
    /// Set to `true` for password fields.
    public var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    /// The return key type for the keyboard.
    public var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    /// The autocapitalization behavior for the field.
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    
    /// The autocorrection behavior for the field.
    public var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }
    
    /// The delegate for the underlying text field.
    ///
    /// Set this to receive text field delegate callbacks such as `textFieldShouldReturn(_:)`.
    public weak var delegate: UITextFieldDelegate?
    
    /// Creates a new text field with the specified configuration.
    ///
    /// - Parameters:
    ///   - style: The visual style of the field. Defaults to `.outlined`.
    ///   - topLabel: The label text above the field. Defaults to `nil`.
    ///   - helperText: Helper text below the field. Defaults to `nil`.
    ///   - errorText: Error message text. Defaults to `nil`.
    ///   - leadingIcon: Icon at the leading edge. Defaults to `nil`.
    ///   - trailingIcon: Icon at the trailing edge. Defaults to `nil`.
    ///   - trailingAction: Action for the trailing icon. Defaults to `nil`.
    ///   - isDisabled: Whether the field starts disabled. Defaults to `false`.
    ///   - delegate: The text field delegate. Defaults to `nil`.
    ///
    /// The text field automatically registers for theme change notifications and updates
    /// its appearance when the active theme changes.
    public init(style: Style = .outlined, topLabel: String? = nil, helperText: String? = nil, errorText: String? = nil, leadingIcon: UIImage? = nil, trailingIcon: UIImage? = nil, trailingAction: HABAccessibleAction? = nil, isDisabled: Bool = false, delegate: UITextFieldDelegate? = nil) {
        self.style = style
        self.topLabel = topLabel
        self.helperText = helperText
        self.errorText = errorText
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
        self.isDisabled = isDisabled
        self.delegate = delegate
        super.init(frame: .zero)
        setupViews()
        updateAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func themeDidChange() {
        updateAppearance()
    }
    
    private func setupViews() {
        textField.delegate = self
        containerView.clipsToBounds = true

        addSubview(fieldLabel)
        containerView.addSubview(leadingIconView)
        containerView.addSubview(textField)
        containerView.addSubview(trailingButton)
        addSubview(containerView)
        addSubview(bottomLabel)
        
        [
            fieldLabel,
            leadingIconView,
            textField,
            trailingButton,
            containerView,
            bottomLabel
        ].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            fieldLabel.topAnchor.constraint(equalTo: topAnchor),
            fieldLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            fieldLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: fieldLabel.bottomAnchor, constant: HABSpacing.xs),
            containerView.leadingAnchor.constraint(equalTo: fieldLabel.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: fieldLabel.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            leadingIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leadingIconView.topAnchor.constraint(equalTo: containerView.topAnchor),
            leadingIconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingIconView.widthAnchor.constraint(equalTo: leadingIconView.heightAnchor),
            
            textField.leadingAnchor.constraint(equalTo: leadingIconView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingButton.leadingAnchor),
            
            trailingButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            trailingButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            trailingButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            trailingButton.widthAnchor.constraint(equalTo: trailingButton.heightAnchor),
            
            bottomLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: HABSpacing.xs),
            bottomLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        fieldLabel.isAccessibilityElement = false
        leadingIconView.isAccessibilityElement = false
        bottomLabel.isAccessibilityElement = false

        trailingButton.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
    }
    
    private func updateAppearance() {
        fieldLabel.isHidden = ((topLabel?.isEmpty) == nil)
        if let topLabel {
            fieldLabel.text = topLabel
            fieldLabel.font = .habFootnote
            fieldLabel.textColor = .habForegroundSecondary
        }
        
        containerView.layer.cornerRadius = HABRadius.sm
        if style == .outlined {
            containerView.layer.borderColor = UIColor.habBorder.cgColor
            containerView.layer.borderWidth = 1
            containerView.backgroundColor = .clear
        } else if style == .filled {
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0
            containerView.backgroundColor = .habSurface
        }
        
        bottomLabel.font = .habCaption1
        bottomLabel.isHidden = false
        if let errorText {
            bottomLabel.text = errorText
            bottomLabel.textColor = .habDestructive
        } else if let helperText {
            bottomLabel.text = helperText
            bottomLabel.textColor = .habForegroundSecondary
        } else {
            bottomLabel.isHidden = true
        }
        
        if let leadingIcon {
            leadingIconView.image = leadingIcon
            leadingIconView.isHidden = false
        } else {
            leadingIconView.isHidden = true
        }
        
        if let trailingIcon {
            trailingButton.setImage(trailingIcon, for: .normal)
            trailingButton.accessibilityLabel = trailingAction?.label
            trailingButton.isHidden = false
        } else {
            trailingButton.isHidden = true
        }
        
        textField.textColor = .habForeground
        textField.tintColor = .habPrimary
        textField.accessibilityLabel = topLabel
        textField.accessibilityHint = errorText ?? helperText

        if isDisabled {
            alpha = 0.4
            textField.isUserInteractionEnabled = false
        } else {
            alpha = 1
            textField.isUserInteractionEnabled = true
        }

        deriveState()

        switch currentState {
            case .focused:
                containerView.layer.borderColor = UIColor.habPrimary.cgColor
                containerView.layer.borderWidth = 1
            case .error:
                containerView.layer.borderColor = UIColor.habDestructive.cgColor
                containerView.layer.borderWidth = 1
            default:
                containerView.layer.borderColor = UIColor.habBorder.cgColor
        }
    }
    
    private func deriveState() {
        if errorText != nil {
            currentState = .error
        } else if isDisabled {
            currentState = .disabled
        } else if textField.isFirstResponder {
            currentState = .focused
        } else {
            currentState = .default
        }
    }
    
    @objc private func trailingButtonTapped() {
        trailingAction?.action()
    }
}

extension HABTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        currentState = .focused
        updateAppearance()
        delegate?.textFieldDidBeginEditing?(textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        deriveState()
        updateAppearance()
        delegate?.textFieldDidEndEditing?(textField)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn?(textField) ?? true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}

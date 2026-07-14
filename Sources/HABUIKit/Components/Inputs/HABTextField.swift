//
//  HABTextField.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABTextField: UIView {
    public enum Style {
        case outlined
        case filled
    }

    public enum State {
        case `default`
        case focused
        case error
        case disabled
    }

    private let fieldLabel = UILabel()
    private let containerView = UIView()
    private let leadingIconView = UIImageView()
    private let textField = UITextField()
    private let trailingButton = UIButton(type: .system)
    private let bottomLabel = UILabel()

    public var style: Style = .outlined {
        didSet { updateAppearance() }
    }
    
    private var currentState: State = .default
    
    public var topLabel: String? {
        didSet { updateAppearance() }
    }
    
    public var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    public var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }
    
    public var helperText: String? {
        didSet { updateAppearance() }
    }
    
    public var errorText: String? {
        didSet {
            updateAppearance()
            if let errorText {
                UIAccessibility.post(notification: .announcement, argument: errorText)
            }
        }
    }
    
    public var leadingIcon: UIImage? {
        didSet { updateAppearance() }
    }
    
    public var trailingIcon: UIImage? {
        didSet { updateAppearance() }
    }
    
    public var trailingAction: HABAccessibleAction?

    public var isDisabled: Bool = false {
        didSet { updateAppearance() }
    }
    
    public var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    public var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    public var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    
    public var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }
    
    public weak var delegate: UITextFieldDelegate?
    
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

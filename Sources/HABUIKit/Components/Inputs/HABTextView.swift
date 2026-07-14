//
//  HABTextView.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABTextView: UIView {
    // MARK: - Enums

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

    // MARK: - Private Subviews

    private let fieldLabel = UILabel()
    private let containerView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let bottomLabel = UILabel()

    // MARK: - Public Properties

    public var style: Style = .outlined {
        didSet { updateAppearance() }
    }

    public var topLabel: String? {
        didSet { updateAppearance() }
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

    public var isDisabled: Bool = false {
        didSet { updateAppearance() }
    }

    public var minHeight: CGFloat = 80 {
        didSet { minHeightConstraint?.constant = minHeight }
    }

    // MARK: - Passthrough Properties

    public var placeholder: String? {
        get { placeholderLabel.text }
        set {
            placeholderLabel.text = newValue
            updatePlaceholder()
        }
    }

    public var text: String? {
        get { textView.text }
        set {
            textView.text = newValue
            updatePlaceholder()
        }
    }

    public var keyboardType: UIKeyboardType {
        get { textView.keyboardType }
        set { textView.keyboardType = newValue }
    }

    public var autocapitalizationType: UITextAutocapitalizationType {
        get { textView.autocapitalizationType }
        set { textView.autocapitalizationType = newValue }
    }

    public var autocorrectionType: UITextAutocorrectionType {
        get { textView.autocorrectionType }
        set { textView.autocorrectionType = newValue }
    }

    public var returnKeyType: UIReturnKeyType {
        get { textView.returnKeyType }
        set { textView.returnKeyType = newValue }
    }

    public weak var delegate: UITextViewDelegate?

    // MARK: - Private State

    private var currentState: State = .default
    private var minHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    public init(
        style: Style = .outlined,
        topLabel: String? = nil,
        placeholder: String? = nil,
        helperText: String? = nil,
        errorText: String? = nil,
        isDisabled: Bool = false,
        minHeight: CGFloat = 80,
        delegate: UITextViewDelegate? = nil
    ) {
        self.style = style
        self.topLabel = topLabel
        self.helperText = helperText
        self.errorText = errorText
        self.isDisabled = isDisabled
        self.minHeight = minHeight
        self.delegate = delegate
        super.init(frame: .zero)
        setupViews()
        self.placeholder = placeholder
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        updateAppearance()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }

    // MARK: - Setup

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        // Configure textView
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.font = .habBody
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(
            top: HABSpacing.sm,
            left: HABSpacing.sm,
            bottom: HABSpacing.sm,
            right: HABSpacing.sm
        )

        // Configure containerView
        containerView.clipsToBounds = true

        // Configure placeholderLabel
        placeholderLabel.font = .habBody
        placeholderLabel.numberOfLines = 0

        // Configure fieldLabel
        fieldLabel.font = .habFootnote
        fieldLabel.numberOfLines = 1

        // Configure bottomLabel
        bottomLabel.font = .habCaption1
        bottomLabel.numberOfLines = 0

        // Accessibility
        fieldLabel.isAccessibilityElement = false
        bottomLabel.isAccessibilityElement = false

        // Add subviews
        addSubview(fieldLabel)
        addSubview(containerView)
        addSubview(bottomLabel)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)

        [
            fieldLabel,
            containerView,
            textView,
            placeholderLabel,
            bottomLabel
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // textContainer.lineFragmentPadding is 5pt by default, so leading offset = sm + 5
        let placeholderLeadingInset = CGFloat(HABSpacing.sm) + 5

        let minH = NSLayoutConstraint(
            item: containerView,
            attribute: .height,
            relatedBy: .greaterThanOrEqual,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: minHeight
        )
        minHeightConstraint = minH

        NSLayoutConstraint.activate([
            // fieldLabel: top/leading/trailing of self
            fieldLabel.topAnchor.constraint(equalTo: topAnchor),
            fieldLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            fieldLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            // containerView: below fieldLabel, leading/trailing aligned
            containerView.topAnchor.constraint(equalTo: fieldLabel.bottomAnchor, constant: HABSpacing.xs),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            minH,

            // textView: fills containerView
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // placeholderLabel: matches textContainerInset top/leading
            placeholderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: HABSpacing.sm),
            placeholderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: placeholderLeadingInset),
            placeholderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CGFloat(HABSpacing.sm)),

            // bottomLabel: below containerView, leading/trailing, pinned to self bottom
            bottomLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: HABSpacing.xs),
            bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // fieldLabel
        if let topLabel, !topLabel.isEmpty {
            fieldLabel.isHidden = false
            fieldLabel.text = topLabel
            fieldLabel.textColor = .habForegroundSecondary
        } else {
            fieldLabel.isHidden = true
        }

        // containerView style
        containerView.layer.cornerRadius = HABRadius.sm
        switch style {
            case .outlined:
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.habBorder.cgColor
                containerView.backgroundColor = .clear
            case .filled:
                containerView.layer.borderWidth = 0
                containerView.layer.borderColor = UIColor.clear.cgColor
                containerView.backgroundColor = .habSurface
        }

        // bottomLabel
        bottomLabel.font = .habCaption1
        if let errorText {
            bottomLabel.isHidden = false
            bottomLabel.text = errorText
            bottomLabel.textColor = .habDestructive
        } else if let helperText {
            bottomLabel.isHidden = false
            bottomLabel.text = helperText
            bottomLabel.textColor = .habForegroundSecondary
        } else {
            bottomLabel.isHidden = true
        }

        // textView colors
        textView.textColor = .habForeground
        textView.tintColor = .habPrimary
        textView.accessibilityLabel = topLabel
        textView.accessibilityHint = errorText ?? helperText

        // placeholderLabel
        placeholderLabel.textColor = .habForegroundTertiary
        placeholderLabel.font = .habBody

        // disabled state
        if isDisabled {
            alpha = 0.4
            textView.isUserInteractionEnabled = false
        } else {
            alpha = 1
            textView.isUserInteractionEnabled = true
        }

        // derive and apply state-driven border
        deriveState()

        switch currentState {
            case .focused:
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.habPrimary.cgColor
            case .error:
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.habDestructive.cgColor
            case .default, .disabled:
                // already set by style block above; only override for outlined to restore base border
                if style == .outlined {
                    containerView.layer.borderWidth = 1
                    containerView.layer.borderColor = UIColor.habBorder.cgColor
                }
        }

        updatePlaceholder()
    }

    private func updatePlaceholder() {
        let isEmpty = textView.text?.isEmpty ?? true
        placeholderLabel.isHidden = !isEmpty
    }

    private func deriveState() {
        if errorText != nil {
            currentState = .error
        } else if isDisabled {
            currentState = .disabled
        } else if textView.isFirstResponder {
            currentState = .focused
        } else {
            currentState = .default
        }
    }
}

// MARK: - UITextViewDelegate

extension HABTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        currentState = .focused
        updateAppearance()
        delegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        deriveState()
        updateAppearance()
        delegate?.textViewDidEndEditing?(textView)
    }

    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        delegate?.textViewDidChange?(textView)
    }

    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        delegate?.textViewShouldEndEditing?(textView) ?? true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
    }
}

//
//  HABStepper.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A themed stepper: minus and plus buttons in a capsule, with an optional label that
/// updates as the value changes ("Every 2 days").
///
/// ## Overview
///
/// ```swift
/// let interval = HABStepper(
///     value: 2,
///     minimumValue: 1,
///     maximumValue: 30,
///     labelFormatter: { "Every \(Int($0)) days" }
/// ) { newValue in
///     draft.intervalDays = Int(newValue)
/// }
/// interval.accessibilityLabel = "Repeat interval"
/// ```
///
/// Without a `labelFormatter` the stepper shows only its buttons. Like `UIStepper`, holding
/// a button repeats the step, and the control sends `.valueChanged` as well as calling
/// ``onValueChanged``.
///
/// ## VoiceOver
///
/// The stepper is a single adjustable element: swipe up or down to change the value. It
/// reads its accessibility label (set one, or put it in an ``HABFormRow`` with a label),
/// then the formatted value.
///
/// ## Topics
///
/// ### Creating a Stepper
/// - ``init(value:minimumValue:maximumValue:stepValue:labelFormatter:onValueChanged:)``
///
/// ### Value and Range
/// - ``value``
/// - ``minimumValue``
/// - ``maximumValue``
/// - ``stepValue``
/// - ``wraps``
///
/// ### Label
/// - ``labelFormatter``
///
/// ### Responding to Changes
/// - ``onValueChanged``
public final class HABStepper: UIControl {
    // MARK: - Public Properties

    /// The current value, kept within ``minimumValue``...``maximumValue``.
    ///
    /// Setting it doesn't call ``onValueChanged``; only the user's changes do.
    public var value: Double {
        get { storedValue }
        set { storedValue = clamped(newValue); updateState() }
    }

    /// The lowest value. Defaults to `0`.
    public var minimumValue: Double { didSet { storedValue = clamped(storedValue); updateState() } }

    /// The highest value. Defaults to `100`.
    public var maximumValue: Double { didSet { storedValue = clamped(storedValue); updateState() } }

    /// How much one tap changes the value. Defaults to `1`. Must be greater than 0.
    public var stepValue: Double {
        didSet { if stepValue <= 0 { stepValue = oldValue } }
    }

    /// Whether stepping past one end wraps around to the other. Defaults to `false`.
    public var wraps = false { didSet { updateState() } }

    /// Turns the value into the label text, e.g. `{ "Every \(Int($0)) days" }`.
    /// `nil` hides the label.
    public var labelFormatter: ((Double) -> String)? { didSet { updateState() } }

    /// Called with the new value when the user changes it.
    public var onValueChanged: ((Double) -> Void)?

    public override var isEnabled: Bool {
        didSet { updateState() }
    }

    // MARK: - Private

    private var storedValue: Double
    private let valueLabel = UILabel()
    private let buttonsContainer = UIView()
    private let decrementButton = HABMinimumHitAreaButton(type: .system)
    private let incrementButton = HABMinimumHitAreaButton(type: .system)
    private let separator = UIView()
    private let stack = UIStackView()

    private var repeatTimer: Timer?

    private static let buttonSize = CGSize(width: 44, height: 32)
    private static let repeatDelay: TimeInterval = 0.5
    private static let repeatInterval: TimeInterval = 0.1

    // MARK: - Init

    /// Creates a stepper.
    ///
    /// - Parameters:
    ///   - value: The starting value. Defaults to `0`.
    ///   - minimumValue: The lowest value. Defaults to `0`.
    ///   - maximumValue: The highest value. Defaults to `100`.
    ///   - stepValue: How much one tap changes the value. Defaults to `1`.
    ///   - labelFormatter: Builds the label from the value; `nil` shows no label.
    ///   - onValueChanged: Called when the user changes the value.
    public init(
        value: Double = 0,
        minimumValue: Double = 0,
        maximumValue: Double = 100,
        stepValue: Double = 1,
        labelFormatter: ((Double) -> String)? = nil,
        onValueChanged: ((Double) -> Void)? = nil
    ) {
        self.minimumValue = minimumValue
        self.maximumValue = max(minimumValue, maximumValue)
        self.stepValue = stepValue > 0 ? stepValue : 1
        self.storedValue = min(max(value, minimumValue), max(minimumValue, maximumValue))
        self.labelFormatter = labelFormatter
        self.onValueChanged = onValueChanged
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        updateAppearance()
        updateState()

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

    // MARK: - Setup

    private func setupViews() {
        valueLabel.numberOfLines = 0
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.isAccessibilityElement = false
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let symbolConfig = UIImage.SymbolConfiguration(textStyle: .body)
            .applying(UIImage.SymbolConfiguration(weight: .semibold))
        decrementButton.setImage(UIImage(systemName: "minus", withConfiguration: symbolConfig), for: .normal)
        incrementButton.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig), for: .normal)

        for button in [decrementButton, incrementButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isAccessibilityElement = false
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            buttonsContainer.addSubview(button)
        }

        separator.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(separator)
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.clipsToBounds = true
        buttonsContainer.setContentHuggingPriority(.required, for: .horizontal)
        buttonsContainer.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            decrementButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            decrementButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            decrementButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            decrementButton.widthAnchor.constraint(equalToConstant: Self.buttonSize.width),
            decrementButton.heightAnchor.constraint(equalToConstant: Self.buttonSize.height),

            separator.leadingAnchor.constraint(equalTo: decrementButton.trailingAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            separator.heightAnchor.constraint(equalTo: buttonsContainer.heightAnchor, multiplier: 0.5),

            incrementButton.leadingAnchor.constraint(equalTo: separator.trailingAnchor),
            incrementButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            incrementButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            incrementButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            incrementButton.widthAnchor.constraint(equalToConstant: Self.buttonSize.width)
        ])

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = HABSpacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(buttonsContainer)
        addSubview(stack)
        stack.pinToSuperview()

        isAccessibilityElement = true
    }

    // MARK: - Hit testing

    /// The buttons are 32pt tall; accept touches in their 44pt areas that fall outside the stepper.
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) { return true }
        return [decrementButton, incrementButton].contains {
            $0.point(inside: convert(point, to: $0), with: event)
        }
    }

    // MARK: - Stepping

    private func clamped(_ newValue: Double) -> Double {
        min(max(newValue, minimumValue), maximumValue)
    }

    private var canDecrement: Bool { wraps || storedValue > minimumValue }
    private var canIncrement: Bool { wraps || storedValue < maximumValue }

    /// Moves the value one step. Returns `false` if it couldn't move.
    @discardableResult
    private func step(by direction: Double) -> Bool {
        var newValue = storedValue + direction * stepValue
        if newValue > maximumValue {
            guard wraps else { return false }
            newValue = minimumValue
        } else if newValue < minimumValue {
            guard wraps else { return false }
            newValue = maximumValue
        }
        guard newValue != storedValue else { return false }
        storedValue = newValue
        updateState()
        sendActions(for: .valueChanged)
        onValueChanged?(storedValue)
        return true
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        let direction: Double = sender === incrementButton ? 1 : -1
        step(by: direction)
        stopRepeating()
        // Holding the button keeps stepping, like UIStepper.
        repeatTimer = Timer.scheduledTimer(withTimeInterval: Self.repeatDelay, repeats: false) { [weak self] _ in
            self?.startRepeating(direction: direction)
        }
    }

    private func startRepeating(direction: Double) {
        repeatTimer = Timer.scheduledTimer(withTimeInterval: Self.repeatInterval, repeats: true) { [weak self] timer in
            guard let self, self.step(by: direction) else {
                timer.invalidate()
                return
            }
        }
    }

    @objc private func buttonTouchEnded() {
        stopRepeating()
    }

    private func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { stopRepeating() }
    }

    // MARK: - Appearance

    private func updateAppearance() {
        valueLabel.font = .habBody
        buttonsContainer.backgroundColor = .habPrimary.withAlphaComponent(0.12)
        buttonsContainer.layer.cornerRadius = habTheme.radius.sm
        separator.backgroundColor = .habPrimary.withAlphaComponent(0.24)
    }

    private func updateState() {
        let text = labelFormatter?(storedValue)
        valueLabel.text = text
        valueLabel.isHidden = text == nil
        valueLabel.textColor = isEnabled ? .habForeground : .habForegroundDisabled

        decrementButton.isEnabled = isEnabled && canDecrement
        incrementButton.isEnabled = isEnabled && canIncrement
        decrementButton.tintColor = decrementButton.isEnabled ? .habPrimary : .habForegroundDisabled
        incrementButton.tintColor = incrementButton.isEnabled ? .habPrimary : .habForegroundDisabled

        accessibilityTraits = isEnabled ? .adjustable : [.adjustable, .notEnabled]
    }

    // MARK: - Accessibility

    public override var accessibilityValue: String? {
        get { labelFormatter?(storedValue) ?? storedValue.formatted() }
        set { super.accessibilityValue = newValue }
    }

    public override func accessibilityIncrement() {
        guard isEnabled else { return }
        step(by: 1)
    }

    public override func accessibilityDecrement() {
        guard isEnabled else { return }
        step(by: -1)
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}

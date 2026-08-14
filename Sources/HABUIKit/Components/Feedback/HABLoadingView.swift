//
//  HABLoadingView.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

public final class HABLoadingView: UIView {
    // MARK: - Style

    public enum Style: Equatable {
        case spinner
        case linear
        case customSpinner
        case customLinear
        case customAnimation(UIImage?)
        
        public static func == (lhs: Style, rhs: Style) -> Bool {
            switch (lhs, rhs) {
                case (.spinner, .spinner),
                    (.linear, .linear),
                    (.customSpinner, .customSpinner),
                    (.customLinear, .customLinear):
                    return true
                case (.customAnimation(let lhsImage), .customAnimation(let rhsImage)):
                    // Compare UIImage instances by reference
                    return lhsImage === rhsImage
                default:
                    return false
            }
        }
    }

    // MARK: - Public Properties

    public var style: Style { didSet { updateAppearance() } }

    public var message: String? {
        didSet {
            updateAppearance()
            updateAccessibility()
        }
    }

    public var progress: Float? {
        didSet {
            updateProgress()
            updateAccessibility()
        }
    }
    
    /// Customize the appearance of the custom spinner.
    /// Only applicable when style is `.customSpinner`.
    public var customSpinnerColor: UIColor? {
        didSet {
            customSpinner.customColor = customSpinnerColor
        }
    }
    
    /// Customize the line width of the custom spinner.
    /// Only applicable when style is `.customSpinner`.
    public var customSpinnerLineWidth: CGFloat = 3 {
        didSet {
            customSpinner.lineWidth = customSpinnerLineWidth
        }
    }
    
    /// Customize the size of the animated image or custom spinner.
    /// Default is 60x60 for animated images, 40x40 for custom spinner.
    public var spinnerSize: CGSize? {
        didSet {
            updateSpinnerSize()
        }
    }
    
    /// Customize the progress color for the custom linear progress view.
    /// Only applicable when style is `.customLinear`.
    public var customProgressColor: UIColor? {
        didSet {
            customProgressView.customProgressColor = customProgressColor
        }
    }
    
    /// Customize the track color for the custom linear progress view.
    /// Only applicable when style is `.customLinear`.
    public var customTrackColor: UIColor? {
        didSet {
            customProgressView.customTrackColor = customTrackColor
        }
    }
    
    /// Customize the corner radius for the custom linear progress view.
    /// Only applicable when style is `.customLinear`. Default is 4.
    public var customProgressCornerRadius: CGFloat = 4 {
        didSet {
            customProgressView.cornerRadius = customProgressCornerRadius
        }
    }
    
    /// Customize the height for the custom linear progress view.
    /// Only applicable when style is `.customLinear`. Default is 8.
    public var customProgressHeight: CGFloat = 8 {
        didSet {
            updateProgressHeight()
        }
    }

    // MARK: - Private Subviews

    private let indicatorContainerView = UIView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let customSpinner = HABCustomSpinnerView()
    private let animatedImageView = UIImageView()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let customProgressView = HABCustomProgressView()
    private let messageLabel = UILabel()
    
    // Constraint references for dynamic sizing
    private var customSpinnerWidthConstraint: NSLayoutConstraint!
    private var customSpinnerHeightConstraint: NSLayoutConstraint!
    private var animatedImageWidthConstraint: NSLayoutConstraint!
    private var animatedImageHeightConstraint: NSLayoutConstraint!
    private var customProgressHeightConstraint: NSLayoutConstraint!
    
    // Track active indicator constraints so we can remove them when style changes
    private var activeIndicatorConstraints: [NSLayoutConstraint] = []

    // MARK: - Init

    public init(style: Style = .spinner, message: String? = nil) {
        self.style = style
        self.message = message
        super.init(frame: .zero)
        setupViews()
        updateAppearance()
        updateAccessibility()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    private func setupViews() {
        indicatorContainerView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        customSpinner.translatesAutoresizingMaskIntoConstraints = false
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        customProgressView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        animatedImageView.contentMode = .scaleAspectFit
        
        // Add all indicators to the container
        indicatorContainerView.addSubview(spinner)
        indicatorContainerView.addSubview(customSpinner)
        indicatorContainerView.addSubview(animatedImageView)
        indicatorContainerView.addSubview(progressView)
        indicatorContainerView.addSubview(customProgressView)
        
        // Add container and message label to main view
        addSubview(indicatorContainerView)
        addSubview(messageLabel)
        
        let gap = CGFloat(HABSpacing.sm)
        
        NSLayoutConstraint.activate([
            // Container view at the top
            indicatorContainerView.topAnchor.constraint(equalTo: topAnchor),
            indicatorContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicatorContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Message label: below the container
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor
            ),
            messageLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor
            ),
            messageLabel.topAnchor.constraint(
                equalTo: indicatorContainerView.bottomAnchor,
                constant: gap
            ),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Create size constraints but don't activate them yet
        customSpinnerWidthConstraint = customSpinner.widthAnchor.constraint(equalToConstant: 40)
        customSpinnerHeightConstraint = customSpinner.heightAnchor.constraint(equalToConstant: 40)
        
        animatedImageWidthConstraint = animatedImageView.widthAnchor.constraint(equalToConstant: 60)
        animatedImageHeightConstraint = animatedImageView.heightAnchor.constraint(equalToConstant: 60)
        
        customProgressHeightConstraint = customProgressView.heightAnchor.constraint(equalToConstant: 8)
        
        // Set up initial indicator constraints
        updateIndicatorConstraints()
    }
    
    // MARK: - Constraint Management
    
    private func updateIndicatorConstraints() {
        // Remove old constraints
        NSLayoutConstraint.deactivate(activeIndicatorConstraints)
        activeIndicatorConstraints.removeAll()
        
        // Add new constraints based on current style
        switch style {
            case .spinner:
                activeIndicatorConstraints = centeredConstraints(for: spinner)
            case .linear:
                activeIndicatorConstraints = fullWidthConstraints(for: progressView)
            case .customSpinner:
                activeIndicatorConstraints = centeredConstraints(for: customSpinner)
            case .customLinear:
                activeIndicatorConstraints = fullWidthConstraints(for: customProgressView, height: customProgressHeightConstraint)
            case .customAnimation:
                activeIndicatorConstraints = centeredConstraints(for: animatedImageView)
        }
        
        // Activate new constraints
        NSLayoutConstraint.activate(activeIndicatorConstraints)
    }
    
    private func centeredConstraints(for view: UIView) -> [NSLayoutConstraint] {
        [
            view.centerXAnchor.constraint(equalTo: indicatorContainerView.centerXAnchor),
            view.topAnchor.constraint(equalTo: indicatorContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: indicatorContainerView.bottomAnchor)
        ]
    }
    
    private func fullWidthConstraints(for view: UIView, height: NSLayoutConstraint? = nil) -> [NSLayoutConstraint] {
        var constraints = [
            view.leadingAnchor.constraint(equalTo: indicatorContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: indicatorContainerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: indicatorContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: indicatorContainerView.bottomAnchor)
        ]
        
        if let height {
            constraints.insert(height, at: 3) // Insert before bottom anchor
        }
        
        return constraints
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // Update indicator constraints for current style
        updateIndicatorConstraints()
        
        // Determine which view to show based on style
        var animatedImage: UIImage?
        if case .customAnimation(let image) = style {
            animatedImage = image
        }

        // Hide/show appropriate views based on current style
        updateViewVisibility(for: style, animatedImage: animatedImage)
        
        // Update message label
        messageLabel.isHidden = (message == nil)
        messageLabel.text = message
        messageLabel.font = .habFootnote
        messageLabel.textColor = .habForegroundSecondary
        messageLabel.textAlignment = .center

        // Update colors for all views
        updateColors()

        // Update sizes for custom spinner and animated image
        updateSpinnerSize()

        // Start/stop animations based on style
        updateAnimations(for: style, animatedImage: animatedImage)
    }
    
    private func updateViewVisibility(for style: Style, animatedImage: UIImage?) {
        spinner.isHidden = (style != .spinner)
        customSpinner.isHidden = (style != .customSpinner)
        animatedImageView.isHidden = (animatedImage == nil)
        progressView.isHidden = (style != .linear)
        customProgressView.isHidden = (style != .customLinear)
    }
    
    private func updateColors() {
        // Standard spinner/progress styling
        spinner.color = .habPrimary
        progressView.progressTintColor = .habPrimary
        progressView.trackTintColor = .habBorder

        // Custom views update their own colors via theme manager
        customSpinner.updateColors()
        customProgressView.updateColors()
    }
    
    private func updateAnimations(for style: Style, animatedImage: UIImage?) {
        // Stop all animations first
        spinner.stopAnimating()
        customSpinner.stopAnimating()
        animatedImageView.stopAnimating()
        
        // Start the appropriate animation
        switch style {
            case .spinner:
                spinner.startAnimating()
            case .customSpinner:
                customSpinner.startAnimating()
            case .customAnimation where animatedImage != nil:
                configureAnimatedImage(animatedImage!)
                animatedImageView.startAnimating()
            case .linear, .customLinear:
                updateProgress()
            default:
                break
        }
    }
    
    private func configureAnimatedImage(_ image: UIImage) {
        animatedImageView.image = image
        // For animated images, also set animation properties if they exist
        if let images = image.images, !images.isEmpty {
            animatedImageView.animationImages = images
            animatedImageView.animationDuration = image.duration
            animatedImageView.animationRepeatCount = 0 // Infinite loop
        }
    }

    // MARK: - Progress

    private func updateProgress() {
        guard style == .linear || style == .customLinear else { return }
        if let progress {
            if style == .linear {
                progressView.setProgress(progress, animated: true)
            } else {
                customProgressView.setProgress(progress, animated: true)
            }
        } else {
            if style == .linear {
                progressView.progress = 0
            } else {
                customProgressView.progress = 0
            }
        }
    }

    // MARK: - Accessibility

    private func updateAccessibility() {
        accessibilityLabel = message ?? "Loading"
        accessibilityTraits = .updatesFrequently
        if let progress {
            accessibilityValue = "\(Int(progress * 100)) percent"
        } else {
            accessibilityValue = nil
        }
    }

    // MARK: - Theme

    @objc private func themeDidChange() { updateAppearance() }
}

// MARK: - Size Management Helpers

private extension HABLoadingView {
    func updateProgressHeight() {
        customProgressHeightConstraint.constant = customProgressHeight
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateSpinnerSize() {
        // First, deactivate all size constraints
        customSpinnerWidthConstraint.isActive = false
        customSpinnerHeightConstraint.isActive = false
        animatedImageWidthConstraint.isActive = false
        animatedImageHeightConstraint.isActive = false
        
        // Determine the effective size and update constraints
        guard let effectiveSize = effectiveSizeForCurrentStyle() else { return }
        
        // Update constraint constants
        customSpinnerWidthConstraint.constant = effectiveSize.width
        customSpinnerHeightConstraint.constant = effectiveSize.height
        animatedImageWidthConstraint.constant = effectiveSize.width
        animatedImageHeightConstraint.constant = effectiveSize.height
        
        // Activate the appropriate constraints for the current style
        activateSizeConstraints(for: style)
        
        // Trigger layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func effectiveSizeForCurrentStyle() -> CGSize? {
        if let spinnerSize {
            return spinnerSize
        }
        
        // Default sizes based on style
        switch style {
            case .customSpinner:
                return CGSize(width: 40, height: 40)
            case .customAnimation:
                return CGSize(width: 60, height: 60)
            default:
                return nil
        }
    }
    
    func activateSizeConstraints(for style: Style) {
        switch style {
            case .customSpinner:
                customSpinnerWidthConstraint.isActive = true
                customSpinnerHeightConstraint.isActive = true
            case .customAnimation:
                animatedImageWidthConstraint.isActive = true
                animatedImageHeightConstraint.isActive = true
            default:
                break
        }
    }
}

// MARK: - HABCustomSpinnerView

/// A custom animated spinner with a circular arc design.
private final class HABCustomSpinnerView: UIView {
    private let shapeLayer = CAShapeLayer()
    private var isAnimating = false
    
    /// Custom color for the spinner. If nil, uses the theme primary color.
    var customColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// Line width for the spinner arc. Default is 3.
    var lineWidth: CGFloat = 3 {
        didSet {
            shapeLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayer() {
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    private func updatePath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - shapeLayer.lineWidth / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (3 * CGFloat.pi / 2)

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        shapeLayer.path = path.cgPath
    }

    func updateColors() {
        shapeLayer.strokeColor = (customColor ?? .habPrimary).cgColor
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        isHidden = false

        // Rotation animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)

        layer.add(rotation, forKey: "rotation")
    }

    func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        layer.removeAllAnimations()
    }
}

// MARK: - HABCustomProgressView

/// A custom linear progress view with rounded ends and smooth animation.
private final class HABCustomProgressView: UIView {
    private let trackLayer = CALayer()
    private let progressLayer = CALayer()

    var progress: Float = 0 {
        didSet {
            updateProgress(animated: false)
        }
    }
    
    /// Custom progress color. If nil, uses the theme primary color.
    var customProgressColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// Custom track color. If nil, uses the theme border color.
    var customTrackColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// Corner radius for both track and progress layers. Default is 4.
    var cornerRadius: CGFloat = 4 {
        didSet {
            trackLayer.cornerRadius = cornerRadius
            progressLayer.cornerRadius = cornerRadius
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayers() {
        trackLayer.cornerRadius = cornerRadius
        progressLayer.cornerRadius = cornerRadius

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.frame = bounds
        updateProgress(animated: false)
    }

    func updateColors() {
        trackLayer.backgroundColor = (customTrackColor ?? .habBorder).cgColor
        progressLayer.backgroundColor = (customProgressColor ?? .habPrimary).cgColor
    }

    func setProgress(_ progress: Float, animated: Bool) {
        self.progress = min(max(progress, 0), 1)
        updateProgress(animated: animated)
    }

    private func updateProgress(animated: Bool) {
        let width = bounds.width * CGFloat(progress)
        let targetFrame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: bounds.height
        )

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(HABAnimation.Duration.normal)
            CATransaction.setAnimationTimingFunction(
                HABAnimation.Curve.easeOut.timingFunction
            )
            progressLayer.frame = targetFrame
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.frame = targetFrame
            CATransaction.commit()
        }
    }
}

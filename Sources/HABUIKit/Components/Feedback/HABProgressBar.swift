//
//  HABProgressBar.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A themed bar that shows an exact amount of progress, such as "3 of 4 doses taken".
///
/// Use ``HABLoadingView`` while something is loading; use `HABProgressBar` to show a
/// known fraction.
///
/// ```swift
/// let today = HABProgressBar(progress: 0.75)
/// today.accessibilityLabel = "Today's doses"
/// today.setProgress(1, animated: true)
/// ```
///
/// The bar fills from the leading edge, so it runs right to left in RTL languages.
/// VoiceOver reads its accessibility label followed by the percentage ("Today's doses,
/// 75%"); set `accessibilityValue` to say it another way ("3 of 4 taken").
///
/// ## Topics
///
/// ### Creating a Progress Bar
/// - ``init(progress:tint:)``
///
/// ### Progress
/// - ``progress``
/// - ``setProgress(_:animated:)``
///
/// ### Appearance
/// - ``tint``
/// - ``Tint``
/// - ``barHeight``
public final class HABProgressBar: UIView {
    // MARK: - Types

    /// The fill color.
    public enum Tint {
        case primary
        case success
        case warning
        case destructive
    }

    // MARK: - Public Properties

    /// The fraction complete, from 0 to 1. Values outside that range are clamped.
    public var progress: Float {
        get { storedProgress }
        set { setProgress(newValue, animated: false) }
    }

    /// The fill color. Defaults to `.primary`.
    public var tint: Tint { didSet { updateAppearance() } }

    /// The bar's thickness in points. Defaults to 8.
    public var barHeight: CGFloat = 8 {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }

    // MARK: - Private

    private var storedProgress: Float
    private let fillView = UIView()
    private var customAccessibilityValue: String?

    // MARK: - Init

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - progress: The starting fraction, 0 to 1. Defaults to `0`.
    ///   - tint: The fill color. Defaults to `.primary`.
    public init(progress: Float = 0, tint: Tint = .primary) {
        self.storedProgress = Self.clamp(progress)
        self.tint = tint
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        // Keep the bar at `barHeight` instead of stretching to fill a taller container.
        setContentHuggingPriority(.required, for: .vertical)
        addSubview(fillView)
        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently
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

    // MARK: - Progress

    /// Sets the progress, optionally animating the fill.
    public func setProgress(_ progress: Float, animated: Bool) {
        storedProgress = Self.clamp(progress)
        if animated, window != nil {
            // A progress fill isn't decorative motion, so it animates even with Reduce Motion on.
            UIView.animate(
                withDuration: habTheme.motion.normal,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut],
                animations: { [weak self] in
                    self?.layoutFill()
                }
            )
        } else {
            setNeedsLayout()
        }
    }

    private static func clamp(_ value: Float) -> Float {
        guard value.isFinite else { return 0 }
        return min(max(value, 0), 1)
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: barHeight)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutFill()
    }

    private func layoutFill() {
        let width = bounds.width * CGFloat(storedProgress)
        let x = effectiveUserInterfaceLayoutDirection == .rightToLeft ? bounds.width - width : 0
        fillView.frame = CGRect(x: x, y: 0, width: width, height: bounds.height)
        layer.cornerRadius = bounds.height / 2
        fillView.layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Appearance

    private func updateAppearance() {
        backgroundColor = .habBlend(.habForeground, over: .habBackground, fraction: 0.12)
        switch tint {
            case .primary: fillView.backgroundColor = .habPrimary
            case .success: fillView.backgroundColor = .habSuccess
            case .warning: fillView.backgroundColor = .habWarning
            case .destructive: fillView.backgroundColor = .habDestructive
        }
    }

    // MARK: - Accessibility

    public override var accessibilityValue: String? {
        get { customAccessibilityValue ?? HABStrings.percent(storedProgress) }
        set { customAccessibilityValue = newValue }
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}

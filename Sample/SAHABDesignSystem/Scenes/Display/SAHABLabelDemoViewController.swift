//
//  SAHABLabelDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABLabelDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let label = HABLabel(textStyle: .body)

    // The sample string is split so the middle span can have independent attributes.
    private let prefix = "The "
    private let span   = "quick brown fox"
    private let suffix = " jumps over the lazy dog."

    private var fullText: String { prefix + span + suffix }

    // MARK: - Mode

    private enum Mode { case plain, styled, attributed }
    private var mode: Mode = .plain

    // MARK: - Attributed String State

    private var spanColor: UIColor = .habForeground
    private var spanBold = false
    private var spanItalic = false
    private var spanUnderline = false
    private var spanStrikethrough = false

    // MARK: - Setup

    override func setupComponent() {
        super.setupComponent()
        title = "HABLabel"

        label.text = fullText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        previewPanel.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            label.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md),
            label.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        super.setupSettings()

        // MARK: Style

        addSectionHeader("Style")

        addRow(label: "Text Style", control: makeSegmented(
            items: ["Body", "Head", "Title", "Cap"],
            selectedIndex: 0
        ) { [weak self] index in
            let styles: [HABTypographyKey] = [.body, .headline, .title2, .caption1]
            self?.label.textStyle = styles[index]
            self?.applyCurrentMode()
        })

        addRow(label: "Mode", control: makeSegmented(
            items: ["Plain", "Styled", "Attr"],
            selectedIndex: 0
        ) { [weak self] index in
            self?.mode = [Mode.plain, .styled, .attributed][index]
            self?.applyCurrentMode()
        })

        // MARK: Content

        addSectionHeader("Content")

        addRow(label: "Lines", control: makeSegmented(
            items: ["Auto", "1", "2"],
            selectedIndex: 0
        ) { [weak self] index in
            self?.label.numberOfLines = [0, 1, 2][index]
        })

        addRow(label: "Alignment", control: makeSegmented(
            items: ["Left", "Ctr", "Right"],
            selectedIndex: 1
        ) { [weak self] index in
            self?.label.textAlignment = [.left, .center, .right][index]
        })

        // MARK: Attributes

        addSectionHeader("Attributes — \"quick brown fox\"")

        addRow(label: "Color", control: makeSegmented(
            items: ["Default", "Primary", "Success", "Warn", "Error"],
            selectedIndex: 0
        ) { [weak self] index in
            let colors: [UIColor] = [.habForeground, .habPrimary, .habSuccess, .habWarning, .habDestructive]
            self?.spanColor = colors[index]
            self?.applyAttributedIfActive()
        })

        addRow(label: "Bold", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.spanBold = isOn
            self?.applyAttributedIfActive()
        })

        addRow(label: "Italic", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.spanItalic = isOn
            self?.applyAttributedIfActive()
        })

        addRow(label: "Underline", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.spanUnderline = isOn
            self?.applyAttributedIfActive()
        })

        addRow(label: "Strikethrough", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.spanStrikethrough = isOn
            self?.applyAttributedIfActive()
        })
    }

    // MARK: - Mode Application

    private func applyCurrentMode() {
        switch mode {
            case .plain:
                label.text = fullText
            case .styled:
                label.styledText = fullText
            case .attributed:
                applyAttributed()
        }
    }

    private func applyAttributedIfActive() {
        guard mode == .attributed else { return }
        applyAttributed()
    }

    // MARK: - Attributed String Builder

    private func applyAttributed() {
        let baseFont = label.font ?? UIFont.habBody

        let string = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: baseFont,
                .foregroundColor: UIColor.habForeground
            ]
        )

        let spanRange = NSRange(location: prefix.count, length: span.count)

        // Color
        string.addAttribute(.foregroundColor, value: spanColor, range: spanRange)

        // Bold / Italic — compose symbolic traits on the base descriptor
        var traits = UIFontDescriptor.SymbolicTraits()
        if spanBold { traits.insert(.traitBold) }
        if spanItalic { traits.insert(.traitItalic) }
        if !traits.isEmpty,
           let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
            string.addAttribute(.font, value: UIFont(descriptor: descriptor, size: 0), range: spanRange)
        }

        // Underline
        if spanUnderline {
            string.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: spanRange)
        }

        // Strikethrough
        if spanStrikethrough {
            string.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: spanRange)
        }

        label.attributedText = string
    }
}

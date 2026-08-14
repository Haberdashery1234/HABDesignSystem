//
//  HABLoadingViewDemoViewController.swift
//  HABUIKitSample
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class HABLoadingViewDemoViewController: ComponentDemoViewController {
    // MARK: - Component

    private let loadingView = HABLoadingView(style: .spinner, message: "Loading…")
    
    // Keep track of current style for segmented control
    private var currentStyleIndex = 0
    
    // Store animated image for custom animation demo
    private var sampleAnimatedImage: UIImage?

    // MARK: - setupComponent

    override func setupComponent() {
        self.title = "HABLoadingView"
        setPreviewHeight(200)
        
        // Load animated image from assets
        sampleAnimatedImage = loadAnimatedImage(named: "SampleAnimatedLoading")

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.lg),
            loadingView.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.lg),
            loadingView.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    // MARK: - setupSettings

    override func setupSettings() {
        addSectionHeader("Appearance")
        addRow(label: "Style", control: makeSegmented(
            items: ["Spinner", "Linear", "Custom S", "Custom L", "Animated"],
            selectedIndex: currentStyleIndex
        ) { [weak self] index in
            guard let self else { return }
            self.currentStyleIndex = index
            switch index {
            case 0:
                self.loadingView.style = .spinner
            case 1:
                self.loadingView.style = .linear
            case 2:
                self.loadingView.style = .customSpinner
            case 3:
                self.loadingView.style = .customLinear
            case 4:
                self.loadingView.style = .customAnimation(self.sampleAnimatedImage)
            default:
                break
            }
            // Rebuild dynamic settings for new style
            self.rebuildDynamicSettings()
        })

        addSectionHeader("Options")
        addRow(label: "Message", control: makeSwitch(isOn: loadingView.message != nil) { [weak self] isOn in
            guard let self else { return }
            self.loadingView.message = isOn ? "Loading…" : nil
        })
        
        // Build initial dynamic settings
        buildDynamicSettings()
    }
    
    // MARK: - Helper Methods
    
    private func rebuildDynamicSettings() {
        // Remove all existing dynamic views using parent class method
        removeDynamicSettings()
        dynamicSettingViews.removeAll()
        
        // Build new dynamic settings
        buildDynamicSettings()
        
        // Update theme colors for new views
        themeDidChange()
    }
    
    private func buildDynamicSettings() {
        // Progress row (only for linear styles)
        if currentStyleIndex == 1 || currentStyleIndex == 3 {
            let stepper = makeStepper(
                value: Double((loadingView.progress ?? 0) * 100),
                min: 0,
                max: 100,
                step: 5,
                format: { "\(Int($0))%" },
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.loadingView.progress = Float(value) / 100
                }
            )
            let beforeCount = settingsStackViewCount()
            addRow(label: "Progress", control: stepper)
            let newViews = settingsStackViews(from: beforeCount)
            dynamicSettingViews.append(contentsOf: newViews)
        }
        
        // Custom Spinner Settings (only when custom spinner is selected)
        if currentStyleIndex == 2 {
            let lineWidthStepper = makeStepper(
                value: Double(loadingView.customSpinnerLineWidth),
                min: 1,
                max: 8,
                step: 1,
                format: { "\(Int($0))pt" },
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.loadingView.customSpinnerLineWidth = value
                }
            )
            let beforeCount1 = settingsStackViewCount()
            addRow(label: "Line Width", control: lineWidthStepper)
            let newViews1 = settingsStackViews(from: beforeCount1)
            dynamicSettingViews.append(contentsOf: newViews1)
            
            let sizeStepper = makeStepper(
                value: Double(loadingView.spinnerSize?.width ?? 40),
                min: 20,
                max: 100,
                step: 10,
                format: { "\(Int($0))×\(Int($0))" },
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.loadingView.spinnerSize = CGSize(width: value, height: value)
                }
            )
            let beforeCount2 = settingsStackViewCount()
            addRow(label: "Size", control: sizeStepper)
            let newViews2 = settingsStackViews(from: beforeCount2)
            dynamicSettingViews.append(contentsOf: newViews2)
            
            let colorSegmented = makeSegmented(
                items: ["Theme", "Purple", "Orange", "Green"]
            ) { [weak self] index in
                guard let self else { return }
                let colors: [UIColor?] = [nil, .systemPurple, .systemOrange, .systemGreen]
                self.loadingView.customSpinnerColor = colors[index]
            }
            let beforeCount3 = settingsStackViewCount()
            addRow(label: "Color", control: colorSegmented)
            let newViews3 = settingsStackViews(from: beforeCount3)
            dynamicSettingViews.append(contentsOf: newViews3)
        }
        
        // Custom Linear Progress Settings (only when custom linear is selected)
        if currentStyleIndex == 3 {
            let heightStepper = makeStepper(
                value: Double(loadingView.customProgressHeight),
                min: 2,
                max: 20,
                step: 2,
                format: { "\(Int($0))pt" },
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.loadingView.customProgressHeight = value
                }
            )
            let beforeCount1 = settingsStackViewCount()
            addRow(label: "Height", control: heightStepper)
            let newViews1 = settingsStackViews(from: beforeCount1)
            dynamicSettingViews.append(contentsOf: newViews1)
            
            let progressColorSegmented = makeSegmented(
                items: ["Theme", "Green", "Blue", "Orange"]
            ) { [weak self] index in
                guard let self else { return }
                let colors: [UIColor?] = [nil, .systemGreen, .systemBlue, .systemOrange]
                self.loadingView.customProgressColor = colors[index]
            }
            let beforeCount2 = settingsStackViewCount()
            addRow(label: "Progress Color", control: progressColorSegmented)
            let newViews2 = settingsStackViews(from: beforeCount2)
            dynamicSettingViews.append(contentsOf: newViews2)
            
            let trackColorSegmented = makeSegmented(
                items: ["Theme", "Gray 5", "Gray 6", "Gray 4"]
            ) { [weak self] index in
                guard let self else { return }
                let colors: [UIColor?] = [nil, .systemGray5, .systemGray6, .systemGray4]
                self.loadingView.customTrackColor = colors[index]
            }
            let beforeCount3 = settingsStackViewCount()
            addRow(label: "Track Color", control: trackColorSegmented)
            let newViews3 = settingsStackViews(from: beforeCount3)
            dynamicSettingViews.append(contentsOf: newViews3)
            
            let cornerRadiusStepper = makeStepper(
                value: Double(loadingView.customProgressCornerRadius),
                min: 0,
                max: 12,
                step: 2,
                format: { "\(Int($0))pt" },
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.loadingView.customProgressCornerRadius = value
                }
            )
            let beforeCount4 = settingsStackViewCount()
            addRow(label: "Corner Radius", control: cornerRadiusStepper)
            let newViews4 = settingsStackViews(from: beforeCount4)
            dynamicSettingViews.append(contentsOf: newViews4)
        }
        
        // Animation Settings (only when animation is selected)
        if currentStyleIndex == 4 {
            let sizeStepper = makeStepper(
                value: Double(loadingView.spinnerSize?.width ?? 60),
                min: 30,
                max: 120,
                step: 10,
                format: { "\(Int($0))×\(Int($0))" },
                onChange: { [weak self] value in
                    guard let self else { return }
                    self.loadingView.spinnerSize = CGSize(width: value, height: value)
                }
            )
            let beforeCount = settingsStackViewCount()
            addRow(label: "Size", control: sizeStepper)
            let newViews = settingsStackViews(from: beforeCount)
            dynamicSettingViews.append(contentsOf: newViews)
        }
    }
    
    // MARK: - Image Loading
    
    /// Loads an animated GIF from the bundle and converts it to an animated UIImage.
    /// - Parameter named: The name of the GIF file (without extension)
    /// - Returns: An animated UIImage if successful, nil otherwise
    private func loadAnimatedImage(named: String) -> UIImage? {
        // Try to find the GIF in the bundle with .gif extension
        guard let gifURL = Bundle.main.url(forResource: named, withExtension: "gif") else {
            return nil
        }
        
        print("📁 Found GIF at: \(gifURL.lastPathComponent)")
        
        // Load the GIF data
        guard let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(source)
        
        guard frameCount > 0 else {
            return nil
        }
        
        // Extract all frames and their durations
        var images: [UIImage] = []
        var totalDuration: TimeInterval = 0
        
        for i in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            // Get frame duration from GIF properties
            var frameDuration: TimeInterval = 0.1 // Default 100ms
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                // Try unclamped delay time first, then regular delay time
                if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval, delayTime > 0 {
                    frameDuration = delayTime
                } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
                    frameDuration = delayTime
                }
            }
            
            totalDuration += frameDuration
            images.append(UIImage(cgImage: cgImage))
        }
        
        // Create animated image
        if frameCount == 1 {
            return images.first
        }
        
        let animatedImage = UIImage.animatedImage(with: images, duration: totalDuration)
        return animatedImage
    }
}

//
//  HABListCellTests.swift
//  HABUIKitTests
//
//  Tests for HABListCell.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABListCellTests: XCTestCase {
    // MARK: - Defaults

    func testDefaults() {
        let cell = HABListCell()
        XCTAssertNil(cell.title)
        XCTAssertNil(cell.subtitle)
        XCTAssertNil(cell.value)
        XCTAssertNil(cell.icon)
        XCTAssertEqual(cell.rowStyle, .default)
        XCTAssertTrue(cell.isEnabled)
        XCTAssertEqual(cell.reuseIdentifier, HABListCell.reuseIdentifier)
    }

    func testConfigureSetsEveryProperty() {
        let cell = HABListCell()
        let icon = UIImage(systemName: "bell")
        cell.configure(title: "Notifications", subtitle: "Daily", value: "On", icon: icon, accessory: .chevron)
        XCTAssertEqual(cell.title, "Notifications")
        XCTAssertEqual(cell.subtitle, "Daily")
        XCTAssertEqual(cell.value, "On")
        XCTAssertEqual(cell.icon, icon)
    }

    func testConfigureResetsOmittedParameters() {
        let cell = HABListCell()
        cell.configure(title: "A", subtitle: "B", value: "C", accessory: .checkmark, style: .value)
        cell.configure(title: "D")
        XCTAssertNil(cell.subtitle)
        XCTAssertNil(cell.value)
        XCTAssertEqual(cell.rowStyle, .default)
    }

    // MARK: - Accessibility

    func testAccessibilityLabelJoinsTitleAndSubtitle() {
        let cell = HABListCell()
        cell.configure(title: "Lisinopril", subtitle: "10 mg tablet")
        XCTAssertTrue(cell.isAccessibilityElement)
        XCTAssertEqual(cell.accessibilityLabel, "Lisinopril, 10 mg tablet")
    }

    func testAccessibilityValueIsTheValue() {
        let cell = HABListCell()
        cell.configure(title: "RxNorm Release", value: "03-Aug-2026", style: .value)
        XCTAssertEqual(cell.accessibilityValue, "03-Aug-2026")
    }

    func testCustomAccessoryLabelIsAppendedToValue() {
        let cell = HABListCell()
        cell.configure(title: "Metformin", value: "8:00 AM", accessory: .custom(HABTag(label: "Late")))
        XCTAssertEqual(cell.accessibilityValue, "8:00 AM, Late")
    }

    func testSettingAccessibilityLabelOverridesAndNilRestores() {
        let cell = HABListCell()
        cell.configure(title: "Title")
        cell.accessibilityLabel = "Custom"
        XCTAssertEqual(cell.accessibilityLabel, "Custom")
        cell.accessibilityLabel = nil
        XCTAssertEqual(cell.accessibilityLabel, "Title")
    }

    func testChevronRowIsAButton() {
        let cell = HABListCell()
        cell.configure(title: "Settings", accessory: .chevron)
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertFalse(cell.accessibilityTraits.contains(.selected))
    }

    func testCheckmarkRowIsSelected() {
        let cell = HABListCell()
        cell.configure(title: "Daily", accessory: .checkmark)
        XCTAssertTrue(cell.accessibilityTraits.contains(.selected))
    }

    func testValueRowIsStaticTextAndDoesNotHighlight() {
        let cell = HABListCell()
        cell.configure(title: "Version", value: "1.0", style: .value)
        XCTAssertTrue(cell.accessibilityTraits.contains(.staticText))
        XCTAssertEqual(cell.selectionStyle, .none)
    }

    func testActionRowIsAButton() {
        let cell = HABListCell()
        cell.configure(title: "Delete Medication", style: .action(.destructive))
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertEqual(cell.rowStyle, .action(.destructive))
    }

    func testDisabledRowIsNotEnabledAndIgnoresTouches() {
        let cell = HABListCell()
        cell.configure(title: "Sign Out", style: .action(.primary))
        cell.isEnabled = false
        XCTAssertTrue(cell.accessibilityTraits.contains(.notEnabled))
        XCTAssertFalse(cell.isUserInteractionEnabled)
        XCTAssertEqual(cell.selectionStyle, .none)
    }

    func testControlAccessoryStaysReachable() {
        let cell = HABListCell()
        let toggle = UISwitch()
        cell.configure(title: "Reminders", accessory: .custom(toggle))
        XCTAssertFalse(cell.isAccessibilityElement)
        XCTAssertEqual(toggle.accessibilityLabel, "Reminders")
        XCTAssertTrue(cell.accessibilityElements?.contains { ($0 as? UIView) === toggle } ?? false)
    }

    func testMenuButtonAccessoryGetsTitleAsName() {
        let cell = HABListCell()
        let menu = HABMenuButton(titles: ["Off", "On"], selectedIndex: 0)
        cell.configure(title: "Sound", accessory: .custom(menu))
        XCTAssertEqual(menu.name, "Sound")
    }

    func testCustomAccessoryIsAddedAndRemoved() {
        let cell = HABListCell()
        let tag = HABTag(label: "New")
        cell.configure(title: "Item", accessory: .custom(tag))
        XCTAssertTrue(tag.isDescendant(of: cell))
        cell.configure(title: "Item", accessory: .chevron)
        XCTAssertNil(tag.superview)
    }

    // MARK: - Reuse

    func testPrepareForReuseResetsEverything() {
        let cell = HABListCell()
        cell.configure(title: "A", subtitle: "B", value: "C", accessory: .checkmark, style: .action(.primary))
        cell.isEnabled = false
        cell.accessibilityLabel = "Custom"
        cell.prepareForReuse()
        XCTAssertNil(cell.title)
        XCTAssertNil(cell.accessibilityLabel)
        XCTAssertEqual(cell.rowStyle, .default)
        XCTAssertTrue(cell.isEnabled)
        XCTAssertFalse(cell.accessibilityTraits.contains(.selected))
    }

    // MARK: - Table integration

    func testDequeuesFromATable() {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), style: .insetGrouped)
        table.register(HABListCell.self, forCellReuseIdentifier: HABListCell.reuseIdentifier)
        let cell = table.dequeueReusableCell(withIdentifier: HABListCell.reuseIdentifier)
        XCTAssertTrue(cell is HABListCell)
    }

    func testThemeChangeDoesNotCrash() {
        let cell = HABListCell()
        cell.configure(title: "Title", value: "Value", icon: UIImage(systemName: "star"), accessory: .chevron)
        NotificationCenter.default.post(name: HABThemeManager.themeDidChangeNotification, object: HABThemeManager.shared)
        XCTAssertEqual(cell.title, "Title")
    }
}

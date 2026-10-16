//
//  SAHABListDemoViewController.swift
//  SAHABDesignSystem
//
//  HABListCell styles and accessories, section headers and footers, swipe action
//  styles, the table empty state and the floating action button, on one table.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABListDemoViewController: HABBaseTableViewController {
    // MARK: - Model

    private enum Section: Int, CaseIterable {
        case medications
        case frequency
        case about
        case actions
    }

    private struct Medication {
        var name: String
        var detail: String
        var time: String
        var isLate: Bool
    }

    private let sampleMedications = [
        Medication(name: "Lisinopril", detail: "10 mg tablet", time: "8:00 AM", isLate: false),
        Medication(name: "Metformin", detail: "500 mg tablet", time: "12:00 PM", isLate: true),
        Medication(name: "Atorvastatin", detail: "20 mg tablet", time: "9:00 PM", isLate: false)
    ]
    private lazy var medications = sampleMedications

    private let frequencies = ["Daily", "Weekly", "As needed"]
    private var selectedFrequency = 0
    private var remindersOn = true
    private var signOutEnabled = true

    // MARK: - Init

    init() {
        super.init(style: .insetGrouped)
        // Set here rather than in viewDidLoad: SANavigationController adds its palette
        // button when the screen is shown, which can happen before the view loads.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            primaryAction: UIAction { [weak self] _ in self?.clearEverything() }
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List Cell"
        tableView.register(HABListCell.self, forCellReuseIdentifier: HABListCell.reuseIdentifier)
        tableView.register(
            HABSectionHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: HABSectionHeaderFooterView.reuseIdentifier
        )

        emptyState = HABEmptyState(
            title: "No medications",
            message: "Tap + to add the sample medications back.",
            icon: UIImage(systemName: "pills")
        )
        floatingActionButton = HABFloatingActionButton(
            icon: UIImage(systemName: "plus"),
            action: HABAccessibleAction(label: "Add Sample Medications") { [weak self] in
                self?.restoreMedications()
            }
        )
    }

    // MARK: - Empty state demo

    /// The empty state shows when the table has no rows, so clearing hides every section.
    private var isCleared = false

    func clearEverything() {
        isCleared = true
        tableView.reloadData()
        updateEmptyStateVisibility(animated: true)
    }

    func restoreMedications() {
        isCleared = false
        medications = sampleMedications
        tableView.reloadData()
        updateEmptyStateVisibility(animated: true)
    }

    private var onTimeSummary: String {
        let onTime = medications.filter { !$0.isLate }.count
        return "\(onTime) of \(medications.count) on time"
    }

    // MARK: - Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        isCleared ? 0 : Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
            case .medications: return medications.count
            case .frequency: return frequencies.count + 1
            case .about: return 2
            case .actions: return 2
            case nil: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: HABListCell.reuseIdentifier, for: indexPath) as! HABListCell

        switch Section(rawValue: indexPath.section) {
            case .medications:
                let medication = medications[indexPath.row]
                cell.configure(
                    title: medication.name,
                    subtitle: medication.detail,
                    value: medication.time,
                    icon: UIImage(systemName: "pills"),
                    accessory: medication.isLate
                        ? .custom(HABTag(label: "Late", style: .subtle, color: .warning))
                        : .chevron
                )
                cell.accessibilityIdentifier = "medication.\(indexPath.row)"

            case .frequency:
                if indexPath.row < frequencies.count {
                    cell.configure(
                        title: frequencies[indexPath.row],
                        accessory: indexPath.row == selectedFrequency ? .checkmark : .none
                    )
                } else {
                    let toggle = UISwitch()
                    toggle.isOn = remindersOn
                    toggle.onTintColor = .habPrimary
                    toggle.addAction(UIAction { [weak self, weak toggle] _ in
                        self?.remindersOn = toggle?.isOn ?? false
                    }, for: .valueChanged)
                    cell.configure(title: "Reminders", icon: UIImage(systemName: "bell"), accessory: .custom(toggle))
                }

            case .about:
                if indexPath.row == 0 {
                    cell.configure(title: "RxNorm Release", value: "03-Aug-2026", style: .value)
                } else {
                    cell.configure(title: "Version", value: "0.1.0", style: .value)
                }

            case .actions:
                if indexPath.row == 0 {
                    cell.configure(
                        title: signOutEnabled ? "Disable Sign Out" : "Enable Sign Out",
                        icon: UIImage(systemName: "switch.2"),
                        style: .action(.primary)
                    )
                } else {
                    cell.configure(
                        title: "Sign Out",
                        icon: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                        style: .action(.destructive)
                    )
                    cell.isEnabled = signOutEnabled
                }

            case nil:
                break
        }
        return cell
    }

    // MARK: - Headers and Footers

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HABSectionHeaderFooterView.reuseIdentifier
        ) as? HABSectionHeaderFooterView
        switch Section(rawValue: section) {
            case .medications:
                view?.configure(kind: .header, text: "Today", detail: onTimeSummary)
            case .frequency:
                view?.configure(kind: .header, text: "Frequency")
            case .about:
                view?.configure(kind: .header, text: "About")
            case .actions:
                view?.configure(kind: .header, text: "Account")
            case nil:
                return nil
        }
        return view
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard Section(rawValue: section) == .medications else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HABSectionHeaderFooterView.reuseIdentifier
        ) as? HABSectionHeaderFooterView
        view?.configure(kind: .footer, text: "Swipe a medication left or right for actions. Tap Clear to see the empty state.")
        return view
    }

    // MARK: - Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section) {
            case .frequency where indexPath.row < frequencies.count:
                selectedFrequency = indexPath.row
                tableView.reloadSections([indexPath.section], with: .none)
            case .actions where indexPath.row == 0:
                signOutEnabled.toggle()
                tableView.reloadSections([indexPath.section], with: .none)
            case .actions:
                // The table scrolls; show the toast over the navigation controller instead.
                HABToast.show(message: "Signed out (not really)", style: .info, in: navigationController?.view ?? view)
            default:
                break
        }
    }

    // MARK: - Swipe Actions

    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .medications else { return nil }
        let taken = UIContextualAction.hab(.success, title: "Taken", image: UIImage(systemName: "checkmark")) { _, _, done in
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [taken])
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .medications else { return nil }
        let delete = UIContextualAction.hab(
            .destructive,
            title: "Delete",
            image: UIImage(systemName: "trash"),
            removesRow: true
        ) { [weak self] _, _, done in
            guard let self else { return done(false) }
            self.medications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            let header = tableView.headerView(forSection: Section.medications.rawValue) as? HABSectionHeaderFooterView
            header?.titleView.detail = self.onTimeSummary
            done(true)
        }
        let skip = UIContextualAction.hab(.warning, title: "Skip", image: UIImage(systemName: "forward")) { _, _, done in
            done(true)
        }
        let edit = UIContextualAction.hab(.neutral, title: "Edit", image: UIImage(systemName: "pencil")) { _, _, done in
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete, skip, edit])
    }
}

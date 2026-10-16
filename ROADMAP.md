# HABUIKit Roadmap

Components and API changes identified while migrating PillPal from SwiftUI to HABUIKit.
Each item notes the PillPal code that currently fills the gap, so it can be ported and
then replaced in the app.

## Highest value — used on almost every screen

- [x] **`HABListCell`** — a themed list row
  - [x] Title, optional subtitle, optional trailing value, optional leading icon
  - [x] Accessories: chevron, checkmark, or a custom view (e.g. an `HABTag`)
  - [x] Styles: default, value ("RxNorm Release … 03-Aug-2026"), action (primary or destructive, with a disabled state)
  - [x] Surface background that keeps the highlighted and selected states
  - [x] One consistent way to expose its labels to VoiceOver and UI tests
  - Replaces: `ListStyle` (`subtitleContent`, `valueContent`, `actionContent`, `applyRowBackground`), and the row setup in PillPal's Settings, prescription detail and drug options screens
- [x] **Section header and footer views** — footnote text in the secondary color, with an optional trailing detail ("Today … 3 of 4 taken")
  - Replaces: `ListStyle.headerContent`, `ListStyle.footerContent`, `ListStyle.headerFooterView`
- [x] **Empty state for tables** — e.g. an `emptyState` on `HABBaseTableViewController` with show/hide, instead of wrapping `HABEmptyState` in a background view by hand
  - Replaces: the same container code in six PillPal screens (Dashboard, History, Upcoming, Medications, drug search, drug options)
- [x] **`HABMenuButton`** — a pull-down showing the current value, with a checkmark menu; labeled for VoiceOver as "Name, value"
  - Replaces: `ListStyle.menuButton` and `MenuRow` (Settings pickers; Repeat, Alert and "If a dose is delayed" in the schedule form; Brand and Route in drug options)

## Form building blocks

- [x] **`HABFormSection` / `HABFormRow`** — header, a card of rows, and footer; dividers that follow the visible rows; labeled rows ("Starts … [date]") and full-width rows for toggles and text fields
  - Replaces: `FormSection` and `FormRow` in PillPal's `Views/Shared/FormStyle.swift` (a working first draft built on `HABCard` and `HABDivider`)
- [x] **`HABStepper`** — a themed stepper, optionally with a label that updates as the value changes
  - Replaces: `StepperRow` (eight plain `UIStepper`s in the schedule form)
- [x] **`HABTextField` change callback** — an `onTextChanged` closure (API change to an existing component), so screens can react while the user types
  - Replaces: the form copying text into its drafts on end editing and on Save
- [x] **Multi-select chip group** — e.g. the weekday picker; also suits filters and tags
  - Replaces: `WeekdayPickerView`

## Smaller, but repeated or reusable

- [x] **Progress bar** — a themed bar showing an exact value (`HABLoadingView` is meant for loading)
  - Replaces: the plain `UIProgressView` in the Dashboard's today summary
- [x] **Floating action button** — owns its placement, shadow and minimum tap area, including inside a table view controller where it would otherwise scroll with the rows
  - Replaces: the pinned `HABButton` on the Medications screen
- [x] **Swipe action styles** — a helper for creating swipe actions in success, warning, destructive and neutral styles, with icons
  - Replaces: the per-screen colors in `DoseLogActionBuilder` and the Dashboard and Medications swipe actions
- [x] *(Optional)* **Tinted card with an accent bar** — a tinted background with a colored leading bar; could generalize into a callout or status card
  - Replaces: `TimelineBlockButton` (Day timeline blocks)

## Status

Everything above is implemented in HABUIKit, with unit tests and sample-app demos
(Catalog › Lists & Forms, Callout Card, Progress Bar). Names as shipped:

| Roadmap item | API |
| --- | --- |
| List row | `HABListCell` (`configure(title:subtitle:value:icon:accessory:style:)`, `rowStyle`, `isEnabled`) |
| Section header/footer | `HABSectionTitleView` (plain view) and `HABSectionHeaderFooterView` (table header/footer) |
| Table empty state | `HABBaseTableViewController.emptyState`, `setEmptyStateVisible(_:animated:)`, `updateEmptyStateVisibility(animated:)` |
| Menu button | `HABMenuButton` (`name`, `options`/`titles`, `selectedIndex`, `onSelectionChanged`) |
| Form section/row | `HABFormSection`, `HABFormRow(label:control:)`, `HABFormRow(content:)` |
| Stepper | `HABStepper` (`labelFormatter`, `onValueChanged`, adjustable for VoiceOver) |
| Text field callback | `HABTextField.onTextChanged` (also an `init` parameter) |
| Chip group | `HABChipGroup` (`.multiple`/`.single`, `.wrap`/`.fillEqually`, `itemAccessibilityLabels`) |
| Progress bar | `HABProgressBar` |
| Floating action button | `HABFloatingActionButton`, or `floatingActionButton` on `HABBaseViewController` / `HABBaseTableViewController` |
| Swipe action styles | `UIContextualAction.hab(_:title:image:removesRow:handler:)` with `HABSwipeActionStyle` |
| Tinted card with accent bar | `HABCalloutCard` (`tone`, optional tap `action`) |

Next: port the PillPal screens listed under each "Replaces:" line and delete the app-side helpers.

## Suggested order

1. `HABListCell` and section header/footer views
2. Table empty state and `HABMenuButton`
3. Form pieces: `HABFormSection`/`HABFormRow`, `HABStepper`, the `HABTextField` callback, the chip group
4. The rest as needed

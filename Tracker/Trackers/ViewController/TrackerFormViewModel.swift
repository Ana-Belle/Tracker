//
//  TrackerFormViewModel.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 17.06.2026.
//

import UIKit

struct TrackerEditingContext {
    let tracker: Tracker
    let categoryHeader: String
}

enum TrackerSection: Int, CaseIterable {
    case emoji
    case color
    
    var title: String {
        switch self {
        case .emoji: "Emoji"
        case .color: "Цвет"
        }
    }
}

final class TrackerFormViewModel {
    
    // MARK: - Bindings
    
    var onCategoryButtonTitleUpdated: ((String) -> Void)?
    var onScheduleButtonTitleUpdated: ((String) -> Void)?
    var onCreateButtonStateChanged: ((Bool) -> Void)?
    var onClearTrackerName: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onPresentCategory: ((String?) -> Void)?
    var onPresentSchedule: (([WeekDay]) -> Void)?
    var onReloadCollectionItems: (([IndexPath]) -> Void)?
    var onLogInfo: ((String) -> Void)?
    
    // MARK: - Properties
    
    weak var delegate: TrackerFormViewControllerDelegate?
    
    private let editingContext: TrackerEditingContext?
    private let recordStore: TrackerRecordStore
    
    private(set) var selectedCategoryHeader: String?
    
    private var selectedWeekDays: [WeekDay] = []
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    
    var isEditing: Bool {
        editingContext != nil
    }
    
    var screenTitle: String {
        isEditing ? "Редактирование привычки" : "Новая привычка"
    }
    
    var actionButtonTitle: String {
        isEditing ? "Сохранить" : "Создать"
    }
    
    var initialTrackerName: String? {
        editingContext?.tracker.name
    }
    
    var completedDaysText: String? {
        guard let trackerId = editingContext?.tracker.id else { return nil }
        return pluralizeDays(recordStore.completedDaysCount(for: trackerId))
    }
    
    init(
        editingContext: TrackerEditingContext? = nil,
        recordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.editingContext = editingContext
        self.recordStore = recordStore
        
        if let editingContext {
            selectedCategoryHeader = editingContext.categoryHeader
            selectedWeekDays = editingContext.tracker.schedule
            selectedEmojiIndex = MockData.emojis.firstIndex(of: editingContext.tracker.emoji)
            selectedColorIndex = Self.index(of: editingContext.tracker.color, in: MockData.colors)
        }
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        if let selectedCategoryHeader {
            onCategoryButtonTitleUpdated?(selectedCategoryHeader)
        } else {
            onCategoryButtonTitleUpdated?("")
        }
        
        if selectedWeekDays.isEmpty {
            onScheduleButtonTitleUpdated?("")
        } else {
            onScheduleButtonTitleUpdated?(formatWeekDays(selectedWeekDays))
        }
        
        updateCreateButtonState(trackerName: initialTrackerName ?? "")
    }
    
    // MARK: - Collection View
    
    var numberOfSections: Int {
        TrackerSection.allCases.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        18
    }
    
    func sectionTitle(for section: Int) -> String {
        TrackerSection(rawValue: section)?.title ?? ""
    }
    
    func emoji(at index: Int) -> String {
        MockData.emojis[index]
    }
    
    func color(at index: Int) -> UIColor {
        MockData.colors[index]
    }
    
    func isEmojiSelected(at index: Int) -> Bool {
        selectedEmojiIndex == index
    }
    
    func isColorSelected(at index: Int) -> Bool {
        selectedColorIndex == index
    }
    
    // MARK: - Actions
    
    func textDidChange(_ text: String) {
        updateCreateButtonState(trackerName: text)
    }
    
    func clearTrackerName() {
        onClearTrackerName?()
        updateCreateButtonState(trackerName: "")
    }
    
    func categoryButtonTapped() {
        onPresentCategory?(selectedCategoryHeader)
    }
    
    func scheduleButtonTapped() {
        onPresentSchedule?(selectedWeekDays)
    }
    
    func cancelButtonTapped() {
        onDismiss?()
    }
    
    func createButtonTapped(trackerName: String) {
        guard let selectedCategoryHeader else { return }
        
        let trackerName = trackerName.isEmpty ? "Новый трекер" : trackerName
        let color = selectedColorIndex.map { MockData.colors[$0] } ?? .colorSelection5
        let emoji = selectedEmojiIndex.map { MockData.emojis[$0] } ?? "🌸"
        
        if let editingContext {
            let tracker = Tracker(
                id: editingContext.tracker.id,
                name: trackerName,
                color: color,
                emoji: emoji,
                schedule: selectedWeekDays
            )
            
            delegate?.updateTracker(
                tracker: tracker,
                categoryHeader: selectedCategoryHeader,
                previousCategoryHeader: editingContext.categoryHeader
            )
        } else {
            let tracker = Tracker(
                id: UUID(),
                name: trackerName,
                color: color,
                emoji: emoji,
                schedule: selectedWeekDays
            )
            
            delegate?.addNewTrackerToCategory(tracker: tracker, to: selectedCategoryHeader)
        }
        
        onDismiss?()
    }
    
    func categorySelected(_ header: String, trackerName: String) {
        selectedCategoryHeader = header
        onCategoryButtonTitleUpdated?(header)
        updateCreateButtonState(trackerName: trackerName)
    }
    
    func scheduleSelected(_ weekDays: [WeekDay], trackerName: String) {
        selectedWeekDays = weekDays
        onScheduleButtonTitleUpdated?(formatWeekDays(weekDays))
        onLogInfo?("Selected days: \(weekDays)")
        updateCreateButtonState(trackerName: trackerName)
    }
    
    func selectEmoji(at index: Int, trackerName: String) {
        let previousIndex = selectedEmojiIndex
        selectedEmojiIndex = index
        reloadSelectionItems(
            section: TrackerSection.emoji.rawValue,
            previousIndex: previousIndex,
            newIndex: index
        )
        updateCreateButtonState(trackerName: trackerName)
    }
    
    func selectColor(at index: Int, trackerName: String) {
        let previousIndex = selectedColorIndex
        selectedColorIndex = index
        reloadSelectionItems(
            section: TrackerSection.color.rawValue,
            previousIndex: previousIndex,
            newIndex: index
        )
        updateCreateButtonState(trackerName: trackerName)
    }
    
    // MARK: - Private Methods
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) \(NSLocalizedString("day", comment: ""))"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) \(NSLocalizedString("days2", comment: ""))"
        } else {
            return "\(count) \(NSLocalizedString("days", comment: ""))"
        }
    }
    
    private func updateCreateButtonState(trackerName: String) {
        let hasCategory = !(selectedCategoryHeader?.isEmpty ?? true)
        let isEnabled = !trackerName.isEmpty
        && hasCategory
        && !selectedWeekDays.isEmpty
        && selectedEmojiIndex != nil
        && selectedColorIndex != nil
        
        onCreateButtonStateChanged?(isEnabled)
    }
    
    private func reloadSelectionItems(section: Int, previousIndex: Int?, newIndex: Int) {
        var indexPaths = [IndexPath(item: newIndex, section: section)]
        if let previousIndex, previousIndex != newIndex {
            indexPaths.append(IndexPath(item: previousIndex, section: section))
        }
        onReloadCollectionItems?(indexPaths)
    }
    
    private func formatWeekDays(_ days: [WeekDay]) -> String {
        days.count == 7 ? "Каждый день" : days.map(\.rawValue).joined(separator: ", ")
    }
    
    private static func index(of color: UIColor, in colors: [UIColor]) -> Int? {
        guard let targetComponents = rgbaComponents(from: color) else { return nil }
        
        return colors.firstIndex { candidate in
            guard let candidateComponents = rgbaComponents(from: candidate) else { return false }
            return componentsMatch(targetComponents, candidateComponents)
        }
    }
    
    private static func rgbaComponents(from color: UIColor) -> [CGFloat]? {
        let resolvedColor = color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        return CoreDataValueCodec.encodeColor(resolvedColor) as? [CGFloat]
    }
    
    private static func componentsMatch(
        _ lhs: [CGFloat],
        _ rhs: [CGFloat],
        tolerance: CGFloat = 0.01
    ) -> Bool {
        guard lhs.count == 4, rhs.count == 4 else { return false }
        
        return zip(lhs, rhs).allSatisfy { abs($0 - $1) <= tolerance }
    }
}

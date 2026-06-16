//
//  NewTrackerViewModel.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 17.06.2026.
//

import UIKit

enum NewTrackerSection: Int, CaseIterable {
    case emoji
    case color
    
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .color: return "Цвет"
        }
    }
}

final class NewTrackerViewModel {
    
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
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private(set) var selectedCategoryHeader: String?
    
    private var selectedWeekDays: [WeekDay] = []
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    
    let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    let colors: [UIColor] = [
        .colorSelection1,  .colorSelection2,  .colorSelection3,  .colorSelection4,  .colorSelection5,  .colorSelection6,
        .colorSelection7,  .colorSelection8,  .colorSelection9,  .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        onCategoryButtonTitleUpdated?("")
        onScheduleButtonTitleUpdated?("")
        onCreateButtonStateChanged?(false)
    }
    
    // MARK: - Collection View
    
    var numberOfSections: Int {
        NewTrackerSection.allCases.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        18
    }
    
    func sectionTitle(for section: Int) -> String {
        NewTrackerSection(rawValue: section)?.title ?? ""
    }
    
    func emoji(at index: Int) -> String {
        emojis[index]
    }
    
    func color(at index: Int) -> UIColor {
        colors[index]
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
        
        let tracker = Tracker(
            id: UUID(),
            name: trackerName.isEmpty ? "Новый трекер" : trackerName,
            color: selectedColorIndex.map { colors[$0] } ?? .colorSelection5,
            emoji: selectedEmojiIndex.map { emojis[$0] } ?? "🌸",
            schedule: selectedWeekDays
        )
        
        delegate?.addNewTrackerToCategory(tracker: tracker, to: selectedCategoryHeader)
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
            section: NewTrackerSection.emoji.rawValue,
            previousIndex: previousIndex,
            newIndex: index
        )
        updateCreateButtonState(trackerName: trackerName)
    }
    
    func selectColor(at index: Int, trackerName: String) {
        let previousIndex = selectedColorIndex
        selectedColorIndex = index
        reloadSelectionItems(
            section: NewTrackerSection.color.rawValue,
            previousIndex: previousIndex,
            newIndex: index
        )
        updateCreateButtonState(trackerName: trackerName)
    }
    
    // MARK: - Private Methods
    
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
        if days.count == 7 {
            return "Каждый день"
        }
        return days.map(\.rawValue).joined(separator: ", ")
    }
}

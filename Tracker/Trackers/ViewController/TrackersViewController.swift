//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {

    private var categories: [TrackerCategory] = []

    private let categoryStore = TrackerCategoryStore()
    private lazy var trackerStore = TrackerStore(categoryStore: categoryStore)
    private lazy var recordStore = TrackerRecordStore(trackerStore: trackerStore)

    private lazy var logger = TrackerLogger.shared

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
            .forAutoLayout
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.searchTextField.backgroundColor = .searchBar
        return searchController
    }()

    private lazy var plugLabel: UILabel = {
        let label = UILabel()
            .forAutoLayout
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private lazy var plugImage: UIImageView = {
        let plugImage = UIImageView(image: UIImage(resource: .dizzy))
            .forAutoLayout
        plugImage.contentMode = .scaleAspectFill
        return plugImage
    }()

    private let trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .whiteDay
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }().forAutoLayout

    override func viewDidLoad() {
        super.viewDidLoad()

        categoryStore.delegate = self
        trackerStore.delegate = self
        recordStore.delegate = self

        try? categoryStore.addCategory(header: "Домашний уют")
        categories = categoryStore.categories

        setElements()
        updateContentVisibility()
    }

    private func setElements() {
        view.backgroundColor = .whiteDay

        let plusButton = UIBarButtonItem(image: UIImage(resource: .plusBlack), style: .plain, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .blackDay
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem?.hidesSharedBackground = true
        }

        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteDay
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

    }

    private func setupTrackerCollectionView() {
        view.addSubview(trackerCollectionView)
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 84),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        trackerCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        trackerCollectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )

        trackerCollectionView.dataSource = self
        trackerCollectionView.delegate = self
    }

    private func setPlug() {
        if trackerCollectionView.superview != nil {
            trackerCollectionView.removeFromSuperview()
        }

        plugImage.removeFromSuperview()
        plugLabel.removeFromSuperview()

        view.addSubview(plugImage)
        NSLayoutConstraint.activate([
            plugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            plugImage.heightAnchor.constraint(equalToConstant: 80),
            plugImage.widthAnchor.constraint(equalToConstant: 80)
        ])

        view.addSubview(plugLabel)
        NSLayoutConstraint.activate([
            plugLabel.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func removePlug() {
        plugImage.removeFromSuperview()
        plugLabel.removeFromSuperview()
    }

    private func areAllTrackersEmpty() -> Bool {
        categories.allSatisfy { $0.trackers.isEmpty }
    }

    private func updateContentVisibility() {
        let filteredCategories = getFilteredCategories()
        let hasTrackers = !filteredCategories.isEmpty && filteredCategories.contains { !$0.trackers.isEmpty }

        if hasTrackers {
            if trackerCollectionView.superview == nil {
                removePlug()
                setupTrackerCollectionView()
            }
            trackerCollectionView.reloadData()
        } else {
            if trackerCollectionView.superview != nil {
                trackerCollectionView.removeFromSuperview()
            }
            setPlug()
        }
    }

    private func getFilteredCategories() -> [TrackerCategory] {
        let weekDay = getWeekDay(from: datePicker.date)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: datePicker.date)

        if selectedDate > today {
            return []
        }

        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekDay)
            }

            if !filteredTrackers.isEmpty {
                return TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
            return nil
        }
    }

    private func getWeekDay(from date: Date) -> WeekDay {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        case 1: return .sunday
        default: return .monday
        }
    }

    @objc private func plusButtonTapped() {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.delegate = self
        present(newTrackerVC, animated: true, completion: nil)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        logger.info("Выбранная дата: \(formattedDate)")
        updateContentVisibility()
    }

}

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let filteredCategories = getFilteredCategories()
        return filteredCategories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let filteredCategories = getFilteredCategories()
        return filteredCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        guard let trackerCell = cell as? TrackerCollectionViewCell else {
            return cell
        }

        let filteredCategories = getFilteredCategories()

        guard indexPath.section < filteredCategories.count,
              indexPath.row < filteredCategories[indexPath.section].trackers.count else {
            return cell
        }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

        trackerCell.delegate = self

        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = getCompletedDaysCount(id: tracker.id)
        trackerCell.configure(with: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }

        let filteredCategories = getFilteredCategories()
        header.configure(with: filteredCategories[indexPath.section].header)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

extension TrackersViewController: TrackerCellDelegate {

    private func isTrackerCompletedToday(id: UUID) -> Bool {
        recordStore.isTrackerCompleted(trackerId: id, on: datePicker.date)
    }

    private func getCompletedDaysCount(id: UUID) -> Int {
        recordStore.completedDaysCount(for: id)
    }

    func completeTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try recordStore.addRecord(trackerId: id, date: datePicker.date)
            trackerCollectionView.reloadItems(at: [indexPath])
        } catch {
            logger.error("Не удалось сохранить выполнение трекера: \(error)")
        }
    }

    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try recordStore.deleteRecord(trackerId: id, date: datePicker.date)
            trackerCollectionView.reloadItems(at: [indexPath])
        } catch {
            logger.error("Не удалось удалить выполнение трекера: \(error)")
        }
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    var trackersCount: UInt {
        UInt(trackerStore.trackers.count)
    }

    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String) {
        do {
            try categoryStore.addCategory(header: categoryHeader)
            try trackerStore.addTracker(tracker, toCategoryHeader: categoryHeader)
        } catch {
            logger.error("Не удалось сохранить трекер: \(error)")
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {

    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory]) {
        self.categories = categories
        updateContentVisibility()
    }
}

extension TrackersViewController: TrackerStoreDelegate {

    func trackerStore(_ store: TrackerStore, didUpdate trackers: [Tracker]) {
        categories = categoryStore.categories
        updateContentVisibility()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {

    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord]) {
        guard trackerCollectionView.superview != nil else { return }
        trackerCollectionView.reloadData()
    }
}

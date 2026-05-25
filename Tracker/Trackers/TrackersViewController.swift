//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIds: Set<String> = []
    private var currentDate: Date = Date()

    private lazy var category: TrackerCategory = {
        TrackerCategory(header: "Домашний уют", trackers: [])
    }()

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

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addNewCategory(category)

        setElements()

        if categories.isEmpty || areAllTrackersEmpty() {
            setPlug()
        } else {
            setupCollectionView()
        }
    }

    private func setElements() {
        view.backgroundColor = .whiteDay

        let plusButton = UIBarButtonItem(image: UIImage(resource: .plus), style: .plain, target: self, action: #selector(plusButtonTapped))
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem?.hidesSharedBackground = true
        }

        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 84),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setPlug() {
        if collectionView.superview != nil {
            collectionView.removeFromSuperview()
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

    private func addNewCategory(_ category: TrackerCategory) {
        categories.append(category)
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

    private func createTrackerKey(id: UInt, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return "\(id)_\(dateString)"
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
        print("Выбранная дата: \(formattedDate)")

        let filteredCategories = getFilteredCategories()
        let hasTrackers = !filteredCategories.isEmpty && filteredCategories.contains { !$0.trackers.isEmpty }

        if hasTrackers {
            if collectionView.superview == nil {
                removePlug()
                setupCollectionView()
            }
            collectionView.reloadData()
        } else {
            if collectionView.superview != nil {
                collectionView.removeFromSuperview()
            }
            setPlug()
        }
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

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath
        ) as! SectionHeaderView

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

    private func isTrackerCompletedToday(id: UInt) -> Bool {
        let key = createTrackerKey(id: id, date: datePicker.date)
        return completedTrackerIds.contains(key)
    }

    private func getCompletedDaysCount(id: UInt) -> Int {
        let prefix = "\(id)_"
        return completedTrackerIds.filter { $0.hasPrefix(prefix) }.count
    }

    func completeTracker(id: UInt, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)

        let key = createTrackerKey(id: id, date: datePicker.date)
        completedTrackerIds.insert(key)

        print("Трекер \(id) выполнен на дату \(datePicker.date)")
        collectionView.reloadItems(at: [indexPath])
    }

    func uncompleteTracker(id: UInt, at indexPath: IndexPath) {
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }

        let key = createTrackerKey(id: id, date: datePicker.date)
        completedTrackerIds.remove(key)

        print("Трекер \(id) не выполнен на дату \(datePicker.date)")
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    var trackersCount: UInt {
        UInt(categories.reduce(0) { $0 + $1.trackers.count })
    }

    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String) {

        if areAllTrackersEmpty() {
            setupCollectionView()
            removePlug()
        }

        if let index = categories.firstIndex(where: { $0.header == categoryHeader }) {
            let currentCategory = categories[index]
            let updatedTrackers = currentCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(
                header: currentCategory.header,
                trackers: updatedTrackers
            )
            categories[index] = updatedCategory
            collectionView.reloadData()
        }
    }
}

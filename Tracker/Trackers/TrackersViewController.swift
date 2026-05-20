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
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
            .forAutoLayout
        label.text = "Трекеры"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
            .forAutoLayout

        searchBar.barTintColor = .searchBar
        searchBar.backgroundImage = UIImage()
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true

        searchBar.searchTextField.backgroundColor = .searchBar
        searchBar.searchTextField.textColor = .label
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17)
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.clipsToBounds = true

        searchBar.placeholder = "Поиск"

        return searchBar
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
            setPlug() }
        else {
            setupCollectionView()
        }
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDay
        
        let plusButton = UIBarButtonItem(image: UIImage(resource: .plus), style: .plain, target: self, action: #selector(plusButtonTapped))
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        view.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
        
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
        view.addSubview(plugImage)
        NSLayoutConstraint.activate([
            plugImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            plugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImage.heightAnchor.constraint(equalToConstant: 80),
            plugImage.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(plugLabel)
        NSLayoutConstraint.activate([
            plugLabel.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func areAllTrackersEmpty() -> Bool {
        for category in categories {
            if !category.trackers.isEmpty {
                return false
            }
        }
        return true
    }
    
    private func addNewCategory(_ category: TrackerCategory) {
        categories.append(category)
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
    }
    
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackerCollectionViewCell
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        cell.configure(with: tracker, isCompletedToday: isCompletedToday, indexPath: indexPath)
        
        return cell
    }
    
    private func isTrackerCompletedToday(id: UInt) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id  == id && isSameDay
        }
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
        
        header.configure(with: categories[indexPath.section].header)
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
        return CGSize(width: collectionView.bounds.width / 2, height: 50)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UInt, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UInt, at indexPath: IndexPath) {
        completedTrackers.removeAll() { trackerRecord in
            trackerRecord.id == id &&
            trackerRecord.date == datePicker.date
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    var trackersCount: UInt {
        UInt(category.trackers.count)
    }
    
    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String) {
        
        if areAllTrackersEmpty() {
            setupCollectionView()
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

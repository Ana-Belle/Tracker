//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let viewModel: TrackersViewModel
    
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
    
    // MARK: - Initialization
    
    init(viewModel: TrackersViewModel = TrackersViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setElements()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        viewModel.plusButtonTapped()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.dateChanged(sender.date)
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.onContentVisibilityChanged = { [weak self] hasTrackers in
            self?.updateContentVisibility(hasTrackers: hasTrackers)
        }
        
        viewModel.onCollectionViewReloadData = { [weak self] in
            guard self?.trackerCollectionView.superview != nil else { return }
            self?.trackerCollectionView.reloadData()
        }
        
        viewModel.onCollectionViewReloadItems = { [weak self] indexPath in
            self?.trackerCollectionView.reloadItems(at: [indexPath])
        }
        
        viewModel.onPresentNewTracker = { [weak self] in
            guard let self else { return }
            let newTrackerVC = NewTrackerViewController()
            newTrackerVC.delegate = self
            self.present(newTrackerVC, animated: true)
        }
        
        viewModel.onLogInfo = { message in
            TrackerLogger.shared.info(message)
        }
        
        viewModel.onError = { message in
            TrackerLogger.shared.error(message)
        }
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDay
        
        let plusButton = UIBarButtonItem(
            image: UIImage(resource: .plusBlack),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
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
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
    
    private func updateContentVisibility(hasTrackers: Bool) {
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
    
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.numberOfItems(in: section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        guard let trackerCell = cell as? TrackerCollectionViewCell,
              let cellViewModel = viewModel.cellViewModel(at: indexPath) else {
            return cell
        }
        
        trackerCell.delegate = self
        trackerCell.configure(
            with: cellViewModel.tracker,
            isCompletedToday: cellViewModel.isCompletedToday,
            completedDays: cellViewModel.completedDays,
            indexPath: indexPath
        )
        
        return trackerCell
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
        
        header.configure(with: viewModel.sectionTitle(for: indexPath.section))
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
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        viewModel.completeTracker(id: id, at: indexPath)
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        viewModel.uncompleteTracker(id: id, at: indexPath)
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    var trackersCount: UInt {
        viewModel.trackersCount
    }
    
    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String) {
        viewModel.addNewTrackerToCategory(tracker: tracker, to: categoryHeader)
    }
}

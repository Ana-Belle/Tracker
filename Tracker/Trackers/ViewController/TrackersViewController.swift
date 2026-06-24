//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private enum Layout {
        static let filtersButtonHeight: CGFloat = 50
        static let filtersButtonBottomInset: CGFloat = 50
        static var filtersButtonOverlayInset: CGFloat {
            filtersButtonHeight + filtersButtonBottomInset
        }
    }
    
    private let viewModel: TrackersViewModel
    private let analyticsService = AnalyticsService()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
            .forAutoLayout
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchController.searchBar.searchTextField.backgroundColor = .backgroundDayNight
        searchController.searchBar.searchTextField.textColor = .searchText
        return searchController
    }()
    
    private lazy var plugLabel: UILabel = {
        let label = UILabel()
            .forAutoLayout
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
        collectionView.backgroundColor = .whiteDayNight
        collectionView.alwaysBounceVertical = true
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }().forAutoLayout
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.filtersButtonTapped()
        })
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        return button
    }().forAutoLayout
    
    private lazy var plugImageNothingWasFound: UIImageView = {
        let plugImage = UIImageView(image: UIImage(resource: .nothingWasFound))
            .forAutoLayout
        plugImage.contentMode = .scaleAspectFill
        return plugImage
    }()
    
    private lazy var plugLabelNothingWasFound: UILabel = {
        let label = UILabel()
            .forAutoLayout
        label.text = "Ничего не найдено"
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
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
        
        definesPresentationContext = true
        bindViewModel()
        setElements()
        viewModel.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen" : "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen" : "Main"])
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        viewModel.plusButtonTapped()
    }
    
    private var isUpdatingDateProgrammatically = false
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        guard !isUpdatingDateProgrammatically else { return }
        viewModel.dateChanged(sender.date)
    }
    
    @objc private func filtersButtonTapped() {
        viewModel.filtersButtonTapped()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.onContentVisibilityChanged = { [weak self] hasTrackersToDisplay, showFiltersButton in
            self?.updateContentVisibility(
                hasTrackersToDisplay: hasTrackersToDisplay,
                showFiltersButton: showFiltersButton
            )
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
            let newTrackerVC = TrackerFormViewController()
            newTrackerVC.delegate = self
            self.present(newTrackerVC, animated: true)
        }
        
        viewModel.onPresentEditTracker = { [weak self] tracker, categoryHeader in
            guard let self else { return }
            let editingContext = TrackerEditingContext(tracker: tracker, categoryHeader: categoryHeader)
            let editTrackerVC = TrackerFormViewController(viewModel: TrackerFormViewModel(editingContext: editingContext))
            editTrackerVC.delegate = self
            self.present(editTrackerVC, animated: true)
        }
        
        viewModel.onShowDeleteConfirmation = { [weak self] trackerId in
            self?.showDeleteConfirmation(for: trackerId)
        }
        
        viewModel.onLogInfo = { message in
            TrackerLogger.shared.info(message)
        }
        
        viewModel.onError = { message in
            TrackerLogger.shared.error(message)
        }
        
        viewModel.onPresentFilters = { [weak self] in
            guard let self else { return }
            let filtersVC = FiltersViewController(selectedFilter: viewModel.selectedFilter)
            filtersVC.delegate = self
            self.present(filtersVC, animated: true)
        }
        
        viewModel.onSelectedDateUpdated = { [weak self] date in
            guard let self else { return }
            self.isUpdatingDateProgrammatically = true
            self.datePicker.setDate(date, animated: true)
            self.isUpdatingDateProgrammatically = false
        }
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDayNight
        
        let plusButton = UIBarButtonItem(
            image: UIImage(resource: .plusBlack),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        plusButton.tintColor = .blackDayNight
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem?.hidesSharedBackground = true
        }
        
        navigationItem.title = NSLocalizedString("trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteDayNight
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UISearchBar.self]
        ).title = NSLocalizedString("cancel", comment: "")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
        
        view.bringSubviewToFront(filtersButton)
    }
    
    private func updateCollectionViewContentInset(showFiltersButton: Bool) {
        let bottomInset = showFiltersButton ? Layout.filtersButtonOverlayInset : 0
        trackerCollectionView.contentInset.bottom = bottomInset
        trackerCollectionView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    private func setPlug() {
        if trackerCollectionView.superview != nil {
            trackerCollectionView.removeFromSuperview()
        }
        
        removePlugNothingWasFound()
        removePlug()
        
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
    
    private func setPlugNothingWasFound() {
        if trackerCollectionView.superview != nil {
            trackerCollectionView.removeFromSuperview()
        }
        
        removePlug()
        removePlugNothingWasFound()
        
        view.addSubview(plugImageNothingWasFound)
        NSLayoutConstraint.activate([
            plugImageNothingWasFound.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImageNothingWasFound.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            plugImageNothingWasFound.heightAnchor.constraint(equalToConstant: 80),
            plugImageNothingWasFound.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(plugLabelNothingWasFound)
        NSLayoutConstraint.activate([
            plugLabelNothingWasFound.topAnchor.constraint(equalTo: plugImageNothingWasFound.bottomAnchor, constant: 8),
            plugLabelNothingWasFound.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func removePlug() {
        plugImage.removeFromSuperview()
        plugLabel.removeFromSuperview()
    }
    
    private func removePlugNothingWasFound() {
        plugImageNothingWasFound.removeFromSuperview()
        plugLabelNothingWasFound.removeFromSuperview()
    }
    
    private func removeAllPlugs() {
        removePlug()
        removePlugNothingWasFound()
    }
    
    private func showDeleteConfirmation(for trackerId: UUID) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(id: trackerId)
        })
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func updateContentVisibility(hasTrackersToDisplay: Bool, showFiltersButton: Bool) {
        filtersButton.isHidden = !showFiltersButton
        updateCollectionViewContentInset(showFiltersButton: showFiltersButton)
        
        if showFiltersButton {
            view.bringSubviewToFront(filtersButton)
        }
        
        if hasTrackersToDisplay {
            removeAllPlugs()
            if trackerCollectionView.superview == nil {
                setupTrackerCollectionView()
            }
            trackerCollectionView.reloadData()
        } else if showFiltersButton {
            if trackerCollectionView.superview != nil {
                trackerCollectionView.removeFromSuperview()
            }
            setPlugNothingWasFound()
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
    
    func editTracker(id: UUID, at indexPath: IndexPath) {
        viewModel.editTracker(at: indexPath)
    }
    
    func requestDeleteTracker(id: UUID, at indexPath: IndexPath) {
        viewModel.requestDeleteTracker(id: id)
    }
}

extension TrackersViewController: TrackerFormViewControllerDelegate {
    var trackersCount: UInt {
        viewModel.trackersCount
    }
    
    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String) {
        viewModel.addNewTrackerToCategory(tracker: tracker, to: categoryHeader)
    }
    
    func updateTracker(tracker: Tracker, categoryHeader: String, previousCategoryHeader: String) {
        viewModel.updateTracker(
            tracker: tracker,
            categoryHeader: categoryHeader,
            previousCategoryHeader: previousCategoryHeader
        )
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func filtersViewController(_ viewController: FiltersViewController, didSelectFilter filter: Filters) {
        viewModel.selectFilter(filter)
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTextChanged(searchController.searchBar.text ?? "")
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchTextChanged("")
    }
}

//
//  TrackerFormViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 07.05.2026.
//

import UIKit

protocol TrackerFormViewControllerDelegate: AnyObject {
    var trackersCount: UInt { get }
    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String)
    func updateTracker(tracker: Tracker, categoryHeader: String, previousCategoryHeader: String)
}

final class TrackerFormViewController: UIViewController {
    
    weak var delegate: TrackerFormViewControllerDelegate? {
        didSet { viewModel.delegate = delegate }
    }
    
    private let viewModel: TrackerFormViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }().forAutoLayout
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }().forAutoLayout
    
    private lazy var completedDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }().forAutoLayout
    
    private var completedDaysLabelHeightConstraint: NSLayoutConstraint?
    
    private lazy var trackerNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.textColor = .blackDayNight
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .backgroundDayNight
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftPadding
        textField.leftViewMode = .always
        
        let rightPaddingContainer = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 20))
        clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        rightPaddingContainer.addSubview(clearButton)
        textField.rightView = rightPaddingContainer
        textField.rightViewMode = .whileEditing
        
        return textField
    }().forAutoLayout
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .xmarkCircle), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        return button
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.viewModel.categoryButtonTapped()
        })
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.blackDayNight, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .backgroundDayNight
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 50)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.clipsToBounds = true
        
        let imageView = UIImageView(image: UIImage(resource: .chevron)).forAutoLayout
        button.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 7),
            imageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return button
    }().forAutoLayout
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.viewModel.scheduleButtonTapped()
        })
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.blackDayNight, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .backgroundDayNight
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.clipsToBounds = true
        
        let imageView = UIImageView(image: UIImage(resource: .chevron)).forAutoLayout
        button.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 7),
            imageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return button
    }().forAutoLayout
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            categoryButton,
            separator,
            scheduleButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.clipsToBounds = true
        return stackView
    }().forAutoLayout
    
    private lazy var separator: UIView = {
        let container = UIView()
        container.backgroundColor = .backgroundDayNight
        
        let view = UIView().forAutoLayout
        view.backgroundColor = UIColor(white: 0.85, alpha: 1)
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            view.heightAnchor.constraint(equalToConstant: 0.5),
            container.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return container
    }()
    
    private lazy var emojiColorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collectionView.register(
            EmojiColorSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiColorSectionHeaderView.reuseIdentifier
        )
        return collectionView
    }().forAutoLayout
    
    private var emojiColorCollectionViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.viewModel.cancelButtonTapped()
        })
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        button.layer.borderWidth = 1
        return button
    }().forAutoLayout
    
    private lazy var createButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.createButtonTapped()
        })
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.whiteDayNight, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }().forAutoLayout
    
    init(viewModel: TrackerFormViewModel = TrackerFormViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setElements()
        trackerNameField.delegate = self
        headerLabel.text = viewModel.screenTitle
        createButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        trackerNameField.text = viewModel.initialTrackerName
        completedDaysLabel.text = viewModel.completedDaysText
        completedDaysLabel.isHidden = viewModel.completedDaysText == nil
        completedDaysLabelHeightConstraint?.constant = viewModel.completedDaysText == nil ? 0 : 38
        viewModel.viewDidLoad()
        emojiColorCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEmojiColorCollectionViewHeight()
    }
    
    private func bindViewModel() {
        viewModel.onCategoryButtonTitleUpdated = { [weak self] secondLine in
            guard let self else { return }
            self.addSecondLineToButton(self.categoryButton, buttonTitle: "Категория", secondLine: secondLine)
        }
        
        viewModel.onScheduleButtonTitleUpdated = { [weak self] secondLine in
            guard let self else { return }
            self.addSecondLineToButton(self.scheduleButton, buttonTitle: "Расписание", secondLine: secondLine)
        }
        
        viewModel.onCreateButtonStateChanged = { [weak self] isEnabled in
            self?.createButton.isEnabled = isEnabled
            self?.createButton.backgroundColor = isEnabled ? .blackDayNight : .ypGray
        }
        
        viewModel.onClearTrackerName = { [weak self] in
            self?.trackerNameField.text = ""
        }
        
        viewModel.onDismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        viewModel.onPresentCategory = { [weak self] selectedCategoryHeader in
            let categoryVC = CategoryViewController(selectedCategoryHeader: selectedCategoryHeader)
            categoryVC.delegate = self
            self?.present(categoryVC, animated: true)
        }
        
        viewModel.onPresentSchedule = { [weak self] selectedWeekDays in
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.previouslySelectedDays = selectedWeekDays
            self?.present(scheduleVC, animated: true)
        }
        
        viewModel.onReloadCollectionItems = { [weak self] indexPaths in
            self?.emojiColorCollectionView.reloadItems(at: indexPaths)
        }
        
        viewModel.onLogInfo = { message in
            TrackerLogger.shared.info(message)
        }
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDayNight
        
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        scrollView.addSubview(completedDaysLabel)
        let completedDaysHeightConstraint = completedDaysLabel.heightAnchor.constraint(equalToConstant: 0)
        completedDaysLabelHeightConstraint = completedDaysHeightConstraint
        
        NSLayoutConstraint.activate([
            completedDaysLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            completedDaysLabel.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            completedDaysLabel.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            completedDaysHeightConstraint
        ])
        
        scrollView.addSubview(trackerNameField)
        NSLayoutConstraint.activate([
            trackerNameField.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 24),
            trackerNameField.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            trackerNameField.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            trackerNameField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: trackerNameField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        scrollView.addSubview(emojiColorCollectionView)
        
        let collectionHeightConstraint = emojiColorCollectionView.heightAnchor.constraint(equalToConstant: 1)
        emojiColorCollectionViewHeightConstraint = collectionHeightConstraint
        
        NSLayoutConstraint.activate([
            emojiColorCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            emojiColorCollectionView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            emojiColorCollectionView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            emojiColorCollectionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            collectionHeightConstraint
        ])
        
        view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.widthAnchor.constraint(equalToConstant: (view.frame.width - 40 - 8) / 2),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addSubview(createButton)
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.widthAnchor.constraint(equalToConstant: (view.frame.width - 40 - 8) / 2),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addSecondLineToButton(_ button: UIButton, buttonTitle: String, secondLine: String) {
        let attributedString = NSMutableAttributedString()
        
        let first = NSAttributedString(
            string: buttonTitle,
            attributes: [
                .foregroundColor: UIColor.blackDayNight,
                .font: UIFont.systemFont(ofSize: 17)
            ]
        )
        
        attributedString.append(first)
        
        if !secondLine.isEmpty {
            let newline = NSAttributedString(string: "\n")
            let second = NSAttributedString(
                string: secondLine,
                attributes: [
                    .foregroundColor: UIColor.ypGray,
                    .font: UIFont.systemFont(ofSize: 17)
                ]
            )
            
            attributedString.append(newline)
            attributedString.append(second)
        }
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    private func updateEmojiColorCollectionViewHeight() {
        emojiColorCollectionView.layoutIfNeeded()
        let contentHeight = emojiColorCollectionView.collectionViewLayout.collectionViewContentSize.height
        guard contentHeight > 0 else { return }
        emojiColorCollectionViewHeightConstraint?.constant = contentHeight
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 6.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let rowHeight: CGFloat = sectionIndex == TrackerSection.emoji.rawValue ? 52 : 56
            let rowGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(rowHeight)
            )
            let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize, subitem: item, count: 6)
            
            let rowsCount = 3
            let sectionGroupHeight = rowHeight * CGFloat(rowsCount) + 8 * CGFloat(rowsCount - 1)
            let sectionGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(sectionGroupHeight)
            )
            let sectionGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: sectionGroupSize,
                subitem: rowGroup,
                count: rowsCount
            )
            
            let section = NSCollectionLayoutSection(group: sectionGroup)
            section.interGroupSpacing = 8
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
            
            return section
        }
    }
    
    @objc private func clearTextField() {
        viewModel.clearTrackerName()
    }
    
    private func createButtonTapped() {
        viewModel.createButtonTapped(trackerName: trackerNameField.text ?? "")
    }
}

extension TrackerFormViewController: CategoryViewControllerDelegate {
    func categoryViewController(_ viewController: CategoryViewController, didSelectCategory header: String) {
        viewModel.categorySelected(header, trackerName: trackerNameField.text ?? "")
    }
}

extension TrackerFormViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ weekDays: [WeekDay]) {
        viewModel.scheduleSelected(weekDays, trackerName: trackerNameField.text ?? "")
    }
}

extension TrackerFormViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = TrackerSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                with: viewModel.emoji(at: indexPath.item),
                isSelected: viewModel.isEmojiSelected(at: indexPath.item)
            )
            return cell
            
        case .color:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                with: viewModel.color(at: indexPath.item),
                isSelected: viewModel.isColorSelected(at: indexPath.item)
            )
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EmojiColorSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? EmojiColorSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(title: viewModel.sectionTitle(for: indexPath.section))
        return header
    }
}

extension TrackerFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = TrackerSection(rawValue: indexPath.section) else { return }
        
        let trackerName = trackerNameField.text ?? ""
        
        switch section {
        case .emoji:
            viewModel.selectEmoji(at: indexPath.item, trackerName: trackerName)
        case .color:
            viewModel.selectColor(at: indexPath.item, trackerName: trackerName)
        }
    }
}

// MARK: - UITextFieldDelegate

extension TrackerFormViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.textDidChange(textField.text ?? "")
        }
        return true
    }
}

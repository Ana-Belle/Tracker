//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 07.05.2026.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    var trackersCount: UInt { get }
    func addNewTrackerToCategory(tracker: Tracker, to categoryHeader: String)
}

final class NewTrackerViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: NewTrackerViewControllerDelegate?

    private var selectedWeekDays: [WeekDay] = []
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?

    private lazy var logger = TrackerLogger.shared

    private enum Section: Int, CaseIterable {
        case emoji
        case color

        var title: String {
            switch self {
            case .emoji: return "Emoji"
            case .color: return "Цвет"
            }
        }
    }

    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    private let colors: [UIColor] = [
        .colorSelection1,  .colorSelection2,  .colorSelection3,  .colorSelection4,  .colorSelection5,  .colorSelection6,
        .colorSelection7,  .colorSelection8,  .colorSelection9,  .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }().forAutoLayout

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 16)
        return label
    }().forAutoLayout

    private lazy var newTrackerNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.textColor = .blackDay
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .backgroundDay
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
        let button = UIButton(type: .custom)
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.blackDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .backgroundDay

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
            self?.scheduleButtonTapped()
        })
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.blackDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .backgroundDay

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
        container.backgroundColor = .backgroundDay

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
            self?.cancelButtonTapped()
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
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }().forAutoLayout

    override func viewDidLoad() {
        super.viewDidLoad()

        setElements()
        newTrackerNameField.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEmojiColorCollectionViewHeight()
    }

    private func setElements() {
        view.backgroundColor = .whiteDay

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

        scrollView.addSubview(newTrackerNameField)
        NSLayoutConstraint.activate([
            newTrackerNameField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            newTrackerNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newTrackerNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newTrackerNameField.heightAnchor.constraint(equalToConstant: 75)
        ])

        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: newTrackerNameField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            categoryButton.heightAnchor.constraint(equalToConstant: 75)
        ])

        addSecondLineToButton(categoryButton, buttonTitle: "Категория", secondLine: "Домашний уют")

        NSLayoutConstraint.activate([
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
            cancelButton.widthAnchor.constraint(equalToConstant: (view.frame.width-40-8)/2),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])

        view.addSubview(createButton)
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.widthAnchor.constraint(equalToConstant: (view.frame.width-40-8)/2),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func addSecondLineToButton(_ button: UIButton, buttonTitle: String, secondLine: String) {
        let attributedString = NSMutableAttributedString()

        let first = NSAttributedString(
            string: buttonTitle,
            attributes: [
                .foregroundColor: UIColor.blackDay,
                .font: UIFont.systemFont(ofSize: 17)
            ]
        )

        let newline = NSAttributedString(string: "\n")

        let second = NSAttributedString(
            string: secondLine,
            attributes: [
                .foregroundColor: UIColor.ypGray,
                .font: UIFont.systemFont(ofSize: 17)
            ]
        )

        attributedString.append(first)
        attributedString.append(newline)
        attributedString.append(second)

        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
    }

    func textField(_ UITextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        DispatchQueue.main.async {
            self.enableCreateButton()
        }

        return true
    }

    private func updateEmojiColorCollectionViewHeight() {
        emojiColorCollectionView.layoutIfNeeded()
        let contentHeight = emojiColorCollectionView.collectionViewLayout.collectionViewContentSize.height
        guard contentHeight > 0 else { return }
        emojiColorCollectionViewHeightConstraint?.constant = contentHeight
    }

    private func enableCreateButton() {
        let isEnabled: Bool = newTrackerNameField.text?.isEmpty == false && !selectedWeekDays.isEmpty && selectedEmojiIndex != nil && selectedColorIndex != nil
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .blackDay : .ypGray
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 6.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            let rowHeight: CGFloat = sectionIndex == Section.emoji.rawValue ? 52 : 56
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
        newTrackerNameField.text = ""
    }

    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.previouslySelectedDays = selectedWeekDays
        present(scheduleVC, animated: true, completion: nil)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func createButtonTapped() {
        let id = UUID()
        let newTrackerNameFieldText = newTrackerNameField.text ?? "Новый трекер"
        let newTracker = Tracker(
            id: id,
            name: newTrackerNameFieldText,
            color: selectedColorIndex.map { colors[$0] } ?? .colorSelection5,
            emoji: selectedEmojiIndex.map { emojis[$0] } ?? "🌸",
            schedule: selectedWeekDays
        )
        delegate?.addNewTrackerToCategory(tracker: newTracker, to: "Домашний уют")
        self.dismiss(animated: true, completion: nil)
    }

}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ weekDays: [WeekDay]) {
        self.selectedWeekDays = weekDays
        addSecondLineToButton(scheduleButton, buttonTitle: "Расписание", secondLine: formatWeekDays(weekDays))
        logger.info("Selected days: \(weekDays)")
        enableCreateButton()
    }

    private func formatWeekDays(_ days: [WeekDay]) -> String {
        if days.count == 7 {
            return "Каждый день"
        }
        return days.map { $0.rawValue }.joined(separator: ", ")
    }
}

extension NewTrackerViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
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
            cell.configure(with: emojis[indexPath.item], isSelected: selectedEmojiIndex == indexPath.item)
            return cell

        case .color:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: colors[indexPath.item], isSelected: selectedColorIndex == indexPath.item)
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

        if let section = Section(rawValue: indexPath.section) {
            header.configure(title: section.title)
        }

        return header
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .emoji:
            let previousIndex = selectedEmojiIndex
            selectedEmojiIndex = indexPath.item
            reloadItems(in: collectionView, section: section.rawValue, previousIndex: previousIndex, newIndex: indexPath.item)
        case .color:
            let previousIndex = selectedColorIndex
            selectedColorIndex = indexPath.item
            reloadItems(in: collectionView, section: section.rawValue, previousIndex: previousIndex, newIndex: indexPath.item)
        }

        enableCreateButton()
    }

    private func reloadItems(
        in collectionView: UICollectionView,
        section: Int,
        previousIndex: Int?,
        newIndex: Int
    ) {
        var indexPaths = [IndexPath(item: newIndex, section: section)]
        if let previousIndex, previousIndex != newIndex {
            indexPaths.append(IndexPath(item: previousIndex, section: section))
        }
        collectionView.reloadItems(at: indexPaths)
    }
}


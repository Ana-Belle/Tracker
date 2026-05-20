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

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
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

        addSecondLineToButton(categoryButton, secondLine: "Домашний уют")

        NSLayoutConstraint.activate([
            scheduleButton.heightAnchor.constraint(equalToConstant: 75)
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

    private func addSecondLineToButton(_ button: UIButton, secondLine: String) {
        let attributedString = NSMutableAttributedString()
        guard let buttonText = button.titleLabel?.text else { return }

        let first = NSAttributedString(
            string: buttonText,
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

    // MARK: - UITextFieldDelegate
    func textField(_ UITextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        DispatchQueue.main.async { [weak self] in
            self?.enableCreateButton()
        }

        return true
    }

    private func enableCreateButton() {
        if newTrackerNameField.text?.isEmpty == false && selectedWeekDays.isEmpty == false {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackDay
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }

    @objc private func clearTextField() {
        newTrackerNameField.text = ""
    }

    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        present(scheduleVC, animated: true, completion: nil)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func createButtonTapped() {
        let id = (delegate?.trackersCount ?? 0) + 1
        let newTrackerNameFieldText = newTrackerNameField.text ?? "Новый трекер"
        let newTracker = Tracker(
            id: id,
            name: newTrackerNameFieldText,
            color: .colorSelection5,
            emoji: "🌸",
            schedule: selectedWeekDays
        )
        delegate?.addNewTrackerToCategory(tracker: newTracker, to: "Домашний уют")
        self.dismiss(animated: true, completion: nil)
    }

}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ weekDays: [WeekDay]) {
        self.selectedWeekDays = weekDays
        addSecondLineToButton(scheduleButton, secondLine: formatWeekDays(weekDays))
        print("Selected days: \(weekDays)")
        enableCreateButton()
    }

    private func formatWeekDays(_ days: [WeekDay]) -> String {
        days.map { $0.rawValue }.joined(separator: ", ")
    }
}

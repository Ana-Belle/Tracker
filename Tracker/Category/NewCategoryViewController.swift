//
//  CategoryFormViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 11.06.2026.
//

import UIKit

final class CategoryFormViewController: UIViewController, UITextFieldDelegate {

    var editingCategoryHeader: String?
    var onCategoryUpdated: ((_ oldHeader: String, _ newHeader: String) -> Void)?
    
    private let categoryStore = TrackerCategoryStore()
    private lazy var logger = TrackerLogger.shared

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }().forAutoLayout

    private lazy var newCategoryNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.textColor = .blackDay
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true

        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftPadding
        textField.leftViewMode = .always

        return textField
    }().forAutoLayout

    private lazy var doneButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.doneButtonTapped()
        })
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }().forAutoLayout

    override func viewDidLoad() {
        super.viewDidLoad()

        setElements()
        newCategoryNameField.delegate = self

        if let editingCategoryHeader {
            headerLabel.text = "Редактирование категории"
            newCategoryNameField.text = editingCategoryHeader
            updateDoneButtonState()
        }
    }

    private func setElements() {
        view.backgroundColor = .whiteDay

        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.addSubview(newCategoryNameField)
        NSLayoutConstraint.activate([
            newCategoryNameField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            newCategoryNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryNameField.heightAnchor.constraint(equalToConstant: 75)
        ])

        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        DispatchQueue.main.async {
            self.updateDoneButtonState()
        }
        return true
    }

    private func updateDoneButtonState() {
        let hasText = !(newCategoryNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText ? .blackDay : .ypGray
    }

    @objc private func doneButtonTapped() {
        let header = newCategoryNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !header.isEmpty else { return }

        do {
            if let editingCategoryHeader {
                try categoryStore.updateCategory(oldHeader: editingCategoryHeader, newHeader: header)
                onCategoryUpdated?(editingCategoryHeader, header)
            } else {
                try categoryStore.addCategory(header: header)
            }
            dismiss(animated: true)
        } catch {
            logger.error("Не удалось сохранить категорию: \(error)")
        }
    }

}

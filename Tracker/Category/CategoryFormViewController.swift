//
//  CategoryFormViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 11.06.2026.
//

import UIKit

final class CategoryFormViewController: UIViewController {
    
    private let viewModel: CategoryFormViewModel
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
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
    
    // MARK: - Initialization
    
    init(viewModel: CategoryFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(
        editingCategoryHeader: String? = nil,
        onCategoryUpdated: ((_ oldHeader: String, _ newHeader: String) -> Void)? = nil
    ) {
        self.init(viewModel: CategoryFormViewModel(
            editingCategoryHeader: editingCategoryHeader,
            onCategoryUpdated: onCategoryUpdated
        ))
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
        newCategoryNameField.delegate = self
        viewModel.viewDidLoad()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.onTitleUpdated = { [weak self] title in
            self?.headerLabel.text = title
        }
        
        viewModel.onInitialTextUpdated = { [weak self] text in
            self?.newCategoryNameField.text = text
        }
        
        viewModel.onDoneButtonStateChanged = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
            self?.doneButton.backgroundColor = isEnabled ? .blackDay : .ypGray
        }
        
        viewModel.onDismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        viewModel.onError = { message in
            TrackerLogger.shared.error(message)
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
    
    private func doneButtonTapped() {
        viewModel.doneButtonTapped(text: newCategoryNameField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension CategoryFormViewController: UITextFieldDelegate {
    
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

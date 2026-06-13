//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 11.06.2026.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func categoryViewController(_ viewController: CategoryViewController, didSelectCategory header: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    
    var selectedCategoryHeader: String?
    
    private let categoryStore = TrackerCategoryStore()
    private lazy var logger = TrackerLogger.shared
    private var categories: [TrackerCategory] = []
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }().forAutoLayout
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.rowHeight = 75
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner,
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner
        ]
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }().forAutoLayout
    
    private lazy var addButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.addButtonTapped()
        })
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        return button
    }().forAutoLayout
    
    private lazy var plugImage: UIImageView = {
        let plugImage = UIImageView(image: UIImage(resource: .dizzy))
            .forAutoLayout
        plugImage.contentMode = .scaleAspectFill
        return plugImage
    }()
    
    private lazy var plugLabel: UILabel = {
        let label = UILabel()
            .forAutoLayout
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let lineHeight: CGFloat = 18
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = .center
        
        label.attributedText = NSAttributedString(
            string: "Привычки и события можно\nобъединить по смыслу",
            attributes: [
                .font: font,
                .foregroundColor: UIColor.blackDay,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: (lineHeight - font.lineHeight) / 2
            ]
        )
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryStore.delegate = self
        categories = categoryStore.categories
        setElements()
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDay
        
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        if !categories.isEmpty {
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 525)
            ]) } else {
                setPlug()
            }
        
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setPlug() {
        view.addSubview(plugImage)
        NSLayoutConstraint.activate([
            plugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 346),
            plugImage.heightAnchor.constraint(equalToConstant: 80),
            plugImage.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(plugLabel)
        NSLayoutConstraint.activate([
            plugLabel.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func addButtonTapped() {
        let newCategoryVC = CategoryFormViewController()
        present(newCategoryVC, animated: true)
    }
    
    private func editCategory(header: String) {
        let newCategoryVC = CategoryFormViewController()
        newCategoryVC.editingCategoryHeader = header
        newCategoryVC.onCategoryUpdated = { [weak self] oldHeader, newHeader in
            if self?.selectedCategoryHeader == oldHeader {
                self?.selectedCategoryHeader = newHeader
            }
        }
        present(newCategoryVC, animated: true)
    }
    
    private func deleteCategory(header: String) {
        do {
            try categoryStore.deleteCategory(header: header)
            if selectedCategoryHeader == header {
                selectedCategoryHeader = nil
            }
        } catch {
            logger.error("Не удалось удалить категорию: \(error)")
        }
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.configure(
            header: category.header,
            isSelected: category.header == selectedCategoryHeader
        )
        cell.backgroundColor = .backgroundDay
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let categoryHeader = categories[indexPath.row].header
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: nil
            ) { _ in
                self?.editCategory(header: categoryHeader)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: nil,
                attributes: .destructive
            ) { _ in
                self?.deleteCategory(header: categoryHeader)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        selectedCategoryHeader = selectedCategory.header
        tableView.reloadRows(at: [indexPath], with: .none)
        
        delegate?.categoryViewController(self, didSelectCategory: selectedCategory.header)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == categories.count - 1
        
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: isLastCell ? tableView.bounds.width : 16,
            bottom: 0,
            right: isLastCell ? 0 : 16
        )
        
        var corners: CACornerMask = []
        if isFirstCell {
            corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        if isLastCell {
            corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }
        
        if corners.isEmpty {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
            cell.layer.masksToBounds = false
        } else {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = corners
            cell.layer.masksToBounds = true
        }
    }
}

extension CategoryViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory]) {
        self.categories = categories
        
        if categories.isEmpty {
            if tableView.superview != nil {
                tableView.removeFromSuperview()
            }
            if plugImage.superview == nil {
                setPlug()
            }
        } else {
            if tableView.superview == nil {
                plugImage.removeFromSuperview()
                plugLabel.removeFromSuperview()
                view.insertSubview(tableView, belowSubview: addButton)
                NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    tableView.heightAnchor.constraint(equalToConstant: 525)
                ])
            }
            tableView.reloadData()
        }
    }
}

//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 20.06.2026.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ viewController: FiltersViewController, didSelectFilter filter: Filters)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    
    private let filters = Filters.allCases
    private var selectedFilter: Filters
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters", comment: "")
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }().forAutoLayout
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FiltersTableViewCell.self, forCellReuseIdentifier: FiltersTableViewCell.identifier)
        tableView.rowHeight = 75
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        return tableView
    }().forAutoLayout
    
    init(selectedFilter: Filters = .allTrackers) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setElements()
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDay
        
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersTableViewCell.identifier,
            for: indexPath
        ) as? FiltersTableViewCell else {
            return UITableViewCell()
        }
        
        let filter = filters[indexPath.row]
        cell.configure(header: filter.rawValue, isSelected: filter == selectedFilter)
        cell.backgroundColor = .backgroundDay
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        selectedFilter = filter
        tableView.reloadData()
        delegate?.filtersViewController(self, didSelectFilter: filter)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == filters.count - 1
        
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

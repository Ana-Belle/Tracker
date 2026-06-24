//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 28.04.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let viewModel: StatisticsViewModel
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics", comment: "")
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }().forAutoLayout
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.register(
            StatisticsTableViewCell.self,
            forCellReuseIdentifier: StatisticsTableViewCell.identifier
        )
        return tableView
    }().forAutoLayout
    
    private lazy var plugImage: UIImageView = {
        let plugImage = UIImageView(image: UIImage(resource: .cryingSmile))
            .forAutoLayout
        plugImage.contentMode = .scaleAspectFill
        return plugImage
    }()
    
    private lazy var plugLabel: UILabel = {
        let label = UILabel()
            .forAutoLayout
        label.text = "Анализировать пока нечего"
        label.textColor = .blackDayNight
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - Initialization
    
    init(viewModel: StatisticsViewModel = StatisticsViewModel()) {
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
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            self?.updateContentVisibility(isEmpty: isEmpty)
        }
        
        viewModel.onStatisticsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func setElements() {
        view.backgroundColor = .whiteDayNight
        
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func updateContentVisibility(isEmpty: Bool) {
        if isEmpty {
            tableView.removeFromSuperview()
            setPlug()
        } else {
            plugImage.removeFromSuperview()
            plugLabel.removeFromSuperview()
            
            if tableView.superview == nil {
                view.addSubview(tableView)
                NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 77),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
            
            tableView.reloadData()
        }
    }
    
    private func setPlug() {
        view.addSubview(plugImage)
        NSLayoutConstraint.activate([
            plugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 375),
            plugImage.heightAnchor.constraint(equalToConstant: 80),
            plugImage.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(plugLabel)
        NSLayoutConstraint.activate([
            plugLabel.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StatisticsTableViewCell.identifier,
                for: indexPath
            ) as? StatisticsTableViewCell,
            let item = viewModel.item(at: indexPath.row)
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: item)
        return cell
    }
}

//
//  ViewController.swift
//  DiffableDataSourceSample
//
//  Created by Ichiko Moro on 2020/10/11.
//  Copyright © 2020 Ichiko Moro. All rights reserved.
//

import UIKit
import DiffableDataSources

enum Section {
    case animal
    case fruit
}

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    typealias Snapshot = DiffableDataSourceSnapshot<Section, String>
    
    private var animalData: [String] = [
    "Dog",
    "Cat",
    "Penguine",
    "Finch",
    ]
    
    private var fruitData: [String] = [
    "🦑",
    "🐙",
    "🦐",
    "🦀",
    ]

    private var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(didTapEdit))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(didTapReload))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(didTapSwitch))
        
        dataSource = DataSource(tableView: tableView)
        dataSource.applyMoveBlock = { [weak self] tableView, fromIndexPath, toIndexPath in
            self?.move(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath)
        }
        
        apply()
    }

    private func apply(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.animal])
        snapshot.appendItems(animalData)
        snapshot.appendSections([.fruit])
        snapshot.appendItems(fruitData)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func move(fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        let fromSection = fromIndexPath.section
        let toSection = toIndexPath.section
        switch (fromSection, toSection) {
        case (0, 0), (1, 1):
            if fromSection == 0 {
                let item = animalData.remove(at: fromIndexPath.item)
                animalData.insert(item, at: toIndexPath.item)
            } else {
                let item = fruitData.remove(at: fromIndexPath.item)
                fruitData.insert(item, at: toIndexPath.item)
            }
        case (0, 1):
            let item = animalData.remove(at: fromIndexPath.item)
            fruitData.insert(item, at: toIndexPath.item)
        case (1, 0):
            let item = fruitData.remove(at: fromIndexPath.item)
            animalData.insert(item, at: toIndexPath.item)
        case (_, _):
            assertionFailure()
        }
    }

    @objc private func didTapEdit() {
        let isEditing = self.isEditing
        setEditing(!isEditing, animated: true)
        tableView.setEditing(!isEditing, animated: true)
        
        if isEditing {
            apply(animated: false)
        }
    }

    @objc private func didTapReload() {
        apply()
    }
    
    @objc private func didTapSwitch() {
        let item = animalData.remove(at: 0)
        animalData.insert(item, at: 3)
        
        apply()
    }
}

private class DataSource: TableViewDiffableDataSource<Section, String> {
    var applyMoveBlock: ((UITableView, IndexPath, IndexPath) -> Void)?
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pets"
        } else {
            return "Sea Food"
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt: IndexPath) -> Bool {
        tableView.isEditing
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, moveRowAt from: IndexPath, to: IndexPath) {
        applyMoveBlock?(tableView, from, to)
    }
}

//
//  HistoriqueViewController.swift
//  Calculator2
//
//  Created by William on 15/12/2023.
//

import Foundation
import UIKit

class HistoriqueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var historique = [Operation]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historique.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = historique[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let secondOperandText = (model.secondOperand == 0) ? "" : " \(model.secondOperand)"
        cell.textLabel?.text = "\(model.firstOperand) \(model.calcul ?? "") \(secondOperandText) = \(model.result)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item =  historique[indexPath.row]
        let sheet = UIAlertController(title: "Supprimer Calcul ?", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
                sheet.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: {[weak self] _ in self?.deleteItem(item: item)}))
        present(sheet, animated: true)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(title: "Vider historique", style: .plain, target: self, action: #selector(ClearHistoryButton))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Calculatrice", image:nil, target: nil, action: nil)
        title = "Historique des calculs"
        view.addSubview(tableView)
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    
    @objc private func ClearHistoryButton() {
        for item in historique {
            deleteItem(item: item)
        }
    }
    
    // MARK: for Core data

    func getAllItems() {
        do {
            historique = try context.fetch(Operation.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            //error
        }
    }
    
    func createItem(firstOperand: Double, calcul: String, secondOperand: Double, result: Double) {
        let newItem = Operation(context: context)
        newItem.firstOperand = firstOperand
        newItem.calcul = calcul
        newItem.secondOperand = secondOperand
        newItem.result = result
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            
        }
    }
    
    func deleteItem(item: Operation) {
        context.delete(item)
        do {
            try context.save()
            getAllItems()
        } catch {
            
        }
    }
}

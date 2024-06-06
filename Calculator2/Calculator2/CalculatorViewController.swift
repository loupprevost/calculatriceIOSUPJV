//
//  ViewController.swift
//  calculator
//
//  Created by William on 28/09/2023.
//

import UIKit

class CalculatorViewController: UIViewController {

    var typing = false
    
    private var brain = CalculatorBrain()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var OperationToAdd: [newOperation] = []

    private struct newOperation {
        var firstOperand: Double?
        var calcul: String = ""
        var secondOperand: Double?
        var result: Double?
    }

    private var nextOperation = newOperation()

    // MARK: Inputs

    @IBOutlet weak var result: UILabel!

    var value: Double {
        get{ return  Double(result.text!)! }
        set{ result.text = String(newValue) }
    }
    
    @IBAction func bouton_digit(_ sender: UIButton) {
        let digit = sender.currentTitle!;
        if (nextOperation.result != nil) {
            brain.clear()
            nextOperation = newOperation()
        }
        if (typing) {
            let text = result.text!
            result.text = text + digit
        } else {
            result.text = digit
            typing = true
        }
    }
    @IBAction func clear(_ sender: UIButton) {
        result.text = "0"
        brain.clear()
        nextOperation = newOperation()
        typing = false
    }

    @IBAction func operation(_ sender: UIButton) {
        if typing {
            if (nextOperation.firstOperand == nil) {
                nextOperation.firstOperand = value
            } else {
                nextOperation.secondOperand = value
            }
            brain.setOperand(value)
        }
        if let symbol = sender.currentTitle {
            if (symbol != "=") {
                if (!typing) {
                    nextOperation.result = nil
                    brain.setOperand(value)
                }
                nextOperation.calcul = symbol
            }
            brain.performOperation(symbol)
            typing = false
        }
        if let result = brain.result {
            nextOperation.result = result
            OperationToAdd.append(nextOperation)
            let calcul = nextOperation.calcul
            let secondOperand = nextOperation.secondOperand
            nextOperation = newOperation(firstOperand: result, calcul: calcul, secondOperand: secondOperand, result: value)
            value = result
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationController = segue.destination
        if let navigationController = destinationController as?  UINavigationController {
            destinationController = navigationController.visibleViewController ?? destinationController
        }
        if let historiqueViewController = destinationController as? HistoriqueViewController {
            for operation in OperationToAdd {
                print(operation)
                historiqueViewController.createItem(firstOperand: operation.firstOperand!, calcul: operation.calcul, secondOperand: operation.secondOperand!, result: operation.result!)
            }
            OperationToAdd.removeAll()
            historiqueViewController.navigationItem.title = "Historique de calculs"
        }
    }
}


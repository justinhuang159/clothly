//
//  PendingViewController.swift
//  Clothly
//
//  Created by Danny on 3/24/18.
//  Copyright © 2018 Stanley Zeng. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

enum Type {
    case pending
    case history
}

class PendingViewController: UIViewController {
    var type: Type!
    
    var dataSource: [JSON] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getData() {
        var donorId = 1
        var orgId = 1
        let donorJson: [String: Any] = [
            "donorId": donorId
        ]
        let orgJson: [String: Any] = [
            "orgId": orgId
        ]
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.status == .donor {
                switch self.type {
                case .pending:
                    DataService.sharedInstance.getPendingDonations(data: donorJson) { (donations) in
                        self.dataSource = donations["data"].array!
                    }
                case .history:
                    DataService.sharedInstance.getPastDonations(data: donorJson) { (donations) in
                        self.dataSource = donations["data"].array!
                    }
                default:
                    break
                }
            } else {
                switch self.type {
                case .pending:
                    DataService.sharedInstance.orgGetPendingDonations(data: orgJson) { (donations) in
                        self.dataSource = donations["data"].array!
                    }
                case .history:
                    DataService.sharedInstance.orgGetPastDonations(data: orgJson) { (donations) in
                        self.dataSource = donations["data"].array!
                    }
                default:
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    class func create() -> PendingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "pendingViewController") as! PendingViewController
        
        let _ = controller.view
        
        return controller
    }
}

extension PendingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "donationCell") as? DonationCell else {
            return UITableViewCell()
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.status == .donor {
                let cellData = self.dataSource[indexPath.row]
                cell.orgLabel.text = cellData["orgName"].stringValue
                cell.descriptionLabel.text = "Quantity: \(cellData["quantity"].stringValue) • Type: \(cellData["type"].stringValue) • Points: \(cellData["pointValue"].stringValue)"
                cell.pickUpLabel.text = "Pick Up Date: \(cellData["pickUpDate"].stringValue)"
                cell.selectionStyle = .none
                return cell
            } else {
                let cellData = self.dataSource[indexPath.row]
                cell.orgLabel.text = cellData["name"].stringValue
                cell.descriptionLabel.text = "Quantity: \(cellData["quantity"].stringValue) • Type: \(cellData["type"].stringValue) • Points: \(cellData["pointValue"].stringValue)"
                cell.pickUpLabel.text = "Pick Up Date: \(cellData["pickUpDate"].stringValue)\nAddress: \(cellData["address"].stringValue)"
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cellData = self.dataSource[indexPath.row]
        let donationId = cellData["donationId"].intValue
        let json: [String: Any] = [
            "donationId": donationId
        ]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            DataService.sharedInstance.orgDeleteDonation(data: json, completionHandler: {
                self.getData()
            })
        }
        deleteAction.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.status == .org {
                let cellData = self.dataSource[indexPath.row]
                let donationId = cellData["donationId"].intValue
                let json: [String: Any] = [
                    "donationId": donationId
                ]
                let approveAction = UIContextualAction(style: .normal, title: "Approve") { (action, view, handler) in
                    DataService.sharedInstance.orgMarkDonationPickedUp(data: json, completionHandler: {
                        self.getData()
                    })
                }
                approveAction.backgroundColor = UIColor.blue
                let configuration = UISwipeActionsConfiguration(actions: [approveAction])
                configuration.performsFirstActionWithFullSwipe = false
                return configuration
            }
        }
        return nil
    }
}

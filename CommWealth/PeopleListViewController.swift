//
//  PeopleListViewController.swift
//  CommWealth
//
//  Created by JAN FREDRICK on 15/09/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JGProgressHUD

class PeopleListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var peopleTableView: UITableView!
    
    let deleteEmployee = "http://dummy.restapiexample.com/api/v1/delete/"
    let updateEmployee = "http://dummy.restapiexample.com/api/v1/update/"
    
    var listToShow : [JSON] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        
    }
    
    @IBAction func backNow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToShow.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(140)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "person_cell", for: indexPath) as! PersonTableCell
        
        let dict = listToShow[indexPath.row]
        
        cell.idLabel.text = "ID : \(dict["id"].stringValue)"
        cell.nameLabel.text = "Name : \(dict["employee_name"].stringValue)"
        cell.salaryLabel.text = "Salary : \(dict["employee_salary"].stringValue)"
        cell.workLabel.text = "Age : \(dict["employee_age"].stringValue)"
        
        cell.editB.addTarget(self, action: #selector(editRow(sender:)), for: .touchUpInside)
        cell.deleteB.addTarget(self, action: #selector(deleteRow(sender:)), for: .touchUpInside)
        
        cell.tag = indexPath.row
        cell.dict = dict
        
        return cell
        
    }
    
    @objc func editRow(sender: UIButton) {
        
        let cell = sender.superview?.superview as! PersonTableCell
        
        callEditPerson(params: ["name": "Charlie Chaplin", "salary": "6750000", "age": "93"], id: cell.dict["id"].stringValue)
        
        cell.nameLabel.text = "Charlie Chaplin"
        cell.salaryLabel.text = "6750000"
        cell.workLabel.text = "93"
    }
    
    @objc func deleteRow(sender: UIButton) {
        let cell = sender.superview?.superview as! PersonTableCell
        
        callRemovePerson(id: cell.dict["id"].stringValue)
        
        listToShow.remove(at: cell.tag)
        
        peopleTableView.reloadData()
    }
    
    func callEditPerson(params: [String: String] = [:], id: String) {
        hud.textLabel.text = "Loading.."
        hud.show(in: view)
        
        print(params)
        print(updateEmployee + id)
        
        AF.request(updateEmployee + id + "?name=\(params["name"]!)&salary=\(params["salary"]!)&age=\(params["age"]!)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!).responseJSON {
            response in
            
            self.hud.dismiss()
            
            if response.error != nil {
                self.showPopup(title: "Error", msg: response.error!.localizedDescription)
            }else{
                print(JSON(response.data!))
                let jsonData = JSON(response.data!)
                if jsonData["status"].stringValue == "success" {
                    print(jsonData["data"])
                    
                    
                }else{
                    self.showPopup(title: "Failed", msg: jsonData["message"].stringValue)
                }
                
            }
            
        }
        
    }
    
    func callRemovePerson(params: [String: Any] = [:], id: String) {
        
        hud.textLabel.text = "Loading.."
        hud.show(in: view)
        
        AF.request(deleteEmployee + id).responseJSON {
            response in
            
            self.hud.dismiss()
            
            if response.error != nil {
                self.showPopup(title: "Error", msg: response.error!.localizedDescription)
            }else{
                print(JSON(response.data!))
                let jsonData = JSON(response.data!)
                if jsonData["status"].stringValue == "success" {
                    print(jsonData["data"])
                    
                    
                }else{
                    self.showPopup(title: "Failed", msg: jsonData["message"].stringValue)
                }
                
            }
            
        }
        
    }
    
    func showPopup(title: String, msg: String, cancelString: String = "OK") {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: cancelString, style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

//
//  ViewController.swift
//  CommWealth
//
//  Created by JAN FREDRICK on 15/09/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JGProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var salaryTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    
    let createEmployee = "http://dummy.restapiexample.com/api/v1/create"
    let readEmployee = "http://dummy.restapiexample.com/api/v1/employees"
    
    let hud = JGProgressHUD(style: .dark)
    
    var jsonToAdd : JSON! = nil
    var listToPass : [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        jsonToAdd = nil
    }

    @IBAction func submit(_ sender: Any) {
        
        if nameTF.text?.replacingOccurrences(of: " ", with: "") == "" || salaryTF.text?.replacingOccurrences(of: " ", with: "") == "" || ageTF.text?.replacingOccurrences(of: " ", with: "") == "" {
            showPopup(title: "Missing Fields", msg: "Kindly fill in all missing fields.")
            return
        }
        
        sendApi(params: ["name" : nameTF.text!, "salary" : salaryTF.text!, "age" : ageTF.text!], urlLink: createEmployee)
    }
    
    func sendApi(params: [String: Any] = [:], urlLink: String){
        
        hud.textLabel.text = "Loading.."
        hud.show(in: view)
        
        AF.request(urlLink, method: .post, parameters: params, encoding: URLEncoding.default)
        .responseJSON { response in
            print(response)
            
            self.hud.dismiss()
            
            switch(response.result) {
            case .success:
                if let json = response.data {
                    let jsonData = JSON(json)
                    
                    if jsonData["status"].stringValue == "success" {
                        print(jsonData["data"])
                        
                        if urlLink == self.createEmployee {
                            self.jsonToAdd = jsonData["data"]
                            self.showPopup(title: "Success", msg: jsonData["message"].stringValue)
                        }
                    }else{
                        self.showPopup(title: "Failed", msg: jsonData["message"].stringValue)
                    }
                    
                }
                break
            case .failure(let error):
                print(error)
                self.showPopup(title: "Error", msg: error.localizedDescription)
                break
            }
            
        }
        
    }
    
    @IBAction func showListNow(_ sender: Any) {
        
        hud.textLabel.text = "Loading.."
        hud.show(in: view)
        
        AF.request(readEmployee).responseJSON {
            response in
            
            self.hud.dismiss()
            
            if response.error != nil {
                self.showPopup(title: "Error", msg: response.error!.localizedDescription)
            }else{
                
                let jsonData = JSON(response.data!)
                
                if jsonData["status"].stringValue == "success" {
                    print(jsonData["data"])
                    
                    self.listToPass = jsonData["data"].arrayValue
                    self.performSegue(withIdentifier: "to_people_list", sender: self)
                    
                }else{
                    self.showPopup(title: "Failed", msg: jsonData["message"].stringValue)
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_people_list" {
            let nvc = segue.destination as! PeopleListViewController
            print("00")
            if jsonToAdd != nil {
                listToPass.append(JSON(["id": jsonToAdd["id"].stringValue, "employee_name": jsonToAdd["name"].stringValue, "employee_salary": jsonToAdd["salary"].stringValue, "employee_age": jsonToAdd["age"].stringValue]))
            }
            print("01")
            nvc.listToShow = listToPass
        }
    }
    
    func showPopup(title: String, msg: String, cancelString: String = "OK") {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: cancelString, style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}


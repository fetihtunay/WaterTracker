//
//  ViewController.swift
//  Water Tracker
//
//  Created by Fetih Tunay Yetişir on 29.05.2020.
//

import UIKit
import SQLite3


class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textLabel: UILabel!

    var db: OpaquePointer?


    override func viewDidLoad() {
        super.viewDidLoad()

        if(UserDefaults.standard.object(forKey: "cupsize") == nil){
            UserDefaults.standard.set(200, forKey: "cupsize")
        }

          let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("water.sqlite")


        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS water (date TEXT, size INT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }

        button.layer.cornerRadius = 50
        button.clipsToBounds = true

        showTodayWater()
        // Do any additional setup after loading the view.
    }

    func showTodayWater(){
        let queryString = "SELECT SUM(size) FROM water WHERE date = '" + getStringFromDate(date: Date(), format: "yyyy/MM/dd") + "' GROUP BY date"


        var stmt:OpaquePointer?

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        while(sqlite3_step(stmt) == SQLITE_ROW){
            let total = String(cString: sqlite3_column_text(stmt, 0))
            textLabel.text = "Today\n" + total + " ml"
            textLabel.numberOfLines = 0


            print(total)

        }

    }

    func addDrink(){
        var stmt: OpaquePointer?

        let cupSize = UserDefaults.standard.integer(forKey: "cupsize")

        let queryString = "INSERT INTO water (date, size) VALUES (?,?)"

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        //print(descriptionTextView.text!)
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        if sqlite3_bind_text(stmt, 1, getStringFromDate(date: Date(), format: "yyyy/MM/dd"), -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }

        if sqlite3_bind_int(stmt, 2 ,Int32(cupSize)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }


        print(cupSize)




        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }

        stmt = nil

        showTodayWater()



    }

    func getStringFromDate(date: Date, format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    @IBAction func addButtonTapped(_ sender: UIButton){
        addDrink()
    }

    @IBAction func cupButtonPressed(_ sender: UIButton){
        let alert = UIAlertController(title: "Cup Capacity", message: "Add your cup Capacity in ml", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Cup Capacity in ml"
        }

        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]

            if((textField?.text?.trimmingCharacters(in: .whitespaces).isInt)!){
                UserDefaults.standard.set(Int((textField?.text?.trimmingCharacters(in: .whitespaces))!), forKey: "cupsize")

            }

        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: {

            })
        }))

        present(alert, animated: true) {
            
        }
    }




}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

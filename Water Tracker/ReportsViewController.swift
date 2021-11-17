//
//  ReportsViewController.swift
//  Water Tracker
//
//  Created by Fetih Tunay Yetişir on 29.05.2020.
//

import UIKit
import SQLite3

class ReportsViewController: UIViewController {
    var waterList = [Water]()
    var db: OpaquePointer?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("water.sqlite")


        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        readValues()

        // Do any additional setup after loading the view.
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func getStringFromDate(date: Date, format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }


    @IBAction func backButtonPressed(_ sender: UIButton){
        dismiss(animated: true) {

        }
    }

    @objc func readValues(){
        waterList.removeAll()

        let queryString = "SELECT date, SUM(size) FROM water GROUP BY date"


        var stmt:OpaquePointer?

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        while(sqlite3_step(stmt) == SQLITE_ROW){
            let date = String(cString: sqlite3_column_text(stmt, 0))
            let size = String(cString: sqlite3_column_text(stmt, 1))
            print(size)
            waterList.append(Water(date: date, size: size))
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }


    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReportsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waterList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CutomTableViewCell
        let water = waterList[indexPath.row] as Water
        cell.dateLabel.text = water.date
        cell.sizeLabel.text = water.size + " ml"
        cell.selectionStyle = .gray

        




        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }




}

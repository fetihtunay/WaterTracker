//
//  CutomTableViewCell.swift
//  Water Tracker
//
//  Created by Fetih Tunay Yetişir on 29.05.2020.
//

import UIKit

class CutomTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

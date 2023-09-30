//
//  DataTableViewCell.swift
//  QR Code App 2
//
//  Created by Abdur Razzak on 27/9/23.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = ""
        descriptionLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configurateTheCell(_ text: QRCode) {
        titleLabel.text = text.name
        descriptionLabel.text = text.descriptions
        
        
    }
}

//
//  ContactTableViewCell.swift
//  iContact
//
//  Created by elzhankk on 23.11.2023.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    static let identifier: String = "ContactTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
}

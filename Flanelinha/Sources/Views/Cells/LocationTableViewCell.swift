//
//  LocationTableViewCell.swift
//  Flanelinha
//
//  Created by Raul Brito on 26/11/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

	@IBOutlet weak var locationNameLabel: UILabel!
	@IBOutlet weak var locationAddressLabel: UILabel!
	
	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

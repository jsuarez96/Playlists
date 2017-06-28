//
//  IndividualPlaylistTableViewCell.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/23/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit

class IndividualPlaylistTableViewCell: UITableViewCell {

    //UIImageView to contain album artwork
    @IBOutlet weak var artwork: UIImageView!
    
    //Label to contain song title
    @IBOutlet weak var songTitleLabel: UILabel!
    
    //Lable to contain artist name
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

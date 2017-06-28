//
//  AddSongTableViewCell.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/21/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit

class AddSongTableViewCell: UITableViewCell {

    //Label to contain album artwork
    @IBOutlet weak var artwork: UIImageView!
    
    //Label to contain song title
    @IBOutlet weak var songTitle: UILabel!
    
    //Label to contain artist name
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

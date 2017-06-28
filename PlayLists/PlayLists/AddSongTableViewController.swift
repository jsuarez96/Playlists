//
//  AddSongTableViewController.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/20/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit
import MediaPlayer

/*
 * Class defined to display all songs in library in table view, user selects to add to playlist
 */
class AddSongTableViewController: UITableViewController,UISearchResultsUpdating {
    
    //Model -- array of MPMediaItem objects
    var songs: [MPMediaItem]?
    //Search controller used to filter songs
    let searchControl = UISearchController(searchResultsController: nil)
    let DEF_WIDTH = 100

    override func viewDidLoad() { 
        super.viewDidLoad()
        let library = MPMediaQuery.songs().items
        songs = library
        searchControl.searchResultsUpdater = self
        searchControl.dimsBackgroundDuringPresentation = false
        searchControl.searchBar.sizeToFit()
        searchControl.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = searchControl.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Search Controller Protocol
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchControl.searchBar.text!
        songs?.removeAll()
        //add all songs to model -- songs array
        songs = MPMediaQuery.songs().items
        if searchText == "" {
            //No need to filter, keep all songs
            self.tableView.reloadData()
            return
        }

        let filteredSongs = songs?.filter() { (item: MPMediaItem) -> Bool in
            if (item.title == nil || !(item.title?.lowercased().contains(searchText.lowercased()))!) && (item.artist == nil || !(item.artist?.lowercased().contains(searchText.lowercased()))!) {
                return false
            } else {
                return true
            }
        }
        //Updata model to contain filtered array
        songs = filteredSongs
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let songCount = songs?.count {
            return songCount
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addSongCell", for: indexPath)

        if let songCell = cell as? AddSongTableViewCell {
            songCell.songTitle.text = songs?[indexPath.row].title
            songCell.artistLabel.text = songs?[indexPath.row].artist
            let art = songs?[indexPath.row].artwork
            if let artwork = art?.image(at: songCell.artwork.bounds.size) {
                songCell.artwork.image = artwork
            } else {
                //No artwork available, use default image
                let song = #imageLiteral(resourceName: "music")
                songCell.artwork.image = song
            }
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add song unwind" {
            if let individualPlaylistMVC = segue.destination as? IndividualPlaylistTableViewController {
                if let sendingSongCell = sender as? AddSongTableViewCell {
                    if let sendingSongObject = self.songs?[(self.tableView.indexPath(for: sendingSongCell)?.row)!] {
                        individualPlaylistMVC.songToAddTitle = sendingSongObject.title!
                        individualPlaylistMVC.songToAddArtist = sendingSongObject.artist!
                        if let songArtwork = sendingSongObject.artwork {
                            individualPlaylistMVC.songToAddArtwork = songArtwork.image(at: sendingSongCell.artwork.bounds.size)
                        } else {
                            individualPlaylistMVC.songToAddArtwork = #imageLiteral(resourceName: "music")
                        }
                        individualPlaylistMVC.songToAddURL = sendingSongObject.assetURL as NSURL?
                    }
                }
            }
        }
    }
    

}

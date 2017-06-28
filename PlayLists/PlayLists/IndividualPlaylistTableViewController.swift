//
//  IndividualPlaylistTableViewController.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/20/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

/*
 * Class defined to display all songs in a given playlistTitle in a UITableView
 */
class IndividualPlaylistTableViewController: UITableViewController,UISearchResultsUpdating {
    
    //Search controller to filter songs in playlist
    let searchControl = UISearchController(searchResultsController: nil)
    //Model -- Display all songs which belong to this playlist
    var playlistTitle: String?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    //Model -- Array of Song objects
    var songsInPlaylist: [Song]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    let DEF_HEIGHT: CGFloat = 100
    //Used in unwind segue to add songs to core data playlist
    var songToAddTitle: String = ""
    var songToAddArtist: String = ""
    var songToAddArtwork: UIImage?
    var songToAddURL: NSURL?
    
    //Unwind Segue -- Create or find new song in core data
    @IBAction func addSongSegue(segue: UIStoryboardSegue) {
        container?.performBackgroundTask { context in
            var song: (Bool,Song)? = nil
            let data = UIImagePNGRepresentation(self.songToAddArtwork!) as NSData?
            if let imageData = data {
                song = try? Song.createOrFindSongs(from: self.playlistTitle!, title: self.songToAddTitle, artist: self.songToAddArtist, artwork: imageData,url: self.songToAddURL!, context: context)
                if !(song?.0)! {
                    //Song is in playlist -- prompt user
                    self.songAlreadyExists()
                } else {
                    //New Song object created -- update model
                    try? context.save()
                    self.updateModel()
                }
            }
        }
    }
    
    //Play song using AVPlayer if table cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedSong = songsInPlaylist?[indexPath.row] {
            let songURL = URL(string: selectedSong.url!)
            let player = AVPlayer(url: songURL!)
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            if searchControl.isActive {
                //Dismiss search controller
                searchControl.isActive = false
            }
            self.present(playerVC, animated: true) {
                playerVC.player?.play()
            }
        }
    }
    
    //Clear songsInPlaylist and reload with most recent playlist model -- all songs
    private func updateModel() {
        if let context = container?.viewContext {
            if let title = playlistTitle {
                if let allSongs = (try? Song.getAll(playlist: title,context: context)) {
                    songsInPlaylist?.removeAll()
                    songsInPlaylist = allSongs
                }
            }
        }
    }
    
    //Alert the user if the selected song to add already exists in the playlist
    private func songAlreadyExists() {
        DispatchQueue.main.async {
            let alreadyExistsAlert = UIAlertController(
                title: "Duplicate Song",
                message: "A Song With This Title Already Exists In This Playlist!",
                preferredStyle: .alert
            )
            
            alreadyExistsAlert.addAction(UIAlertAction(
                title: "Cancel",
                style: .destructive)
            {(action: UIAlertAction) -> Void in
                }
            )
            self.present(alreadyExistsAlert, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let pTitle = playlistTitle {
            self.title = pTitle
        }
        searchControl.searchResultsUpdater = self
        searchControl.dimsBackgroundDuringPresentation = false
        searchControl.searchBar.sizeToFit()
        searchControl.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = searchControl.searchBar
        self.updateModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Search Controller Protocol
    //Used to filter model to contain searched for terms
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchControl.searchBar.text!
        self.updateModel()
        if searchText == "" {
            //No search term, do not filter
            return
        }
        let filteredSongs = songsInPlaylist?.filter() { (song: Song) -> Bool in
            if (song.title == nil || !(song.title?.lowercased().contains(searchText.lowercased()))!) && (song.artist == nil || !(song.artist?.lowercased().contains(searchText.lowercased()))!) {
                //if artist field and song title field do not match, return false
                return false
            } else {
                //one of artist or song title field matched
                return true
            }
        }
        //Update model to contain filtered array
        songsInPlaylist = filteredSongs
    }
    
    // MARK: Edit Table View
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Delete song from database, remove from model
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            container?.performBackgroundTask { context in
                let toDeleteSong = self.songsInPlaylist?[indexPath.row]
                if let toDelete = try? Song.remove(from: self.playlistTitle!, title: (toDeleteSong?.title)!, artist: (toDeleteSong?.artist)!, context: context) {
                    context.delete(toDelete!)
                    try? context.save()
                    self.updateModel()
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = songsInPlaylist?.count {
            return count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DEF_HEIGHT
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "individualPlaylistCell", for: indexPath)
        if let individualCell = cell as? IndividualPlaylistTableViewCell {
            individualCell.songTitleLabel.text = songsInPlaylist?[indexPath.row].title
            individualCell.artistLabel.text = songsInPlaylist?[indexPath.row].artist
            if let artwork = UIImage(data: (songsInPlaylist?[indexPath.row].artwork)! as Data) {
                individualCell.artwork.image = artwork
            }
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    

}

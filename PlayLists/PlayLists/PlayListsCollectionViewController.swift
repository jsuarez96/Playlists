//
//  PlayListsCollectionViewController.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/20/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit
import CoreData


private let reuseIdentifier = "PlaylistCell"
private let itemsPerRow: CGFloat = 2
private let sectionInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
private let DELETE_TOUCHES = 1
private let DELETE_DURATION = 1.5

/*
 * Class defines UICollectionViewController to display all of a user's created playlists
 */
class PlayListsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //model data -- array of playlist objects
    var playlists: [Playlist]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    //Prompt user to either create a new playlist or cancel
    @IBAction func addPlayList(_ sender: UIBarButtonItem) {
        PlayListAlert()
    }
    
    private func PlayListAlert() {
        let addPlaylistAlert = UIAlertController(
            title: "Create New Playlist",
            message: "New Playlist's title",
            preferredStyle: .alert
        )
        
        addPlaylistAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .destructive)
        {(action: UIAlertAction) -> Void in
            }
        )
        
        addPlaylistAlert.addAction(UIAlertAction(
            title: "Add",
            style: .default)
        {(action: UIAlertAction) -> Void in
            if let playlistTitle = addPlaylistAlert.textFields?.first?.text {
                self.createPlaylist(title: playlistTitle)
            }
            }
        )
        
        addPlaylistAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "PlayList Title"
        })
        
        present(addPlaylistAlert, animated: true, completion: nil)
    }
    
    //Alert user playlist with title already exists
    private func playlistAlreadyExists() {
        DispatchQueue.main.async {
            let alreadyExistsAlert = UIAlertController(
                title: "Duplicate Playlist",
                message: "A Playlist With This Title Already Exists!",
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
    
    //Clear current playlists array and update with most recent playlist model
    private func updateModel() {
        if let context = container?.viewContext {
            if let allPlaylists = (try? Playlist.getAll(context: context)) {
                playlists?.removeAll()
                playlists = allPlaylists
            }
        }
    }
    
    //Create or find playlist -- if title already exists, prompt user, else save and update model
    private func createPlaylist(title: String) {
        container?.performBackgroundTask { context in
            var playlist: (Bool,Playlist)? = nil
            playlist = try! Playlist.createOrFind(playlist: title, context: context)
            if !(playlist?.0)! {
                self.playlistAlreadyExists()
            } else {
                try? context.save()
                self.updateModel()
            }
        }
    }

    //Remove playlist title from database, update the current model
    private func deletePlayList(_ item: Int) {
        let toDelete = playlists?[item]
        if let deleteTitle = toDelete?.name {
            container?.performBackgroundTask{ context in
                if let toDeletePlaylist = try? Playlist.remove(playlist: deleteTitle, context: context) {
                    context.delete(toDeletePlaylist)
                    try? context.save()
                    self.updateModel()
                }
            }
        }
    }
    
    //Prompt user to delete selected playlist from database
    private func deleteAlert(at: IndexPath) {
        let deleteAlert = UIAlertController(
            title: "Delete Playlist",
            message: "Would You Like To Delete This Playlist?",
            preferredStyle: .alert
        )
        
        deleteAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .default)
        {(action: UIAlertAction) -> Void in
        })
        
        deleteAlert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive)
        {(action: UIAlertAction) -> Void in
            self.deletePlayList(at.item)
        })
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    //Long gesture recognizer -- used to delete playlists via long press on collection view cell
    func longGesture(byReactingTo: UILongPressGestureRecognizer) {
        if byReactingTo.state == .began {
            let location = byReactingTo.location(in: self.collectionView)
            let indexPath = self.collectionView?.indexPathForItem(at: location)
            if let selectedIndexPath = indexPath {
                deleteAlert(at: selectedIndexPath)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My PlayLists"
        self.updateModel()
        //Create deletion handler and add recognizer to collection view
        let deleteHandler = #selector(PlayListsCollectionViewController.longGesture(byReactingTo:))
        let longGest = UILongPressGestureRecognizer(target: self, action: deleteHandler)
        longGest.numberOfTouchesRequired = DELETE_TOUCHES
        longGest.minimumPressDuration = DELETE_DURATION
        self.collectionView?.addGestureRecognizer(longGest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Playlist" {
            if let destinationVC = segue.destination as? IndividualPlaylistTableViewController {
                if let sendingPlaylist = sender as? PlayListCollectionViewCell {
                    destinationVC.playlistTitle = sendingPlaylist.playListTitle.text
                }
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padSpace
        let widthPerItem =  availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = playlists?.count {
            return count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let playListCell = cell as? PlayListCollectionViewCell {
            playListCell.backgroundColor = UIColor.black
            if let playlist = playlists?[indexPath.item] { 
                playListCell.playListTitle.text = playlist.name
            }
        }
        return cell
    }
    
}

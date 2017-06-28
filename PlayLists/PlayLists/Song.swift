//
//  Song.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/22/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit
import CoreData

/*
 * Class defining Song NSManagedObject. Song contains title, artist, album artwork and a url.
 * Many songs point to one playlist
 */
class Song: NSManagedObject {
    
    //Creates a song or returns a song if it already exists in a given playlist
    //Returns tuple (bool,song). If bool is false, song already existed, if bool is true, song was newly created
    static func createOrFindSongs(from playlist: String,title: String, artist: String, artwork: NSData, url: NSURL ,context: NSManagedObjectContext)  throws -> (Bool,Song) {
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        //Playlist in which song will belong to
        let parentPlaylist = try? Playlist.createOrFind(playlist: playlist, context: context)
        request.predicate = NSPredicate(format: "playlist = %@ && artist = %@ && title = %@", (parentPlaylist??.playlist)!,artist,title) 
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                //Song found in playlist
                return (false,matches[0])
            } else {
                let newSong = Song(context: context)
                newSong.artist = artist
                newSong.title = title
                newSong.artwork = artwork
                newSong.playlist = parentPlaylist??.playlist
                newSong.url = url.absoluteString
                //New song created
                return (true,newSong)
            }
        } catch {
            throw error
        }
    }
    
    //Returns song -- used to remove from database
    static func remove(from playlist: String,title: String, artist: String,context: NSManagedObjectContext)  throws -> Song? {
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        let parentPlaylist = try? Playlist.createOrFind(playlist: playlist, context: context)
        request.predicate = NSPredicate(format: "playlist = %@ && artist = %@ && title = %@", (parentPlaylist??.playlist)!,artist,title)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return matches[0]
            } else {
                return nil
            }
        } catch {
            throw error
        }
    }
    
    //Returns all songs that belong to a given playlist
    static func getAll(playlist: String, context: NSManagedObjectContext) throws -> [Song] {
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        let parentPlaylist = try? Playlist.createOrFind(playlist: playlist, context: context)
        request.predicate = NSPredicate(format: "playlist = %@" , (parentPlaylist??.playlist)!)
        do {
            let matches = try context.fetch(request)
            return matches
        } catch {
            throw error
        }
    }

}

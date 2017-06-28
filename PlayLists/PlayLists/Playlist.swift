//
//  Playlist.swift
//  PlayLists
//
//  Created by Jose Suarez-Rodriguez on 6/22/17.
//  Copyright © 2017 Jose Suarez-Rodriguez. All rights reserved.
//

import UIKit
import CoreData

/*
 * Class defining playlist object. Playlist has a name and is associated with multiple Songs
 */
class Playlist: NSManagedObject {
    
    /*If a playlist with *name* exists, it will be returned. Else, one will be created and returned
    Returns a tuple with (boolean,playlist). If playlist already existed, bool will be false, if newly created
    boolean will be true.
    */
    static func createOrFind(playlist name: String, context: NSManagedObjectContext) throws -> (created: Bool,playlist: Playlist)? {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        do {
            let matches = try context.fetch(request)
            //Only a single playlist with name should exist
            assert(matches.count < 2, "Database Inconsistency")
            if matches.count > 0 {
                //Playlist with same name found in database
                return (false,matches[0])
            } else {
                //New playlist created with title: name
                let playlist = Playlist(context: context)
                playlist.name = name
                return (true,playlist)
            }
        } catch {
            throw error
        }
    }

    //Return playlist with title: name. Used to delete from the database
    static func remove(playlist name: String, context: NSManagedObjectContext) throws -> Playlist {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        do {
            let matches = try context.fetch(request)
            assert(matches.count == 1, "Database Inconsistency")
            return matches[0]
        } catch {
            throw error   
        }
    }
    
    //Returns all of the playlists stored in the database
    static func getAll(context: NSManagedObjectContext)throws -> [Playlist] {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        do {
            let matches = try context.fetch(request)
            return matches
        } catch {
            throw error
        }
    }
}

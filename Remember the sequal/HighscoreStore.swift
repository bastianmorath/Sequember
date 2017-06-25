//
//  File.swift
//  Sequember
//
//  Created by Bastian Morath on 3/6/16.
//  Copyright © 2016 Bastian Morath. All rights reserved.
//

import Foundation
import CoreData
import AddressBook
import UIKit


final class HighscoreStore: NSObject{
    
    var coreDataStore: ACoreDataStore = ACoreDataStore.sharedInstance
    var coreDataPortal: ACoreDataPortal = ACoreDataStore.sharedInstance
    
    /**
     Singleton function returns the default Instance of this Store.
     
     :returns: returns the default instance.
     */
    static let sharedInstance: HighscoreStore = { HighscoreStore() }()
    
    
    
    
    /**************************** READ Methods **********************************/
    func getHighscore() -> Highscore{
        let highscoreArray = self.coreDataStore.performFetch(entityName: "Highscore") as! [Highscore]
        return highscoreArray.first!

    }
    
    /**************************** WRITE Methods **********************************/
    func createHighscore(score: Double) -> Highscore? {
        let highscore = self.coreDataPortal.createObject(entityName: "Highscore") as? Highscore
        highscore?.highscore = score as NSNumber
        self.coreDataPortal.save()
        return highscore
    }
}

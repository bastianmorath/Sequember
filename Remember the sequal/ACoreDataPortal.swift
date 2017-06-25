//
//  ACoreDataPortal.swift
//  Trainer
//
//  Created by Lukas Reichart on 18/12/14.
//  Copyright (c) 2014 Antum. All rights reserved.
//

import Foundation
import CoreData

/**
*  ACoreDataPortal is a wrapper for one NSManagedObjectContext.
*  It provides an interface for creating, editing and deleting objects in his
*  NSManagedObjectContext.
*
*   TODO: Add NSUndoManager support for each Core Data Portal.

    Naming: ACoreDataPortal because portals are awesome. :D
*/
class ACoreDataPortal: NSObject {
  /// The NSManagedObjectContext managed by this object.
  internal var managedObjectContext: NSManagedObjectContext!
  
  /// Every Portal can have a parentPortal. This is important for saving:
  /// the paranet portal is autmatically saved, when the child portal is saved.
  internal var parentPortal: ACoreDataPortal?
  
  /// If AutoSave is set to true, the object will autmatically save the
  /// NSManagedObjectContext every time an object is added or deleted.
  var autoSave = false
  
  /**
  This initializers is only used in subclasses, that do their init work.
  */
  internal override init() {
    super.init()
  }
  
  /**
  Standard initializer of this class.
  
  :param: managedObjectContext The NSManagedObjectContext, that this portal should manager.
  :param: parentPortal         Optional parent of this Portal
  */
  init( managedObjectContext: NSManagedObjectContext, Parent parentPortal: ACoreDataPortal? = nil ) {
    super.init()
    
    self.managedObjectContext = managedObjectContext
    self.parentPortal = parentPortal
  }
  
  /**
  Creates a new NSManagedObject in the NSManagedObjectContext of this CoreDataPortal.
  
  :param: tableName Name of the entity to create
  
  :returns: the newly created NSManagedObject as an optional.
  */
  func createObject( entityName: String ) -> NSManagedObject? {
    let res: AnyObject? = NSEntityDescription.insertNewObject( forEntityName: entityName, into: self.managedObjectContext )
    return res as? NSManagedObject
  }
  
  /**
  Deletes the provided NSManagedObject from the NSManagedObjectContext.
  
  :param: object the NSManagedObject that should be deleted.
  */
  func deleteObject( object: NSManagedObject ) {
    managedObjectContext.delete( object )
  }
  
  /**
  Saves the NSManagedObjectContext of this CoreDataPortal. Calls also save on its parent.
  The saving is handled asynchronus, so the main thread is not blocked.
  */
  func save() {
    // push the changes to the parent

      // call save on the parent
      self.parentPortal?.save()
  }


}

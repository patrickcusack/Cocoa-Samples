//
//  ViewController.swift
//  Cocoa Binding
//
//  Created by Szabolcs Toth on 30/04/2020.
//  Copyright © 2020 purzelbaum.hu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    @objc dynamic var peopleArray: [Person] = [Person(firstName: "Ragnar", lastName: "Lothbrok", mobileNumber: "555-12347"),
                                               Person(firstName: "Bjorn", lastName: "Lothbrok", mobileNumber: "555-34129"),
                                               Person(firstName: "Harald", lastName: "Finehair", mobileNumber: "555-45128")
                                                ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        if (tableColumn?.identifier)!.rawValue == "firstName" {
            cell.objectValue = peopleArray[row]
        }
        
        return cell
    }
    
    func tableView(
        _ tableView: NSTableView,
        validateDrop info: NSDraggingInfo,
        proposedRow row: Int,
        proposedDropOperation dropOperation: NSTableView.DropOperation)
        -> NSDragOperation
    {
        // info.draggingSource is nil when the source is in a different application.
        // This disallows drags from other apps, sources within the same app that
        // aren’t NSTableViews, and drags from the left table view.
        return .copy
    }
    
//    tableView.registerForDraggedTypes([.fileURL])
//    tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
//    [nextTableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
//    [nextTableView setDraggingSourceOperationMask:(NSDragOperationCopy | NSDragOperationMove) forLocal:YES];
//    [nextTableView registerForDraggedTypes: [NSArray arrayWithObjects:CopiedRowsType, MovedRowsType, nil]];

    func tableView(
        _ tableView: NSTableView,
        acceptDrop info: NSDraggingInfo,
        row: Int,
        dropOperation: NSTableView.DropOperation) -> Bool
    {
        let pboard = info.draggingPasteboard

        if let stringTypes = pboard.readObjects(forClasses: [NSString.self], options: [:]) as? [NSString] {
            for s in stringTypes {
                
            }
        }

        tableView.reloadData()
        return true
    }
    
    
}



/*

 //MARK: Drag 'n Drop
 
- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;

*/

/*

- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard
{

    // declare our own pasteboard types
    NSArray *typesArray = [NSArray arrayWithObjects:CopiedRowsType, MovedRowsType, nil];

    [pboard declareTypes:typesArray owner:self];

    // add rows array for local move
    NSData *rowIndexesArchive = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard setData:rowIndexesArchive forType:MovedRowsType];

    // create new array of selected rows for remote drop
    // could do deferred provision, but keep it direct for clarity

    NSMutableArray *rowCopies = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
    NSUInteger currentIndex = [rowIndexes firstIndex];
    while (currentIndex != NSNotFound){
        [rowCopies addObject:[[self arrangedObjects] objectAtIndex:currentIndex]];
        currentIndex = [rowIndexes indexGreaterThanIndex: currentIndex];
    }

    // setPropertyList works here because we're using dictionaries, strings,
    // and dates; otherwise, archive collection to NSData...
    //[pboard setPropertyList:rowCopies forType:CopiedRowsType];
 
    NSDictionary *copiedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                [self tableViewType],
                                @"tableType",
                                rowCopies,
                                @"rows",
                                [myDocument performSelector:@selector(uuid)],
                                @"uuid",
                                nil];

    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:copiedData] forType:CopiedRowsType];

    return YES;
}

 */

/*
 
- (NSDragOperation)tableView:(NSTableView*)tv
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(int)row
       proposedDropOperation:(NSTableViewDropOperation)op
{
    //dropping video onto track
    if([[self tableViewType] isEqualToString:@"versionTableView"]){
        if([[[info draggingPasteboard] types] containsObject:NSFilenamesPboardType]){
            [tv setDropRow:row dropOperation:NSTableViewDropOn];
            return NSDragOperationLink;
        }
    }

    NSDragOperation dragOp = NSDragOperationCopy;

    //we do not want to validate drops from other doc into anything other than the masterTableView
    if([[[info draggingSource] window] delegate] != [[tv window] delegate]){
        if(![[[self myController] name] isEqualToString:MASTERCUES]){
            if([[self tableViewType] isEqualToString:@"cueTableView"]){
                return NSDragOperationNone;
            }
        }
    }

    // if drag source is self, it's a move unless the Option key is pressed
    if ([info draggingSource] == tableView) {

        NSEvent *currentEvent = [NSApp currentEvent];
        int optionKeyPressed = [currentEvent modifierFlags] & NSAlternateKeyMask;
        if (optionKeyPressed == 0) {
            dragOp =  NSDragOperationMove;
        }
    }

    NSData *droppedData = [[info draggingPasteboard] dataForType:CopiedRowsType];
    NSDictionary *dropCopiedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:droppedData];

    if(![[self tableViewType] isEqualToString:[dropCopiedObjects valueForKey:@"tableType"]]){
        return NSDragOperationNone;
    }

    // we want to put the object at, not over,
    // the current row (contrast NSTableViewDropOn)
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];

    return dragOp;
}

 */

/*
 
- (BOOL)tableView:(NSTableView*)tv
       acceptDrop:(id <NSDraggingInfo>)info
              row:(int)row
    dropOperation:(NSTableViewDropOperation)op
{
 
 
    //dropping video onto track
    if([[self tableViewType] isEqualToString:@"versionTableView"]){
        if([[[info draggingPasteboard] types] containsObject:NSFilenamesPboardType]){
            if([[self arrangedObjects] count] > 0){
                NSString *firstName = [[[info draggingPasteboard] propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
                if([[NSFileManager defaultManager] fileExistsAtPath:firstName]){
                    [[[self arrangedObjects] objectAtIndex:row] setValue:firstName forKey:@"moviePath"];
                    return YES;
                }
            }
            return NO;
        }
    }
    
    if (row < 0) {
        row = 0;
    }
    
    // if drag source is self, it's a move unless the Option key is pressed
    if ([info draggingSource] == tableView) {
        
        NSEvent *currentEvent = [NSApp currentEvent];
        int optionKeyPressed = [currentEvent modifierFlags] & NSAlternateKeyMask;
        
        if (optionKeyPressed == 0) {
            
            NSData *rowsData = [[info draggingPasteboard] dataForType:MovedRowsType];
            NSIndexSet *indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
            //NSLog(@"%@", indexSet);
            
            NSIndexSet *destinationIndexes = [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
            // set selected rows to those that were just moved
            [self setSelectionIndexes:destinationIndexes];
            
            return YES;
        }
    }
    
    // Can we get rows from another document?  If so, add them, then return.
    NSData *droppedData = [[info draggingPasteboard] dataForType:CopiedRowsType];
    NSDictionary *dropCopiedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:droppedData];
    NSArray *newRows = [dropCopiedObjects valueForKey:@"rows"];
    MyDocument * sourceDocument = (MyDocument*)[[[info draggingSource] window] delegate];
    
    if (newRows) {
        //DRAGGING FROM ANOTHER DOCUMENT
        if(myDocument != sourceDocument){
            NSArray *copyOfNewRows = [NSArray arrayWithArray:newRows];
            unsigned int intendedCount = [copyOfNewRows count];
        
            
            if(intendedCount != [copyOfNewRows count]){
                
                NSAlert * alertPanel = [[NSAlert alloc] init];
                [alertPanel setMessageText:@"Some of the material you are dragging already exist."];
                [alertPanel setInformativeText:@"Would you like me to add the material that doesn't already exist?"];
                [alertPanel addButtonWithTitle:@"Add"];
                [alertPanel addButtonWithTitle:@"Cancel"];
                NSInteger alertResult = [alertPanel runModal];
                [alertPanel release];

                if (alertResult == NSAlertFirstButtonReturn) {
                    newRows = copyOfNewRows;
                } else if (alertResult == NSAlertSecondButtonReturn){
                    return NO;
                }
            }
            
        }
        
        NSRange range = NSMakeRange(row, [newRows count]);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        
        //we're in the master folder
        
        [self insertObjects:newRows atArrangedObjectIndexes:indexSet];
        // set selected rows to those that were just copied
        [self setSelectionIndexes:indexSet];
        return YES;
    }
    
    return NO;
}

*/

/*

-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet
                                                toIndex:(unsigned int)insertIndex
{
    // If any of the removed objects come before the insertion index,
    // we need to decrement the index appropriately
    unsigned int adjustedInsertIndex =
    insertIndex - [fromIndexSet countOfIndexesInRange:(NSRange){0, insertIndex}];
    NSRange destinationRange = NSMakeRange(adjustedInsertIndex, [fromIndexSet count]);
    NSIndexSet *destinationIndexes = [NSIndexSet indexSetWithIndexesInRange:destinationRange];
    
    [self setIsAboutToRemove:YES];
    [self setIsMoving:YES];
    
    NSArray *objectsToMove = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
    [self removeObjectsAtArrangedObjectIndexes:fromIndexSet];
    [self insertObjects:objectsToMove atArrangedObjectIndexes:destinationIndexes];
    
    [self setIsMoving:NO];
    
    return destinationIndexes;
}

*/

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
NSTableCellView subclass for handling drag images.
*/

import Cocoa

class TableCellView: NSTableCellView {
	
    /** We override draggingImageComponents for two reasons:
        1. To include both the image and text in the drag image since they each appear in their own separate columns.
        2. To layout the drag image so the image is aligned on top of the text.
    */
    override var draggingImageComponents: [NSDraggingImageComponent] {

        var imageComponents = super.draggingImageComponents

        if let photoItem = objectValue as? PhotoItem {
            // 1) Create the text label component for the drag.
            
            /** Note: once you have an textField assigned to the outlet of NSTableCellView storyboard,
                it will automatically use it and do the correct thing for you.
                We get that by earlier calling 'super.draggingImageComponents'
            */
            if textField != nil {
                // We found the textField, our call to super has already given us its drag image.
            } else {
                // The 'textField' outlet is not wired up to this table view cell. So we need to create our own text image for the image drag.
                let customTextField = NSTextField(frame: NSRect())
                customTextField.stringValue = photoItem.title
                customTextField.sizeToFit()
                if let imageRep = customTextField.bitmapImageRepForCachingDisplay(in: customTextField.bounds) {
                    customTextField.cacheDisplay(in: customTextField.bounds, to: imageRep)
                    let draggedImage = NSImage(size: imageRep.size)
                    draggedImage.addRepresentation(imageRep)
                    let labelComponent = NSDraggingImageComponent(key: .label)
                    labelComponent.contents = draggedImage
                    
                    let xPos = (frame.size.width - imageRep.size.width ) / 2
                    labelComponent.frame = NSRect(x: xPos, y: -6.0, width: imageRep.size.width, height: imageRep.size.height)
                    imageComponents.append(labelComponent)
                }
            }

            // 2) Create the image component for the drag.
            
            /** Note: once you have an imageView assigned to the outlet of NSTableCellView storyboard,
                it will automatically use it and do the correct thing with respect to the drag image size and aspect ratio.
            */
            if imageView != nil {
                // We found the imageView, our call to super has already given us its image.
            } else {
                /** The 'imageView' outlet is not wired up to this table view cell.
                    So we need to create our own image for the image drag.
                */
                
                /** The image we supply for dragging will be stretched to meet the dragging frame
                    So we need to figure out the aspect ratio of the drag image so we can calculate the appropriate component frame.
                */
                
                /** The key for an image component should be either IconKey or LabelKey
                    If you only have one drag image, it's always IconKey. In this case, it really is the icon and not the label.
                    Note: Once you have an icon, (and maybe an label component) if you have a 3rd (or more) component(s)
                    then they each should have a unique key. That key is unique to the component's use, not some propery of the
                    item being dragged. For example, perhaps there is is a "background" component, or a "badge", etc...
                */
                let aComponent = NSDraggingImageComponent(key: .icon)
                if let theImage = photoItem.thumbnailImage {
                    aComponent.contents = theImage
            
                    let aspectRatio = theImage.size.width / theImage.size.height
                    var componentFrame = NSRect.zero
                    let imageViewSize = theImage.size
                    if theImage.size.width > theImage.size.height {
                        componentFrame.size.width = imageViewSize.width
                        componentFrame.size.height = imageViewSize.width / aspectRatio
                    } else {
                        componentFrame.size.width = imageViewSize.height * aspectRatio
                        componentFrame.size.height = imageViewSize.height
                    }
                    
                    let fontAttributes = [NSAttributedString.Key.font: textField?.font]
                    let size = textField!.stringValue.size(withAttributes: fontAttributes as [NSAttributedString.Key: Any])
                    componentFrame.origin.x = (size.width - imageViewSize.width) / 2
                    componentFrame.origin.y = textField!.frame.origin.y + textField!.frame.size.height + 6.0
                    aComponent.frame = componentFrame

                    imageComponents.append(aComponent)
                }
            }
        }
        
        return imageComponents
    }
    
}

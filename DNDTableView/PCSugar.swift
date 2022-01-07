//
//  PCSugar.swift
//  Forney-cator
//
//  Created by Patrick Cusack on 9/25/21.
//

import Cocoa
import Foundation

func framesToTimeCode(frameRate: Int = 24, frames:Int, offset: Int = 0, escaped: Bool = false) -> String {
    
    var total = (frames + offset)
    
    let hour = total / (60*60*frameRate)
    total = total % (60*60*frameRate)
    
    let min = total / (60*frameRate)
    total = total % (60*frameRate)
    
    let sec = total / frameRate
    let frames = total % frameRate
    
    if escaped == true {
        return String(format: "%02d", hour) + #"\:"# + String(format: "%02d",min) + #"\:"# + String(format: "%02d",sec) + #"\:"# + String(format: "%02d",frames)
    }
    
    return String(format: "%02d", hour) + ":" + String(format: "%02d",min) + ":" + String(format: "%02d",sec) + ":" + String(format: "%02d",frames)
}

func framesToFootage(frames:Int, offset: Int = 0) -> String {
    
    let total = (frames + offset)
    let feet = total / 16
    let frames = total % 16
    
    return (String(format: "%05d", feet) + "+" + String(format: "%02d", frames))
}

func createTempDirectory() -> String {
    return NSTemporaryDirectory()
}

func dialogOKCancel(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
}
func showModalMessage(msg:String, info:String) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

func getJSON(data:Data) throws -> [String: AnyObject]? {
    return try (JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject])
}


extension String {
    var fileName: String {
       URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    var fileExtension: String{
       URL(fileURLWithPath: self).pathExtension
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func timeToSeconds() -> Float {
        let components = self.components(separatedBy: CharacterSet.init(charactersIn: ":"))
        if components.count != 3 {
            return 0.0
        }
        let hour = 60 * 60 * (Int(components[0]) ?? 0)
        let min = 60 * (Int(components[1]) ?? 0)
        let seconds = (Float(components[2]) ?? 0.0)
        return Float(hour) + Float(min) + seconds
    }
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
 
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
    
//    let filepath = "KidProblems_P3_Source_r1.mov"
//    if let range = filepath.range(of: #"_[rR][0-9]\."#, options: .regularExpression) {
//        print(filepath)
//        print(filepath[range])
//    }
    
    func matchesForRegex(pattern:String) -> [String] {
        
        var results = [String]()
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(self.startIndex..<self.endIndex,
                                  in: self)
            
            regex.enumerateMatches(in:self,
                                   options: [],
                                   range: nsrange) { (match, _, stop) in
                guard let match = match else { return}

                for x in 0..<match.numberOfRanges {
                    if let r = Range(match.range(at: x), in:self) {
                        results.append(String(self[r]))
                    }
                }
            }

        } catch  {
            print("\(error)")
        }
        
        return results
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

//https://stackoverflow.com/questions/35700281/date-format-in-swift
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}


func randomNameString(length: Int = 10)->String{
    
    enum s {
        static let c = Array("abcdefghjklmnopqrstuvwxyz123457890")
        static let k = UInt32(c.count)
    }
    
    var result = [Character](repeating: "-", count: length)
    
    for i in 0..<length {
        let r = Int(arc4random_uniform(s.k))
        result[i] = s.c[r]
    }
    
    return String(result)
}

func makeRandomTempFile(ext: String) -> String? {
    return (createTempDirectory() as NSString).appendingPathComponent("temp_" + randomNameString() + "." + ext)
}

extension NSColor {

    var hexString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "000000FF"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let alpha = Int(round(rgbColor.alphaComponent * 0xFF))
        let hexString = NSString(format: "%02X%02X%02X%02X", red, green, blue, alpha)
        return hexString as String
    }
    
    var hexStringNoAlpha: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "000000FF"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "%02X%02X%02X", red, green, blue)
        return hexString as String
    }
    
    var imageMagickString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "0,0,0,1.0"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        var alpha = rgbColor.alphaComponent;
        if alpha < 0.01 {
            alpha = 0.005
        }
        let hexString = NSString(format: "%d,%d,%d,%f", red, green, blue, alpha)
        return hexString as String
    }
    
    var imageMagickStringNoAlpha: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "0,0,0"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "%d,%d,%d", red, green, blue)
        return hexString as String
    }
}

extension NSImageView {

    /** Returns an `NSRect` of the drawn image in the view. */
    func imageRect() -> NSRect {
        // Find the content frame of the image without any borders first
        var contentFrame = self.bounds
        guard let imageSize = image?.size else { return .zero }
        let imageFrameStyle = self.imageFrameStyle

        if imageFrameStyle == .button || imageFrameStyle == .groove {
            contentFrame = NSInsetRect(self.bounds, 2, 2)
        } else if imageFrameStyle == .photo {
            contentFrame = NSRect(x: contentFrame.origin.x + 1, y: contentFrame.origin.x + 2, width: contentFrame.size.width - 3, height: contentFrame.size.height - 3)
        } else if imageFrameStyle == .grayBezel {
            contentFrame = NSInsetRect(self.bounds, 8, 8)
        }


        // Now find the right image size for the current imageScaling
        let imageScaling = self.imageScaling
        var drawingSize = imageSize

        // Proportionally scaling
        if imageScaling == .scaleProportionallyDown || imageScaling == .scaleProportionallyUpOrDown {
            var targetScaleSize = contentFrame.size
            if imageScaling == .scaleProportionallyDown {
                if targetScaleSize.width > imageSize.width { targetScaleSize.width = imageSize.width }
                if targetScaleSize.height > imageSize.height { targetScaleSize.height = imageSize.height }
            }

            let scaledSize = self.sizeByScalingProportianlly(toSize: targetScaleSize, fromSize: imageSize)
            drawingSize = NSSize(width: scaledSize.width, height: scaledSize.height)
        }

        // Axes independent scaling
        else if imageScaling == .scaleAxesIndependently {
            drawingSize = contentFrame.size
        }


        // Now get the image position inside the content frame (center is default) from the current imageAlignment
        let imageAlignment = self.imageAlignment
        var drawingPosition = NSPoint(x: contentFrame.origin.x + contentFrame.size.width / 2 - drawingSize.width / 2,
                                      y: contentFrame.origin.y + contentFrame.size.height / 2 - drawingSize.height / 2)

        // Top Alignments
        if imageAlignment == .alignTop || imageAlignment == .alignTopLeft || imageAlignment == .alignTopRight {
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height

            if imageAlignment == .alignTopLeft {
                drawingPosition.x = contentFrame.origin.x
            } else if imageAlignment == .alignTopRight {
                drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
            }
        }

        // Bottom Alignments
        else if imageAlignment == .alignBottom || imageAlignment == .alignBottomLeft || imageAlignment == .alignBottomRight {
            drawingPosition.y = contentFrame.origin.y

            if imageAlignment == .alignBottomLeft {
                drawingPosition.x = contentFrame.origin.x
            } else if imageAlignment == .alignBottomRight {
                drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
            }
        }

        // Left Alignment
        else if imageAlignment == .alignLeft {
            drawingPosition.x = contentFrame.origin.x
        }

        // Right Alginment
        else if imageAlignment == .alignRight {
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        }

        return NSRect(x: round(drawingPosition.x), y: round(drawingPosition.y), width: ceil(drawingSize.width), height: ceil(drawingSize.height))
    }


    func sizeByScalingProportianlly(toSize newSize: NSSize, fromSize oldSize: NSSize) -> NSSize {
        let widthHeightDivision = oldSize.width / oldSize.height
        let heightWidthDivision = oldSize.height / oldSize.width

        var scaledSize = NSSize.zero

        if oldSize.width > oldSize.height {
            if (widthHeightDivision * newSize.height) >= newSize.width {
                scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
            } else {
                scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
            }
        } else {
            if (heightWidthDivision * newSize.width) >= newSize.height {
                scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
            } else {
                scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
            }
        }

        return scaledSize
    }
}

extension NSTableView {
    func reloadDataAndKeepSelection() {
        self.reloadData(forRowIndexes: self.selectedRowIndexes, columnIndexes: IndexSet.init(integer: 0))
    }
}

extension NSOpenPanel {
    var selectFolder: URL? {
        title = "Select Destination"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = false
        //allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls.first : nil
    }
//    var selectUrl: URL? {
//        title = "Select Image"
//        allowsMultipleSelection = false
//        canChooseDirectories = false
//        canChooseFiles = true
//        canCreateDirectories = false
//        allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
//        return runModal() == .OK ? urls.first : nil
//    }
//    var selectUrls: [URL]? {
//        title = "Select Images"
//        allowsMultipleSelection = true
//        canChooseDirectories = false
//        canChooseFiles = true
//        canCreateDirectories = false
//        allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
//        return runModal() == .OK ? urls : nil
//    }
}

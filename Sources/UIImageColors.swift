//
//  UIImageColors.swift
//  https://github.com/jathu/UIImageColors
//
//  Created by Jathu Satkunarajah (@jathu) on 2015-06-11 - Toronto
//  Original Cocoa version by Panic Inc. - Portland
//
// Useage:
// -------
//  let colors = imageView.image!.getColors()
//  backgroundColor = colors.backgroundColor
//  albumTitle.textColor = colors.primaryColor
//  artistTitle.textColor = colors.secondaryColor
//  yearLabel.textColor = colors.detailColor


import UIKit

public struct UIImageColors {
    public var backgroundColor: UIColor!
    public var primaryColor: UIColor!
    public var secondaryColor: UIColor!
    public var detailColor: UIColor!
}

class CountedColor {
    let color: UIColor
    let count: Int
    
    init(color: UIColor, count: Int) {
        self.color = color
        self.count = count
    }
}

extension UIColor {
    
    public var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let ciColor = CIColor(cgColor: self.cgColor)
        return (ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
    }
    
    public var isDarkColor: Bool {
        let rgb = components
        return (0.2126 * rgb.red + 0.7152 * rgb.green + 0.0722 * rgb.blue) < 0.5
    }
    
    public var isBlackOrWhite: Bool {
        let rgb = components
        return (rgb.red > 0.91 && rgb.green > 0.91 && rgb.blue > 0.91) || (rgb.red < 0.09 && rgb.green < 0.09 && rgb.blue < 0.09)
    }
    
    public func isDistinct(_ compareColor: UIColor) -> Bool {
        let bg = components
        let fg = compareColor.components
        let threshold: CGFloat = 0.25
        
        if fabs(bg.red - fg.red) > threshold || fabs(bg.green - fg.green) > threshold || fabs(bg.blue - fg.blue) > threshold {
            if fabs(bg.red - bg.green) < 0.03 && fabs(bg.red - bg.blue) < 0.03 {
                if fabs(fg.red - fg.green) < 0.03 && fabs(fg.red - fg.blue) < 0.03 {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    public func colorWithMinimumSaturation(_ minSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        if saturation < minSaturation {
            return UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
        } else {
            return self
        }
    }
    
    public func isContrastingColor(_ compareColor: UIColor) -> Bool {
        let bg = components
        let fg = compareColor.components
        
        let bgLum = 0.2126 * bg.red + 0.7152 * bg.green + 0.0722 * bg.blue
        let fgLum = 0.2126 * fg.red + 0.7152 * fg.green + 0.0722 * fg.blue
        let contrast = (bgLum > fgLum) ? (bgLum + 0.05)/(fgLum + 0.05):(fgLum + 0.05)/(bgLum + 0.05)
        
        return 1.6 < contrast
    }
}

extension UIImage {
    
    public func resize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: CGRect(x: 0, y:0, width: newSize.width, height: newSize.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    public func getColors() -> UIImageColors {
        let ratio = self.size.width/self.size.height
        let r_width: CGFloat = 250
        return self.getColors(CGSize(width: r_width, height: r_width / ratio))
    }
    
    public func getColors(_ scaleDownSize: CGSize) -> UIImageColors {
        var result = UIImageColors()
        
        let cgImage = self.resize(newSize: scaleDownSize).cgImage
        let width = cgImage!.width
        let height = cgImage!.height
        
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = width * bytesPerPixel
        let bitsPerComponent: Int = 8
        let randomColorsThreshold = Int(CGFloat(height)*0.01)
        let sortedColorComparator: Comparator = { (main, other) -> ComparisonResult in
            let m = main as! CountedColor, o = other as! CountedColor
            if m.count < o.count {
                return .orderedDescending
            } else if m.count == o.count {
                return .orderedSame
            } else {
                return .orderedAscending
            }
        }
        let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let whiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let raw = malloc(bytesPerRow * height)
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        let ctx = CGContext(data: raw, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        ctx!.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), image: cgImage!)
        let data = UnsafePointer<UInt8>(ctx!.data)
        
        let leftEdgeColors = NSCountedSet(capacity: height)
        let imageColors = NSCountedSet(capacity: width * height)
        
        for x in 0..<width {
            for y in 0..<height {
                let pixel = ((width * y) + x) * bytesPerPixel
                let color = UIColor(
                    red: CGFloat((data?[pixel+1])!)/255,
                    green: CGFloat((data?[pixel+2])!)/255,
                    blue: CGFloat((data?[pixel+3])!)/255,
                    alpha: 1
                )
                
                // A lot of albums have white or black edges from crops, so ignore the first few pixels
                if 5 <= x && x <= 10 {
                    leftEdgeColors.add(color)
                }
                
                imageColors.add(color)
            }
        }
        
        // Get background color
        var enumerator = leftEdgeColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: leftEdgeColors.count)
        while let kolor = enumerator.nextObject() as? UIColor {
            let colorCount = leftEdgeColors.count(for: kolor)
            if randomColorsThreshold < colorCount  {
                sortedColors.add(CountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        var proposedEdgeColor: CountedColor
        if 0 < sortedColors.count {
            proposedEdgeColor = sortedColors.object(at: 0) as! CountedColor
        } else {
            proposedEdgeColor = CountedColor(color: blackColor, count: 1)
        }
        
        if proposedEdgeColor.color.isBlackOrWhite && 0 < sortedColors.count {
            for i in 1..<sortedColors.count {
                let nextProposedEdgeColor = sortedColors.object(at: i) as! CountedColor
                if (CGFloat(nextProposedEdgeColor.count)/CGFloat(proposedEdgeColor.count)) > 0.3 {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        result.backgroundColor = proposedEdgeColor.color
        
        // Get foreground colors
        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !result.backgroundColor.isDarkColor
        
        while var kolor = enumerator.nextObject() as? UIColor {
            kolor = kolor.colorWithMinimumSaturation(0.15)
            if kolor.isDarkColor == findDarkTextColor {
                let colorCount = imageColors.count(for: kolor)
                sortedColors.add(CountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        for curContainer in sortedColors {
            let kolor = (curContainer as! CountedColor).color
            
            if result.primaryColor == nil {
                if kolor.isContrastingColor(result.backgroundColor) {
                    result.primaryColor = kolor
                }
            } else if result.secondaryColor == nil {
                if !result.primaryColor.isDistinct(kolor) || !kolor.isContrastingColor(result.backgroundColor) {
                    continue
                }
                
                result.secondaryColor = kolor
            } else if result.detailColor == nil {
                if !result.secondaryColor.isDistinct(kolor) || !result.primaryColor.isDistinct(kolor) || !kolor.isContrastingColor(result.backgroundColor) {
                    continue
                }
                
                result.detailColor = kolor
                break
            }
        }
        
        let isDarkBackgound = result.backgroundColor.isDarkColor
        
        if result.primaryColor == nil {
            result.primaryColor = isDarkBackgound ? whiteColor:blackColor
        }
        
        if result.secondaryColor == nil {
            result.secondaryColor = isDarkBackgound ? whiteColor:blackColor
        }
        
        if result.detailColor == nil {
            result.detailColor = isDarkBackgound ? whiteColor:blackColor
        }
        
        // Release the allocated memory
        free(raw)
        
        return result
    }
}

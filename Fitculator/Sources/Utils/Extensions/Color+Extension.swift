import SwiftUI

extension Color {
    static var fitculatorBackgroundColor: Color {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "181C31").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return Color(uiColor: UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        }
    }
    
    static var brightBackgroundColor: Color {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "272B3E").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return Color(uiColor: UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        }
    }
    
    static var tabButtonColor: Color {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "5BBFF6").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return Color(uiColor: UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        }
    }
    
    static var fatigueBackgroundColor: Color {
        get {
            return Color(uiColor: UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00))
        }
    }
    
    static var fatigueProgressColor: Color {
        get {
            return Color(uiColor: UIColor(red: 0.16, green: 0.82, blue: 0.25, alpha: 1.00))
        }
    }
    
    static var textFieldBackgrounColor: Color {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "2A3B65").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return Color(uiColor: UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        }
    }
}

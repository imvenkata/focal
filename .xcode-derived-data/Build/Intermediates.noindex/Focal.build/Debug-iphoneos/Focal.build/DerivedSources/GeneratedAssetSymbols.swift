import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "Amber" asset catalog color resource.
    static let amber = DeveloperToolsSupport.ColorResource(name: "Amber", bundle: resourceBundle)

    /// The "AmberLight" asset catalog color resource.
    static let amberLight = DeveloperToolsSupport.ColorResource(name: "AmberLight", bundle: resourceBundle)

    /// The "Background" asset catalog color resource.
    static let background = DeveloperToolsSupport.ColorResource(name: "Background", bundle: resourceBundle)

    /// The "BackgroundSecondary" asset catalog color resource.
    static let backgroundSecondary = DeveloperToolsSupport.ColorResource(name: "BackgroundSecondary", bundle: resourceBundle)

    /// The "BorderStrong" asset catalog color resource.
    static let borderStrong = DeveloperToolsSupport.ColorResource(name: "BorderStrong", bundle: resourceBundle)

    /// The "CardBackground" asset catalog color resource.
    static let cardBackground = DeveloperToolsSupport.ColorResource(name: "CardBackground", bundle: resourceBundle)

    /// The "Coral" asset catalog color resource.
    static let coral = DeveloperToolsSupport.ColorResource(name: "Coral", bundle: resourceBundle)

    /// The "CoralLight" asset catalog color resource.
    static let coralLight = DeveloperToolsSupport.ColorResource(name: "CoralLight", bundle: resourceBundle)

    /// The "Divider" asset catalog color resource.
    static let divider = DeveloperToolsSupport.ColorResource(name: "Divider", bundle: resourceBundle)

    /// The "Lavender" asset catalog color resource.
    static let lavender = DeveloperToolsSupport.ColorResource(name: "Lavender", bundle: resourceBundle)

    /// The "LavenderLight" asset catalog color resource.
    static let lavenderLight = DeveloperToolsSupport.ColorResource(name: "LavenderLight", bundle: resourceBundle)

    /// The "Night" asset catalog color resource.
    static let night = DeveloperToolsSupport.ColorResource(name: "Night", bundle: resourceBundle)

    /// The "NightLight" asset catalog color resource.
    static let nightLight = DeveloperToolsSupport.ColorResource(name: "NightLight", bundle: resourceBundle)

    /// The "Overlay" asset catalog color resource.
    static let overlay = DeveloperToolsSupport.ColorResource(name: "Overlay", bundle: resourceBundle)

    /// The "Rose" asset catalog color resource.
    static let rose = DeveloperToolsSupport.ColorResource(name: "Rose", bundle: resourceBundle)

    /// The "RoseLight" asset catalog color resource.
    static let roseLight = DeveloperToolsSupport.ColorResource(name: "RoseLight", bundle: resourceBundle)

    /// The "Sage" asset catalog color resource.
    static let sage = DeveloperToolsSupport.ColorResource(name: "Sage", bundle: resourceBundle)

    /// The "SageLight" asset catalog color resource.
    static let sageLight = DeveloperToolsSupport.ColorResource(name: "SageLight", bundle: resourceBundle)

    /// The "Sky" asset catalog color resource.
    static let sky = DeveloperToolsSupport.ColorResource(name: "Sky", bundle: resourceBundle)

    /// The "SkyLight" asset catalog color resource.
    static let skyLight = DeveloperToolsSupport.ColorResource(name: "SkyLight", bundle: resourceBundle)

    /// The "Slate" asset catalog color resource.
    static let slate = DeveloperToolsSupport.ColorResource(name: "Slate", bundle: resourceBundle)

    /// The "SlateLight" asset catalog color resource.
    static let slateLight = DeveloperToolsSupport.ColorResource(name: "SlateLight", bundle: resourceBundle)

    /// The "SurfaceSecondary" asset catalog color resource.
    static let surfaceSecondary = DeveloperToolsSupport.ColorResource(name: "SurfaceSecondary", bundle: resourceBundle)

    /// The "TextInverse" asset catalog color resource.
    static let textInverse = DeveloperToolsSupport.ColorResource(name: "TextInverse", bundle: resourceBundle)

    /// The "TextPrimary" asset catalog color resource.
    static let textPrimary = DeveloperToolsSupport.ColorResource(name: "TextPrimary", bundle: resourceBundle)

    /// The "TextSecondary" asset catalog color resource.
    static let textSecondary = DeveloperToolsSupport.ColorResource(name: "TextSecondary", bundle: resourceBundle)

    /// The "TextTertiary" asset catalog color resource.
    static let textTertiary = DeveloperToolsSupport.ColorResource(name: "TextTertiary", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AccentColor" asset catalog color.
    static var accent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "Amber" asset catalog color.
    static var amber: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .amber)
#else
        .init()
#endif
    }

    /// The "AmberLight" asset catalog color.
    static var amberLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .amberLight)
#else
        .init()
#endif
    }

    /// The "Background" asset catalog color.
    static var background: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "BackgroundSecondary" asset catalog color.
    static var backgroundSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backgroundSecondary)
#else
        .init()
#endif
    }

    /// The "BorderStrong" asset catalog color.
    static var borderStrong: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .borderStrong)
#else
        .init()
#endif
    }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cardBackground)
#else
        .init()
#endif
    }

    /// The "Coral" asset catalog color.
    static var coral: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coral)
#else
        .init()
#endif
    }

    /// The "CoralLight" asset catalog color.
    static var coralLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coralLight)
#else
        .init()
#endif
    }

    /// The "Divider" asset catalog color.
    static var divider: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .divider)
#else
        .init()
#endif
    }

    /// The "Lavender" asset catalog color.
    static var lavender: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lavender)
#else
        .init()
#endif
    }

    /// The "LavenderLight" asset catalog color.
    static var lavenderLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lavenderLight)
#else
        .init()
#endif
    }

    /// The "Night" asset catalog color.
    static var night: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .night)
#else
        .init()
#endif
    }

    /// The "NightLight" asset catalog color.
    static var nightLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .nightLight)
#else
        .init()
#endif
    }

    /// The "Overlay" asset catalog color.
    static var overlay: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .overlay)
#else
        .init()
#endif
    }

    /// The "Rose" asset catalog color.
    static var rose: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rose)
#else
        .init()
#endif
    }

    /// The "RoseLight" asset catalog color.
    static var roseLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .roseLight)
#else
        .init()
#endif
    }

    /// The "Sage" asset catalog color.
    static var sage: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sage)
#else
        .init()
#endif
    }

    /// The "SageLight" asset catalog color.
    static var sageLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sageLight)
#else
        .init()
#endif
    }

    /// The "Sky" asset catalog color.
    static var sky: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sky)
#else
        .init()
#endif
    }

    /// The "SkyLight" asset catalog color.
    static var skyLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skyLight)
#else
        .init()
#endif
    }

    /// The "Slate" asset catalog color.
    static var slate: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .slate)
#else
        .init()
#endif
    }

    /// The "SlateLight" asset catalog color.
    static var slateLight: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .slateLight)
#else
        .init()
#endif
    }

    /// The "SurfaceSecondary" asset catalog color.
    static var surfaceSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .surfaceSecondary)
#else
        .init()
#endif
    }

    /// The "TextInverse" asset catalog color.
    static var textInverse: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textInverse)
#else
        .init()
#endif
    }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textPrimary)
#else
        .init()
#endif
    }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textSecondary)
#else
        .init()
#endif
    }

    /// The "TextTertiary" asset catalog color.
    static var textTertiary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textTertiary)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AccentColor" asset catalog color.
    static var accent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "Amber" asset catalog color.
    static var amber: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .amber)
#else
        .init()
#endif
    }

    /// The "AmberLight" asset catalog color.
    static var amberLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .amberLight)
#else
        .init()
#endif
    }

    /// The "Background" asset catalog color.
    static var background: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "BackgroundSecondary" asset catalog color.
    static var backgroundSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .backgroundSecondary)
#else
        .init()
#endif
    }

    /// The "BorderStrong" asset catalog color.
    static var borderStrong: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .borderStrong)
#else
        .init()
#endif
    }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .cardBackground)
#else
        .init()
#endif
    }

    /// The "Coral" asset catalog color.
    static var coral: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .coral)
#else
        .init()
#endif
    }

    /// The "CoralLight" asset catalog color.
    static var coralLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .coralLight)
#else
        .init()
#endif
    }

    /// The "Divider" asset catalog color.
    static var divider: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .divider)
#else
        .init()
#endif
    }

    /// The "Lavender" asset catalog color.
    static var lavender: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .lavender)
#else
        .init()
#endif
    }

    /// The "LavenderLight" asset catalog color.
    static var lavenderLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .lavenderLight)
#else
        .init()
#endif
    }

    /// The "Night" asset catalog color.
    static var night: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .night)
#else
        .init()
#endif
    }

    /// The "NightLight" asset catalog color.
    static var nightLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .nightLight)
#else
        .init()
#endif
    }

    /// The "Overlay" asset catalog color.
    static var overlay: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .overlay)
#else
        .init()
#endif
    }

    /// The "Rose" asset catalog color.
    static var rose: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .rose)
#else
        .init()
#endif
    }

    /// The "RoseLight" asset catalog color.
    static var roseLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .roseLight)
#else
        .init()
#endif
    }

    /// The "Sage" asset catalog color.
    static var sage: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sage)
#else
        .init()
#endif
    }

    /// The "SageLight" asset catalog color.
    static var sageLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sageLight)
#else
        .init()
#endif
    }

    /// The "Sky" asset catalog color.
    static var sky: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sky)
#else
        .init()
#endif
    }

    /// The "SkyLight" asset catalog color.
    static var skyLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .skyLight)
#else
        .init()
#endif
    }

    /// The "Slate" asset catalog color.
    static var slate: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .slate)
#else
        .init()
#endif
    }

    /// The "SlateLight" asset catalog color.
    static var slateLight: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .slateLight)
#else
        .init()
#endif
    }

    /// The "SurfaceSecondary" asset catalog color.
    static var surfaceSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .surfaceSecondary)
#else
        .init()
#endif
    }

    /// The "TextInverse" asset catalog color.
    static var textInverse: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textInverse)
#else
        .init()
#endif
    }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textPrimary)
#else
        .init()
#endif
    }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textSecondary)
#else
        .init()
#endif
    }

    /// The "TextTertiary" asset catalog color.
    static var textTertiary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textTertiary)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "Amber" asset catalog color.
    static var amber: SwiftUI.Color { .init(.amber) }

    /// The "AmberLight" asset catalog color.
    static var amberLight: SwiftUI.Color { .init(.amberLight) }

    /// The "Background" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "BackgroundSecondary" asset catalog color.
    static var backgroundSecondary: SwiftUI.Color { .init(.backgroundSecondary) }

    /// The "BorderStrong" asset catalog color.
    static var borderStrong: SwiftUI.Color { .init(.borderStrong) }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: SwiftUI.Color { .init(.cardBackground) }

    /// The "Coral" asset catalog color.
    static var coral: SwiftUI.Color { .init(.coral) }

    /// The "CoralLight" asset catalog color.
    static var coralLight: SwiftUI.Color { .init(.coralLight) }

    /// The "Divider" asset catalog color.
    static var divider: SwiftUI.Color { .init(.divider) }

    /// The "Lavender" asset catalog color.
    static var lavender: SwiftUI.Color { .init(.lavender) }

    /// The "LavenderLight" asset catalog color.
    static var lavenderLight: SwiftUI.Color { .init(.lavenderLight) }

    /// The "Night" asset catalog color.
    static var night: SwiftUI.Color { .init(.night) }

    /// The "NightLight" asset catalog color.
    static var nightLight: SwiftUI.Color { .init(.nightLight) }

    /// The "Overlay" asset catalog color.
    static var overlay: SwiftUI.Color { .init(.overlay) }

    /// The "Rose" asset catalog color.
    static var rose: SwiftUI.Color { .init(.rose) }

    /// The "RoseLight" asset catalog color.
    static var roseLight: SwiftUI.Color { .init(.roseLight) }

    /// The "Sage" asset catalog color.
    static var sage: SwiftUI.Color { .init(.sage) }

    /// The "SageLight" asset catalog color.
    static var sageLight: SwiftUI.Color { .init(.sageLight) }

    /// The "Sky" asset catalog color.
    static var sky: SwiftUI.Color { .init(.sky) }

    /// The "SkyLight" asset catalog color.
    static var skyLight: SwiftUI.Color { .init(.skyLight) }

    /// The "Slate" asset catalog color.
    static var slate: SwiftUI.Color { .init(.slate) }

    /// The "SlateLight" asset catalog color.
    static var slateLight: SwiftUI.Color { .init(.slateLight) }

    /// The "SurfaceSecondary" asset catalog color.
    static var surfaceSecondary: SwiftUI.Color { .init(.surfaceSecondary) }

    /// The "TextInverse" asset catalog color.
    static var textInverse: SwiftUI.Color { .init(.textInverse) }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: SwiftUI.Color { .init(.textPrimary) }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: SwiftUI.Color { .init(.textSecondary) }

    /// The "TextTertiary" asset catalog color.
    static var textTertiary: SwiftUI.Color { .init(.textTertiary) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "Amber" asset catalog color.
    static var amber: SwiftUI.Color { .init(.amber) }

    /// The "AmberLight" asset catalog color.
    static var amberLight: SwiftUI.Color { .init(.amberLight) }

    /// The "Background" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "BackgroundSecondary" asset catalog color.
    static var backgroundSecondary: SwiftUI.Color { .init(.backgroundSecondary) }

    /// The "BorderStrong" asset catalog color.
    static var borderStrong: SwiftUI.Color { .init(.borderStrong) }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: SwiftUI.Color { .init(.cardBackground) }

    /// The "Coral" asset catalog color.
    static var coral: SwiftUI.Color { .init(.coral) }

    /// The "CoralLight" asset catalog color.
    static var coralLight: SwiftUI.Color { .init(.coralLight) }

    /// The "Divider" asset catalog color.
    static var divider: SwiftUI.Color { .init(.divider) }

    /// The "Lavender" asset catalog color.
    static var lavender: SwiftUI.Color { .init(.lavender) }

    /// The "LavenderLight" asset catalog color.
    static var lavenderLight: SwiftUI.Color { .init(.lavenderLight) }

    /// The "Night" asset catalog color.
    static var night: SwiftUI.Color { .init(.night) }

    /// The "NightLight" asset catalog color.
    static var nightLight: SwiftUI.Color { .init(.nightLight) }

    /// The "Overlay" asset catalog color.
    static var overlay: SwiftUI.Color { .init(.overlay) }

    /// The "Rose" asset catalog color.
    static var rose: SwiftUI.Color { .init(.rose) }

    /// The "RoseLight" asset catalog color.
    static var roseLight: SwiftUI.Color { .init(.roseLight) }

    /// The "Sage" asset catalog color.
    static var sage: SwiftUI.Color { .init(.sage) }

    /// The "SageLight" asset catalog color.
    static var sageLight: SwiftUI.Color { .init(.sageLight) }

    /// The "Sky" asset catalog color.
    static var sky: SwiftUI.Color { .init(.sky) }

    /// The "SkyLight" asset catalog color.
    static var skyLight: SwiftUI.Color { .init(.skyLight) }

    /// The "Slate" asset catalog color.
    static var slate: SwiftUI.Color { .init(.slate) }

    /// The "SlateLight" asset catalog color.
    static var slateLight: SwiftUI.Color { .init(.slateLight) }

    /// The "SurfaceSecondary" asset catalog color.
    static var surfaceSecondary: SwiftUI.Color { .init(.surfaceSecondary) }

    /// The "TextInverse" asset catalog color.
    static var textInverse: SwiftUI.Color { .init(.textInverse) }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: SwiftUI.Color { .init(.textPrimary) }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: SwiftUI.Color { .init(.textSecondary) }

    /// The "TextTertiary" asset catalog color.
    static var textTertiary: SwiftUI.Color { .init(.textTertiary) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif


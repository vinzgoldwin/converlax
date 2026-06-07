import Foundation
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

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "ClxAssetAskDirections" asset catalog image resource.
    static let clxAssetAskDirections = DeveloperToolsSupport.ImageResource(name: "ClxAssetAskDirections", bundle: resourceBundle)

    /// The "ClxAssetAskInfo" asset catalog image resource.
    static let clxAssetAskInfo = DeveloperToolsSupport.ImageResource(name: "ClxAssetAskInfo", bundle: resourceBundle)

    /// The "ClxAssetBookAccommodation" asset catalog image resource.
    static let clxAssetBookAccommodation = DeveloperToolsSupport.ImageResource(name: "ClxAssetBookAccommodation", bundle: resourceBundle)

    /// The "ClxAssetCustomLesson" asset catalog image resource.
    static let clxAssetCustomLesson = DeveloperToolsSupport.ImageResource(name: "ClxAssetCustomLesson", bundle: resourceBundle)

    /// The "ClxAssetFreeTalk" asset catalog image resource.
    static let clxAssetFreeTalk = DeveloperToolsSupport.ImageResource(name: "ClxAssetFreeTalk", bundle: resourceBundle)

    /// The "ClxAssetHistoryUsage" asset catalog image resource.
    static let clxAssetHistoryUsage = DeveloperToolsSupport.ImageResource(name: "ClxAssetHistoryUsage", bundle: resourceBundle)

    /// The "ClxAssetReview" asset catalog image resource.
    static let clxAssetReview = DeveloperToolsSupport.ImageResource(name: "ClxAssetReview", bundle: resourceBundle)

    /// The "ClxAssetRoleplay" asset catalog image resource.
    static let clxAssetRoleplay = DeveloperToolsSupport.ImageResource(name: "ClxAssetRoleplay", bundle: resourceBundle)

    /// The "ClxAssetSavedLines" asset catalog image resource.
    static let clxAssetSavedLines = DeveloperToolsSupport.ImageResource(name: "ClxAssetSavedLines", bundle: resourceBundle)

    /// The "ClxAssetSettings" asset catalog image resource.
    static let clxAssetSettings = DeveloperToolsSupport.ImageResource(name: "ClxAssetSettings", bundle: resourceBundle)

    /// The "ClxAssetStreak" asset catalog image resource.
    static let clxAssetStreak = DeveloperToolsSupport.ImageResource(name: "ClxAssetStreak", bundle: resourceBundle)

    /// The "ClxAssetVocab" asset catalog image resource.
    static let clxAssetVocab = DeveloperToolsSupport.ImageResource(name: "ClxAssetVocab", bundle: resourceBundle)

    /// The "ClxMascotAvatar" asset catalog image resource.
    static let clxMascotAvatar = DeveloperToolsSupport.ImageResource(name: "ClxMascotAvatar", bundle: resourceBundle)

    /// The "ClxMascotCelebrating" asset catalog image resource.
    static let clxMascotCelebrating = DeveloperToolsSupport.ImageResource(name: "ClxMascotCelebrating", bundle: resourceBundle)

    /// The "ClxMascotEncouraging" asset catalog image resource.
    static let clxMascotEncouraging = DeveloperToolsSupport.ImageResource(name: "ClxMascotEncouraging", bundle: resourceBundle)

    /// The "ClxMascotIdle" asset catalog image resource.
    static let clxMascotIdle = DeveloperToolsSupport.ImageResource(name: "ClxMascotIdle", bundle: resourceBundle)

    /// The "ClxMascotThinking" asset catalog image resource.
    static let clxMascotThinking = DeveloperToolsSupport.ImageResource(name: "ClxMascotThinking", bundle: resourceBundle)

    /// The "ClxMascotWaving" asset catalog image resource.
    static let clxMascotWaving = DeveloperToolsSupport.ImageResource(name: "ClxMascotWaving", bundle: resourceBundle)

}


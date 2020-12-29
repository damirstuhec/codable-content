import Foundation

// MARK: - HStack

public struct CodableHStack: CodableComponent {
    public static let type = CodableComponentType.hstack
    public let components: [AnyCodableComponent]
}

// MARK: - VStack

public struct CodableVStack: CodableComponent {
    public static let type = CodableComponentType.vstack
    public let components: [AnyCodableComponent]
}

// MARK: - Image

public struct CodableImage: CodableComponent {
    public static let type = CodableComponentType.image
    public let url: String
}

// MARK: - Text

public struct CodableText: CodableComponent {
    public enum Style: String, Codable {
        case title
        case body
        case footnote
    }

    public static let type = CodableComponentType.text
    public let text: String
    public var style = Style.body
}

// MARK: - Button

public struct CodableButtonAction: Hashable, Codable {
    public let identifier: String
}

extension CodableButtonAction: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        identifier = value
    }
}

public extension CodableButtonAction {
    static var open: Self { #function }
    static var dismiss: Self { #function }
    static var openUrl: Self { #function }
    static var shareUrl: Self { #function }
}

public struct CodableButton: CodableComponent {
    public static let type = CodableComponentType.button
    public let title: String
    public var subtitle: String? = nil
    public let action: CodableButtonAction
    public var url: String? = nil
}

// MARK: - CodableComponent

public enum CodableComponentType: String, Codable {
    case hstack
    case vstack = "group" // Backwards compatibility
    case image
    case text
    case button

    var metatype: CodableComponent.Type {
        switch self {
        case .hstack:
            return CodableHStack.self
        case .vstack:
            return CodableVStack.self
        case .image:
            return CodableImage.self
        case .text:
            return CodableText.self
        case .button:
            return CodableButton.self
        }
    }
}

public protocol CodableComponent: Codable {
    static var type: CodableComponentType { get }
}

// MARK: - AnyCodableComponent

public struct AnyCodableComponent: Codable {
    public let component: CodableComponent

    public init(_ component: CodableComponent) {
        self.component = component
    }

    private enum CodingKeys: CodingKey {
        case type
        case component
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CodableComponentType.self, forKey: .type)
        self.component = try type.metatype.init(from: container.superDecoder(forKey: .component))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type(of: component).type, forKey: .type)
        try component.encode(to: container.superEncoder(forKey: .component))
    }
}

public extension AnyCodableComponent {
    static func hstack(_ components: [AnyCodableComponent]) -> AnyCodableComponent {
        AnyCodableComponent(CodableHStack(components: components))
    }

    static func vstack(_ components: [AnyCodableComponent]) -> AnyCodableComponent {
        AnyCodableComponent(CodableVStack(components: components))
    }

    static func image(url: String) -> AnyCodableComponent {
        AnyCodableComponent(CodableImage(url: url))
    }

    static func text(_ text: String, _ style: CodableText.Style = .body) -> AnyCodableComponent {
        AnyCodableComponent(CodableText(text: text, style: style))
    }

    static func button(title: String, subtitle: String? = nil, _ action: CodableButtonAction, url: String? = nil) -> AnyCodableComponent {
        AnyCodableComponent(CodableButton(title: title, subtitle: subtitle, action: action, url: url))
    }
}

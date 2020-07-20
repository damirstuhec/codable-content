import Foundation

// MARK: - HStack

public struct CodableHStack: CodableComponent {
    public static let type = CodableComponentType.hstack
    public var id: String { components.first?.id ?? UUID().uuidString }
    public let components: [AnyCodableComponent]
}

// MARK: - Group

public struct CodableGroup: CodableComponent {
    public static let type = CodableComponentType.group
    public var id: String { components.first?.id ?? UUID().uuidString }
    public var isProminent = false
    public let components: [AnyCodableComponent]
}

// MARK: - Image

public struct CodableImage: CodableComponent {
    public static let type = CodableComponentType.image
    public var id: String { url }
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
    public var id: String { text }
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
    public var id: String { title }
    public let action: CodableButtonAction
    public let title: String
    public var subtitle: String? = nil
    public var url: String? = nil
}

// MARK: - CodableComponent

public enum CodableComponentType: String, Codable {
    case hstack
    case group
    case image
    case text
    case button

    var metatype: CodableComponent.Type {
        switch self {
        case .hstack:
            return CodableHStack.self
        case .group:
            return CodableGroup.self
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
    var id: String { get }
}

// MARK: - AnyCodableComponent

public struct AnyCodableComponent: Codable {
    let component: CodableComponent

    public init(component: CodableComponent) {
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

extension AnyCodableComponent: Equatable {
    var id: String { component.id }

    public static func == (lhs: AnyCodableComponent, rhs: AnyCodableComponent) -> Bool {
        return lhs.id == rhs.id
    }
}

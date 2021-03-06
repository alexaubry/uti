//
//  URL+UTI
//
//  This file is part of the uti project.
//  Copyright (c) 2018 - present Alexis Aubry and the uti authors.
//
//  Licensed under the terms of the MIT License.
//

import Foundation

/**
 * Errors that can occur when handling URLs.
 */

public enum URLTypeError: LocalizedError, Equatable {
    case fileNotFound(String)
    case resourcesUnavailable(NSError)
    case noUTI

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Cannot find item at path '\(path)'."
        case .resourcesUnavailable(let error):
            return "The attributes of the file could not be read because of an error. (\(error))"
        case .noUTI:
            return "The file attributes do not contain a type identifier. Please check the format of the file."
        }
    }
}

extension URL {

    /**
     * Initializes the URL for the specified terminal-intuitive resource path.
     * - parameter path: The path to the resource. You can use a path relative to the current
     * directory, the home directory, or an absolute path.
     * - throws: `URLError.realPathNotFound` when the path could not be expanded, or
     * `URLError.fileNotFound` if the file could not be found.
     */

    public init(relativeFilePath path: String) throws {
        let relativeFilePath = (path as NSString).expandingTildeInPath

        guard let realPath = realpath(relativeFilePath, nil) else {
            throw URLTypeError.fileNotFound(relativeFilePath)
        }

        let filePath = String(cString: realPath)
        self.init(fileURLWithPath: filePath)
    }

    /**
     * Get the Uniform Type Identifier for the resource at this URL.
     * - throws: `URLError.resourcesUnavailable` if the file does not have
     * any attributes, or `URLError.noUTI` if the attributes of the file do not
     * include an UTI.
     * - returns: The UTI that describes the resource file.
     */

    public func fetchTypeIdentifier() throws -> String {
        var uti: String?

        do {
            let resources = try resourceValues(forKeys: [.typeIdentifierKey])
            uti = resources.typeIdentifier
        } catch {
            throw URLTypeError.resourcesUnavailable(error as NSError)
        }

        guard let typeIdentifier = uti else {
            throw URLTypeError.noUTI
        }

        return typeIdentifier
    }

}

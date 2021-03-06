//
//  Command
//
//  This file is part of the uti project.
//  Copyright (c) 2018 - present Alexis Aubry and the uti authors.
//
//  Licensed under the terms of the MIT License.
//

import Foundation

/**
 * The commands that can be executed by the app.
 */

public enum Command: Equatable {

    /// A command to print the help.
    case printHelp

    /// A command to get the UTI of a file.
    case getUTI(URL)

    /// A command to check if the UTI of a file conforms to another UTI.
    case checkConformance(String, URL)

}

/**
 * The name of the supported commands.
 */

public enum CommandType: String {
    case getUTI = "get"
    case checkConformance = "conforms"
    case usage = "help"

    static let all: [CommandType] = [.getUTI, .checkConformance, .usage]

    /// The description of what the command does.
    public var description: String {
        switch self {
        case .getUTI:
            return "Get the Uniform Type Identifier of a file."
        case .checkConformance:
            return "Check that a file conforms to the specified type."
        case .usage:
            return "Print the instructions to use the program."
        }
    }

    /// A description
    public var usage: String {
        switch self {
        case .getUTI:
            return "uti get <file URL>"
        case .checkConformance:
            return "uti <UTI to check> <file URL>"
        case .usage:
            return "uti help"
        }
    }

    /// The example usage of the command.
    public var exampleUsage: String? {
        switch self {
        case .getUTI:
            return "uti get ~/Desktop"
        case .checkConformance:
            return "uti conforms public.folder ~/Desktop"
        case .usage:
            return nil
        }
    }
}

/**
 * Errors that can occur when parsing the 
 */

public enum CommandParserError: LocalizedError, Equatable {
    case missingCommandName
    case unknownCommand(String)
    case invalidUsage(CommandType)

    public var errorDescription: String? {
        switch self {
        case .missingCommandName, .invalidUsage:
            return nil
        case .unknownCommand(let commandName):
            return "'\(commandName)' is not a uti command name. See 'uti help'."
        }
    }
}

// MARK: - Parsing

extension Array where Element == String {

    /**
     * Attempts to parse a supported command from a list of arguments.
     * - returns: The command, and the error that prevented a command from being detected.
     */

    public func parseCommand() -> Result<Command> {
        do {
            let command = try rawParseCommand()
            return .success(command)
        } catch {
            return .error(error)
        }
    }

    func rawParseCommand() throws -> Command {
        guard count >= 2 else {
            throw CommandParserError.missingCommandName
        }

        let commandName = self[1]

        guard let commandType = CommandType(rawValue: commandName) else {
            throw CommandParserError.unknownCommand(commandName)
        }

        switch commandType {
        case .getUTI:
            guard count >= 3 else {
                throw CommandParserError.invalidUsage(commandType)
            }

            let url = try URL(relativeFilePath: self[2])
            return .getUTI(url)

        case .checkConformance:
            guard count >= 4 else {
                throw CommandParserError.invalidUsage(commandType)
            }

            let uti = self[2]
            let url = try URL(relativeFilePath: self[3])
            return .checkConformance(uti, url)
        case .usage:
            return .printHelp
        }
    }

}

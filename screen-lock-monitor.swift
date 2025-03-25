#!/usr/bin/swift

import Cocoa
import Foundation

signal(SIGINT) { signal in
  print("\nCaught signal \(signal), exiting...")
  exit(0)
}

var lockCommand: String?
var unlockCommand: String?

var i = 1
while i < CommandLine.arguments.count {
  let arg = CommandLine.arguments[i]

  switch arg {
  case "-l", "--lock":
    if i + 1 < CommandLine.arguments.count {
      lockCommand = CommandLine.arguments[i + 1]
      i += 2
    } else {
      print("Error: Missing command for lock event")
      exit(1)
    }
  case "-u", "--unlock":
    if i + 1 < CommandLine.arguments.count {
      unlockCommand = CommandLine.arguments[i + 1]
      i += 2
    } else {
      print("Error: Missing command for unlock event")
      exit(1)
    }
  default:
    print("Unknown option: \(arg)")
    i += 1
  }
}

if lockCommand == nil && unlockCommand == nil {
  print("Usage: \(CommandLine.arguments[0]) [options]")
  print("Options:")
  print("  -l, --lock COMMAND            Command to run when screen is locked (password required)")
  print("  -u, --unlock COMMAND          Command to run when screen is unlocked")
  print("At least one command is required.")
  exit(1)
}

func log(_ message: String) {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  let timestamp = dateFormatter.string(from: Date())
  print("\(timestamp): \(message)")
}

func executeCommand(_ command: String?, description: String = "") {
  guard let cmd = command else { return }

  log("Executing \(description) command: \(cmd)")

  let task = Process()
  task.executableURL = URL(fileURLWithPath: "/bin/sh")
  task.arguments = ["-c", cmd]

  // Redirect output to prevent blocking
  let outputPipe = Pipe()
  let errorPipe = Pipe()
  task.standardOutput = outputPipe
  task.standardError = errorPipe

  do {
    try task.run()

    DispatchQueue.global(qos: .background).async {
      task.waitUntilExit()

      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: outputData, encoding: .utf8) ?? ""
      let error = String(data: errorData, encoding: .utf8) ?? ""

      DispatchQueue.main.async {
        if task.terminationStatus != 0 {
          log("\(description) command exited with status \(task.terminationStatus)")
          if !error.isEmpty {
            log("Error output: \(error)")
          }
        } else {
          log("\(description) command completed successfully")
          if !output.isEmpty && output.count < 100 {
            log("Output: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
          }
        }
      }
    }
  } catch {
    log("Error executing \(description) command: \(error)")
  }
}

let dnc = DistributedNotificationCenter.default

log("Setting up screen event observers...")

var observers: [Any] = []
if let command = lockCommand {
  let observer = dnc.addObserver(
    forName: NSNotification.Name("com.apple.screenIsLocked"),
    object: nil,
    queue: .main
  ) { _ in
    log("Screen locked event detected")
    executeCommand(command, description: "lock")
  }
  observers.append(observer)
  log("Lock screen observer registered")
}

if let command = unlockCommand {
  let observer = dnc.addObserver(
    forName: NSNotification.Name("com.apple.screenIsUnlocked"),
    object: nil,
    queue: .main
  ) { _ in
    log("Screen unlocked event detected")
    executeCommand(command, description: "unlock")
  }
  observers.append(observer)
  log("Unlock screen observer registered")
}

log("Screen event monitor started")
log("Press Ctrl+C to exit")
if let cmd = lockCommand { log("Lock command: \(cmd)") }
if let cmd = unlockCommand { log("Unlock command: \(cmd)") }

// This timer keeps the script alive by firing periodically
let keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
  // Do nothing, just keep the RunLoop alive
}

RunLoop.main.run()

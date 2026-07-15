import Foundation

func runDeviceProofHarnessChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas iOS · DeviceProof harness (C7):")
    let path = "App/scripts/run-device-proof.sh"
    guard let script = try? String(contentsOfFile: path, encoding: .utf8) else {
        check("script físico está disponível no gate", false)
        return
    }

    let lockProbe = script.range(of: "device info lockState")
    let lockedState = script.range(of: "passcodeRequired: true")
    let destructiveCleanup = script.range(of: "rm -rf \"$RESULT\" \"$EVIDENCE\"")
    let lockPrecedesCleanup: Bool
    if let lockProbe, let destructiveCleanup {
        lockPrecedesCleanup = lockProbe.lowerBound < destructiveCleanup.lowerBound
    } else {
        lockPrecedesCleanup = false
    }
    check("device bloqueado falha antes de apagar evidência ou iniciar Xcode",
          lockProbe != nil && lockedState != nil && destructiveCleanup != nil &&
          lockPrecedesCleanup)

    check("device pareado alcança o lock probe mesmo com túnel sob demanda",
          script.contains("conn.get(\"pairingState\") == \"paired\"") &&
          !script.contains("conn.get(\"tunnelState\") == \"connected\""))

    let project = try? String(contentsOfFile: "App/project.yml", encoding: .utf8)
    check("target desta vertical é iPhone-only e não gera warning de orientação iPad",
          project?.contains("TARGETED_DEVICE_FAMILY: \"1\"") == true)
}

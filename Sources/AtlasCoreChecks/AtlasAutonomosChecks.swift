import Foundation
import AtlasCore

public func runAtlasAutonomosChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas Autônomos · contrato 24/7 separado:")
    let decoder = JSONDecoder(); decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let areasJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_areas.v1",
     "read_only":true,"areas":[{"area_id":"agentic_engineering_os","area_name":"Agentic Engineering OS",
       "focus":"dev_forge","autonomy_tier":5,"max_tier_for_area":5,"dev_mode":"max_governed",
       "registered":true,"objective":"Auditar Atlas Native","owned_systems":["atlas-native"],
       "repo_scope":{"path":"/repo"},"stop_conditions":["risk"],"run_state":{"lock":{"held":true}}}],
     "area_count":1,"default_area":"agentic_engineering_os","default_focus":"dev_forge"}
    """
    let areas = try? decoder.decode(AtlasAutonomosAreasResponse.self, from: Data(areasJSON.utf8))
    check("áreas Autônomos decodificam sem depender da conversa", areas?.areas.first?.objective == "Auditar Atlas Native")
    check("área preserva tier e lock reais", areas?.areas.first?.autonomyTier == 5 && areas?.areas.first?.isLocked == true)

    let liveJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_live.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","portfolio_id":"atlas_software_company",
     "read_only":true,"cockpit":{"status":"active"},
     "run_state":{"lock":{"held":true},"pause":{"paused":false},"kill_switch":{"active":false}}}
    """
    let live = try? decoder.decode(AtlasAutonomosLiveResponse.self, from: Data(liveJSON.utf8))
    check("live separa lock, pausa e kill switch", live?.isRunning == true && live?.isPaused == false && live?.isKilled == false)

    let controlJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_run_control.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","action":"pause","operator_actor":"vitor",
     "applied":true,"kill_switch":{"active":false},"pause":{"paused":true},"note":"next boundary"}
    """
    let control = try? decoder.decode(AtlasAutonomosRunControlResponse.self, from: Data(controlJSON.utf8))
    check("recibo de controle só confirma ação aplicada pelo servidor", control?.applied == true && control?.action == .pause && control?.isPaused == true)

    let command = AtlasAutonomosRunControlInput(action: .kill, operatorActor: "vitor", reason: "risco")
    check("comando exige actor e ação explícita", command.operatorActor == "vitor" && command.action == .kill)
}

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
       "repo_scope":{"repos":["atlas-server"]},"stop_conditions":["risk"],"run_state":{"lock":{"held":true}}}],
     "area_count":1,"default_area":"agentic_engineering_os","default_focus":"dev_forge"}
    """
    let areas = try? decoder.decode(AtlasAutonomosAreasResponse.self, from: Data(areasJSON.utf8))
    check("áreas Autônomos decodificam sem depender da conversa", areas?.areas.first?.objective == "Auditar Atlas Native")
    check("área preserva tier, repo público e lock reais", areas?.areas.first?.autonomyTier == 5 && areas?.areas.first?.repositoryNames == ["atlas-server"] && areas?.areas.first?.isLocked == true)

    let liveJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_live.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","portfolio_id":"atlas_software_company",
     "read_only":true,"cockpit":{"schema_version":"atlas.autonomos.cockpit_summary.v1","status":"active"},
     "run_state":{"lock":{"held":true,"holder":{"host":"mac-mini","acquired_at":"2026-07-13T12:00:00Z","lease_ttl_seconds":3600,"runtime":{"environment":"production","workspace":"Atlas","repository":"atlas-server","branch":"main"}}},"pause":{"active":false},"kill_switch":{"active":false}}}
    """
    let live = try? decoder.decode(AtlasAutonomosLiveResponse.self, from: Data(liveJSON.utf8))
    check("live separa lock, pausa e kill switch", live?.isRunning == true && live?.isPaused == false && live?.isKilled == false && live?.cockpit.status == "active")
    check("live projeta fase tipada sem a casca ler JSON", live?.loopStatus.phase == .running)
    check("placement runtime só expõe host e lease realmente publicados", live?.runtimePlacement.host == "mac-mini" && live?.runtimePlacement.leaseTTLSeconds == 3600)
    check("placement preserva ambiente, workspace, repo e branch sem caminho absoluto", live?.runtimePlacement.environment == "production" && live?.runtimePlacement.workspace == "Atlas" && live?.runtimePlacement.repository == "atlas-server" && live?.runtimePlacement.branch == "main")

    let pausedLiveJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_live.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","portfolio_id":"atlas_software_company",
     "read_only":true,"cockpit":{"schema_version":"atlas.autonomos.cockpit_summary.v1","status":"ready"},
     "run_state":{"lock":{"held":true,"available":false},"pause":{"active":true},"kill_switch":{"active":false}}}
    """
    let pausedLive = try? decoder.decode(AtlasAutonomosLiveResponse.self, from: Data(pausedLiveJSON.utf8))
    check("pausa vence lease para a fase apresentada", pausedLive?.loopStatus.phase == .paused)

    let cyclesJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_cycles.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","ledger_record_count_total":1,
     "returned_count":1,"cycles":[{"cycle_index":7,"outcome":"blocked",
       "cycle_final_status":"blocked","merge_performed":false,"merge_hash":"",
       "loop_receipt_integrity":"verified","blockers":["quality_gate_failed"],
       "repaired":false,"retried":true,"quarantined":false,"quarantine_reason":"",
       "recorded_at":"2026-07-14T00:00:00Z"}]}
    """
    let cycles = try? decoder.decode(AtlasAutonomosCyclesResponse.self, from: Data(cyclesJSON.utf8))
    check("histórico de ciclos é tipado e não carrega ledger bruto", cycles?.cycles.first?.outcome == "blocked" && cycles?.cycles.first?.blockers == ["quality_gate_failed"] && cycles?.cycles.first?.recordedAt == "2026-07-14T00:00:00Z")

    let deliveredJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_done.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","read_only":true,
     "ledger_record_count_total":9,"delivered_total":1,"returned":1,"offset":0,"limit":20,
     "delivered":[{"cycle_index":8,"outcome":"merged","cycle_final_status":"merged",
       "merge_performed":true,"merge_hash":"abc123","loop_receipt_integrity":"verified",
       "blockers":[],"repaired":false,"retried":false,"quarantined":false,"quarantine_reason":"",
       "recorded_at":"2026-07-14T00:01:00Z"}]}
    """
    let delivered = try? decoder.decode(AtlasAutonomosDeliveredResponse.self, from: Data(deliveredJSON.utf8))
    check("histórico Autônomos mantém somente entrega comprovada e tipada", delivered?.deliveredTotal == 1 && delivered?.delivered.first?.mergeHash == "abc123" && delivered?.delivered.first?.cycleIndex == 8)

    let backlogJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_backlog.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","portfolio_id":"atlas_software_company","read_only":true,
     "findings":{"total":2,"distinct_total":1,"returned":1,"offset":0,"limit":20,
       "by_risk":{"high":1},"by_route":{"atlas_dev":1},
       "items":[{"finding_hash":"sha256:abc123","title":"Contrato de fila","source":"area_focus",
         "source_owner":"atlas_dev","gap_kind":"partial_canon","risk_level":"high",
         "priority_score":85,"route":"atlas_dev","count":2,"created_at":"2026-07-01T00:00:00Z",
         "rule_id":"R2","rule_text":"Símbolo public sem consumidor."}]},
     "work_orders":[{"work_order_id":"awo_123","finding_hash":"sha256:abc123","title":"Contrato de fila",
       "route":"atlas_dev","routes_to_owner_service":"atlas_dev","risk_level":"high","priority_score":85,
       "requires_branch_isolation":true,"operator_decision_required":true,"evidence_required":true,
       "execution_executed":false,"status":"queued","created_at":"2026-07-02T00:00:00Z"}],
     "inbox_items":[{"finding_hash":"sha256:abc123","title":"Contrato de fila","route":"atlas_dev",
       "risk_level":"high","priority_score":85,"decision_required":true,"decision_options":["accept","reject"],
       "created_at":"2026-07-03T00:00:00Z"}],
     "budgets":{"dev_budget":{"mode":"governed","max_concurrent_work_orders":2},
       "forge_budget":{"mode":"governed","max_concurrent_obras":1},"wip_limit":3,"wip_used":1,
       "dev_routed":1,"forge_routed":0,"queued":1,"budget_consumed":false,"execution_executed":false}}
    """
    let backlog = try? decoder.decode(AtlasAutonomosBacklogResponse.self, from: Data(backlogJSON.utf8))
    check("backlog Autônomos é tipado sem payload interno", backlog?.findings.items.first?.title == "Contrato de fila" && backlog?.workOrders.first?.requiresBranchIsolation == true && backlog?.inboxItems.first?.decisionOptions == ["accept", "reject"] && backlog?.budgets.wipLimit == 3)
    check("finding Autônomos preserva regra citada quando servidor publica", backlog?.findings.items.first?.ruleId == "R2" && backlog?.findings.items.first?.ruleText == "Símbolo public sem consumidor.")
    check("backlog Autônomos preserva created_at opcional para aging visual",
          backlog?.findings.items.first?.createdAt == "2026-07-01T00:00:00Z" &&
          backlog?.workOrders.first?.createdAt == "2026-07-02T00:00:00Z" &&
          backlog?.inboxItems.first?.createdAt == "2026-07-03T00:00:00Z")

    let controlJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_run_control.v1",
     "area_id":"agentic_engineering_os","focus":"dev_forge","action":"pause","operator_actor":"vitor",
     "applied":true,"kill_switch":{"active":false},"pause":{"active":true},"note":"next boundary"}
    """
    let control = try? decoder.decode(AtlasAutonomosRunControlResponse.self, from: Data(controlJSON.utf8))
    check("recibo de controle só confirma ação aplicada pelo servidor", control?.applied == true && control?.action == .pause && control?.pause.active == true && control?.killSwitch.active == false)

    let command = AtlasAutonomosRunControlInput(action: .kill, operatorActor: "vitor", reason: "risco")
    check("comando exige actor e ação explícita", command.operatorActor == "vitor" && command.action == .kill)

    let startRunJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_start_run.v1",
     "status":"enqueued","launch":"queued_job","queue":"software_company_loop",
     "area_id":"agentic_engineering_os","focus":"dev_forge","mode":"execute","execute":true,
     "requires_worker":true,"operator_actor":"vitor","operator_reason_recorded":true,
     "started":false,"merge_performed":false,"provider_invoked":false,"note":"queued"}
    """
    let startRun = try? decoder.decode(AtlasAutonomosStartRunResponse.self, from: Data(startRunJSON.utf8))
    check("início Autônomos preserva fila sem fingir execução", startRun?.isEnqueued == true && startRun?.started == false && startRun?.operatorReasonRecorded == true)
    let executeInput = AtlasAutonomosStartRunInput(mode: .execute, operatorActor: "vitor", operatorReason: "janela aprovada")
    check("execução Autônomos exige motivo auditável", executeInput.isLocallyValidForSubmission)

    let transferJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_command_transfer.v1",
     "status":"transfer_requested","transfer_requested":true,"started":false,
     "area_id":"agentic_engineering_os","focus":"dev_forge",
     "handoff":{"schema_version":"atlas.software_company_stewardship.ap790_loop_handoff.v1",
       "handoff_id":"ap790handoff_123","area_id":"agentic_engineering_os","focus":"dev_forge",
       "status":"transfer_requested","source":{"run_id":"ap790run_source","host":"mac-mini","acquired_at":"2026-07-13T12:00:00Z"},
       "target":{"status":"awaiting_source_release","run_id":null,"host":null,"claimed_at":null},
       "requested_at":"2026-07-13T12:01:00Z","source_released_at":null,"successor_enqueued_at":null,"checkpoint":null,"updated_at":"2026-07-13T12:01:00Z"},
     "source":{"run_id":"ap790run_source","host":"mac-mini","acquired_at":"2026-07-13T12:00:00Z"},
     "target":{"status":"awaiting_source_release","run_id":null,"host":null,"claimed_at":null},
     "note":"awaiting safe boundary"}
    """
    let transfer = try? decoder.decode(AtlasAutonomosTransferResponse.self, from: Data(transferJSON.utf8))
    check("transferência Autônomos preserva fonte real sem inventar target", transfer?.isAwaitingSourceRelease == true && transfer?.handoff.source.runId == "ap790run_source" && transfer?.handoff.target.host == nil)
    let transferInput = AtlasAutonomosTransferInput(operatorActor: "vitor", reason: "trocar no próximo limite seguro")
    let transferEncoder = JSONEncoder(); transferEncoder.keyEncodingStrategy = .convertToSnakeCase
    let transferPayload = (try? JSONSerialization.jsonObject(with: transferEncoder.encode(transferInput))) as? [String: Any]
    check("transferência envia comando auditável em snake_case", transferInput.isLocallyValidForSubmission && transferPayload?["operator_actor"] as? String == "vitor" && transferPayload?["reason"] as? String == "trocar no próximo limite seguro")

    check("rota M08 revert usa superfície Autônomos sem /loop",
          AtlasRoute.autonomosCycleRevert(area: "agentic/engineering", cycle: "7") == "/ai/software-company-stewardship/autonomos/agentic%2Fengineering/cycles/7/revert")
    check("rota M09 digest usa endpoint global do Autônomos",
          AtlasRoute.autonomosDigest == "/ai/software-company-stewardship/autonomos/digest")

    let revertJSON = """
    {"schema_version":"atlas.software_company_stewardship.loop_cycle_revert.v1",
     "status":"enqueued","area_id":"agentic_engineering_os","focus":"dev_forge",
     "cycle_index":7,"cycle_id":"aesc_test_7","merge_hash":"abc123def456",
     "revert_of":{"cycle_index":7,"cycle_id":"aesc_test_7","merge_hash":"abc123def456"},
     "receipt_id":"m08rev_123","queue":"software_company_loop","operator_actor":"vitor",
     "git_revert_performed":false,"worker_implemented":false,
     "mission":{"type":"governed_git_revert","status":"enqueued","target_merge_hash":"abc123def456",
       "command_intent":"git revert abc123def456","worker_implemented":false,
       "worker_gap":"executor pending"},
     "note":"queued"}
    """
    let revert = try? decoder.decode(AtlasAutonomosCycleRevertResponse.self, from: Data(revertJSON.utf8))
    check("M08 revert decodifica recibo enfileirado sem alegar git revert", revert?.status == .enqueued && revert?.revertOf.mergeHash == "abc123def456" && revert?.gitRevertPerformed == false && revert?.workerImplemented == false)
    check("M08 revert preserva missão governada sem executar no app", revert?.mission.type == "governed_git_revert" && revert?.mission.workerImplemented == false)
    let revertInput = AtlasAutonomosCycleRevertInput(operatorActor: "vitor", reason: "rollback requested after operator inspection")
    let revertEncoder = JSONEncoder(); revertEncoder.keyEncodingStrategy = .convertToSnakeCase
    let revertPayload = (try? JSONSerialization.jsonObject(with: revertEncoder.encode(revertInput))) as? [String: Any]
    check("M08 input envia operator_actor + reason", revertInput.isLocallyValidForSubmission && revertPayload?["operator_actor"] as? String == "vitor" && revertPayload?["reason"] as? String == "rollback requested after operator inspection")

    let digestJSON = """
    {"schema_version":"atlas.autonomos.digest.v1","read_only":true,"provider_safe":true,
     "next_digest_at":null,
     "schedule":{"available":false,"source":null,"reason":"no_active_autonomos_digest_schedule_found"},
     "last":{"window":{"kind":"rolling","hours":24,"started_at":"2026-07-16T00:00:00+00:00",
       "ended_at":"2026-07-17T00:00:00+00:00","timezone":"UTC",
       "areas":["agentic_engineering_os"],"focus":"dev_forge"},
       "counts":{"delivered":1,"risks":2,"pending_decisions":1},
       "delivered":[{"source":"cycle_ledger","area_id":"agentic_engineering_os","focus":"dev_forge",
         "cycle_index":1,"cycle_id":"aesc_delivered_recent","outcome":"merged",
         "cycle_final_status":"merged","merge_performed":true,"merge_hash":"abc1234",
         "recorded_at":"2026-07-16T22:00:00+00:00"}],
       "risks":[{"source":"cycle_ledger","area_id":"agentic_engineering_os","focus":"dev_forge",
         "cycle_index":2,"cycle_id":"aesc_blocked_recent","severity":"high",
         "reason":"provider_quota_exhausted","blockers":["provider_quota_exhausted","operator_decision_required"],
         "quarantined":false,"recorded_at":"2026-07-16T23:00:00+00:00"}],
       "pending_decisions":[{"source":"area_focus_read_model","area_id":"agentic_engineering_os",
         "focus":"dev_forge","finding_id":"nsf_digest_pending_decision",
         "title":"Decisão pendente","severity":"high","route":"operator_review",
         "route_reason":"needs_owner","priority_score":90,"operator_decision_required":true}],
       "source_statuses":{"agentic_engineering_os":{"area_focus_read_model":"available"}}}}
    """
    let digest = try? decoder.decode(AtlasAutonomosDigestResponse.self, from: Data(digestJSON.utf8))
    check("M09 digest falha fechado no schema e preserva agenda ausente", digest?.schemaVersion == AtlasAutonomosDigestResponse.schemaVersion && digest?.nextDigestAt == nil && digest?.schedule.available == false)
    check("M09 digest preserva janela e contagens governadas", digest?.last.window.hours == 24 && digest?.last.counts.delivered == 1 && digest?.last.counts.risks == 2 && digest?.last.counts.pendingDecisions == 1)
    check("M09 digest entrega, risco e decisão pendente são tipados", digest?.last.delivered.first?.mergeHash == "abc1234" && digest?.last.risks.first?.reason == "provider_quota_exhausted" && digest?.last.pendingDecisions.first?.findingId == "nsf_digest_pending_decision")

    let decisionJSON = """
    {"schema_version":"atlas.software_company_stewardship.area_focus_operator_decision_receipt.v1",
     "ap_contract":"AP-724","decision_id":"afod_123","area_id":"agentic_engineering_os",
     "inbox_item_id":null,"finding_hash":"sha256:abc123","work_order_id":null,
     "evidence_pack_hash":null,"operator_actor":"vitor","decision":"accept",
     "rationale":"risco revisado","risk_level":"high",
     "next_allowed_action":"release_to_owner_execution_under_operator_review",
     "routes_to_owner":{"owner":"area_focus_loop","note":"nada executa aqui"},"requires_owner_execution":true,
     "executed":false,"atlas_auto_decided":false,"autoapproval_allowed":false,
     "autoimplementation_allowed":false,"branch_created":false,"provider_invoked":false,
     "mutates_target_repo":false,"parallel_registry_created":false,"operator_owned":true,
     "decision_hash":"sha256:def456","decided_at":"2026-07-13T12:00:00Z"}
    """
    let decisionReceipt = try? decoder.decode(AtlasAutonomosOperatorDecisionReceipt.self, from: Data(decisionJSON.utf8))
    check("decisão Autônomos preserva recibo e nunca finge execução", decisionReceipt?.decision == .accept && decisionReceipt?.isRecordedDecisionOnly == true && decisionReceipt?.requiresOwnerExecution == true && decisionReceipt?.routesToOwner.owner == "area_focus_loop")
    let highRiskAccept = AtlasAutonomosOperatorDecisionInput(
        operatorActor: "vitor", decision: .accept, findingHash: "sha256:abc", riskLevel: .high
    )
    check("aceite de alto risco exige justificativa local", highRiskAccept.isLocallyValidForSubmission == false)
    let acceptedDecision = AtlasAutonomosOperatorDecisionInput(
        operatorActor: "vitor", decision: .accept, findingHash: "sha256:abc",
        rationale: "risco revisado", riskLevel: .high
    )
    let decisionEncoder = JSONEncoder(); decisionEncoder.keyEncodingStrategy = .convertToSnakeCase
    let decisionPayload = (try? JSONSerialization.jsonObject(with: decisionEncoder.encode(acceptedDecision))) as? [String: Any]
    check("decisão Autônomos envia contrato snake_case esperado pelo servidor", decisionPayload?["operator_actor"] as? String == "vitor" && decisionPayload?["finding_hash"] as? String == "sha256:abc" && decisionPayload?["risk_level"] as? String == "high")

    let fleetJSON = """
    {"schema_version":"atlas.agents.status.v1","generated_at":"2026-07-13T12:00:00Z",
     "fleet_master":"on","active_count":1,"spending_accounts":["atlas"],
     "agents":[{"key":"loop","label":"Loop principal","account":"atlas","kind":"loop",
       "provider_spending":true,"desired":true,"authorized":true,"set_by":"vitor",
       "set_at":"2026-07-13T11:00:00Z","ttl_remaining_seconds":300,"budget_limit_usd":20,
       "target_ref":"main","reason":"operação","status":"running","alive":true,
       "pids":[123],"uptime_seconds":60,"spent_usd":1.5}]}
    """
    let fleet = try? decoder.decode(AtlasAutonomosFleetResponse.self, from: Data(fleetJSON.utf8))
    check("frota global preserva agente vivo e uptime real", fleet?.activeCount == 1 && fleet?.agents.first?.isAlive == true && fleet?.agents.first?.uptimeSeconds == 60)

    let historyJSON = """
    {"schema_version":"atlas.agents.history.v1","events":[{"agent_key":"loop","event":"started",
      "at":"2026-07-13T12:00:00Z","by":"reconciler","account":"atlas","pid":123,
      "duration_seconds":null,"reason":"operator_confirmed"}]}
    """
    let history = try? decoder.decode(AtlasAutonomosFleetHistoryResponse.self, from: Data(historyJSON.utf8))
    check("histórico da frota é append-only tipado e provider-safe", history?.events.first?.event == "started" && history?.events.first?.reason == "operator_confirmed")

    let taskHealthJSON = """
    {"schema_version":"atlas.autonomos.task_health.v1","observed_at":"2026-07-14T00:43:00Z",
     "provider_safe":true,"healthy":false,
     "tasks":{"claimable":12,"servable_now":8,"claimed":2,"blocked":1,"completed":4,"recoverable":3},
     "leases":{"active":2,"matches_claimed":true},
     "incidents":{"present":true,"flags":["serving_jammed"]},
     "operating":{"recommended_action":"recover_blocked_backlog","queue_pressure":"high"}}
    """
    let taskHealth = try? decoder.decode(AtlasAutonomosTaskHealthResponse.self, from: Data(taskHealthJSON.utf8))
    check("saúde da fila Autônomos é tipada sem expor pacote ou prompt", taskHealth?.providerSafe == true && taskHealth?.tasks.servableNow == 8 && taskHealth?.leases.matchesClaimed == true)
    check("incidente da fila é explícito e não vira progresso inventado", taskHealth?.incidents.present == true && taskHealth?.incidents.flags == ["serving_jammed"] && taskHealth?.operating.queuePressure == "high")
}

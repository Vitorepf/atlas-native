import Foundation

// MARK: - Golden checks

/// Decoda um fixture realista (snake_case, shape do servidor) da resposta
/// principal do cluster e prova: snake->camel, bag JSONValue, contador Int,
/// null->nil, união aberta (action) como String, struct aninhada.
public func runJobsChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "jobs": [
        {
          "id": "job_1",
          "trace_id": null,
          "client_id": "cli_9",
          "kind": "interaction",
          "status": "awaiting_user_choice",
          "priority": 5,
          "agent_slug": "atlas.router",
          "provider": "claude_cli",
          "model": null,
          "input_text": "resume this",
          "context_refs": [],
          "payload": {"topic": "jobs"},
          "atlas_decide_execution": {
            "strategy": "sequential",
            "dependency_timeout_seconds": 30
          },
          "result_text": null,
          "result_json": {},
          "error_code": null,
          "error_message": null,
          "available_at": null,
          "reserved_at": null,
          "started_at": null,
          "finished_at": null,
          "attempts": 2,
          "max_attempts": 3,
          "timeout_seconds": 120,
          "worker_id": null,
          "awaiting_user_choice": true,
          "choice_options": [
            {"id": "opt_switch", "label": "Switch provider", "action": "switch_provider"}
          ],
          "metadata": {"source": "cli"},
          "attempt_history": [
            {
              "id": "att_1",
              "ai_job_id": "job_1",
              "attempt_number": 1,
              "worker_id": "worker_a",
              "provider": "claude_cli",
              "model": "claude-opus",
              "command": ["claude", "run"],
              "command_hash": null,
              "prompt_hash": "abc123",
              "response_hash": null,
              "status": "failed",
              "exit_code": 1,
              "duration_ms": 8421,
              "output_text": null,
              "stdout_excerpt": null,
              "stderr_excerpt": "boom",
              "error_code": "provider_error",
              "error_message": "provider failed",
              "started_at": "2026-07-12T10:00:00Z",
              "finished_at": "2026-07-12T10:00:08Z",
              "metadata": {},
              "created_at": "2026-07-12T10:00:00Z",
              "updated_at": "2026-07-12T10:00:08Z"
            }
          ],
          "created_at": "2026-07-12T09:59:00Z",
          "updated_at": "2026-07-12T10:00:08Z"
        }
      ]
    }
    """
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = atlasSnakeKeyDecoding
    do {
        let resp = try dec.decode(AiJobsResponse.self, from: Data(json.utf8))
        let job = resp.jobs[0]
        check("jobs snake->camel: agentSlug", job.agentSlug == "atlas.router")
        check("jobs snake->camel: inputText", job.inputText == "resume this")
        check("jobs Int count: attempts", job.attempts == 2)
        check("jobs Int: timeoutSeconds", job.timeoutSeconds == 120)
        check("jobs null->nil: traceId", job.traceId == nil)
        check("jobs metadata JSONValue", job.metadata?["source"]?.stringValue == "cli")
        check("jobs open-union action String", job.choiceOptions?.first?.action == "switch_provider")
        check("jobs nested attempt durationMs Int", job.attemptHistory?.first?.durationMs == 8421)
        check("jobs nested execution state", job.atlasDecideExecution?.dependencyTimeoutSeconds == 30)
    } catch {
        check("jobs decodes AiJobsResponse", false)
    }
}

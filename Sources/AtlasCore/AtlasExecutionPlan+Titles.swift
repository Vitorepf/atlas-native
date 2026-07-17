import Foundation

extension AtlasExecutionPlan {
    static func steps(from value: JSONValue?) -> [Step] {
        guard case .array(let values) = value else { return [] }
        return values.compactMap { value in
            guard case .object(let object) = value,
                  let id = object["id"]?.stringValue,
                  let checkpoint = object["checkpoint"]?.stringValue,
                  let title = object["title"]?.stringValue,
                  !id.isEmpty, !checkpoint.isEmpty, !title.isEmpty
            else { return nil }
            return Step(id: id, checkpoint: checkpoint, title: title)
        }
    }

    static func workflowTitle(_ workflow: String) -> String {
        switch workflow {
        case "plan_execute_test_review_summarize": return "Planejar, executar e comprovar"
        case "reproduce_localize_patch_regress": return "Reproduzir, corrigir e testar"
        case "read_diff_find_risks_recommend": return "Revisar mudanças e riscos"
        case "plan_source_extract_synthesize": return "Pesquisar e sintetizar"
        case "frame_options_tradeoffs_recommend": return "Avaliar opções e recomendar"
        case "extract_classify_validate_store_candidate": return "Extrair e validar memória"
        case "frame_plan_risks_next_step": return "Definir plano e próximos passos"
        case "direct_answer_with_context": return "Responder com contexto"
        default: return "Plano de execução"
        }
    }

    static func agentTitle(_ value: String) -> String {
        switch value {
        case "planner": return "Planejador"
        case "executor": return "Executor"
        case "reviewer": return "Revisor"
        case "debugger": return "Depurador"
        case "researcher": return "Pesquisador"
        case "source_checker": return "Verificador de fontes"
        case "synthesizer": return "Sintetizador"
        case "decision_advisor": return "Conselheiro de decisão"
        case "skeptic": return "Revisor crítico"
        case "memory_writer": return "Curador de memória"
        case "evaluator": return "Avaliador"
        default: return value.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    static func toolTitle(_ value: String) -> String {
        switch value {
        case "semantic_search": return "Busca semântica"
        case "session.search": return "Busca na sessão"
        case "repo_context": return "Contexto do projeto"
        case "git_diff": return "Diferenças do Git"
        case "source_retrieval": return "Recuperação de fontes"
        case "memory_schema": return "Esquema de memória"
        default: return value.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    static func gateTitle(_ value: String) -> String {
        switch value {
        case "answer_grounded_in_context_or_lacuna_declared": return "Resposta fundamentada ou lacuna declarada"
        case "findings_before_summary": return "Achados antes do resumo"
        case "risks_and_missing_tests_checked": return "Riscos e testes ausentes verificados"
        case "diff_summary_required": return "Resumo das mudanças"
        case "tests_or_not_run_reason_required": return "Testes ou motivo registrado"
        case "sources_required_when_claiming_facts": return "Fontes exigidas para fatos"
        case "tradeoffs_and_reversibility_required": return "Trade-offs e reversibilidade explícitos"
        case "human_authorship_preserved": return "Autoria humana preservada"
        case "memory_origin_scope_confidence_required": return "Origem, escopo e confiança registrados"
        case "human_confirmation_required": return "Confirmação humana necessária"
        default: return value.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

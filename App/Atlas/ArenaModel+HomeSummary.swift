import Foundation

// Resumo humano da exceção para a HOME — presentation-only.
//
// A home não fala jargão (suíte/motor/delta): o ponto vermelho é o alerta,
// a sublinha diz só "N regressões" em voz calma. A exceção completa
// (regressionException) vive DENTRO da Arena, onde o detalhe é o assunto.

extension ArenaModel {
    var regressionSummary: String? {
        let n = scoreboard?.suites.filter { suite in
            suite.engines.contains(where: \.regressed)
        }.count ?? 0
        guard n > 0 else { return nil }
        return n == 1 ? "1 regressão" : "\(n) regressões"
    }
}

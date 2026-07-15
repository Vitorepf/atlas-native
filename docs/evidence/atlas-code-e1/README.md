# E1 · prova do grafo no simulador

Captura do M0 no simulador: [m0-simulator.jpg](m0-simulator.jpg).

O M0 mostra, ao lado de cada nó, o prefixo do hash recebido pelo endpoint.
O primeiro trecho visível é `b43e907d`, `d62fd132`, `3caf7538`, `1c9e2e81`,
`31354901`, `69f589bd`, `affd8e1a`, `647ec51e`, `39373fc1`, `bab6bd3b`,
`617aad40`, `f708145e`. Eles correspondem aos hashes completos do comando
real em [git-log.txt](git-log.txt), na mesma ordem topo-ordenada.

Runtime: iPhone 17 Pro Simulator, iOS 26.5, Atlas build/run aprovado, backend
local servido em `127.0.0.1:3737` a partir do checkout do `atlas-server`.
O override `ATLAS_HOST=127.0.0.1` foi apenas argumento de build do simulador;
nenhum arquivo de segredo foi alterado.

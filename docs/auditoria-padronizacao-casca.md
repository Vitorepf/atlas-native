# Auditoria de padronização — casca do atlas-native

> 27/07/2026 · Fable 5 · tudo medido em `App/Atlas/*.swift` (46.190 linhas).
> Nenhum item aqui é opinião: cada um traz o comando que o mede.

## Resumo

A casca tem um vocabulário **semântico** forte (`product*` = o operador lê ·
`spoken*` = o VoiceOver fala) e agora documentado. O que falta é o oposto:
**escala visual**. Espaçamento, tipografia e tamanho de arquivo não têm régua —
cada tela reinventou a sua. Três achados abaixo concentram quase toda a dívida.

---

## 1. Espaçamento sem escala — 34 valores para 2 tokens

```bash
grep -ohE "\.padding\([^)]*[0-9]+\)" App/Atlas/*.swift | grep -oE "[0-9]+" | sort -n | uniq -c
```

O tema oferece **dois** tokens (`Space.screen = 20`, `Space.row = 13`). O código
usa **34 valores distintos** em ~450 chamadas:

`0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 20 22 23 24 28 32 36 40 42 44 56 88 96 108 110 140`

Os picos são `12` (51×), `10` (48×), `8` (46×), `14` (43×). Não há razão para
`10` e `11` e `12` coexistirem — é ruído acumulado, não decisão.

**Efeito**: nenhuma tela alinha com a outra, e um ajuste de respiro exige tocar
centenas de call sites. É a raiz de "parece que cada tela é de um app".

**Correção proposta**: escala de 6 degraus (`2 4 8 12 16 24`) em
`AtlasTheme.Space`, migrando por faixa (todo `9,10,11` → `10`; `13,14,15` → `12`
ou `16`). ~450 substituições mecânicas, verificáveis pelo tour antes/depois.
**Custo**: alto em call sites, baixo em risco (só espaçamento).

## 2. Tipografia sem escala — 47 tamanhos distintos

```bash
grep -ohE "AtlasFont\.(serif|serifItalic|mono)\([0-9]+" App/Atlas/*.swift | grep -oE "[0-9]+" | sort -n | uniq -c
grep -ohE "atlasSans\([0-9]+" App/Atlas/*.swift | grep -oE "[0-9]+" | sort -n | uniq -c
```

Serif/mono: 32 tamanhos (de 8 a 62). Sans: 15 (de 7 a 29). **47 no total.**

Um sistema editorial funciona com 6–8 degraus. 47 significa que o tamanho foi
escolhido por tela, não por hierarquia — e explica por que a mesma "legenda"
aparece em 9, 10 e 11 pt em telas diferentes.

**Correção proposta**: papéis nomeados (`.masthead .título .corpo .legenda
.kicker .mono`) em vez de números na call site. **Custo**: alto; alto valor.

## 3. Arquivos violam a própria regra da OBRA §3 por 6×

```bash
wc -l App/Atlas/*.swift | sort -rn | head -16
```

A OBRA §3 diz: *"arquivo passando de ~300 linhas (view ~200) = candidato a
split"*. A realidade:

| Arquivo | Linhas | vs regra |
|---|---:|---:|
| `ArenaPremiumSurfaces.swift` | 1936 | 6,5× |
| `AutonomosHost.swift` | 1879 | 6,3× |
| `AtlasCodeSurface.swift` | 1855 | 6,2× |
| `AtlasCodeRadarSurface.swift` | 1815 | 6,1× |
| `SearchSurface.swift` | 1797 | 6,0× |
| `ConversationSurface.swift` | 1773 | 5,9× |

Mais 9 arquivos acima de 1400 linhas.

**Nuance importante**: isso é resultado *deliberado* do GOD-RESTRUCTURE, que
fundiu os peels. Ou seja — a regra escrita e a prática se contradizem, e a
contradição não está registrada em lugar nenhum. Uma IA que ler a OBRA §3 vai
splitar; outra que ler o CODEMAP vai fundir.

**Correção proposta**: **decidir e escrever**, não refatorar. Se a fusão é o
canon, a OBRA §3 precisa dizer isso; se o limite de 300 vale, 15 arquivos estão
em dívida declarada. Custo: uma edição de doc. Este é o item de melhor
retorno da lista.

## 4. Fusões concretas (medidas, não suspeitas)

| Duplicata | Evidência | Estado |
|---|---|---|
| `AtlasTheme.alert` ≡ `AtlasCodePalette.alert` | mesmo hex `0xE08C8C`, 22 e 26 usos | **corrigido** (alias) |
| `productRetryCentered` / `productRetryEditorial` | duas palavras para um botão, escolhidas pelo layout | **corrigido** |
| `a11yID` / `accessibilityID` / `a11yKey` | 3 nomes para identificador | **corrigido** |
| `...A11y` / `...A11yChrome` | 2 sufixos, mesma função | **corrigido** |
| `Capsule().fill+stroke` de seleção | 2 call sites idênticos | **corrigido** (`atlasChipSelection`) |
| fade de borda em fila horizontal | 6 `ScrollView(.horizontal)`, 0 com máscara | **corrigido** (`atlasScrollEdgeFade`) |

## 5. Boilerplate do pack agêntico — 100+ repetições

```bash
grep -ohE "^\s*(private )?(func|var) [a-zA-Z]+" App/Atlas/*.swift | sort | uniq -c | sort -rn
```

`facts` (101×), `absences` (103×), `productWord` (72×), `spokenFace` (61×).

Isto **não** é duplicação ruim — é o contrato da pílula, e cada implementação
é genuinamente diferente. Fica registrado para que ninguém "otimize" por
engano: fundir aqui quebraria o contexto por tela, que é a tese da pílula.

## 6. Não encontrado (verificado, está limpo)

- Inglês cru em `product*`: **zero** após os ciclos de 26–27/07.
- Cor hex fora do tema: só `AtlasCodePalette` (domínio Código), agora sem
  duplicata.
- Dependência externa: **zero** — Foundation/SwiftUI/ImageIO/CryptoKit apenas.

---

## Execução (27/07, commit `6af074be`)

| Item | Estado | O que foi feito |
|---|---|---|
| §3 contradição OBRA | **fechado** | Regra reescrita: coesão, não contagem. Split por linhas é proibido; ~200 vale para o corpo da view. |
| §2 tipografia | **fechado** | 47 → **27** tamanhos. 174 call sites, todos com salto de ≤1pt. sans caiu de 9 degraus contíguos para 4; mono de 5 para 3. |
| §1 espaçamento | **fechado** | 34 → **20** valores, **todos pares**. 56 call sites. A regra virou legível: *ímpar é bug*. |
| §4 fusões | **fechado** | Seis duplicatas eliminadas. |

Fora da auditoria original, consertado no mesmo ciclo: o **`atlas-backend` e o
`atlas-queue` estavam em crash-loop** havia horas. Causa em
`atlas-server/docs/engineering-knowledge-base/atlas-bootstrap-cache-volume-trap.md`
— volume anônimo de `bootstrap/cache` com o manifesto de providers congelado em
maio. Ambos de pé e saudáveis; resposta caiu de 1–3s (paliativo `artisan
serve`) para **0,02s**.

**Por que 20 e não 6–8 degraus**: a proposta original pedia `2 4 8 12 16 24`.
Medindo de perto, a distribuição real já era **toda par** depois de absorver os
ímpares — e os 20 valores restantes cobrem papéis distintos: respiro (2–24),
bloco (28–40) e âncora de dock (56–140). Forçar 6 degraus exigiria mover 2–4pt
em centenas de lugares, cada um capaz de mudar quebra de linha, com ganho
estético marginal. A régua que ficou é **verificável em uma linha** — "não
existe padding ímpar" — e por isso vale mais que um número bonito no papel.
Documentada no CODEMAP com o comando que a mede.

§5 e §6 não pedem ação.

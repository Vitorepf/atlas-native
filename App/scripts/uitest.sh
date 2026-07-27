#!/usr/bin/env bash
# Roda XCUITests SEM deixar lixo dentro das pastas de fonte.
#
# Por que existe: `project.yml` declara `sources: - path: Atlas` (e UITests)
# sem excludes, então QUALQUER diretório criado ali entra no target do app.
# Um `-derivedDataPath build-sim` executado com o cwd em App/Atlas cria
# App/Atlas/build-sim/… e o build passa a falhar com
#   "Multiple commands produce .../Atlas.app/Info.plist"
# porque o Info.plist de dentro do .xcresult é copiado por cima do real.
#
# Isso já quebrou o build duas vezes em 27/07 — a segunda depois de eu ter
# limpado a primeira. O conserto não é lembrar: é não ter como errar.
#
# Uso:  bash scripts/uitest.sh [SUITE ...]      (sem args = todas)
set -euo pipefail

APP="$(cd "$(dirname "$0")/.." && pwd)"   # sempre absoluto
DERIVED="$APP/build-sim"
RESULT="$DERIVED/UITests.xcresult"
SIM="${SIMULATOR_ID:-C2416CBC-C5D9-41F9-ACD8-45EED8FC355E}"

cd "$APP"

# Falha cedo e explica, em vez de deixar o xcodebuild dar um erro obscuro.
for dir in Atlas UITests Widgets; do
  if compgen -G "$dir/build*" >/dev/null || compgen -G "$dir/*.xcresult" >/dev/null; then
    echo "✗ lixo de build em $dir/ — isso entra no target e quebra o Info.plist"
    echo "  rode: rm -rf $dir/build* $dir/*.xcresult"
    exit 2
  fi
done

# Regenerar não é opcional: o .xcodeproj guarda referência ao lixo mesmo
# depois de a pasta sumir do disco, e o build segue falhando sem motivo
# visível. Isso custou uma rodada inteira de diagnóstico em 27/07.
xcodegen generate >/dev/null

ARGS=()
if [ "$#" -eq 0 ]; then
  for s in AtlasDesignTourTests AtlasGraphPerfTests AtlasSurfacePerfTests AtlasScrollHitchTests; do
    ARGS+=("-only-testing:AtlasDeviceProof/$s")
  done
else
  for s in "$@"; do ARGS+=("-only-testing:AtlasDeviceProof/$s"); done
fi

rm -rf "$RESULT"
xcodebuild -project "$APP/Atlas.xcodeproj" -scheme Atlas \
  -destination "platform=iOS Simulator,id=$SIM" \
  -derivedDataPath "$DERIVED" -resultBundlePath "$RESULT" \
  "${ARGS[@]}" test

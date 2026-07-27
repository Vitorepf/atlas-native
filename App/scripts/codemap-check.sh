#!/usr/bin/env bash
# O CODEMAP é o mapa que as IAs leem antes de mexer no código. Mapa que mente
# é pior que mapa nenhum: manda procurar o que não existe.
#
# Este check falha se algum símbolo citado entre `crases` no CODEMAP não for
# encontrado como struct/class/enum/extension ou arquivo em App/Atlas ou
# App/Widgets. Já achou 22 referências mortas em 27/07 (arquivos fundidos pelo
# GOD-RESTRUCTURE que o mapa continuava anunciando).
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import re, pathlib, sys

codemap = pathlib.Path('Atlas/CODEMAP.md').read_text()
fontes, arquivos = [], set()
for d in ('Atlas', 'Widgets'):
    for p in pathlib.Path(d).glob('*.swift'):
        fontes.append(p.read_text()); arquivos.add(p.name)
blob = "\n".join(fontes)

# Nomes que não são símbolos: target de teste e exemplos citados em prosa.
IGNORAR = {'AtlasDeviceProof', 'FINISHED'}

faltando = []
for nome in sorted(set(re.findall(r'`([A-Z][A-Za-z0-9_+]*)`', codemap))):
    if nome in IGNORAR:
        continue
    base = nome.split('+')[0]
    achou = re.search(rf'\b(struct|class|enum|extension)\s+{base}\b', blob) \
        or f'{base}.swift' in arquivos
    if not achou:
        faltando.append(nome)

if faltando:
    print("✗ CODEMAP cita o que não existe:")
    for f in faltando:
        print(f"   {f}")
    print("  corrija o mapa ou o código — IA que lê isto vai procurar em vão")
    sys.exit(1)

print("✓ CODEMAP honesto: todo símbolo citado existe")
PY

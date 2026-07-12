# Loop de dev do app Atlas nativo — o análogo do `npm run dev:ios` do Expo.
#
# Setup único (1ª vez, ~2 min no Xcode):
#   make open          # abre o projeto
#   → Signing & Capabilities: escolha seu time (Apple ID)
#   → conecte o iPhone no cabo, confie no Mac, marque "Connect via network"
#   → Cmd+R uma vez (assina + instala + confia no device)
# Depois disso o cabo é dispensável e o loop é um comando:
#   make device        # builda + instala + abre no iPhone (wireless)

SCHEME  := Atlas
PROJECT := Atlas.xcodeproj
BUNDLE  := com.vitor.atlas.native

.PHONY: generate build sim device open clean

# Regenera o .xcodeproj a partir do project.yml (texto → projeto).
generate:
	xcodegen generate

# Compila + linka o AtlasCore pro SDK do simulador. NÃO precisa de runtime nem
# assinatura — é o "typecheck" do app, roda na CLI/CI. Prova que o fio compila.
build: generate
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
	  -destination 'generic/platform=iOS Simulator' -configuration Debug \
	  build CODE_SIGNING_ALLOWED=NO | xcpretty || true

# Roda no simulador (precisa do runtime iOS uma vez: make runtime).
sim: generate
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
	  -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug build
	xcrun simctl install booted "$$(xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination 'platform=iOS Simulator,name=iPhone 16' -showBuildSettings 2>/dev/null | awk -F'= ' '/ CODESIGNING_FOLDER_PATH/{print $$2; exit}')"
	xcrun simctl launch booted $(BUNDLE)

# Baixa o runtime do simulador iOS (multi-GB, uma vez só).
runtime:
	xcodebuild -downloadPlatform iOS

# Builda + instala + abre no iPhone conectado/wireless (assinatura automática).
device: generate
	bash scripts/run-device.sh $(BUNDLE) $(SCHEME) $(PROJECT)

open: generate
	open $(PROJECT)

clean:
	rm -rf build ~/Library/Developer/Xcode/DerivedData/Atlas-*

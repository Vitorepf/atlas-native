# Atlas — app iOS nativo (SwiftUI puro)

Casca fina SwiftUI que linka o pacote **AtlasCore** (lógica/rede/merge puros, um
diretório acima). Alvo `com.vitor.atlas.native` — coexiste com o app RN
(`com.vitor.atlas`) até o cutover (estratégia parallel-native-rebuild).

O projeto `.xcodeproj` é **gerado** a partir de `project.yml` (XcodeGen) — não
fica no git, some do diff. Regenera com `make generate`.

## O loop de dev (o análogo do `npm run dev:ios` do Expo)

Nativo não tem bundle-JS-over-the-air; o app **é** código nativo, então mudança
recompila. Mas o loop chega perto de "um comando + reload":

```bash
make build     # compila + linka AtlasCore p/ SDK do simulador (sem assinar) — o "typecheck" do app
make device    # builda + instala + abre no iPhone conectado/wireless
make sim       # roda no simulador (precisa do runtime: make runtime)
make open      # abre o projeto no Xcode
```

## Setup — uma vez só

1. **Plataforma iOS** (install fresco do Xcode não traz): `make runtime`
   (`xcodebuild -downloadPlatform iOS`, alguns GB). Gate de qualquer build iOS.
2. **Assinatura** (só p/ device físico): `make open` → target Atlas → *Signing &
   Capabilities* → escolha seu time (Apple ID). Grátis funciona (app expira em 7
   dias); pago ($99/ano) tira a expiração + TestFlight.
3. **iPhone**: conecte no cabo a 1ª vez, confie no Mac, e rode **Cmd+R** uma vez
   (assina + instala + registra o device). Marque *Connect via network* na
   janela Devices → depois é wireless, cabo dispensável.
4. **Backend**: `cp Atlas/Secrets.example.xcconfig Atlas/Secrets.xcconfig` e cole
   o `ATLAS_TOKEN` (do `atlas-server/.env`). No device real, descomente
   `ATLAS_HOST` com o IP da LAN do Mac (o iPhone não acha `127.0.0.1`).

Depois disso: `make device` a cada iteração. Cabo nunca mais.

## Hot reload (recupera o Fast Refresh do Expo)

Ajuste de UI sem rebuild: adicione o pacote [Inject](https://github.com/krzysztofzablocki/Inject)
+ o app InjectionIII. Salvou o `.swift` da view → atualiza no device ao vivo.
(A fazer — Fase 0.5.)

## Estrutura

```
App/
  project.yml         → XcodeGen (fonte do .xcodeproj)
  Makefile            → o loop de um comando
  scripts/run-device.sh
  Atlas/
    AtlasApp.swift     → @main, injeta AtlasSession
    AtlasSession.swift → @Observable/@MainActor: segura AtlasClient + estado
    RootView.swift     → 1ª tela: lista de threads do Atlas AI (dado real)
    Config.xcconfig    → host/porta (Secrets.xcconfig sobrescreve, gitignored)
    Info.plist         → ATS local + chaves de backend
    Assets.xcassets/
```

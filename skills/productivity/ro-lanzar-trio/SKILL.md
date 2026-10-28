---
name: ro-lanzar-trio
description: Usar cuando Roberto pide trabajar un issue de GitHub con el trío PM/WK/RV en su PC (herdr + agy), o cuando hay que decirle cómo lanzarlo.
---
# lanzar un trío con pj-trio

## comando
pj-trio start <proyecto> <issue> --repo <repo-miembro>
- <proyecto>: el meta-repo pj- sin el prefijo de la org (ej. pj-domina, pj-omarchy, pj-paolino).
- <issue>: número del issue dentro de <repo-miembro>.
- <repo-miembro>: nombre del repo donde vive el issue, sin `robert-flo/` (ej. pj-domina-rf-git-setup).
Ejemplo: `pj-trio start pj-domina 3 --repo pj-domina-rf-git-setup` abre el trío para robert-flo/pj-domina-rf-git-setup#3.

## antes de lanzarlo
1. Verificá que el issue exista y esté abierto: `gh issue view <n> -R robert-flo/<repo>`.
2. Si pj-trio dice "no se encontró el directorio del proyecto", cloná el meta-repo: `try-clone robert-flo/<proyecto>`, y volvé a lanzarlo. Los clones viven en /z-drive/tries; nunca clones en otro lado.
3. Para ver el kickoff sin abrir nada: `pj-trio kickoff <proyecto> <issue> --repo <repo>`.

## qué pasa al lanzarlo
- Crea o reusa el workspace de herdr con PM, WK y RV, y espera a que el PM esté listo (hasta 180 s) antes de mandarle el kickoff.
- Si agy muestra el aviso de confiar en la carpeta, Roberto lo acepta a mano una vez. Nunca escribas config de confianza.
- Si se vence el tiempo, imprime el kickoff para pegarlo a mano.
- Estado: `pj-trio status <proyecto> <issue>`.

## alternativas
- `ravn-sessionizer trio`: elegir el issue desde una lista.

## reglas
- Al darle el comando a Roberto, va en una sola línea dentro de un bloque de código, sin `exec bash` ni nada que cierre su terminal.
- No uses Cursor cloud agents (no hay cuota): el trabajo de código va por pj-trio en su PC.

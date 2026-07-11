# Investigación: backends para instalar OpenCode

Fecha: 2026-07-10

## Conclusión

Nix es viable para instalar OpenCode y ofrece el mejor modelo de reproducibilidad y rollback, pero no debería ser el backend predeterminado de RaVN. En una instalación Arch orientada a dotfiles, introducir Nix únicamente para una herramienta añade un runtime de distribución completo, más estado global y más requisitos operativos.

La recomendación es mantener backends explícitos por tarea:

1. `pacman`/AUR cuando exista un paquete nativo fiable.
2. `mise` para CLIs distribuidos como paquetes npm y herramientas que necesitan un runtime versionado.
3. `nix` como backend opcional para herramientas con derivación Nix mantenida o cuando la reproducibilidad/rollback pese más que la simplicidad.
4. Instalador oficial o binario upstream como fallback explícito.
5. `npx` efímero únicamente cuando la tarea acepte dependencia de red y menor control del ciclo de vida.

## Hallazgos

El repositorio oficial de OpenCode documenta npm, Homebrew, pacman/AUR, mise y Nix como métodos soportados. También ofrece `nix run nixpkgs#opencode` y una referencia directa a su flake para desarrollo. Esto confirma que Nix no sería un experimento arbitrario para este caso.

Nix proporciona perfiles versionados: permiten instalar, listar, actualizar, eliminar y hacer rollback de paquetes independientemente. Las flakes añaden referencias bloqueables, por lo que una tarea puede fijar el commit de nixpkgs y hacer reproducible su entrada. Sin embargo, usar una referencia no bloqueada como `nixpkgs#opencode` favorece actualizaciones implícitas y una referencia fijada puede quedarse deliberadamente congelada.

La disponibilidad de `opencode` en nixpkgs es una ventaja, pero no elimina el mantenimiento. El historial de nixpkgs muestra problemas de identidad del paquete, binarios y detalles de runtime. También existen reportes de fallos de bibliotecas dinámicas al usar OpenCode dentro de entornos NixOS. No es evidencia de que falle en Arch, pero sí evidencia de que el empaquetado debe probarse en el entorno objetivo.

mise encaja mejor con el piloto actual: puede fijar Node y el paquete npm en una instalación aislada, crear un wrapper estable y no requiere shell initialization para que el wrapper invoque el runtime. Su backend npm también documenta controles sobre lifecycle scripts, aunque esos controles dependen del gestor subyacente y requieren una política explícita de confianza.

El instalador npx/omarchy es útil como compatibilidad, pero es intrínsecamente menos determinista: resuelve paquetes desde el registro, puede depender de red en la primera ejecución y necesita resolver correctamente el binario expuesto por cada paquete. Debe permanecer como backend de fallback, no como abstracción universal.

## Decisión recomendada para RaVN

No integrar Nix como dependencia obligatoria de `install.sh`. Diseñar un contrato de tarea con backend declarado y estado verificable. Para cada backend, la tarea debe definir `install`, `verify` y `reset`, además de ownership claro de wrapper, configuración, cache y runtime.

Antes de adoptar Nix globalmente, crear un piloto aislado de OpenCode que compare:

- `nix profile install` con un perfil propio de la tarea;
- `nix profile list` y ejecución del binario desde ese perfil;
- `nix profile remove`/rollback como reset;
- ejecución en Arch host y en Docker/VM;
- comportamiento sin `mise activate`, sin `.bashrc` y sin `.zshrc`;
- versión obtenida, red requerida y tiempo de primera instalación.

El criterio de aprobación no es únicamente que `opencode --version` funcione. Debe demostrarse que la tarea puede detectar un estado incompleto, repetir la instalación idempotentemente y eliminar todo lo que declara como propio sin tocar configuraciones compartidas.

## Fuentes

- [OpenCode: métodos oficiales de instalación](https://github.com/anomalyco/opencode#installation)
- [Nix: perfiles](https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-profile)
- [Nix: instalación en perfiles](https://nix.dev/manual/nix/2.31/command-ref/new-cli/nix3-profile-add.html)
- [Nix: flakes reproducibles](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-flake.html)
- [Nixpkgs](https://github.com/NixOS/nixpkgs)
- [mise: backend npm](https://mise.jdx.dev/dev-tools/backends/npm.html)
- [mise: backend y uso de CLIs npm](https://mise.jdx.dev/getting-started)
- [Nixpkgs: historial de problemas del paquete OpenCode](https://github.com/NixOS/nixpkgs/issues/424533)
- [Nixpkgs: problema de runtime de OpenCode](https://github.com/NixOS/nixpkgs/issues/432051)

# Configuracion NixOS

Guia de la configuracion de NixOS, Home Manager, Niri, Noctalia, shell y herramientas de desarrollo de este repositorio.

La configuracion actual conserva tres sistemas:

- `desktop`: configuracion original asociada al usuario `cedric`.
- `laptop`: configuracion original asociada al usuario `cedric`.
- `victus`: configuracion nueva para el usuario `alejandro` y el hostname `victus`.

El objetivo de `victus` es conservar las aplicaciones, el aspecto visual y los dotfiles existentes, cambiando solamente la identidad del usuario y de la maquina.

## 1. Como se organiza el repositorio

```text
flake.nix                 Entradas externas y definicion de hosts
flake.lock                Versiones fijadas de las entradas del flake
hosts/
  desktop/                Host original con GRUB
  laptop/                 Host original con systemd-boot y especializacion server
  victus/                 Nuevo host de Alejandro
home/
  cedric/                 Home Manager del usuario original
  server/                 Home Manager de la especializacion server
  alejandro/              Home Manager de Alejandro
modules/                  Modulos reutilizables de Home Manager
  lazyvim.nix             Herramientas de desarrollo y Treesitter
  languages.nix           Java, Maven, Gradle y JAVA_HOME
  niri.nix                Niri, Noctalia y paquetes Wayland
  ohmyzsh.nix             Zsh, Oh My Zsh y Powerlevel10k
  mpd.nix                 Music Player Daemon sobre PipeWire
dotfiles/                 Configuraciones enlazadas desde el repositorio
  ghostty/                Terminal
  niri/                   Compositor Niri
  noctalia/               Shell/barra/panel y ajustes visuales
  nvim/                   LazyVim y plugins de Neovim
  p10k/                   Tema Powerlevel10k
  profile/                Imagen de perfil
  rmpc/                   Cliente de MPD
  wallpapers/             Fondos de pantalla
```

Los archivos dentro de `dotfiles/` no se copian a `$HOME/.config`. Home Manager crea enlaces simbolicos fuera del store hacia el repositorio local. Por eso los cambios hechos en el repositorio se reflejan directamente en la configuracion de la sesion del usuario.

## 2. El flake y la seleccion del sistema

El archivo [flake.nix](flake.nix) usa estas entradas:

- `nixpkgs`: rama `nixos-unstable`.
- `home-manager`: integracion de Home Manager como modulo de NixOS.
- `zen-browser`: modulo para Zen Browser Twilight.
- `noctalia`: shell de escritorio Noctalia.
- `quickshell`: dependencia seguida por Noctalia.

La funcion interna es:

```nix
mkSystem = host: system: homeUser: nixpkgs.lib.nixosSystem { ... };
```

Recibe tres valores:

1. El nombre de la carpeta dentro de `hosts/`.
2. La arquitectura del sistema, actualmente `x86_64-linux`.
3. El usuario de Home Manager y el nombre de su carpeta dentro de `home/`.

Las salidas actuales son:

```nix
desktop = mkSystem "desktop" "x86_64-linux" "cedric";
laptop  = mkSystem "laptop"  "x86_64-linux" "cedric";
victus  = mkSystem "victus"  "x86_64-linux" "alejandro";
```

Para construir cada salida, `mkSystem` combina:

1. `hosts/${host}/configuration.nix`.
2. El modulo de NixOS de Home Manager.
3. La configuracion global de Home Manager.
4. `home/${homeUser}/home.nix` para el usuario seleccionado.

Home Manager usa el mismo `pkgs` global de NixOS mediante:

```nix
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
```

Los argumentos `inputs` y `system` se pasan a los modulos para que puedan usar entradas externas como Noctalia y Zen Browser.

## 3. Host `victus`

Los archivos del host son:

- [hosts/victus/configuration.nix](hosts/victus/configuration.nix)
- [hosts/victus/normalConfig.nix](hosts/victus/normalConfig.nix)

### Identidad

- Hostname: `victus`.
- Usuario normal: `alejandro`.
- Home: `/home/alejandro`.
- Shell del usuario: Zsh.
- Grupos adicionales: `networkmanager` y `wheel`.
- Zona horaria: `America/Tijuana`.
- Locale: `en_US.UTF-8`.

El usuario puede administrar el sistema mediante `sudo` porque pertenece al grupo `wheel`. La configuracion no establece una contrasena; se debe definir durante o despues de la instalacion con el procedimiento normal de NixOS.

### Arranque

`victus` usa systemd-boot:

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

No usa GRUB. La configuracion presupone una instalacion UEFI con una particion EFI montada en `/boot`.

### Servicios del sistema

El host habilita:

- NetworkManager.
- OpenSSH.
- Bluetooth y encendido automatico de Bluetooth.
- Blueman.
- Tailscale.
- Docker.
- Zsh.
- PipeWire con ALSA y PulseAudio compatibility.
- X11 como base necesaria para la sesion grafica configurada por el modulo normal.
- XDG Desktop Portal GTK.
- Polkit y rtkit mediante la configuracion compartida cuando corresponde.

Tambien permite paquetes no libres y activa los comandos experimentales necesarios para flakes:

```nix
nixpkgs.config.allowUnfree = true;
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Los paquetes instalados a nivel del sistema son:

- `git`
- `neovim`
- `ghostty`

### Graficos y audio

[hosts/victus/normalConfig.nix](hosts/victus/normalConfig.nix) habilita:

- `programs.niri.enable = true`.
- X11 y teclado `us,es` con `Caps Lock` como selector de layout.
- Graficos.
- PipeWire con ALSA y PulseAudio.
- PulseAudio clasico deshabilitado.
- Portal GTK.
- Autologin del usuario `alejandro`.

El autologin esta declarado, pero este repositorio no fija explicitamente un display manager concreto. La eleccion efectiva depende de los defaults y de los modulos de NixOS presentes en la version de `nixpkgs` utilizada.

## 4. Hardware pendiente de `victus`

No existe todavia `hosts/victus/hardware-configuration.nix` a proposito. Ese archivo debe generarse desde el instalador o desde el propio equipo HP Victus 15.

La configuracion esperada del equipo es:

- NVMe.
- Intel Iris Xe integrada.
- NVIDIA GeForce RTX dedicada.
- 20 GB de RAM DDR4.
- Arranque UEFI con systemd-boot.

Estos datos de hardware no estan codificados actualmente en Nix. En particular:

- La configuracion de particiones, UUIDs y swap aun no existe para `victus`.
- La GPU NVIDIA no tiene habilitado aqui ningun driver, modo hibrido, PRIME u offload.
- La cantidad de RAM no necesita una declaracion manual para que Linux la detecte.

Despues de generar el archivo especifico del equipo, hay que:

1. Guardarlo como `hosts/victus/hardware-configuration.nix`.
2. Agregar `./hardware-configuration.nix` al `imports` de [hosts/victus/configuration.nix](hosts/victus/configuration.nix).
3. Revisar la configuracion grafica NVIDIA antes de aplicar el sistema.
4. Confirmar que los UUIDs de `/` y `/boot` corresponden al NVMe real.

No se debe reutilizar el hardware configuration de `hosts/laptop/`, porque contiene UUIDs y detalles del equipo anterior.

## 5. Usuario `alejandro` y Home Manager

El archivo [home/alejandro/home.nix](home/alejandro/home.nix) define:

```nix
home.username = "alejandro";
home.homeDirectory = "/home/alejandro";
home.stateVersion = "24.11";
```

Activa Home Manager y conserva las aplicaciones del home original.

### Aplicaciones principales

- Zen Browser Twilight.
- Obsidian.
- rmpc.
- Brave.
- Steam.
- `tree`.
- Ghostty.
- Neovim/LazyVim.
- Niri.
- Noctalia.
- Nautilus.
- Swaylock.
- Xwayland Satellite.
- `wl-clipboard`.

### Cursor

El cursor global es:

- Tema: `Bibata-Modern-Classic`.
- Tamano: `24`.
- Integracion GTK habilitada.
- Integracion X11 habilitada.

### Git

La identidad configurada para Git es:

```text
Nombre: Alejandro
Correo: pineda.alejandro@cetys.edu.mx
Rama inicial: main
```

### Enlaces de dotfiles

Home Manager enlaza estas rutas:

```text
~/.config/nvim                  -> ~/nixos-config/dotfiles/nvim
~/.config/ghostty/config        -> ~/nixos-config/dotfiles/ghostty/config
~/.config/noctalia/settings.json -> ~/nixos-config/dotfiles/noctalia/settings.json
~/.config/rmpc/config.ron       -> ~/nixos-config/dotfiles/rmpc/config.ron
~/.config/niri/config.kdl       -> ~/nixos-config/dotfiles/niri/config.kdl
```

Las rutas se construyen usando `config.home.homeDirectory`, por lo que para Alejandro apuntan a `/home/alejandro/nixos-config/...`.

## 6. Inicio de la sesion grafica

El flujo esperado en `victus` es:

1. UEFI inicia systemd-boot.
2. NixOS carga la configuracion del host `victus`.
3. El display manager realiza autologin como `alejandro`.
4. Se inicia una sesion Wayland con Niri.
5. Niri enlaza su configuracion desde `dotfiles/niri/config.kdl`.
6. Niri inicia `noctalia-shell`.
7. Niri inicia `xwayland-satellite` para aplicaciones X11.
8. Dos segundos despues, Niri ejecuta el bloqueo de Noctalia mediante IPC.
9. Home Manager proporciona la configuracion del shell, terminal, editor, Noctalia, MPD y demas programas.

En [dotfiles/niri/config.kdl](dotfiles/niri/config.kdl) estan declarados estos autostarts:

```kdl
spawn-at-startup "noctalia-shell"
spawn-at-startup "xwayland-satellite"
spawn-at-startup "bash" "-c" "sleep 2 && noctalia-shell ipc call lockScreen lock"
```

El bloqueo inicial es intencional y forma parte del flujo visual de la sesion.

## 7. Niri

Niri es el compositor Wayland principal. Su configuracion esta en [dotfiles/niri/config.kdl](dotfiles/niri/config.kdl).

### Entrada

- Teclado `us,latam`.
- `Caps Lock` cambia el layout.
- El foco sigue al mouse.
- Touchpad con tap y desplazamiento natural.
- Mouse sin aceleracion adicional.

### Monitor declarado

El archivo contiene un monitor concreto:

```text
HKC OVERSEAS LIMITED 34E6UC 0000000000001
```

Con modo `3440x1440@144.000`, escala `1.0` y posicion `0,0`.

En la HP Victus este bloque puede no coincidir con el panel interno. Si Niri no detecta correctamente la pantalla, hay que revisar las salidas con:

```bash
niri msg outputs
```

y eliminar o adaptar el bloque `output`.

### Layout y aspecto

- Gaps entre ventanas: `12`.
- Anchos predefinidos: `50%`, `66%` y `100%`.
- Ancho inicial: `50%`.
- Focus ring azul `#7aa2f7`.
- Focus ring inactivo `#3b4261`.
- Sin borde de ventana normal.
- Esquinas redondeadas de `8` y opacidad general de `0.9`.
- Animaciones con velocidad normal.
- Hot corners desactivadas.

### Atajos principales

`Mod` es normalmente la tecla Super/Windows.

| Atajo | Accion |
| --- | --- |
| `Mod+Return` | Abrir Ghostty |
| `Mod+E` | Abrir Nautilus |
| `Mod+Z` | Abrir Zen Browser |
| `Mod+B` | Abrir Brave |
| `Mod+O` | Abrir Obsidian |
| `Mod+Space` | Abrir launcher de Noctalia |
| `Mod+P` | Abrir control center de Noctalia |
| `Mod+,` | Abrir ajustes de Noctalia |
| `Mod+W` | Abrir selector de wallpaper |
| `Mod+Shift+Q` | Abrir menu de sesion |
| `Mod+S` | Captura |
| `Ctrl+Print` | Captura de pantalla completa |
| `Alt+Print` | Captura de ventana |
| `Mod+H` / `Mod+L` | Mover el foco izquierda/derecha |
| `Mod+J` / `Mod+K` | Mover el foco abajo/arriba |
| `Mod+Shift+H/J/K/L` | Mover ventanas |
| `Mod+1` a `Mod+5` | Cambiar de workspace |
| `Mod+Shift+1` a `Mod+Shift+5` | Mover ventana a workspace |
| `Mod+Minus` / `Mod+Equal` | Reducir/aumentar ancho |
| `Mod+R` | Cambiar preset de ancho |
| `Mod+A` | Maximizar columna |
| `Mod+F` | Alternar ventana flotante |
| `Mod+Shift+F` | Pantalla completa |
| `Mod+Q` | Cerrar ventana |
| `Mod+Tab` | Alternar overview |
| `Mod+Ctrl+L` | Bloquear pantalla |
| `Mod+Shift+E` | Salir de Niri |
| `Mod+Shift+P` | Apagar monitores |

Las teclas multimedia controlan volumen mediante `wpctl` y brillo mediante `brightnessctl`.

## 8. Noctalia

Noctalia se importa en [modules/niri.nix](modules/niri.nix) desde la entrada externa del flake:

```nix
imports = [ inputs.noctalia.homeModules.default ];
programs.noctalia-shell.enable = true;
```

Su configuracion completa esta en [dotfiles/noctalia/settings.json](dotfiles/noctalia/settings.json). Incluye, entre otras cosas:

- Barra superior siempre visible.
- Launcher.
- Reloj.
- Monitor del sistema.
- Ventana activa.
- Media mini player.
- Bandeja del sistema.
- Historial de notificaciones.
- Bateria.
- Control center.
- Ajustes de apariencia.
- Lock screen.
- Wallpapers.
- Atajos IPC para launcher, control center, ajustes, wallpaper y menu de sesion.

Las rutas de avatar y wallpapers apuntan a `/home/alejandro/nixos-config/...`.

## 9. Ghostty y el tema visual

[dotfiles/ghostty/config](dotfiles/ghostty/config) define:

- Tema `TokyoNight Moon`.
- JetBrainsMono Nerd Font.
- Tamano de fuente `13`.
- Opacidad de fondo `0.85`.
- Blur de fondo `20`.
- Sin decoraciones de ventana.
- Padding horizontal `12` y vertical `10`.
- Cursor tipo barra con parpadeo.
- Integracion de shell con Zsh.

## 10. Zsh, Oh My Zsh y Powerlevel10k

[modules/ohmyzsh.nix](modules/ohmyzsh.nix) activa:

- Zsh.
- Completion.
- Autosuggestions.
- Syntax highlighting.
- Oh My Zsh.
- Plugins `git` y `sudo`.
- Powerlevel10k mediante `zsh-powerlevel10k`.

El tema se lee desde:

```text
~/nixos-config/dotfiles/p10k/.p10k.zsh
```

Aliases actuales:

```bash
gc              sudo nix-collect-garbage -d
rebuild         sudo nixos-rebuild switch --flake ~/nixos-config#desktop
laptop-rebuild  sudo nixos-rebuild switch --flake ~/nixos-config#laptop
```

Importante: estos aliases conservan los nombres del repositorio original. En `victus`, `rebuild` y `laptop-rebuild` no aplican automaticamente la configuracion `victus`; para este equipo hay que usar explicitamente:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#victus
```

## 11. Neovim y LazyVim

La entrada [dotfiles/nvim/init.lua](dotfiles/nvim/init.lua) arranca LazyVim mediante `config.lazy`.

El modulo [modules/lazyvim.nix](modules/lazyvim.nix) instala herramientas de desarrollo:

- GCC, Clang, GDB, CMake, Make y `pkg-config`.
- `clang-tools`.
- Node.js y Python.
- `ripgrep`, `fd`, `fzf`, `lazygit`, `wget`, `unzip`.
- Stylua y shfmt.
- Parsers Treesitter para C/C++, Lua, Python, Rust, TypeScript, JavaScript, HTML, CSS, JSON, Bash, Vim, Markdown, YAML, TOML, XML y otros.

La configuracion de LazyVim importa soporte para:

- TypeScript.
- JSON.
- Python.
- Rust.
- Clangd.

Mason instala o mantiene herramientas como:

- `pyright`.
- `rust-analyzer`.
- `typescript-language-server`.
- ESLint, Tailwind, HTML y CSS language servers.
- `clangd` y `clang-format`.
- `jdtls`.
- Prettier, Black, Ruff, Stylua y Google Java Format.

Copilot usa sugerencias inline al entrar en modo insercion. Sus teclas principales son:

- `Ctrl+L`: aceptar sugerencia completa.
- `Ctrl+J`: aceptar palabra.
- `Ctrl+E`: aceptar linea.
- `Alt+]` y `Alt+[`: siguiente/anterior sugerencia.
- `Ctrl+X`: descartar.

El panel de Copilot esta desactivado. Markdown, ayuda y commits no reciben sugerencias.

## 12. Lenguajes y herramientas Java

[modules/languages.nix](modules/languages.nix) instala:

- JDK 21.
- Maven.
- Gradle.

Tambien define:

```text
JAVA_HOME = ruta al JDK 21 de Nix
```

## 13. Musica y MPD

[modules/mpd.nix](modules/mpd.nix) activa MPD con:

- Directorio musical: `/home/Music`.
- Escucha local: `127.0.0.1`.
- Puerto por defecto: `6600`.
- Salida de audio: PipeWire.

[rmpc/config.ron](dotfiles/rmpc/config.ron) es el cliente de terminal para MPD. Usa `127.0.0.1:6600`, refresco de estado cada segundo, soporte de mouse, hot reload y atajos para cola, reproduccion, volumen, busqueda y navegacion.

## 14. Hyprland

Hyprland no es el compositor activo. El import correspondiente esta comentado en `home/alejandro/home.nix` y la entrada `hyprland` del flake tambien esta comentada.

El archivo [modules/hyprland.nix](modules/hyprland.nix) se conserva como configuracion alternativa, pero actualmente no participa en la evaluacion de `victus`.

Por esa razon, el inicio real usa Niri, no Hyprland. Si algun dia se activa Hyprland, habra que revisar tambien que la entrada `hyprland` del flake este habilitada.

## 15. Hosts originales

### `desktop`

- Usa GRUB.
- Usa el hardware configuration original de desktop.
- Hostname configurado como `nixos`.
- Usuario `cedric`.
- Tiene Niri habilitado desde su propia configuracion.
- Tiene autologin para `cedric`.
- Conserva paquetes como Ghostty, Git, Neovim y LibreOffice.

### `laptop`

- Usa systemd-boot.
- Usa el hardware configuration original de laptop.
- Hostname `laptop`.
- Usuario `cedric`.
- Importa `normalConfig.nix` y `serverConfig.nix`.
- Conserva la especializacion opcional `server`.

Estos hosts no deben mezclarse con `victus`. Sus UUIDs, usuarios y archivos de hardware pertenecen a la configuracion original.

## 16. Especializacion `server`

[hosts/laptop/serverConfig.nix](hosts/laptop/serverConfig.nix) define una especializacion llamada `server`. No se importa en `victus`.

Cuando se selecciona esa especializacion en el host laptop, desactiva o modifica partes de la sesion grafica y habilita servicios de servidor, incluyendo Immich en el puerto `2283`. Tambien usa [home/server/home.nix](home/server/home.nix), que sigue perteneciendo al usuario original `cedric`.

## 17. Operacion diaria

Desde el directorio `~/nixos-config`, los comandos habituales para `victus` son:

```bash
# Ver las salidas definidas
nix flake show

# Actualizar el lockfile cuando se desee actualizar entradas externas
nix flake update

# Aplicar la configuracion de victus despues de tener hardware-configuration.nix
sudo nixos-rebuild switch --flake .#victus

# Probar una configuracion sin convertirla en la configuracion activa
sudo nixos-rebuild test --flake .#victus

# Validar la evaluacion del flake sin cambiar el sistema
nix flake check
```

Antes de aplicar `victus` por primera vez hay que confirmar:

- Que el repositorio esta en `/home/alejandro/nixos-config`.
- Que existe `/home/alejandro`.
- Que el usuario `alejandro` tiene contrasena.
- Que existe `hosts/victus/hardware-configuration.nix`.
- Que `configuration.nix` importa ese archivo.
- Que los UUIDs de las particiones son correctos.
- Que el monitor declarado en Niri corresponde al equipo o se ha ajustado.
- Que se ha decidido como configurar la GPU NVIDIA.

## 18. Cosas que no hace esta configuracion automaticamente

- No genera hardware configuration.
- No instala NixOS.
- No configura particiones.
- No configura un driver NVIDIA especifico.
- No detecta automaticamente si el monitor ultrawide declarado existe en la HP Victus.
- No cambia los aliases heredados de Zsh.
- No habilita Hyprland.
- No copia los dotfiles: crea enlaces hacia el checkout del repositorio.

## 19. Regla de mantenimiento

Los cambios de identidad de usuario deben hacerse en todos estos lugares cuando se cree otro host:

1. `hosts/<host>/configuration.nix`.
2. `hosts/<host>/normalConfig.nix` si existe autologin.
3. `home/<usuario>/home.nix`.
4. La entrada correspondiente de `mkSystem` en `flake.nix`.
5. Cualquier ruta absoluta dentro de `modules/` o `dotfiles/`.

Las rutas basadas en `${config.home.homeDirectory}` no deben reemplazarse manualmente: se adaptan automaticamente al usuario configurado en Home Manager.

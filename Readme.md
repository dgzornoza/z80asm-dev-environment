# z80asm-dev-environment README

z80asm Developer Container Environment for Visual Studio Code.

Author: David González Zornoza

## Features

Project to set up a development environment for zx spectrum with sjasmplus/pasmo, in a visual studio code dev-container.

Environment using DeZog for debugging ASM/sjasmplus with source code tags.
Pasmo can not debug with DeZog, but you can use for build, on this sample is using PASMO for build end tap file with loader, screen and code.

## Requirements

- installed visual studio code dev-container extension:
  [https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers](vscode-remote.remote-containers)

- Docker environment

## How to use

- Download repository
- Set the folder name to the desired project name
- Open folder with Visual Studio Code
- Press F1, then execute `Dev Containers: Reopen in container`
- Wait for install container and recomended extensions
- Execute build task Ctrl + Shift + B (Build)
- All ready to develop your project

(optional for build tap file with loader + screen + code)
- Press F1 and select 'Run Task' -> 'Build with PASMO'
- use build/main-output.tap in any emulator


## Remarks

Container name is created based in folder project name, you can create other folders based on this repository with other names for more projects.
The first time it download docker hub image with the sjasmplus sources from 2023-009-05 and PASMO 0.5.5

Source code sample is from Juan Antonio Rubio García book 'Ensamblador para ZX Spectrum: ¿Hacemos un juego?'
www: https://espamatica.com/


## Links of interest 

- sjasmplus: https://github.com/z00m128/sjasmplus
- sjasmplus-doc: https://z00m128.github.io/sjasmplus/documentation.html
- PASMO-doc: https://pasmo.speccy.org/pasmodoc.html
- SPECCY: https://www.speccy.org/

- DeZog/sjasmplus sample program: https://github.com/maziac/z80-sample-program
- ASM telegram group: https://t.me/EnsambladorZXSpectrum

- My Github account: https://github.com/dgzornoza

## Releases

### 1.0.0

Initial release PASMO 0.5.5, SJASMPLUS 1.20.3

**Enjoy!**

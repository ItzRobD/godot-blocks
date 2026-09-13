# T3-TR15

A small, deliberately unpolished falling-blocks game made as a first project for learning Godot 4 and GDScript.

This is not meant to be a complete or accurate Tetris implementation. The goal was to learn the engine by building the core pieces of a familiar game from scratch: grid logic, piece movement and rotation, collision, line clearing, signals, UI, audio, and game state.

## Features

- 10×20 board with the seven standard tetromino shapes
- Timed falling that speeds up as difficulty increases
- Left/right movement, rotation, and hard drop
- Wall and stack collision
- Short lock delay once a piece lands
- Line clearing with score, lines-cleared, and difficulty tracking
- Hold and next-piece previews
- Pause, game over, and restart
- Background music and sound effects

## Not included

Things a proper Tetris game has that this project intentionally skips:

- Wall kicks (the SRS rotation system)
- Ghost piece
- 7-bag randomizer (pieces are chosen purely at random)
- Guideline scoring (T-spins, combos, back-to-back)
- Line-clear animations and visual polish

## Note

This project is a simple implementation of Tetris and does not include all the features of a full-fledged Tetris game. For a more complete experience, consider exploring other Tetris games or implementing additional features.
Assets are not specific to this project. It is known that the pause menu keybinds are not accurate.

## Controls

| Key    | Action     |
| ------ | ---------- |
| A / D  | Move left / right |
| Space  | Rotate     |
| S      | Hard drop  |
| W      | Hold piece |
| Esc    | Pause      |

## Running it

1. Install [Godot 4.7](https://godotengine.org/download) or newer.
2. Open Godot and import this folder (select `project.godot`).
3. Open `game_mode.tscn` and press **Run Current Scene** (F6).

## Project layout

| File | Responsibility |
| ---- | -------------- |
| `game_mode.gd` | Coordinator: input, falling, locking, spawning, and wiring signals to the UI |
| `grid.gd` | Board state, placement checks, and line clearing |
| `piece.gd` | Tetromino shapes, rotation, and cell positions |
| `game_state_manager.gd` | Score, lines cleared, difficulty, and game state |
| `audio_manager.gd` | Music playback and a small pool of sound-effect players |
| `main_menu.gd` | Start and game-over menu |

## Credits

Graphics and audio are by pixelquber. See [CREDITS.md](CREDITS.md).

## License

See [LICENSE](LICENSE).

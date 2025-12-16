# FPGA-Tetris
A classic implementation of the game Tetris, built using SystemVerilog on an Altera FPGA Board. The goal of the project was to test my SystemVerilog skills, create comprehensive testbenches, and work with an LED Display attachment.

Play the classic arcade-style game where geometric pieces fall from the top of the playing field. The player must manipulate these shapes by moving and rotating them to create horizontal lines of ten blocks without gaps. When a line is completed, it disappears, and the blocks above it shift down, earning the player points. The game ends when a stack of pieces reaches the top of the playing field.

[Watch my Youtube video demonstrating a game of Tetris!](https://youtu.be/BjajGMzQn48?si=0TM0EscjjZfB07jS)

## Top Level Diagram
![Top Level Diagram](https://github.com/vidyabalachander/FPGA-Tetris/blob/main/TetrisTopLevel.jpg)

## Controls
Key 3: Left

Key 2: Right

Key 1: Rotate

Key 0: Hard Drop (Instantly Place Piece)

## Rules
Objective: Clear as many lines as possible.

Line Clear: Clear a line by filling all 10 columns with blocks.

Game Over: The game ends when a newly spawned piece cannot be fully placed in the playing field.

## Technologies Used
Programming Language: SystemVerilog

Tools: Quartus Prime, ModelSim

## Author
**Vidya Balachander**

Email: vidyakbalachander@gmail.com

GitHub: [vidyabalachander](https://github.com/vidyabalachander)

LinkedIn: [vidya-balachander](https://www.linkedin.com/in/vidya-balachander/)

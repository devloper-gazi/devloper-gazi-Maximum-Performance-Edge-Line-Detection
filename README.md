# Edge Detection and Hough Transform in Assembly

This project implements **Sobel Edge Detection** and **Hough Transform** algorithms in **x86-64 Assembly** language, utilizing **AVX-512** instructions for efficient performance. It reads a **BMP image**, processes it to detect edges, applies the Hough Transform for line detection, and outputs a processed image.

## Features

- **Sobel Edge Detection**: Detects edges in an image using Sobel filter.
- **Hough Transform**: Detects lines in an edge-detected image.
- **BMP Image Input/Output**: Processes 512x512 BMP images (modifiable).
- **Optimized with AVX-512**: High-performance computation with AVX-512 instructions for speed.

## Prerequisites

- **x86-64 CPU** that supports **AVX-512** instructions.
- **NASM**: An assembler to assemble the `.asm` file.
- **Linux (or a Unix-like system)**: For building and running the assembly code.

## Files

- `edge_detection_hough.asm`: The main Assembly source code that implements edge detection and Hough transform.
- `input.bmp`: Sample input BMP image (use your own BMP images).
- `output.bmp`: Output BMP image after edge detection and Hough transform.

## Installation

### Step 1: Assemble the Source Code

First, you need to assemble and link the Assembly code. You can do this with `nasm` and `ld`.

1. Install **NASM** if you haven't already:
   ```bash
   sudo apt install nasm
   nasm -f elf64 edge_detection_hough.asm -o edge_detection_hough.o
   ld edge_detection_hough.o -o edge_detection_hough
   ./edge_detection_hough

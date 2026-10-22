# 🍬 Candy Tower (Tháp Bánh Kẹo) - 2D Physics Game

> **An independent 2D physics-based puzzle and balancing game developed from scratch using Godot Engine.**

[![Godot Engine](https://img.shields.io/badge/Godot-4.x-blue.svg)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-orange)](#)

---

## 📌 Executive Summary
* **Author:** Nguyen Phuong Linh
* **Engine & Language:** Godot Engine (GDScript), Box2D Physics Simulation
* **Project Type:** Independent STEM / Game Development Project
* **Quick Links:** [Download Releases](../../releases) | [Demo Video](#) *(Optional: Insert link)*

This project explores real-time 2D physics mechanics—specifically center-of-mass calculation, friction interaction, and rigid-body dynamics—translated into an interactive, engaging puzzle-balancing experience.

---

## 🎮 Gameplay & Core Features
* **Real-time Physics Simulation:** Utilizes `RigidBody2D` and `Area2D` nodes to accurately calculate and simulate gravity, collision impact, and structural balance.
* **Dynamic Scoring System:** Evaluates the stability and height of the candy tower dynamically based on weight distribution and center of gravity offsets.
* **Responsive UI/UX:** Complete game lifecycle management including Main Menu, Pause Menu, High Score tracking, and Game Over states.

---

## 🛠️ Technical Architecture

### 1. Scene & Node Hierarchy
```text
Main (Node2D)
├── Environment (StaticBody2D - Ground & Boundaries)
├── CandySpawner (Node2D - Object Generation & Input Handling)
├── TowerManager (Script - Center of Mass & Balance Calculation)
└── UILayer (CanvasLayer - HUD, Score, & Menu Screens)

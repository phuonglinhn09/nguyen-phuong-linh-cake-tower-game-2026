# 🍬 Candy Tower (Tháp Bánh Kẹo) - 2D Physics Game

> **Một dự án game 2D mô phỏng vật lý được phát triển độc lập sử dụng Godot Engine.**

[![Godot Engine](https://img.shields.io/badge/Godot-4.x-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-orange)](#)

---

## 📌 Executive Summary / Tổng quan dự án
* **Tác giả:** Nguyễn Phương Linh
* **Công nghệ sử dụng:** Godot Engine (GDScript), Box2D Physics Simulation.
* **Thời gian thực hiện:** [Tháng/Năm]
* **Demo / Release:** [Link tải file game .exe hoặc link xem video Demo]

Dự án được xây dựng nhằm nghiên cứu và ứng dụng cơ chế vật lý 2D (khái niệm trọng tâm, lực ma sát, sự va chạm biến dạng) vào lập trình game giải đố, tạo ra trải nghiệm tương tác trực quan cho người chơi.

---

## 🎮 Gameplay & Highlights (Tính năng chính)
- **Cơ chế mô phỏng vật lý thời gian thực:** Áp dụng `RigidBody2D` và `Area2D` để tính toán chính xác trọng tâm và điểm tựa của các khối bánh kẹo.
- **Hệ thống tính điểm động (Dynamic Scoring):** Độ bền và điểm số của tháp được tính dựa trên độ lệch trọng tâm và số lượng vật thể xếp đè lên nhau.
- **Giao diện & Trải nghiệm (UI/UX):** Xây dựng hoàn chỉnh màn hình Menu, Pause, High Score và Game Over responsive trên nhiều độ phân giải.

---

## 🛠️ Technical Architecture (Kiến trúc Kỹ thuật)

### 1. Cấu trúc Scene & Node (Scene Hierarchy)
```text
Main (Node2D)
├── Environment (StaticBody2D - Mặt đất & Vật cản)
├── CandySpawner (Node2D - Quản lý sinh vật thể)
├── TowerManager (Script - Tính toán trọng tâm & cân bằng)
└── UILayer (CanvasLayer - Màn hình UI & Điểm số)

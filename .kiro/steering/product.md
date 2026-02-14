---
inclusion: always
---

# Product Overview

ControlR is an open-source, cross-platform remote access and remote control solution for managing devices remotely. It enables users to control desktops, transfer files, access terminals, and communicate via chat across Windows, Linux, and macOS systems.

## Core Capabilities

- Remote desktop control with real-time screen streaming
- Secure file transfer and file system browsing
- Cross-platform terminal access (embedded PowerShell)
- Real-time chat between web clients and desktop clients
- Multi-tenancy support for MSPs and organizations
- Self-hosted deployment via Docker
- Role-based and resource-based authorization
- Personal Access Tokens (PATs) for API authentication
- Experimental VNC support for Mac and Linux

## Architecture

ControlR consists of three main components:

1. **Web Server** - ASP.NET Core backend with SignalR hubs, REST API, and Blazor WebAssembly frontend
2. **Agent** - Background service/daemon running on controlled devices, handles heartbeats and command routing
3. **Desktop Client** - Avalonia UI application running in user sessions, performs actual screen capture and input simulation

Communication flows through SignalR for control messages and WebSocket relay for real-time remote control streams. Agent and Desktop Client communicate via IPC (named pipes).

## Deployment

Primary deployment is via Docker Compose with PostgreSQL database. Supports reverse proxy configurations (Nginx, Caddy, Cloudflare). Can be deployed on Railway or self-hosted on-premises.

## Platform Support

- Windows 11 (x64, x86) - Full support
- macOS (Apple Silicon and Intel) - Full support with experimental VNC
- Ubuntu AMD64 (latest LTS) - Full support on X11, experimental on Wayland

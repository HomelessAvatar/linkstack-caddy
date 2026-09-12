# 🔗 LinkStack Caddy

Ultra-lightweight, high-performance [LinkStack](https://linkstack.org/) container powered by **Alpine Linux**, **PHP 8.4-FPM** (with `ondemand` process management), and **Caddy v2** with native **HTTP/3 (QUIC)** support.

Replaces the bloated official Apache prefork image, slashing idle RAM consumption from **~220 MB** down to **~15 - 25 MB**.

---

## ✨ Features

* **🧠 Ultra-low RAM Footprint:** PHP-FPM configured with `pm = ondemand`. Idle worker processes terminate after 10s of inactivity.
* **⚡ Caddy v2 Web Server:** Blazing-fast static file serving with `zstd` & `gzip` compression, HTTP/2 & HTTP/3.
* **🛡️ Hardened Security:** Direct Caddy-level blocking (HTTP 403) for `.sqlite`, `.env`, `.git`, `/database/*`, and Laravel system directories.
* **🐘 Modern PHP 8.4:** Powered by PHP 8.4-FPM Alpine with OPcache, SQLite, MySQL, and GD support.
* **🌍 Multi-Arch:** Built for both `linux/amd64` and `linux/arm64`.

---

## 🚀 Quick Start with Docker Compose

Create a `docker-compose.yml`:

```yaml
services:
  linkstack:
    image: ghcr.io/homelessavatar/linkstack-caddy:latest
    container_name: linkstack
    restart: unless-stopped
    ports:
      - "127.0.0.1:8097:80"
    environment:
      - TZ=Europe/Istanbul
      - PHP_MEMORY_LIMIT=128M
      - UPLOAD_MAX_FILESIZE=8M
    volumes:
      - linkstack_data:/htdocs

volumes:
  linkstack_data:
```

Run:
```bash
docker compose up -d
```

---

## 🔒 Reverse Proxy Example (Caddy)

```caddy
links.example.com {
    encode zstd gzip
    reverse_proxy 127.0.0.1:8097
}
```

---

## ⚖️ Performance Comparison

| Metric | Official Image (Apache) | LinkStack Caddy (This Image) |
| :--- | :--- | :--- |
| **Web Server** | Apache 2.4 (Prefork) | ⚡ Caddy v2 (HTTP/3) |
| **PHP Runtime** | PHP 8.3 mod_php | 🐘 PHP 8.4-FPM (Ondemand) |
| **Idle RAM Usage** | 🔴 **~170 - 220 MB** | 🟢 **~15 - 25 MB** |
| **Active Processes** | 12+ PIDs | 3 PIDs |
| **Security Rules** | `.htaccess` (Runtime) | Native Caddy 403 block |

---

## 📄 License

MIT License. LinkStack itself is licensed under GPL-3.0.

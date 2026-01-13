# Deploy ComparezAssurez (DigitalOcean)

This setup runs:
- Postgres (container)
- Spring Boot backend (container)
- Angular frontend + Nginx (container)
- Ollama on the host (not containerized)

## 1) Prepare the droplet

Install Docker + Compose (skip if already installed):
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Install Ollama on the droplet and pull the model:
```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull mistral:latest
```

## 2) Upload your repo to the droplet

Example:
```bash
git clone <your-repo-url>
cd project1
```

## 3) Configure env

```bash
cp deployment/.env.example deployment/.env
```

Update `deployment/.env` if you want different DB credentials or model name.

## 4) Build and run

```bash
docker compose -f deployment/docker-compose.yml --env-file deployment/.env up -d --build
```

The app will be available on:
```
http://<droplet-ip>:8080/chat
```

## 5) Domain + HTTPS (tekup-admission.me)

Point your domain A record to the droplet IP.

Install Nginx + Certbot on the host:
```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

Create `/etc/nginx/sites-available/tekup-admission.me`:
```nginx
server {
  listen 80;
  server_name tekup-admission.me www.tekup-admission.me;

  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Enable and reload:
```bash
sudo ln -s /etc/nginx/sites-available/tekup-admission.me /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Get HTTPS:
```bash
sudo certbot --nginx -d tekup-admission.me -d www.tekup-admission.me
```

After this, your app will be live at:
```
https://tekup-admission.me/chat
```

## Troubleshooting
- Check containers:
  ```bash
  docker compose -f deployment/docker-compose.yml ps
  docker compose -f deployment/docker-compose.yml logs -f --tail=200
  ```
- If Ollama is down, backend responses will fail. Restart with:
  ```bash
  systemctl status ollama
  ```

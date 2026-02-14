#!/usr/bin/env bash
set -euo pipefail

echo "=== Bootstrap: creando estructura y archivos para Super-App-Viajes ==="

# Directorios
mkdir -p apps/web
mkdir -p apps/api/src/routes
mkdir -p apps/api/src/utils
mkdir -p apps/api/prisma
mkdir -p crm
mkdir -p data
mkdir -p .github/workflows
mkdir -p .github/scripts
mkdir -p docs

# README
cat > README.md <<'EOF'
# Super-App-Viajes — Global Tierra (Starter Kit)

Repositorio inicial con:
- Mockup Home (HTML + Tailwind)
- Dashboard mockup (HTML + Chart.js)
- Esqueleto API (Node/TS + ejemplos Python)
- Integraciones: PayPal, Stripe (ejemplos)
- CRM init script (Holstin)
- Mailer (SMTP) y WhatsApp (Meta) ejemplos
- CI/CD workflow (GitHub Actions) para Docker Hub / Vercel / Render

NO incluir secretos en este repo. Rellenar .env en local o en GitHub Secrets.

Contact: maurodestinodeveloper@gmail.com
EOF

# LICENSE (MIT)
cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2026 Mauricio

Permission is hereby granted, free of charge, to any person obtaining a copy
...
EOF

# .env.example
cat > .env.example <<'EOF'
# API
PORT=4000
DATABASE_URL=postgresql://globalt:changeme@localhost:5432/globalt_db

# PayPal (sandbox)
PAYPAL_CLIENT_ID=your_paypal_client_id
PAYPAL_CLIENT_SECRET=your_paypal_client_secret

# Stripe
STRIPE_SECRET_KEY=your_stripe_secret

# SMTP (SendGrid / Mailgun)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=your_sendgrid_api_key
NOTIFY_EMAIL=maurodestinodeveloper@gmail.com

# Twilio / WhatsApp
WHATSAPP_ACCESS_TOKEN=your_whatsapp_token
CRM_API_KEY=your_holstin_api_key
EOF

# docker-compose.yml
cat > docker-compose.yml <<'EOF'
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: globalt
      POSTGRES_PASSWORD: changeme
      POSTGRES_DB: globalt_db
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  redis:
    image: redis:7
    ports:
      - "6379:6379"
  api:
    build:
      context: ./apps/api
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: "postgresql://globalt:changeme@postgres:5432/globalt_db"
      REDIS_URL: "redis://redis:6379"
      NODE_ENV: development
    depends_on:
      - postgres
      - redis
    ports:
      - "4000:4000"
    volumes:
      - ./apps/api:/usr/src/app
  web:
    build:
      context: ./apps/web
      dockerfile: Dockerfile
    environment:
      API_URL: "http://localhost:4000"
      NODE_ENV: development
    depends_on:
      - api
    ports:
      - "3000:3000"
    volumes:
      - ./apps/web:/usr/src/app
volumes:
  pgdata:
EOF

# GitHub Actions workflow
cat > .github/workflows/ci-cd.yml <<'EOF'
name: CI/CD

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "20"
      - name: Build frontend (if Next.js)
        run: |
          if [ -f apps/web/package.json ]; then
            cd apps/web
            npm ci
            npm run build || echo "No frontend build-script"
          fi
      - name: Build backend
        run: |
          if [ -f apps/api/package.json ]; then
            cd apps/api
            npm ci || echo "No node backend deps"
          fi

  publish-docker:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Build & push backend image
        uses: docker/build-push-action@v5
        with:
          context: ./apps/api
          file: ./apps/api/Dockerfile
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/globalt-api:latest
      - name: Build & push frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./apps/web
          file: ./apps/web/Dockerfile
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/globalt-web:latest

  deploy:
    needs: publish-docker
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Trigger Render deploy (if configured)
        if: ${{ secrets.RENDER_SERVICE_ID && secrets.RENDER_API_KEY }}
        run: |
          curl -X POST "https://api.render.com/v1/services/${RENDER_SERVICE_ID}/deploys" \
            -H "Authorization: Bearer ${RENDER_API_KEY}" \
            -H "Content-Type: application/json" \
            -d '{"clearCache": true }'
      - name: Deploy to Vercel (if configured)
        if: ${{ secrets.VERCEL_TOKEN && secrets.VERCEL_PROJECT_ID }}
        run: |
          npm i -g vercel@33.0.0
          vercel deploy --prod --token "$VERCEL_TOKEN" --confirm --project "$VERCEL_PROJECT_ID"
EOF

# deploy scripts
cat > .github/scripts/deploy_render.sh <<'EOF'
#!/usr/bin/env bash
set -e
if [ -z "$RENDER_SERVICE_ID" ] || [ -z "$RENDER_API_KEY" ]; then
  echo "RENDER_SERVICE_ID or RENDER_API_KEY not set. Skipping Render deploy."
  exit 0
fi
curl -X POST "https://api.render.com/v1/services/${RENDER_SERVICE_ID}/deploys" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"clearCache": true }'
EOF
chmod +x .github/scripts/deploy_render.sh

cat > .github/scripts/deploy_vercel.sh <<'EOF'
#!/usr/bin/env bash
set -e
if [ -z "$VERCEL_TOKEN" ] || [ -z "$VERCEL_PROJECT_ID" ] || [ -z "$VERCEL_ORG_ID" ]; then
  echo "VERCEL_TOKEN or VERCEL_PROJECT_ID or VERCEL_ORG_ID not set. Skipping Vercel deploy."
  exit 0
fi
npm i -g vercel@33.0.0
vercel deploy --prod --token "$VERCEL_TOKEN" --confirm --project "$VERCEL_PROJECT_ID" --org "$VERCEL_ORG_ID"
EOF
chmod +x .github/scripts/deploy_vercel.sh

# apps/web mockup (HTML)
cat > apps/web/mockup-home.html <<'EOF'
<!doctype html><html lang="es"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/><title>Global Tierra — Mockup Home</title><script src="https://cdn.tailwindcss.com"></script></head><body class="bg-gray-50 p-6"><h1 class="text-3xl font-bold">Global Tierra — Mockup Home</h1><p>Ver mockup-dashboard en /dashboard-mockup.html</p></body></html>
EOF

# apps/web dashboard mockup
cat > apps/web/dashboard-mockup.html <<'EOF'
<!doctype html><html lang="es"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/><title>Dashboard Mockup</title><script src="https://cdn.tailwindcss.com"></script><script src="https://cdn.jsdelivr.net/npm/chart.js"></script></head><body class="p-6 bg-gray-100"><h1 class="text-2xl font-bold">Dashboard Mockup</h1><canvas id="chart" width="400" height="150"></canvas><script>const ctx=document.getElementById('chart');new Chart(ctx,{type:'bar',data:{labels:['Ene','Feb','Mar'],datasets:[{label:'Reservas',data:[10,20,15],backgroundColor:'#2f5d43'}]}})</script></body></html>
EOF

# apps/web package.json (starter)
cat > apps/web/package.json <<'EOF'
{
  "name": "globalt-web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "axios": "^1.4.0",
    "tailwindcss": "^4.0.0"
  }
}
EOF

# apps/api package.json (starter)
cat > apps/api/package.json <<'EOF'
{
  "name": "globalt-api",
  "version": "0.1.0",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc -p .",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0",
    "axios": "^1.4.0",
    "@paypal/checkout-server-sdk": "^1.0.2",
    "stripe": "^12.0.0",
    "nodemailer": "^6.9.3",
    "ioredis": "^5.3.2",
    "prisma": "^5.0.0",
    "@prisma/client": "^5.0.0"
  },
  "devDependencies": {
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.1.6"
  }
}
EOF

# apps/api/src/index.ts (simple)
cat > apps/api/src/index.ts <<'EOF'
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { PrismaClient } from "@prisma/client";
import crmRoutes from "./routes/crm";
import paypalRoutes from "./routes/paypal";
dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());
const prisma = new PrismaClient();
app.set("prisma", prisma);
app.use("/api/crm", crmRoutes);
app.use("/api/paypal", paypalRoutes);
app.get("/api/health", (req, res) => res.json({ ok: true }));
const port = Number(process.env.PORT || 4000);
app.listen(port, () => console.log(`API listening on ${port}`));
EOF

# apps/api/src/routes/crm.ts
cat > apps/api/src/routes/crm.ts <<'EOF'
import { Router } from "express";
import nodemailer from "nodemailer";
const router = Router();
router.post("/leads", async (req, res) => {
  const { nombre, correo, telefono, mensaje } = req.body;
  // TODO: guardar en DB
  // Enviar email (demo)
  try {
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: Number(process.env.SMTP_PORT || 587),
      auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS }
    });
    await transporter.sendMail({
      from: '"Global Tierra" <no-reply@globaltierra.com>',
      to: process.env.NOTIFY_EMAIL,
      subject: `Nuevo lead: ${nombre}`,
      text: `Nuevo lead: ${nombre} - ${correo} - ${telefono}\nMensaje: ${mensaje}`
    });
  } catch (err) {
    console.warn("Error enviando email", err);
  }
  res.json({ status: "ok", lead: { nombre, correo, telefono, mensaje } });
});
export default router;
EOF

# apps/api/src/routes/paypal.ts
cat > apps/api/src/routes/paypal.ts <<'EOF'
import { Router } from "express";
import paypal from "@paypal/checkout-server-sdk";
const router = Router();
const env = new paypal.core.SandboxEnvironment(process.env.PAYPAL_CLIENT_ID || "", process.env.PAYPAL_CLIENT_SECRET || "");
const client = new paypal.core.PayPalHttpClient(env);
router.post("/create-order", async (req, res) => {
  const { amount, currency = "USD" } = req.body;
  const request = new paypal.orders.OrdersCreateRequest();
  request.prefer("return=representation");
  request.requestBody({ intent: "CAPTURE", purchase_units: [{ amount: { currency_code: currency, value: amount } }] });
  try {
    const order = await client.execute(request);
    res.json({ id: order.result.id });
  } catch (err) { console.error(err); res.status(500).json({ error: "paypal_error" }); }
});
export default router;
EOF

# prisma schema
cat > apps/api/prisma/schema.prisma <<'EOF'
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql" url = env("DATABASE_URL") }
model Lead {
  id Int @id @default(autoincrement())
  nombre String
  correo String
  telefono String?
  mensaje String?
  origen String?
  createdAt DateTime @default(now())
}
model User {
  id Int @id @default(autoincrement())
  name String
  email String @unique
  password String
  role String @default("operator")
  createdAt DateTime @default(now())
}
EOF

# mailer util (python example)
cat > apps/api/src/utils/mailer.py <<'EOF'
import os, smtplib, ssl
from email.message import EmailMessage
SMTP_HOST = os.getenv("SMTP_HOST","smtp.sendgrid.net")
SMTP_PORT = int(os.getenv("SMTP_PORT",587))
SMTP_USER = os.getenv("SMTP_USER","apikey")
SMTP_PASS = os.getenv("SMTP_PASS","")
FROM_EMAIL = os.getenv("EMAIL_FROM","no-reply@globaltierra.com")
def send_email(subject,to,html_body,text_body=None):
    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = FROM_EMAIL
    msg["To"] = to
    if not text_body:
        text_body = html_body
    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")
    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls(context=ssl.create_default_context())
            server.login(SMTP_USER, SMTP_PASS)
            server.send_message(msg)
        return {"success": True}
    except Exception as e:
        return {"success": False, "error": str(e)}
EOF

# crm init script
cat > crm/init_crm.py <<'EOF'
#!/usr/bin/env python3
import os, requests
CRM_API_URL = "https://api.holstincrm.com/v1"
API_KEY = os.getenv("CRM_API_KEY","")
HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
roles = [{"name":"Administrador","permissions":["all"]},{"name":"Operador","permissions":["manage_leads","view_reservas"]},{"name":"Cliente","permissions":["view_reservas"]}]
for r in roles:
    if API_KEY:
        requests.post(f"{CRM_API_URL}/roles", headers=HEADERS, json=r)
users = [{"name":"Mauricio","email":"maurodestinodeveloper@gmail.com","role":"Administrador"},{"name":"Operador1","email":"operador@globaltierra.com","role":"Operador"}]
for u in users:
    if API_KEY:
        requests.post(f"{CRM_API_URL}/users", headers=HEADERS, json=u)
leads=[{"nombre":"Cliente Demo","correo":"cliente@demo.com","telefono":"+57 3000000000","interes":"Rafting Río Samaná"}]
for l in leads:
    if API_KEY:
        requests.post(f"{CRM_API_URL}/leads", headers=HEADERS, json=l)
print("init_crm: terminado (si CRM_API_KEY configurado).")
EOF
chmod +x crm/init_crm.py

# data example
cat > data/kpis.json <<'EOF'
{
  "reservasPorMes": [40,50,60,45,70,80,75,90,100,95,110,98],
  "meses": ["Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic","Ene","Feb"],
  "leads": {"convertidos": 34, "noConvertidos": 66},
  "mensajesMensual": [200,220,250,230,260,300,310,320,340,350,400,412]
}
EOF

# docs (manuals)
cat > docs/OPERATOR_MANUAL.md <<'EOF'
# Manual Operador - Global Tierra
(Resumen, ver archivos en repo raíz)
EOF

cat > docs/ADMIN_MANUAL.md <<'EOF'
# Manual Admin - Global Tierra
(Resumen, ver archivos en repo raíz)
EOF

cat > docs/USER_MANUAL.md <<'EOF'
# Manual Usuario - Global Tierra
(Resumen, ver archivos en repo raíz)
EOF

echo "=== Bootstrap finalizado. Archivos creados. Revisa, git add/commit y push a feature/dashboard-mockup ==="

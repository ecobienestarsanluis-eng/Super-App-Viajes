# Manual de Administración Avanzada — Global Tierra (Admin)

Versión: 1.0  
Fecha: 2026-02-14  
Contacto técnico: maurodestinodeveloper@gmail.com · WhatsApp: +57 323 915 7120

Resumen
-------
Este documento recoge prácticas, runbooks y configuraciones para administrar la plataforma Global Tierra en producción: CI/CD, hosting, base de datos, seguridad, backups, monitoreo y respuesta a incidentes. Está pensado para el administrador del sistema y el equipo de DevOps.

Índice
------
- Acceso y control de cuentas
- Repositorio y ramas
- CI/CD (GitHub Actions → Vercel / Render)
- Variables de entorno y secretos
- Despliegues y rollback
- Base de datos (Postgres): migraciones, backups y restores
- Infraestructura: Vercel, Render, Supabase, AWS (opciones)
- Monitoreo, logs y alertas
- Seguridad y cumplimiento
- Runbook de incidentes (pasos rápidos)
- Tareas de mantenimiento periódicas
- Checklist de pre-lanzamiento y post-lanzamiento
- Referencias y comandos útiles

1. Acceso y control de cuentas
--------------------------------
- Cuentas administrativas:
  - GitHub (repo): acceso por equipos. Usa SSO y MFA.
  - Vercel: invitaciones por email, habilita MFA.
  - Render / AWS: roles IAM para producción, evite cuentas root.
  - Proveedores (SendGrid, Twilio, PayPal, Stripe, Holstin): credenciales en vault/Secrets.
- Principio: mínimo privilegio (RBAC). Crea roles: admin, devops, operator.
- Auditoría: activar logs de acceso y revisar al menos mensualmente.

2. Repositorio y ramas
-----------------------
- Rama principal: `main` (deploy automático en producción).
- Ramas de features: `feature/*`.
- Ramas de release: `release/x.y`.
- Protecciones:
  - Require PR reviews (2 reviewers).
  - Tests y linter obligatorios antes de merge.
  - Firmas de commits opcional (GPG).
- Etiquetas de versión (semver): usar tags `vX.Y.Z` y releases en GitHub.

3. CI/CD (GitHub Actions → Vercel / Render)
--------------------------------------------
- Pipeline sugerido:
  1. push a `main` -> job: lint/test -> build images/artifacts
  2. deploy frontend a Vercel (via Vercel CLI o integración Vercel/GitHub)
  3. deploy backend a Render (trigger por API) o push a ECS/EKS si AWS
  4. migraciones DB seguras (ver sección migraciones)
  5. ejecutar sanity checks (healthchecks / smoke tests)
- Ejemplo: ejecutar migraciones en job separado con confirmación manual (approval) para producción.
- Secrets en GitHub: no en código. Usar GitHub Secrets y, si es posible, HashiCorp Vault o Parameter Store.

4. Variables de entorno y secretos
----------------------------------
Variables mínimas (ejemplos):
- DATABASE_URL
- PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET
- STRIPE_SECRET_KEY
- SMTP_HOST, SMTP_USER, SMTP_PASS
- TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
- VERCEL_TOKEN, RENDER_API_KEY
- CRM_API_KEY
Buenas prácticas:
- Usar namespaced keys: `PROD_...`
- Rotación periódica: cada 90 días (o según política).
- Registrar cambios y rotaciones en un log seguro.

5. Despliegues y rollback
--------------------------
Despliegue seguro:
- PR → merge a `main` gatilla CI.
- Pipeline ejecuta tests y build.
- Antes de migraciones destructivas: crear snapshot DB y marcar release.
Rollback:
- Revertir commit (git revert), push a `main` o forzar redeploy a tag/commit anterior.
- Si migración DB alteró esquema incompatible:
  1. Restaurar DB desde snapshot más reciente.
  2. Aplicar rollback de schema (si se dispone).
  3. Redeploy del código compatible.
- Mantener scripts de rollback documentados y probados en staging.

6. Base de datos (Postgres): migraciones, backups y restores
------------------------------------------------------------
Migraciones:
- Usar Prisma/Migrate o Alembic/Knex según stack.
- Workflow:
  1. Crear migración en rama feature.
  2. Ejecutar en staging.
  3. Revisar rendimiento y backups.
  4. Merge y migración en producción con snapshot previo.
Backups:
- Frecuencia: nightly full snapshot + WAL streaming (reducción RPO).
- Herramientas: pg_dump/pg_restore para export; uso de provider snapshot (RDS/Supabase).
- Retención: 30 días (ajustable).
Restores:
- Procedimiento documentado: desde snapshot S3 o RDS snapshot.
- Probar restores mensualmente en entorno de staging.
Comandos útiles:
- Dump: `pg_dump -Fc -h host -U user -d dbname -f backup-$(date +%F).dump`
- Restore: `pg_restore -c -d dbname -h host -U user backup-file.dump`

7. Infraestructura (Vercel, Render, Supabase, AWS)
--------------------------------------------------
Vercel (frontend):
- Conectar repo GitHub → deploy automático.
- Dominios: añadir `globaltierra.com`, configurar DNS con registros de Vercel y habilitar SSL.
Render (backend) / AWS (alternativa):
- Render: crear service, configurar env vars y webhook deploy.
- AWS: ECS/Fargate + RDS + ALB o EKS para mayor escala.
Supabase (BD alternativa):
- Provee Postgres gestionado + auth + storage. Buen para iteraciones rápidas.
CDN y media:
- Usar Cloudflare o Vercel Edge for assets, habilitar cache y optimizar imágenes (AVIF/WebP).

8. Monitoreo, logs y alertas
----------------------------
- Logs centralizados: use Grafana Loki / Datadog / Papertrail.
- APM: Sentry / Datadog APM para errores y traces.
- Métricas: Prometheus + Grafana o provider integrado.
- Healthchecks: endpoint `/api/health`. Configurar uptime checks y alertas.
- Alertas:
  - P99 latency > threshold
  - Error rate > X%
  - DB connection errors > N
  - Failed deploys
- Notificaciones: Slack / email / PagerDuty.

9. Seguridad y cumplimiento
----------------------------
- HTTPS obligatorio en todo el stack.
- CSP, HSTS y X-Frame-Options en respuestas HTTP.
- Escaneo de dependencias (Dependabot).
- SAST (GitHub CodeQL) en CI.
- Rate limiting: API gateway / express-rate-limit + WAF (Cloudflare/AWS WAF).
- Datos personales: encriptar PII at rest (DB column-level) y in transit (TLS).
- GDPR/local: conservar datos minimizados, ofrecer export/delete endpoints.
- Backups cifrados (KMS).

10. Runbook de incidentes (pasos rápidos)
-----------------------------------------
Incidente: API caída
1. Ver logs (Render/AWS): revisar últimas 5 min.
2. Chequear uso CPU/RAM, DB connections.
3. Si deploy reciente -> revertir a commit anterior.
4. Ejecutar `healthcheck` y notificar stakeholders.
Incidente: Pago no confirmado
1. Revisar webhooks de PayPal/Stripe en logs.
2. Verificar idempotencia y señal de webhook.
3. Reprocesar webhook desde provider (replay).
Incidente: Fugas de credenciales
1. Rotar secret comprometido (GitHub Secrets / provider).
2. Forzar re-deploy.
3. Revisar logs y bloquear accesos no autorizados.
Siempre: comunicar por Slack + abrir ticket en sistema de incidentes.

11. Tareas de mantenimiento periódicas
--------------------------------------
Diarias:
- Revisar alertas/errores críticos.
Semanales:
- Revisar deploys y tests fallidos.
Mensuales:
- Probar restore de backup en staging.
- Revisar rotación de secrets y usuarios inactivos.
Trimestrales:
- Pen testing básico y auditoría de dependencias.

12. Checklist de pre-lanzamiento y post-lanzamiento
---------------------------------------------------
Pre-lanzamiento:
- Tests (unit/integración) pass.
- Backups actuales y snapshot DB creado.
- Variables de entorno configuradas.
- CDN y dominio configurado.
- Monitor y alertas activas.
Post-lanzamiento:
- Verificar healthchecks 0/3 failures.
- Revisar logs y métricas 1–24 h.
- Confirmar emails/WhatsApp de prueba.

13. Referencias y comandos útiles
--------------------------------
- Docker compose local: `docker-compose up --build -d`
- Run migrations (Prisma): `npx prisma migrate deploy`
- Vercel deploy: `vercel --token $VERCEL_TOKEN --prod`
- Trigger Render deploy: `curl -X POST "https://api.render.com/v1/services/${RENDER_SERVICE_ID}/deploys" -H "Authorization: Bearer ${RENDER_API_KEY}" -H "Content-Type: application/json" -d '{"clearCache": true}'`

¿Deseas que suba este archivo al repositorio `ecobienestarsanluis-eng/globaltierra` en una rama `docs/admin-manual` y cree un Pull Request hacia `main`?  
Responde: "sube al repo" o "solo dame el archivo".  

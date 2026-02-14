# Super-App-Viajes
a web moderna intuitiva lo que supera las espectativas del cliente
# Global Tierra — Dashboard Mockup (Interactive)

Este mockup es un prototipo navegable del Dashboard CRM para operadores y administradores.
Incluye gráficas de KPIs (Reservas por mes, Leads convertidos, Mensajes enviados), lista de leads recientes y un historial de notificaciones.

Cómo probar localmente
1. Coloca `dashboard-mockup.html` y la carpeta `data/` (con `kpis.json`) en la misma carpeta.
2. Abre `dashboard-mockup.html` en un navegador moderno.
   - Recomendado: servir con un servidor simple para evitar problemas CORS:
     - Python 3: `python -m http.server 8000` y abrir `http://localhost:8000/dashboard-mockup.html`
3. El mockup simula actualizaciones en tiempo real (cada 8s añade un lead y una notificación).

Tecnologías usadas
- HTML + TailwindCSS (CDN)
- Chart.js (CDN)
- JS vanilla para simulación de datos (fácil de conectar a tu API)

Siguientes pasos sugeridos
- Conectar los charts a la API real (`/api/kpis`, `/api/leads`, `/api/notifications`) para mostrar datos reales.
- Convertir a React/Next.js y crear componentes reutilizables (Chart component, LeadsList, Notifications).
- Añadir autenticación y roles (Admin/Operador) en el backend.
- Integrar WebSockets (Socket.io / Pusher) para updates en tiempo real.

¿Te lo subo ya al repo `ecobienestarsanluis-eng/globaltierra` y creo una rama `feature/dashboard-mockup` con estos archivos?  
También puedo:
- Convertir este mockup a una página Next.js y añadir componentes TypeScript.
- Preparar las rutas API para servir `kpis` desde `apps/api`.
- Crear un Figma con este diseño (mockup gráfico vectorial).

Responde con la opción que prefieras: subir al repo / convertir a Next.js / crear Figma / otro.

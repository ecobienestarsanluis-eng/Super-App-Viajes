import os
import smtplib
import ssl
from email.message import EmailMessage
from jinja2 import Template
from typing import Dict, Optional

# Config desde env
SMTP_HOST = os.getenv("SMTP_HOST", "smtp.sendgrid.net")
SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
SMTP_USER = os.getenv("SMTP_USER", "apikey")  # SendGrid usa 'apikey' como user
SMTP_PASS = os.getenv("SMTP_PASS", "")
FROM_NAME = os.getenv("EMAIL_FROM_NAME", "Global Tierra")
FROM_EMAIL = os.getenv("EMAIL_FROM", "no-reply@globaltierra.com")
NOTIFY_EMAIL = os.getenv("NOTIFY_EMAIL", "maurodestinodeveloper@gmail.com")

context_ssl = ssl.create_default_context()

def render_template(template_str: str, context: Dict) -> str:
    tpl = Template(template_str)
    return tpl.render(**context)

def send_email(
    subject: str,
    to: str,
    html_body: str,
    text_body: Optional[str] = None,
    cc: Optional[str] = None
) -> Dict:
    """
    Envía un correo con HTML y text fallback.
    Retorna dict con resultado (success, error).
    """
    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = f"{FROM_NAME} <{FROM_EMAIL}>"
    msg["To"] = to
    if cc:
        msg["Cc"] = cc

    if not text_body:
        # fallback simple a partir del HTML (strip tags sería mejor con bleach/bs4)
        text_body = html_body.replace("<br>", "\n").replace("<br/>", "\n")

    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")

    try:
        # smtp STARTTLS
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=20) as server:
            server.ehlo()
            if SMTP_PORT == 587:
                server.starttls(context=context_ssl)
                server.ehlo()
            if SMTP_USER and SMTP_PASS:
                server.login(SMTP_USER, SMTP_PASS)
            server.send_message(msg)
        return {"success": True}
    except Exception as e:
        # Aquí podrías integrar reintentos o push a una cola (Redis) para reintento
        return {"success": False, "error": str(e)}

# Plantillas simples (puedes colocarlas en archivos .html y cargarlas con jinja2.FileSystemLoader)
LEAD_NOTIFICATION_HTML = """
<h2>Nuevo lead desde Global Tierra</h2>
<ul>
  <li><strong>Nombre:</strong> {{ nombre }}</li>
  <li><strong>Correo:</strong> {{ correo }}</li>
  <li><strong>Teléfono:</strong> {{ telefono }}</li>
  <li><strong>Mensaje:</strong> {{ mensaje }}</li>
  <li><strong>Origen:</strong> {{ origen }}</li>
</ul>
"""

LEAD_NOTIFICATION_TEXT = """
Nuevo lead desde Global Tierra

Nombre: {{ nombre }}
Correo: {{ correo }}
Teléfono: {{ telefono }}
Mensaje: {{ mensaje }}
Origen: {{ origen }}
"""

RESERVATION_CONFIRMATION_HTML = """
<h2>Confirmación de Reserva — {{ tour_nombre }}</h2>
<p>Hola {{ cliente_nombre }},</p>
<p>Gracias por reservar con Global Tierra. Aquí los detalles de tu reserva:</p>
<ul>
  <li><strong>Tour:</strong> {{ tour_nombre }}</li>
  <li><strong>Fecha:</strong> {{ fecha }}</li>
  <li><strong>Personas:</strong> {{ personas }}</li>
  <li><strong>Total:</strong> {{ total }}</li>
</ul>
<p>Recibirás otro correo cuando la reserva esté confirmada por el operador.</p>
<p>Saludos,<br/>Global Tierra</p>
"""

RESERVATION_CONFIRMATION_TEXT = """
Confirmación de Reserva — {{ tour_nombre }}

Hola {{ cliente_nombre }},

Gracias por reservar con Global Tierra. Aquí los detalles de tu reserva:

Tour: {{ tour_nombre }}
Fecha: {{ fecha }}
Personas: {{ personas }}
Total: {{ total }}

Recibirás otro correo cuando la reserva esté confirmada por el operador.

Saludos,
Global Tierra
"""

def send_lead_notification(lead: Dict) -> Dict:
    html = render_template(LEAD_NOTIFICATION_HTML, lead)
    text = render_template(LEAD_NOTIFICATION_TEXT, lead)
    # Notificar al email de operaciones / admin
    subject = f"Nuevo lead: {lead.get('nombre', 'Sin nombre')}"
    return send_email(subject, NOTIFY_EMAIL, html, text)

def send_reservation_confirmation(reservation: Dict) -> Dict:
    html = render_template(RESERVATION_CONFIRMATION_HTML, reservation)
    text = render_template(RESERVATION_CONFIRMATION_TEXT, reservation)
    subject = f"Reserva recibida: {reservation.get('tour_nombre')}"
    # enviar al cliente y copia a CRM/operador si aplica
    client_email = reservation.get("cliente_correo")
    cc = os.getenv("CRM_NOTIFY_EMAIL")
    return send_email(subject, client_email, html, text, cc=cc)

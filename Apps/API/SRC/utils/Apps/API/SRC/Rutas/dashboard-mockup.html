# Ejemplo de uso en una ruta Flask (o integrable en tu Express/Node via request al servicio de correo)
from flask import Blueprint, request, jsonify
from apps.api.src.utils.mailer import send_lead_notification, send_reservation_confirmation

crm_routes = Blueprint("crm_routes", __name__)

@crm_routes.route("/leads", methods=["POST"])
def create_lead():
    data = request.json
    # Aquí guardas en DB (Prisma/Postgres) - omitido por brevedad
    # Luego notificar por email
    result = send_lead_notification({
        "nombre": data.get("nombre"),
        "correo": data.get("correo"),
        "telefono": data.get("telefono"),
        "mensaje": data.get("mensaje"),
        "origen": data.get("origen", "web")
    })
    return jsonify({"ok": True, "email_result": result}), 201

@crm_routes.route("/reservas/confirm", methods=["POST"])
def confirm_reservation():
    data = request.json
    # Guardar reserva y luego enviar confirmación al cliente
    email_res = send_reservation_confirmation({
        "tour_nombre": data.get("tour_nombre"),
        "fecha": data.get("fecha"),
        "personas": data.get("personas"),
        "total": data.get("total"),
        "cliente_nombre": data.get("cliente_nombre"),
        "cliente_correo": data.get("cliente_correo")
    })
    return jsonify({"ok": True, "email_result": email_res}), 200

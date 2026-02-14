import React from "react";
import axios from "axios";

export default function Home() {
  const [leads, setLeads] = React.useState("");
  const submitLead = async () => {
    await axios.post("/api/crm/leads", {
      nombre: "Visitante",
      correo: "visitante@example.com",
      telefono: "+57 3000000000",
      mensaje: "Interesado en rafting"
    });
    alert("Lead enviado");
  };

  return (
    <main style={{ padding: 24 }}>
      <h1>Agencias Operadora Experiencias - Global Tierra</h1>
      <p>Hero ancestral-modern — buscador central (placeholder)</p>
      <button onClick={submitLead} style={{ padding: "12px 20px", borderRadius: 8 }}>
        Enviar lead de prueba
      </button>
    </main>
  );
}

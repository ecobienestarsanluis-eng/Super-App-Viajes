import Head from 'next/head';
import { useEffect, useState } from 'react';
import Chart from 'chart.js/auto';

export default function Home() {
  const [kpis, setKpis] = useState<any>(null);

  useEffect(() => {
    async function fetchData() {
      const res = await fetch('/data/kpis.json');
      const data = await res.json();
      setKpis(data);
    }
    fetchData();
  }, []);

  return (
    <>
      <Head>
        <title>Super-App-Viajes Dashboard</title>
      </Head>
      <main className="p-8">
        <h1 className="text-3xl font-bold mb-6">Dashboard CRM</h1>

        {kpis ? (
          <div className="grid grid-cols-2 gap-6">
            <div>
              <h2 className="text-xl font-semibold">Reservas por mes</h2>
              <canvas id="reservasChart"></canvas>
            </div>
            <div>
              <h2 className="text-xl font-semibold">Leads convertidos</h2>
              <canvas id="leadsChart"></canvas>
            </div>
            <div>
              <h2 className="text-xl font-semibold">Mensajes enviados</h2>
              <canvas id="mensajesChart"></canvas>
            </div>
            <div>
              <h2 className="text-xl font-semibold">$ESTRELLAS</h2>
              <canvas id="estrellasChart"></canvas>
            </div>
          </div>
        ) : (
          <p>Cargando datos...</p>
        )}
      </main>
    </>
  );
}

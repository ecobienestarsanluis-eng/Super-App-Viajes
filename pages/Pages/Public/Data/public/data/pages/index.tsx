import React, { useEffect } from 'react';
import Head from 'next/head';
import Chart from 'chart.js/auto';

export default function Home() {
  useEffect(() => {
    async function cargarKPIs() {
      try {
        const res = await fetch('/data/kpis.json');
        const data = await res.json();

        // Gráfico mensual
        const ctxMeses = document.getElementById('mesesChart') as HTMLCanvasElement;
        if (ctxMeses) {
          new Chart(ctxMeses, {
            type: 'line',
            data: {
              labels: data.meses,
              datasets: [{
                label: 'Reservas por mes',
                data: data.reservasPorMes,
                borderColor: 'blue'
              }]
            }
          });
        }

        // Gráfico semanal
        const ctxSemanas = document.getElementById('semanasChart') as HTMLCanvasElement;
        if (ctxSemanas) {
          new Chart(ctxSemanas, {
            type: 'bar',
            data: {
              labels: data.semanas,
              datasets: [{
                label: 'Reservas por semana',
                data: data.reservasPorSemana,
                backgroundColor: 'green'
              }]
            }
          });
        }

        // Gráfico diario
        const ctxDias = document.getElementById('diasChart') as HTMLCanvasElement;
        if (ctxDias) {
          new Chart(ctxDias, {
            type: 'line',
            data: {
              labels: data.dias,
              datasets: [{
                label: 'Reservas por día',
                data: data.reservasPorDia,
                borderColor: 'orange'
              }]
            }
          });
        }

        // Gráfico de $ESTRELLAS mensual
        const ctxEstrellas = document.getElementById('estrellasChart') as HTMLCanvasElement;
        if (ctxEstrellas) {
          new Chart(ctxEstrellas, {
            type: 'line',
            data: {
              labels: data.meses,
              datasets: [{
                label: '$ESTRELLAS',
                data: data.estrellas,
                borderColor: 'purple'
              }]
            }
          });
        }
      } catch (error) {
        console.error('Error cargando KPIs:', error);
      }
    }

    cargarKPIs();
  }, []);

  return (
    <>
      <Head>
        <title>Super-App-Viajes Dashboard</title>
      </Head>
      <main className="p-8">
        <h1 className="text-3xl font-bold mb-6">Dashboard CRM</h1>
        <div className="grid grid-cols-2 gap-6">
          <canvas id="mesesChart"></canvas>
          <canvas id="semanasChart"></canvas>
          <canvas id="diasChart"></canvas>
          <canvas id="estrellasChart"></canvas>
        </div>
      </main>
    </>
  );
}

import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { PrismaClient } from "@prisma/client";
import crmRoutes from "./routes/crm";
import paypalRoutes from "./routes/paypal";
import stripeRoutes from "./routes/stripe";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const prisma = new PrismaClient();
app.set("prisma", prisma);

// Rutas
app.use("/api/crm", crmRoutes);
app.use("/api/paypal", paypalRoutes);
app.use("/api/stripe", stripeRoutes);

app.get("/api/health", (req, res) => res.json({ ok: true }));

const port = Number(process.env.PORT || 4000);
app.listen(port, () => {
  console.log(`API listening on ${port}`);
});

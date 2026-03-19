🧠 Lluvia de Ideas — Escalado MQL5 Range Project

  ---
  CAPA 1 — Más Indicadores de Análisis

  Rango por sesión horaria
  - M30_Session_Range.mq5 — separa el día en sesiones (Tokio / Londres / Nueva York) y calcula el rango de
  cada una. Útil para traders de sessiones.

  Rango promedio histórico (ATR manual M30)
  - M30_ATR_Custom.mq5 — calcula el ATR propio en M30 para N períodos, sin depender del indicador ATR
  nativo. Te da control total sobre la fórmula.

  Comparador de rangos entre días
  - M30_DayComparison.mq5 — compara el rango total de hoy vs ayer vs hace 7 días. Detecta si el mercado está
   expandiendo o contrayendo volatilidad.

  Rango por hora del día
  - M30_HourlyProfile.mq5 — para cada hora del día (0h–23h), calcula el rango promedio histórico de las
  velas M30 de esa hora. Perfil de volatilidad intradiaria.

  Detector de velas outlier
  - M30_OutlierDetector.mq5 — marca las velas M30 cuyo rango supera X desviaciones estándar del promedio
  histórico. Filtro de ruido extremo.

  ---
  CAPA 2 — Scripts de Utilidad

  Exportador a CSV
  - MQL5/Scripts/ExportRangesToCSV.mq5 — exporta rangos M30 de un período completo a un archivo .csv en
  MQL5/Files/. Para análisis en Excel / Python.

  Reseteador de Comment
  - MQL5/Scripts/ClearComment.mq5 — script de un clic para limpiar todos los Comment() del gráfico. Útil en
  desarrollo.

  Validador de datos históricos
  - MQL5/Scripts/CheckDataIntegrity.mq5 — recorre un rango de fechas y detecta gaps (velas M30 faltantes).
  Imprescindible antes de cualquier backtesting.

  ---
  CAPA 3 — Expansión de la Librería

  RangeUtils.mqh — funciones adicionales
  - GetSessionRange(symbol, date, session) — rango de una sesión específica (London/NY/Asia)
  - GetStdDevRange(symbol, periods) — desviación estándar de rangos para detectar outliers
  - GetPercentileRange(symbol, periods, pct) — percentil N del rango histórico (ej. percentil 80)
  - NormalizeRange(symbol, range) — normaliza el rango entre 0–1 respecto al histórico reciente

  ---
  CAPA 4 — Expert Advisors más Sofisticados

  EA con múltiples filtros combinados
  - MultiFilter_EA.mq5 — combina filtro de rango M30 + hora del día + día de la semana. Solo opera si los 3
  filtros pasan.

  EA con gestión de riesgo dinámica
  - DynamicRisk_EA.mq5 — ajusta el LotSize automáticamente según el rango de la vela M30 (rango mayor = lote
   menor, para compensar volatilidad).

  EA de ruptura de rango
  - RangeBreakout_EA.mq5 — espera que el precio rompa el high o low de la vela M30 analizada y entra en la
  dirección de la ruptura.

  ---
  CAPA 5 — Infraestructura y Calidad

  Sistema de logging a archivo
  - MQL5/Include/Logger.mqh — librería que escribe eventos en MQL5/Files/range_log.txt con timestamp.
  Reemplaza los Print() dispersos por logs estructurados.

  Sistema de alertas
  - MQL5/Include/Alerts.mqh — centraliza Alert(), SendNotification() (push móvil) y SendMail(). Los
  indicadores/EAs llaman una sola función.

  Panel visual en el gráfico (Dashboard)
  - M30_RangeDashboard.mq5 — indicador que dibuja un panel de texto con ObjectCreate en lugar de Comment().
  No desaparece al mover el ratón, es persistente y posicionable.

  Tests de unidad para RangeUtils
  - MQL5/Scripts/TestRangeUtils.mq5 — script que llama cada función de la librería con valores conocidos y
  verifica los resultados. Detecta regresiones al modificar la librería.

  ---
  CAPA 6 — Integración y Reporting

  Reporte HTML automático
  - MQL5/Scripts/GenerateReport.mq5 — genera un archivo .html en MQL5/Files/ con tabla de rangos por fecha,
  coloreados por categoría (verde=BAJO, amarillo=MEDIO, rojo=ALTO). Se abre directamente en el navegador.

  Integración con Telegram
  - MQL5/Include/TelegramNotifier.mqh — envía mensajes vía WebRequest() al API de Telegram cuando el EA
  detecta una señal válida. Alertas en tiempo real al móvil.

  ---
  RESUMEN — Prioridades sugeridas

  ┌──────────────┬──────────────────────────────────────┬───────────────────────────────────────────────┐
  │  Prioridad   │          Qué hacer primero           │                    Por qué                    │
  ├──────────────┼──────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 🔴 Alta      │ Logger.mqh + Alerts.mqh              │ Infraestructura base que beneficia todos los  │
  │              │                                      │ archivos existentes                           │
  ├──────────────┼──────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 🔴 Alta      │ ExportRangesToCSV.mq5                │ Permite validar los datos fuera de MT5        │
  ├──────────────┼──────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 🟡 Media     │ M30_HourlyProfile.mq5 +              │ Análisis accionable de mercado real           │
  │              │ M30_Session_Range.mq5                │                                               │
  ├──────────────┼──────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 🟡 Media     │ RangeBreakout_EA.mq5                 │ EA con lógica de trading concreta, no solo    │
  │              │                                      │ filtro                                        │
  ├──────────────┼──────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 🟢 Largo     │ Dashboard visual + Reporte HTML      │ Presentación y UX                             │
  │ plazo        │                                      │                                               │
  ├──────────────┼──────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 🟢 Largo     │ TestRangeUtils.mq5                   │ Madurez del proyecto como software            │
  │ plazo        │                                      │ profesional                                   │
  └──────────────┴──────────────────────────────────────┴───────────────────────────────────────────────┘

  ---
  ¿Por dónde quieres empezar? ¿Infraestructura (Logger + Alerts), más análisis (sesiones, perfil horario),
  el EA de ruptura, o el exportador CSV?

//+------------------------------------------------------------------+
//|                                          M30_Range_Heatmap.mq5   |
//|              Indicador: Análisis estadístico de rangos M30        |
//|              para un bloque completo de fechas (inicio → fin)     |
//|              Clasifica velas como BAJO / MEDIO / ALTO             |
//|              Depende de: Include/RangeUtils.mqh                   |
//+------------------------------------------------------------------+
#property copyright   "MK Claude Projects"
#property version     "1.00"
#property description "Estadísticas de volatilidad M30: clasifica rangos BAJO/MEDIO/ALTO en un rango de fechas"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <RangeUtils.mqh>

//--- Rango de fechas a analizar
input datetime FechaInicio  = D'2023.01.01 00:00';
input datetime FechaFin     = D'2023.01.07 00:00';
//--- Umbrales de clasificación de volatilidad (en puntos)
input int      UmbralBajo   = 50;    // Velas con rango menor a este valor → BAJO
input int      UmbralAlto   = 150;   // Velas con rango mayor a este valor → ALTO

//+------------------------------------------------------------------+
//| Inicialización del indicador — toda la lógica reside aquí        |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validar que la fecha de inicio no sea futura
   if(IsDateFuture(FechaInicio))
   {
      Comment("ERROR: La fecha de inicio es futura. Introduce un rango de fechas pasado.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Validar que el rango de fechas sea coherente
   if(FechaInicio >= FechaFin)
   {
      Comment("ERROR: FechaInicio debe ser anterior a FechaFin.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Validar coherencia de los umbrales de clasificación
   if(UmbralBajo <= 0 || UmbralAlto <= 0 || UmbralBajo >= UmbralAlto)
   {
      Comment("ERROR: Umbrales inválidos. Asegúrate: 0 < UmbralBajo < UmbralAlto.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Ajustar FechaFin si supera la hora actual del servidor (no es un error)
   datetime finEfectivo     = FechaFin;
   bool     fechaFinAjustada = false;
   if(FechaFin > TimeCurrent())
   {
      finEfectivo      = TimeCurrent();
      fechaFinAjustada = true;
   }

   // Obtener todas las velas M30 del rango usando el overload de fechas (inicio → fin)
   MqlRates velas[];
   int copiadas = CopyRates(_Symbol, PERIOD_M30, FechaInicio, finEfectivo, velas);

   if(copiadas <= 0)
   {
      Comment("ERROR: No hay datos M30 para el rango de fechas seleccionado.");
      return(INIT_FAILED);
   }

   // Clasificar cada vela y acumular estadísticas de volatilidad
   int contBajo  = 0;
   int contMedio = 0;
   int contAlto  = 0;
   int rangos[];
   ArrayResize(rangos, copiadas);

   double punto = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   for(int i = 0; i < copiadas; i++)
   {
      rangos[i] = (int)MathRound((velas[i].high - velas[i].low) / punto);
      string categoria = GetRangeCategory(rangos[i], UmbralBajo, UmbralAlto);

      if(categoria == "BAJO")       contBajo++;
      else if(categoria == "MEDIO") contMedio++;
      else                          contAlto++;
   }

   // Calcular el rango promedio de todas las velas analizadas
   double promedio = CalcAverageRange(rangos, copiadas);

   // Nota de ajuste si la fecha fin fue recortada al tiempo actual
   string avisoAjuste = fechaFinAjustada
      ? "\n* FechaFin ajustada a hora actual del servidor"
      : "";

   // Construir el comentario con el resumen estadístico completo
   string comentario =
      "--- Heatmap M30 Rangos ---\n" +
      "Período:  " + TimeToString(FechaInicio,   TIME_DATE) +
      " → "        + TimeToString(finEfectivo,    TIME_DATE) + "\n" +
      "Velas:    " + IntegerToString(copiadas) + " analizadas\n" +
      "BAJO   (< "  + IntegerToString(UmbralBajo) + " pts):  " + IntegerToString(contBajo)  + "\n" +
      "MEDIO  ("    + IntegerToString(UmbralBajo) + "-" + IntegerToString(UmbralAlto) + " pts): " + IntegerToString(contMedio) + "\n" +
      "ALTO   (> "  + IntegerToString(UmbralAlto) + " pts):  " + IntegerToString(contAlto)  + "\n" +
      "Promedio: "  + DoubleToString(promedio, 1) + " pts" +
      avisoAjuste;

   Comment(comentario);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Función de cálculo del indicador (sin lógica pesada)            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Sin procesamiento: toda la lógica está en OnInit()
   return(rates_total);
}
//+------------------------------------------------------------------+

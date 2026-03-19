//+------------------------------------------------------------------+
//|                              M30_MultiDate_Range_Finder.mq5       |
//|              Indicador: Muestra el rango de hasta 5 velas M30    |
//|              simultáneamente, una por cada fecha seleccionada     |
//|              Depende de: Include/RangeUtils.mqh                   |
//+------------------------------------------------------------------+
#property copyright   "MK Claude Projects"
#property version     "1.00"
#property description "Muestra el rango M30 de hasta 5 fechas distintas en un solo Comment"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <RangeUtils.mqh>

//--- Fechas objetivo (hasta 5 velas M30 simultáneas)
input datetime Fecha1 = D'2023.01.02 09:00';
input datetime Fecha2 = D'2023.01.03 09:00';
input datetime Fecha3 = D'2023.01.04 09:00';
input datetime Fecha4 = D'2023.01.05 09:00';
input datetime Fecha5 = D'2023.01.06 09:00';

//+------------------------------------------------------------------+
//| Inicialización del indicador — toda la lógica reside aquí        |
//+------------------------------------------------------------------+
int OnInit()
{
   // Agrupar las fechas en un arreglo para iterar de forma uniforme
   datetime fechas[5];
   fechas[0] = Fecha1;
   fechas[1] = Fecha2;
   fechas[2] = Fecha3;
   fechas[3] = Fecha4;
   fechas[4] = Fecha5;

   string comentario       = "--- MultiDate M30 Rangos ---\n";
   int    validasProcesadas = 0;

   for(int i = 0; i < 5; i++)
   {
      // Omitir fechas futuras con una nota en el comentario
      if(IsDateFuture(fechas[i]))
      {
         comentario += "Fecha " + IntegerToString(i + 1) + ": [FUTURA - omitida]\n";
         continue;
      }

      // Obtener la vela M30 correspondiente a esta fecha
      MqlRates vela;
      int rango = GetCandleRange(_Symbol, PERIOD_M30, fechas[i], vela);

      if(rango < 0)
      {
         // Sin datos M30 disponibles para esta fecha específica
         comentario += "Fecha " + IntegerToString(i + 1) + ": [Sin datos M30]\n";
         continue;
      }

      // Añadir la línea formateada al comentario acumulado
      comentario += FormatRangeComment(fechas[i], rango, "M30") + "\n";
      validasProcesadas++;
   }

   // Si ninguna fecha produjo datos válidos, reportar error crítico
   if(validasProcesadas == 0)
   {
      Comment("ERROR: Ninguna de las fechas seleccionadas tiene datos M30 válidos.");
      return(INIT_FAILED);
   }

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

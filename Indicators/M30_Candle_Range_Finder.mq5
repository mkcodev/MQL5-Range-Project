//+------------------------------------------------------------------+
//|                                      M30_Candle_Range_Finder.mq5 |
//|              Indicador: Rango de vela M30 para una fecha dada     |
//|              Toda la lógica reside en OnInit()                    |
//+------------------------------------------------------------------+
#property copyright   "MK Claude Projects"
#property version     "1.00"
#property description "Muestra el rango en puntos de la vela M30 de la fecha seleccionada"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Parámetro de entrada: fecha objetivo
input datetime TargetDate = D'2023.01.01 00:00';

//+------------------------------------------------------------------+
//| Función de inicialización del indicador                          |
//+------------------------------------------------------------------+
int OnInit()
{
   // a) Validación: la fecha no debe ser futura
   if(TargetDate >= TimeCurrent())
   {
      Comment("ERROR: La fecha introducida es futura. Introduce una fecha pasada.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // b) Obtener datos de la vela M30 en la fecha objetivo
   MqlRates rates[];
   int copiadas = CopyRates(_Symbol, PERIOD_M30, TargetDate, 1, rates);

   // c) Manejo de error si CopyRates no devuelve datos
   if(copiadas <= 0)
   {
      Comment("ERROR: No hay datos M30 para la fecha seleccionada.");
      return(INIT_FAILED);
   }

   // d) Calcular el rango de la vela en puntos
   int rango = (int)MathRound((rates[0].high - rates[0].low) / _Point);

   // e) Mostrar el resultado formateado en el gráfico
   Comment(
      "Vela M30 [" + TimeToString(TargetDate, TIME_DATE | TIME_MINUTES) +
      "] - Rango: " + IntegerToString(rango) + " Puntos"
   );

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

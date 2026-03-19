//+------------------------------------------------------------------+
//|                                                    RangeUtils.mqh |
//|              Librería compartida de utilidades de rango M30       |
//|              Usada por indicadores y EAs del proyecto MK          |
//+------------------------------------------------------------------+
#ifndef RANGE_UTILS_MQH
#define RANGE_UTILS_MQH

//+------------------------------------------------------------------+
//| Verifica si una fecha es futura respecto al servidor              |
//+------------------------------------------------------------------+
bool IsDateFuture(const datetime fecha)
{
   return(fecha >= TimeCurrent());
}

//+------------------------------------------------------------------+
//| Obtiene el rango en puntos de una vela en la fecha dada          |
//| Rellena outVela con los datos OHLC de la vela encontrada         |
//| Devuelve -1 si no hay datos disponibles                          |
//+------------------------------------------------------------------+
int GetCandleRange(
   const string          simbolo,
   const ENUM_TIMEFRAMES temporalidad,
   const datetime        fechaObjetivo,
   MqlRates              &outVela
)
{
   MqlRates velas[];
   int copiadas = CopyRates(simbolo, temporalidad, fechaObjetivo, 1, velas);

   // Sin datos: limpiar la estructura de salida y devolver error
   if(copiadas <= 0)
   {
      ZeroMemory(outVela);
      return(-1);
   }

   outVela = velas[0];

   // Usar SYMBOL_POINT del símbolo para compatibilidad multi-símbolo
   double punto = SymbolInfoDouble(simbolo, SYMBOL_POINT);
   if(punto <= 0.0) return(-1);

   return((int)MathRound((velas[0].high - velas[0].low) / punto));
}

//+------------------------------------------------------------------+
//| Formatea un string de presentación para un rango de vela         |
//| etiqueta: prefijo visual, p.ej. "M30" o "H1"                    |
//+------------------------------------------------------------------+
string FormatRangeComment(
   const datetime fechaObjetivo,
   const int      rangoEnPuntos,
   const string   etiqueta
)
{
   return(
      etiqueta + " [" +
      TimeToString(fechaObjetivo, TIME_DATE | TIME_MINUTES) +
      "] Rango: " + IntegerToString(rangoEnPuntos) + " pts"
   );
}

//+------------------------------------------------------------------+
//| Clasifica un rango como BAJO, MEDIO o ALTO                       |
//| Los umbrales son configurables por el llamador (agnóstico)        |
//+------------------------------------------------------------------+
string GetRangeCategory(
   const int rangoEnPuntos,
   const int umbralBajo,
   const int umbralAlto
)
{
   if(rangoEnPuntos < umbralBajo)  return("BAJO");
   if(rangoEnPuntos <= umbralAlto) return("MEDIO");
   return("ALTO");
}

//+------------------------------------------------------------------+
//| Calcula el rango promedio de un arreglo de rangos enteros        |
//| Devuelve 0.0 si la cantidad es inválida                          |
//+------------------------------------------------------------------+
double CalcAverageRange(const int &rangos[], const int cantidad)
{
   if(cantidad <= 0 || ArraySize(rangos) < cantidad) return(0.0);
   double suma = 0.0;
   for(int i = 0; i < cantidad; i++)
      suma += rangos[i];
   return(suma / cantidad);
}

#endif // RANGE_UTILS_MQH

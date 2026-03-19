//+------------------------------------------------------------------+
//|                                              RangeFilter_EA.mq5  |
//|              Expert Advisor: Filtra entradas de mercado según     |
//|              el rango de la última vela M30 completada            |
//|              Sólo opera cuando el rango está dentro de la banda   |
//|              configurada (evita velas explosivas o muertas)       |
//|              Depende de: Include/RangeUtils.mqh                   |
//+------------------------------------------------------------------+
#property copyright   "MK Claude Projects"
#property version     "1.00"
#property description "EA con filtro de volatilidad M30: opera solo si el rango está en la banda configurada"

#include <RangeUtils.mqh>

//--- Parámetros del filtro de rango
input int    RangoMinPuntos   = 30;       // Rango mínimo para operar (puntos)
input int    RangoMaxPuntos   = 120;      // Rango máximo para operar (puntos)
//--- Parámetros de la operación
input double LotSize          = 0.10;     // Tamaño del lote
input int    StopLossPuntos   = 100;      // Stop Loss en puntos
input int    TakeProfitPuntos = 200;      // Take Profit en puntos
input int    NumeroMagico     = 20260319; // Identificador único de este EA

//--- Variable global: controla que la lógica se ejecute una sola vez por vela M30
datetime g_ultimaVelaM30 = 0;

//+------------------------------------------------------------------+
//| Inicialización del Expert Advisor                                 |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validar coherencia del filtro de rango
   if(RangoMinPuntos <= 0 || RangoMaxPuntos <= 0 || RangoMinPuntos >= RangoMaxPuntos)
   {
      Print("ERROR: RangoMinPuntos debe ser > 0 y menor que RangoMaxPuntos.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Validar parámetros de gestión de la operación
   if(LotSize <= 0.0 || StopLossPuntos <= 0 || TakeProfitPuntos <= 0)
   {
      Print("ERROR: LotSize, StopLossPuntos y TakeProfitPuntos deben ser mayores que cero.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   Print(
      "RangeFilter EA inicializado | Filtro: ", RangoMinPuntos, "-", RangoMaxPuntos,
      " pts | Lote: ", DoubleToString(LotSize, 2),
      " | SL: ", StopLossPuntos, " pts | TP: ", TakeProfitPuntos, " pts"
   );

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Desinicialización del Expert Advisor                              |
//+------------------------------------------------------------------+
void OnDeinit(const int razon)
{
   Print("RangeFilter EA desactivado. Código de razón: ", razon);
   Comment(""); // Limpiar cualquier comentario residual en el gráfico
}

//+------------------------------------------------------------------+
//| Tick del Expert Advisor — lógica principal de filtrado y entrada  |
//+------------------------------------------------------------------+
void OnTick()
{
   // Obtener la última vela M30 completada (posición 1 = vela anterior a la actual)
   MqlRates ultimaVela[];
   if(CopyRates(_Symbol, PERIOD_M30, 1, 1, ultimaVela) != 1) return;

   // Protección de barra: ejecutar lógica sólo una vez por nueva vela M30
   if(ultimaVela[0].time == g_ultimaVelaM30) return;
   g_ultimaVelaM30 = ultimaVela[0].time;

   // Calcular el rango de la última vela M30 completada (datos ya disponibles en memoria)
   int rangoPuntos = (int)MathRound((ultimaVela[0].high - ultimaVela[0].low) / _Point);

   // Aplicar el filtro de volatilidad: sólo operar dentro de la banda configurada
   if(rangoPuntos < RangoMinPuntos || rangoPuntos > RangoMaxPuntos)
   {
      string categoria = GetRangeCategory(rangoPuntos, RangoMinPuntos, RangoMaxPuntos);
      Print(
         "Filtro M30: Rango=", rangoPuntos,
         " pts [", categoria, "] — Fuera del filtro. Sin operación."
      );
      return;
   }

   // Verificar si ya existe una posición abierta de este EA en el símbolo actual
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == _Symbol &&
         (long)PositionGetInteger(POSITION_MAGIC) == (long)NumeroMagico)
      {
         // Posición activa encontrada: no apilar órdenes
         return;
      }
   }

   // Determinar dirección según el sesgo de la vela M30 (alcista = compra, bajista = venta)
   bool esBullish       = (ultimaVela[0].close > ultimaVela[0].open);
   ENUM_ORDER_TYPE tipo = esBullish ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;

   // Calcular niveles de precio de entrada, Stop Loss y Take Profit
   double precioEntrada = esBullish
      ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double stopLoss = esBullish
      ? precioEntrada - StopLossPuntos   * _Point
      : precioEntrada + StopLossPuntos   * _Point;
   double takeProfit = esBullish
      ? precioEntrada + TakeProfitPuntos * _Point
      : precioEntrada - TakeProfitPuntos * _Point;

   // Detectar automáticamente el modo de relleno soportado por el símbolo/broker
   int                    modoRelleno  = (int)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   ENUM_ORDER_TYPE_FILLING tipoRelleno;
   if((modoRelleno & SYMBOL_FILLING_FOK) != 0)
      tipoRelleno = ORDER_FILLING_FOK;
   else if((modoRelleno & SYMBOL_FILLING_IOC) != 0)
      tipoRelleno = ORDER_FILLING_IOC;
   else
      tipoRelleno = ORDER_FILLING_RETURN;

   // Construir la solicitud de orden al mercado
   MqlTradeRequest solicitud = {};
   MqlTradeResult  resultado = {};

   solicitud.action       = TRADE_ACTION_DEAL;
   solicitud.symbol       = _Symbol;
   solicitud.volume       = LotSize;
   solicitud.type         = tipo;
   solicitud.price        = precioEntrada;
   solicitud.sl           = stopLoss;
   solicitud.tp           = takeProfit;
   solicitud.magic        = NumeroMagico;
   solicitud.comment      = "RangeFilter | Rango=" + IntegerToString(rangoPuntos) + "pts";
   solicitud.type_filling = tipoRelleno;

   // Enviar la orden y verificar el resultado
   if(!OrderSend(solicitud, resultado))
   {
      Print(
         "ERROR OrderSend: código=", GetLastError(),
         " retcode=", resultado.retcode
      );
   }
   else
   {
      Print(
         "Orden enviada OK | ", (esBullish ? "COMPRA" : "VENTA"),
         " | Rango filtrado: ", rangoPuntos, " pts",
         " | Ticket: ", resultado.order
      );
   }
}
//+------------------------------------------------------------------+

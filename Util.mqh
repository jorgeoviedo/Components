//##########################################################################################################
//# Util                                                                                                   #
//##########################################################################################################
int  getEventTimer(ENUM_TIMEFRAMES period)
{    switch(period)
     {  case PERIOD_M1:  return(            01*60);
        case PERIOD_M2:  return(            02*60);
        case PERIOD_M3:  return(            03*60);
        case PERIOD_M4:  return(            04*60);
        case PERIOD_M5:  return(            05*60);
        case PERIOD_M6:  return(            06*60);
        case PERIOD_M10: return(            10*60);
        case PERIOD_M12: return(            12*60);
        case PERIOD_M15: return(            15*60);
        case PERIOD_M20: return(            20*60);
        case PERIOD_M30: return(            30*60);
        case PERIOD_H1:  return(         01*60*60);
        case PERIOD_H2:  return(         02*60*60);
        case PERIOD_H3:  return(         03*60*60);
        case PERIOD_H4:  return(         04*60*60);
        case PERIOD_H6:  return(         06*60*60);
        case PERIOD_H8:  return(         08*60*60);
        case PERIOD_H12: return(         12*60*60);
        case PERIOD_D1:  return(      01*60*60*60);
        case PERIOD_W1:  return(   01*60*60*60*60);
        case PERIOD_MN1: return(01*60*60*60*60*60);
     }  
     return(0);
}

string getInfoOnTick()
{    return  "ASK: "    + DoubleToString (SymbolInfoDouble (Symbol(),SYMBOL_ASK   ),6) + "\n" +
             "BID: "    + DoubleToString (SymbolInfoDouble (Symbol(),SYMBOL_BID   ),6) + "\n" +
             "SPREAD: " + IntegerToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD));
}
//##########################################################################################################
//# End Util                                                                                               #
//##########################################################################################################
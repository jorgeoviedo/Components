int handleFile;
int objIndName = 0;
double lastAccProfit = 0;
static long   MAGIC     = 123456;
static ulong  DEVIATION = 15;
static double PIP_LOSS  = 100; //Pips / 10 in EUR USD
static double VOLUME    = 0.2;
static double DELTA     = 50;

void orderCheckForOpen(ENUM_ORDER_TYPE type, MqlTradeRequest &req, MqlTradeResult  &res)
{    if(PositionsTotal()==0)
     {  orderOpen(type, req, res);
     }
     else
     {  if(!(req.type == type))
        {  orderDelete(req, res);
        }
     }
}

void orderOpen(ENUM_ORDER_TYPE type, MqlTradeRequest &req, MqlTradeResult  &res)
{    ZeroMemory(req);
     ZeroMemory(res);
     lastAccProfit  = 0;
     req.type       = type;
     req.magic      = MAGIC;
     req.volume     = VOLUME;
     req.symbol     = _Symbol;
     req.action     = TRADE_ACTION_DEAL;
     req.comment    = "OPEN ";
     req.deviation  = DEVIATION;
     switch(req.type)
     {   case ORDER_TYPE_BUY:  
              req.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
              req.sl    = req.price - (_Point * PIP_LOSS);
              break;
         case ORDER_TYPE_SELL: 
              req.price = SymbolInfoDouble(_Symbol, SYMBOL_BID); 
              req.sl    = req.price + (_Point * PIP_LOSS); 
              break;
     }
     orderExecute(req, res);
     orderWriteLog(req, res);
     orderPaitnt(req);
}  

void orderDelete(MqlTradeRequest &req, MqlTradeResult  &res)
{    req.type    = (req.type == ORDER_TYPE_SELL)? ORDER_TYPE_BUY: ORDER_TYPE_SELL;
     req.action  = TRADE_ACTION_DEAL;
     req.comment = "CLOSE ";
     req.sl=0;
     req.tp=0;
     orderExecute(req, res);
     orderWriteLog(req, res);
     orderPaitnt(req);        
}  

void orderModifySLTP(MqlTradeRequest &req, MqlTradeResult  &res)
{    req.tp = 0;
     switch(req.type)
     {   case ORDER_TYPE_BUY:  
              req.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (_Point * (PIP_LOSS + DELTA));
              break;
         case ORDER_TYPE_SELL: 
              req.sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (_Point * (PIP_LOSS + DELTA));
              break;
     }
     req.action  = TRADE_ACTION_SLTP;
     req.comment = "Modify SL ";
     orderExecute(req, res);
}  
   
void orderExecute(MqlTradeRequest &req, MqlTradeResult &res)
{    ResetLastError();
     if(OrderSend(req, res)==true)
     {       if (req.action == TRADE_ACTION_SLTP) PlaySound("news.wav");
        else if (req.type   == ORDER_TYPE_BUY   ) PlaySound("connect.wav");
        else if (req.type   == ORDER_TYPE_SELL  ) PlaySound("ok.wav");
     }
     else
     {  Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

void orderCheckModSLTP(MqlTradeRequest &req, MqlTradeResult &res)
{    if((PositionsTotal() > 0) &&
        (AccountInfoDouble(ACCOUNT_PROFIT) > 0) &&
        (AccountInfoDouble(ACCOUNT_PROFIT) > lastAccProfit))
     {  orderModifySLTP(req, res);
        if(GetLastError()==0)
        {  lastAccProfit = AccountInfoDouble(ACCOUNT_PROFIT);
        }
     }
}

void orderGetInfoOnTick()
{    Comment(StringFormat("ASK=%.6f  \nBID=%.6f  \nSPREAD=%G  \nPATRIMONIO=%G  \nBENEFICIO=%G  \nLAST PROFIT:%G", 
     SymbolInfoDouble( Symbol(),SYMBOL_ASK), 
     SymbolInfoDouble( Symbol(),SYMBOL_BID), 
     SymbolInfoInteger(Symbol(),SYMBOL_SPREAD),
     AccountInfoDouble(ACCOUNT_EQUITY),
     AccountInfoDouble(ACCOUNT_PROFIT),
     lastAccProfit));
}

int  orderGetEventTimer(ENUM_TIMEFRAMES period)
{    switch(period)
     {  case PERIOD_M1:  return(   01*60);
        case PERIOD_M2:  return(   02*60);
        case PERIOD_M3:  return(   03*60);
        case PERIOD_M4:  return(   04*60);
        case PERIOD_M5:  return(   05*60);
        case PERIOD_M6:  return(   06*60);
        case PERIOD_M10: return(   10*60);
        case PERIOD_M12: return(   12*60);
        case PERIOD_M15: return(   15*60);
        case PERIOD_M20: return(   20*60);
        case PERIOD_M30: return(   30*60);
        case PERIOD_H1:  return(01*60*60);
        case PERIOD_H2:  return(02*60*60);
        case PERIOD_H3:  return(03*60*60);
        case PERIOD_H4:  return(04*60*60);
        case PERIOD_H6:  return(06*60*60);
        case PERIOD_H8:  return(08*60*60);
        case PERIOD_H12: return(12*60*60);
     }  
     return(0);
}

void orderInstanceLog()
{    if(handleFile == 0)
     {  if(FileIsExist("log.txt"))
        {  FileDelete("log.txt");
        }   
        ResetLastError();
        handleFile = FileOpen("log.txt", FILE_WRITE|FILE_TXT);
        if(handleFile == INVALID_HANDLE)
        {  Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
        }
     }   
}

void orderWriteLog(MqlTradeRequest &req, MqlTradeResult &res)
{    FileWrite(handleFile, 
     "===================================================="+"\r\n"
     "              ", req.comment                         +"\r\n"
     "===================================================="+"\r\n"
     "TimeCurrent:  ", TimeToString(TimeCurrent())         +"\r\n"
     "Symbol:       ",                   req.symbol        +"\r\n"
     "Magic Number: ", StringFormat("%d",req.magic)        +"\r\n"
     "Type:         ",      EnumToString(req.type)         +"\r\n"
     "Expiration:   ",      TimeToString(req.expiration)   +"\r\n"
     "Price:        ", StringFormat("%G",req.price)        +"\r\n"
     "Deviation:    ", StringFormat("%G",req.deviation)    +"\r\n"
     "Stop Loss:    ", StringFormat("%G",req.sl)           +"\r\n"
     "Take Profit:  ", StringFormat("%G",req.tp)           +"\r\n"
     "Stop Limit:   ", StringFormat("%G",req.stoplimit)    +"\r\n"
     "Volume:       ", StringFormat("%G",req.volume)       +"\r\n"
     "Request ID:   ", StringFormat("%d",res.request_id)   +"\r\n"
     "Order ticket: ",           (string)res.order         +"\r\n"
     "Deal ticket:  ",           (string)res.deal          +"\r\n"
     "Ask:          ", StringFormat("%G",res.ask)          +"\r\n"
     "Bid:          ", StringFormat("%G",res.bid)          +"\r\n"
     "GetLastError: ", _LastError                           );
}

void orderPaitnt(MqlTradeRequest &req)
{    if(req.comment == "OPEN ")
     {  orderPaintType(OBJ_TREND, req);
        orderPaintType(OBJ_ARROW_LEFT_PRICE, req);
     } 
     if(req.comment == "CLOSE ")
     {  objIndName = objIndName - 4;
        orderPaintType(OBJ_TREND, req);
        objIndName = objIndName + 4;
        orderPaintType(OBJ_ARROW_RIGHT_PRICE, req);
        
     }
     orderPaintType(OBJ_VLINE, req);
     orderPaintText(req);
     ChartRedraw(0);
}

void orderPaintType(ENUM_OBJECT type, MqlTradeRequest &req)
{    objIndName++;
     ObjectCreate    (0, IntegerToString(objIndName), type, 0, TimeCurrent(), req.price);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_COLOR, clrYellow);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_STYLE, STYLE_SOLID);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_WIDTH, 1);
}

void orderPaintText(MqlTradeRequest &req)
{    objIndName++;
     ObjectCreate    (0, IntegerToString(objIndName), OBJ_TEXT, 0, TimeCurrent(), req.price);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_COLOR, clrYellow);
     ObjectSetString (0, IntegerToString(objIndName), OBJPROP_TEXT, req.comment + EnumToString(req.type));
     ObjectSetString (0, IntegerToString(objIndName), OBJPROP_FONT, "Arial");
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_FONTSIZE, 6);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_ANCHOR, ANCHOR_LOWER);
     ObjectSetDouble (0, IntegerToString(objIndName), OBJPROP_ANGLE, 90);
}
int handleFile;
static long   MAGIC     = 123456;
static ulong  DEVIATION = 15;
static double PIP_LOSS  = 70; //Pips / 10 in EUR USD
static double PIP_TAKE  = 70; //Pips / 10 in EUS USD
static double VOLUME    = 0.2;

void stepForOpenOrder(ENUM_ORDER_TYPE type, MqlTradeRequest &req, MqlTradeResult &res)
{    setOrderOpen(type, req, res);
     setOrderPriceSLTP(req);
     executeOrder(req, res);
}

void stepForDeleteOrder(MqlTradeRequest &req, MqlTradeResult &res)
{    setOrderDelete(req);
     setOrderPriceSLTP(req);
     executeOrder(req, res);
}

void setOrderOpen(ENUM_ORDER_TYPE type, MqlTradeRequest &req, MqlTradeResult  &res)
{    ZeroMemory(req);
     ZeroMemory(res);
     req.type       = type;
     req.magic      = MAGIC;
     req.volume     = VOLUME;
     req.symbol     = _Symbol;
     req.action     = TRADE_ACTION_DEAL;
     req.comment    = "OPEN ";
     req.deviation  = DEVIATION;
}  

void setOrderDelete(MqlTradeRequest &req)
{    req.type    = (req.type == ORDER_TYPE_SELL)? ORDER_TYPE_BUY: ORDER_TYPE_SELL;
     req.action  = TRADE_ACTION_DEAL;
     req.comment = "CLOSE ";
}  

void setOrderPriceSLTP(MqlTradeRequest &req)
{    switch(req.type)
     {   case ORDER_TYPE_BUY:
              req.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
              req.sl    = req.price - (_Point * PIP_LOSS);
              req.tp    = req.price + (_Point * PIP_TAKE); break;
         case ORDER_TYPE_SELL:
              req.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
              req.tp    = req.price - (_Point * PIP_TAKE);
              req.sl    = req.price + (_Point * PIP_LOSS); break;
     }
}

void setOrderModifySLTP(MqlTradeRequest &req)
{    req.action  = TRADE_ACTION_SLTP;
     req.comment = "Modify SL-TP ";
}  
   
void executeOrder(MqlTradeRequest &req, MqlTradeResult  &res)
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

int  getEventTimer(ENUM_TIMEFRAMES period)
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

void instanceLogOrder()
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

void writeLogOrder(MqlTradeRequest &req, MqlTradeResult &res)
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
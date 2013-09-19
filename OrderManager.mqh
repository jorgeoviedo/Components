int handleFile;
int objIndName = 0;
double lastAccProfit = 0;
static double VOLUME = 0.2;
static long MAGIC = 123456;
static ulong DEVIATION = 15;
static double PIP_LOSS = 15;
static int OBJECT_POSITION = 4;
#define SY_ASK SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define SY_BID SymbolInfoDouble(_Symbol, SYMBOL_BID)
#define SL_ASK SY_ASK - (_Point * PIP_LOSS)
#define SL_BID SY_BID + (_Point * PIP_LOSS)

void orderOpen(ENUM_ORDER_TYPE type, MqlTradeRequest &req, MqlTradeResult &res) {
     ZeroMemory(req);
     ZeroMemory(res);
     req.type = type;
     lastAccProfit = 0;
     req.magic = MAGIC;
     req.volume = VOLUME;
     req.symbol = _Symbol;
     req.comment = "OPEN ";
     req.deviation = DEVIATION;
     req.action = TRADE_ACTION_DEAL;
     req.price = (req.type == ORDER_TYPE_BUY)? SY_ASK: SY_BID;
     req.sl = (req.type == ORDER_TYPE_BUY)? SL_ASK: SL_BID;
     orderExecute(req, res);
}

void orderDelete(MqlTradeRequest &req, MqlTradeResult &res) {
     req.sl=0;
     req.tp=0;
     req.comment = "CLOSE ";
     req.action = TRADE_ACTION_DEAL;
     req.price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
     req.type = (req.type == ORDER_TYPE_SELL)? ORDER_TYPE_BUY: ORDER_TYPE_SELL;
     orderExecute(req, res);
}

void orderModifySLTP(MqlTradeRequest &req, MqlTradeResult &res) {
     req.tp = 0;
     req.comment = "Modify SL ";
     req.action = TRADE_ACTION_SLTP;
     req.sl = (req.type == ORDER_TYPE_BUY)? SL_ASK: SL_BID;
     orderExecute(req, res);
}

void orderExecute(MqlTradeRequest &req, MqlTradeResult &res) {
     ResetLastError();
     if (OrderSend(req, res) == true) {
         if (req.action == TRADE_ACTION_SLTP) {
             PlaySound("news.wav");
         }
         else if (req.type == ORDER_TYPE_BUY) {
             PlaySound("connect.wav");
         }
         else if (req.type == ORDER_TYPE_SELL) {
             PlaySound("ok.wav");
         }
     }
     else {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

void orderCheckModSLTP(MqlTradeRequest &req, MqlTradeResult &res) {
     double accountProfit = AccountInfoDouble(ACCOUNT_PROFIT);
     if ((accountProfit > 0) && (accountProfit > lastAccProfit) && (PositionsTotal() > 0)) {
          orderModifySLTP(req, res);
          if (GetLastError() == 0) {
              lastAccProfit = accountProfit;
          }
     }
}

void orderGetInfoOnTick() {
     Comment(StringFormat("ASK=%.6f \nBID=%.6f \nLAST PROFIT=%G \nSPREAD=%G \nPATRIMONIO=%G \nBENEFICIO=%G",
     SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_BID), lastAccProfit,
     SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_PROFIT)));
}

int orderGetEventTimer(ENUM_TIMEFRAMES period) {
     switch(period) {
        case PERIOD_M1:  return(01*60);
        case PERIOD_M2:  return(02*60);
        case PERIOD_M3:  return(03*60);
        case PERIOD_M4:  return(04*60);
        case PERIOD_M5:  return(05*60);
        case PERIOD_M6:  return(06*60);
        case PERIOD_M10: return(10*60);
        case PERIOD_M12: return(12*60);
        case PERIOD_M15: return(15*60);
        case PERIOD_M20: return(20*60);
        case PERIOD_M30: return(30*60);
     }
     return(0);
}

void orderInstanceLog() {
     if (handleFile == 0) {
         if (FileIsExist("log.txt")) {
             FileDelete("log.txt");
         }
         ResetLastError();
         handleFile = FileOpen("log.txt", FILE_WRITE|FILE_TXT);
         if (handleFile == INVALID_HANDLE) {
             Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
         }
     }
}

void orderWriteLog(MqlTradeRequest &req, MqlTradeResult &res) {
     FileWrite(handleFile, 
     "===================================================="+"\r\n"
     "              ", req.comment                         +"\r\n"
     "===================================================="+"\r\n"
     "TimeCurrent:  ", TimeToString(TimeCurrent())         +"\r\n"
     "Symbol:       ",                    req.symbol       +"\r\n"
     "Magic Number: ", StringFormat("%d", req.magic)       +"\r\n"
     "Type:         ",      EnumToString( req.type)        +"\r\n"
     "Expiration:   ",      TimeToString( req.expiration)  +"\r\n"
     "Price:        ", StringFormat("%G", req.price)       +"\r\n"
     "Deviation:    ", StringFormat("%G", req.deviation)   +"\r\n"
     "Stop Loss:    ", StringFormat("%G", req.sl)          +"\r\n"
     "Take Profit:  ", StringFormat("%G", req.tp)          +"\r\n"
     "Stop Limit:   ", StringFormat("%G", req.stoplimit)   +"\r\n"
     "Volume:       ", StringFormat("%G", req.volume)      +"\r\n"
     "Request ID:   ", StringFormat("%d", res.request_id)  +"\r\n"
     "Order ticket: ",            (string)res.order        +"\r\n"
     "Deal ticket:  ",            (string)res.deal         +"\r\n"
     "Ask:          ", StringFormat("%G", res.ask)         +"\r\n"
     "Bid:          ", StringFormat("%G", res.bid)         +"\r\n"
     "GetLastError: ", _LastError                           );
}

void orderPaint(MqlTradeRequest &req) {
     if (req.comment == "OPEN ") {
         orderPaintType(OBJ_TREND, req);
         orderPaintType(OBJ_ARROW_LEFT_PRICE, req);
     }
     if (req.comment == "CLOSE ") {
         objIndName = objIndName - OBJECT_POSITION;
         orderPaintType(OBJ_TREND, req);
         objIndName = objIndName + OBJECT_POSITION;
         orderPaintType(OBJ_ARROW_RIGHT_PRICE, req);
     }
     orderPaintType(OBJ_VLINE, req);
     orderPaintText(req);
     ChartRedraw(0);
}

void orderPaintType(ENUM_OBJECT type, MqlTradeRequest &req) {
     string objName = IntegerToString(objIndName++);
     ObjectCreate(0, objName, type, 0, TimeCurrent(), req.price);
     ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
     ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
     ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
}

void orderPaintText(MqlTradeRequest &req) {
     string objName = IntegerToString(objIndName++);
     ObjectCreate(0, objName, OBJ_TEXT, 0, TimeCurrent(), req.price);
     ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
     ObjectSetString (0, objName, OBJPROP_TEXT, req.comment + EnumToString(req.type));
     ObjectSetString (0, objName, OBJPROP_FONT, "Arial");
     ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 6);
     ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LOWER);
     ObjectSetDouble (0, objName, OBJPROP_ANGLE, 90);
}

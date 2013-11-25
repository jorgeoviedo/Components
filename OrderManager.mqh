int handleFile;
int objIndName = 0;
MqlTradeResult result;
MqlTradeRequest request;
double lastAccProfit = 0;
static int OBJECT_POSITION = 4;
input static double VOLUME = 0.2;
input static long MAGIC = 123456;
input static ulong DEVIATION = 15;
input static double PIP_LOSS = 15;

void orderOpen(ENUM_ORDER_TYPE type) {
     ZeroMemory(request);
     ZeroMemory(result);
     request.type = type;
     lastAccProfit = 0;
     request.magic = MAGIC;
     request.volume = VOLUME;
     request.symbol = _Symbol;
     request.comment = "OPEN ";
     request.deviation = DEVIATION;
     request.action = TRADE_ACTION_DEAL;
     if (request.type == ORDER_TYPE_BUY) {
         request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         request.sl = request.price - (_Point * PIP_LOSS);
     } else {
         request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         request.sl = request.price + (_Point * PIP_LOSS);
     }
     orderExecute();
}

void orderDelete() {
     request.sl=0;
     request.tp=0;
     request.comment = "CLOSE ";
     request.action = TRADE_ACTION_DEAL;
     request.price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
     if (request.type == ORDER_TYPE_SELL) {
         request.type = ORDER_TYPE_BUY;
     } else {
         request.type = ORDER_TYPE_SELL;
     }
     orderExecute();
}

void orderModifySLTP() {
     request.tp = 0;
     request.comment = "Modify SL ";
     request.action = TRADE_ACTION_SLTP;
     if (request.type == ORDER_TYPE_BUY) {
         request.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (_Point * PIP_LOSS);
     } else {
         request.sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (_Point * PIP_LOSS);
     }
     orderExecute();
}

void orderExecute() {
     ResetLastError();
     if (OrderSend(request, result) == true) {
         if (request.action == TRADE_ACTION_SLTP) {
             PlaySound("news.wav");
         } else if (request.type == ORDER_TYPE_BUY) {
             PlaySound("connect.wav");
         } else if (request.type == ORDER_TYPE_SELL) {
             PlaySound("ok.wav");
         }
     } else {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

void orderCheckModSLTP() {
     double accountProfit = AccountInfoDouble(ACCOUNT_PROFIT);
     if ((accountProfit > 0) && (accountProfit > lastAccProfit) && (PositionsTotal() > 0)) {
          orderModifySLTP();
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

void orderWriteLog() {
     FileWrite(handleFile, 
     "========================================================"+"\r\n"
     "              ", request.comment                         +"\r\n"
     "========================================================"+"\r\n"
     "TimeCurrent:  ", TimeToString(TimeCurrent())             +"\r\n"
     "Symbol:       ",                    request.symbol       +"\r\n"
     "Magic Number: ", StringFormat("%d", request.magic)       +"\r\n"
     "Type:         ",      EnumToString( request.type)        +"\r\n"
     "Expiration:   ",      TimeToString( request.expiration)  +"\r\n"
     "Price:        ", StringFormat("%G", request.price)       +"\r\n"
     "Deviation:    ", StringFormat("%G", request.deviation)   +"\r\n"
     "Stop Loss:    ", StringFormat("%G", request.sl)          +"\r\n"
     "Take Profit:  ", StringFormat("%G", request.tp)          +"\r\n"
     "Stop Limit:   ", StringFormat("%G", request.stoplimit)   +"\r\n"
     "Volume:       ", StringFormat("%G", request.volume)      +"\r\n"
     "Request ID:   ", StringFormat("%d", result.request_id)   +"\r\n"
     "Order ticket: ",            (string)result.order         +"\r\n"
     "Deal ticket:  ",            (string)result.deal          +"\r\n"
     "Ask:          ", StringFormat("%G", result.ask)          +"\r\n"
     "Bid:          ", StringFormat("%G", result.bid)          +"\r\n"
     "GetLastError: ", _LastError                             );
}

void orderPaint() {
     if (request.comment == "OPEN ") {
         orderPaintType(OBJ_TREND);
         orderPaintType(OBJ_ARROW_LEFT_PRICE);
     }
     if (request.comment == "CLOSE ") {
         objIndName = objIndName - OBJECT_POSITION;
         orderPaintType(OBJ_TREND);
         objIndName = objIndName + OBJECT_POSITION;
         orderPaintType(OBJ_ARROW_RIGHT_PRICE);
     }
     orderPaintType(OBJ_VLINE);
     orderPaintText();
     ChartRedraw(0);
}

void orderPaintType(ENUM_OBJECT type) {
     string objName = IntegerToString(objIndName++);
     ObjectCreate(0, objName, type, 0, TimeCurrent(), request.price);
     ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
     ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
     ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
}

void orderPaintText() {
     string objName = IntegerToString(objIndName++);
     ObjectCreate(0, objName, OBJ_TEXT, 0, TimeCurrent(), request.price);
     ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
     ObjectSetString (0, objName, OBJPROP_TEXT, request.comment + EnumToString(request.type));
     ObjectSetString (0, objName, OBJPROP_FONT, "Arial");
     ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 6);
     ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LOWER);
     ObjectSetDouble (0, objName, OBJPROP_ANGLE, 90);
}

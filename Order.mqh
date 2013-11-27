//+-------------------------------------------------------------------------------------------------------------------+
//|                                                                                                        Order.mqh  |
//+-------------------------------------------------------------------------------------------------------------------+
class Order
{	private:
		int               handleFile;
		int               objIndName;
		MqlTradeResult    result;
		MqlTradeRequest   request;
		double            lastAccProfit;
		static int        OBJECT_POSITION;
		static double     VOLUME;
		static long       MAGIC;
		static ulong      DEVIATION;
		static double     PIP_LOSS;
		void              orderDelete();
		void              orderExecute();
		void              orderWriteLog();
		void              orderPaintText();
		void              orderModifySLTP();
		void              orderPaintType(ENUM_OBJECT type);
    public:
		void              Order(void);
		void              orderPaint();
		int               getHandleFile();
		void              orderInstanceLog();
		void              orderCheckModSLTP();
		void              orderGetInfoOnTick();
		void              orderOpen(ENUM_ORDER_TYPE type);
		int               orderGetEventTimer(ENUM_TIMEFRAMES period);
};
//+-------------------------------------------------------------------------------------------------------------------+
//| declaration                                                                                                       |
//+-------------------------------------------------------------------------------------------------------------------+
double   Order::VOLUME = 0.2;
double   Order::PIP_LOSS = 20;
ulong    Order::DEVIATION = 15;
long     Order::MAGIC = 123456;
int      Order::OBJECT_POSITION = 4;
//+-------------------------------------------------------------------------------------------------------------------+
//| Order()                                                                                                           |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::Order(void) {
	objIndName = 0;
	lastAccProfit = 0;
}
//+-------------------------------------------------------------------------------------------------------------------+
//| orderOpen()                                                                                                       |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderOpen(ENUM_ORDER_TYPE type) {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderDelete()                                                                                                     |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderDelete() {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderModifySLTP()                                                                                                 |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderModifySLTP() {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderExecute()                                                                                                    |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderExecute() {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderCheckModSLTP()                                                                                               |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderCheckModSLTP() {
	double accountProfit = AccountInfoDouble(ACCOUNT_PROFIT);
	if ((accountProfit > 0) && (accountProfit > lastAccProfit) && (PositionsTotal() > 0)) {
		orderModifySLTP();
		if (GetLastError() == 0) {
			lastAccProfit = accountProfit;
		}
	}
}
//+-------------------------------------------------------------------------------------------------------------------+
//| orderGetInfoOnTick()                                                                                              |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderGetInfoOnTick() {
	Comment(StringFormat("ASK=%.6f \nBID=%.6f \nBEST PROFIT=%G \nSPREAD=%G \nPATRIMONIO=%G \nBENEFICIO=%G",
	SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_BID), lastAccProfit,
	SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_PROFIT)));
}
//+-------------------------------------------------------------------------------------------------------------------+
//| orderGetEventTimer()                                                                                              |
//+-------------------------------------------------------------------------------------------------------------------+
int Order::orderGetEventTimer(ENUM_TIMEFRAMES period) {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderInstanceLog()                                                                                                |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderInstanceLog() {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderWriteLog()                                                                                                   |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderWriteLog() {
	FileWrite(handleFile, 
	"======================================================="+"\r\n"
	"              ", request.comment                        +"\r\n"
	"======================================================="+"\r\n"
	"TimeCurrent:  ", TimeToString(TimeCurrent())            +"\r\n"
	"Symbol:       ",                    request.symbol      +"\r\n"
	"Magic Number: ", StringFormat("%d", request.magic)      +"\r\n"
	"Type:         ",      EnumToString( request.type)       +"\r\n"
	"Expiration:   ",      TimeToString( request.expiration) +"\r\n"
	"Price:        ", StringFormat("%G", request.price)      +"\r\n"
	"Deviation:    ", StringFormat("%G", request.deviation)  +"\r\n"
	"Stop Loss:    ", StringFormat("%G", request.sl)         +"\r\n"
	"Take Profit:  ", StringFormat("%G", request.tp)         +"\r\n"
	"Stop Limit:   ", StringFormat("%G", request.stoplimit)  +"\r\n"
	"Volume:       ", StringFormat("%G", request.volume)     +"\r\n"
	"Request ID:   ", StringFormat("%d", result.request_id)  +"\r\n"
	"Order ticket: ",            (string)result.order        +"\r\n"
	"Deal ticket:  ",            (string)result.deal         +"\r\n"
	"Ask:          ", StringFormat("%G", result.ask)         +"\r\n"
	"Bid:          ", StringFormat("%G", result.bid)         +"\r\n"
	"GetLastError: ", _LastError                             );
}
//+-------------------------------------------------------------------------------------------------------------------+
//| orderPaint()                                                                                                      |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderPaint() {
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
//+-------------------------------------------------------------------------------------------------------------------+
//| orderPaintType()                                                                                                  |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderPaintType(ENUM_OBJECT type) {
	string objName = IntegerToString(objIndName++);
	ObjectCreate(0, objName, type, 0, TimeCurrent(), request.price);
	ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
	ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
	ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
}
//+-------------------------------------------------------------------------------------------------------------------+
//| orderPaintText()                                                                                                  |
//+-------------------------------------------------------------------------------------------------------------------+
void Order::orderPaintText() {
	string objName = IntegerToString(objIndName++);
	ObjectCreate(0, objName, OBJ_TEXT, 0, TimeCurrent(), request.price);
	ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
	ObjectSetString (0, objName, OBJPROP_TEXT, request.comment + EnumToString(request.type));
	ObjectSetString (0, objName, OBJPROP_FONT, "Arial");
	ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 6);
	ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LOWER);
	ObjectSetDouble (0, objName, OBJPROP_ANGLE, 90);
}
//+-------------------------------------------------------------------------------------------------------------------+
//| getHandleFile()                                                                                                   |
//+-------------------------------------------------------------------------------------------------------------------+
int Order::getHandleFile() {
	return handleFile;
}
//+-------------------------------------------------------------------------------------------------------------------+
//| end                                                                                                               |
//+-------------------------------------------------------------------------------------------------------------------+
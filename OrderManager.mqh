//##########################################################################################################
//#  Variables  Order Manager                                                                              #
//##########################################################################################################
static long   MAGIC     = 123456;
static ulong  DEVIATION = 15;
static double PIP_LOSS  = 70; //Pips / 10 in EUR USD
static double PIP_TAKE  = 70; //Pips / 10 in EUS USD
static double VOLUME    = 0.2;

//##########################################################################################################
//#  Order Open / Modify / Stop Loss and Take Profit / Delete / Execute                                    #
//##########################################################################################################
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
     req.expiration = TimeTradeServer() + 15*60;
}  

void setOrderDelete(MqlTradeRequest &req)
{    req.type    = (req.type == ORDER_TYPE_SELL)? ORDER_TYPE_BUY: ORDER_TYPE_SELL;
     req.action  = TRADE_ACTION_DEAL;
     req.comment = "CLOSE ORDER ";
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
//##########################################################################################################
//#  End Order Open / Modify / Stop Loss and Take Profit / Delete / Execute                                #
//##########################################################################################################
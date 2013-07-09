int handleFile;

void instanceLog()
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

void writeLog(MqlTradeRequest &req, MqlTradeResult &res)
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
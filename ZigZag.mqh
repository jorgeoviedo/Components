//+------------------------------------------------------------------+
//|                                                      ZigZag.mqh  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| class ZigZag                                                     |
//+------------------------------------------------------------------+
class ZigZag
{
      private:
         double            Low[];
         double            High[];
         int               handleInd;
         void              read(void);
         bool              eval(double &vector[]);
         string            write(double &vector[]);
      
      public:
         void              print();
         void              instance(void);
         ENUM_ORDER_TYPE   evalToOpenPosition();
};
//+------------------------------------------------------------------+
//| instance()                                                       |
//+------------------------------------------------------------------+
void ZigZag::instance() {
     ResetLastError();
     handleInd = iCustom(_Symbol, _Period, "Examples\\ZigzagColor");
     if (handleInd == INVALID_HANDLE) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}
//+------------------------------------------------------------------+
//| read()                                                           |
//+------------------------------------------------------------------+
void ZigZag::read() {
     ResetLastError();
     if ((CopyBuffer(handleInd, 3, 0, 6, High) == WRONG_VALUE) || 
         (CopyBuffer(handleInd, 4, 0, 6, Low) == WRONG_VALUE)) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}
//+------------------------------------------------------------------+
//| eval()                                                           |
//+------------------------------------------------------------------+
bool ZigZag::eval(double &vector[]) {
     if (vector[ArraySize(vector)-1] == 0) {
         return false;
     }
     for (int index=0; index<ArraySize(vector)-1; index++) {
          if (vector[index] > 0) {
              return false;
          }
     }
     return true;
}
//+------------------------------------------------------------------+
//| evalToOpenPosition()                                             |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE ZigZag::evalToOpenPosition() {
     read();
     if (eval(High)) {
         return ORDER_TYPE_SELL;
     } else if (eval(Low)) {
         return ORDER_TYPE_BUY;
     }   
     return NULL;
}
//+------------------------------------------------------------------+
//| write()                                                          |
//+------------------------------------------------------------------+
string ZigZag::write(double &vector[]) {
     string values = "";
     for (int index=0; index<=ArraySize(vector)-1; index++) {
          values = values + DoubleToString(vector[index], 2) + " ";
     }
     return values;
}
//+------------------------------------------------------------------+
//| print()                                                          |
//+------------------------------------------------------------------+
void ZigZag::print() {
     printf("High: %s  Low: %s", write(High), write(Low));
}
//+------------------------------------------------------------------+
//| end                                                              |
//+------------------------------------------------------------------+

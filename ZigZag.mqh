int handleInd;
double High[], Low[];

void zzInstance() {
     ResetLastError();
     handleInd = iCustom(_Symbol, _Period, "Examples\\ZigzagColor");
     if (handleInd == INVALID_HANDLE) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

void zzRead() {
     ResetLastError();
     if ((CopyBuffer(handleInd, 3, 0, 6, High) == WRONG_VALUE) || 
         (CopyBuffer(handleInd, 4, 0, 6, Low) == WRONG_VALUE)) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

bool zzEval(double &vector[]) {
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

ENUM_ORDER_TYPE zzEvalToOpenPosition() {
     zzRead();
     if (zzEval(High)) {
         return ORDER_TYPE_SELL;
     } else if (zzEval(Low)) {
         return ORDER_TYPE_BUY;
     }   
     return NULL;
}

string zzWrite(double &vector[]) {
     string values = "";
     for (int index=0; index<=ArraySize(vector)-1; index++) {
          values = values + DoubleToString(vector[index], 2) + " ";
     }
     return values;
}

void zzPrint() {
     printf("High: %s  Low: %s", zzWrite(High), zzWrite(Low));
}

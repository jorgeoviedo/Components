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
     if ((CopyBuffer(handleInd, 3, 0, 6, High ) == WRONG_VALUE) || 
         (CopyBuffer(handleInd, 4, 0, 6, Low  ) == WRONG_VALUE)) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

bool zzEval(double &checkData[]) {
     if (checkData[ArraySize(checkData)-1] == 0) {
         return false;
     }
     for (int index=0; index<ArraySize(checkData)-1; index++) {
          if (checkData[index] > 0) {
              return false;
          }
     }
     return true;
}

string zzWrite(double &checkData[]) {
     string values = "";
     for (int index=0; index<=ArraySize(checkData)-1; index++) {
          values = values + DoubleToString(checkData[index], 2) + " ";
     }
     return values;
}

void zzPrint() {
     printf("High: %s  Low: %s", zzWrite(High), zzWrite(Low));
}

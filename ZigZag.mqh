int handleInd;
double High[], Low[], Color[];

void ZZinstance() {
     ResetLastError();
     handleInd = iCustom(_Symbol, _Period, "Examples\\ZigzagColor");
     if (handleInd == INVALID_HANDLE) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

void ZZread() {
     ResetLastError();
     if (CopyBuffer(handleInd, 2, 0, 6, Color) == WRONG_VALUE) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
     if (CopyBuffer(handleInd, 3, 0, 6, High ) == WRONG_VALUE) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
     if (CopyBuffer(handleInd, 4, 0, 6, Low  ) == WRONG_VALUE) {
         Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     }
}

bool ZZeval(double &checkData[]) {
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

string ZZwrite(double &checkData[]) {
     string values = "";
     for (int index=0; index<=ArraySize(checkData)-1; index++) {
          values = values + DoubleToString(checkData[index], 2) + " ";
     }
     return values;
}

void ZZprint() {
     printf("Color: %s  High: %s  Low: %s", ZZwrite(Color), ZZwrite(High), ZZwrite(Low));
}

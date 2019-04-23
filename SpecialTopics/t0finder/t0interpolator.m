% 2019/107/20:46:06.958094    CDTime_Time_Text                                                                 BA  - CDT Text                  ---------------- -000:00:00:00.003.                  
% 2019/107/20:46:06.968070    CDTime_Time_Text                                                                 BA  - CDT Text                  ---------------- +000:00:00:00.006.                  



UTC1=makeMatlabTimeVector({'2019/107/20:46:06.958094'},0,0)
UTC2=makeMatlabTimeVector({'2019/107/20:46:06.968070'},0,0)
CDT1= -00.003
CDT2=  00.006

t = linterp(0,CDT1,UTC1,CDT2,UTC2)


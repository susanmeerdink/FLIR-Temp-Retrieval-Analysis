%MBBMin	MBBMax	M.95	M.95Min	M.95Max	Mpix	MPixMin	MpixMax	TBB	TBBmin	TBBMax	T.95	T.95min	T.95Max	Tpix	TpixMin	TpixMax
MBB=Avg_Exit_at_BB;
MMBMIn=min(min(Exit_at_BB));
MMBMax=max(max(Exit_at_BB));
M95=Avg_Surf_exit;
M95MIn=min(min(Surf_exit));
M95Max=max(max(Surf_exit));
Mpix=Avg_Surf_exit_using_class_emiss;
MpixMin=min(min(Surf_exit_using_class_emiss));
MpixMax=max(max(Surf_exit_using_class_emiss));
TBB=Scene_temp_calcul_from_Avg_exit_at_BB;
TBBMin=min(min(unCorTem));
TBBMax=max(max(unCorTem));
T95=Scene_temp_at_Emiss_95;
T95MIn=min(min(Temp_calcul_from_Surf_exit));
T95Max=max(max(Temp_calcul_from_Surf_exit));
Tpix=Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss;
TpixMin=min(min(Surf_temp_using_class_emiss));
TpixMax=max(max(Surf_temp_using_class_emiss));
outputs=[MBB,MMBMIn,MMBMax,M95,M95MIn,M95Max,Mpix,MpixMin,MpixMax,TBB,TBBMin,...
    TBBMax,T95,T95MIn,T95Max,Tpix,TpixMin,TpixMax]


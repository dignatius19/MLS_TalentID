function [newTable] = compare_groups(results, query, field)

newTable = results(field == query, :);

newTable.PsA3Succ_Diff = (newTable.PassA3Success - nanmean(newTable.PassA3Success)) ./ nanmean(newTable.PassA3Success) * 100;
newTable.PsForSucc_Diff = (newTable.PassForSuccess - nanmean(newTable.PassForSuccess)) ./ nanmean(newTable.PassForSuccess) * 100;
newTable.TakeOnSucc_Diff = (newTable.TakeOnSuccess - nanmean(newTable.TakeOnSuccess)) ./ nanmean(newTable.TakeOnSuccess) * 100;
newTable.TouchesA3_Diff = (newTable.TchsA3 - nanmean(newTable.TchsA3)) ./ nanmean(newTable.TchsA3) * 100;
newTable.Shots_Diff = (newTable.Shot - nanmean(newTable.Shot)) ./ nanmean(newTable.Shot) * 100;
newTable.Crosses_Diff = (newTable.Crosses - nanmean(newTable.Crosses)) ./ nanmean(newTable.Crosses) * 100;
newTable.CrossSucc_Diff = (newTable.CrossSuccess - nanmean(newTable.CrossSuccess)) ./ nanmean(newTable.CrossSuccess) * 100;
newTable.KeyPass_Diff = (newTable.KeyPass - nanmean(newTable.KeyPass)) ./ nanmean(newTable.KeyPass) * 100;
newTable.Chance_Diff = (newTable.Chance - nanmean(newTable.Chance)) ./ nanmean(newTable.Chance) * 100;
newTable.DefA3_Diff = (newTable.DefActionA3 - nanmean(newTable.DefActionA3)) ./ nanmean(newTable.DefActionA3) * 100;
newTable.RecInt_Diff = (newTable.TotalRecInt - nanmean(newTable.TotalRecInt)) ./ nanmean(newTable.TotalRecInt) * 100;
newTable.TotalDistance_Diff = (newTable.TotalDistancekm - nanmean(newTable.TotalDistancekm)) ./ nanmean(newTable.TotalDistancekm) * 100;
newTable.SigActions_Diff = (newTable.sigActions - nanmean(newTable.sigActions)) ./ nanmean(newTable.sigActions) * 100;
newTable.SigActionsA3_Diff = (newTable.sigActionsA3 - nanmean(newTable.sigActionsA3)) ./ nanmean(newTable.sigActionsA3) * 100;
newTable.ga_mod_Diff = (newTable.ga_mod - nanmean(newTable.ga_mod)) ./ nanmean(newTable.ga_mod) * 100;
newTable.GplusA_Diff = (newTable.GplusA - nanmean(newTable.GplusA)) ./ nanmean(newTable.GplusA) * 100;

end
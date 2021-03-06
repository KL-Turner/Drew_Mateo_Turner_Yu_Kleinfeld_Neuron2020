function CreateTrialSpectrograms_Neuron2020(mergedDataFiles)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyzes the raw neural data from each MergedData.mat file and calculates two different spectrograms.
%________________________________________________________________________________________________________________________

for a = 1:size(mergedDataFiles,1)
    mergedDataFileID = mergedDataFiles(a,:);
    specFileID = [mergedDataFileID(1:end - 15) '_SpecData.mat'];
    if ~exist(specFileID,'file')
        load(mergedDataFileID);
        duration = MergedData.notes.trialDuration_Sec;
        anFs = MergedData.notes.anFs;
        expectedLength = duration*anFs;
        [animalID,~,fileID,vesselID,imageID] = GetFileInfo2_Neuron2020(mergedDataFileID);
        rawNeuro = detrend(MergedData.data.rawNeuralData(1:expectedLength),'constant');
        w0 = 60/(anFs/2);
        bw = w0/35;
        [num,den] = iirnotch(w0,bw);
        rawNeuro2 = filtfilt(num,den,rawNeuro);
        % Spectrogram parameters
        params1.tapers = [1,1];
        params1.Fs = anFs;
        params1.fpass = [1,100];
        movingwin1 = [1,1/10];
        params5.tapers = [5,9];
        params5.Fs = anFs;
        params5.fpass = [1,100];
        movingwin5 = [5,1/5];
        disp(['Creating spectrogram for file number ' num2str(a) ' of ' num2str(size(mergedDataFiles, 1)) '...']); disp(' ')
        [S1,T1,F1] = mtspecgramc_Neuron2020(rawNeuro2,movingwin1,params1);
        [S5,T5,F5] = mtspecgramc_Neuron2020(rawNeuro2,movingwin5,params5);
        SpecData.fiveSec.S = S5';
        SpecData.fiveSec.T = T5;
        SpecData.fiveSec.F = F5;
        SpecData.fiveSec.params = params5;
        SpecData.fiveSec.movingwin = movingwin5;
        SpecData.oneSec.S = S1';
        SpecData.oneSec.T = T1;
        SpecData.oneSec.F = F1;
        SpecData.oneSec.params = params1;
        SpecData.oneSec.movingwin = movingwin1;
        save([animalID '_' vesselID '_' fileID '_' imageID '_SpecData.mat'],'SpecData');
    else
        disp([specFileID ' already exists. Continuing...']); disp(' ')
    end
end

end

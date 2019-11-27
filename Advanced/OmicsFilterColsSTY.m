% O = OmicsFilterColsSTY(O)
% 
%   This function keeps only prespecified get(O,'cols')
% 
% Example:
% WriteWithColnames(OmicsFilterColsSTY(O),'Data.xlsx',get(O,'data'))

function O = OmicsFilterColsSTY(O)

drin = {'Proteins'
'PositionsWithinProteins'
'LeadingProteins'
'Protein'
'ProteinNames'
'GeneNames'
'FastaHeaders'
'DiagnosticPeak'
'NumberOfPhospho_STY_'
'AminoAcid'
'SequenceWindow'
'ModificationWindow'
'PeptideWindowCoverage'
'Phospho_STY_Probabilities'
'Phospho_STY_ScoreDiffs'
'Reverse'
'PotentialContaminant'
'ProteinGroupIDs'
'Positions'
'PeptideIDs'
'Mod_PeptideIDs'
'EvidenceIDs'
'MS_MSIDs'
'BestLocalizationRawFile'
'BestScoreRawFile'
'BestPEPRawFile'
'LocalizationProb'
'ScoreDiff'
'PEP'
'Score'
'DeltaScore'
'ScoreForLocalization'
'PositionInPeptide'
'Charge'
'MassError_ppm_'
'id'
'Position'
'BestLocalizationEvidenceID'
'BestLocalizationMS_MSID'
'BestLocalizationScanNumber'
'BestScoreEvidenceID'
'BestScoreMS_MSID'
'BestScoreScanNumber'
'BestPEPEvidenceID'
'BestPEPMS_MSID'
'BestPEPScanNumber'
'ProteinIDs'};

cols = get(O,'cols');
fn = intersect(fieldnames(cols),drin,'stable');
cols2 = struct;
for f=1:length(fn)
    cols2.(fn{f}) = cols.(fn{f});
end
O = set(O,'cols',cols2);



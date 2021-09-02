% booklet_maker
%
% Make Abstract Programme Booklet from Google Form data.
%
% Save Google Form as csv.
% This code loads this csv into a MATLAB Table. Fields will be named from
% questions in form.
% Writes out .tex files for use with Overleaf's 'A Basic Conference 
% Abstract Booklet'. Code will overwrite existing files!
%
% Tex files need uploadng to Overleaf and some editing - currently 
% affiliations need to be moved into {} on next line.
% Check for %, <, >, degrees etc
%
% URLs are from Google Form and link to drive where form uploads were
% saved (in the account of the form creator). This folder needs to be made 
% public if others are to view.
%
% Copyright 2021. David Atkinson,  D.Atkinson@ucl.ac.uk
% University College London
%

% Local folder where abstract tex files will be saved. Will overwrite existing
% files!
disp(['Select folder where abstract .tex will be saved'])
abstract_folder = pref_uigetdir('booklet_maker','abstract_folder') ;

disp(['Slect csv file'])
T = readtable(pref_uigetfile) ;
wsa = T.WhichSessionsWillYouAttend_ ;

nentry = size(T,1) ;
for ientry = 1: nentry  % Loop through Table rows, creating .tex files

    if length(T.PermissionForPublication{ientry}) < 10
        warning(['Permision withheld for entry: ', num2str(ientry)])
    end

    fname = ['paper',num2str(ientry, '%03u'), '.tex']; % tex filename
    ffn = fullfile(abstract_folder, fname) ;

    fid = fopen(ffn,"w");
    if fid < 1
        ferror(fid)
    end

    % sessions
    if isempty(strfind(wsa{ientry},'Session A')) 
        sA = ' ';
    else
        sA = 'A' ;
    end

    if isempty(strfind(wsa{ientry},'Session B')) 
        sB = ' ';
    else
        sB = 'B' ;
    end

    if isempty(strfind(wsa{ientry},'Session C')) 
        sC = ' ';
    else
        sC = 'C' ;
    end

    fprintf(fid,'%s\n', ...
        ['\begin{conf-abstract}[\textbf{',sA,'\\',sB,'\\',sC,'}]'] );

    fprintf(fid,'{%s}\n', ['[',num2str(ientry,'%03u'),'] ',T.PosterTitle{ientry}] ) ;

    fprintf(fid,'{%s}\n', T.AuthorNamesAndAffiliations{ientry} ) ;

    fprintf(fid,'%s\n','{ }' );

    fprintf(fid,'%s\n\n', '\indexauthors{}') ;
    
    fprintf(fid,'%s\n\n', T.Synopsis{ientry} );

    fprintf(fid,'%s\n', '\vskip10pt') ;

    ci = T.x_optional_ContactInformationForProgrammeBooklet{ientry} ;
    if ~isempty(ci)
        line8 = ['Contact Information: \texttt{',ci , '}'] ;
    else
        line8 = ' ';
    end
    fprintf(fid,'%s\n\n', line8) ;
    fprintf(fid,'%s\n', '\vskip10pt') ;
    fprintf(fid,'%s\n', '\textbf{Remove below before publication}') ;
    fprintf(fid,'%s\n', '\vskip10pt') ;
    fprintf(fid,'%s\n', T.EmailAddress{ientry}) ; 
    fprintf(fid,'%s\n', '\vskip10pt') ;

    % URL(s) for poster image. Multiple uploads were allowed in form 
    % (as cannot delete in Google Forms once submitted)
    urls = T.PosterUpload{ientry} ;
    ihttps = strfind(urls,'https') ;
    icomma = strfind(urls,',') ;
    icomma = [icomma(:)' length(urls)+1]-1 ;
    for iurl = 1:length(ihttps)
        fprintf(fid,'\\url{%s}\n\n', urls(ihttps(iurl):icomma(iurl))) ;
    end

    fprintf(fid,'%s\n', '\vskip10pt') ;

    fprintf(fid,'\nOptional Caption: %s\n\n', T.x_optional_Caption{ientry} ) ;

    fprintf(fid,'%s\n', '\vskip10pt') ;
    fprintf(fid,'%s\n', ['\end{conf-abstract}'] );

    fclose(fid) ;
end




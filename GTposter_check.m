% GTposter_check
%
% Gets information about GatherTown posters - useful for checking Private
% Space squares, Posters, previews and captions.
%
% To use this you will need to have got an API token from GatherTown.
%
% Copyright 2021. David Atkinson, University College London.


% You will need an api token from GatherTown.
% Line below calls my own personal function to return my token, 
% replace with your token
apiKey = get_token('GatherTown') ;

% spaceId is the string in the URL after gather.town/app/
% mapId is the name in the Rooms tab on mapmaker

% https://gather.town/app/5pRltGc2MyWucPw2/moco_demo_poster
spaceId = '5pRltGc2MyWucPw2\moco_demo_poster' ; mapId = 'custom-entrance' ;


% spaceId = 'UsyRSfBoDWzhA2QL\ucacdat' ; mapId = 'posterh' ;
% spaceId = 'jkS45ZLfgi2Fscjw\moco' ; mapId = 'Poster_room' ;

gt_url = 'https://gather.town/api/' ;
action = 'getMap' ;  % getMap action needs a mapId

url = [gt_url, action, '?spaceId=', spaceId, '&mapId=',mapId, '&apiKey=',apiKey] ;

% disp(url)

options = weboptions('Timeout', 10) ;
data = webread(url, options) 

disp(' ')
disp(' Check the number of tiles for each private space are as expected')
disp(['Private Spaces (name: tile count)'])
spaces = [data.spaces{:}] ;
[sid, ia, ic] = unique({spaces.spaceId}) ;
for isid = 1:length(sid)
    disp([sid{isid},': ', num2str(sum(ic==isid))])
end
disp(' ')

% Figure with all the posters, previews and captions.
% Numbers are the tile row column, Note not in same order as room layout.
disp('Figure will show poster, preview, caption and row-column map position')
figure
t=tiledlayout('flow','TileSpacing','tight') ;
nobj = length(data.objects) ;
for iobj = 1:nobj
    this_obj = data.objects{iobj} ;
    switch this_obj.x_name
        case 'Poster Set'
            x = this_obj.x + 1 ;
            y = this_obj.y + 1 ;
            height = this_obj.height ;
            width = this_obj.width ;
            ax = nexttile ;
            ax.XTick = [] ;
            ax.YTick = [] ;
            if isfield(this_obj.properties,'image')
                poster =  imread(this_obj.properties.image) ;
                imshow(poster)  
            end
            title([num2str(y),'  ', num2str(x)])

            ax = nexttile ;
            ax.XTick = [] ;
            ax.YTick = [] ;
            if isfield(this_obj.properties,'preview')
                preview = imread(this_obj.properties.preview) ;
                imshow(preview)
            end
            if isfield(this_obj.properties,'blurb')
                title(this_obj.properties.blurb)
            end
        otherwise
    end
end

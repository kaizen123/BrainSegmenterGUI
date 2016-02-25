function varargout = allSectionsView(varargin)
% ALLSECTIONSVIEW MATLAB code for allSectionsView.fig
%      ALLSECTIONSVIEW, by itself, creates a new ALLSECTIONSVIEW or raises the existing
%      singleton*.
%
%      H = ALLSECTIONSVIEW returns the handle to a new ALLSECTIONSVIEW or the handle to
%      the existing singleton*.
%
%      ALLSECTIONSVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALLSECTIONSVIEW.M with the given input arguments.
%
%      ALLSECTIONSVIEW('Property','Value',...) creates a new ALLSECTIONSVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before allSectionsView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to allSectionsView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help allSectionsView

% Last Modified by GUIDE v2.5 17-Feb-2016 23:01:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @allSectionsView_OpeningFcn, ...
                   'gui_OutputFcn',  @allSectionsView_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before allSectionsView is made visible.
function allSectionsView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to allSectionsView (see VARARGIN)

% Choose default command line output for allSectionsView
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes allSectionsView wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global allSinfo btainRoot

% getAllSinfo;
% allSinfo.cnames = {'s1','s2','s3','s4','s5'};
% allSinfo.data = {true true true false true;true true true true true;true true true true true;true true true true true;...
%                  true true true true true;true true true true true;false false false false false;false false false false false};
d = allSinfo.data;
r = allSinfo.cnames;
set(handles.tableAll, 'data', d', 'RowName', r');
%set(handles.tableAll, 'CellEditCallback', @check_checked);


% --- Outputs from this function are returned to the command line.
function varargout = allSectionsView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object deletion, before destroying properties.
function tableAll_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to tableAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in tableAll.
function tableAll_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tableAll (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global brainRoot batchRoot sectionName
data=get(hObject,'Data'); % get the data cell array of the table
cols=get(hObject,'ColumnFormat'); % get the column formats
if strcmp(cols(eventdata.Indices(2)),'logical') % if the column of the edited cell is logical
    if eventdata.EditData % if the checkbox was set to true
        data(eventdata.Indices(1),eventdata.Indices(2))=true; % set the data value to true
        set(hObject,'Data',data); % now set the table's data to the updated data cell array 
        drawnow()
        rows = get(hObject,'RowName');
        sectionName = rows{eventdata.Indices(1)};
        batchRoot = [brainRoot '\Processed\' sectionName '\'];
        BrainSegmenterGUI('openAnalysis_Callback',hObject,eventdata,guidata(hObject),sectionName);
    else % if the checkbox was set to false
        data(eventdata.Indices(1),eventdata.Indices(2))=false; % set the data value to false
        set(hObject,'Data',data); % now set the table's data to the updated data cell array 
        drawnow()
    end
end

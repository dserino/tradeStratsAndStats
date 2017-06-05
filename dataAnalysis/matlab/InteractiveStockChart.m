function varargout = InteractiveStockChart(varargin)
% INTERACTIVESTOCKCHART MATLAB code for InteractiveStockChart.fig
%      INTERACTIVESTOCKCHART, by itself, creates a new INTERACTIVESTOCKCHART or raises the existing
%      singleton*.
%
%      H = INTERACTIVESTOCKCHART returns the handle to a new INTERACTIVESTOCKCHART or the handle to
%      the existing singleton*.
%
%      INTERACTIVESTOCKCHART('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERACTIVESTOCKCHART.M with the given input arguments.
%
%      INTERACTIVESTOCKCHART('Property','Value',...) creates a new INTERACTIVESTOCKCHART or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InteractiveStockChart_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InteractiveStockChart_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InteractiveStockChart

% Last Modified by GUIDE v2.5 04-Jun-2017 22:43:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InteractiveStockChart_OpeningFcn, ...
                   'gui_OutputFcn',  @InteractiveStockChart_OutputFcn, ...
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

% TODO:
%  - symbol update from picker
%  - scroll bar
%  - candle sticks for multiple days
%  - add in dates
%  - tech indicators
%    - moving average
%    - stochastics
%    - macd
%    - etc.
%  - draw lines (like snapchat draw)


% --- Executes just before InteractiveStockChart is made visible.
function InteractiveStockChart_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InteractiveStockChart (see VARARGIN)

% Choose default command line output for InteractiveStockChart
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InteractiveStockChart wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% save user data to axes1
if ~isempty(varargin)
  set(handles.axes1,'UserData',varargin);
end

data = get(handles.axes1,'UserData');
symbols = data{1};
dates = data{2};
close = data{3};
open = data{4};
high = data{5};
low = data{6};
volume = data{7};

%% set menus
set(handles.popupmenu_symbols,'String',symbols);

time_period = {'1D','2D','5D','20D'};
set(handles.popupmenu_period,'String',time_period);

%% plot
update_plots(handles);


% --- Outputs from this function are returned to the command line.
function varargout = InteractiveStockChart_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  resered - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu_symbols.
function popupmenu_symbols_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_symbols contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_symbols


% --- Executes during object creation, after setting all properties.
function popupmenu_symbols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_analysis.
function popupmenu_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_analysis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_analysis


% --- Executes during object creation, after setting all properties.
function popupmenu_analysis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_period.
function popupmenu_period_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_period contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_period


% --- Executes during object creation, after setting all properties.
function popupmenu_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in zoom_in_.
function zoom_in_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_in_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get current color and if button is clicked
  color = get(handles.popupmenu_symbols,'BackgroundColor');
  
  isClicked = get(handles.zoom_out,'UserData');

  if isClicked
    % if already clicked unclick
    set(handles.zoom_in,'UserData',0);

    color_new = get(handles.popupmenu_symbols,'BackgroundColor');
    set(handles.zoom_in,'BackgroundColor',color_new);
    
    return
  else
    % not clicked yet
    set(handles.zoom_in,'UserData',1);
    isClicked = 1;

    color_new = color/1.5;
    set(handles.zoom_in,'BackgroundColor',color_new);
  end
  
  data = get(handles.axes1,'UserData');
  symbols = data{1};
  dates = data{2};
  close = data{3};
  open = data{4};
  high = data{5};
  low = data{6};
  volume = data{7};

  k = 1;
  
  while true
    
    isClicked = get(handles.zoom_in,'UserData');
    if ~isClicked
      return
    end
    
    axes(handles.axes1)
    hold on
    y_ = ylim;
    
    [x1,y,~] = ginput(1);
    
    % check to see if user unclicked
    if y > y_(2)
      color_new = get(handles.popupmenu_symbols,'BackgroundColor');
      set(handles.zoom_in,'BackgroundColor',color_new);
      set(handles.zoom_in,'UserData',0);
      return
    end
    
    % draw ref line
    plot([x1,x1],[y_(1),y_(2)],'b');
    
    [x2,y,~] = ginput(1);

    % check to see if user unclicked
    if y > y_(2)
      color_new = get(handles.popupmenu_symbols,'BackgroundColor');
      set(handles.zoom_in,'BackgroundColor',color_new);
      set(handles.zoom_in,'UserData',0);
      % need to undo last plot
      x_ = xlim;
      cla;
      update_plots(handles,x_(1),x_(2));
      return
    end

    % draw ref line
    plot([x2,x2],[y_(1),y_(2)],'b');

    cla;
    update_plots(handles);
    
    axes(handles.axes1)
    % find axis x limits
    n1 = floor(x1);
    n2 = ceil(x2);
    
    xlim([n1,n2]);
    
    % find axis y limits
    y0 = min(low(k,n1:n2));
    y1 = max(high(k,n1:n2));
    ylim([y0,y1]);
    
    axes(handles.axes2);
    xlim([n1,n2]);

    y0 = min(volume(k,n1:n2));
    y1 = max(volume(k,n1:n2));

    ylim([y0,y1]);

  end
    
% --- Executes on button press in zoom_out.
function zoom_out_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get current color and if button is clicked
  color = get(handles.popupmenu_symbols,'BackgroundColor');
      
  isClicked = get(handles.zoom_out,'UserData');

  if isClicked
    % if already clicked unclick
    set(handles.zoom_out,'UserData',0);

    color_new = get(handles.popupmenu_symbols,'BackgroundColor');
    set(handles.zoom_out,'BackgroundColor',color_new);
    
    return
  else
    % not clicked yet
    set(handles.zoom_out,'UserData',1);
    isClicked = 1;

    color_new = color/1.5;
    set(handles.zoom_out,'BackgroundColor',color_new);
  end
  
  data = get(handles.axes1,'UserData');
  symbols = data{1};
  dates = data{2};
  close = data{3};
  open = data{4};
  high = data{5};
  low = data{6};
  volume = data{7};

  k = 1;
  
  axes(handles.axes1)
  
  while true
    isClicked = get(handles.zoom_out,'UserData');
    if ~isClicked
      return
    end
    
    [x,y,~] = ginput(1);

    % check to see if user unclicked
    y0 = ylim;
    if y > y0(2)
      color_new = get(handles.popupmenu_symbols,'BackgroundColor');
      set(handles.zoom_out,'BackgroundColor',color_new);
      set(handles.zoom_out,'UserData',0);
      return
    end

    % find axis x limist
    x0 = xlim;
    l0 = x0(2)-x0(1);

    z_factor = 1.5;
    l = l0*1.5;
    n1 = floor(x-l/2);
    n2 = ceil(x+l/2);
    
    if n1 < 1
      n1 = 1;
    end
    if n2 > length(close(1,:))
      n2 = length(close(1,:));
    end
    xlim([n1,n2]);
    
    % find axis y limits
    y0 = min(low(k,n1:n2));
    y1 = max(high(k,n1:n2));
    ylim([y0,y1]);
    
    axes(handles.axes2);
    xlim([n1,n2]);

    y0 = min(volume(k,n1:n2));
    y1 = max(volume(k,n1:n2));

    ylim([y0,y1]);
    


  end

  
  
  
  
%% general functions
function update_plots(handles,n1,n2)

  data = get(handles.axes1,'UserData');
  symbols = data{1};
  dates = data{2};
  close = data{3};
  open = data{4};
  high = data{5};
  low = data{6};
  volume = data{7};

  %% plot
  axes(handles.axes1);
  k = 1; % todo
  N = length(close(k,:));

  % find axis x limits
  if ~exist('n1','var')
    n1 = 1;
    n2 = N;
  end
  
  CandlestickPlot(n1:n2,close(k,n1:n2),open(k,n1:n2),high(k,n1:n2),low(k,n1:n2),1,0.35,1.0);

  xlim([n1,n2]);
    
  % find axis y limits
  y0 = min(low(k,n1:n2));
  y1 = max(high(k,n1:n2));
  ylim([y0,y1]);

  axes(handles.axes2);
  k = 1;
  N = length(close(k,:));

  bar((1:N)+0.5,volume(k,:));

  % find axis x limits
  xlim([n1,n2]);
  grid on

  set(gca,'YAxisLocation','right');

  

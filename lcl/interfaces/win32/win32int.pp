{ $Id: win32int.pp 53358 2016-11-12 12:58:55Z maxim $ }
{
 /***************************************************************************
                         WIN32INT.pp  -  Win32Interface Object
                             -------------------



 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}

unit Win32Int;

{$mode objfpc}{$H+}{$T-}{$message warning Fix implicit pointer conversions}
{$I win32defines.inc}

interface

{
  When editing this unit list, be sure to keep Windows listed first to ensure
  successful compilation.
}
uses
  Windows, // keep as first
  ActiveX, Classes,
  Translations, ComCtrls, Controls, Buttons,
  LCLIntf, LclProc, LazUTF8, LCLType, LMessages,
  Forms, Dialogs, GraphMath, GraphType, InterfaceBase,
  StdCtrls, SysUtils, Win32Def, Graphics, Menus, CommCtrl,
  MultiMon, Themes{, Win32Debug};

const
  // standard windows cursors
  // they are already defined in the rtl, however the
  // const = const defines after this fail with an illegal expression
  IDC_ARROW     = System.MakeIntResource(32512);
  IDC_IBEAM     = System.MakeIntResource(32513);
  IDC_WAIT      = System.MakeIntResource(32514);
  IDC_CROSS     = System.MakeIntResource(32515);
  IDC_UPARROW   = System.MakeIntResource(32516);
  IDC_SIZE      = System.MakeIntResource(32640);
  IDC_ICON      = System.MakeIntResource(32641);
  IDC_SIZENWSE  = System.MakeIntResource(32642);
  IDC_SIZENESW  = System.MakeIntResource(32643);
  IDC_SIZEWE    = System.MakeIntResource(32644);
  IDC_SIZENS    = System.MakeIntResource(32645);
  IDC_SIZEALL   = System.MakeIntResource(32646);
  IDC_NO        = System.MakeIntResource(32648);
  IDC_HAND      = System.MakeIntResource(32649);
  IDC_APPSTARTING = System.MakeIntResource(32650);
  IDC_HELP      = System.MakeIntResource(32651);

{
  These are add-ons, don't exist in windows itself!
  IDC_NODROP    = MakeIntResource(32767);
  IDC_DRAG      = MakeIntResource(32766);
  IDC_HSPLIT    = MakeIntResource(32765);
  IDC_VSPLIT    = MakeIntResource(32764);
  IDC_MULTIDRAG = MakeIntResource(32763);
  IDC_SQLWAIT   = MakeIntResource(32762);
  IDC_HANDPT    = MakeIntResource(32761);
}
  IDC_NODROP    = IDC_NO;
  IDC_DRAG      = IDC_ARROW;
  IDC_HSPLIT    = IDC_SIZEWE;
  IDC_VSPLIT    = IDC_SIZENS;
  IDC_MULTIDRAG = IDC_ARROW;
  IDC_SQLWAIT   = IDC_WAIT;
  IDC_HANDPT    = IDC_HAND;

  LclCursorToWin32CursorMap: array[crLow..crHigh] of PChar = (
  // uni-direction cursors are mapped to bidirection win32 cursors
     IDC_SIZENWSE, IDC_SIZENS, IDC_SIZENESW, IDC_SIZEWE, IDC_SIZEWE,
     IDC_SIZENESW, IDC_SIZENS, IDC_SIZENWSE, IDC_SIZEALL, IDC_HANDPT, IDC_HELP,
     IDC_APPSTARTING, IDC_NO, IDC_SQLWAIT, IDC_MULTIDRAG, IDC_VSPLIT,
     IDC_HSPLIT, IDC_NODROP, IDC_DRAG, IDC_WAIT, IDC_UPARROW, IDC_SIZEWE,
     IDC_SIZENWSE, IDC_SIZENS, IDC_SIZENESW, IDC_SIZE, IDC_IBEAM, IDC_CROSS,
     IDC_ARROW, IDC_ARROW, IDC_ARROW);

  //flag used to avoid propagating LM_CHANGE for TCustomCheckBox
  SKIP_LMCHANGE = 1000;

type
  PPPipeEventInfo = ^PPipeEventInfo;
  PPipeEventInfo = ^TPipeEventInfo;
  TPipeEventInfo = record
    Handle: THandle;
    UserData: PtrInt;
    OnEvent: TPipeEvent;
    Prev: PPipeEventInfo;
    Next: PPipeEventInfo;
  end;

  TWaitHandler = record
    ListIndex: pdword;
    UserData: PtrInt;
    OnEvent: TWaitHandleEvent;
  end;

  TSocketEvent = function(ASocket: THandle; Flags: dword): Integer of object;

  { Win32 interface-object class }

  { TWin32WidgetSet }

  TWin32WidgetSet = class(TWidgetSet)
  private
    // The parent of all windows, represents the button of the taskbar
    // This window is also the owner of the clipboard.
    // Assoc. windowproc also acts as handler for popup menus
    FAppHandle,
    FDockWndHandle: HWND;
    FCommonControlsVersion: DWord;

    FMetrics: TNonClientMetrics;
    FMetricsFailed: Boolean;
    FDefaultFont: HFONT;

    FWaitHandleCount: dword;
    FWaitHandles: array of HANDLE;
    FWaitHandlers: array of TWaitHandler;
    FWaitPipeHandlers: PPipeEventInfo;
    FPendingWaitHandlerIndex: Integer;

    InitCommonControlsEx: function(ICC: PInitCommonControlsEx): LongBool; stdcall;

    FOnAsyncSocketMsg: TSocketEvent;
    FDotsPatternBitmap: HBitmap;

    function GetDotsPatternBitmap: HBitmap;

    { event handler helper functions }
    procedure HandleProcessEvent(AData: PtrInt; AFlags: dword);
    procedure CheckPipeEvents;

    function WinRegister: Boolean;

    procedure CreateAppHandle;
  protected
    function CreateThemeServices: TThemeServices; override;
    function GetAppHandle: THandle; override;
    procedure SetAppHandle(const AValue: THandle); override;
  public
    { Creates a callback of Lazarus message Msg for Sender }
    procedure SetCallback(Msg: LongInt; Sender: TObject); virtual;
    { Removes all callbacks for Sender }
    procedure RemoveCallbacks(Sender: TObject); virtual;

    { Constructor of the class }
    constructor Create; override;
    { Destructor of the class }
    destructor Destroy; override;

    procedure DCSetAntialiasing(CanvasHandle: HDC; AEnabled: Boolean); override;
    function LCLPlatform: TLCLPlatform; override;
    function GetLCLCapability(ACapability: TLCLCapability): PtrUInt; override;

    { Initialize the API }
    procedure AppInit(var ScreenInfo: TScreenInfo); override;
    procedure AppMinimize; override;
    procedure AppRestore; override;
    procedure AppBringToFront; override;
    procedure AppProcessMessages; override;
    procedure AppWaitMessage; override;
    procedure AppTerminate; override;
    procedure AppSetIcon(const Small, Big: HICON); override;
    procedure AppSetTitle(const ATitle: string); override;
    procedure AppSetVisible(const AVisible: Boolean); override;
    function AppRemoveStayOnTopFlags(const ASystemTopAlso: Boolean = False): Boolean; override;
    function AppRestoreStayOnTopFlags(const ASystemTopAlso: Boolean = False): Boolean; override;
    procedure AppSetMainFormOnTaskBar(const DoSet: Boolean); override;

    function  InitStockFont(AFont: TObject; AStockFont: TStockFont): Boolean; override;

    procedure DCSetPixel(CanvasHandle: HDC; X, Y: integer; AColor: TGraphicsColor); override;
    function  DCGetPixel(CanvasHandle: HDC; X, Y: integer): TGraphicsColor; override;
    procedure DCRedraw(CanvasHandle: HDC); override;
    procedure SetDesigning(AComponent: TComponent); override;

    // create and destroy
    function CreateTimer(Interval: integer; TimerFunc: TWSTimerProc) : THandle; override;
    function DestroyTimer(TimerHandle: THandle) : boolean; override;

    // thread synchronize support
    procedure HandleWakeMainThread(Sender: TObject);
    property DefaultFont: HFONT read FDefaultFont;

    {$I win32winapih.inc}
    {$I win32lclintfh.inc}

    //property MessageFont: HFONT read FMessageFont;
    property CommonControlsVersion: DWord read FCommonControlsVersion;
    property OnAsyncSocketMsg: TSocketEvent read FOnAsyncSocketMsg write FOnAsyncSocketMsg;
    property DotsPatternBitmap: HBitmap read GetDotsPatternBitmap;
  end;

  {$I win32listslh.inc}
  
var
  Win32WidgetSet: TWin32WidgetSet absolute WidgetSet;


const
  BOOL_RESULT: array[Boolean] of String = ('False', 'True');
  ClsName: array[0..6] of char = 'Window'#0;
  ClsHintName: array[0..10] of char = 'HintWindow'#0;
  EditClsName: array[0..4] of char = 'Edit'#0;
  ButtonClsName: array[0..6] of char = 'Button'#0;
  ComboboxClsName: array[0..8] of char = 'ComboBox'#0;
  ListboxClsName: array[0..8] of char = 'LISTBOX'#0;
  TabControlClsName: array[0..15] of char = 'SysTabControl32'#0;
  ListViewClsName: array[0..13] of char = 'SysListView32'#0;

  LCLComboboxClsName: array[0..11] of char = 'LCLComboBox'#0;
  LCLListboxClsName: array[0..10] of char = 'LCLListBox'#0;
  LCLCheckListboxClsName: array[0..15] of char = 'LCLCheckListBox'#0;
  ClsNameW: array[0..6] of WideChar = ('W', 'i', 'n', 'd', 'o', 'w', #0);
  ClsHintNameW: array[0..10] of WideChar = ('H', 'i', 'n', 't', 'W', 'i', 'n', 'd', 'o', 'w', #0);

{$ifdef DEBUG_DOUBLEBUFFER}
var
  CopyBitmapToClipboard: boolean = true;
{$endif}

{ export for widgetset implementation }

function WindowProc(Window: HWnd; Msg: UInt; WParam: Windows.WParam;
    LParam: Windows.LParam): LResult; stdcall;
function CallDefaultWindowProc(Window: HWnd; Msg: UInt; WParam: Windows.WParam;
  LParam: Windows.LParam): LResult;
{$ifdef RedirectDestroyMessages}
function DestroyWindowProc(Window: HWnd; Msg: UInt; WParam: Windows.WParam;
    LParam: Windows.LParam): LResult; stdcall;
{$endif}

implementation

uses
  WsControls,
  Win32Proc,
  Win32WSFactory,
  Win32WSControls,
  Win32WSButtons,
  Win32WSMenus,
  Win32WSStdCtrls,
  Win32WSDialogs,
  Win32Themes,
////////////////////////////////////////////////////
  Win32Extra, LCLMessageGlue;

type
  PProcessEvent = ^TProcessEvent;
  TProcessEvent = record
    Handle: THandle;
    Handler: PEventHandler;
    UserData: PtrInt;
    OnEvent: TChildExitEvent;
  end;

var
  MouseDownCount: Integer;
  MouseDownTime: QWord;
  MouseDownPos: TPoint;
  MouseDownWindow: HWND = 0;
  ComboBoxHandleSizeWindow: HWND = 0;
  IgnoreNextCharWindow: HWND = 0;  // ignore next WM_(SYS)CHAR message
  IgnoreKeyUp: Boolean = True; // ignore KeyUp after application start; issue #30836
  // set to true, if we are redirecting a WM_MOUSEWHEEL message, to prevent recursion
  InMouseWheelRedirection: boolean = false;
  OnClipBoardRequest: TClipboardRequestEvent;

  MMenuItemInfoSize: DWORD; // size depends on windows version;

{$if defined(MSG_DEBUG) or defined(DBG_SendPaintMessage)}
  MessageStackDepth: string = '';
{$endif}

{$I win32listsl.inc}
{$I win32callback.inc}
{$I win32object.inc}
{$I win32winapi.inc}
{$I win32lclintf.inc}

const
  W95_MENUITEMINFO_SIZE = 44;
  
initialization
  { initialize mousedownclick to far before double click time }
  if GetTickCount > 5000 then
    MouseDownTime := GetTickCount - 5000
  else
    MouseDownTime := 0;
  SystemCharSetIsUTF8:=true;

  if (Win32MajorVersion = 4) and (Win32MinorVersion = 0)
  then MMenuItemInfoSize := W95_MENUITEMINFO_SIZE
  else MMenuItemInfoSize := sizeof(MENUITEMINFO);
  
  // Vista with classic theme is buggy with Windows.SetPixel() 
  // http://bugs.freepascal.org/view.php?id=15822
  if WindowsVersion=wvVista then
    IntSetPixel:=@VistaSetPixel
  else
    IntSetPixel:=@Windows.SetPixel;

finalization
  if CurDoubleBuffer.Bitmap <> 0 then
  begin
    Windows.DeleteObject(CurDoubleBuffer.Bitmap);
    CurDoubleBuffer.Bitmap := 0;
  end;
end.

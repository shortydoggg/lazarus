{ This is an autogenerated unit using gobject introspection (gir2pascal). Do not Edit. }
unit LazGModule2;

{$MODE OBJFPC}{$H+}

{$PACKRECORDS C}
{$MODESWITCH DUPLICATELOCALS+}

{$LINKLIB libgmodule-2.0.so.0}
interface
uses
  CTypes, LazGLib2;

const
  GModule2_library = 'libgmodule-2.0.so.0';


type
  TGModuleFlags = Integer;
const
  { GModuleFlags }
  G_MODULE_BIND_LAZY: TGModuleFlags = 1;
  G_MODULE_BIND_LOCAL: TGModuleFlags = 2;
  G_MODULE_BIND_MASK: TGModuleFlags = 3;
type

  PPGModule = ^PGModule;
  PGModule = ^TGModule;

  PPGModuleFlags = ^PGModuleFlags;
  PGModuleFlags = ^TGModuleFlags;
  TGModule = object
    function close: gboolean; cdecl; inline;
    procedure make_resident; cdecl; inline;
    function name: Pgchar; cdecl; inline;
    function symbol(symbol_name: Pgchar; symbol: Pgpointer): gboolean; cdecl; inline;
    function build_path(directory: Pgchar; module_name: Pgchar): Pgchar; cdecl; inline; static;
    function error: Pgchar; cdecl; inline; static;
    function open(file_name: Pgchar; flags: TGModuleFlags): PGModule; cdecl; inline; static;
    function supported: gboolean; cdecl; inline; static;
  end;
  TGModuleCheckInit = function(module: PGModule): Pgchar; cdecl;
  TGModuleUnload = procedure(module: PGModule); cdecl;

function g_module_build_path(directory: Pgchar; module_name: Pgchar): Pgchar; cdecl; external;
function g_module_close(module: PGModule): gboolean; cdecl; external;
function g_module_error: Pgchar; cdecl; external;
function g_module_name(module: PGModule): Pgchar; cdecl; external;
function g_module_open(file_name: Pgchar; flags: TGModuleFlags): PGModule; cdecl; external;
function g_module_supported: gboolean; cdecl; external;
function g_module_symbol(module: PGModule; symbol_name: Pgchar; symbol: Pgpointer): gboolean; cdecl; external;
procedure g_module_make_resident(module: PGModule); cdecl; external;
implementation
function TGModule.close: gboolean; cdecl;
begin
  Result := LazGModule2.g_module_close(@self);
end;

procedure TGModule.make_resident; cdecl;
begin
  LazGModule2.g_module_make_resident(@self);
end;

function TGModule.name: Pgchar; cdecl;
begin
  Result := LazGModule2.g_module_name(@self);
end;

function TGModule.symbol(symbol_name: Pgchar; symbol: Pgpointer): gboolean; cdecl;
begin
  Result := LazGModule2.g_module_symbol(@self, symbol_name, symbol);
end;

function TGModule.build_path(directory: Pgchar; module_name: Pgchar): Pgchar; cdecl;
begin
  Result := LazGModule2.g_module_build_path(directory, module_name);
end;

function TGModule.error: Pgchar; cdecl;
begin
  Result := LazGModule2.g_module_error();
end;

function TGModule.open(file_name: Pgchar; flags: TGModuleFlags): PGModule; cdecl;
begin
  Result := LazGModule2.g_module_open(file_name, flags);
end;

function TGModule.supported: gboolean; cdecl;
begin
  Result := LazGModule2.g_module_supported();
end;

end.
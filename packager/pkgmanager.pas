{
 /***************************************************************************
                            pkgmanager.pas
                            --------------


 ***************************************************************************/

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************

  Author: Mattias Gaertner

  Abstract:
    TPkgManager is the class for the global PkgBoss variable, which controls
    the whole package system in the IDE.
}
unit PkgManager;

{$mode objfpc}{$H+}

interface

{$I ide.inc}

{off $DEFINE VerbosePkgEditDrag}

uses
  {$IFDEF IDE_MEM_CHECK}
  MemCheck,
  {$ENDIF}
  // FCL, LCL
  TypInfo, math, Classes, SysUtils, LCLProc, LazUTF8, Forms, Controls, Dialogs, Menus,
  contnrs, StringHashList, Translations, LResources, ComCtrls,
  // codetools
  CodeToolsConfig, CodeToolManager, CodeCache, CodeToolsStructs, BasicCodeTools,
  FileProcs, CodeTree, Laz2_XMLCfg, lazutf8classes, LazFileUtils, LazFileCache,
  // IDE Interface
  SrcEditorIntf, NewItemIntf, ProjPackIntf, ProjectIntf, PackageIntf, CompOptsIntf,
  MenuIntf, IDEWindowIntf,
  IDEExternToolIntf,
  PropEdits, MacroIntf, LazIDEIntf, IDEMsgIntf,
  // IDE
  IDECmdLine, LazarusIDEStrConsts, IDEProcs, ObjectLists, DialogProcs,
  IDECommands, IDEOptionDefs, EnvironmentOpts, MiscOptions, InputHistory,
  Project, ComponentReg, OldCustomCompDlg, PackageEditor, AddToPackageDlg,
  PackageDefs, PackageLinks, PackageSystem, OpenInstalledPkgDlg,
  PkgGraphExplorer, BrokenDependenciesDlg, CompilerOptions,
  IDETranslations, TransferMacros, BuildLazDialog, NewDialog, FindInFilesDlg,
  IDEDialogs, UnitResources, ProjectInspector, SourceEditor,
  AddFileToAPackageDlg, LazarusPackageIntf, PublishProjectDlg, PkgLinksDlg,
  InterPkgConflictFiles, InstallPkgSetDlg, ConfirmPkgListDlg, NewPkgComponentDlg,
  // bosses
  BaseBuildManager, BasePkgManager, MainBar, MainIntf, MainBase, ModeMatrixOpts;

type
  { TPkgManager }

  TPkgManager = class(TBasePkgManager)
    // events - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // package editor
    function OnPackageEditorAddToProject(Sender: TObject; APackage: TLazPackage;
                                     OnlyTestIfPossible: boolean): TModalResult;
    function OnPackageEditorCompilePackage(Sender: TObject;
                          APackage: TLazPackage;
                          CompileClean, CompileRequired: boolean): TModalResult;
    procedure OnPackageEditorCopyMoveFiles(Sender: TObject);
    function OnPackageEditorCreateFile(Sender: TObject;
                                       Params: TAddToPkgResult): TModalResult;
    function OnPackageEditorCreateMakefile(Sender: TObject;
                                           APackage: TLazPackage): TModalResult;
    function OnPackageEditorCreateFpmakeFile(Sender: TObject;
                                           APackage: TLazPackage): TModalResult;
    function OnPackageEditorDeleteAmbiguousFiles(Sender: TObject;
      {%H-}APackage: TLazPackage; const Filename: string): TModalResult;
    procedure OnPackageEditorDragDropTreeView(Sender, Source: TObject;
      X, Y: Integer);
    function OnPackageEditorDragOverTreeView(Sender, Source: TObject;
      X, Y: Integer; out TargetTVNode: TTreeNode;
      out TargetTVType: TTreeViewInsertMarkType): boolean;
    function OnPackageEditorFindInFiles(Sender: TObject; APackage: TLazPackage
      ): TModalResult;
    function OnPackageEditorInstallPackage(Sender: TObject;
                                           APackage: TLazPackage): TModalResult;
    function OnPackageEditorOpenPackage(Sender: TObject; APackage: TLazPackage): TModalResult;
    function OnPackageEditorOpenPkgFile(Sender: TObject; PkgFile: TPkgFile): TModalResult;
    function OnPackageEditorPublishPackage(Sender: TObject;
      APackage: TLazPackage): TModalResult;
    function OnPackageEditorRevertPackage(Sender: TObject; APackage: TLazPackage
      ): TModalResult;
    function OnPackageEditorSavePackage(Sender: TObject; APackage: TLazPackage;
                                        SaveAs: boolean): TModalResult;
    function OnPackageEditorUninstallPackage(Sender: TObject;
                                           APackage: TLazPackage): TModalResult;
    function OnPackageEditorViewPkgSource(Sender: TObject;
                                          APackage: TLazPackage): TModalResult;
    procedure OnAfterWritePackage(Sender: TObject; Restore: boolean);
    procedure OnBeforeReadPackage(Sender: TObject);
    procedure OnPackageEditorFreeEditor(APackage: TLazPackage);
    procedure OnPackageEditorGetUnitRegisterInfo(Sender: TObject;
                              const AFilename: string; out TheUnitName: string;
                              out HasRegisterProc: boolean);
    function PackageGraphCheckInterPkgFiles(IDEObject: TObject;
                          PkgList: TFPList; out FilesChanged: boolean): boolean;

    // package graph
    function PackageGraphExplorerOpenPackage(Sender: TObject;
                                           APackage: TLazPackage): TModalResult;
    function PackageGraphExplorerOpenProject(Sender: TObject;
                                             AProject: TProject): TModalResult;
    function PackageGraphExplorerUninstallPackage(Sender: TObject;
                                           APackage: TLazPackage): TModalResult;
    procedure PackageGraphAddPackage(Pkg: TLazPackage);
    procedure PackageGraphBeginUpdate(Sender: TObject);
    procedure PackageGraphChangePackageName(APackage: TLazPackage;
                                            const OldName: string);
    procedure PackageGraphDeletePackage(APackage: TLazPackage);
    procedure PackageGraphDependencyModified(ADependency: TPkgDependency);
    procedure PackageGraphEndUpdate(Sender: TObject; GraphChanged: boolean);
    procedure PackageGraphFindFPCUnit(const AUnitName, Directory: string;
                                      var Filename: string);

    // menu
    procedure MainIDEitmPkgOpenPackageFileClick(Sender: TObject);
    procedure MainIDEitmPkgPkgGraphClick(Sender: TObject);
    procedure MainIDEitmPkgEditInstallPkgsClick(Sender: TObject);
    procedure MainIDEitmPkgAddCurFileToPkgClick(Sender: TObject);
    procedure MainIDEitmPkgNewComponentClick(Sender: TObject);
    procedure MainIDEitmPkgOpenPackageOfCurUnitClicked(Sender: TObject);
    procedure MainIDEitmConfigCustomCompsClicked(Sender: TObject);
    procedure MainIDEitmOpenRecentPackageClicked(Sender: TObject);
    procedure MainIDEitmPkgOpenLoadedPackageClicked(Sender: TObject);
    procedure MainIDEitmPkgNewPackageClick(Sender: TObject);
    procedure MainIDEitmPackageLinksClicked(Sender: TObject);

    // component palette
    procedure IDEComponentPaletteOpenPackage(Sender: TObject);
    procedure IDEComponentPaletteOpenUnit(Sender: TObject);

    // source editor
    procedure OnOpenPackageForCurrentSrcEditFile(Sender: TObject);

    // LCL
    procedure OnApplicationIdle(Sender: TObject; var {%H-}Done: Boolean);

    // misc
    procedure GetDependencyOwnerDescription(Dependency: TPkgDependency;
                                            out Description: string);
    procedure GetDependencyOwnerDirectory(Dependency: TPkgDependency;
                                          out Directory: string);
    procedure PackageFileLoaded(Sender: TObject);
    procedure OnCheckInstallPackageList(PkgIDList: TObjectList;
                                     RemoveConflicts: boolean; out Ok: boolean);
    function DoBeforeCompilePackages(aPkgList: TFPList): TModalResult;
    function LoadDependencyList(FirstDependency: TPkgDependency;
                                Quiet: boolean): TModalResult;
    procedure CreateIDEWindow(Sender: TObject; aFormName: string;
                          var AForm: TCustomForm; DoDisableAutoSizing: boolean);
  private
    // helper functions
    FLastLazarusSrcDir: string;
    function DoShowSavePackageAsDialog(APackage: TLazPackage): TModalResult;
    function CheckPackageGraphForCompilation(APackage: TLazPackage;
                                 FirstDependency: TPkgDependency;
                                 const Directory: string;
                                 ShowAbort: boolean): TModalResult;
    function DoGetUnitRegisterInfo(const AFilename: string;
                          out TheUnitName: string; out HasRegisterProc: boolean;
                          IgnoreErrors: boolean): TModalResult;
    procedure SaveAutoInstallDependencies;
    procedure LoadStaticCustomPackages;
    function LoadInstalledPackage(const PackageName: string;
                    AddToAutoInstall: boolean; var Quiet: boolean): TLazPackage;
    procedure LoadAutoInstallPackages;
    procedure AddUnitToProjectMainUsesSection(AProject: TProject;
                                    const AnUnitName, AnUnitInFilename: string);
    // move files
    function CheckDrag(Sender, Source: TObject; X, Y: Integer;
      out SrcFilesEdit, TargetFilesEdit: IFilesEditorInterface;
      out aFileCount, aDependencyCount, aDirectoryCount: integer;
      out TargetTVNode: TTreeNode; out TargetTVType: TTreeViewInsertMarkType
      ): boolean;
    procedure FilesEditDragDrop(Sender, Source: TObject; X, Y: Integer);
    function MoveFiles(TargetFilesEdit, SrcFilesEdit: IFilesEditorInterface;
      TargetDirectory: string): boolean;
    function MoveFiles(TargetFilesEdit, SrcFilesEdit: IFilesEditorInterface;
      IDEFiles: TFPList; TargetDirectory: string): boolean;
    function CopyMoveFiles(Sender: TObject): boolean;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    // initialization and menu
    procedure ConnectMainBarEvents; override;
    procedure ConnectSourceNotebookEvents; override;
    procedure SetupMainBarShortCuts; override;
    procedure SetRecentPackagesMenu; override;
    procedure AddToMenuRecentPackages(const Filename: string);
    procedure SaveSettings; override;
    procedure ProcessCommand(Command: word; var Handled: boolean); override;
    procedure OnSourceEditorPopupMenu(const AddMenuItemProc: TAddMenuItemProc); override;
    procedure TranslateResourceStrings; override;

    // files
    function GetDefaultSaveDirectoryForFile(const Filename: string): string; override;
    function GetPublishPackageDir(APackage: TLazPackage): string;
    function OnRenameFile(const OldFilename, NewFilename: string;
                          IsPartOfProject: boolean): TModalResult; override;
    function FindIncludeFileInProjectDependencies(aProject: TProject;
                          const Filename: string): string; override;
    function GetOwnersOfUnit(const UnitFilename: string): TFPList; override;
    procedure ExtendOwnerListWithUsedByOwners(OwnerList: TFPList); override;
    function GetSourceFilesOfOwners(OwnerList: TFPList): TStrings; override;
    function GetPossibleOwnersOfUnit(const UnitFilename: string;
                                     Flags: TPkgIntfOwnerSearchFlags): TFPList; override;
    function GetPackageOfCurrentSourceEditor(out APackage: TIDEPackage): TPkgFile;
    function GetPackageOfSourceEditor(out APackage: TIDEPackage; ASrcEdit: TObject): TLazPackageFile; override;
    function FindVirtualUnitSource(PkgFile: TPkgFile): string;
    function SearchFile(const AFilename: string;
                        SearchFlags: TSearchIDEFileFlags;
                        InObject: TObject): TPkgFile; override;
    function SearchUnitInDesigntimePackages(const AnUnitName: string;
                        InObject: TObject): TPkgFile; override;
    function ShowFindInPackageFilesDlg(APackage: TLazPackage): TModalResult;

    // package graph
    function AddPackageToGraph(APackage: TLazPackage): TModalResult;
    procedure DoShowPackageGraph(Show: boolean);
    procedure DoShowPackageGraphPathList(PathList: TFPList); override;
    function ShowBrokenDependenciesReport(Dependencies: TFPList): TModalResult;
    function CheckUserSearchPaths(aCompilerOptions: TBaseCompilerOptions): TModalResult; override;
    procedure RebuildDefineTemplates; override;
    procedure LazarusSrcDirChanged; override;
    function GetPackageCount: integer; override;
    function GetPackages(Index: integer): TIDEPackage; override;
    function FindPackageWithName(const PkgName: string; IgnorePackage: TIDEPackage = nil): TIDEPackage; override;
    function IsOwnerDependingOnPkg(AnOwner: TObject; const PkgName: string;
                                   out DependencyOwner: TObject): boolean; override;
    procedure GetRequiredPackages(AnOwner: TObject; out PkgList: TFPList;
                                  Flags: TPkgIntfRequiredFlags = []); override;
    function AddDependencyToOwners(OwnerList: TFPList; APackage: TIDEPackage;
                   OnlyTestIfPossible: boolean = false): TModalResult; override;
    function AddDependencyToUnitOwners(const OwnedFilename,
                              RequiredUnitname: string): TModalResult; override;
    function RedirectPackageDependency(APackage: TIDEPackage): TIDEPackage; override;
    procedure GetPackagesChangedOnDisk(out ListOfPackages: TStringList); override;
    function RevertPackages(APackageList: TStringList): TModalResult; override;

    // project
    function OpenProjectDependencies(AProject: TProject;
                                ReportMissing: boolean): TModalResult; override;
    function CheckProjectHasInstalledPackages(AProject: TProject; 
                                  Interactive: boolean): TModalResult; override;
    function CanOpenDesignerForm(AnUnitInfo: TUnitInfo; 
                                 Interactive: boolean): TModalResult; override;
    function AddProjectDependency(AProject: TProject; APackage: TLazPackage;
                                  OnlyTestIfPossible: boolean = false): TModalResult; override;
    function AddProjectDependency(AProject: TProject;
                                  ADependency: TPkgDependency): TModalResult; override;
    procedure AddProjectRegCompDependency(AProject: TProject;
                          ARegisteredComponent: TRegisteredComponent); override;
    procedure AddProjectLCLDependency(AProject: TProject); override;
    function AddProjectDependencies(AProject: TProject; const Packages: string;
                                  OnlyTestIfPossible: boolean = false): TModalResult; override;
    function OnProjectInspectorAddDependency(Sender: TObject;
                           ADependency: TPkgDependency): TModalResult; override;
    function OnProjectInspectorRemoveDependency(Sender: TObject;
                           ADependency: TPkgDependency): TModalResult; override;
    function OnProjectInspectorReAddDependency(Sender: TObject;
                           ADependency: TPkgDependency): TModalResult; override;
    procedure OnProjectInspectorDragDropTreeView(Sender, Source: TObject;
      X, Y: Integer); override;
    function OnProjectInspectorDragOverTreeView(Sender, Source: TObject;
      X, Y: Integer; out TargetTVNode: TTreeNode;
      out TargetTVType: TTreeViewInsertMarkType): boolean; override;
    procedure OnProjectInspectorCopyMoveFiles(Sender: TObject); override;

    // package editors
    function DoOpenPkgFile(PkgFile: TPkgFile): TModalResult;
    function DoNewPackage: TModalResult; override;
    function DoShowLoadedPkgDlg: TModalResult; override;
    function DoOpenPackage(APackage: TLazPackage; Flags: TPkgOpenFlags;
                           ShowAbort: boolean): TModalResult; override;
    function DoOpenPackageWithName(const APackageName: string;
                         Flags: TPkgOpenFlags; ShowAbort: boolean): TModalResult; override;
    function DoOpenPackageFile(AFilename: string;
                         Flags: TPkgOpenFlags;
                         ShowAbort: boolean): TModalResult; override;
    procedure OpenHiddenModifiedPackages; override;
    function DoSavePackage(APackage: TLazPackage;
                           Flags: TPkgSaveFlags): TModalResult; override;
    function DoSaveAllPackages(Flags: TPkgSaveFlags): TModalResult; override;
    function DoClosePackageEditor(APackage: TLazPackage): TModalResult; override;
    function DoCloseAllPackageEditors: TModalResult; override;
    function DoAddActiveUnitToAPackage: TModalResult;
    function DoNewPackageComponent: TModalResult;
    function SavePackageFiles(APackage: TLazPackage): TModalResult;
    function WarnAboutMissingPackageFiles(APackage: TLazPackage): TModalResult;
    function AddPackageDependency(APackage: TLazPackage; const ReqPackage: string;
                                  OnlyTestIfPossible: boolean = false): TModalResult; override;
    function GetPackageOfEditorItem(Sender: TObject): TIDEPackage; override;

    // package compilation
    function DoCompileProjectDependencies(AProject: TProject;
                               Flags: TPkgCompileFlags): TModalResult; override;
    function DoCompilePackage(APackage: TLazPackage; Flags: TPkgCompileFlags;
                              ShowAbort: boolean): TModalResult; override;
    function DoCreatePackageMakefile(APackage: TLazPackage;
                                     ShowAbort: boolean): TModalResult;
    function DoCreatePackageFpmakefile(APackage: TLazPackage;
                                       ShowAbort: boolean): TModalResult;

    // package installation
    procedure LoadInstalledPackages; override;
    procedure UnloadInstalledPackages;
    function ShowConfigureCustomComponents: TModalResult; override;
    function DoInstallPackage(APackage: TLazPackage): TModalResult;
    function DoUninstallPackage(APackage: TLazPackage;
                   Flags: TPkgUninstallFlags; ShowAbort: boolean): TModalResult;
    function CheckInstallPackageList(PkgIDList: TObjectList;
                          Flags: TPkgInstallInIDEFlags = []
                          ): boolean; override;
    function InstallPackages(PkgIdList: TObjectList;
                             Flags: TPkgInstallInIDEFlags = []): TModalResult; override;
    procedure DoTranslatePackage(APackage: TLazPackage);
    function DoOpenPackageSource(APackage: TLazPackage): TModalResult;
    function DoCompileAutoInstallPackages(Flags: TPkgCompileFlags;
                                          OnlyBase: boolean): TModalResult; override;
    function DoSaveAutoInstallConfig: TModalResult; override;
    function DoPublishPackage(APackage: TLazPackage; Flags: TPkgSaveFlags;
                              ShowDialog: boolean): TModalResult;
                              
    // components
    function AddUnitDependenciesForComponentClasses(const UnitFilename: string;
                         ComponentClassnames: TStrings;
                         Quiet: boolean = false): TModalResult; override;
    function GetMissingDependenciesForUnit(const UnitFilename: string;
                         ComponentClassnames: TStrings;
                         var List: TObjectArray): TModalResult;
    function GetUsableComponentUnits(CurRoot: TPersistent): TFPList; override; // list of TUnitInfo
    procedure IterateComponentNames(CurRoot: TPersistent; TypeData: PTypeData;
                                    Proc: TGetStrProc); override;
    function FindUsableComponent(CurRoot: TPersistent;
                        const ComponentPath: string): TComponent; override;
    function FindReferencedRootComponent(CurRoot: TPersistent; 
         const ComponentName: string): TComponent; override;
  end;


  { TLazPackageDescriptors }

  TLazPackageDescriptors = class(TPackageDescriptors)
  private
    fDestroying: boolean;
    fItems: TFPList; // list of TProjectDescriptor
  protected
    function GetItems(Index: integer): TPackageDescriptor; override;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: integer; override;
    function GetUniqueName(const Name: string): string; override;
    function IndexOf(const Name: string): integer; override;
    function FindByName(const Name: string): TPackageDescriptor; override;
    procedure RegisterDescriptor(Descriptor: TPackageDescriptor); override;
    procedure UnregisterDescriptor(Descriptor: TPackageDescriptor); override;
    procedure AddDefaultPackageDescriptors;
  public
    property Items[Index: integer]: TPackageDescriptor read GetItems; default;
  end;
  
  
  { TPackageDescriptorStd }
  
  TPackageDescriptorStd = class(TPackageDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

var
  LazPackageDescriptors: TLazPackageDescriptors;

implementation

{ TPkgManager }

procedure TPkgManager.MainIDEitmPkgOpenPackageFileClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  AFilename: string;
  I: Integer;
  OpenFlags: TPkgOpenFlags;
begin
  OpenDialog:=TOpenDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    OpenDialog.Title:=lisOpenPackageFile;
    OpenDialog.Options:=OpenDialog.Options+[ofAllowMultiSelect];
    OpenDialog.Filter:=dlgFilterLazarusPackage+' (*.lpk)|*.lpk'
                     +'|'+dlgFilterAll+' ('+FileMask+')|'+FileMask;
    if OpenDialog.Execute and (OpenDialog.Files.Count>0) then begin
      OpenFlags:=[pofAddToRecent];
      For I := 0 to OpenDialog.Files.Count-1 do
        Begin
          AFilename:=CleanAndExpandFilename(OpenDialog.Files.Strings[i]);
          if i<OpenDialog.Files.Count-1 then
            Include(OpenFlags,pofMultiOpen)
          else
            Exclude(OpenFlags,pofMultiOpen);
          if DoOpenPackageFile(AFilename,OpenFlags,true)=mrAbort then begin
            break;
          end;
        end;
    end;
    InputHistories.StoreFileDialogSettings(OpenDialog);
  finally
    OpenDialog.Free;
  end;
end;

procedure TPkgManager.MainIDEitmPkgPkgGraphClick(Sender: TObject);
begin
  DoShowPackageGraph(true);
end;

procedure TPkgManager.MainIDEitmPkgEditInstallPkgsClick(Sender: TObject);
var
  RebuildIDE: Boolean;
  PkgIDList: TObjectList;
  Flags: TPkgInstallInIDEFlags;
begin
  RebuildIDE:=false;
  PkgIDList:=nil;
  try
    if ShowEditInstallPkgsDialog(PackageGraph.FirstAutoInstallDependency,
      @OnCheckInstallPackageList,PkgIDList,RebuildIDE)<>mrOk
    then exit;

    Flags:=[piiifSkipChecks,piiifClear];
    if RebuildIDE then Include(Flags,piiifRebuildIDE);
    InstallPackages(PkgIDList,Flags);
  finally
    PkgIDList.Free;
  end;
end;

procedure TPkgManager.IDEComponentPaletteOpenPackage(Sender: TObject);
begin
  if (Sender=nil) or (not (Sender is TLazPackage)) then exit;
  DoOpenPackage(TLazPackage(Sender),[],false);
end;

procedure TPkgManager.IDEComponentPaletteOpenUnit(Sender: TObject);
var
  PkgComponent: TPkgComponent;
  PkgFile: TPkgFile;
  Filename: String;
begin
  if (Sender=nil) then exit;
  if (Sender is TPkgFile) then
    DoOpenPkgFile(TPkgFile(Sender))
  else if (Sender is TPkgComponent) then begin
    PkgComponent:=TPkgComponent(Sender);
    PkgFile:=PkgComponent.PkgFile;
    if PkgFile=nil then exit;
    Filename:='';
    if PkgFile.FileType=pftVirtualUnit then
      Filename:=FindVirtualUnitSource(PkgFile);
    if Filename='' then
      Filename:=PkgFile.GetFullFilename;
    MainIDE.DoOpenFileAndJumpToIdentifier(
      Filename,PkgComponent.ComponentClass.ClassName,
      -1, -1, // open page somewhere
      [ofOnlyIfExists,ofAddToRecent,ofRegularFile,ofConvertMacros]);
  end;
end;

procedure TPkgManager.GetDependencyOwnerDescription(
  Dependency: TPkgDependency; out Description: string);
begin
  GetDescriptionOfDependencyOwner(Dependency,Description);
end;

procedure TPkgManager.GetDependencyOwnerDirectory(Dependency: TPkgDependency;
  out Directory: string);
begin
  GetDirectoryOfDependencyOwner(Dependency,Directory);
end;

procedure TPkgManager.PackageFileLoaded(Sender: TObject);
begin
  DoCallNotifyHandler(pihtPackageFileLoaded,Sender);
end;

procedure TPkgManager.OnCheckInstallPackageList(PkgIDList: TObjectList;
  RemoveConflicts: boolean; out Ok: boolean);
var
  Flags: TPkgInstallInIDEFlags;
begin
  Flags:=[];
  if RemoveConflicts then
    Include(Flags,piiifRemoveConflicts);
  Ok:=CheckInstallPackageList(PkgIDList,Flags);
  if Ok then
    SaveAutoInstallDependencies;
end;

function TPkgManager.DoBeforeCompilePackages(aPkgList: TFPList): TModalResult;
// called before a bunch of packages are compiled

  function GetIgnorePkgOutDirID(CurPkg: TLazPackage): string;
  begin
    Result:='PkgOutDir#'+CurPkg.Filename+':'+CurPkg.GetOutputDirectory;
  end;

var
  PkgWithProjOverriddenOutDirs: TFPList;
  i: Integer;
  CurPkg: TLazPackage;
  OutDir: String;
  IgnoreItem: TIgnoreIDEQuestionItem;
  s: String;
begin
  Result:=mrOk;
  if MainIDEBar=nil then exit; // not interactive
  if InputHistories=nil then exit;

  if not Assigned(OnGetOutputDirectoryOverride) then exit;
  PkgWithProjOverriddenOutDirs:=TFPList.Create;
  try
    for i:=0 to aPkgList.Count-1 do
    begin
      CurPkg:=TLazPackage(aPkgList[i]);
      OutDir:='';
      OnGetOutputDirectoryOverride(CurPkg,OutDir,[bmgtProject,bmgtSession]);
      if OutDir<>'' then begin
        IgnoreItem:=InputHistories.Ignores.Find(GetIgnorePkgOutDirID(CurPkg));
        if (IgnoreItem=nil) then
          PkgWithProjOverriddenOutDirs.Add(CurPkg);
      end;
    end;
    if PkgWithProjOverriddenOutDirs.Count>0 then
    begin
      s:='';
      for i:=0 to PkgWithProjOverriddenOutDirs.Count-1 do begin
        CurPkg:=TLazPackage(PkgWithProjOverriddenOutDirs[i]);
        OutDir:=CreateRelativePath(CurPkg.GetOutputDirectory,CurPkg.Directory);
        s+=CurPkg.Name+': '+OutDir+LineEnding;
      end;
      if IDEMessageDialog(lisConfirmation,
        Format(lisPkgTheProjectOverridesTheOutputDirectoryOfTheFollowin,
               [LineEnding, LineEnding+LineEnding, s]),
        mtWarning, [mbOk, mbCancel])<>mrOk
      then
        exit(mrCancel);
      // remember the answer
      for i:=0 to PkgWithProjOverriddenOutDirs.Count-1 do begin
        CurPkg:=TLazPackage(PkgWithProjOverriddenOutDirs[i]);
        InputHistories.Ignores.Add(GetIgnorePkgOutDirID(CurPkg),iiidForever);
      end;
    end;
  finally
    PkgWithProjOverriddenOutDirs.Free;
  end;
end;

function TPkgManager.LoadDependencyList(FirstDependency: TPkgDependency;
  Quiet: boolean): TModalResult;
var
  CurDependency: TPkgDependency;
  OpenResult: TLoadPackageResult;
begin
  Result:=mrCancel;
  // load all packages
  CurDependency:=FirstDependency;
  while CurDependency<>nil do begin
    OpenResult:=PackageGraph.OpenDependency(CurDependency,false);
    if OpenResult<>lprSuccess then begin
      if not Quiet then
        IDEMessageDialog(lisCCOErrorCaption,
          Format(lisUnableToLoadPackage, [CurDependency.AsString]),
          mtError,[mbCancel]);
      exit;
    end;
    CurDependency:=CurDependency.NextRequiresDependency;
  end;
  Result:=mrOk;
end;

procedure TPkgManager.OnOpenPackageForCurrentSrcEditFile(Sender: TObject);
var
  APackage: TIDEPackage;
begin
  GetPackageOfCurrentSourceEditor(APackage);
  if APackage is TLazPackage then
    DoOpenPackage(TLazPackage(APackage),[],false);
end;

procedure TPkgManager.CreateIDEWindow(Sender: TObject; aFormName: string; var
  AForm: TCustomForm; DoDisableAutoSizing: boolean);
var
  APackageName: String;
  NewDependency: TPkgDependency;
  APackage: TLazPackage;
  LoadResult: TLoadPackageResult;
begin
  //debugln(['TPkgManager.CreateIDEWindow ',aFormName]);
  if SysUtils.CompareText(aFormName,NonModalIDEWindowNames[nmiwPkgGraphExplorer])=0
  then begin
    DoShowPackageGraph(false);
    AForm:=PackageGraphExplorer;
    if DoDisableAutoSizing then
      AForm.DisableAutoSizing{$IFDEF DebugDisableAutoSizing}('TPkgManager.CreateIDEWindow'){$ENDIF};
  end else if SysUtils.CompareText(PackageEditorWindowPrefix,
    copy(aFormName,1,length(PackageEditorWindowPrefix)))=0
  then begin
    APackageName:=copy(aFormName,length(PackageEditorWindowPrefix)+1,length(aFormName));
    if not IsValidPkgName(APackageName) then exit;
    NewDependency:=TPkgDependency.Create;
    try
      NewDependency.PackageName:=APackageName;
      LoadResult:=PackageGraph.OpenDependency(NewDependency,false);
      if LoadResult<>lprSuccess then exit;
    finally
      NewDependency.Free;
    end;
    APackage:=PackageGraph.FindPackageWithName(APackageName,nil);
    if APackage=nil then exit;
    AForm:=PackageEditors.CreateEditor(APackage,DoDisableAutoSizing);
  end;
end;

procedure TPkgManager.MainIDEitmPkgAddCurFileToPkgClick(Sender: TObject);
begin
  DoAddActiveUnitToAPackage;
end;

procedure TPkgManager.MainIDEitmPkgNewComponentClick(Sender: TObject);
begin
  DoNewPackageComponent;
end;

procedure TPkgManager.MainIDEitmPkgOpenPackageOfCurUnitClicked(Sender: TObject);
var
  ActiveSourceEditor: TSourceEditorInterface;
  ActiveUnitInfo: TUnitInfo;
  PkgFile: TPkgFile;
begin
  MainIDE.GetCurrentUnitInfo(ActiveSourceEditor,ActiveUnitInfo);
  if ActiveSourceEditor=nil then exit;
  PkgFile:=PackageGraph.FindFileInAllPackages(ActiveUnitInfo.Filename,true,
                                            not ActiveUnitInfo.IsPartOfProject);
  if PkgFile=nil then
    IDEMessageDialog(lisProjAddPackageNotFound,
        lisPkgThisFileIsNotInAnyLoadedPackage, mtInformation, [mbCancel])
  else
    DoOpenPackageFile(PkgFile.LazPackage.Filename,[pofAddToRecent],false);
end;

procedure TPkgManager.OnAfterWritePackage(Sender: TObject; Restore: boolean);
begin
  //debugln(['TPkgManager.OnAfterWritePackage ',DbgSName(APackage),' Restore=',Restore]);
  if Restore then
    (Sender as TPackageIDEOptions).Package.RestoreOptions;
end;

procedure TPkgManager.OnBeforeReadPackage(Sender: TObject);
begin
  //debugln(['TPkgManager.OnBeforeReadPackage ',DbgSName(APackage)]);
  (Sender as TPackageIDEOptions).Package.BackupOptions;
end;

function TPkgManager.OnPackageEditorCompilePackage(Sender: TObject;
  APackage: TLazPackage; CompileClean, CompileRequired: boolean): TModalResult;
var
  Flags: TPkgCompileFlags;
begin
  Flags:=[];
  if CompileClean then Include(Flags,pcfCleanCompile);
  if CompileRequired then Include(Flags,pcfCompileDependenciesClean);
  //debugln('TPkgManager.OnPackageEditorCompilePackage OS=',Globals.TargetOS);
  Result:=DoCompilePackage(APackage,Flags,false);
end;

procedure TPkgManager.OnPackageEditorCopyMoveFiles(Sender: TObject);
begin
  CopyMoveFiles(Sender);
end;

function TPkgManager.OnPackageEditorCreateMakefile(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoCreatePackageMakefile(APackage,false);
end;

function TPkgManager.OnPackageEditorCreateFpmakeFile(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoCreatePackageFpmakefile(APackage,false);
end;

function TPkgManager.OnPackageEditorCreateFile(Sender: TObject;
  Params: TAddToPkgResult): TModalResult;
var
  LE: String;
  UsesLine: String;
  NewSource: String;
  UnitDirectives: String;
  IconLRSFilename: String;
  BinFileStream: TFileStreamUTF8;
  BinMemStream: TMemoryStream;
  BinExt: String;
  ResType: String;
  ResName: String;
  ResMemStream: TMemoryStream;
  CodeBuf: TCodeBuffer;
begin
  Result:=mrCancel;

  // create icon resource
  IconLRSFilename:='';
  if Params.IconFile<>'' then begin
    IconLRSFilename:=ChangeFileExt(Params.UnitFilename,'')+'_icon.lrs';
    CodeBuf:=CodeToolBoss.CreateFile(IconLRSFilename);
    if CodeBuf=nil then begin
      debugln(['Error: (lazarus) [TPkgManager.OnPackageEditorCreateFile] file create failed: ',IconLRSFilename]);
      exit;
    end;
    try
      BinFileStream:=TFileStreamUTF8.Create(Params.IconFile,fmOpenRead);
      try
        BinMemStream:=TMemoryStream.Create;
        ResMemStream:=TMemoryStream.Create;
        try
          BinMemStream.CopyFrom(BinFileStream,BinFileStream.Size);
          BinMemStream.Position:=0;
          BinExt:=uppercase(ExtractFileExt(Params.IconFile));
          ResType:=copy(BinExt,2,length(BinExt)-1);
          ResName:=ExtractFileNameOnly(Params.NewClassName);
          BinaryToLazarusResourceCode(BinMemStream,ResMemStream,ResName,ResType);
          ResMemStream.Position:=0;
          CodeBuf.LoadFromStream(ResMemStream);
          Result:=SaveCodeBuffer(CodeBuf);
          if Result<>mrOk then exit;
        finally
          BinMemStream.Free;
          ResMemStream.Free;
        end;
      finally
        BinFileStream.Free;
      end;
    except
      on E: Exception do begin
        MessageDlg(lisCCOErrorCaption,
          Format(lisErrorLoadingFile2,[Params.IconFile]) + LineEnding + E.Message,
        mtError, [mbCancel], 0);
      end;
    end;
  end;

  // create sourcecode
  LE:=LineEnding;
  if PackageGraph.FindDependencyRecursively(Params.Pkg.FirstRequiredDependency,
    'LCL')<>nil
  then
    UsesLine:='Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs'
  else
    UsesLine:='Classes, SysUtils';
  if (System.Pos(Params.UsedUnitname,UsesLine)<1)
  and (Params.UsedUnitname<>'') then
    UsesLine:=UsesLine+', '+Params.UsedUnitname;
  UnitDirectives:='{$mode objfpc}{$H+}';
  if Params.Pkg<>nil then
    UnitDirectives:=TFileDescPascalUnit.CompilerOptionsToUnitDirectives(
                                                    Params.Pkg.CompilerOptions);

  NewSource:=
     'unit '+Params.Unit_Name+';'+LE
    +LE
    +UnitDirectives+LE
    +LE
    +'interface'+LE
    +LE
    +'uses'+LE
    +'  '+UsesLine+';'+LE
    +LE
    +'type'+LE
    +'  '+Params.NewClassName+' = class('+Params.AncestorType+')'+LE
    +'  private'+LE
    +'    { Private declarations }'+LE
    +'  protected'+LE
    +'    { Protected declarations }'+LE
    +'  public'+LE
    +'    { Public declarations }'+LE
    +'  published'+LE
    +'    { Published declarations }'+LE
    +'  end;'+LE
    +LE
    +'procedure Register;'+LE
    +LE
    +'implementation'+LE
    +LE
    +'procedure Register;'+LE
    +'begin'+LE;
  if IconLRSFilename<>'' then
    NewSource:=NewSource
      +'  {$I '+ExtractFileName(IconLRSFilename)+'}'+LE;
  NewSource:=NewSource
    +'  RegisterComponents('''+Params.PageName+''',['+Params.NewClassName+']);'+LE
    +'end;'+LE
    +LE
    +'end.'+LE;

  FileDescriptorUnit.Owner:=Params.Pkg;
  try
    Result:=MainIDE.DoNewEditorFile(FileDescriptorUnit,
       Params.UnitFilename,NewSource,
       [nfOpenInEditor,nfIsNotPartOfProject,nfSave,nfAddToRecent]);
  finally
    FileDescriptorUnit.Owner:=nil;
  end;
end;

function TPkgManager.OnPackageEditorDeleteAmbiguousFiles(Sender: TObject;
  APackage: TLazPackage; const Filename: string): TModalResult;
begin
  Result:=BuildBoss.DeleteAmbiguousFiles(Filename);
end;

procedure TPkgManager.OnPackageEditorDragDropTreeView(Sender, Source: TObject;
  X, Y: Integer);
begin
  FilesEditDragDrop(Sender, Source, X, Y);
end;

function TPkgManager.OnPackageEditorDragOverTreeView(Sender, Source: TObject;
  X, Y: Integer; out TargetTVNode: TTreeNode;
  out TargetTVType: TTreeViewInsertMarkType): boolean;
var
  aFileCount: integer;
  aDependencyCount: integer;
  aDirectoryCount: integer;
  TargetFilesEdit: IFilesEditorInterface;
  SrcFilesEdit: IFilesEditorInterface;
begin
  Result:=CheckDrag(Sender, Source, X, Y, TargetFilesEdit, SrcFilesEdit, aFileCount,
    aDependencyCount, aDirectoryCount, TargetTVNode, TargetTVType);
end;

function TPkgManager.OnPackageEditorFindInFiles(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=ShowFindInPackageFilesDlg(APackage);
end;

function TPkgManager.OnPackageEditorAddToProject(Sender: TObject;
  APackage: TLazPackage; OnlyTestIfPossible: boolean): TModalResult;
begin
  Result:=AddProjectDependency(Project1,APackage,OnlyTestIfPossible);
end;

function TPkgManager.OnPackageEditorInstallPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoInstallPackage(APackage);
end;

function TPkgManager.OnPackageEditorPublishPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoPublishPackage(APackage,[],true);
end;

function TPkgManager.OnPackageEditorRevertPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  if (not FilenameIsAbsolute(APackage.Filename))
  or (not FileExistsUTF8(APackage.Filename)) then
    exit(mrCancel);
  Result:=DoOpenPackageFile(APackage.Filename,[pofRevert],false);
end;

function TPkgManager.OnPackageEditorUninstallPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoUninstallPackage(APackage,[],false);
end;

function TPkgManager.OnPackageEditorOpenPkgFile(Sender: TObject;
  PkgFile: TPkgFile): TModalResult;
begin
  Result:=DoOpenPkgFile(PkgFile);
end;

procedure TPkgManager.OnPackageEditorFreeEditor(APackage: TLazPackage);
begin
  APackage.Editor:=nil;
  PackageGraph.ClosePackage(APackage);
end;

procedure TPkgManager.OnPackageEditorGetUnitRegisterInfo(Sender: TObject;
  const AFilename: string; out TheUnitName: string; out HasRegisterProc: boolean
  );
begin
  DoGetUnitRegisterInfo(AFilename,TheUnitName,HasRegisterProc,true);
end;

function TPkgManager.PackageGraphCheckInterPkgFiles(IDEObject: TObject;
  PkgList: TFPList; out FilesChanged: boolean): boolean;
begin
  Result:=CheckInterPkgFiles(IDEObject,PkgList,FilesChanged);
end;

function TPkgManager.OnPackageEditorOpenPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoOpenPackage(APackage,[],false);
end;

function TPkgManager.OnPackageEditorSavePackage(Sender: TObject;
  APackage: TLazPackage; SaveAs: boolean): TModalResult;
begin
  if SaveAs then
    Result:=DoSavePackage(APackage,[psfSaveAs])
  else
    Result:=DoSavePackage(APackage,[]);
end;

function TPkgManager.OnPackageEditorViewPkgSource(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoOpenPackageSource(APackage);
end;

procedure TPkgManager.PackageGraphBeginUpdate(Sender: TObject);
begin
  if PackageGraphExplorer<>nil then PackageGraphExplorer.BeginUpdate;
end;

procedure TPkgManager.PackageGraphChangePackageName(APackage: TLazPackage;
  const OldName: string);
begin
  if PackageGraphExplorer<>nil then
    PackageGraphExplorer.UpdatePackageName(APackage,OldName);
end;

procedure TPkgManager.PackageGraphDeletePackage(APackage: TLazPackage);
begin
  if APackage.Editor<>nil then begin
    APackage.Editor.Hide;
    APackage.Editor.Free;
  end;
end;

procedure TPkgManager.PackageGraphDependencyModified(ADependency: TPkgDependency);
var
  DepOwner: TObject;
begin
  DepOwner:=ADependency.Owner;
  if DepOwner is TLazPackage then
    TLazPackage(DepOwner).Modified:=true
  else if DepOwner is TProject then
    TProject(DepOwner).Modified:=true;
end;

function TPkgManager.PackageGraphExplorerOpenPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoOpenPackage(APackage,[pofAddToRecent],false);
end;

function TPkgManager.PackageGraphExplorerOpenProject(Sender: TObject;
  AProject: TProject): TModalResult;
begin
  if AProject<>Project1 then exit(mrCancel);
  MainIDE.DoShowProjectInspector;
  Result:=mrOk;
end;

procedure TPkgManager.PackageGraphAddPackage(Pkg: TLazPackage);
begin
  if FileExistsUTF8(Pkg.FileName) then PkgLinks.AddUserLink(Pkg);
  if PackageGraphExplorer<>nil then
    PackageGraphExplorer.UpdatePackageAdded(Pkg);
end;

procedure TPkgManager.PackageGraphEndUpdate(Sender: TObject;
  GraphChanged: boolean);
begin
  if GraphChanged then IncreaseCompilerParseStamp;
  if PackageGraphExplorer<>nil then begin
    if GraphChanged then PackageGraphExplorer.UpdateAll;
    PackageGraphExplorer.EndUpdate;
  end;
  if GraphChanged then begin
    if PackageEditors<>nil then
      PackageEditors.UpdateAllEditors(false);
    if ProjInspector<>nil then
      ProjInspector.UpdateRequiredPackages;
    DoCallNotifyHandler(pihtGraphChanged,Self);
  end;
end;

procedure TPkgManager.PackageGraphFindFPCUnit(const AUnitName,
  Directory: string; var Filename: string);
begin
  if (Directory<>'') and not FilenameIsAbsolute(Directory) then
    RaiseGDBException(Directory);
  //DebugLn('TPkgManager.PackageGraphFindFPCUnit "',Directory,'"');
  Filename:=CodeToolBoss.DirectoryCachePool.FindUnitInUnitLinks(Directory,
                                                                AUnitName);
end;

function TPkgManager.PackageGraphExplorerUninstallPackage(Sender: TObject;
  APackage: TLazPackage): TModalResult;
begin
  Result:=DoUninstallPackage(APackage,[],false);
end;

procedure TPkgManager.MainIDEitmConfigCustomCompsClicked(Sender: TObject);
begin
  ShowConfigureCustomComponents;
end;

procedure TPkgManager.MainIDEitmPkgNewPackageClick(Sender: TObject);
begin
  DoNewPackage;
end;

procedure TPkgManager.MainIDEitmPkgOpenLoadedPackageClicked(Sender: TObject);
begin
  DoShowLoadedPkgDlg;
end;

procedure TPkgManager.MainIDEitmPackageLinksClicked(Sender: TObject);
begin
  ShowPackageLinks;
end;

procedure TPkgManager.MainIDEitmOpenRecentPackageClicked(Sender: TObject);

  procedure UpdateEnvironment;
  begin
    SetRecentPackagesMenu;
    MainIDE.SaveEnvironment;
  end;

var
  AFilename: string;
begin
  AFileName:=ExpandFileNameUTF8((Sender as TIDEMenuItem).Caption);
  if DoOpenPackageFile(AFilename,[pofAddToRecent],false)=mrOk then begin
    UpdateEnvironment;
  end else begin
    // open failed
    if not FileExistsUTF8(AFilename) then begin
      // file does not exist -> delete it from recent file list
      RemoveFromRecentList(AFilename,EnvironmentOptions.RecentPackageFiles,rltFile);
      UpdateEnvironment;
    end;
  end;
end;

procedure TPkgManager.OnApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  if PackageGraph = nil then Exit;
  if MainIDE.ToolStatus<>itNone then exit;
  if (Screen.ActiveCustomForm<>nil)
  and (fsModal in Screen.ActiveCustomForm.FormState) then exit;
  PackageGraph.CloseUnneededPackages;
end;

function TPkgManager.DoShowSavePackageAsDialog(
  APackage: TLazPackage): TModalResult;
var
  OldPkgFilename: String;
  SaveDialog: TSaveDialog;
  NewFileName: String;
  NewPkgName: String;
  ConflictPkg: TLazPackage;
  PkgFile: TPkgFile;
  LowerFilename: String;
  BrokenDependencies: TFPList;
  RenameDependencies: Boolean;
  OldPkgName: String;
  NewMainUnitFileName: String;
  
  procedure RenamePackageInProject;
  var
    AProject: TProject;
    OldUnitName: String;
    NewUnitName: String;
  begin
    AProject:=Project1;
    if (pfMainUnitIsPascalSource in AProject.Flags)
    and (AProject.MainUnitInfo<>nil) then begin
      OldUnitName:=OldPkgName;
      NewUnitName:=APackage.Name;
      if (OldUnitName<>NewUnitName) then begin
        MainIDEInterface.SaveSourceEditorChangesToCodeCache(nil);
        if CodeToolBoss.RenameUsedUnit(
          AProject.MainUnitInfo.Source,OldUnitName,NewUnitName,'')
        then
          AProject.MainUnitInfo.Modified:=true;
      end;
    end;
  end;
  
begin
  OldPkgFilename:=APackage.Filename;
  OldPkgName:=APackage.Name;

  SaveDialog:=TSaveDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(SaveDialog);
    SaveDialog.Title:=Format(lisPkgMangSavePackageLpk, [APackage.IDAsString]);
    SaveDialog.Filter:=dlgFilterLazarusPackage+' (*.lpk)|*.lpk'
                     +'|'+dlgFilterAll+' ('+FileMask+')|'+FileMask;
    if APackage.HasDirectory then
      SaveDialog.InitialDir:=APackage.Directory;

    // build a nice package filename suggestion
    NewFileName:=APackage.Name+'.lpk';
    SaveDialog.FileName:=NewFileName;

    repeat
      Result:=mrCancel;

      if not SaveDialog.Execute then begin
        // user cancels
        Result:=mrCancel;
        exit;
      end;
      NewFileName:=CleanAndExpandFilename(SaveDialog.Filename);
      NewPkgName:=ExtractFileNameOnly(NewFilename);
      if APackage.MainUnitHasPkgName then
        NewMainUnitFileName:=ChangeFileExt(NewFileName,'.pas')
      else
        NewMainUnitFileName:='';

      if PackageEditors.FindEditor(NewPkgName) <> nil then
      begin
        Result:=IDEMessageDialog(lisPkgMangInvalidPackageName,
          Format(lisPkgMangSaveAsAlreadyOpenedPackage, [NewPkgName]),
          mtInformation,[mbRetry,mbAbort]);
        if Result=mrAbort then exit;
        continue; // try again
      end;
      
      // check file extension
      if ExtractFileExt(NewFilename)='' then begin
        // append extension
        NewFileName:=NewFileName+'.lpk';
      end else if ExtractFileExt(NewFilename)<>'.lpk' then begin
        Result:=IDEMessageDialog(lisPkgMangInvalidPackageFileExtension,
          lisPkgMangPackagesMustHaveTheExtensionLpk,
          mtInformation,[mbRetry,mbAbort]);
        if Result=mrAbort then exit;
        continue; // try again
      end;

      // check filename
      if not IsValidPkgName(NewPkgName) then begin
        Result:=IDEMessageDialog(lisPkgMangInvalidPackageName,
          Format(lisPkgMangThePackageNameIsNotAValidPackageNamePleaseChooseAn,
                 [NewPkgName, LineEnding]),
          mtInformation,[mbRetry,mbAbort]);
        if Result=mrAbort then exit;
        continue; // try again
      end;

      // apply naming conventions
      
      if lowercase(NewPkgName) <> NewPkgName then
      begin
        LowerFilename:=ExtractFilePath(NewFilename)+lowercase(ExtractFileName(NewFilename));
        if EnvironmentOptions.CharcaseFileAction = ccfaAsk then
        begin
          if IDEMessageDialog(lisPkgMangRenameFileLowercase,
            Format(lisPkgMangShouldTheFileRenamedLowercaseTo,[LineEnding, LowerFilename]),
            mtConfirmation,[mbYes,mbNo])=mrYes
          then
            NewFileName:=LowerFilename;
        end
        else
        begin
          if EnvironmentOptions.CharcaseFileAction = ccfaAutoRename then NewFileName:=LowerFilename;
        end;
      end;

      // check unit name conflict
      if NewMainUnitFileName<>'' then
      begin
        PkgFile:=APackage.FindUnit(NewPkgName);
        if PkgFile<>nil then begin
          Result:=IDEMessageDialog(lisNameConflict,
            lisThePackageAlreadyContainsAUnitWithThisName,
            mtWarning,[mbRetry,mbAbort]);
          if Result=mrAbort then exit;
          continue; // try again
        end;
      end;

      // check package name conflict
      ConflictPkg:=PackageGraph.FindPackageWithName(NewPkgName,APackage);
      if ConflictPkg<>nil then begin
        Result:=IDEMessageDialog(lisPkgMangPackageNameAlreadyExists,
          Format(lisPkgMangThereIsAlreadyAnotherPackageWithTheName,
            [NewPkgName, LineEnding, ConflictPkg.IDAsString, LineEnding, ConflictPkg.Filename]),
          mtInformation,[mbRetry,mbAbort,mbIgnore]);
        if Result=mrAbort then exit;
        if Result<>mrIgnore then continue; // try again
      end;
      
      // check file name conflict with project
      if (NewMainUnitFileName<>'')
      and (Project1.ProjectUnitWithFilename(NewMainUnitFileName)<>nil) then begin
        Result:=IDEMessageDialog(lisPkgMangFilenameIsUsedByProject,
          Format(lisPkgMangTheFileNameIsPartOfTheCurrentProject,[NewFilename,LineEnding]),
          mtInformation,[mbRetry,mbAbort]);
        if Result=mrAbort then exit;
        continue; // try again
      end;
      
      // check file name conflicts with files in other packages
      if (NewMainUnitFileName<>'') then
      begin
        PkgFile:=PackageGraph.FindFileInAllPackages(NewMainUnitFileName,true,false);
        if PkgFile<>nil then begin
          Result:=IDEMessageDialog(lisPkgMangFilenameIsUsedByOtherPackage,
            Format(lisPkgMangTheFileNameIsUsedByThePackageInFile, [NewFilename, LineEnding,
                   PkgFile.LazPackage.IDAsString, LineEnding, PkgFile.LazPackage.Filename]),
            mtWarning,[mbRetry,mbAbort]);
          if Result=mrAbort then exit;
          continue; // try again
        end;
      end;

      // check for broken dependencies
      BrokenDependencies:=PackageGraph.GetBrokenDependenciesWhenChangingPkgID(
        APackage,NewPkgName,APackage.Version);
      RenameDependencies:=false;
      try
        if BrokenDependencies.Count>0 then begin
          Result:=ShowBrokenDependencies(BrokenDependencies);
          if Result=mrOK then             // = Yes
            RenameDependencies:=true
          else if Result<>mrClose then    // <> Ignore
            exit;
        end;
      finally
        BrokenDependencies.Free;
      end;
      
      // check existing file
      if (CompareFilenames(NewFileName,OldPkgFilename)<>0) then
      begin
        if FileExistsUTF8(NewFileName) then begin
          Result:=IDEMessageDialog(lisPkgMangReplaceFile,
            Format(lisPkgMangReplaceExistingFile, [NewFilename]),
            mtConfirmation,[mbOk,mbCancel]);
          if Result<>mrOk then exit;
        end;
        if FileExistsUTF8(NewMainUnitFileName) then
        begin
          Result:=IDEMessageDialog(lisPkgMangReplaceFile,
            Format(lisPkgMangReplaceExistingFile, [NewFilename]),
            mtConfirmation,[mbOk,mbCancel]);
          if Result<>mrOk then exit;
        end;
      end;

      // check if new file is read/writable
      Result:=CheckCreatingFile(NewFileName,true);
      if Result=mrAbort then exit;

    until Result<>mrRetry;
  finally
    InputHistories.StoreFileDialogSettings(SaveDialog);
    SaveDialog.Free;
  end;
  
  // set filename
  APackage.Filename:=NewFilename;
  if Assigned(APackage.Editor) then
    APackage.Editor.LazPackage := APackage;//force package editor name change!
  
  // rename package
  PackageGraph.ChangePackageID(APackage,NewPkgName,APackage.Version,
                               RenameDependencies,true);
  SaveAutoInstallDependencies;
  RenamePackageInProject;

  //update LastOpenPackages list
  EnvironmentOptions.LastOpenPackages.Remove(OldPkgFilename);
  EnvironmentOptions.LastOpenPackages.Add(NewFileName);
  MainIDE.SaveEnvironment;

  // clean up old package file to reduce ambiguousities
  if FileExistsUTF8(OldPkgFilename)
  and (CompareFilenames(OldPkgFilename,NewFilename)<>0) then begin
    if IDEMessageDialog(lisPkgMangDeleteOldPackageFile,
      Format(lisPkgMangDeleteOldPackageFile2, [OldPkgFilename]),
      mtConfirmation,[mbYes,mbNo])=mrYes
    then begin
      if DeleteFileUTF8(OldPkgFilename) then begin
        RemoveFromRecentList(OldPkgFilename,
                             EnvironmentOptions.RecentPackageFiles,rltFile);
      end else begin
        IDEMessageDialog(lisPkgMangDeleteFailed,
          Format(lisPkgMangUnableToDeleteFile, [OldPkgFilename]), mtError, [mbOk]);
      end;
    end;
  end;

  // success
  Result:=mrOk;
end;

function TPkgManager.CheckPackageGraphForCompilation(APackage: TLazPackage;
  FirstDependency: TPkgDependency; const Directory: string; ShowAbort: boolean
  ): TModalResult;
var
  PathList: TFPList;
  Dependency: TPkgDependency;
  PkgFile1,PkgFile2: TPkgFile;
  ConflictPkg: TLazPackage;
  s: String;
  Btns: TMsgDlgButtons;
  PkgList: TFPList;
  i: Integer;
begin
  {$IFDEF VerbosePkgCompile}
  debugln('TPkgManager.CheckPackageGraphForCompilation A');
  {$ENDIF}
  if ShowAbort
  then Btns := [mbCancel] // will be replaced to Ignore
  else Btns := [mbOK];
  PathList:=nil;
  PkgList:=nil;
  try
    // check for unsaved packages
    PathList:=PackageGraph.FindUnsavedDependencyPath(APackage,FirstDependency);
    if PathList<>nil then begin
      DoShowPackageGraphPathList(PathList);
      Result:=IDEMessageDialogAb(lisPkgMangUnsavedPackage,
        lisPkgMangThereIsAnUnsavedPackageInTheRequiredPackages,
        mtError,[mbCancel],ShowAbort);
      exit;
    end;

    // check for broken dependencies
    PathList:=PackageGraph.FindBrokenDependencyPath(APackage,FirstDependency);
    if PathList<>nil then begin
      if (PathList.Count=1) then begin
        Dependency:=TPkgDependency(PathList[0]);
        if Dependency is TPkgDependency then begin
          // check if project
          if Dependency.Owner is TProject then begin
            MainIDE.DoShowProjectInspector;
            Result:=IDEMessageDialogAb(lisPkgMangBrokenDependency,
              Format(lisPkgMangTheProjectRequiresThePackageButItWasNotFound,
                    [Dependency.AsString, LineEnding]),
              mtError,Btns,ShowAbort);
            if not ShowAbort then
              Result := mrCancel; // User confirmed error, implicitly cancel the action
            exit;
          end;
        end;
      end;
      DoShowPackageGraphPathList(PathList);
      Result:=IDEMessageDialogAb(lisPkgMangBrokenDependency,
        lisPkgMangRequiredPackagesWereNotFound,
        mtError,Btns,ShowAbort);
      if not ShowAbort then
        Result := mrCancel; // User confirmed error, implicitly cancel the action
      exit;
    end;

    // check for cycle dependencies
    PathList:=PackageGraph.FindCycleDependencyPath(APackage,FirstDependency);
    if PathList<>nil then begin
      DoShowPackageGraphPathList(PathList);
      Result:=IDEMessageDialogAb(lisPkgMangCircularDependencies,
        lisPkgMangThereIsACircularDependency,
        mtError,Btns,ShowAbort);
      if not ShowAbort then
        Result := mrCancel; // User confirmed error, implicitly cancel the action
      exit;
    end;

    // check for all used package with wrong
    PackageGraph.GetAllRequiredPackages(APackage,FirstDependency,PkgList);
    if (PkgList<>nil) then begin
      for i:=0 to PkgList.Count-1 do begin
        Result:=CheckUserSearchPaths(TLazPackage(PkgList[i]).CompilerOptions);
        if Result<>mrOk then
          exit(mrCancel);
      end;
    end;

    // check for a package that compiles to the default FPC search path
    PathList:=PackageGraph.FindPkgOutputInFPCSearchPath(APackage,FirstDependency);
    if PathList<>nil then begin
      ConflictPkg:=TObject(PathList[PathList.Count-1]) as TLazPackage;
      DoShowPackageGraphPathList(PathList);
      Result:=IDEMessageDialogAb(lisPkgMangCircularDependencies,
        Format(lisPkgMangThePackageIsCompiledAutomaticallyAndItsOutputDirec,
          [ConflictPkg.Name, ConflictPkg.GetOutputDirectory, LineEnding+LineEnding, LineEnding]),
        mtError,Btns,ShowAbort);
      if not ShowAbort then
        Result := mrCancel; // User confirmed error, implicitly cancel the action
      exit;
    end;

    // check for ambiguous units between packages
    if PackageGraph.FindAmbiguousUnits(APackage,FirstDependency,
      PkgFile1,PkgFile2,ConflictPkg)
    then begin
      if (PkgFile1<>nil) and (PkgFile2<>nil) then begin
        s:=Format(lisPkgMangThereAreTwoUnitsWithTheSameName1From2From,
          [LineEnding+LineEnding, PkgFile1.Filename, PkgFile1.LazPackage.IDAsString,
           LineEnding, PkgFile2.Filename, PkgFile2.LazPackage.IDAsString]) + LineEnding;
      end else if (PkgFile1<>nil) and (ConflictPkg<>nil) then begin
        s:=Format(lisPkgMangThereIsAUnitWithTheSameNameAsAPackage1From2,
          [LineEnding+LineEnding, PkgFile1.Filename, PkgFile1.LazPackage.IDAsString,
           LineEnding, ConflictPkg.IDAsString]) + LineEnding;
      end else
        s:='Internal inconsistency FindAmbiguousUnits: '
          +'Please report this bug and how you got here.'+LineEnding;
      Result:=IDEMessageDialogAb(lisPkgMangAmbiguousUnitsFound, Format(
        lisPkgMangBothPackagesAreConnectedThisMeansEitherOnePackageU, [s]),
          mtError,Btns,ShowAbort);
      if not ShowAbort then
        Result := mrCancel; // User confirmed error, implicitly cancel the action
      exit;
    end;

    // check for ambiguous units between packages and FPC units
    if PackageGraph.FindFPCConflictUnit(APackage,FirstDependency,Directory,
      @PackageGraphFindFPCUnit,PkgFile1,ConflictPkg)
    then begin
      if (ConflictPkg<>nil) then begin
        s:=Format(lisPkgMangThereIsAFPCUnitWithTheSameNameAsAPackage,
          [LineEnding+LineEnding, ConflictPkg.IDAsString]) + LineEnding;
      end else if (PkgFile1<>nil) then begin
        s:=Format(lisPkgMangThereIsAFPCUnitWithTheSameNameFrom,
          [LineEnding+LineEnding, PkgFile1.Filename, PkgFile1.LazPackage.IDAsString]) + LineEnding;
      end else
        s:='Internal inconsistency FindFPCConflictUnits: '
          +'Please report this bug and how you got here.'+LineEnding;
      Result:=IDEMessageDialogAb(lisPkgMangAmbiguousUnitsFound, s,
          mtError,Btns,ShowAbort);
      if not ShowAbort then
        Result := mrCancel; // User confirmed error, implicitly cancel the action
      exit;
    end;

  finally
    PkgList.Free;
    PathList.Free;
  end;
  
  {$IFDEF VerbosePkgCompile}
  debugln('TPkgManager.CheckPackageGraphForCompilation END');
  {$ENDIF}
  Result:=mrOk;
end;

function TPkgManager.DoGetUnitRegisterInfo(const AFilename: string; out
  TheUnitName: string; out HasRegisterProc: boolean; IgnoreErrors: boolean
  ): TModalResult;
  
  function ErrorsHandled: boolean;
  begin
    if (CodeToolBoss.ErrorMessage='') or IgnoreErrors then exit(true);
    MainIDE.DoJumpToCodeToolBossError;
    Result:=false;
  end;
  
var
  ExpFilename: String;
  CodeBuffer: TCodeBuffer;
begin
  Result:=mrCancel;
  ExpFilename:=TrimFilename(AFilename);
  // create default values
  TheUnitName:='';
  HasRegisterProc:=false;
  MainIDE.SaveSourceEditorChangesToCodeCache(nil);
  CodeBuffer:=CodeToolBoss.LoadFile(ExpFilename,true,false);
  if CodeBuffer<>nil then begin
    TheUnitName:=CodeToolBoss.GetSourceName(CodeBuffer,false);
    if not ErrorsHandled then exit;
    CodeToolBoss.HasInterfaceRegisterProc(CodeBuffer,HasRegisterProc);
    if not ErrorsHandled then exit;
  end;
  if TheUnitName='' then
    TheUnitName:=ExtractFileNameOnly(ExpFilename);
  Result:=mrOk;
end;

procedure TPkgManager.SaveAutoInstallDependencies;
var
  Dependency: TPkgDependency;
  sl: TStringList;
begin
  sl:=TStringList.Create;
  Dependency:=PackageGraph.FirstAutoInstallDependency;
  while Dependency<>nil do begin
    if (Dependency.LoadPackageResult=lprSuccess)
    and (not Dependency.RequiredPackage.Missing)
    and (not PackageGraph.IsStaticBasePackage(Dependency.PackageName))
    and (not (Dependency.RequiredPackage.PackageType in [lptRunTime,lptRunTimeOnly]))
    then begin
      if sl.IndexOf(Dependency.PackageName)<0 then begin
        sl.Add(Dependency.PackageName);
        //DebugLn('TPkgManager.SaveAutoInstallDependencies A ',Dependency.PackageName);
      end;
    end;
    Dependency:=Dependency.NextRequiresDependency;
  end;
  MiscellaneousOptions.BuildLazProfiles.StaticAutoInstallPackages.Assign(sl);
  MiscellaneousOptions.Save;
  sl.Free;
end;

procedure TPkgManager.LoadStaticCustomPackages;
var
  StaticPackages: TFPList;
  StaticPackage: PRegisteredPackage;
  i: Integer;
  APackage: TLazPackage;
  Quiet: Boolean;
begin
  StaticPackages:=LazarusPackageIntf.RegisteredPackages;
  if StaticPackages=nil then exit;
  Quiet:=false;
  for i:=0 to StaticPackages.Count-1 do begin
    StaticPackage:=PRegisteredPackage(StaticPackages[i]);

    // check package name
    if not IsValidPkgName(StaticPackage^.Name)
    then begin
      DebugLn('Warning: (lazarus) [TPkgManager.LoadStaticCustomPackages] Invalid Package Name: "',
        BinaryStrToText(StaticPackage^.Name),'"');
      continue;
    end;
    
    // check register procedure
    if (StaticPackage^.RegisterProc=nil) then begin
      DebugLn('Warning: (lazarus) [TPkgManager.LoadStaticCustomPackages]',
        ' Package "',StaticPackage^.Name,'" has no register procedure.');
      continue;
    end;
    
    // load package
    APackage:=LoadInstalledPackage(StaticPackage^.Name,KeepInstalledPackages,
                                   Quiet);
    
    // register
    PackageGraph.RegisterStaticPackage(APackage,StaticPackage^.RegisterProc);
  end;
  PackageGraph.SortAutoInstallDependencies;
  ClearRegisteredPackages;
end;

function TPkgManager.LoadInstalledPackage(const PackageName: string;
  AddToAutoInstall: boolean; var Quiet: boolean): TLazPackage;
var
  NewDependency: TPkgDependency;
  PackageList: TStringList;
begin
  //DebugLn('TPkgManager.LoadInstalledPackage PackageName="',PackageName,'" Quiet=',Quiet);
  NewDependency:=TPkgDependency.Create;
  NewDependency.Owner:=Self;
  NewDependency.PackageName:=PackageName;
  PackageGraph.OpenInstalledDependency(NewDependency,pitStatic,Quiet);
  Result:=NewDependency.RequiredPackage;
  if AddToAutoInstall and (Result<>nil) then begin
    if FindDependencyByNameInList(
           PackageGraph.FirstAutoInstallDependency,pdlRequires,PackageName)=nil
    then begin
      NewDependency.RequiredPackage.AutoInstall:=pitStatic;
      NewDependency.AddToList(PackageGraph.FirstAutoInstallDependency,pdlRequires)
    end else
      NewDependency.Free;
    PackageList:=MiscellaneousOptions.BuildLazProfiles.StaticAutoInstallPackages;
    if PackageList.IndexOf(PackageName)<0 then
      PackageList.Add(PackageName);
  end else begin
    NewDependency.Free;
  end;
end;

procedure TPkgManager.LoadAutoInstallPackages;
begin
  FLastLazarusSrcDir:=EnvironmentOptions.GetParsedLazarusDirectory;
  PackageGraph.LoadAutoInstallPackages(
    MiscellaneousOptions.BuildLazProfiles.StaticAutoInstallPackages);
end;

procedure TPkgManager.AddUnitToProjectMainUsesSection(AProject: TProject;
  const AnUnitName, AnUnitInFilename: string);
begin
  // add unit to project main source file
  if (pfMainUnitIsPascalSource in AProject.Flags)
  and (pfMainUnitHasUsesSectionForAllUnits in AProject.Flags)
  and (AProject.MainUnitInfo<>nil) then begin
    //debugln('TPkgManager.AddUnitToProjectMainUsesSection B ',AnUnitName);
    if (AnUnitName<>'') then begin
      MainIDEInterface.SaveSourceEditorChangesToCodeCache(nil);
      if CodeToolBoss.AddUnitToMainUsesSectionIfNeeded(
        AProject.MainUnitInfo.Source,AnUnitName,AnUnitInFilename)
      then
        AProject.MainUnitInfo.Modified:=true;
    end;
  end;
end;

function TPkgManager.CheckDrag(Sender, Source: TObject; X, Y: Integer; out
  SrcFilesEdit, TargetFilesEdit: IFilesEditorInterface; out aFileCount,
  aDependencyCount, aDirectoryCount: integer; out TargetTVNode: TTreeNode; out
  TargetTVType: TTreeViewInsertMarkType): boolean;

  function GetFilesEditIntf(o: TObject): IFilesEditorInterface;
  var
    PkgEdit: TPackageEditorForm;
    aProjInsp: TProjectInspectorForm;
  begin
    Result:=nil;
    if o is TTreeView then begin
      PkgEdit:=PackageEditors.TreeViewToPkgEditor(TTreeView(o));
      if PkgEdit<>nil then
        Result:=PkgEdit
      else begin
        aProjInsp:=ProjInspector.TreeViewToInspector(TTreeView(o));
        if aProjInsp<>nil then
          Result:=aProjInsp;
      end;
    end;
  end;

var
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
  Directory: String;
  TV: TTreeView;
begin
  Result:=false;
  SrcFilesEdit:=nil;
  TargetFilesEdit:=nil;
  aFileCount:=0;
  aDependencyCount:=0;
  aDirectoryCount:=0;
  TargetTVNode:=nil;
  TargetTVType:=tvimNone;

  // get source
  SrcFilesEdit:=GetFilesEditIntf(Source);
  if (SrcFilesEdit=nil) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: unknown src=',DbgSName(Source)]);
    {$ENDIF}
    exit;
  end;
  if SrcFilesEdit.FilesOwnerReadOnly
  or (not FilenameIsAbsolute(SrcFilesEdit.FilesBaseDirectory)) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: src=',DbgSName(SrcFilesEdit.FilesOwner),' readonly=',SrcFilesEdit.FilesOwnerReadOnly,' basedir=',SrcFilesEdit.FilesBaseDirectory]);
    {$ENDIF}
    exit;
  end;

  // get target
  TargetFilesEdit:=GetFilesEditIntf(Sender);
  if (TargetFilesEdit=nil) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: unknown target=',DbgSName(Sender)]);
    {$ENDIF}
    exit;
  end;
  if TargetFilesEdit.FilesOwnerReadOnly
  or (not FilenameIsAbsolute(TargetFilesEdit.FilesBaseDirectory)) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: target=',DbgSName(TargetFilesEdit.FilesOwner),' readonly=',SrcFilesEdit.FilesOwnerReadOnly,' basedir=',SrcFilesEdit.FilesBaseDirectory]);
    {$ENDIF}
    exit;
  end;

  //debugln(['TPkgManager.CheckDrag Src=',SrcFilesEdit.FilesOwnerName,' Target=',TargetFilesEdit.FilesOwnerName]);

  // check items
  aFileCount:=0;
  aDependencyCount:=0;
  aDirectoryCount:=0;
  for i:=0 to SrcFilesEdit.FilesEditTreeView.SelectionCount-1 do begin
    TVNode:=SrcFilesEdit.FilesEditTreeView.Selections[i];
    if SrcFilesEdit.GetNodeDataItem(TVNode,NodeData,Item) then begin
      if NodeData.Removed then exit; // removed things cannot be moved
      if Item is TIDEOwnedFile then begin
        if (Item is TUnitInfo) and (TUnitInfo(Item)=TUnitInfo(Item).Project.MainUnitInfo)
        then
          continue;
        inc(aFileCount);
      end else if Item is TPkgDependency then begin
        inc(aDependencyCount);
      end;
    end else if SrcFilesEdit.IsDirectoryNode(TVNode) then begin
      inc(aDirectoryCount);
    end;
  end;
  if aFileCount+aDependencyCount+aDirectoryCount=0 then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: nothing useful dragged']);
    {$ENDIF}
    exit;
  end;
  if aDirectoryCount>0 then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: move directory is not implemented']);
    {$ENDIF}
    exit;
  end;
  if aDependencyCount>0 then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: move dependency is not implemented']);
    {$ENDIF}
    exit;
  end;
  if Sign(aFileCount)+Sign(aDependencyCount)+Sign(aDirectoryCount)>1 then begin
    // more than one type, but only one type can be dragged
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: more than one type Files=',aFileCount,' Deps=',aDependencyCount,' Dirs=',aDirectoryCount]);
    {$ENDIF}
    exit;
  end;

  TV:=TargetFilesEdit.FilesEditTreeView;
  TargetTVNode:=TV.GetNodeAt(X,Y);
  if TargetTVNode=nil then begin
    if aDependencyCount>0 then begin
      TargetTVNode:=TargetFilesEdit.TVNodeRequiredPackages;
    end else begin
      TargetTVNode:=TargetFilesEdit.TVNodeFiles;
    end;
    TargetTVType:=tvimAsFirstChild;
  end;
  if TargetFilesEdit.GetNodeDataItem(TargetTVNode,NodeData,Item) then begin
    // move to specific position is not yet supported
    // => redirect to parent nodes
    repeat
      TargetTVNode:=TargetTVNode.Parent;
      if TargetTVNode=nil then
        exit;
    until (TargetTVNode=TargetFilesEdit.TVNodeFiles)
      or (TargetTVNode=TargetFilesEdit.TVNodeRequiredPackages)
      or TargetFilesEdit.IsDirectoryNode(TargetTVNode);
    TargetTVType:=tvimAsFirstChild;
  end;
  if TargetFilesEdit.IsDirectoryNode(TargetTVNode)
  or (TargetTVNode=TargetFilesEdit.TVNodeFiles)
  then begin
    Directory:=TargetFilesEdit.GetNodeFilename(TargetTVNode);
    if not FilenameIsAbsolute(Directory) then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.CheckDrag: invalid target directory="',Directory,'"']);
      {$ENDIF}
      exit;
    end;
    TargetTVType:=tvimAsFirstChild;
    if aFileCount>0 then begin
      // drag files
    end else if aDirectoryCount>0 then begin
      // drag directory
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.CheckDrag drag directory not implemented yet']);
      {$ENDIF}
      exit;
    end else begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.CheckDrag failed: expected files or directory']);
      {$ENDIF}
      exit;
    end;
  end else if TargetTVNode=TargetFilesEdit.TVNodeRequiredPackages then begin
    if aDependencyCount=0 then exit;
    // drag dependencies
    TargetTVType:=tvimAsFirstChild;
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag drag dependencies not implemented yet']);
    {$ENDIF}
    exit;
  end else begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: invalid target node: ',TargetTVNode.Text]);
    {$ENDIF}
    exit;
  end;

  if (SrcFilesEdit=TargetFilesEdit)
  and (TargetTVNode.Selected or TargetTVNode.MultiSelected)
  then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.CheckDrag failed: target is selected']);
    {$ENDIF}
    exit;
  end;

  Result:=true;
end;

procedure TPkgManager.FilesEditDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  aFileCount: integer;
  aDependencyCount: integer;
  aDirectoryCount: integer;
  TargetTVNode: TTreeNode;
  TargetTVType: TTreeViewInsertMarkType;
  NodeData: TPENodeData;
  Item: TObject;
  aFile: TIDEOwnedFile;
  Directory: String;
  SrcFilesEdit: IFilesEditorInterface;
  TargetFilesEdit: IFilesEditorInterface;
begin
  if not CheckDrag(Sender, Source, X, Y, SrcFilesEdit, TargetFilesEdit,
   aFileCount, aDependencyCount, aDirectoryCount, TargetTVNode, TargetTVType)
  then begin
    ShowMessage('drop failed, dragover was wrong');
    exit;
  end;

  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.FilesEditDragDrop START Src=',SrcFilesEdit.FilesOwnerName,' Target=',TargetFilesEdit.FilesOwnerName,' FileCount=',aFileCount,' DepCount=',aDependencyCount,' DirCount=',aDirectoryCount]);
  {$ENDIF}
  if TargetFilesEdit.GetNodeDataItem(TargetTVNode,NodeData,Item) then begin
    if Item is TIDEOwnedFile then begin
      aFile:=TIDEOwnedFile(Item);
      if aFileCount=0 then exit;
      // drag files
      Directory:=ExtractFilePath(aFile.GetFullFilename);
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.FilesEditDragDrop drag files to directory of ',aFile.Filename]);
      {$ENDIF}
      MoveFiles(TargetFilesEdit,SrcFilesEdit,Directory);
    end else if Item is TPkgDependency then begin
      if aDependencyCount=0 then exit;
      // ToDo: drag dependencies
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.FilesEditDragDrop: drag dependencies']);
      {$ENDIF}
      ShowMessage('Not implemented yet: drag dependencies');
    end;
  end else if TargetFilesEdit.IsDirectoryNode(TargetTVNode)
  or (TargetTVNode=TargetFilesEdit.TVNodeFiles)
  then begin
    Directory:=TargetFilesEdit.GetNodeFilename(TargetTVNode);
    if aFileCount>0 then begin
      // drag files
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.FilesEditDragDrop drag files to ',TargetFilesEdit.FilesBaseDirectory]);
      {$ENDIF}
      MoveFiles(TargetFilesEdit,SrcFilesEdit,Directory);
    end else if aDirectoryCount>0 then begin
      // drag directory
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.FilesEditDragDrop: drag directory']);
      {$ENDIF}
      ShowMessage('Not implemented yet: drag directory');
    end else begin
      ShowMessage('I cannot drag that to a directory');
    end;
  end else if TargetTVNode=TargetFilesEdit.TVNodeRequiredPackages then begin
    if aDependencyCount=0 then exit;
    // ToDo: drag dependencies
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.FilesEditDragDrop: drag dependencies']);
    {$ENDIF}
    ShowMessage('Not implemented yet: drag dependencies');
  end else begin
    {$IFDEF VerbosePkgEditDrag}
    if TargetTVNode=nil then
      debugln(['TPkgManager.FilesEditDragDrop TargetTVNode=nil'])
    else
      debugln(['TPkgManager.FilesEditDragDrop TargetTVNode="',TargetTVNode.Text,'"']);
    {$ENDIF}
  end;
  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.FilesEditDragDrop END']);
  {$ENDIF}
end;

function TPkgManager.MoveFiles(TargetFilesEdit, SrcFilesEdit: IFilesEditorInterface;
  TargetDirectory: string): boolean;
var
  Files: TFPList; // list of TPkgFile
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
begin
  Result:=false;
  if not FilenameIsAbsolute(TargetDirectory) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.MoveFiles invalid TargetDirectory=',TargetDirectory]);
    {$ENDIF}
    exit;
  end;
  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.MoveFiles Target=',TargetFilesEdit.FilesOwnerName,' Src=',SrcFilesEdit.FilesOwnerName,' Dir="',TargetDirectory,'"']);
  {$ENDIF}
  Files:=TFPList.Create;
  try
    for i:=0 to SrcFilesEdit.FilesEditTreeView.SelectionCount-1 do begin
      TVNode:=SrcFilesEdit.FilesEditTreeView.Selections[i];
      if not SrcFilesEdit.GetNodeDataItem(TVNode, NodeData, Item) then continue;
      if NodeData.Removed then continue;
      if not (Item is TIDEOwnedFile) then continue;
      if (Item is TUnitInfo) and (TUnitInfo(Item)=TUnitInfo(Item).Project.MainUnitInfo)
      then
        continue;
      Files.Add(Item);
    end;
    if Files.Count=0 then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles no file feasable for moving']);
      {$ENDIF}
      exit(true);
    end;

    Result:=MoveFiles(TargetFilesEdit,SrcFilesEdit,Files,TargetDirectory);
  finally
    Files.Free;
  end;
end;

function TPkgManager.MoveFiles(TargetFilesEdit, SrcFilesEdit: IFilesEditorInterface;
  IDEFiles: TFPList; TargetDirectory: string): boolean;
var
  ChangedFilenames: TFilenameToStringTree; // old to new file name
  AllChangedFilenames: TFilenameToStringTree; // including resouce files
  NewFileToOldOwnedFile: TFilenameToPointerTree; // filename to TIDEOwnedFile
  DeleteOld: Boolean;
  UnitFilenameToResFileList: TFilenameToPointerTree; // filename to TStringList
  SrcDirToPkg: TFilenameToPointerTree;
  SrcPackage, TargetPackage: TLazPackage;
  SrcProject, TargetProject: TProject;
  SrcIsTarget: Boolean;

  procedure DeleteNonExistingPkgFiles;
  var
    i: Integer;
    CurFile: TIDEOwnedFile;
    aFilename: String;
  begin
    // ignore non existing files
    for i:=IDEFiles.Count-1 downto 0 do begin
      CurFile:=TIDEOwnedFile(IDEFiles[i]);
      aFilename:=CurFile.GetFullFilename;
      if not FileExistsCached(aFilename) then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['TPkgManager.MoveFiles WARNING: file not found: ',aFilename]);
        {$ENDIF}
        IDEFiles.Delete(i);
      end;

      if (CurFile is TUnitInfo) and (TUnitInfo(CurFile)=TUnitInfo(CurFile).Project.MainUnitInfo)
      then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['TPkgManager.MoveFiles WARNING: main unit of project cannot be moved: ',aFilename]);
        {$ENDIF}
        IDEFiles.Delete(i);
      end;
    end;
  end;

  function GetPkgProj(FilesEdit: IFilesEditorInterface; out aPkg: TLazPackage;
    out aProject: TProject): boolean;
  var
    MainUnit: TUnitInfo;
    Code: TCodeBuffer;
    Tool: TCodeTool;
  begin
    Result:=false;
    aPkg:=nil;
    aProject:=nil;
    if not FilenameIsAbsolute(FilesEdit.FilesBaseDirectory) then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles base dir not absolute: ',FilesEdit.FilesBaseDirectory]);
      {$ENDIF}
      exit;
    end;

    if FilesEdit.FilesOwner is TLazPackage then begin
      aPkg:=TLazPackage(FilesEdit.FilesOwner);
      Result:=true;
    end else if FilesEdit.FilesOwner is TProject then begin
      aProject:=TProject(FilesEdit.FilesOwner);
      MainUnit:=aProject.MainUnitInfo;
      if (MainUnit<>nil) and (pfMainUnitIsPascalSource in aProject.Flags) then
      begin
        // check project main source for syntax errors
        if LoadCodeBuffer(Code,MainUnit.Filename,[lbfUpdateFromDisk,lbfCheckIfText],false)<>mrOk
        then exit;
        if not CodeToolBoss.Explore(Code,Tool,true) then begin
          {$IFDEF VerbosePkgEditDrag}
          debugln(['TPkgManager.MoveFiles project main source has errors: ',Code.Filename]);
          {$ENDIF}
          LazarusIDE.DoJumpToCodeToolBossError;
          exit;
        end;
      end;
      Result:=true;
    end;
  end;

  function FileIsUnit(aFile: TIDEOwnedFile): boolean;
  begin
    if aFile is TPkgFile then
      Result:=TPkgFile(aFile).FileType in PkgFileRealUnitTypes
    else
      Result:=FilenameIsPascalSource(aFile.Filename);
  end;

  procedure AddResFile(ResFiles: TStringList; ResFile: string);
  var
    NewResFile: String;
  begin
    if not FilenameIsAbsolute(ResFile) then exit;
    if AllChangedFilenames.Contains(ResFile) then exit;
    if IndexInRecentList(ResFiles,rltFile,ResFile)>=0 then exit;
    if not FileExistsCached(ResFile) then exit;
    ResFiles.Add(ResFile);
    NewResFile:=TargetDirectory+ExtractFilename(ResFile);
    AllChangedFilenames[ResFile]:=NewResFile;
  end;

  function CollectFiles(out MoveFileCount: integer): boolean;
  var
    i: Integer;
    aFile: TIDEOwnedFile;
    OldFilename: String;
    NewFilename: String;
    ResFileList: TStringList;
    UnitResArr: TUnitResourcefileFormatArr;
    j: Integer;
    aFilename: String;
    S2PItem: PStringToPointerTreeItem;
  begin
    Result:=false;
    MoveFileCount:=0;
    for i:=0 to IDEFiles.Count-1 do begin
      aFile:=TIDEOwnedFile(IDEFiles[i]);
      OldFilename:=aFile.GetFullFilename;
      NewFilename:=TargetDirectory+ExtractFilename(OldFilename);

      // check if two copied/moved files will get the same new file name
      if NewFileToOldOwnedFile.Contains(NewFilename) then begin
        IDEMessageDialog(lisConflictDetected,
          Format(lisTwoMovedFilesWillHaveTheSameFileNameIn, [#13, aFile
            .Filename, #13, TIDEOwnedFile(NewFileToOldOwnedFile[NewFilename]).
            Filename, #13, TargetFilesEdit.FilesOwnerName]), mtError, [mbCancel]);
        exit;
      end;
      NewFileToOldOwnedFile[NewFilename]:=aFile;

      if CompareFilenames(NewFilename,OldFilename)<>0 then begin
        // file be copied/moved to another directory
        debugln(['Hint: (lazarus) CollectFiles Old="',OldFilename,'"']);
        debugln(['Hint: (lazarus) New="',NewFilename,'"']);
        inc(MoveFileCount);
        ChangedFilenames[OldFilename]:=NewFilename;
        AllChangedFilenames[OldFilename]:=NewFilename;

        // check resource file
        if FileIsUnit(aFile) then begin
          ResFileList:=TStringList.Create;
          UnitFilenameToResFileList[OldFilename]:=ResFileList;
          AddResFile(ResFileList,ChangeFileExt(OldFilename,'.lfm'));
          AddResFile(ResFileList,ChangeFileExt(OldFilename,'.dfm'));
          AddResFile(ResFileList,ChangeFileExt(OldFilename,'.lrs'));
          UnitResArr:=GetUnitResourcefileFormats;
          for j:=0 to length(UnitResArr)-1 do begin
            aFilename:=UnitResArr[j].GetUnitResourceFilename(OldFilename,true);
            AddResFile(ResFileList,aFilename);
          end;
        end;
      end;
    end;

    // remove res files, that are in IDEFiles
    for S2PItem in UnitFilenameToResFileList do begin
      OldFilename:=S2PItem^.Name;
      ResFileList:=TStringList(S2PItem^.Value);
      for i:=ResFileList.Count-1 downto 0 do begin
        if ChangedFilenames.Contains(ResFileList[i]) then
          ResFileList.Delete(i);
      end;
    end;

    Result:=true;
  end;

  function CheckNewFilesDoNotExist: boolean;
  var
    S2SItem: PStringToStringTreeItem;
    OldFilename: String;
    NewFilename: String;
    ConflictFile: TIDEOwnedFile;
    CurName: String;
    ShortFilename: String;
    r: TModalResult;
    i: Integer;
    WarnUnitClash: Boolean;
    WarnNameClash: Boolean;
    Cnt: Integer;
    SrcEdit: TSourceEditor;
  begin
    Result:=false;
    WarnUnitClash:=true;
    WarnNameClash:=true;
    for S2SItem in AllChangedFilenames do begin
      OldFilename:=S2SItem^.Name;
      NewFilename:=S2SItem^.Value;
      if CompareFilenames(OldFilename,NewFilename)=0 then continue;

      // check file does not exist
      if FileExistsCached(NewFilename) then begin
        IDEMessageDialog(lisConflictDetected,
          Format(lisThereIsAlreadyAFileIn, [#13, NewFilename, #13,
            TargetFilesEdit.FilesOwnerName]), mtError, [mbCancel]);
        exit;
      end;

      // close source editor
      repeat
        SrcEdit:=SourceEditorManager.SourceEditorIntfWithFilename(NewFilename);
        if SrcEdit=nil then break;
        if LazarusIDE.DoCloseEditorFile(SrcEdit,[cfSaveFirst,
          cfCloseDependencies,cfSaveDependencies])<>mrOk then exit;
      until false;

      if (not SrcIsTarget) then begin
        // warn duplicate names
        if FilenameIsPascalUnit(NewFilename) then begin
          // warn duplicate unit name
          CurName:=ExtractFileNameOnly(NewFilename);
          if TargetPackage<>nil then
            ConflictFile:=TargetPackage.FindUnit(CurName,true)
          else if TargetProject<>nil then
            ConflictFile:=TargetProject.UnitWithUnitname(CurName)
          else
            ConflictFile:=nil;
          if (ConflictFile<>nil) and WarnUnitClash then begin
            ShortFilename:=NewFilename;
            ShortFilename:=CreateRelativePath(ShortFilename,TargetFilesEdit.FilesBaseDirectory);
            r:=IDEMessageDialog(lisDuplicateUnit,
              Format(lisThereIsAlreadyAUnitInOldNewYouHaveToMakeSur, [
                CurName, TargetFilesEdit.FilesOwnerName, #13,
                ConflictFile.GetShortFilename(true), #13,
                ShortFilename, #13, #13, #13])
              ,mtWarning,[mbYes,mbYesToAll,mbCancel]);
            case r of
            mrYes: ;
            mrYesToAll: WarnUnitClash:=false;
            else exit;
            end;
          end;
        end else begin
          // warn duplicate file
          if TargetPackage<>nil then
            Cnt:=TargetPackage.FileCount
          else if TargetProject<>nil then
            Cnt:=TargetProject.FileCount
          else
            Cnt:=0;
          for i:=0 to Cnt-1 do begin
            if not WarnNameClash then continue;
            if TargetPackage<>nil then
              ConflictFile:=TargetPackage.Files[i]
            else if TargetProject<>nil then
              ConflictFile:=TargetProject.Files[i]
            else
              continue;
            ShortFilename:=ExtractFilename(NewFilename);
            CurName:=ExtractFileName(ConflictFile.Filename);
            if (UTF8CompareText(CurName,ShortFilename)<>0)
            and (CompareFilenames(CurName,ShortFilename)<>0) then
              continue;
            // name clash on this or other platforms => warn
            ShortFilename:=NewFilename;
            ShortFilename:=CreateRelativePath(ShortFilename,TargetFilesEdit.FilesBaseDirectory);
            r:=IDEMessageDialog(lisDuplicateFileName,
              Format(lisThereIsAlreadyAFileInOldNewContinue, [CurName,
                TargetFilesEdit.FilesOwnerName, #13,
                ConflictFile.GetShortFilename(true), #13,
                ShortFilename, #13, #13])
              ,mtWarning,[mbYes,mbYesToAll,mbCancel]);
            case r of
            mrYes: ;
            mrYesToAll: WarnNameClash:=false;
            else exit;
            end;
          end;
        end;
      end;
    end;
    Result:=true;
  end;

  function CloseSrcEditors: boolean;
  var
    i: Integer;
    SrcEdit: TSourceEditorInterface;
  begin
    for i:=SourceEditorManagerIntf.SourceEditorCount-1 downto 0 do begin
      if i>=SourceEditorManagerIntf.SourceEditorCount then continue;
      SrcEdit:=SourceEditorManagerIntf.SourceEditors[i];
      if not AllChangedFilenames.Contains(SrcEdit.FileName) then continue;
      if LazarusIDE.DoCloseEditorFile(SrcEdit,
        [cfSaveFirst,cfCloseDependencies])<>mrOk
      then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['CloseSrcEditors failed']);
        {$ENDIF}
        exit(false);
      end;
    end;
    Result:=true;
  end;

  function ClearOldCompiledFiles: boolean;
  var
    OutDir: String;
    CurFiles: TStrings;
    OutFilename: String;
    CurUnitName: String;
    Ext: String;
    S2SItem: PStringToStringTreeItem;
    OldFilename: String;
    SeparateOutDir: Boolean;
    r: TModalResult;
  begin
    Result:=false;
    // => clear output directory of Src
    if SrcPackage<>nil then begin
      if PackageGraph.PreparePackageOutputDirectory(SrcPackage,true)<>mrOk then
      begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['TPkgManager.MoveFiles PreparePackageOutputDirectory failed']);
        {$ENDIF}
        exit;
      end;
    end else if SrcProject<>nil then begin
      OutDir:=ChompPathDelim(SrcProject.GetOutputDirectory);
      if not FilenameIsAbsolute(OutDir) then exit(true);
      CurFiles:=nil;
      try
        CodeToolBoss.DirectoryCachePool.GetListing(OutDir,CurFiles,false);
        for OutFilename in CurFiles do begin
          CurUnitName:=ExtractFilenameOnly(OutFilename);
          for S2SItem in ChangedFilenames do begin
            OldFilename:=S2SItem^.Name;
            if not FilenameIsPascalSource(OldFilename) then continue;
            if CompareTextCT(CurUnitName,ExtractFileNameOnly(OldFilename))<>0 then
              continue;
            // output filename and source have same unitname
            SeparateOutDir:=CompareFilenames(ChompPathDelim(ExtractFilePath(OldFilename)),OutDir)<>0;
            Ext:=lowercase(ExtractFileExt(OutFilename));
            if (Ext='ppu') or (Ext='o') or (Ext='ppl') or (Ext='rst') or (Ext='lrt')
            or (SeparateOutDir and ((Ext='lrs') or (Ext='lfm'))) then begin
              // automatically created file found => delete
              r:=DeleteFileInteractive(OutFilename,[mbCancel,mbIgnore]);
              if not (r in [mrOk,mrIgnore]) then exit;
            end;
            break;
          end;
        end;
      finally
        CurFiles.Free;
      end;
    end;
    Result:=true;
  end;

  function CheckUsesSection(Tool: TCodeTool; UsesNode: TCodeTreeNode;
    NewUnitFilename: string): boolean;
  // true if no warnings
  var
    AnUnitName, AnUnitInFilename: string;
    OldUsedUnitCode: TCodeBuffer;
    OldUsedUnitFilename: string;
    Node: TCodeTreeNode;
    NamePos: Integer;
    OldCompiledUnitname: String;
    CodePos: TCodeXYPosition;
    Msg: String;
    PkgName: String;
    UsedPkg: TLazPackage;
    NewUsedUnitFilename: String;
  begin
    Result:=true;
    if UsesNode=nil then exit;
    // check that all used units are available in the target package
    Node:=UsesNode.FirstChild;
    while Node<>nil do begin
      // read unit name
      AnUnitInFilename:='';
      AnUnitName:=Tool.ExtractUsedUnitName(Node,@AnUnitInFilename);
      NamePos:=Node.StartPos;
      Node:=Node.NextBrother;
      if AnUnitName='' then continue;
      // find unit file
      OldUsedUnitCode:=Tool.FindUnitSource(AnUnitName,AnUnitInFilename,false,NamePos);
      if (OldUsedUnitCode=nil) then begin
        // no source found
        // => search for ppu
        OldCompiledUnitname:=AnUnitName+'.ppu';
        OldUsedUnitFilename:=Tool.DirectoryCache.FindCompiledUnitInCompletePath(
                                                     OldCompiledUnitname,false);
        if OldUsedUnitFilename='' then begin
          // unit not found
          // (that is ok, e.g. if the unit is used on another platform)
          // => only warn
          Msg:=Format(lisUnitNotFound, [AnUnitName]);
          if not Tool.CleanPosToCaret(NamePos,CodePos) then continue;
          Result:=false;
          IDEMessagesWindow.AddCustomMessage(mluWarning,Msg,
            CodePos.Code.Filename, CodePos.Y, CodePos.X, lisMoveFiles);
          continue;
        end;
      end else begin
        // unit found
        OldUsedUnitFilename:=OldUsedUnitCode.Filename;
        if AllChangedFilenames.Contains(OldUsedUnitFilename) then begin
          // this unit will be moved too => ok
          continue;
        end;
      end;
      // OldUsedUnitFilename is now either a .pas/pp/p or .ppu file

      // search unit in new position
      NewUsedUnitFilename:=CodeToolBoss.DirectoryCachePool.FindUnitSourceInCompletePath(
        ExtractFilePath(NewUnitFilename),AnUnitName,AnUnitInFilename);
      if (NewUsedUnitFilename='') and (AnUnitInFilename='') then
        NewUsedUnitFilename:=CodeToolBoss.DirectoryCachePool.FindCompiledUnitInCompletePath(
          ExtractFilePath(NewUnitFilename),AnUnitName);
      if CompareFilenames(OldUsedUnitFilename,NewUsedUnitFilename)=0 then
        continue;
      // not found or a different unit found

      if not Tool.CleanPosToCaret(NamePos,CodePos) then continue;

      // find package of used unit
      PkgName:='';
      UsedPkg:=TLazPackage(SrcDirToPkg[ExtractFilePath(OldUsedUnitFilename)]);
      if UsedPkg<>nil then
        PkgName:=UsedPkg.Name;

      if NewUsedUnitFilename='' then begin
        // at the new position the unit cannot be found
        if PkgName='' then begin
          Msg:=Format(lisUnitNotFoundAtNewPosition, [AnUnitName, NewUnitFilename
            ]);
        end else begin
          Msg:=Format(lisUnitRequiresPackage, [AnUnitName, PkgName]);
        end;
      end else begin
        // a different unit will be used
        Msg:=Format(lisDifferentUnitFoundAtNewPosition, [AnUnitName,
          NewUnitFilename]);
      end;

      Result:=false;
      IDEMessagesWindow.AddCustomMessage(mluWarning,Msg,
        CodePos.Code.Filename, CodePos.Y, CodePos.X, lisMoveFiles);
    end;
  end;

  function CheckUsesSections: boolean;
  // check that all used units are available in the target package
  var
    i: Integer;
    aFile: TIDEOwnedFile;
    OldFilename: String;
    Code: TCodeBuffer;
    Tool: TCodeTool;
    NewFilename: String;
  begin
    if SrcIsTarget then
      exit(true);
    // moving files to another package/project
    if (SrcPackage<>nil) and (PackageGraph.FindDependencyRecursively(
      TargetFilesEdit.FirstRequiredDependency,SrcPackage)<>nil)
    then begin
      // units are moved to higher level package/project
      // => no check needed
      exit(true);
    end;

    // check that all used units are available in the target
    Result:=true;
    for i:=0 to IDEFiles.Count-1 do begin
      aFile:=TIDEOwnedFile(IDEFiles[i]);
      if not FileIsUnit(aFile) then continue;
      OldFilename:=aFile.GetFullFilename;
      NewFilename:=ChangedFilenames[OldFilename];
      if CompareFilenames(ExtractFilePath(OldFilename),ExtractFilePath(NewFilename))=0
      then continue;
      if LoadCodeBuffer(Code,OldFilename,[lbfUpdateFromDisk,lbfCheckIfText],false)<>mrOk
      then exit;
      CodeToolBoss.Explore(Code,Tool,false);
      if not CheckUsesSection(Tool,Tool.FindMainUsesNode,NewFilename) then
        Result:=false;
      if not CheckUsesSection(Tool,Tool.FindImplementationUsesNode,NewFilename) then
        Result:=false;
    end;
    if not Result then begin
      if IDEMessageDialog(lisCCOWarningCaption,
        lisMovingTheseUnitsWillBreakTheirUsesSectionsSeeMessa,
        mtWarning,[mbIgnore,mbCancel])<>mrIgnore
      then
        exit;
      Result:=true;
    end;
  end;

  function ExtendSearchPaths: boolean;
  var
    i: Integer;
    aFile: TIDEOwnedFile;
    NewDir: String;
    NewUnitPaths: String;
    NewIncPaths: String;
    OldFilename: String;
    FileType: TPkgFileType;
  begin
    NewUnitPaths:='';
    NewIncPaths:='';
    for i:=0 to IDEFiles.Count-1 do begin
      aFile:=TIDEOwnedFile(IDEFiles[i]);
      OldFilename:=aFile.GetFullFilename;
      NewDir:=ChompPathDelim(ExtractFilePath(ChangedFilenames[OldFilename]));
      if aFile is TPkgFile then
        FileType:=TPkgFile(aFile).FileType
      else
        FileType:=FileNameToPkgFileType(OldFilename);
      case FileType of
      pftUnit,pftMainUnit:
        MergeSearchPaths(NewUnitPaths,NewDir);
      pftInclude:
        MergeSearchPaths(NewIncPaths,NewDir);
      end;
    end;
    // unit paths
    if (NewUnitPaths<>'') and not TargetFilesEdit.ExtendUnitSearchPath(NewUnitPaths)
    then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['ExtendSearchPaths ExtendUnitSearchPath failed: NewUnitPaths="',NewUnitPaths,'"']);
      {$ENDIF}
      exit(false);
    end;
    // include paths
    if (NewIncPaths<>'') and not TargetFilesEdit.ExtendIncSearchPath(NewIncPaths)
    then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['ExtendSearchPaths ExtendIncSearchPath failed: NewIncPaths="',NewIncPaths,'"']);
      {$ENDIF}
      exit(false);
    end;
    Result:=true;
  end;

  function MoveOrCopyFile(OldFilename: string;
    MovedFiles: TFilenameToPointerTree): boolean;
  var
    NewFilename: String;
    r: TModalResult;
    OldPkgFile: TPkgFile;
    NewPkgFile: TPkgFile;
    NewFileType: TPkgFileType;
    NewUnitName: String;
    NewCompPrio: TComponentPriority;
    NewResourceBaseClass: TPFComponentBaseClass;
    NewHasRegisterProc: Boolean;
    NewAddToUses: Boolean;
    OldProjFile: TUnitInfo;
    Code: TCodeBuffer;
    NewProjFile: TUnitInfo;
  begin
    Result:=false;
    // check if needed
    NewFilename:=TargetDirectory+ExtractFilename(OldFilename);
    if CompareFilenames(NewFilename,OldFilename)=0 then
      exit(true);
    // check if already moved
    if MovedFiles.Contains(OldFilename) then
      exit(true);
    MovedFiles[OldFilename]:=Self;
    // copy or move file
    if FileExistsUTF8(OldFilename) then begin
      if DeleteOld then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['MoveOrCopyFile rename "',OldFilename,'" to "',NewFilename,'"']);
        {$ENDIF}
        r:=RenameFileWithErrorDialogs(OldFilename,NewFilename,[mbAbort,mbIgnore]);
      end else begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['MoveOrCopyFile copy "',OldFilename,'" to "',NewFilename,'"']);
        {$ENDIF}
        r:=CopyFileWithErrorDialogs(OldFilename,NewFilename,[mbAbort,mbIgnore]);
      end;
      if not (r in [mrIgnore,mrOK]) then begin
        debugln(['Error: (lazarus) MoveOrCopyFile: rename/copy failed: "',OldFilename,'" to "',NewFilename,'"']);
        exit;
      end;
    end else begin
      if IDEMessageDialog(lisCCOWarningCaption,
        Format(lisFileNotFound5, [#13, OldFilename]), mtWarning, [mbIgnore,
          mbCancel])<>mrIgnore
      then
        exit;
    end;

    OldPkgFile:=nil;
    OldProjFile:=nil;
    if SrcPackage<>nil then begin
      OldPkgFile:=SrcPackage.FindPkgFile(OldFilename,true,false);
      if OldPkgFile=nil then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['MoveOrCopyFile old file not in lpk: "',OldFilename,'" pkg=',SrcPackage.Name]);
        {$ENDIF}
        // this is a resource file
        // => do not create an entry in the target
        exit(true);
      end;
    end else if SrcProject<>nil then begin
      OldProjFile:=SrcProject.UnitInfoWithFilename(OldFilename,[pfsfOnlyProjectFiles]);
      if OldProjFile=nil then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['MoveOrCopyFile old file not in lpi: "',OldFilename,'"']);
        {$ENDIF}
        // this is a resource file
        // => do not create an entry in the target
        exit(true);
      end;
    end else begin
      raise Exception.Create('implement me');
    end;

    if OldPkgFile<>nil then begin
      NewUnitName:=OldPkgFile.Unit_Name;
      NewFileType:=OldPkgFile.FileType;
      if NewFileType=pftMainUnit then NewFileType:=pftUnit;
      NewCompPrio:=OldPkgFile.ComponentPriority;
      NewResourceBaseClass:=OldPkgFile.ResourceBaseClass;
      NewHasRegisterProc:=OldPkgFile.HasRegisterProc;
      NewAddToUses:=OldPkgFile.AddToUsesPkgSection;
    end else begin
      NewUnitName:=OldProjFile.SrcUnitName;
      NewFileType:=FileNameToPkgFileType(OldFilename);
      NewCompPrio:=ComponentPriorityNormal;
      NewResourceBaseClass:=OldProjFile.ResourceBaseClass;
      NewHasRegisterProc:=false;
      NewAddToUses:=true;
      if NewFileType=pftUnit then begin
        Code:=CodeToolBoss.LoadFile(OldFilename,true,false);
        if (Code<>nil) then begin
          if TargetPackage<>nil then
            CodeToolBoss.HasInterfaceRegisterProc(Code,NewHasRegisterProc);
        end;
      end;
    end;

    NewPkgFile:=nil;
    NewProjFile:=nil;
    if TargetPackage<>nil then begin
      // create new TPkgFile
      NewPkgFile:=TargetPackage.FindPkgFile(NewFilename,true,false);
      if NewPkgFile=nil then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['MoveOrCopyFile create new "',NewFilename,'" pkg=',TargetPackage.Name]);
        {$ENDIF}
        NewPkgFile:=TargetPackage.AddFile(NewFilename,NewUnitName,
          NewFileType,[],NewCompPrio.Category);
      end else begin
        NewPkgFile.Unit_Name:=NewUnitName;
        NewFileType:=NewFileType;
        NewPkgFile.FileType:=NewFileType;
      end;
      NewPkgFile.ComponentPriority:=NewCompPrio;
      NewPkgFile.ResourceBaseClass:=NewResourceBaseClass;
      NewPkgFile.HasRegisterProc:=NewHasRegisterProc;
      if NewAddToUses
      and (TargetPackage.FindUsedUnit(ExtractFileNameOnly(NewFilename),NewPkgFile)<>nil)
      then begin
        // another unit with this name is already used
        NewPkgFile.AddToUsesPkgSection:=false;
      end else begin
        NewPkgFile.AddToUsesPkgSection:=NewAddToUses;
      end;
    end else if TargetProject<>nil then begin
      // create new TUnitInfo

      NewProjFile:=TargetProject.UnitInfoWithFilename(NewFilename);
      if NewProjFile=nil then begin
        NewProjFile:=TUnitInfo.Create(nil);
        NewProjFile.Filename:=NewFilename;
        TargetProject.AddFile(NewProjFile,false);
      end;
      NewProjFile.IsPartOfProject:=true;
      NewProjFile.ResourceBaseClass:=NewResourceBaseClass;
      if OldProjFile<>nil then begin
        NewProjFile.HasResources:=OldProjFile.HasResources;
        NewProjFile.ComponentName:=OldProjFile.ComponentName;
        NewProjFile.ComponentResourceName:=OldProjFile.ComponentResourceName;
        NewProjFile.BuildFileIfActive:=OldProjFile.BuildFileIfActive;
        NewProjFile.RunFileIfActive:=OldProjFile.RunFileIfActive;
        NewProjFile.DefaultSyntaxHighlighter:=OldProjFile.DefaultSyntaxHighlighter;
        NewProjFile.DisableI18NForLFM:=OldProjFile.DisableI18NForLFM;
        NewProjFile.CustomDefaultHighlighter:=OldProjFile.CustomDefaultHighlighter;
      end;
      if (not SrcIsTarget)
      and (pfMainUnitHasUsesSectionForAllUnits in TargetProject.Flags) then
      begin
        CodeToolBoss.AddUnitToMainUsesSection(
                       TargetProject.MainUnitInfo.Source,NewUnitName,'');
        CodeToolBoss.SourceChangeCache.Apply;
        TargetProject.MainUnitInfo.Modified:=true;
      end;
    end else begin
      raise Exception.Create('implement me');
    end;

    // delete old
    if DeleteOld then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['MoveOrCopyFile delete "',OldFilename,'" from=',SrcFilesEdit.FilesOwnerName]);
      {$ENDIF}
      if OldPkgFile<>nil then begin
        SrcPackage.DeleteFile(OldPkgFile);
      end else if OldProjFile<>nil then begin
        OldProjFile.IsPartOfProject:=false;
        if (not SrcIsTarget)
        and (pfMainUnitHasUsesSectionForAllUnits in SrcProject.Flags) then
        begin
          CodeToolBoss.RemoveUnitFromAllUsesSections(
                         SrcProject.MainUnitInfo.Source,NewUnitName);
          CodeToolBoss.SourceChangeCache.Apply;
          SrcProject.MainUnitInfo.Modified:=true;
        end;
      end else begin
        raise Exception.Create('implement me');
      end;
    end;
    TargetFilesEdit.UpdateAll;
    SrcFilesEdit.UpdateAll;
    Result:=true;
  end;

  function MoveOrCopyFiles: boolean;
  var
    i: Integer;
    OldFilename: String;
    MovedFiles: TFilenameToPointerTree;
    ResFileList: TStringList;
    j: Integer;
    OldFilenames: TStringList;
  begin
    Result:=false;
    TargetFilesEdit.BeginUpdate;
    SrcFilesEdit.BeginUpdate;
    OldFilenames:=TStringList.Create;
    MovedFiles:=TFilenameToPointerTree.Create(false);
    try
      for i:=0 to IDEFiles.Count-1 do
        OldFilenames.Add(TIDEOwnedFile(IDEFiles[i]).GetFullFilename);
      for i:=0 to OldFilenames.Count-1 do begin
        OldFilename:=OldFilenames[i];
        if not MoveOrCopyFile(OldFilename,MovedFiles) then exit;
        ResFileList:=TStringList(UnitFilenameToResFileList[OldFilename]);
        if ResFileList=nil then continue;
        for j:=0 to ResFileList.Count-1 do
          if not MoveOrCopyFile(ResFileList[j],MovedFiles) then exit;
      end;
    finally
      MovedFiles.Free;
      OldFilenames.Free;
      SrcFilesEdit.EndUpdate;
      TargetFilesEdit.EndUpdate;
    end;
    Result:=true;
  end;

var
  MoveFileCount: Integer;
  MsgResult: TModalResult;
begin
  Result:=false;

  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.MoveFiles Self=',TargetFilesEdit.FilesOwnerName,' Src=',SrcFilesEdit.FilesOwnerName,' Dir="',TargetDirectory,'" FileCount=',IDEFiles.Count]);
  {$ENDIF}
  if not GetPkgProj(SrcFilesEdit,SrcPackage,SrcProject) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.MoveFiles invalid src=',DbgSName(SrcFilesEdit.FilesOwner)]);
    {$ENDIF}
    exit;
  end;
  if not GetPkgProj(TargetFilesEdit,TargetPackage,TargetProject) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.MoveFiles invalid target=',DbgSName(TargetFilesEdit.FilesOwner)]);
    {$ENDIF}
    exit;
  end;

  DeleteNonExistingPkgFiles;
  if IDEFiles.Count=0 then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.MoveFiles PkgFiles.Count=0']);
    {$ENDIF}
    exit(true);
  end;

  if TargetFilesEdit.FilesOwnerReadOnly then begin
    IDEMessageDialog(lisTargetIsReadOnly,
      Format(lisTheTargetIsNotWritable, [TargetFilesEdit.FilesOwnerName]),
        mtError, [mbCancel]);
    exit;
  end;

  if not FilenameIsAbsolute(TargetDirectory) then begin
    {$IFDEF VerbosePkgEditDrag}
    debugln(['TPkgManager.MoveFiles invalid target dir=',TargetDirectory]);
    {$ENDIF}
    exit;
  end;
  TargetDirectory:=AppendPathDelim(TargetDirectory);

  // check TargetDirectory
  if CheckDirectoryIsWritable(TargetDirectory)<>mrOk then begin
    debugln(['Warning: (lazarus) TPkgManager.MoveFiles not writable TargetDirectory=',TargetDirectory]);
    exit;
  end;

  SrcIsTarget:=SrcFilesEdit.FilesOwner=TargetFilesEdit.FilesOwner;

  IDEMessagesWindow.Clear;

  NewFileToOldOwnedFile:=TFilenameToPointerTree.Create(false);
  ChangedFilenames:=TFilenameToStringTree.Create(false);
  AllChangedFilenames:=TFilenameToStringTree.Create(false);
  UnitFilenameToResFileList:=TFilenameToPointerTree.Create(false);
  UnitFilenameToResFileList.FreeValues:=true;
  SrcDirToPkg:=nil;
  try
    // collect all affected files including resource files
    if not CollectFiles(MoveFileCount) then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles CollectFiles failed']);
      {$ENDIF}
      exit;
    end;

    // check if new position is free
    if not CheckNewFilesDoNotExist then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles CheckNewFilesDoNotExist failed']);
      {$ENDIF}
      exit;
    end;

    if (MoveFileCount=0) and (SrcIsTarget) then begin
      // no move, only change order in package
      // ToDo: check this case in ItemsTreeViewDragDrop
      ShowMessage('Changing order via drag and drop is not implemented.');
      exit;
    end;

    // ask for confirmation
    if IDEFiles.Count=MoveFileCount then begin
      MsgResult:=IDEQuestionDialog(lisMoveOrCopyFiles,
        Format(lisMoveOrCopyFileSFromToTheDirectoryOfPackage, [
          IntToStr(MoveFileCount),
          SrcFilesEdit.FilesOwnerName, #13,
          TargetDirectory, #13,
          TargetFilesEdit.FilesOwnerName]),
        mtConfirmation, [100, lisMove, 101, lisCopy, mrCancel]);
      case MsgResult of
      100: DeleteOld:=true;
      101: DeleteOld:=false;
      else exit;
      end;
    end else begin
      if IDEMessageDialog(lisMoveFiles2,
        Format(lisMoveFileSFromToTheDirectoryOf, [
          IntToStr(MoveFileCount),
          SrcFilesEdit.FilesOwnerName, #13,
          TargetDirectory, #13,
          TargetFilesEdit.FilesOwnerName]),
        mtConfirmation,[mbOk,mbCancel])<>mrOK
      then exit;
      DeleteOld:=true;
    end;

    // fetch used packages
    SrcDirToPkg:=PackageGraph.GetMapSourceDirectoryToPackage;

    // check uses sections
    if not CheckUsesSections then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles CheckUsesSections failed']);
      {$ENDIF}
      exit;
    end;

    if DeleteOld then begin
      // close files and res files in source editor
      if not CloseSrcEditors then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['TPkgManager.MoveFiles CloseSrcEditors failed']);
        {$ENDIF}
        exit;
      end;
    end;

    if (not SrcIsTarget) then begin
      // files will be moved to another package/project
      if not ClearOldCompiledFiles then begin
        {$IFDEF VerbosePkgEditDrag}
        debugln(['TPkgManager.MoveFiles ClearOldCompiledFiles failed']);
        {$ENDIF}
        exit;
      end;
    end;

    // extend unit/include path of LazPackage
    if not ExtendSearchPaths then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles ExtendSearchPaths failed']);
      {$ENDIF}
      exit;
    end;

    // move/copy files
    if not MoveOrCopyFiles then begin
      {$IFDEF VerbosePkgEditDrag}
      debugln(['TPkgManager.MoveFiles MoveOrCopyFiles failed']);
      {$ENDIF}
      exit;
    end;

    Result:=true;
  finally
    SrcDirToPkg.Free;
    UnitFilenameToResFileList.Free;
    AllChangedFilenames.Free;
    ChangedFilenames.Free;
    NewFileToOldOwnedFile.Free;
  end;
end;

function TPkgManager.CopyMoveFiles(Sender: TObject): boolean;
var
  SelDirDlg: TSelectDirectoryDialog;
  FilesEdit: IFilesEditorInterface;
  TargetDir: String;
begin
  Result:=false;
  if Sender is TPackageEditorForm then
    FilesEdit:=TPackageEditorForm(Sender)
  else if Sender is TProjectInspectorForm then
    FilesEdit:=TProjectInspectorForm(Sender)
  else begin
    debugln(['Error: (lazarus) TPkgManager.CopyMoveFiles wrong Sender: ',DbgSName(Sender)]);
    exit;
  end;
  SelDirDlg:=TSelectDirectoryDialog.Create(nil);
  try
    SelDirDlg.InitialDir:=FilesEdit.FilesBaseDirectory;
    SelDirDlg.Title:=lisSelectTargetDirectory;
    SelDirDlg.Options:=SelDirDlg.Options+[ofPathMustExist,ofFileMustExist];
    if not SelDirDlg.Execute then exit;
    TargetDir:=CleanAndExpandDirectory(SelDirDlg.FileName);
    Result:=MoveFiles(FilesEdit,FilesEdit,TargetDir);
  finally
    SelDirDlg.Free;
  end;
end;

constructor TPkgManager.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  OnGetDependencyOwnerDescription:=@GetDependencyOwnerDescription;
  OnGetDependencyOwnerDirectory:=@GetDependencyOwnerDirectory;
  OnPackageFileLoaded:=@PackageFileLoaded;

  // package links
  PkgLinks:=TPackageLinks.Create;
  PkgLinks.UpdateAll;

  // package graph
  PackageGraph:=TLazPackageGraph.Create;
  PackageGraphInterface:=PackageGraph;
  PackageGraph.OnAddPackage:=@PackageGraphAddPackage;
  PackageGraph.OnBeforeCompilePackages:=@DoBeforeCompilePackages;
  PackageGraph.OnBeginUpdate:=@PackageGraphBeginUpdate;
  PackageGraph.OnChangePackageName:=@PackageGraphChangePackageName;
  PackageGraph.OnCheckInterPkgFiles:=@PackageGraphCheckInterPkgFiles;
  PackageGraph.OnDeleteAmbiguousFiles:=@BuildBoss.DeleteAmbiguousFiles;
  PackageGraph.OnDeletePackage:=@PackageGraphDeletePackage;
  PackageGraph.OnDependencyModified:=@PackageGraphDependencyModified;
  PackageGraph.OnEndUpdate:=@PackageGraphEndUpdate;
  PackageGraph.OnTranslatePackage:=@DoTranslatePackage;
  PackageGraph.OnUninstallPackage:=@DoUninstallPackage;

  // package editors
  PackageEditors:=TPackageEditors.Create;
  PackageEditors.OnAddToProject:=@OnPackageEditorAddToProject;
  PackageEditors.OnAfterWritePackage:=@OnAfterWritePackage;
  PackageEditors.OnBeforeReadPackage:=@OnBeforeReadPackage;
  PackageEditors.OnCompilePackage:=@OnPackageEditorCompilePackage;
  PackageEditors.OnCopyMoveFiles:=@OnPackageEditorCopyMoveFiles;
  PackageEditors.OnCreateFpmakeFile:=@OnPackageEditorCreateFpmakeFile;
  PackageEditors.OnCreateMakefile:=@OnPackageEditorCreateMakefile;
  PackageEditors.OnCreateNewFile:=@OnPackageEditorCreateFile;
  PackageEditors.OnDeleteAmbiguousFiles:=@OnPackageEditorDeleteAmbiguousFiles;
  PackageEditors.OnDragDropTreeView:=@OnPackageEditorDragDropTreeView;
  PackageEditors.OnDragOverTreeView:=@OnPackageEditorDragOverTreeView;
  PackageEditors.OnShowFindInFiles:=@OnPackageEditorFindInFiles;
  PackageEditors.OnFreeEditor:=@OnPackageEditorFreeEditor;
  PackageEditors.OnGetIDEFileInfo:=@MainIDE.GetIDEFileState;
  PackageEditors.OnGetUnitRegisterInfo:=@OnPackageEditorGetUnitRegisterInfo;
  PackageEditors.OnInstallPackage:=@OnPackageEditorInstallPackage;
  PackageEditors.OnOpenFile:=@MainIDE.DoOpenMacroFile;
  PackageEditors.OnOpenPackage:=@OnPackageEditorOpenPackage;
  PackageEditors.OnOpenPkgFile:=@OnPackageEditorOpenPkgFile;
  PackageEditors.OnPublishPackage:=@OnPackageEditorPublishPackage;
  PackageEditors.OnRevertPackage:=@OnPackageEditorRevertPackage;
  PackageEditors.OnSavePackage:=@OnPackageEditorSavePackage;
  PackageEditors.OnUninstallPackage:=@OnPackageEditorUninstallPackage;
  PackageEditors.OnViewPackageSource:=@OnPackageEditorViewPkgSource;

  // package macros
  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PKGDIR',nil,@PackageGraph.MacroFunctionCTPkgDir);
  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PKGSRCPATH',nil,@PackageGraph.MacroFunctionCTPkgSrcPath);
  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PKGUNITPATH',nil,@PackageGraph.MacroFunctionCTPkgUnitPath);
  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PKGINCPATH',nil,@PackageGraph.MacroFunctionCTPkgIncPath);
  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PKGNAME',nil,@PackageGraph.MacroFunctionCTPkgName);
  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PKGOUTDIR',nil,@PackageGraph.MacroFunctionCTPkgOutDir);

  LazPackageDescriptors:=TLazPackageDescriptors.Create;
  LazPackageDescriptors.AddDefaultPackageDescriptors;

  // idle handler
  Application.AddOnIdleHandler(@OnApplicationIdle,true);
end;

destructor TPkgManager.Destroy;
begin
  FreeThenNil(LazPackageDescriptors);
  PackageGraph.FreeAutoInstallDependencies;
  FreeThenNil(PackageGraphExplorer);
  FreeThenNil(PackageEditors);
  FreeThenNil(PackageGraph);
  FreeThenNil(PkgLinks);
  FreeThenNil(PackageDependencies);
  inherited Destroy;
end;

procedure TPkgManager.ConnectMainBarEvents;
begin
  with MainIDEBar do begin
    itmPkgNewPackage.OnClick :=@MainIDEitmPkgNewPackageClick;
    itmPkgOpenLoadedPackage.OnClick :=@MainIDEitmPkgOpenLoadedPackageClicked;
    itmPkgOpenPackageFile.OnClick:=@MainIDEitmPkgOpenPackageFileClick;
    itmPkgOpenPackageOfCurUnit.OnClick :=@MainIDEitmPkgOpenPackageOfCurUnitClicked;
    itmPkgAddCurFileToPkg.OnClick:=@MainIDEitmPkgAddCurFileToPkgClick;
    itmPkgAddNewComponentToPkg.OnClick:=@MainIDEitmPkgNewComponentClick;
    itmPkgPkgGraph.OnClick:=@MainIDEitmPkgPkgGraphClick;
    itmPkgPackageLinks.OnClick := @MainIDEitmPackageLinksClicked;
    itmPkgEditInstallPkgs.OnClick:=@MainIDEitmPkgEditInstallPkgsClick;
    {$IFDEF CustomIDEComps}
    itmCompsConfigCustomComps.OnClick :=@MainIDEitmConfigCustomCompsClicked;
    {$ENDIF}
  end;
  
  SetRecentPackagesMenu;

  IDEWindowCreators.Add(NonModalIDEWindowNames[nmiwPkgGraphExplorer],
                        nil,@CreateIDEWindow,'250','200','','');
  IDEWindowCreators.Add(PackageEditorWindowPrefix,
                        nil,@CreateIDEWindow,'250','200','','');
  RegisterStandardPackageEditorMenuItems;
end;

procedure TPkgManager.ConnectSourceNotebookEvents;
begin

end;

procedure TPkgManager.SetupMainBarShortCuts;
begin

end;

procedure TPkgManager.SetRecentPackagesMenu;
begin
  MainIDE.SetRecentSubMenu(itmPkgOpenRecent,
     EnvironmentOptions.RecentPackageFiles,@MainIDEitmOpenRecentPackageClicked);
end;

procedure TPkgManager.AddToMenuRecentPackages(const Filename: string);
begin
  EnvironmentOptions.AddToRecentPackageFiles(Filename);
  SetRecentPackagesMenu;
  MainIDE.SaveEnvironment;
end;

procedure TPkgManager.SaveSettings;
begin

end;

function TPkgManager.GetDefaultSaveDirectoryForFile(const Filename: string): string;
var
  APackage: TLazPackage;
  PkgFile: TPkgFile;
begin
  Result:='';
  if FilenameIsAbsolute(Filename) then begin
    Result:=ExtractFilePath(Filename);
    exit;
  end;
  PkgFile:=PackageGraph.FindFileInAllPackages(Filename,true,true);
  if PkgFile=nil then exit;
  APackage:=PkgFile.LazPackage;
  if APackage.IsVirtual or (not APackage.HasDirectory) then exit;
  Result:=APackage.Directory;
end;

function TPkgManager.GetPublishPackageDir(APackage: TLazPackage): string;
begin
  Result:=APackage.PublishOptions.DestinationDirectory;
  if IDEMacros.SubstituteMacros(Result) then begin
    if FilenameIsAbsolute(Result) then begin
      Result:=AppendPathDelim(TrimFilename(Result));
    end else begin
      Result:='';
    end;
  end else begin
    Result:='';
  end;
end;

procedure TPkgManager.LoadInstalledPackages;
begin
  IDEComponentPalette.BeginUpdate(true);
  try
    PackageGraph.LoadStaticBasePackages;
    LoadStaticCustomPackages;
    LoadAutoInstallPackages;
  finally
    IDEComponentPalette.EndUpdate;
  end;
end;

procedure TPkgManager.UnloadInstalledPackages;
var
  Dependency: TPkgDependency;
begin
  // unbind and free auto installed packages
  while PackageGraph.FirstAutoInstallDependency<>nil do begin
    Dependency:=PackageGraph.FirstAutoInstallDependency;
    Dependency.RequiredPackage:=nil;
    Dependency.RemoveFromList(PackageGraph.FirstAutoInstallDependency,pdlRequires);
    Dependency.Free;
  end;
end;

procedure TPkgManager.ProcessCommand(Command: word; var Handled: boolean);
begin
  Handled:=true;
  case Command of
  ecOpenPackage: MainIDEitmPkgOpenLoadedPackageClicked(Self);
  ecOpenPackageFile: MainIDEitmPkgOpenPackageFileClick(Self);
  ecOpenPackageOfCurUnit: MainIDEitmPkgOpenPackageOfCurUnitClicked(Self);
  ecAddCurFileToPkg: MainIDEitmPkgAddCurFileToPkgClick(Self);
  ecPackageGraph: MainIDEitmPkgPkgGraphClick(Self);
  ecEditInstallPkgs: MainIDEitmPkgEditInstallPkgsClick(Self);
  else
    Handled:=false;
  end;
end;

procedure TPkgManager.OnSourceEditorPopupMenu(const AddMenuItemProc: TAddMenuItemProc);
var
  APackage: TIDEPackage;
begin
  GetPackageOfCurrentSourceEditor(APackage);
  if APackage<>nil then
    AddMenuItemProc(Format(lisOpenPackage2, [APackage.Name]), true,
                    @OnOpenPackageForCurrentSrcEditFile);
end;

procedure TPkgManager.TranslateResourceStrings;
var
  PkgList: TFPList;
  i: Integer;
begin
  PkgList:=nil;
  PackageGraph.GetAllRequiredPackages(nil,
    PackageGraph.FirstAutoInstallDependency,PkgList);
  if PkgList=nil then exit;
  for i:=0 to PkgList.Count-1 do
    if TObject(PkgList[i]) is TLazPackage then
      DoTranslatePackage(TLazPackage(PkgList[i]));
  PkgList.Free;
end;

procedure TPkgManager.DoTranslatePackage(APackage: TLazPackage);
var
  TranslatedUnits: TStringHashList;
  
  function UnitTranslated(const AnUnitName: string): boolean;
  begin
    Result:=(TranslatedUnits<>nil) and (TranslatedUnits.Find(AnUnitName)>=0);
  end;
  
  procedure TranslateUnit(const AFilename, AnUnitName: string);
  begin
    //DebugLn(['TranslateUnit AFilename="',AFilename,'" AnUnitName="',AnUnitName,'"']);
    if TranslatedUnits=nil then
      TranslatedUnits:=TStringHashList.Create(false);
    TranslatedUnits.Add(AnUnitName);
    TranslateUnitResourceStrings(AnUnitName,AFilename);
  end;

  function GetPOFilenameParts(const Filename: string;
    out AUnitName, Language: string): boolean;
  var
    UnitNameEnd: Integer;
    LangEnd: Integer;
  begin
    Result:=false;
    AUnitName:='';
    Language:='';
    UnitNameEnd:=1;
    while (UnitNameEnd<=length(Filename)) and (Filename[UnitNameEnd]<>'.') do
      inc(UnitNameEnd);
    if (UnitNameEnd=1) then exit;
    LangEnd:=UnitNameEnd+1;
    while (LangEnd<=length(Filename)) and (Filename[LangEnd]<>'.') do
      inc(LangEnd);
    if LangEnd<>length(Filename)-2 then exit;
    AUnitName:=copy(Filename,1,UnitNameEnd-1);
    Language:=copy(Filename,UnitNameEnd+1,LangEnd-UnitNameEnd-1);
    Result:=IsValidUnitName(AUnitName) and (Language<>'');
    //DebugLn(['GetPOFilenameParts AUnitName=',AUnitName,' Language=',Language,' Result=',Result]);
  end;
  
  procedure TranslateWithFileMask(APackage: TLazPackage;
    const Directory, Language: string);
  var
    CurUnitName: string;
    CurLang: string;
    Files: TStrings;
    Filename: String;
  begin
    if Language='' then exit;
    Files:=nil;
    try
      CodeToolBoss.DirectoryCachePool.GetListing(Directory,Files,false);
      for Filename in Files do begin
        if CompareFileExt(Filename,'.po',false)<>0 then continue;
        if GetPOFilenameParts(Filename,CurUnitName,CurLang)
        and (CurLang=Language)
        and (not UnitTranslated(CurUnitName))
        and (APackage.FindUnit(CurUnitName)<>nil)
        then begin
          TranslateUnit(AppendPathDelim(Directory)+Filename,CurUnitName);
        end;
      end;
    finally
      Files.Free;
    end;
  end;

var
  Directory: String;
  Lang: String;
  FallbackLang: String;
  Language: String;
begin
  //DebugLn(['TPkgManager.DoTranslatePackage ',APackage.Name,' from ', APackage.POOutputDirectory]);
  if (APackage.POOutputDirectory='') then exit;
  Directory:=AppendPathDelim(APackage.GetPOOutDirectory);

  Language:=EnvironmentOptions.LanguageID;
  if Language='' then begin
    Lang:=SystemLanguageID1;
    FallbackLang:=SystemLanguageID2;
  end else begin
    Lang:=Language;
    FallbackLang:='';
  end;
  
  //DebugLn(['TPkgManager.DoTranslatePackage ', APackage.Name,' from ', APackage.POOutputDirectory,', Translated=',APackage.Translated,' Lang=',Lang]);
  if APackage.Translated=Lang then exit;
  APackage.Translated:=Lang;
  
  TranslatedUnits:=nil;
  try
    //DebugLn(['TPkgManager.DoTranslatePackage ',APackage.Name,' Directory=',Directory,' Lang=',Lang,' FallbackLang=',FallbackLang]);
    TranslateWithFileMask(APackage,Directory,Lang);
    if FallbackLang<>Lang then
      TranslateWithFileMask(APackage,Directory,FallbackLang);
  finally
    TranslatedUnits.Free;
    MainIDEInterface.PackageTranslated(APackage);
  end;
end;

function TPkgManager.AddPackageToGraph(APackage: TLazPackage): TModalResult;
var
  ConflictPkg: TLazPackage;
  Link: TPackageLink;
begin
  // check Package Name
  if not IsValidPkgName(APackage.Name) then begin
    Result:=IDEMessageDialog(lisPkgMangInvalidPackageName2,
      Format(lisPkgMangThePackageNameOfTheFileIsInvalid,
             [APackage.Name, LineEnding, APackage.Filename]),
      mtError,[mbCancel,mbAbort]);
    exit;
  end;

  // check if Package with same name is already loaded
  ConflictPkg:=PackageGraph.FindPackageWithName(APackage.Name,nil);
  if ConflictPkg<>nil then begin
    if not PackageGraph.PackageCanBeReplaced(ConflictPkg,APackage) then begin
      Result:=IDEMessageDialog(lisPkgMangPackageConflicts,
        Format(lisPkgMangThereIsAlreadyAPackageLoadedFromFile,
          [ConflictPkg.IDAsString, LineEnding, ConflictPkg.Filename, LineEnding, LineEnding]),
        mtError,[mbCancel,mbAbort]);
      exit;
    end;
    
    if ConflictPkg.Modified and (not ConflictPkg.ReadOnly) then begin
      Result:=IDEMessageDialog(lisPkgMangSavePackage,
        Format(lisPkgMangLoadingPackageWillReplacePackage, [
          APackage.IDAsString, ConflictPkg.IDAsString, LineEnding,
          ConflictPkg.Filename, LineEnding, LineEnding+LineEnding, ConflictPkg.Filename]),
        mtConfirmation,[mbYes,mbNo,mbCancel,mbAbort]);
      if Result=mrNo then Result:=mrOk;
      if Result=mrYes then begin
        Result:=DoSavePackage(ConflictPkg,[]);
      end;
      if Result<>mrOk then exit;
    end;
    
    // replace package
    PackageGraph.ReplacePackage(ConflictPkg,APackage);
  end else begin
    // add to graph
    PackageGraph.AddPackage(APackage);
  end;

  // save package file links
  //DebugLn(['TPkgManager.AddPackageToGraph ',APackage.Name]);
  Link:=PkgLinks.AddUserLink(APackage);
  if Link<>nil then
  begin
    //debugln(['Hint: (lazarus) TPkgManager.AddPackageToGraph LinkLastUsed=',DateToCfgStr(Link.LastUsed,DateTimeAsCfgStrFormat),' ',dbgs(Link.Origin)]);
    PkgLinks.SaveUserLinks;
  end;

  Result:=mrOk;
end;

function TPkgManager.OpenProjectDependencies(AProject: TProject;
  ReportMissing: boolean): TModalResult;
var
  BrokenDependencies: TFPList;
begin
  Result:=mrOk;
  PackageGraph.OpenRequiredDependencyList(AProject.FirstRequiredDependency);
  if ReportMissing then begin
    BrokenDependencies:=PackageGraph.FindAllBrokenDependencies(nil,
                                             AProject.FirstRequiredDependency);
    if BrokenDependencies<>nil then begin
      Result:=ShowBrokenDependenciesReport(BrokenDependencies);
      BrokenDependencies.Free;
    end;
  end;
  PkgLinks.SaveUserLinks;
end;

function TPkgManager.AddProjectDependency(AProject: TProject;
  APackage: TLazPackage; OnlyTestIfPossible: boolean): TModalResult;
var
  NewDependency: TPkgDependency;
  ProvidingAPackage: TLazPackage;
  ConflictDependency: TPkgDependency;
begin
  Result:=mrCancel;

  // check if there is a dependency, that requires another version
  ConflictDependency:=PackageGraph.FindConflictRecursively(
    AProject.FirstRequiredDependency,APackage);
  if ConflictDependency<>nil then begin
    DebugLn(['Error: (lazarus) [TPkgManager.AddProjectDependency] ',APackage.IDAsString,' conflicts with ',ConflictDependency.AsString]);
    Result:=mrCancel;
    exit;
  end;

  // check if the dependency is already there
  if FindDependencyByNameInList(AProject.FirstRequiredDependency,pdlRequires,
    APackage.Name)<>nil
  then begin
    // package already there
    Result:=mrOk;
    exit;
  end;

  ProvidingAPackage:=PackageGraph.FindPackageProvidingName(
    AProject.FirstRequiredDependency,APackage.Name);
  if ProvidingAPackage<>nil then
  begin
    // package is already provided by another package
    DebugLn(['Error: (lazarus) [TPkgManager.AddProjectDependency] ',APackage.Name,' is already provided by ',ProvidingAPackage.IDAsString]);
    Result:=mrOk;
    exit;
  end;

  if OnlyTestIfPossible then
    exit(mrOk);
  // add a dependency for the package to the project
  NewDependency:=APackage.CreateDependencyWithOwner(AProject);
  Result:=AddProjectDependency(AProject,NewDependency);
end;

function TPkgManager.AddProjectDependency(AProject: TProject;
  ADependency: TPkgDependency): TModalResult;
begin
  Result:=mrOk;
  AProject.AddRequiredDependency(ADependency);
  PackageGraph.OpenDependency(ADependency,false);
  if (ADependency.RequiredPackage<>nil)
  and (not ADependency.RequiredPackage.Missing)
  and ADependency.RequiredPackage.AddToProjectUsesSection
  and ((ADependency.RequiredPackage.PackageType<>lptDesignTime)
       or (pfUseDesignTimePackages in AProject.Flags))
  then begin
    AddUnitToProjectMainUsesSection(AProject,
      ExtractFileNameOnly(ADependency.RequiredPackage.GetCompileSourceFilename),'');
  end;
end;

procedure TPkgManager.AddProjectRegCompDependency(AProject: TProject;
  ARegisteredComponent: TRegisteredComponent);
var
  PkgFile: TPkgFile;
  APackage: TLazPackage;
begin
  if not (ARegisteredComponent is TPkgComponent) then exit;
  
  PkgFile:=TPkgComponent(ARegisteredComponent).PkgFile;
  if (PkgFile=nil) then exit;

  APackage:=PkgFile.LazPackage;
  APackage:=TLazPackage(RedirectPackageDependency(APackage));

  AddProjectDependency(AProject,APackage);
end;

procedure TPkgManager.AddProjectLCLDependency(AProject: TProject);
begin
  AddProjectDependency(AProject,PackageGraph.LCLPackage);
end;

function TPkgManager.AddProjectDependencies(AProject: TProject;
  const Packages: string; OnlyTestIfPossible: boolean): TModalResult;
var
  RequiredPackages: TStrings;
  i: Integer;
  PkgName: string;
  APackage: TLazPackage;
begin
  Result:=mrOk;
  RequiredPackages:=SplitString(Packages,';');
  try
    for i:=0 to RequiredPackages.Count-1 do begin
      PkgName:=Trim(RequiredPackages[i]);
      if not IsValidPkgName(PkgName) then continue;
      APackage:=PackageGraph.FindPackageWithName(PkgName,nil);
      if APackage=nil then begin
        DebugLn(['Error: (lazarus) [TPkgManager.AddProjectDependencies] package not found: ',PkgName]);
        if OnlyTestIfPossible then
          exit(mrCancel);
        continue;
      end;
      Result:=AddProjectDependency(AProject,APackage,OnlyTestIfPossible);
      if Result<>mrOk then exit;
    end;
  finally
    RequiredPackages.Free;
  end;
end;

function TPkgManager.CheckProjectHasInstalledPackages(AProject: TProject; 
  Interactive: boolean): TModalResult;
var
  MissingUnits: TFPList;
  i: Integer;
  PkgFile: TPkgFile;
  Msg: String;
  PkgList: TObjectList;
begin
  Result:=mrOk;
  MissingUnits:=PackageGraph.FindNotInstalledRegisterUnits(nil,
                                              AProject.FirstRequiredDependency);
  if MissingUnits<>nil then begin
    if Interactive then begin 
      Msg:=Format(lisProbablyYouNeedToInstallSomePackagesForBeforeConti,
        [LineEnding+LineEnding, LineEnding, LineEnding+LineEnding]) + LineEnding+LineEnding;
      PkgList:=TObjectList.Create(false);
      try
        for i:=0 to MissingUnits.Count-1 do begin
          PkgFile:=TPkgFile(MissingUnits[i]);
          if PkgList.IndexOf(PkgFile.LazPackage)<0 then
            PkgList.Add(PkgFile.LazPackage);
          Msg:=Format(lisUnitInPackage,
            [Msg, PkgFile.Unit_Name, PkgFile.LazPackage.IDAsString]) + LineEnding;
        end;
        Result:=IDEQuestionDialog(lisPackageNeedsInstallation,
          Msg,mtWarning,
          [mrIgnore,'Continue without install',mrYes,'Install these packages',mrCancel,'Cancel','IsDefault']);
        if Result=mrIgnore then begin
          // continue
        end else if Result=mrYes then
        begin
          // install
          AProject.AutoOpenDesignerFormsDisabled:=true;
          InstallPackages(PkgList,[piiifRebuildIDE]);
          Result:=mrAbort;
        end else begin
          // do not warn again
          AProject.AutoOpenDesignerFormsDisabled:=true;
        end;
      finally
        PkgList.Free;
      end;
    end else
      Result:=mrCancel;    
    MissingUnits.Free;
  end;
end;

function TPkgManager.ShowConfigureCustomComponents: TModalResult;
begin
  Result:=ShowConfigureCustomComponentDlg(EnvironmentOptions.GetParsedLazarusDirectory);
end;

function TPkgManager.DoNewPackage: TModalResult;
var
  NewPackage: TLazPackage;
begin
  Result:=mrCancel;
  // create a new package with standard dependencies
  NewPackage:=PackageGraph.CreateNewPackage(NameToValidIdentifier(lisPkgMangNewPackage));
  PackageGraph.AddDependencyToPackage(NewPackage,
                PackageGraph.FCLPackage.CreateDependencyWithOwner(NewPackage));
  NewPackage.Modified:=false;

  // open a package editor
  PackageEditors.OpenEditor(NewPackage,true);

  Result:=DoSavePackage(NewPackage,[psfSaveAs]);
end;

function TPkgManager.DoShowLoadedPkgDlg: TModalResult;
var
  APackage: TLazPackage;
begin
  Result:=ShowOpenLoadedPkgDlg(APackage);
  if (Result<>mrOk) then exit;
  Result:=DoOpenPackage(APackage,[pofAddToRecent],false);
end;

function TPkgManager.DoOpenPackage(APackage: TLazPackage;
  Flags: TPkgOpenFlags; ShowAbort: boolean): TModalResult;
var
  AFilename: String;
begin
  AFilename:=APackage.Filename;
  //debugln(['TPkgManager.DoOpenPackage ',AFilename]);
  
  // revert: if possible and wanted
  if (pofRevert in Flags) and (FileExistsCached(AFilename)) then begin
    Result:=DoOpenPackageFile(AFilename,Flags,ShowAbort);
    exit;
  end;

  // open a package editor
  PackageEditors.OpenEditor(APackage,true);

  // add to recent packages
  if (pofAddToRecent in Flags) then begin
    AFilename:=APackage.Filename;
    if FileExistsCached(AFilename) then begin
      AddToMenuRecentPackages(AFilename);
    end;
  end;

  Result:=mrOk;
end;

function TPkgManager.DoOpenPackageWithName(const APackageName: string;
  Flags: TPkgOpenFlags; ShowAbort: boolean): TModalResult;
var
  APackage: TLazPackage;
  NewDependency: TPkgDependency;
  LoadResult: TLoadPackageResult;
begin
  Result:=mrCancel;
  if not IsValidPkgName(APackageName) then exit;
  NewDependency:=TPkgDependency.Create;
  try
    NewDependency.PackageName:=APackageName;
    LoadResult:=PackageGraph.OpenDependency(NewDependency,ShowAbort);
    if LoadResult<>lprSuccess then exit;
  finally
    NewDependency.Free;
  end;
  APackage:=PackageGraph.FindPackageWithName(APackageName,nil);
  if APackage=nil then exit;
  Result:=DoOpenPackage(APackage,Flags,ShowAbort);
end;

function TPkgManager.DoOpenPackageFile(AFilename: string; Flags: TPkgOpenFlags;
  ShowAbort: boolean): TModalResult;
var
  APackage: TLazPackage;
  XMLConfig: TXMLConfig;
  AlternativePkgName: String;
  Code: TCodeBuffer;
  OpenEditor: Boolean;
  
  procedure DoQuestionDlg(const Caption, Message: string);
  begin
    if pofMultiOpen in Flags then
      Result:=IDEQuestionDialog(Caption, Message,
        mtError, [mrIgnore, lisPkgMangSkipThisPackage, mrAbort])
    else
      Result:=IDEQuestionDialog(Caption, Message,
        mtError,[mrAbort])
  end;
begin
  // replace macros
  if pofConvertMacros in Flags then begin
    if not GlobalMacroList.SubstituteStr(AFilename) then exit(mrCancel);
  end;

  AFilename:=GetPhysicalFilenameCached(CleanAndExpandFilename(AFilename),false);

  // check file extension
  if (CompareFileExt(AFilename,'.lpk',false)<>0)
  and (not (pofRevert in Flags)) then begin
    DoQuestionDlg(lisPkgMangInvalidFileExtension,
      Format(lisPkgMangTheFileIsNotALazarusPackage, [AFilename]));
    RemoveFromRecentList(AFilename,EnvironmentOptions.RecentPackageFiles,rltFile);
    SetRecentPackagesMenu;
    exit;
  end;
  
  // check filename
  AlternativePkgName:=ExtractFileNameOnly(AFilename);
  if (not (pofRevert in Flags))
  and (not IsValidPkgName(AlternativePkgName))
  then begin
    DoQuestionDlg(lisPkgMangInvalidPackageFilename,
      Format(lisPkgMangThePackageFileNameInIsNotAValidLazarusPackageName,
             [AlternativePkgName, LineEnding, AFilename]));
    RemoveFromRecentList(AFilename,EnvironmentOptions.RecentPackageFiles,rltFile);
    SetRecentPackagesMenu;
    exit;
  end;

  // add to recent packages
  if pofAddToRecent in Flags then begin
    AddToMenuRecentPackages(AFilename);
  end;

  OpenEditor:=not (pofDoNotOpenEditor in Flags);

  // check if package is already loaded
  APackage:=PackageGraph.FindPackageWithFilename(AFilename);
  if (APackage=nil) or (pofRevert in Flags) then begin
    // package not yet loaded or it should be reloaded
    
    if (pofRevert in Flags)
    and ((APackage=nil) or (APackage.Editor=nil)) then
      OpenEditor:=false;
    
    if not FileExistsUTF8(AFilename) then begin
      IDEMessageDialog(lisFileNotFound,
        Format(lisPkgMangFileNotFound, [AFilename]),
        mtError,[mbCancel]);
      RemoveFromRecentList(AFilename,EnvironmentOptions.RecentPackageFiles,rltFile);
      SetRecentPackagesMenu;
      Result:=mrCancel;
      exit;
    end;

    // create a new package
    Result:=mrCancel;
    APackage:=TLazPackage.Create;
    try

      // load the package file
      try
        XMLConfig:=TCodeBufXMLConfig.Create(nil);
        try
          APackage.Filename:=AFilename;
          Result:=LoadXMLConfigFromCodeBuffer(AFilename,XMLConfig,
                               Code,[lbfUpdateFromDisk,lbfRevert],ShowAbort);
          if Result<>mrOk then exit;
          APackage.LPKSource:=Code;
          APackage.LoadFromXMLConfig(XMLConfig,'Package/');
        finally
          XMLConfig.Free;
        end;
      except
        on E: Exception do begin
          DoQuestionDlg(lisPkgMangErrorReadingPackage,
            Format(lisPkgUnableToReadPackageFileError, [AFilename, LineEnding, E.Message]));
          exit;
        end;
      end;

      // newly loaded is not modified
      APackage.Modified:=false;

      // check if package name and file name correspond
      if (SysUtils.CompareText(AlternativePkgName,APackage.Name)<>0) then begin
        Result:=IDEMessageDialog(lisPkgMangFilenameDiffersFromPackagename,
          Format(lisPkgMangTheFilenameDoesNotCorrespondToThePackage,
            [ExtractFileName(AFilename), APackage.Name, LineEnding, AlternativePkgName]),
          mtConfirmation,[mbYes,mbCancel,mbAbort]);
        if Result<>mrYes then exit;
        APackage.Name:=AlternativePkgName;
      end;
      
      // integrate it into the graph
      Result:=AddPackageToGraph(APackage);
    finally
      if Result<>mrOk then APackage.Free;
    end;
  end;

  if OpenEditor then
    Result:=DoOpenPackage(APackage,[],ShowAbort)
  else
    Result:=mrOk;

  PkgLinks.SaveUserLinks;

  // the source editor highlighting depends on the compiler mode
  MainIDEInterface.UpdateHighlighters;
end;

procedure TPkgManager.OpenHiddenModifiedPackages;
var
  i: Integer;
  APackage: TLazPackage;
begin
  for i:=0 to PackageGraph.Count-1 do begin
    APackage:=PackageGraph.Packages[i];
    if (APackage.Editor=nil) and APackage.Modified
    and (APackage.UserIgnoreChangeStamp<>APackage.ChangeStamp) then begin
      PackageEditors.OpenEditor(APackage,false);
    end;
  end;
end;

function TPkgManager.DoSavePackage(APackage: TLazPackage;
  Flags: TPkgSaveFlags): TModalResult;
var
  XMLConfig: TCodeBufXMLConfig;
  PkgLink: TPackageLink;
  Code: TCodeBuffer;
begin
  // do not save during compilation
  if not (MainIDE.ToolStatus in [itNone,itDebugger]) then begin
    Result:=mrAbort;
    exit;
  end;
  
  if APackage.IsVirtual then Include(Flags,psfSaveAs);

  if not ( (psfSaveAs in Flags) or APackage.ReadOnly or APackage.Modified
          or FileExistsCached(APackage.Filename)
          or (APackage.UserIgnoreChangeStamp<>APackage.ChangeStamp )) then
  begin
    Result:=mrOk;
    exit;
  end;

  // save new or changed files
  Result:=SavePackageFiles(APackage);
  if Result<>mrOk then exit;

  // warn about missing files
  Result:=WarnAboutMissingPackageFiles(APackage);
  if Result<>mrOk then exit;

  // save editor files to codetools
  MainIDE.SaveSourceEditorChangesToCodeCache(nil);

  // save package
  if (psfSaveAs in Flags) then begin
    Result:=DoShowSavePackageAsDialog(APackage);
    if Result<>mrOk then exit;
  end;
  
  // backup old file
  Result:=BuildBoss.BackupFile(APackage.Filename);
  if Result=mrAbort then exit;

  // delete ambiguous files
  Result:=BuildBoss.DeleteAmbiguousFiles(APackage.Filename);
  if Result=mrAbort then exit;

  // save
  try
    XMLConfig:=TCodeBufXMLConfig.Create(nil);
    try
      XMLConfig.Clear;
      XMLConfig.KeepFileAttributes:=true;
      APackage.SaveToXMLConfig(XMLConfig,'Package/');
      Code:=nil;
      Result:=SaveXMLConfigToCodeBuffer(APackage.Filename,XMLConfig,Code,true);
      if Result<>mrOk then exit;
      APackage.LPKSource:=Code;
      PkgLink:=PkgLinks.AddUserLink(APackage);
      if PkgLink<>nil then begin
        PkgLink.LPKFileDate:=FileDateToDateTimeDef(FileAgeUTF8(APackage.Filename));
        PkgLink.LPKFileDateValid:=true;
        PkgLinks.SaveUserLinks;
      end;
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      Result:=IDEMessageDialog(lisPkgMangErrorWritingPackage,
        Format(lisPkgMangUnableToWritePackageToFileError,
          [APackage.IDAsString, LineEnding, APackage.Filename, LineEnding, E.Message]),
        mtError,[mbAbort,mbCancel]);
      exit;
    end;
  end;

  // success
  APackage.Modified:=false;
  // add to recent
  if (psfSaveAs in Flags) then begin
    AddToMenuRecentPackages(APackage.Filename);
  end;

  if APackage.Editor<>nil then
    APackage.Editor.UpdateAll(true);
  Result:=mrOk;
end;

procedure TPkgManager.DoShowPackageGraph(Show: boolean);
begin
  if PackageGraphExplorer=nil then begin
    PackageGraphExplorer:=TPkgGraphExplorerDlg.Create(Application);
    PackageGraphExplorer.OnOpenPackage:=@PackageGraphExplorerOpenPackage;
    PackageGraphExplorer.OnOpenProject:=@PackageGraphExplorerOpenProject;
    PackageGraphExplorer.OnUninstallPackage:=@PackageGraphExplorerUninstallPackage;
  end;
  if Show then
    IDEWindowCreators.ShowForm(PackageGraphExplorer,true);
end;

function TPkgManager.DoCloseAllPackageEditors: TModalResult;
var
  APackage: TLazPackage;
begin
  while PackageEditors.Count>0 do begin
    APackage:=PackageEditors.Editors[PackageEditors.Count-1].LazPackage;
    Result:=DoClosePackageEditor(APackage);
    if Result<>mrOk then exit;
  end;
  Result:=mrOk;
end;

procedure TPkgManager.DoShowPackageGraphPathList(PathList: TFPList);
begin
  DoShowPackageGraph(true);
  PackageGraphExplorer.ShowPath(PathList);
end;

function TPkgManager.ShowBrokenDependenciesReport(Dependencies: TFPList): TModalResult;
var
  Msg: String;
  i: Integer;
  ADependency: TPkgDependency;
begin
  Result:=mrOk;
  if (Dependencies=nil) or (Dependencies.Count=0) then exit;
  if Dependencies.Count=1 then
    Msg:=lisPkgMangTheFollowingPackageFailedToLoad
  else
    Msg:=lisPkgMangTheFollowingPackagesFailedToLoad;
  Msg:=Msg+LineEnding+LineEnding;
  for i:=0 to Dependencies.Count-1 do begin
    ADependency:=TPkgDependency(Dependencies[i]);
    Msg:=Msg+ADependency.AsString+LineEnding;
  end;
  
  // give some hints
  ADependency:=TPkgDependency(Dependencies[0]);
  if (ADependency.Owner is TProject) then begin
    // broken dependency used by project -> show project inspector
    if ADependency.Owner=Project1 then begin
      MainIDE.DoShowProjectInspector;
      Msg:=Format(lisSeeProjectProjectInspector, [Msg]);
    end;
  end;
  
  Result:=IDEMessageDialog(lisMissingPackages, Msg, mtError, [mbOk]);
end;

function TPkgManager.CheckUserSearchPaths(aCompilerOptions: TBaseCompilerOptions
  ): TModalResult;
var
  aPackage: TLazPackage;
  aProject: TProject;
  CurUnitPath: String;
  CurIncPath: String;
  CurSrcPath: String;
  CurOutPath: String;
  SrcDirToPkg: TFilenameToPointerTree;

  function CheckPathContainsDirOfOtherPkg(Option: TParsedCompilerOptString
    ): TModalResult;
  var
    aSearchPath: String;
    p: Integer;
    Dir: String;
    OtherPackage: TLazPackage;
    aType: String;
    s: String;
  begin
    Result:=mrOk;
    case Option of
    pcosIncludePath:
      begin
        aType:='include files search path';
        aSearchPath:=CurIncPath;
      end;
    pcosUnitPath:
      begin
        aType:='other unit files search path (aka unit path)';
        aSearchPath:=CurUnitPath;
      end;
    pcosSrcPath:
      begin
        aType:='other sources path';
        aSearchPath:=CurSrcPath;
      end;
    else
      exit;
    end;
    p:=1;
    repeat
      Dir:=GetNextDirectoryInSearchPath(aSearchPath,p);
      if Dir='' then break;
      Dir:=ChompPathDelim(Dir);
      if not FilenameIsAbsolute(Dir) then continue;
      OtherPackage:=TLazPackage(SrcDirToPkg[Dir]);
      if (OtherPackage<>nil) and (OtherPackage<>aPackage) then begin
        // search path contains source directory of another package
        if Option=pcosIncludePath then;
        s:=aType+' of "'+aCompilerOptions.GetOwnerName+'" contains "'+Dir+'", which belongs to package "'+OtherPackage.Name+'"';
        debugln(['Warning: (lazarus) [TPkgManager.CheckUserSearchPaths]: ',s]);
        { ToDo: find out
           - which path it is in the unparsed path
           - if there is already the dependency
           - if the dependency can be added
           and ask the user to delete the path and to add the dependency

           if the user has already answered this question in the past, just warn }
        // warn user
        IDEMessagesWindow.AddCustomMessage(mluWarning,s);
        exit;
      end;
    until false;
  end;

  function CheckOutPathContainsSources: TModalResult;
  var
    Files: TStrings;
    i: Integer;
    aFilename: String;
    s: String;
  begin
    Result:=mrOk;
    if aPackage=nil then exit;
    if not FilenameIsAbsolute(CurOutPath) then exit;
    Files:=nil;
    CodeToolBoss.DirectoryCachePool.GetListing(CurOutPath,Files,false);
    try
      for i:=0 to Files.Count-1 do begin
        aFilename:=Files[i];
        if FilenameIsPascalUnit(aFilename) then begin
          // warning: packages output path contain unit source
          s:='output directory of '+aCompilerOptions.GetOwnerName+' contains Pascal unit source "'+aFilename+'"';
          debugln(['Warning: (lazarus) [CheckOutPathContainsSources]: ',s]);
          { ToDo: if the OutPath is not the default: ask user and change it }
          IDEMessagesWindow.AddCustomMessage(mluWarning,s);
          exit;
        end;
      end;
    finally
      Files.Free;
    end;
  end;

  function CheckSrcPathIsInUnitPath: TModalResult;
  // warn: SrcPath should not contain directories of UnitPath
  var
    p: Integer;
    UnparsedUnitPath: String;
    UnparsedSrcPath: String;
    Dir: String;
    s: String;
  begin
    Result:=mrOk;
    UnparsedUnitPath:=aCompilerOptions.OtherUnitFiles;
    UnparsedSrcPath:=aCompilerOptions.SrcPath;
    p:=1;
    repeat
      Dir:=GetNextDirectoryInSearchPath(UnparsedSrcPath,p);
      if Dir='' then exit;
      if SearchDirectoryInSearchPath(UnparsedUnitPath,Dir)>0 then begin
        // Note: when changing this, update TQuickFixSrcPathOfPkgContains_OpenPkg
        s:=Format(lisOtherSourcesPathOfPackageContainsDirectoryWhichIsA, [
          aCompilerOptions.GetOwnerName, Dir]);
        debugln(['Warning: (lazarus) [CheckSrcPathIsInUnitPath]: ',s]);
        { ToDo: ask user and remove dir from unit path }
        IDEMessagesWindow.AddCustomMessage(mluWarning,s);
        exit;
      end;
    until false;
  end;

begin
  Result:=mrOk;
  if aCompilerOptions.CompilerPath='' then exit; // not a normal Pascal project

  aPackage:=nil;
  aProject:=nil;
  if aCompilerOptions.Owner is TLazPackage then
    aPackage:=TLazPackage(aCompilerOptions.Owner)
  else if aCompilerOptions.Owner is TProject then
    aProject:=TProject(aCompilerOptions.Owner);
  if (aPackage=nil) and (aProject=nil) then exit;

  CurUnitPath:=aCompilerOptions.ParsedOpts.GetParsedValue(pcosUnitPath);
  CurIncPath:=aCompilerOptions.ParsedOpts.GetParsedValue(pcosIncludePath);
  CurSrcPath:=aCompilerOptions.ParsedOpts.GetParsedValue(pcosSrcPath);
  CurOutPath:=aCompilerOptions.ParsedOpts.GetParsedValue(pcosOutputDir);
  //debugln(['TPkgManager.CheckUserSearchPaths CompOpts=',aCompilerOptions.GetOwnerName,' UnitPath="',CurUnitPath,'" IncPath="',CurIncPath,'" SrcPath="',CurSrcPath,'" OutPath="',CurOutPath,'"']);

  // create mapping source-directory to package
  SrcDirToPkg:=PackageGraph.GetMapSourceDirectoryToPackage(aPackage);
  try
    Result:=CheckPathContainsDirOfOtherPkg(pcosUnitPath);
    if Result<>mrOk then exit;

    Result:=CheckPathContainsDirOfOtherPkg(pcosSrcPath);
    if Result<>mrOk then exit;

    Result:=CheckOutPathContainsSources;
    if Result<>mrOk then exit;

    Result:=CheckSrcPathIsInUnitPath;
    if Result<>mrOk then exit;

    // ToDo: check if SrcPath is in inherited SrcPath
    // ToDo: check if UnitPath is in inherited UnitPath
  finally
    SrcDirToPkg.Free;
  end;
end;

procedure TPkgManager.RebuildDefineTemplates;
begin
  PackageGraph.RebuildDefineTemplates;
end;

procedure TPkgManager.LazarusSrcDirChanged;
const
  LazDirMacro = '$(LazarusDir)';
var
  NewLazarusSrcDir: String;
  OldLazarusSrcDir: String;
  VisitedPkgs: TStringToStringTree;
  ReloadPkgs: TStringList;

  function PkgInOldLazarusDir(APackage: TLazPackage): boolean;
  begin
    Result:=FileIsInPath(APackage.Filename,OldLazarusSrcDir)
      or PackageGraph.IsStaticBasePackage(APackage.Name)
      or (SysUtils.CompareText(copy(APackage.Filename,1,length(LazDirMacro)),LazDirMacro)=0)
  end;

  procedure GatherLazarusSrcPackages(APackage: TLazPackage);
  var
    ADependency: TPkgDependency;
  begin
    if APackage=nil then exit;
    if VisitedPkgs.Contains(APackage.Name) then exit;
    VisitedPkgs[APackage.Name]:='1';
    // search the dependencies first
    ADependency:=APackage.FirstRequiredDependency;
    while ADependency<>nil do begin
      GatherLazarusSrcPackages(ADependency.RequiredPackage);
      ADependency:=ADependency.NextRequiresDependency;
    end;
    if PkgInOldLazarusDir(APackage) then begin
      // this package was from the old lazarus source directory
      ReloadPkgs.Add(APackage.Name);
    end;
  end;

  function ReloadPkg(APackage: TLazPackage): boolean;
  var
    Link: TPackageLink;
    MsgResult: TModalResult;
    Filename: String;
  begin
    Result:=true;
    if APackage=nil then exit;
    if not PkgInOldLazarusDir(APackage) then exit;
    // this package was from the old lazarus source directory
    // check if there is a package in the new version
    Link:=PkgLinks.FindLinkWithPkgName(APackage.Name);
    if Link<>nil then begin
      Filename:=TrimFilename(Link.LPKFilename);
      if not FilenameIsAbsolute(Filename) then
        Filename:=AppendPathDelim(NewLazarusSrcDir)+Filename;
      if FileIsInPath(Filename,NewLazarusSrcDir)
      and FileExistsUTF8(Filename) then
      begin
        DebugLn(['Hint: (lazarus) [TPkgManager.LazarusSrcDirChanged] load: ',Filename]);
        // open package in new lazarus source directory
        MsgResult:=DoOpenPackageFile(Filename,[pofDoNotOpenEditor,pofRevert],true);
        if MsgResult=mrAbort then exit(false);
      end;
    end;
  end;

var
  i: Integer;
begin
  if PackageGraph=nil then exit;
  OldLazarusSrcDir:=FLastLazarusSrcDir;
  NewLazarusSrcDir:=EnvironmentOptions.GetParsedLazarusDirectory;
  FLastLazarusSrcDir:=NewLazarusSrcDir;
  if CompareFilenames(OldLazarusSrcDir,NewLazarusSrcDir)=0 then exit;
  debugln(['Hint: (lazarus) [TPkgManager.LazarusSrcDirChanged] loading new lpl files from ',PkgLinks.GetGlobalLinkDirectory]);
  if PkgLinks.IsUpdating then
    debugln(['Warning: (lazarus) [TPkgManager.LazarusSrcDirChanged] inconsistency: pkglinks are locked']);
  PkgLinks.UpdateGlobalLinks;

  VisitedPkgs:=TStringToStringTree.Create(false);
  ReloadPkgs:=TStringList.Create;
  try
    // collect candidates
    for i:=0 to PackageGraph.Count-1 do
      GatherLazarusSrcPackages(PackageGraph.Packages[i]);
    // reload
    for i:=0 to ReloadPkgs.Count-1 do
      ReloadPkg(PackageGraph.FindPackageWithName(ReloadPkgs[i],nil));
  finally
    ReloadPkgs.Free;
    VisitedPkgs.Free;
  end;
end;

function TPkgManager.GetPackageCount: integer;
begin
  Result:=PackageGraph.Count;
end;

function TPkgManager.GetPackages(Index: integer): TIDEPackage;
begin
  Result:=PackageGraph.Packages[Index];
end;

function TPkgManager.FindPackageWithName(const PkgName: string;
  IgnorePackage: TIDEPackage): TIDEPackage;
var
  Pkg: TLazPackage;
begin
  Pkg:=nil;
  if (IgnorePackage<>nil) then
    Pkg:=IgnorePackage as TLazPackage;
  Result:=PackageGraph.FindPackageWithName(PkgName,Pkg);
end;

function TPkgManager.RedirectPackageDependency(APackage: TIDEPackage): TIDEPackage;
begin
  Result:=APackage;
  if Result=PackageGraph.LCLBasePackage then begin
    // Older Lazarus does not have a LCLBase and a component does not work
    // without an LCLBase implementation, so we have to use LCL instead.
    Result:=PackageGraph.LCLPackage;
  end;
end;

function TPkgManager.DoCompileProjectDependencies(AProject: TProject;
  Flags: TPkgCompileFlags): TModalResult;
var
  CompilePolicy: TPackageUpdatePolicy;
begin
  // check graph for cycles and broken dependencies
  if not (pcfDoNotCompileDependencies in Flags) then begin
    Result:=CheckPackageGraphForCompilation(nil,
                                            AProject.FirstRequiredDependency,
                                            AProject.ProjectDirectory,false);
    if Result<>mrOk then exit;
  end;
  
  // save all open files
  if not (pcfDoNotSaveEditorFiles in Flags) then begin
    Result:=MainIDE.DoSaveForBuild(crCompile);
    if Result<>mrOk then exit;
  end;

  PackageGraph.BeginUpdate(false);
  try
    // automatically compile required packages
    if not (pcfDoNotCompileDependencies in Flags) then begin
      CompilePolicy:=pupAsNeeded;
      if pcfCompileDependenciesClean in Flags then
        CompilePolicy:=pupOnRebuildingAll;
      Result:=PackageGraph.CompileRequiredPackages(nil,
                                AProject.FirstRequiredDependency,
                                not (pfUseDesignTimePackages in AProject.Flags),
                                CompilePolicy);
      if Result<>mrOk then exit;
    end;
  finally
    PackageGraph.EndUpdate;
  end;
  
  Result:=mrOk;
end;

function TPkgManager.DoCompilePackage(APackage: TLazPackage;
  Flags: TPkgCompileFlags; ShowAbort: boolean): TModalResult;
begin
  Result:=mrCancel;

  DebugLn('Hint: (lazarus) compile package ',APackage.IDAsString,' Flags=',PkgCompileFlagsToString(Flags));
  
  if APackage.IsVirtual then exit;

  Result:=MainIDE.PrepareForCompile;
  if Result<>mrOk then exit;
  
  // check graph for circles and broken dependencies
  if not (pcfDoNotCompileDependencies in Flags) then begin
    Result:=CheckPackageGraphForCompilation(APackage,nil,APackage.Directory,ShowAbort);
    if Result<>mrOk then exit;
  end;
  
  // save all open files
  {$IFDEF VerboseSaveForBuild}
  DebugLn('TPkgManager.DoCompilePackage  ',APackage.IDAsString,' Flags=',PkgCompileFlagsToString(Flags));
  {$ENDIF}
  if not (pcfDoNotSaveEditorFiles in Flags) then begin
    Result:=MainIDE.DoSaveForBuild(crCompile);
    if Result<>mrOk then exit;
  end;

  // check user search paths
  Result:=CheckUserSearchPaths(APackage.CompilerOptions);
  if Result<>mrOk then exit;

  // compile
  Result:=PackageGraph.CompilePackage(APackage,Flags,false);
end;

function TPkgManager.DoCreatePackageMakefile(APackage: TLazPackage;
  ShowAbort: boolean): TModalResult;
begin
  Result:=DoCompilePackage(APackage,[pcfDoNotCompileDependencies,
                       pcfDoNotCompilePackage,pcfCreateMakefile],ShowAbort);
end;

function TPkgManager.DoCreatePackageFpmakefile(APackage: TLazPackage;
  ShowAbort: boolean): TModalResult;
begin
  Result:=DoCompilePackage(APackage,[pcfDoNotCompileDependencies,
                       pcfDoNotCompilePackage,pcfCreateFpmakeFile],ShowAbort);
end;

function TPkgManager.OnRenameFile(const OldFilename, NewFilename: string;
  IsPartOfProject: boolean): TModalResult;
var
  OldPackage: TLazPackage;
  OldPkgFile: TPkgFile;
  NewPkgFile: TPkgFile;
begin
  Result:=mrOk;
  if (OldFilename=NewFilename) then
    exit;
  //debugln('TPkgManager.OnRenameFile A OldFilename="',OldFilename,'" New="',NewFilename,'"');
  OldPkgFile:=PackageGraph.FindFileInAllPackages(OldFilename,true,not IsPartOfProject);
  if (OldPkgFile=nil) or (OldPkgFile.LazPackage.ReadOnly) then
    exit;
  OldPackage:=OldPkgFile.LazPackage;
  debugln('Hint: (lazarus) [TPkgManager.OnRenameFile] OldPackage="',OldPackage.Name);
  NewPkgFile:=PackageGraph.FindFileInAllPackages(NewFilename,true,false);
  if (NewPkgFile<>nil) and (OldPackage<>NewPkgFile.LazPackage) then exit;

  OldPkgFile.Filename:=NewFilename;
  if OldPackage.Editor<>nil then
    OldPackage.Editor.UpdateAll(true);
  OldPackage.Modified:=true;
end;

{------------------------------------------------------------------------------
  function TPkgManager.FindIncludeFileInProjectDependencies(Project1: TProject;
    const Filename: string): string;
    
  Search filename in the include paths of all required packages
------------------------------------------------------------------------------}
function TPkgManager.FindIncludeFileInProjectDependencies(aProject: TProject;
  const Filename: string): string;
var
  APackage: TLazPackage;
  IncPath: String;
  PkgList: TFPList;
  i: Integer;
begin
  Result:='';
  if FilenameIsAbsolute(Filename) then begin
    Result:=Filename;
    exit;
  end;
  PkgList:=nil;
  PackageGraph.GetAllRequiredPackages(nil,aProject.FirstRequiredDependency,
    PkgList,[pirCompileOrder]);
  if PkgList=nil then exit;
  try
    for i:=0 to PkgList.Count-1 do begin
      APackage:=TLazPackage(PkgList[i]);
      IncPath:=APackage.CompilerOptions.GetIncludePath(false);
      Result:=SearchFileInPath(Filename,APackage.Directory,IncPath,';',
                               ctsfcDefault);
      if Result<>'' then exit;
    end;
  finally
    PkgList.Free;
  end;
end;

function TPkgManager.AddUnitDependenciesForComponentClasses(
  const UnitFilename: string; ComponentClassnames: TStrings;
  Quiet: boolean): TModalResult;
var
  UnitBuf: TCodeBuffer;
  UnitNames: TStringList;
  Packages: TFPList;
  MissingDependencies: TObjectArray;
  
  function LoadAndParseUnitBuf: TModalResult;
  begin
    if not CodeToolBoss.GatherExternalChanges then begin
      Result:=mrCancel;
      MainIDE.DoJumpToCodeToolBossError;
      exit;
    end;
    UnitBuf:=CodeToolBoss.LoadFile(UnitFilename,false,false);
    if UnitBuf=nil then begin
      Result:=IDEMessageDialog(lisErrorLoadingFile,
        Format(lisLoadingFailed, [UnitFilename]),
        mtError,[mbCancel,mbAbort]);
      exit;
    end;
    Result:=mrOk;
  end;

  function CollectNeededUnitnamesAndPackages: TModalResult;
  var
    i: Integer;
    RegComp: TRegisteredComponent;
    NewUnitName: String;
    PkgFile: TPkgFile;
    ClassUnitInfo: TUnitInfo;
    APackage: TLazPackage;
  begin
    for i:=0 to ComponentClassnames.Count-1 do begin
      //DebugLn(['CollectNeededUnitnamesAndPackages ComponentClassnames[i]=',ComponentClassnames[i]]);
      RegComp:=IDEComponentPalette.FindComponent(ComponentClassnames[i]);
      NewUnitName:='';
      if (RegComp<>nil) then begin
        if RegComp.ComponentClass<>nil then
          NewUnitName:=GetClassUnitName(RegComp.ComponentClass);
        //DebugLn(['CollectNeededUnitnamesAndPackages NewUnitName=',NewUnitName]);
        if NewUnitName='' then
          NewUnitName:=RegComp.GetUnitName;
      end else begin
        ClassUnitInfo:=Project1.UnitWithComponentClassName(ComponentClassnames[i]);
        if ClassUnitInfo<>nil then
          NewUnitName:=ClassUnitInfo.SrcUnitName;
      end;
      if (NewUnitName<>'') and (UnitNames.IndexOf(NewUnitName)<0) then begin
        // new needed unit
        UnitNames.Add(NewUnitName);
        // find package
        PkgFile:=PackageGraph.FindUnitInAllPackages(NewUnitName,true);
        //DebugLn(['CollectNeededUnitnamesAndPackages PkgFile=',PkgFile<>nil]);
        if (PkgFile=nil) and (RegComp is TPkgComponent) then
          PkgFile:=TPkgComponent(RegComp).PkgFile;
        if (PkgFile<>nil) then begin
          APackage:=PkgFile.LazPackage;
          APackage:=TLazPackage(RedirectPackageDependency(APackage));
          if (APackage<>nil) and (Packages.IndexOf(APackage)<0) then
            Packages.Add(APackage);
        end;
      end;
    end;
    Result:=mrOk;
  end;

  function RemoveExistingUnitnames: TModalResult;
  var
    ImplementationUsesSection: TStrings;
    MainUsesSection: TStrings;
    j: LongInt;
    i: Integer;
  begin
    Result:=LoadAndParseUnitBuf;
    if Result<>mrOk then exit;
    MainUsesSection:=nil;
    ImplementationUsesSection:=nil;
    try
      if not CodeToolBoss.FindUsedUnitNames(UnitBuf,MainUsesSection,
        ImplementationUsesSection)
      then begin
        MainIDE.DoJumpToCodeToolBossError;
        exit;
      end;
      for i:=0 to MainUsesSection.Count-1 do begin
        j:=UnitNames.IndexOf(MainUsesSection[i]);
        if j>=0 then UnitNames.Delete(j);
      end;
    finally
      MainUsesSection.Free;
      ImplementationUsesSection.Free;
    end;
    Result:=mrOk;
  end;
  
  function AskUser: TModalResult;
  var
    UsesAdditions: String;
    UnitOwner: TObject;
    RequiredPackage: TLazPackage;
    i: Integer;
    PackageAdditions: String;
    Msg: String;
  begin
    UsesAdditions:='';
    for i:=0 to UnitNames.Count-1 do begin
      if UsesAdditions<>'' then UsesAdditions:=UsesAdditions+', ';
      UsesAdditions:=UsesAdditions+UnitNames[i];
    end;
    //DebugLn('TPkgManager.AddUnitDependenciesForComponentClasses UsesAdditions=',UsesAdditions);
    PackageAdditions:='';
    if MissingDependencies<>nil then begin
      for i:=0 to MissingDependencies.Count-1 do begin
        UnitOwner:=TObject(MissingDependencies[i]);
        RequiredPackage:=TLazPackage(MissingDependencies.Objects[i]);
        RequiredPackage:=TLazPackage(RedirectPackageDependency(RequiredPackage));
        if UnitOwner is TProject then begin
          PackageAdditions:=Format(lisPkgMangAddingNewDependencyForProjectPackage,
            [PackageAdditions, TProject(UnitOwner).GetTitle, RequiredPackage.Name]) + LineEnding+LineEnding;
        end else if UnitOwner is TLazPackage then begin
          PackageAdditions:=Format(lisPkgMangAddingNewDependencyForPackagePackage,
            [PackageAdditions, TLazPackage(UnitOwner).Name, RequiredPackage.Name]) + LineEnding+LineEnding;
        end;
      end;
    end;
    //DebugLn('TPkgManager.AddUnitDependenciesForComponentClasses PackageAdditions=',PackageAdditions);
    Msg:='';
    if UsesAdditions<>'' then begin
      Msg:=Format(lisPkgMangTheFollowingUnitsWillBeAddedToTheUsesSectionOf,
        [Msg, LineEnding, UnitFilename, LineEnding, UsesAdditions]) + LineEnding+LineEnding;
    end;
    if PackageAdditions<>'' then begin
      Msg:=Msg+PackageAdditions;
    end;
    if Msg<>'' then begin
      Result:=IDEMessageDialog(lisConfirmChanges,Msg,mtConfirmation,[mbOk,mbAbort]);
      exit;
    end;
    Result:=mrOk;
  end;
  
  function AddDependencies: TModalResult;
  var
    i: Integer;
    UnitOwner: TObject;
    RequiredPackage: TLazPackage;
  begin
    if MissingDependencies<>nil then begin
      for i:=0 to MissingDependencies.Count-1 do begin
        UnitOwner:=TObject(MissingDependencies[i]);
        RequiredPackage:=TLazPackage(MissingDependencies.Objects[i]);
        RequiredPackage:=TLazPackage(RedirectPackageDependency(RequiredPackage));
        if UnitOwner is TProject then begin
          DebugLn('Hint: (lazarus) [TPkgManager.AddUnitDependenciesForComponentClasses] Adding Project Dependency ',TProject(UnitOwner).GetTitle,' -> ',RequiredPackage.Name);
          AddProjectDependency(TProject(UnitOwner),RequiredPackage);
        end else if UnitOwner is TLazPackage then begin
          DebugLn('Hint: (lazarus) [TPkgManager.AddUnitDependenciesForComponentClasses] Adding Package Dependency ',TLazPackage(UnitOwner).Name,' -> ',RequiredPackage.Name);
          AddPackageDependency(TLazPackage(UnitOwner),RequiredPackage.Name);
        end;
      end;
    end;
    Result:=mrOk;
  end;

  function AddUsedUnits: TModalResult;
  var
    i: Integer;
  begin
    Result:=LoadAndParseUnitBuf;
    if Result<>mrOk then exit;
    for i:=0 to UnitNames.Count-1 do begin
      DebugLn('Hint: (lazarus) [TPkgManager.AddUnitDependenciesForComponentClasses] Extending Uses ',UnitBuf.Filename,' ',UnitNames[i]);
      if not CodeToolBoss.AddUnitToMainUsesSection(UnitBuf,UnitNames[i],'') then
        MainIDE.DoJumpToCodeToolBossError;
    end;
    Result:=mrOk;
  end;

begin
  Result:=mrCancel;
  UnitNames:=TStringList.Create;
  Packages:=TFPList.Create;
  MissingDependencies:=nil;
  try
  
    Result:=CollectNeededUnitnamesAndPackages;
    if Result<>mrOk then exit;
    
    Result:=RemoveExistingUnitnames;
    if Result<>mrOk then exit;
    
    Result:=GetMissingDependenciesForUnit(UnitFilename,ComponentClassnames,
                                          MissingDependencies);
    if Result<>mrOk then exit;
    if (UnitNames.Count=0)
    and ((MissingDependencies=nil) or (MissingDependencies.Count=0)) then begin
      // no change needed
      Result:=mrOk;
      exit;
    end;

    if not Quiet then begin
      Result:=AskUser;
      if Result<>mrOk then exit;
    end;
    
    Result:=AddDependencies;
    if Result<>mrOk then exit;

    Result:=AddUsedUnits;
    if Result<>mrOk then exit;

    Result:=mrOk;
  finally
    UnitNames.Free;
    Packages.Free;
    MissingDependencies.Free;
  end;
end;

function TPkgManager.GetMissingDependenciesForUnit(
  const UnitFilename: string; ComponentClassnames: TStrings;
  var List: TObjectArray): TModalResult;
// returns a list of packages needed to use the Component in the unit
var
  UnitOwners: TFPList;
  UnitOwner: TObject;
  FirstDependency: TPkgDependency;
  CurClassID: Integer;
  CurOwnerID: Integer;
  CurCompClass: string;
  CurRegisteredComponent: TRegisteredComponent;
  PkgFile: TPkgFile;
  RequiredPackage: TLazPackage;
  CurUnitName: String;
begin
  Result:=mrCancel;
  List:=nil;
  UnitOwners:=GetOwnersOfUnit(UnitFilename);
  if (UnitOwners<>nil) then begin
    for CurOwnerID:=0 to UnitOwners.Count-1 do begin
      UnitOwner:=TObject(UnitOwners[CurOwnerID]);
      if UnitOwner is TProject then
        FirstDependency:=TProject(UnitOwner).FirstRequiredDependency
      else if UnitOwner is TLazPackage then
        FirstDependency:=TLazPackage(UnitOwner).FirstRequiredDependency
      else
        FirstDependency:=nil;
      for CurClassID:=0 to ComponentClassnames.Count-1 do begin
        CurCompClass:=ComponentClassnames[CurClassID];
        CurRegisteredComponent:=IDEComponentPalette.FindComponent(CurCompClass);
        if CurRegisteredComponent is TPkgComponent then begin
          CurUnitName:='';
          if CurRegisteredComponent.ComponentClass<>nil then
            CurUnitName:=GetClassUnitName(CurRegisteredComponent.ComponentClass);
          //DebugLn(['TPkgManager.GetMissingDependenciesForUnit CurUnitName=',CurUnitName]);
          if CurUnitName='' then
            CurUnitName:=CurRegisteredComponent.GetUnitName;
          PkgFile:=PackageGraph.FindUnitInAllPackages(CurUnitName,true);
          //DebugLn(['TPkgManager.GetMissingDependenciesForUnit PkgFile=',PkgFile<>nil]);
          if PkgFile=nil then
            PkgFile:=TPkgComponent(CurRegisteredComponent).PkgFile;
          if PkgFile<>nil then begin
            RequiredPackage:=PkgFile.LazPackage;
            RequiredPackage:=TLazPackage(RedirectPackageDependency(RequiredPackage));
            if (RequiredPackage<>nil)
            and (RequiredPackage<>UnitOwner)
            and (FindCompatibleDependencyInList(FirstDependency,pdlRequires,
              RequiredPackage)=nil)
            and (PackageGraph.FindPackageProvidingName(FirstDependency,
              RequiredPackage.Name)=nil)
            then begin
              if List=nil then List:=TObjectArray.Create;
              List.AddObject(UnitOwner,RequiredPackage);
              //debugln(['TPkgManager.GetMissingDependenciesForUnit A ',UnitOwner.ClassName,' ',RequiredPackage.Name]);
              //if TObject(List[List.Count-1])<>UnitOwner then RaiseException('A');
              //if TObject(List.Objects[List.Count-1])<>RequiredPackage then RaiseException('B');
            end;
          end;
        end;
      end;
    end;
    UnitOwners.Free;
  end else begin
    DebugLn(['Warning: (lazarus) [TPkgManager.GetMissingDependenciesForUnit] unit has no owner: ',UnitFilename]);
  end;
  Result:=mrOk;
end;

function TPkgManager.GetOwnersOfUnit(const UnitFilename: string): TFPList;
begin
  Result:=GetPossibleOwnersOfUnit(UnitFilename,[]);
end;

procedure TPkgManager.ExtendOwnerListWithUsedByOwners(OwnerList: TFPList);
// use items (packages and projects) in OwnerList as leaves and create the
// list of all packages and projects using them.
// The result will be the topologically sorted list of projects and packages
// using the projects/packages in OwnerList, beginning with the top levels.
var
  AddedNonPackages: TFPList;

  procedure AddUsedByOwners(ADependenyOwner: TObject);
  var
    LazPackage: TLazPackage;
    Dependency: TPkgDependency;
  begin
    if ADependenyOwner is TProject then begin
      if AddedNonPackages.IndexOf(ADependenyOwner)>=0 then exit;
      AddedNonPackages.Add(ADependenyOwner);
      OwnerList.Add(ADependenyOwner);
    end else if ADependenyOwner is TLazPackage then begin
      LazPackage:=TLazPackage(ADependenyOwner);
      if lpfVisited in LazPackage.Flags then exit;
      LazPackage.Flags:=LazPackage.Flags+[lpfVisited];
      Dependency:=LazPackage.FirstUsedByDependency;
      while Dependency<>nil do begin
        AddUsedByOwners(Dependency.Owner);
        Dependency:=Dependency.NextUsedByDependency;
      end;
      OwnerList.Add(LazPackage);
    end;
  end;
  
var
  i: Integer;
  OldOwnerList: TFPList;
begin
  OldOwnerList:=TFPList.Create;
  for i:=0 to OwnerList.Count-1 do
    OldOwnerList.Add(OwnerList[i]);
  OwnerList.Clear;
  AddedNonPackages:=TFPList.Create;
  PackageGraph.MarkAllPackagesAsNotVisited;
  for i:=0 to OldOwnerList.Count-1 do
    AddUsedByOwners(TObject(OldOwnerList[i]));
  AddedNonPackages.Free;
  OldOwnerList.Free;
end;

function TPkgManager.GetSourceFilesOfOwners(OwnerList: TFPList): TStrings;

  procedure AddFile(TheOwner: TObject; const Filename: string);
  begin
    if Result=nil then Result:=TStringList.Create;
    Result.AddObject(Filename,TheOwner);
  end;

var
  CurOwner: TObject;
  CurPackage: TLazPackage;
  CurPkgFile: TPkgFile;
  CurProject: TProject;
  CurUnit: TUnitInfo;
  i: Integer;
  j: Integer;
begin
  Result:=nil;
  if OwnerList=nil then exit;
  for i:=0 to OwnerList.Count-1 do begin
    CurOwner:=TObject(OwnerList[i]);
    if CurOwner is TLazPackage then begin
      CurPackage:=TLazPackage(CurOwner);
      for j:=0 to CurPackage.FileCount-1 do begin
        CurPkgFile:=CurPackage.Files[j];
        if CurPkgFile.FileType in PkgFileUnitTypes then
          AddFile(CurOwner,CurPkgFile.GetFullFilename);
      end;
    end else if CurOwner is TProject then begin
      CurProject:=TProject(CurOwner);
      CurUnit:=CurProject.FirstPartOfProject;
      while CurUnit<>nil do begin
        if FilenameIsPascalSource(CurUnit.Filename) then
          AddFile(CurOwner,CurUnit.Filename);
        CurUnit:=CurUnit.NextPartOfProject;
      end;
    end;
  end;
end;

function TPkgManager.GetPossibleOwnersOfUnit(const UnitFilename: string;
  Flags: TPkgIntfOwnerSearchFlags): TFPList;
var
  SrcDir: String;// ExtractFilePath(UnitFilename);

  procedure SearchInProject(AProject: TProject);
  var
    BaseDir: String;
    ProjectDirs: String;
    Add: Boolean;
  begin
    if AProject=nil then exit;
    Add:=false;

    // check if in units
    if not (piosfExcludeOwned in Flags) then begin
      //DebugLn(['SearchInProject ',AProject.ProjectInfoFile,' UnitFilename=',UnitFilename]);
      if (CompareFilenames(UnitFilename,AProject.ProjectInfoFile)=0)
      or (AProject.UnitInfoWithFilename(UnitFilename,[pfsfOnlyProjectFiles])<>nil)
      then
        Add:=true;
    end;

    BaseDir:=ExtractFilePath(AProject.ProjectInfoFile);

    // check if in virtual project
    if (not Add)
    and (piosfIncludeSourceDirectories in Flags)
    and (BaseDir='')
    and (ExtractFilePath(UnitFilename)='') then
      Add:=true;

    if (not Add)
    and (piosfIncludeSourceDirectories in Flags)
    and FilenameIsAbsolute(UnitFilename)
    and (BaseDir<>'') then begin
      // search in project source directories
      ProjectDirs:=AProject.LazCompilerOptions.OtherUnitFiles+';.';
      if IDEMacros.CreateAbsoluteSearchPath(ProjectDirs,BaseDir) then begin
        if FindPathInSearchPath(PChar(SrcDir),length(SrcDir),
          PChar(ProjectDirs),length(ProjectDirs))<>nil
        then
          Add:=true;
      end;
    end;

    if Add then
      Result.Add(AProject);
  end;

var
  PkgFile: TPkgFile;
  CurPackage: TLazPackage;
  i: Integer;
begin
  //DebugLn(['TPkgManager.GetPossibleOwnersOfUnit ',UnitFilename]);
  Result:=TFPList.Create;

  SrcDir:=ExtractFilePath(UnitFilename);

  // ToDo: create a cache

  SearchInProject(Project1);
  
  // find all packages owning file
  if piosfIncludeSourceDirectories in Flags then begin
    PackageGraph.FindPossibleOwnersOfUnit(UnitFilename,Result);
  end else if not (piosfExcludeOwned in Flags) then begin
    PkgFile:=PackageGraph.FindFileInAllPackages(UnitFilename,true,true);
    if (PkgFile<>nil) and (PkgFile.LazPackage<>nil) then
      Result.Add(PkgFile.LazPackage);
    //debugln(['TPkgManager.GetPossibleOwnersOfUnit ',UnitFilename,' ',PkgFile<>nil,' ',(PkgFile<>nil) and (PkgFile.LazPackage<>nil),' Result.Count=',Result.Count]);
    // check package source files (they usually do not have a TPkgFile)
    for i:=0 to PackageGraph.Count-1 do begin
      CurPackage:=PackageGraph.Packages[i];
      if ((CompareFilenames(UnitFilename,CurPackage.GetSrcFilename)=0)
          or (CompareFilenames(UnitFilename,CurPackage.Filename)=0))
      and (Result.IndexOf(CurPackage)<0) then
        Result.Add(CurPackage);
    end;
  end;

  // clean up
  if Result.Count=0 then
    FreeThenNil(Result);
end;

function TPkgManager.GetPackageOfCurrentSourceEditor(out APackage: TIDEPackage
  ): TPkgFile;
var
  SrcEdit: TSourceEditor;
begin
  Result:=nil;
  APackage:=nil;
  SrcEdit:=SourceEditorManager.GetActiveSE;
  if SrcEdit=nil then exit;
  Result := TPkgFile(GetPackageOfSourceEditor(APackage, SrcEdit));
end;

function TPkgManager.GetPackageOfSourceEditor(out APackage: TIDEPackage;
  ASrcEdit: TObject): TLazPackageFile;
var
  Filename: String;
  i: Integer;
begin
  Result:=nil;
  APackage:=nil;
  if ASrcEdit=nil then exit;
  Filename:=TSourceEditor(ASrcEdit).FileName;
  Result:=SearchFile(Filename,[],nil);
  if Result<>nil then begin
    APackage:=Result.LazPackage;
    exit;
  end;
  for i:=0 to PackageGraph.Count-1 do begin
    APackage:=PackageGraph[i];
    if CompareFilenames(TLazPackage(APackage).GetSrcFilename,FileName)=0 then
      exit;
  end;
  APackage:=nil;
end;

function TPkgManager.IsOwnerDependingOnPkg(AnOwner: TObject;
  const PkgName: string; out DependencyOwner: TObject): boolean;
var
  FirstDep: TPkgDependency;
  Dep: TPkgDependency;
begin
  Result:=false;
  DependencyOwner:=nil;
  if (AnOwner=nil) or (PkgName='') then exit;
  if AnOwner is TProject then
    FirstDep:=TProject(AnOwner).FirstRequiredDependency
  else if AnOwner is TLazPackage then begin
    if CompareDottedIdentifiers(PChar(TLazPackage(AnOwner).Name),
      PChar(PkgName))=0
    then begin
      DependencyOwner:=AnOwner;
      exit(true);
    end;
    FirstDep:=TLazPackage(AnOwner).FirstRequiredDependency;
  end else
    exit(false);
  if PackageGraph=nil then exit;
  Dep:=PackageGraph.FindDependencyRecursively(FirstDep,PkgName);
  if Dep=nil then exit;
  DependencyOwner:=Dep.Owner;
  Result:=true;
end;

procedure TPkgManager.GetRequiredPackages(AnOwner: TObject; out PkgList: TFPList;
  Flags: TPkgIntfRequiredFlags);
var
  Dependency: TPkgDependency;
begin
  PkgList:=nil;
  Dependency:=nil;
  if AnOwner is TProject then
    Dependency:=TProject(AnOwner).FirstRequiredDependency
  else if AnOwner is TLazPackage then
    Dependency:=TLazPackage(AnOwner).FirstRequiredDependency
  else if AnOwner=PkgBoss then
    Dependency:=PackageGraph.FirstAutoInstallDependency;
  if Dependency=nil then exit;
  PackageGraph.GetAllRequiredPackages(nil,Dependency,PkgList,Flags);
end;

function TPkgManager.AddDependencyToOwners(OwnerList: TFPList;
  APackage: TIDEPackage; OnlyTestIfPossible: boolean): TModalResult;
var
  i: Integer;
  Item: TObject;
  NewDependency: TPkgDependency;
  ADependency: TPkgDependency;
  r: TModalResult;
  Pkg: TLazPackage;
begin
  Pkg:=APackage as TLazPackage;
  if not OnlyTestIfPossible then begin
    Result:=AddDependencyToOwners(OwnerList,APackage,true);
    if Result<>mrOk then exit;
  end;

  Result:=mrCancel;
  for i:=0 to OwnerList.Count-1 do begin
    Item:=TObject(OwnerList[i]);
    if Item=APackage then continue;
    if Item is TProject then begin
      Result:=AddProjectDependency(TProject(Item),Pkg,OnlyTestIfPossible);
      if Result<>mrOk then exit;
    end else if Item is TLazPackage then begin
      NewDependency:=TPkgDependency.Create;
      try
        NewDependency.PackageName:=APackage.Name;
        r:=CheckAddingDependency(TLazPackage(Item),NewDependency,false,false);
        if r=mrCancel then exit;
        if (not OnlyTestIfPossible) and (r<>mrIgnore) then begin
          ADependency:=NewDependency;
          NewDependency:=nil;
          PackageGraph.AddDependencyToPackage(TLazPackage(Item),ADependency);
        end;
      finally
        NewDependency.Free;
      end;
    end;
  end;
  Result:=mrOk;
end;

function TPkgManager.DoOpenPkgFile(PkgFile: TPkgFile): TModalResult;
var
  Filename: String;
begin
  if (PkgFile.FileType=pftVirtualUnit) then begin
    Filename:=FindVirtualUnitSource(PkgFile);
    if Filename<>'' then begin
      Result:=MainIDE.DoOpenEditorFile(Filename,-1,-1,
                                  [ofOnlyIfExists,ofAddToRecent,ofRegularFile]);
      exit;
    end;
  end;
  Result:=MainIDE.DoOpenEditorFile(PkgFile.GetFullFilename,-1,-1,
                                  [ofOnlyIfExists,ofAddToRecent,ofRegularFile]);
end;

function TPkgManager.FindVirtualUnitSource(PkgFile: TPkgFile): string;
begin
  Result:='';
  if (PkgFile.FileType=pftVirtualUnit)
  and (PkgFile.LazPackage<>nil)
  and (not FileExistsUTF8(PkgFile.Filename)) then begin
    Result:=MainIDE.FindSourceFile(PkgFile.GetShortFilename(false),
                                   PkgFile.LazPackage.Directory,[]);
  end;
end;

function TPkgManager.SearchFile(const AFilename: string;
  SearchFlags: TSearchIDEFileFlags; InObject: TObject): TPkgFile;
var
  APackage: TLazPackage;
  CurFilename: String;
begin
  if InObject is TLazPackage then begin
    APackage:=TLazPackage(InObject);
    CurFilename:=AFilename;
    APackage.ShortenFilename(CurFilename,true);
    Result:=APackage.SearchShortFilename(CurFilename,SearchFlags);
    if Result<>nil then exit;
  end;
  if not (siffDoNotCheckAllPackages in SearchFlags) then begin
    Result := PackageGraph.FindFileInAllPackages(AFilename, True, True);
    if Result<>nil then exit;
  end;
  Result:=nil;
end;

function TPkgManager.SearchUnitInDesigntimePackages(const AnUnitName: string;
  InObject: TObject): TPkgFile;
var
  i: Integer;
  APackage: TLazPackage;
begin
  if InObject is TLazPackage then begin
    APackage:=TLazPackage(InObject);
    Result:=APackage.FindUnit(AnUnitName);
    if Result<>nil then exit;
  end;
  for i:=0 to PackageGraph.Count-1 do begin
    APackage:=PackageGraph[i];
    if APackage.Installed=pitNope then continue;
    Result:=APackage.FindUnit(AnUnitName);
    if Result<>nil then exit;
  end;
  Result:=nil;
end;

function TPkgManager.ShowFindInPackageFilesDlg(APackage: TLazPackage
  ): TModalResult;
var
  Dlg: TLazFindInFilesDialog;
begin
  Result:=mrOk;
  Dlg:=FindInFilesDialog;
  Dlg.FindInSearchPath(APackage.SourceDirectories.CreateSearchPathFromAllFiles);
end;

function TPkgManager.AddDependencyToUnitOwners(const OwnedFilename,
  RequiredUnitname: string): TModalResult;
var
  OwnersList: TFPList;
  RequiredPkgFile: TPkgFile;
  RequiredPkg: TLazPackage;
begin
  Result:=mrCancel;
  //DebugLn(['TPkgManager.AddDependencyToUnitOwners RequiredUnitname=',RequiredUnitname,' OwnedFilename=',OwnedFilename]);

  // find needed package
  RequiredPkgFile:=SearchUnitInDesigntimePackages(RequiredUnitName,nil);
  if RequiredPkgFile=nil then begin
    DebugLn(['Note: (lazarus) [TPkgManager.AddDependencyToUnitOwners] unit not in designtime package: ',RequiredUnitName]);
    exit;
  end;
  RequiredPkg:=RequiredPkgFile.LazPackage;

  // find owners of unit (package or project)
  OwnersList:=GetOwnersOfUnit(OwnedFilename);
  try
    if (OwnersList=nil) or (OwnersList.Count=0) then begin
      DebugLn(['Note: (lazarus) TPkgManager.AddDependencyToUnitOwners Owner not found of unit ',OwnedFilename]);
      exit;
    end;
    // add package dependency
    //DebugLn(['TPkgManager.AddDependencyToUnitOwners ',dbgsName(TObject(OwnersList[0])),' ',RequiredPkg.IDAsString]);
    RequiredPkg:=TLazPackage(RedirectPackageDependency(RequiredPkg));
    Result:=AddDependencyToOwners(OwnersList,RequiredPkg,false);
  finally
    OwnersList.Free;
  end;
end;

procedure TPkgManager.GetPackagesChangedOnDisk(out ListOfPackages: TStringList);
begin
  if PackageGraph=nil then exit;
  PackageGraph.GetPackagesChangedOnDisk(ListOfPackages);
end;

function TPkgManager.RevertPackages(APackageList: TStringList): TModalResult;
var
  i: Integer;
  APackage: TLazPackage;
  Filename: String;
begin
  if APackageList=nil then exit(mrOk);
  for i:=0 to APackageList.Count-1 do begin
    APackage:=TLazPackage(APackageList.Objects[i]);
    Filename:=APackageList[i];
    if Filename='' then
      Filename:=APackage.Filename;
    debugln(['Hint: (lazarus) [TPkgManager.RevertPackages] BEFORE Old=',APackage.Filename,' New=',Filename,' ',FileExistsCached(Filename)]);
    if FileExistsCached(Filename) then
      Result:=DoOpenPackageFile(Filename,[pofRevert],true)
    else begin
      APackage.LPKSource:=nil;
      APackage.Missing:=true;
      Result:=mrCancel;
    end;
    debugln(['Hint: (lazarus) [TPkgManager.RevertPackages] AFTER ',PackageGraph.FindPackageWithFilename(Filename)<>nil]);
    if Result=mrAbort then exit;
  end;
  Result:=mrOk;
end;

function TPkgManager.DoAddActiveUnitToAPackage: TModalResult;
var
  ActiveSourceEditor: TSourceEditorInterface;
  ActiveUnitInfo: TUnitInfo;
  PkgFile: TPkgFile;
  Filename: String;
begin
  MainIDE.GetCurrentUnitInfo(ActiveSourceEditor,ActiveUnitInfo);
  if ActiveSourceEditor=nil then exit(mrAbort);

  Filename:=ActiveUnitInfo.Filename;

  // check if filename is absolute
  if ActiveUnitInfo.IsVirtual or (not FileExistsUTF8(Filename)) then begin
    Result:=IDEMessageDialog(lisPkgMangFileNotSaved,
      lisPkgMangPleaseSaveTheFileBeforeAddingItToAPackage, mtWarning,[mbCancel]);
    exit;
  end;
  
  // check if file is part of project
  if ActiveUnitInfo.IsPartOfProject then begin
    Result:=IDEMessageDialog(lisPkgMangFileIsInProject,
      Format(lisPkgMangWarningTheFileBelongsToTheCurrentProject,[Filename,LineEnding]),
      mtWarning,[mbIgnore,mbCancel]);
    if Result<>mrIgnore then exit;
  end;

  // check if file is already in a package
  PkgFile:=PackageGraph.FindFileInAllPackages(Filename,true,true);
  if PkgFile<>nil then begin
    Result:=IDEMessageDialog(lisPkgMangFileIsAlreadyInPackage,
      Format(lisPkgMangTheFileIsAlreadyInThePackage,
             [Filename, LineEnding, PkgFile.LazPackage.IDAsString]),
      mtWarning,[mbIgnore,mbCancel]);
    if Result<>mrIgnore then exit;
  end;

  Result:=ShowAddFileToAPackageDlg(Filename);
end;

function TPkgManager.DoNewPackageComponent: TModalResult;
var
  APackage: TLazPackage;
  SaveFlags: TPkgSaveFlags;
  Page: TAddToPkgType;
  CurEditor: TPackageEditorForm;
begin
  Result:=ShowNewPkgComponentDialog(APackage);
  if Result<>mrOk then exit;
  SaveFlags:=[];
  if APackage=nil then begin
    // create new package
    // create a new package with standard dependencies
    APackage:=PackageGraph.CreateNewPackage(NameToValidIdentifier(lisPkgMangNewPackage));
    PackageGraph.AddDependencyToPackage(APackage,
                  PackageGraph.IDEIntfPackage.CreateDependencyWithOwner(APackage));
    APackage.Modified:=false;
    Include(SaveFlags,psfSaveAs);
  end;
  // open a package editor
  CurEditor:=PackageEditors.OpenEditor(APackage,true);
  // save
  Result:=DoSavePackage(APackage,SaveFlags);
  if Result<>mrOk then exit;
  // show new component dialog
  Page:=d2ptNewComponent;
  Result:=CurEditor.ShowAddDialog(Page);
end;

function TPkgManager.SavePackageFiles(APackage: TLazPackage): TModalResult;
var
  i: Integer;
  AFile: TPkgFile;
  AFilename: String;
  SaveFlags: TSaveFlags;
  SrcEdit: TSourceEditor;
begin
  Result:=mrOk;
  for i:=0 to APackage.FileCount-1 do begin
    AFile:=APackage.Files[i];
    if AFile.FileType=pftVirtualUnit then continue;
    AFilename:=AFile.Filename;
    if System.Pos('$(',AFilename)>0 then begin
      // filename contains macros -> skip
      //debugln(['TPkgManager.SavePackageFiles macros ',AFilename]);
      continue;
    end;
    // check if open in editor
    SrcEdit:=SourceEditorManager.SourceEditorIntfWithFilename(AFilename);
    if SrcEdit=nil then
    begin
      // not open in source editor => skip
      //debugln(['TPkgManager.SavePackageFiles no src edit ',AFilename]);
      continue;
    end;
    SaveFlags:=[sfCanAbort];
    if not FilenameIsAbsolute(AFilename) then
      SaveFlags:=[sfSaveAs];
    Result:=LazarusIDE.DoSaveEditorFile(SrcEdit,SaveFlags);
    if Result=mrIgnore then Result:=mrOk;
    if Result<>mrOk then begin
      debugln(['Error: (lazarus) [TPkgManager.SavePackageFiles] failed writing "',AFilename,'"']);
      exit;
    end;
  end;
end;

function TPkgManager.WarnAboutMissingPackageFiles(APackage: TLazPackage
  ): TModalResult;
var
  i: Integer;
  AFile: TPkgFile;
  AFilename: String;
begin
  Result:=mrOk;
  for i:=0 to APackage.FileCount-1 do begin
    AFile:=APackage.Files[i];
    if AFile.FileType=pftVirtualUnit then continue;
    AFilename:=AFile.GetFullFilename;
    if System.Pos('$(',AFilename)>0 then begin
      // filename contains macros -> skip
      continue;
    end;
    if FilenameIsAbsolute(AFilename) and FileExistsCached(AFilename) then
      continue;
    Result:=IDEQuestionDialog(lisPkgSysPackageFileNotFound,
      Format(lisPkgMangTheFileOfPackageWasNotFound, [AFilename, APackage.
        IDAsString]),
      mtWarning,[mrIgnore,mrAbort]);
    if Result<>mrAbort then
      Result:=mrOk;
    // one warning is enough
    exit;
  end;
end;

function TPkgManager.AddPackageDependency(APackage: TLazPackage;
  const ReqPackage: string; OnlyTestIfPossible: boolean): TModalResult;
var
  NewDependency: TPkgDependency;
  ADependency: TPkgDependency;
begin
  NewDependency:=TPkgDependency.Create;
  try
    NewDependency.PackageName:=ReqPackage;
    Result:=CheckAddingDependency(APackage,NewDependency,false,false);
    if Result=mrIgnore then exit(mrOk);
    if Result<>mrOk then exit;
    if not OnlyTestIfPossible then begin
      ADependency:=NewDependency;
      NewDependency:=nil;
      PackageGraph.AddDependencyToPackage(APackage,ADependency);
      Result:=mrOk;
    end;
  finally
    NewDependency.Free;
  end;
end;

function TPkgManager.GetPackageOfEditorItem(Sender: TObject): TIDEPackage;
begin
  Result:=nil;
  while (Sender is TMenuItem) and (TMenuItem(Sender).Parent<>nil) do
    Sender:=TMenuItem(Sender).Parent;
  if (Sender is TMenuItem) and (TMenuItem(Sender).Menu<>nil)
  then
    Sender:=TMenuItem(Sender).Menu;
  if (Sender is TComponent) and (TComponent(Sender).Owner is TCustomForm) then
    Sender:=TCustomForm(TComponent(Sender).Owner);
  if Sender is TPackageEditorForm then
    Result:=TPackageEditorForm(Sender).LazPackage;
end;

function TPkgManager.DoInstallPackage(APackage: TLazPackage): TModalResult;
var
  PkgList: TFPList;
  
  function GetPkgListIndex(APackage: TLazPackage): integer;
  begin
    Result:=PkgList.Count-1;
    while (Result>=0) and (TLazPackage(PkgList[Result])<>APackage) do
      dec(Result);
  end;

  function WarnForSuspiciousPackage(APackage: TLazPackage): TModalResult;
  var
    IgnorePath: String;
    UnitPath: String;
  begin
    if APackage.UsageOptions.IncludePath<>'' then
    begin
      IgnorePath:='InstallPkgAddsIncPath/'+APackage.Filename;
      if InputHistories.Ignores.Find(IgnorePath)=nil then
      begin
        Result:=IDEQuestionDialog(lisSuspiciousIncludePath,
          Format(lisThePackageAddsThePathToTheIncludePathOfTheIDEThisI, [
            APackage.IDAsString, dbgstr(APackage.UsageOptions.IncludePath), LineEnding]
            ),
          mtWarning, [mrYes, lisContinue, mrYesToAll, lisContinueAndDoNotAskAgain, mrCancel]);
        case Result of
        mrYes: ;
        mrYesToAll:
          InputHistories.Ignores.Add(IgnorePath,iiidForever);
        else
          exit(mrCancel);
        end;
      end;
    end;
    UnitPath:=Trim(GetForcedPathDelims(APackage.UsageOptions.UnitPath));
    while (UnitPath<>'') and (UnitPath[1]=';') do
      UnitPath:=copy(UnitPath,2,Length(UnitPath));
    while (UnitPath<>'') and (RightStr(UnitPath,1)=';') do
      UnitPath:=copy(UnitPath,1,Length(UnitPath)-1);
    UnitPath:=ChompPathDelim(TrimFilename(UnitPath));
    if SysUtils.CompareText(UnitPath,'$(PkgOutDir)')<>0 then
    begin
      IgnorePath:='InstallPkgAddsUnitPath/'+APackage.Filename;
      if InputHistories.Ignores.Find(IgnorePath)=nil then
      begin
        Result:=IDEQuestionDialog(lisSuspiciousUnitPath,
          Format(lisThePackageAddsThePathToTheUnitPathOfTheIDEThisIsPr, [
            APackage.IDAsString, dbgstr(APackage.UsageOptions.UnitPath), LineEnding]),
          mtWarning, [mrYes, lisContinue, mrYesToAll, lisContinueAndDoNotAskAgain, mrCancel]);
        case Result of
        mrYes: ;
        mrYesToAll:
          InputHistories.Ignores.Add(IgnorePath,iiidForever);
        else
          exit(mrCancel);
        end;
      end;
    end;
    Result:=mrOk;
  end;
  
var
  Dependency: TPkgDependency;
  i: Integer;
  s: String;
  NeedSaving: Boolean;
  RequiredPackage: TLazPackage;
  BuildIDEFlags: TBuildLazarusFlags;
  Msg: string;
  Btns: TMsgDlgButtons;
  ConflictDep: TPkgDependency;
begin
  if not MainIDE.DoResetToolStatus([rfInteractive]) then exit(mrCancel);

  try
    BuildBoss.SetBuildTargetIDE;

    PackageGraph.BeginUpdate(true);
    PkgList:=nil;
    try

      // check if package is designtime package
      if APackage.PackageType in [lptRunTime,lptRunTimeOnly] then begin
        Btns:=[mbAbort];
        if APackage.PackageType=lptRunTime then
          Include(Btns,mbIgnore);
        Result:=IDEMessageDialog(lisPkgMangPackageIsNoDesigntimePackage,
          Format(lisPkgMangThePackageIsARuntimeOnlyPackageRuntimeOnlyPackages,
                 [APackage.IDAsString, LineEnding]),
          mtError,Btns);
        if Result<>mrIgnore then exit;
      end;
      // check if package requires a runtime only package
      ConflictDep:=PackageGraph.FindRuntimePkgOnlyRecursively(
        APackage.FirstRequiredDependency);
      if ConflictDep<>nil then begin
        IDEQuestionDialog(lisNotADesigntimePackage,
          Format(lisThePackageCanNotBeInstalledBecauseItRequiresWhichI, [
            APackage.Name, ConflictDep.AsString]),
          mtError,
          [mrCancel]
          );
        exit;
      end;

      // save package
      if APackage.IsVirtual or APackage.Modified then begin
        Result:=DoSavePackage(APackage,[]);
        if Result<>mrOk then exit;
      end;

      // check consistency
      Result:=CheckPackageGraphForCompilation(APackage,nil,
                              EnvironmentOptions.GetParsedLazarusDirectory,false);
      if Result<>mrOk then exit;

      // get all required packages, which will also be auto installed
      APackage.GetAllRequiredPackages(PkgList,false);
      if PkgList=nil then PkgList:=TFPList.Create;

      // remove packages already marked for installation
      for i:=PkgList.Count-1 downto 0 do begin
        RequiredPackage:=TLazPackage(PkgList[i]);
        if (RequiredPackage.AutoInstall<>pitNope) then
          PkgList.Delete(i);
      end;

      // now PkgList contains only the required packages that were added to the
      // list of installation packages
      // => show the user the list
      if PkgList.Count>0 then begin
        s:='';
        for i:=0 to PkgList.Count-1 do begin
          RequiredPackage:=TLazPackage(PkgList[i]);
          s:=s+RequiredPackage.IDAsString+LineEnding;
        end;
        if PkgList.Count=0 then
          Msg:=Format(lisPkgMangInstallingThePackageWillAutomaticallyInstallThePac,
                      [APackage.IDAsString])
        else
          Msg:=Format(lisPkgMangInstallingThePackageWillAutomaticallyInstallThePac2,
                      [APackage.IDAsString]);
        Result:=IDEMessageDialog(lisPkgMangAutomaticallyInstalledPackages,
          Msg+LineEnding+s,mtConfirmation,[mbOk,mbCancel]);
        if Result<>mrOk then exit;
      end;

      // warn for packages with suspicious settings
      Result:=WarnForSuspiciousPackage(APackage);
      if Result<>mrOk then exit;
      for i:=0 to PkgList.Count-1 do begin
        RequiredPackage:=TLazPackage(PkgList[i]);
        Result:=WarnForSuspiciousPackage(RequiredPackage);
        if Result<>mrOk then exit;
      end;

      // add packages to auto installed packages
      if GetPkgListIndex(APackage)<0 then
        PkgList.Add(APackage);
      NeedSaving:=false;
      for i:=0 to PkgList.Count-1 do begin
        RequiredPackage:=TLazPackage(PkgList[i]);
        if RequiredPackage.AutoInstall=pitNope then begin
          RequiredPackage.AutoInstall:=pitStatic;
          Dependency:=RequiredPackage.CreateDependencyWithOwner(Self);
          Dependency.AddToList(PackageGraph.FirstAutoInstallDependency,pdlRequires);
          PackageGraph.OpenDependency(Dependency,false);
          NeedSaving:=true;
        end;
      end;
    finally
      PackageGraph.EndUpdate;
      PkgList.Free;
    end;

    if NeedSaving then begin
      PackageGraph.SortAutoInstallDependencies;
      SaveAutoInstallDependencies;
    end;

    // save IDE build configs, so user can build IDE on command line
    BuildIDEFlags:=[blfDontClean,blfOnlyIDE];
    Result:=MainIDE.DoSaveBuildIDEConfigs(BuildIDEFlags);
    if Result<>mrOk then exit;
  finally
    BuildBoss.SetBuildTargetProject1;
  end;

  // ask user to rebuild Lazarus now
  Result:=IDEMessageDialog(lisPkgMangRebuildLazarus,
    Format(lisPkgMangThePackageWasMarkedForInstallationCurrentlyLazarus,
           [APackage.IDAsString, LineEnding, LineEnding+LineEnding]),
    mtConfirmation,[mbYes,mbNo]);
  if Result<>mrYes then begin
    Result:=mrOk;
    exit;
  end;

  // rebuild Lazarus
  Result:=MainIDE.DoBuildLazarus(BuildIDEFlags);
  if Result<>mrOk then exit;

  Result:=mrOk;
end;

function TPkgManager.DoUninstallPackage(APackage: TLazPackage;
  Flags: TPkgUninstallFlags; ShowAbort: boolean): TModalResult;
var
  DependencyPath: TFPList;
  ParentPackage: TLazPackage;
  Dependency: TPkgDependency;
  BuildIDEFlags: TBuildLazarusFlags;
begin
  if (APackage.Installed=pitNope) and (APackage.AutoInstall=pitNope) then exit;
  
  // check if package is required by auto install package
  DependencyPath:=PackageGraph.FindAutoInstallDependencyPath(APackage);
  if DependencyPath<>nil then begin
    DoShowPackageGraphPathList(DependencyPath);
    ParentPackage:=TLazPackage(DependencyPath[0]);
    Result:=IDEMessageDialogAb(lisPkgMangPackageIsRequired,
      Format(lisPkgMangThePackageIsRequiredByWhichIsMarkedForInstallation,
             [APackage.IDAsString, ParentPackage.IDAsString, LineEnding]),
      mtError,[mbCancel],ShowAbort);
    exit;
  end;

  // check if package is a lazarus base package
  if PackageGraph.IsStaticBasePackage(APackage.Name) then begin
    Result:=IDEMessageDialogAb(lisUninstallImpossible,
      Format(lisThePackageCanNotBeUninstalledBecauseItIsNeededByTh,[APackage.Name]),
      mtError,[mbCancel],ShowAbort);
    exit;
  end;

  // confirm uninstall package
  if not (puifDoNotConfirm in Flags) then begin
    Result:=IDEMessageDialogAb(lisPkgMangUninstallPackage,
      Format(lisPkgMangUninstallPackage2, [APackage.IDAsString]),
      mtConfirmation,[mbYes,mbCancel],ShowAbort);
    if Result<>mrYes then exit;
  end;
  
  PackageGraph.BeginUpdate(true);
  try
    // save package
    if APackage.IsVirtual or APackage.Modified then begin
      Result:=DoSavePackage(APackage,[]);
      if Result<>mrOk then exit;
    end;

    // remove package from auto installed packages
    if APackage.AutoInstall<>pitNope then begin
      APackage.AutoInstall:=pitNope;
      Dependency:=FindCompatibleDependencyInList(PackageGraph.FirstAutoInstallDependency,
                                                 pdlRequires,APackage);
      if Dependency<>nil then begin
        Dependency.RemoveFromList(PackageGraph.FirstAutoInstallDependency,pdlRequires);
        Dependency.Free;
        PackageGraph.SortAutoInstallDependencies;
      end;
      SaveAutoInstallDependencies;
    end;

    // save IDE build configs, so user can build IDE on command line
    BuildIDEFlags:=[blfDontClean,blfOnlyIDE];
    Result:=MainIDE.DoSaveBuildIDEConfigs(BuildIDEFlags);
    if Result<>mrOk then exit;

    if not (puifDoNotBuildIDE in Flags) then begin
      // ask user to rebuilt Lazarus now
      Result:=IDEMessageDialog(lisPkgMangRebuildLazarus,
        Format(lisPkgMangThePackageWasMarkedCurrentlyLazarus,
               [APackage.IDAsString, LineEnding, LineEnding+LineEnding]),
        mtConfirmation,[mbYes,mbNo]);
      if Result=mrNo then begin
        Result:=mrOk;
        exit;
      end;

      // rebuild Lazarus
      Result:=MainIDE.DoBuildLazarus(BuildIDEFlags);
      if Result<>mrOk then exit;
    end;
  finally
    PackageGraph.EndUpdate;
  end;
  Result:=mrOk;
end;

function TPkgManager.CheckInstallPackageList(PkgIDList: TObjectList;
  Flags: TPkgInstallInIDEFlags): boolean;
var
  NewFirstAutoInstallDependency: TPkgDependency;

  procedure DeleteDependency(ADependency: TPkgDependency);
  var
    i: Integer;
    PkgID: TLazPackageID;
  begin
    DeleteDependencyInList(ADependency,NewFirstAutoInstallDependency,pdlRequires);
    if piiifRemoveConflicts in Flags then
      for i:=PkgIDList.Count-1 downto 0 do begin
        PkgID:=TLazPackageID(PkgIDList[i]);
        if SysUtils.CompareText(PkgID.Name,ADependency.PackageName)=0 then begin
          PkgIDList.Delete(i);
          PkgID.Free;
        end;
      end;
  end;

var
  PkgList: TFPList;
  i: Integer;
  APackage: TLazPackage;
  ADependency: TPkgDependency;
  NextDependency: TPkgDependency;
  SaveFlags: TPkgSaveFlags;
  ConflictDep: TPkgDependency;
begin
  Result:=false;
  PkgList:=nil;
  try
    // create new auto install dependency PkgIDList
    ListPkgIDToDependencyList(PkgIDList,NewFirstAutoInstallDependency,
                              pdlRequires,Self,true);

    // load all required packages
    if LoadDependencyList(NewFirstAutoInstallDependency,piiifQuiet in Flags)<>mrOk then exit;

    // remove all top level runtime packages from the list
    // Note: it's ok if a designtime package uses a runtime package
    ADependency:=NewFirstAutoInstallDependency;
    while ADependency<>nil do begin
      NextDependency:=ADependency.NextRequiresDependency;
      if (ADependency.RequiredPackage<>nil) then begin
        if (ADependency.RequiredPackage.PackageType in [lptRunTime,lptRunTimeOnly])
        then begin
          // top level dependency on runtime package => delete
          DeleteDependency(ADependency);
        end else begin
          ConflictDep:=PackageGraph.FindRuntimePkgOnlyRecursively(
            ADependency.RequiredPackage.FirstRequiredDependency);
          //debugln(['TPkgManager.CheckInstallPackageList ',ADependency.RequiredPackage.Name,' ',ConflictDep<>nil]);
          if ConflictDep<>nil then begin
            if piiifRemoveConflicts in Flags then begin
              // can remove conflict
              if not (piiifQuiet in Flags)
              and (IDEQuestionDialog(lisNotADesigntimePackage,
                Format(lisThePackageCanNotBeInstalledBecauseItRequiresWhichI, [
                  ADependency.RequiredPackage.Name, ConflictDep.AsString]),
                mtError,
                [mrYes, Format(lisUninstall, [ADependency.RequiredPackage.Name]), mrCancel]
                )<>mrYes)
              then
                exit;
            end else begin
              // can not remove conflict
              if not (piiifQuiet in Flags) then
                IDEQuestionDialog(lisNotADesigntimePackage,
                  Format(lisThePackageCanNotBeInstalledBecauseItRequiresWhichI, [
                    ADependency.RequiredPackage.Name, ConflictDep.AsString]),
                  mtError,[mrCancel]);
              exit;
            end;
            // dependency needs a runtime only package => delete
            DeleteDependency(ADependency);
          end;
        end;
      end;
      ADependency:=NextDependency;
    end;

    PackageGraph.GetAllRequiredPackages(nil,NewFirstAutoInstallDependency,PkgList);

    // try save all modified packages
    for i:=0 to PkgList.Count-1 do begin
      APackage:=TLazPackage(PkgList[i]);
      if (not APackage.UserReadOnly)
      and (APackage.IsVirtual or APackage.Modified) then begin
        SaveFlags:=[];
        if DoSavePackage(APackage,SaveFlags)<>mrOk then exit;
      end;
    end;

    Result:=true;
  finally
    FreeDependencyList(NewFirstAutoInstallDependency,pdlRequires);
    PkgList.Free;
  end;
end;

function TPkgManager.InstallPackages(PkgIdList: TObjectList;
  Flags: TPkgInstallInIDEFlags): TModalResult;

  procedure CreateChangeReport(
    OldDependencyList, NewDependencyList: TPkgDependency; Report: TStrings);
  var
    CurDependency: TPkgDependency;
    OldDependency: TPkgDependency;
    NewDependency: TPkgDependency;
    s: String;
  begin
    // list all packages, that will be installed
    CurDependency:=NewDependencyList;
    while CurDependency<>nil do begin
      s:=CurDependency.AsString;
      OldDependency:=FindDependencyByNameInList(OldDependencyList,pdlRequires,
                                                CurDependency.PackageName);
      if OldDependency=nil then begin
        // newly installed
        s:=s+'|'+lisPkgMgrNew;
        Report.Add(s);
      end;
      CurDependency:=CurDependency.NextRequiresDependency;
    end;

    // list all packages, that will be removed
    CurDependency:=OldDependencyList;
    while CurDependency<>nil do begin
      NewDependency:=FindDependencyByNameInList(NewDependencyList,pdlRequires,
                                                CurDependency.PackageName);
      if NewDependency=nil then
        // this package will be removed
        Report.Add('|'+lisPkgMgrRemove+'|'+CurDependency.AsString);
      CurDependency:=CurDependency.NextRequiresDependency;
    end;

    // list all packages, that are kept
    CurDependency:=NewDependencyList;
    while CurDependency<>nil do begin
      s:=CurDependency.AsString;
      OldDependency:=FindDependencyByNameInList(OldDependencyList,pdlRequires,
                                                CurDependency.PackageName);
      if OldDependency<>nil then begin
        // stay installed
        if CurDependency.AsString<>OldDependency.AsString then
          s:=s+'|'+lisPkgMgrKeep+'|'+OldDependency.AsString;
        Report.Add(s);
      end;
      CurDependency:=CurDependency.NextRequiresDependency;
    end;
  end;

var
  NewFirstAutoInstallDependency: TPkgDependency;
  BuildIDEFlags: TBuildLazarusFlags;
  Report: TStringList;
  PkgList: TFPList;
  RequiredPackage: TLazPackage;
  i: Integer;
  CurDependency: TPkgDependency;
  OldID: TLazPackageID;
begin
  Result:=mrCancel;
  NewFirstAutoInstallDependency:=nil;
  PkgList:=nil;
  try
    if not (piiifClear in Flags) then
    begin
      // add existing install packages to list
      NewFirstAutoInstallDependency:=PackageGraph.FirstAutoInstallDependency;
      while NewFirstAutoInstallDependency<>nil do begin
        if NewFirstAutoInstallDependency.RequiredPackage<>nil then begin
          i:=PkgIdList.Count-1;
          while (i>=0)
          and (TLazPackageID(PkgIdList[i]).Compare(NewFirstAutoInstallDependency.RequiredPackage)<>0)
          do dec(i);
          if i<0 then begin
            OldID:=TLazPackageID.Create;
            OldID.AssignID(NewFirstAutoInstallDependency.RequiredPackage);
            PkgIdList.Add(OldID);
          end;
        end;
        NewFirstAutoInstallDependency:=NewFirstAutoInstallDependency.NextRequiresDependency;
      end;
    end;

    if not (piiifSkipChecks in Flags) then
    begin
      if not CheckInstallPackageList(PkgIDList,Flags*[piiifQuiet,piiifRemoveConflicts]) then
        exit(mrCancel);
    end;

    // create new auto install dependency PkgIDList
    ListPkgIDToDependencyList(PkgIDList,NewFirstAutoInstallDependency,
      pdlRequires,Self,true);

    PackageGraph.SortDependencyListTopologicallyOld(NewFirstAutoInstallDependency,
                                                 false);

    if not (piiifQuiet in Flags) then
    begin
      // tell the user, which packages will stay, which will be removed and
      // which will be newly installed
      try
        Report:=TStringList.Create;
        CreateChangeReport(
          PackageGraph.FirstAutoInstallDependency,NewFirstAutoInstallDependency,
          Report);
        if not ConfirmPackageList(Report) then exit(mrCancel);
      finally
        Report.Free;
      end;
    end;

    // try to commit changes -> replace install list
    PackageGraph.BeginUpdate(true);
    try
      // get all required packages
      //debugln('TPkgManager.MainIDEitmPkgEditInstallPkgsClick GetAllRequiredPackages for ',DependencyListAsString(NewFirstAutoInstallDependency,pdlRequires));
      if LoadDependencyList(NewFirstAutoInstallDependency,false)<>mrOk then exit(mrCancel);
      PackageGraph.GetAllRequiredPackages(nil,NewFirstAutoInstallDependency,PkgList);

      // mark packages for installation
      //debugln('TPkgManager.MainIDEitmPkgEditInstallPkgsClick mark packages for installation');
      for i:=0 to PkgList.Count-1 do begin
        RequiredPackage:=TLazPackage(PkgList[i]);
        if RequiredPackage.AutoInstall=pitNope then begin
          RequiredPackage.AutoInstall:=pitStatic;
        end;
      end;

      // mark packages for uninstall
      //debugln('TPkgManager.MainIDEitmPkgEditInstallPkgsClick mark packages for uninstall');
      CurDependency:=PackageGraph.FirstAutoInstallDependency;
      while CurDependency<>nil do begin
        if (CurDependency.RequiredPackage<>nil)
        and (not PackageGraph.IsStaticBasePackage(CurDependency.PackageName)) then
          CurDependency.RequiredPackage.AutoInstall:=pitNope;
        CurDependency:=CurDependency.NextRequiresDependency;
      end;

      // replace install list
      //debugln('TPkgManager.MainIDEitmPkgEditInstallPkgsClick replace install list');
      FreeDependencyList(PackageGraph.FirstAutoInstallDependency,pdlRequires);
      PackageGraph.FirstAutoInstallDependency:=NewFirstAutoInstallDependency;
      NewFirstAutoInstallDependency:=nil;
    finally
      PackageGraph.EndUpdate;
    end;

    // save package list
    //debugln('TPkgManager.MainIDEitmPkgEditInstallPkgsClick save package list');
    PackageGraph.SortAutoInstallDependencies;
    SaveAutoInstallDependencies;

    // save IDE build configs, so user can build IDE on command line
    BuildIDEFlags:=[blfDontClean,blfOnlyIDE];
    if MainIDE.DoSaveBuildIDEConfigs(BuildIDEFlags)<>mrOk then exit(mrCancel);

    if piiifRebuildIDE in Flags then
    begin
      // rebuild Lazarus
      if MainIDE.DoBuildLazarus(BuildIDEFlags)<>mrOk then exit(mrCancel);
    end;

  finally
    FreeDependencyList(NewFirstAutoInstallDependency,pdlRequires);
    PkgList.Free;
  end;
  Result:=mrOk;
end;

function TPkgManager.DoOpenPackageSource(APackage: TLazPackage): TModalResult;
var
  Filename: String;
begin
  Result:=mrCancel;
  if APackage.IsVirtual then begin
    IDEMessageDialog(lisCCOErrorCaption,
      lisPkgMangThisIsAVirtualPackageItHasNoSourceYetPleaseSaveThe,
      mtError, [mbCancel]);
    exit;
  end;
  Filename:=APackage.GetSrcFilename;
  if (not FilenameIsAbsolute(Filename)) or (not FileExistsCached(Filename)) then begin
    IDEMessageDialog(lisCCOErrorCaption, lisPkgMangPleaseCompileThePackageFirst,
      mtError,[mbCancel]);
    exit;
  end;
  Result:=MainIDE.DoOpenEditorFile(Filename,-1,-1,[ofRegularFile]);
end;

function TPkgManager.DoCompileAutoInstallPackages(Flags: TPkgCompileFlags;
  OnlyBase: boolean): TModalResult;
var
  Dependency: TPkgDependency;
  OldDependency: TPkgDependency;
  Dependencies: TPkgDependency;
  AutoRemove: Boolean;
  CompilePolicy: TPackageUpdatePolicy;
begin
  PackageGraph.BeginUpdate(false);
  Dependencies:=PackageGraph.FirstAutoInstallDependency;
  try
    if OnlyBase then
    begin
      // create the list of base packages
      OldDependency:=PackageGraph.FirstAutoInstallDependency;
      Dependencies:=nil;
      while OldDependency<>nil do begin
        if (OldDependency.RequiredPackage<>nil)
        and PackageGraph.IsStaticBasePackage(OldDependency.RequiredPackage.Name) then
        begin
          Dependency:=TPkgDependency.Create;
          Dependency.Assign(OldDependency);
          Dependency.AddToEndOfList(Dependencies,pdlRequires);
        end;
        OldDependency:=OldDependency.NextRequiresDependency;
      end;
      Dependencies:=GetFirstDependency(Dependencies,pdlRequires);
      PackageGraph.OpenRequiredDependencyList(Dependencies);
    end;

    // check every installed package if it was loaded correctly
    Dependency:=Dependencies;
    AutoRemove:=false;
    while Dependency<>nil do begin
      OldDependency:=Dependency;
      Dependency:=Dependency.NextRequiresDependency;
      if OldDependency.LoadPackageResult<>lprSuccess then begin
        if not AutoRemove then begin
          Result:=IDEMessageDialog(lisProjAddPackageNotFound,
            Format(lisPkgMangThePackageIsMarkedForInstallationButCanNotBeFound,
                   [OldDependency.AsString, LineEnding]),
            mtError,[mbYes,mbYesToAll,mbAbort]);
          case Result of
          mrYes: ;
          mrYesToAll: AutoRemove:=true;
          else
            SaveAutoInstallDependencies;
            exit;
          end;
        end;
        OldDependency.RemoveFromList(PackageGraph.FirstAutoInstallDependency,pdlRequires);
        OldDependency.Free;
      end;
    end;
    SaveAutoInstallDependencies;

    // check consistency
    Result:=CheckPackageGraphForCompilation(nil,Dependencies,
                            EnvironmentOptions.GetParsedLazarusDirectory,false);
    if Result<>mrOk then begin
      if ConsoleVerbosity>0 then
        debugln(['Error: (lazarus) [TPkgManager.DoCompileAutoInstallPackages] CheckPackageGraphForCompilation failed']);
      exit;
    end;
    //DebugLn(['TPkgManager.DoCompileAutoInstallPackages LCLUnitPath=',PackageGraph.LCLPackage.CompilerOptions.GetUnitPath(true)]);

    // save all open files
    if not (pcfDoNotSaveEditorFiles in Flags) then begin
      Result:=MainIDE.DoSaveForBuild(crCompile);
      if Result<>mrOk then begin
        if ConsoleVerbosity>0 then
          debugln(['Error: (lazarus) [TPkgManager.DoCompileAutoInstallPackages] MainIDE.DoSaveForBuild failed']);
        exit;
      end;
    end;
    
    // compile all auto install dependencies
    CompilePolicy:=pupAsNeeded;
    if pcfCompileDependenciesClean in Flags then
      CompilePolicy:=pupOnRebuildingAll;
    Result:=PackageGraph.CompileRequiredPackages(nil,Dependencies,false,
                                                 CompilePolicy);
    if Result<>mrOk then begin
      if ConsoleVerbosity>0 then
        debugln(['Error: (lazarus) [TPkgManager.DoCompileAutoInstallPackages] PackageGraph.CompileRequiredPackages failed']);
      exit;
    end;

  finally
    if OnlyBase then
      FreeDependencyList(Dependencies,pdlRequires);
    PackageGraph.EndUpdate;
  end;
  Result:=mrOk;
end;

function TPkgManager.DoSaveAutoInstallConfig: TModalResult;
var
  TargetDir: String;
begin
  TargetDir:=MiscellaneousOptions.BuildLazProfiles.Current.TargetDirectory;
  IDEMacros.SubstituteMacros(TargetDir);
  TargetDir:=TrimFilename(TargetDir);
  if not ForceDirectory(TargetDir) then begin
    Result:=IDEMessageDialog(lisPkgMangUnableToCreateDirectory,
      Format(lisPkgMangUnableToCreateTargetDirectoryForLazarus,
             [LineEnding, TargetDir, LineEnding]),
      mtError,[mbCancel,mbAbort]);
    exit;
  end;

  Result:=PackageGraph.SaveAutoInstallConfig;
end;

function TPkgManager.DoPublishPackage(APackage: TLazPackage;
  Flags: TPkgSaveFlags; ShowDialog: boolean): TModalResult;
begin
  // show the publish dialog
  if ShowDialog then begin
    Result:=ShowPublishProjectDialog(APackage.PublishOptions);
    if Result<>mrOk then exit;
  end;

  // save package
  Result:=DoSavePackage(APackage,Flags);
  if Result<>mrOk then exit;

  // publish package
  Result:=MainIDE.DoPublishModule(APackage.PublishOptions,APackage.Directory,
                                  GetPublishPackageDir(APackage));
end;

function TPkgManager.GetUsableComponentUnits(CurRoot: TPersistent): TFPList;
var
  FMainUnitInfo: TUnitInfo;
  FMainUnitInfoValid: boolean;
  FMainOwner: TObject;
  FMainOwnerValid: boolean;

  function MainUnitInfo: TUnitInfo;
  begin
    if not FMainUnitInfoValid then
    begin
      if CurRoot is TComponent then
        FMainUnitInfo := Project1.UnitWithComponent(TComponent(CurRoot));
      FMainUnitInfoValid := True;
    end;
    Result := FMainUnitInfo;
  end;

  function MainOwner: TObject;
  var
    Owners: TFPList;
  begin
    if not FMainOwnerValid then
    begin
      if MainUnitInfo <> nil then
      begin
        if MainUnitInfo.IsPartOfProject then
          FMainOwner := Project1
        else
        begin
          Owners := GetOwnersOfUnit(MainUnitInfo.Filename);
          if (Owners <> nil) and (Owners.Count > 0) then
            FMainOwner := TObject(Owners[0]);
          Owners.Free;
        end;
      end;
      FMainOwnerValid := True;
    end;
    Result := FMainOwner;
  end;

  procedure CheckUnit(AnUnitInfo: TUnitInfo);
  var
    Owners: TFPList;
    OtherOwner: TObject;
    APackage: TLazPackage;
    ConflictDependency: TPkgDependency;
    FirstDependency: TPkgDependency;
  begin
    if (AnUnitInfo.Component=nil)
    or (AnUnitInfo.Component=CurRoot) then
      exit;
    // check if the component can be used
    // A component can only be used, if it has a CreateForm statement in the lpr
    // A unit can not be used, if it has no owner (project/package).
    // And a unit can not be used, if it belongs to a higher level package.
    // For example: Package A uses Package B.
    // A can use units of B, but B can not use units of A.
    if AnUnitInfo.IsPartOfProject and MainUnitInfo.IsPartOfProject then
    begin
      // both units belong to the project => ok
    end else if AnUnitInfo.IsPartOfProject then
    begin
      // AnUnitInfo belongs to Project, but MainUnitInfo does not
      // A project unit can only be used by the project => not allowed
      exit;
    end else
    begin
      Owners:=GetOwnersOfUnit(AnUnitInfo.Filename);
      if (Owners=nil) or (Owners.Count=0) then begin
        // AnUnitInfo does not belong to a project or package
        // => this unit can not be used
        Owners.Free;
        exit;
      end;
      OtherOwner:=TObject(Owners[0]);
      Owners.Free;
      if OtherOwner=MainOwner then begin
        // both units belong to the same owner => ok
      end else if (OtherOwner is TLazPackage) then begin
        // check if MainOwner can use the package
        APackage:=TLazPackage(OtherOwner);
        if MainOwner is TProject then
          FirstDependency:=TProject(MainOwner).FirstRequiredDependency
        else if MainOwner is TLazPackage then
          FirstDependency:=TLazPackage(MainOwner).FirstRequiredDependency
        else
          exit;
        ConflictDependency:=PackageGraph.FindConflictRecursively(
          FirstDependency,APackage);
        if ConflictDependency<>nil then exit;
        if MainOwner is TLazPackage then begin
          // check if package already uses MainOwner
          ConflictDependency:=PackageGraph.FindDependencyRecursively(
            APackage.FirstRequiredDependency,TLazPackage(MainOwner).Name);
          if ConflictDependency<>nil then exit;
        end;
      end else begin
        // AnUnitInfo does not belong to a Package => can not be used
        exit;
      end;
    end;
    // this unit can be used -> add components
    if Result=nil then
      Result:=TFPList.Create;
    Result.Add(AnUnitInfo);
  end;
  
var
  AnUnitInfo: TUnitInfo;
begin
  Result:=nil;
  if not (CurRoot is TComponent) then exit;
  FMainOwner:=nil;
  FMainOwnerValid:=false;
  FMainUnitInfo:=nil;
  FMainUnitInfoValid:=false;
  if (MainOwner=nil) or (MainUnitInfo=nil) then exit;
  // search all open designer forms (can be hidden)
  AnUnitInfo:=Project1.FirstUnitWithComponent;
  while AnUnitInfo<>nil do begin
    CheckUnit(AnUnitInfo);
    AnUnitInfo:=AnUnitInfo.NextUnitWithComponent;
  end;
end;

procedure TPkgManager.IterateComponentNames(CurRoot: TPersistent;
  TypeData: PTypeData; Proc: TGetStrProc);

  procedure CheckComponent(aRoot: TComponent);
  var
    i: integer;
    CurName: String;
  begin
    if aRoot = nil then exit;
    if (aRoot <> CurRoot) and (aRoot is TypeData^.ClassType) then
      Proc(aRoot.Name);
    for i := 0 to aRoot.ComponentCount - 1 do
      if (aRoot.Components[i] is TypeData^.ClassType) then
      begin
        CurName := aRoot.Components[i].Name;
        if aRoot <> CurRoot then
          CurName := aRoot.Name + '.' + CurName;
        Proc(CurName);
      end;
  end;

var
  UnitList: TFPList;
  i: Integer;
begin
  if not (CurRoot is TComponent) then exit;
  CheckComponent(TComponent(CurRoot));
  UnitList := GetUsableComponentUnits(CurRoot);
  if UnitList = nil then exit;
  try
    for i := 0 to UnitList.Count - 1 do
      CheckComponent(TUnitInfo(UnitList[i]).Component);
  finally
    UnitList.Free;
  end;
end;

function TPkgManager.FindReferencedRootComponent(CurRoot: TPersistent;
  const ComponentName: string): TComponent;
var
  UnitList: TFPList;
  ARoot: TComponent;
  i: integer;
begin
  //DebugLn(['search ', ComponentName, ' CurRoot = ', dbgsName(CurRoot)]);
  Result := nil;
  UnitList := GetUsableComponentUnits(CurRoot);
  if UnitList = nil then 
    Exit;
  try
    for i := 0 to UnitList.Count - 1 do 
    begin
      ARoot := TUnitInfo(UnitList[i]).Component;
      DebugLn(['Hint: (lazarus) [TPkgManager.FindReferencedRootComponent] Root=',dbgsName(CurRoot),' Searched="',ComponentName,'" other root=',dbgsName(ARoot)]);
      if (ARoot <> nil) and (SysUtils.CompareText(ComponentName, ARoot.Name) = 0) then
      begin
        Result := ARoot;
        break;
      end;
    end;
  finally
    UnitList.Free;
  end;
  //DebugLn('search end');
end;

function TPkgManager.FindUsableComponent(CurRoot: TPersistent;
  const ComponentPath: string): TComponent;

  procedure CheckComponent(const RootName, SubPath: string; aRoot: TComponent);
  var
    i: integer;
  begin
    if aRoot = nil then exit;
    if (SysUtils.CompareText(RootName, aRoot.Name) <> 0) then exit;

    if SubPath = '' then
    begin
      Result := aRoot;
      Exit;
    end;

    for i := 0 to aRoot.ComponentCount - 1 do
      if SysUtils.CompareText(aRoot.Components[i].Name, SubPath) = 0 then
      begin
        Result := aRoot.Components[i];
        exit;
      end;
  end;

var
  UnitList: TFPList;
  SubPath: String;
  p: LongInt;
  RootName: String;
  i: Integer;
begin
  Result := nil;
  if not (CurRoot is TComponent) then exit;
  SubPath := ComponentPath;
  p := System.Pos('.',SubPath);
  if p < 1 then
    RootName := ''
  else begin
    RootName := copy(ComponentPath, 1, p - 1);
    SubPath := copy(SubPath, p + 1, length(SubPath));
  end;
  if (RootName = '') or (SysUtils.CompareText(RootName, TComponent(CurRoot).Name) = 0) then
    CheckComponent(TComponent(CurRoot).Name, SubPath, TComponent(CurRoot));
  if (p < 1) then
    if Result = nil then
    begin
      RootName := SubPath;
      SubPath := '';
    end
    else
      exit;
  UnitList := GetUsableComponentUnits(CurRoot);
  if UnitList = nil then exit;
  try
    for i := 0 to UnitList.Count-1 do
    begin
      CheckComponent(RootName, SubPath, TUnitInfo(UnitList[i]).Component);
      if Result <> nil then exit;
    end;
  finally
    UnitList.Free;
  end;
end;

function TPkgManager.OnProjectInspectorAddDependency(Sender: TObject;
  ADependency: TPkgDependency): TModalResult;
begin
  Result:=AddProjectDependency(Project1,ADependency);
end;

function TPkgManager.OnProjectInspectorRemoveDependency(Sender: TObject;
  ADependency: TPkgDependency): TModalResult;
var
  ShortUnitName: String;
  Dummy: Boolean;
begin
  Result:=mrOk;
  Project1.RemoveRequiredDependency(ADependency);
  //debugln('TPkgManager.OnProjectInspectorRemoveDependency A');
  if (Project1.MainUnitID>=0)
  and (pfMainUnitIsPascalSource in Project1.Flags)
  then begin
    MainIDEInterface.SaveSourceEditorChangesToCodeCache(nil);
    ShortUnitName:=ADependency.PackageName;
    //debugln('TPkgManager.OnProjectInspectorRemoveDependency B ShortUnitName="',ShortUnitName,'"');
    if (ShortUnitName<>'') then begin
      Dummy:=CodeToolBoss.RemoveUnitFromAllUsesSections(
                                    Project1.MainUnitInfo.Source,ShortUnitName);
      if Dummy then
        Project1.MainUnitInfo.Modified:=true
      else begin
        MainIDEInterface.DoJumpToCodeToolBossError;
        Result:=mrCancel;
        exit;
      end;
    end;
  end;
end;

function TPkgManager.OnProjectInspectorReAddDependency(Sender: TObject;
  ADependency: TPkgDependency): TModalResult;
begin
  Result:=mrOk;
  Project1.ReaddRemovedDependency(ADependency);
  PackageGraph.OpenDependency(ADependency,false);
  if (ADependency.RequiredPackage<>nil)
  and (not ADependency.RequiredPackage.Missing) then begin
    AddUnitToProjectMainUsesSection(Project1,ADependency.PackageName,'');
  end;
end;

procedure TPkgManager.OnProjectInspectorDragDropTreeView(Sender,
  Source: TObject; X, Y: Integer);
begin
  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.OnProjectInspectorDragDropTreeView START']);
  {$ENDIF}
  FilesEditDragDrop(Sender, Source, X, Y);
  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.OnProjectInspectorDragDropTreeView END']);
  {$ENDIF}
end;

function TPkgManager.OnProjectInspectorDragOverTreeView(Sender,
  Source: TObject; X, Y: Integer; out TargetTVNode: TTreeNode; out
  TargetTVType: TTreeViewInsertMarkType): boolean;
var
  SrcFilesEdit: IFilesEditorInterface;
  TargetFilesEdit: IFilesEditorInterface;
  aFileCount: integer;
  aDependencyCount: integer;
  aDirectoryCount: integer;
begin
  {$IFDEF VerbosePkgEditDrag}
  debugln(['TPkgManager.OnProjectInspectorDragOverTreeView ']);
  {$ENDIF}
  Result:=CheckDrag(Sender, Source, X, Y, SrcFilesEdit, TargetFilesEdit,
    aFileCount, aDependencyCount, aDirectoryCount, TargetTVNode, TargetTVType);
end;

procedure TPkgManager.OnProjectInspectorCopyMoveFiles(Sender: TObject);
begin
  CopyMoveFiles(Sender);
end;

function TPkgManager.CanOpenDesignerForm(AnUnitInfo: TUnitInfo;
  Interactive: boolean): TModalResult;
var
  AProject: TProject;
begin
  Result:=mrCancel;
  if AnUnitInfo=nil then exit;
  AProject:=AnUnitInfo.Project;
  if AProject=nil then exit;
  Result:=CheckProjectHasInstalledPackages(AProject,Interactive);
end;

function TPkgManager.DoClosePackageEditor(APackage: TLazPackage): TModalResult;
begin
  if APackage.Editor<>nil then
    APackage.Editor.Free;
  Result:=mrOk;
end;

function TPkgManager.DoSaveAllPackages(Flags: TPkgSaveFlags): TModalResult;
var
  AllSaved: Boolean;
  i: Integer;
  CurPackage: TLazPackage;
begin
  try
    repeat
      AllSaved:=true;
      i:=0;
      while i<PackageGraph.Count do begin
        CurPackage:=PackageGraph[i];
        if CurPackage.Modified and (not CurPackage.ReadOnly)
        and (not (lpfSkipSaving in CurPackage.Flags)) then begin
          Result:=DoSavePackage(CurPackage,Flags);
          if Result=mrIgnore then begin
            CurPackage.Flags:=CurPackage.Flags+[lpfSkipSaving];
            Result:=mrOk;
          end;
          if Result<>mrOk then exit;
          AllSaved:=false;
        end;
        inc(i);
      end;
    until AllSaved;
  finally
    // clear all lpfSkipSaving flags
    for i:=0 to PackageGraph.Count-1 do begin
      CurPackage:=PackageGraph[i];
      CurPackage.Flags:=CurPackage.Flags-[lpfSkipSaving];
    end;
  end;
  Result:=mrOk;
end;

{ TLazPackageDescriptors }

function TLazPackageDescriptors.GetItems(Index: integer): TPackageDescriptor;
begin
  Result:=TPackageDescriptor(FItems[Index]);
end;

constructor TLazPackageDescriptors.Create;
begin
  PackageDescriptors:=Self;
  FItems:=TFPList.Create;
end;

destructor TLazPackageDescriptors.Destroy;
var
  i: Integer;
begin
  fDestroying:=true;
  for i:=Count-1 downto 0 do Items[i].Release;
  FItems.Free;
  FItems:=nil;
  PackageDescriptors:=nil;
  inherited Destroy;
end;

function TLazPackageDescriptors.Count: integer;
begin
  Result:=FItems.Count;
end;

function TLazPackageDescriptors.GetUniqueName(const Name: string): string;
var
  i: Integer;
begin
  Result:=Name;
  if IndexOf(Result)<0 then exit;
  i:=0;
  repeat
    inc(i);
    Result:=Name+IntToStr(i);
  until IndexOf(Result)<0;
end;

function TLazPackageDescriptors.IndexOf(const Name: string): integer;
begin
  Result:=Count-1;
  while (Result>=0) and (UTF8CompareText(Name,Items[Result].Name)<>0) do
    dec(Result);
end;

function TLazPackageDescriptors.FindByName(const Name: string
  ): TPackageDescriptor;
var
  i: LongInt;
begin
  i:=IndexOf(Name);
  if i>=0 then
    Result:=Items[i]
  else
    Result:=nil;
end;

procedure TLazPackageDescriptors.RegisterDescriptor(
  Descriptor: TPackageDescriptor);
begin
  if Descriptor.Name='' then
    raise Exception.Create('TLazPackageDescriptors.RegisterDescriptor Descriptor.Name empty');
  Descriptor.Name:=GetUniqueName(Descriptor.Name);
  FItems.Add(Descriptor);
end;

procedure TLazPackageDescriptors.UnregisterDescriptor(
  Descriptor: TPackageDescriptor);
var
  i: LongInt;
begin
  if fDestroying then exit;
  i:=FItems.IndexOf(Descriptor);
  if i<0 then
    raise Exception.Create('TLazPackageDescriptors.UnregisterDescriptor');
  FItems.Delete(i);
  Descriptor.Release;
end;

procedure TLazPackageDescriptors.AddDefaultPackageDescriptors;
begin
  NewIDEItems.Add(TNewLazIDEItemCategoryPackage.Create(PkgDescGroupName));
  RegisterPackageDescriptor(TPackageDescriptorStd.Create);
end;

{ TPackageDescriptorStd }

constructor TPackageDescriptorStd.Create;
begin
  inherited Create;
  Name:=PkgDescNameStandard;
end;

function TPackageDescriptorStd.GetLocalizedName: string;
begin
  Result:=lisPackage;
end;

function TPackageDescriptorStd.GetLocalizedDescription: string;
begin
  Result:=Format(lisNewDlgCreateANewStandardPackageAPackageIsACollectionOfUn,
                 [LineEnding]);
end;

end.


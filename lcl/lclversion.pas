{  $Id: lclversion.pas 54277 2017-02-25 23:30:30Z mattias $  }
{
 /***************************************************************************
                               lclversion.pas
                             -------------------
                             Version numbers for the LCL

 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit LCLVersion;

{ At least 2.4.2 is required, except for wince which supports fpc 2.2.0+ too }
{$ifdef Wince}
  {$if defined(ver1) or (FPC_FULLVERSION<20200)}
    {$fatal Lazarus for WinCE requires at least FPC 2.2.0}
  {$endif}
{$else}
  {$if defined(ver1) or (FPC_FULLVERSION<20402) }
    {$fatal Lazarus requires at least FPC 2.4.2}
  {$endif}
{$endif}

{$mode objfpc}{$H+}

interface

const
  lcl_major = 1;
  lcl_minor = 6;
  lcl_release = 4;
  lcl_patch = 0;
  lcl_fullversion = ((lcl_major *  100 + lcl_minor) * 100 + lcl_release) * 100 + lcl_patch;
  lcl_version = '1.6.4.0';

implementation

end.


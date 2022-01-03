{ $Id: fpdglobal.pas 44792 2014-04-23 08:53:41Z joost $ }
{
 ---------------------------------------------------------------------------
 fpdglobal.pas  -  FP standalone debugger - Globals
 ---------------------------------------------------------------------------

 This unit contains global types / vars

 ---------------------------------------------------------------------------

 @created(Mon Apr 10th WET 2006)
 @lastmod($Date: 2014-04-23 10:53:41 +0200 (Mi, 23 Apr 2014) $)
 @author(Marc Weustink <marc@@dommelstein.nl>)

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
}
unit FPDGlobal;
{$mode objfpc}{$H+}
interface

uses
  SysUtils,
  FPDbgController;

type
  TFPDImageInfo = (iiNone, iiName, iiDetail);

var
  GBreakOnLibraryLoad: Boolean = False;
  GImageInfo: TFPDImageInfo = iiNone;

  GController: TDbgController = nil;

implementation

initialization
  GController := TDbgController.Create;
finalization
  GController.Free;
end.

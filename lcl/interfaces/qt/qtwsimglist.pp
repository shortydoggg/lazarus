{ $Id: qtwsimglist.pp 57164 2018-01-27 18:12:35Z ondrej $}
{
 *****************************************************************************
 *                              QtWSImgList.pp                               * 
 *                              --------------                               * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit QtWSImgList;

{$mode objfpc}{$H+}

interface

uses
////////////////////////////////////////////////////
// I M P O R T A N T                                
////////////////////////////////////////////////////
// To get as little as posible circles,
// uncomment only when needed for registration
////////////////////////////////////////////////////
//  ImgList,
////////////////////////////////////////////////////
  WSImgList, WSLCLClasses;

type

  { TQtWSCustomImageListResolution }

  TQtWSCustomImageListResolution = class(TWSCustomImageListResolution)
  published
  end;


implementation

end.

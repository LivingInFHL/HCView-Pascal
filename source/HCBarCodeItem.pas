{*******************************************************}
{                                                       }
{               HCView V1.1  作者：荆通                 }
{                                                       }
{      本代码遵循BSD协议，你可以加入QQ群 649023932      }
{            来获取更多的技术交流 2018-5-4              }
{                                                       }
{         文档BarCodeItem(一维码)对象实现单元           }
{                                                       }
{*******************************************************}

unit HCBarCodeItem;

interface

uses
  Windows, Graphics, Classes, SysUtils, HCStyle, HCItem, HCRectItem, HCCustomData,
  HCCommon, HCCode128B;

type
  THCBarCodeItem = class(THCResizeRectItem)
  private
    FText: string;
  protected
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    //
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    procedure SetText(const Value: string);
  public
    constructor Create(const AOwnerData: THCCustomData; const AText: string);
    destructor Destroy; override;

    /// <summary> 约束到指定大小范围内 </summary>
    procedure RestrainSize(const AWidth, AHeight: Integer); override;

    property Text: string read FText write SetText;
  end;

implementation

{ THCBarCodeItem }

constructor THCBarCodeItem.Create(const AOwnerData: THCCustomData; const AText: string);
begin
  inherited Create(AOwnerData);
  StyleNo := THCStyle.BarCode;
  Width := 100;
  Height := 100;
  SetText(AText);
end;

destructor THCBarCodeItem.Destroy;
begin
  inherited Destroy;
end;

procedure THCBarCodeItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vCode128B: THCCode128B;
  vBitmap: TBitmap;
begin
  vBitmap := TBitmap.Create;
  try
    vCode128B := THCCode128B.Create;
    try
      vCode128B.Height := Height;
      vCode128B.CodeKey := FText;

      vBitmap.SetSize(vCode128B.Width, vCode128B.Height);
      vCode128B.PaintToEx(vBitmap.Canvas);

      ACanvas.StretchDraw(ADrawRect, vBitmap);
    finally
      FreeAndNil(vCode128B);
    end;
  finally
    vBitmap.Free;
  end;

  inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, ACanvas, APaintInfo);
end;

procedure THCBarCodeItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);

  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.ReadBuffer(vBuffer[0], vSize);
    FText := StringOf(vBuffer);
  end;
end;

procedure THCBarCodeItem.RestrainSize(const AWidth, AHeight: Integer);
var
  vBL: Single;
begin
  if Width > AWidth then
  begin
    vBL := Width / AWidth;
    Width := AWidth;
    Height := Round(Height / vBL);
  end;

  if Height > AHeight then
  begin
    vBL := Height / AHeight;
    Height := AHeight;
    Width := Round(Width / vBL);
  end;
end;

procedure THCBarCodeItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FText);
  if System.Length(vBuffer) > MAXWORD then
    raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
  vSize := System.Length(vBuffer);
  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure THCBarCodeItem.SetText(const Value: string);
var
  vBarCode: THCCode128B;
begin
  if FText <> Value then
  begin
    FText := Value;

    vBarCode := THCCode128B.Create;
    try
      vBarCode.CodeKey := FText;
      Width := vBarCode.Width;
    finally
      vBarCode.Free;
    end;
  end;
end;

end.

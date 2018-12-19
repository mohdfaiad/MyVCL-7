unit XLSAdapter;
{$IFDEF LINUX}{$INCLUDE ../FLXCONFIG.INC}{$ELSE}{$INCLUDE ..\FLXCONFIG.INC}{$ENDIF}

//Note: Excel uses 1-Based arrays, and that's the interface we present to our users.
// but, TExcelWorkbook uses 0-Based arrays, to be consistent with the file format (made in C)
//So here we have to add and substract 1 everywere to be consistent.

interface
{$R EmptySheet.res}
uses
  SysUtils, Classes,
  UExcelAdapter, XlsBaseTemplateStore, UFlxMessages, UExcelRecords, XlsMessages,
  UFlxRowComments,
  {$IFDEF WIN32}Windows, WOLE2Stream,{$ENDIF} //Here is not VCL/CLX, but Linux/Windows
  {$IFDEF LINUX}KGsfStream,{$ENDIF}
  {$IFDEF FLX_VCL}Clipbrd,{$ENDIF}
  {$IFDEF FLX_CLX}QClipbrd, {$ENDIF}

  {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants, Types, {$IFEND}{$ENDIF} //Delphi 6 or above
  UXlsSheet, UFlxFormats, UXlsRowColEntries,
  {$IFNDEF TMSASG}
  UTextDelim,
  {$ENDIF}
  UXlsXF;

type
  TExcelSaveFormatNative= (
    snXLS, snCSVComma, snCSVSemiColon, snTabDelimited
    );

  TSetOfExcelSaveFormatNative = Set Of TExcelSaveFormatNative;


type
  TXLSAdapter = class(TExcelAdapter)
  private
    FTemplateStore: TXlsBaseTemplateStore;
    FSaveFormat: TSetOfExcelSaveFormatNative;
    procedure SetTemplateStore(const Value: TXLSBaseTemplateStore);
    { Private declarations }
  protected
    { Protected declarations }
  public
    constructor Create(AOwner:TComponent);override;
    function GetWorkbook: TExcelFile;override;
    { Public declarations }
  published
    property SaveFormat: TSetOfExcelSaveFormatNative read FSaveFormat write FSaveFormat default [snXLS];
    property TemplateStore: TXLSBaseTemplateStore read FTemplateStore write SetTemplateStore;
    { Published declarations }
  end;

  TXLSFile = class(TExcelFile)
  private
    FAdapter: TXLSAdapter;
    FActiveSheet: integer;

    FWorkbook: TWorkbook;
    FTemplate: TXlsStorageList;
    FTmpTemplate: TXlsStorageList;

    FirstColumn,LastColumn: integer;

    RowPictures: TRowComments;
    procedure ParsePictures;
    procedure PasteFromStream(const Row, Col: integer; const Stream: TStream);
    procedure OpenFileOrStream(const FileName: TFileName; const aStream: TStream);
    procedure PasteFromBiff8(const Row, Col: integer);
    procedure PasteFromText(const Row, Col: integer);

    procedure SaveAsXls(const FileName: string; const DataStream: TStream);
    procedure SaveAsTextDelimited(const FileName: string; const DataStream: TStream; const Delim: char);

    procedure InternalSetCellString(const aRow, aCol: integer; const Text: Widestring; const Fm: PFlxFormat; const DateFormat, TimeFormat: widestring);
    procedure SetCellValueAndFmt(const aRow, aCol: integer; const v: variant; const Fm: PFlxFormat);

  protected
    function GetActiveSheet: integer; override;
    procedure SetActiveSheet(const Value: integer); override;
    function GetActiveSheetName: WideString; override;
    procedure SetActiveSheetName(const Value: WideString); override;

    function GetColumnWidth(aCol: integer): integer;override;
    function GetRowHeight(aRow: integer): integer;override;
    procedure SetColumnWidth(aCol: integer; const Value: integer);override;
    procedure SetRowHeight(aRow: integer; const Value: integer);override;

    function GetDefaultColWidth: integer;override;
    function GetDefaultRowHeight: integer;override;

    function GetCommentsCount(Row: integer): integer; override;
    function GetCommentText(Row, aPos: integer): widestring; override;
    function GetCommentColumn(Row, aPos: integer): integer; override;
    function GetPictureName(Row, aPos: integer): widestring;  override; //use row < 0 to return all
    function GetPicturesCount(Row: integer): integer;  override; //use row < 0 to return all

    function GetCellValue(aRow, aCol: integer): Variant; override;
    procedure SetCellValue(aRow, aCol: integer; const Value: Variant); override;
    function GetCellValueX(aRow, aCol: integer): TXlsCellValue; override;
    procedure SetCellValueX(aRow, aCol: integer; const Value: TXlsCellValue); override;

    function GetCellFormula(aRow, aCol: integer): widestring; override;
    procedure SetCellFormula(aRow, aCol: integer; const Value: widestring); override;

    function GetAutoRowHeight(Row: integer): boolean;override;
    procedure SetAutoRowHeight(Row: integer; const Value: boolean);override;

    function GetColumnFormat(aColumn: integer): integer; override;
    function GetRowFormat(aRow: integer): integer;override;
    procedure SetColumnFormat(aColumn: integer; const Value: integer);override;
    procedure SetRowFormat(aRow: integer; const Value: integer);override;

    function GetCellFormat(aRow, aCol: integer): integer; override;
    procedure SetCellFormat(aRow, aCol: integer; const Value: integer); override;

    function GetColorPalette(Index: TColorPaletteRange): LongWord; override;
    procedure SetColorPalette(Index: TColorPaletteRange; const Value: LongWord); override;

    function GetFormatList(index: integer): TFlxFormat; override;

    function GetPageFooter: WideString;override;
    function GetPageHeader: WideString;override;
    procedure SetPageFooter(const Value: WideString);override;
    procedure SetPageHeader(const Value: WideString);override;

    function GetShowGridLines: boolean; override;
    procedure SetShowGridLines(const Value: boolean); override;
    function GetPrintGridLines: boolean; override;
    procedure SetPrintGridLines(const Value: boolean); override;

    function GetSheetZoom: integer;override;
    procedure SetSheetZoom(const Value: integer);override;

    function GetMargins: TXlsMargins;override;
    procedure SetMargins(const Value: TXlsMargins);override;

    function GetPrintNumberOfHorizontalPages: word;override;
    function GetPrintNumberOfVerticalPages: word;override;
    function GetPrintScale: integer;override;
    function GetPrintToFit: boolean;override;
    procedure SetPrintNumberOfHorizontalPages(const Value: word);override;
    procedure SetPrintNumberOfVerticalPages(const Value: word);override;
    procedure SetPrintScale(const Value: integer);override;
    procedure SetPrintToFit(const Value: boolean);override;

    function GetCellMergedBounds(aRow, aCol: integer): TXlsCellRange; override;

  public
    constructor Create(const aAdapter: TXLSAdapter );
    destructor Destroy; override;

    procedure Connect;override;
    procedure Disconnect;override;

    procedure NewFile;override;
    procedure OpenFile(const FileName: TFileName);override;
    procedure LoadFromStream(const aStream: TStream);override;
    procedure CloseFile; override;

    procedure InsertAndCopySheets (const CopyFrom, InsertBefore, SheetCount: integer);override;
    function SheetCount: integer;override;
    procedure SelectSheet(const SheetNo:integer); override;

    procedure DeleteMarkedRows(const Mark: widestring);override;
    procedure RefreshChartRanges(const VarStr: string);override;
    procedure MakePageBreaks(const Mark: widestring);override;
    procedure InsertHPageBreak(const Row: integer); override;
    procedure InsertVPageBreak(const Col: integer); override;
    procedure DeleteHPageBreak(const Row: integer); override;
    procedure DeleteVPageBreak(const Col: integer); override;
    function HasHPageBreak(const Row: integer): boolean;override;
    function HasVPageBreak(const Col: integer): boolean;override;
    procedure RefreshPivotTables;override;

    procedure Save(const AutoClose: boolean; const FileName: string; const OnGetFileName: TOnGetFileNameEvent; const OnGetOutStream: TOnGetOutStreamEvent=nil; const DataStream: TStream=nil);override;

    procedure InsertAndCopyRows(const FirstRow, LastRow, DestRow, aCount: integer; const OnlyFormulas: boolean);override;
    procedure DeleteRows(const aRow, aCount: integer);override;

    procedure BeginSheet;override;
    procedure EndSheet(const RowOffset: integer);override;

    function CanOptimizeRead: boolean; override;


    function GetExcelNameCount: integer;  override;
    function GetRangeName(index: integer): widestring;  override;
    function GetRangeR1(index: integer): integer; override;
    function GetRangeR2(index: integer): integer; override;
    function GetRangeC1(index: integer): integer; override;
    function GetRangeC2(index: integer): integer; override;
    function GetRangeSheet(index: integer): integer; override;

    procedure AssignPicture(const Row, aPos: integer; const Pic: string; const PicType: TXlsImgTypes); override; //use row < 0 to return all
    procedure GetPicture(const Row, aPos: integer; const Pic: TStream; var PicType: TXlsImgTypes; var Anchor: TClientAnchor); override; //use row < 0 to return all

    procedure DeleteImage(const Index: integer);override;
    procedure ClearImage(const Index: integer);override;
    procedure AddImage(const Data: string; const DataType: TXlsImgTypes; const Properties: TImageProperties;const Anchor: TFlxAnchorType);override;

    procedure AssignComment(const Row, aPos: integer; const Comment: widestring); override;
    function GetCellComment(Row, Col: integer): widestring; override;
    procedure SetCellComment(Row, Col: integer; const Value: widestring; const Properties: TImageProperties); override;

    procedure MergeCells(const FirstRow, FirstCol, LastRow, LastCol: integer); override;

    function CellCount(const aRow: integer): integer;override;
    function GetCellData(const aRow, aColOffset: integer): variant;override;
    function GetCellDataX(const aRow, aColOffset: integer): TXlsCellValue;override;
    procedure AssignCellData(const aRow, aColOffset: integer; const Value: variant);override;
    procedure AssignCellDataX(const aRow, aColOffset: integer; const Value: TXlsCellValue);override;
    procedure SetCellString(const aRow, aCol: integer; const Text: Widestring; const DateFormat: widestring=''; const TimeFormat: widestring='');overload;override;
    procedure SetCellString(const aRow, aCol: integer; const Text: Widestring; const Fm: TFlxFormat; const DateFormat: widestring=''; const TimeFormat: widestring='');overload;override;
    function MaxRow: integer; override;
    function MaxCol: integer; override;
    function IsEmptyRow(const aRow: integer): boolean; override;

    function ColByIndex(const Row, ColIndex: integer): integer;override;
    function ColIndexCount(const Row: integer): integer; override;
    function ColIndex(const Row, Col: integer): integer;override;

    procedure SetBounds(const aRangePos: integer);override;
    function GetFirstColumn: integer; override;

    procedure PrepareBlockData(const R1,C1,R2,C2: integer);override;
    procedure AssignBlockData(const Row,Col: integer; const v: variant);override;
    procedure PasteBlockData;override;

    function IsWorksheet(const index: integer): boolean; override;

    function FormatListCount: integer;override;
    function AddFormat (const Fmt: TFlxFormat): integer; override;

    procedure CopyToClipboard; overload; override;
    procedure CopyToClipboard(const Range: TXlsCellRange);overload;override;
    procedure PasteFromClipboard(const Row, Col: integer);override;

    procedure ParseComments; override;
  end;


{$IFNDEF TMSASG}
  procedure Register;
{$ENDIF}
implementation

uses UXlsBaseRecordLists, UXlsBaseRecords, UXlsNotes;
{$IFNDEF TMSASG}
  {$R IXLSAdapter.res}

procedure Register;
begin
  RegisterComponents('FlexCel', [TXLSAdapter]);
end;
{$ENDIF}
{ TXLSAdapter }

constructor TXLSAdapter.Create(AOwner: TComponent);
begin
  inherited;
  FSaveFormat:=[snXLS];
end;

function TXLSAdapter.GetWorkbook: TExcelFile;
begin
  Result:= TXLSFile.Create(Self);
end;

procedure TXLSAdapter.SetTemplateStore(const Value: TXLSBaseTemplateStore);
begin
  FTemplateStore := Value;
end;

{ TXLSFile }

procedure TXLSFile.AssignCellData(const aRow, aColOffset: integer; const Value: variant);
var
  V: TXlsCellValue;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
    V.Value:=Value; V.XF:=-1;
    FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1, FirstColumn + aColOffset]:=V;
end;

procedure TXLSFile.SetCellValueAndFmt(const aRow, aCol: integer; const v: variant; const Fm: PFlxFormat);
var
  Value: TXlsCellValue;
begin
  if Fm=nil then SetCellValue(ARow, ACol, v) else
  begin
    Value.XF:=AddFormat(Fm^);
    Value.Value:=v;
    Value.IsFormula:=False;
    SetCellValueX(aRow, aCol, Value);
  end;
end;

procedure TXLSFile.InternalSetCellString(const aRow, aCol: integer; const Text: Widestring; const Fm: PFlxFormat; const DateFormat, TimeFormat: widestring);
var
  e:extended;
  s: string;
  dt: TDateTime;
  dFormat: widestring;
  Fmt: TFlxFormat;
  HasTime, HasDate: boolean;
begin
  //try to convert to number
  s:=Text; //for if value is a widestring
  if TextToFloat(PChar(s), e, fvExtended) then  //Dont use val because it doesnt handle locales
    SetCellValueAndFmt(ARow, ACol, e, Fm) else
  //try to convert to boolean
    if UpperCase(s)=TxtFalse then SetCellValueAndFmt(ARow, ACol, false, Fm)  else
    if UpperCase(s)=TxtTrue then SetCellValueAndFmt(ARow, ACol, true, Fm) else
  //try to convert to a date
    if FlxTryStrToDateTime(s, dt, dFormat, HasDate, HasTime, DateFormat, TimeFormat) then
    begin
      if Fm=nil then Fmt:=GetFormatList(CellFormat[ARow, ACol]) else Fmt:=Fm^;
      Fmt.Format:=dFormat;
      SetCellValueAndFmt(ARow, ACol, double(dt), @Fmt)
    end else

    SetCellValueAndFmt(ARow, ACol, Text, Fm);
end;

procedure TXLSFile.SetCellString(const aRow, aCol: integer; const Text: Widestring; const DateFormat: widestring; const TimeFormat: widestring);
begin
  InternalSetCellString(aRow, aCol, Text, nil, DateFormat, TimeFormat);
end;

procedure TXLSFile.SetCellString(const aRow, aCol: integer; const Text: Widestring; const Fm: TFlxFormat; const DateFormat: widestring; const TimeFormat: widestring);
begin
  InternalSetCellString(aRow, aCol, Text, @Fm, DateFormat, TimeFormat);
end;


procedure TXLSFile.AssignCellDataX(const aRow, aColOffset: integer; const Value: TXlsCellValue);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1, FirstColumn + aColOffset]:=Value;
end;

procedure TXLSFile.AssignComment(const Row, aPos: integer;
  const Comment: widestring);
begin
  if FWorkbook.IsWorkSheet(ActiveSheet-1) then
  begin
    if Comment='' then FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1].Delete(aPos) else
    FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1][aPos].Text:= Comment;
  end;
end;

procedure TXLSFile.AssignPicture(const Row, aPos: integer; const Pic: string; const PicType: TXlsImgTypes);
var
  MyPos: integer;
begin
  if Row>0 then MyPos:=RowPictures[Row][aPos] else MyPos:=aPos;
  if FWorkbook.IsWorkSheet(ActiveSheet-1) then
    FWorkbook.WorkSheets[ActiveSheet-1].AssignDrawing(MyPos, Pic, PicType);
end;

procedure TXLSFile.GetPicture(const Row, aPos: integer; const Pic: TStream;
  var PicType: TXlsImgTypes; var Anchor: TClientAnchor);
var
  MyPos: integer;
begin
  if Row>0 then MyPos:=RowPictures[Row][aPos] else MyPos:=aPos;
  if FWorkbook.IsWorkSheet(ActiveSheet-1) then
  begin
    FWorkbook.WorkSheets[ActiveSheet-1].GetDrawingFromStream(MyPos, Pic, PicType);
    Anchor:=FWorkbook.WorkSheets[ActiveSheet-1].GetAnchor(MyPos);
    inc(Anchor.Col1);
    inc(Anchor.Col2);
    inc(Anchor.Row1);
    inc(Anchor.Row2);
  end;
end;

procedure TXLSFile.ParsePictures;
var
  i:integer;

begin
  FreeAndNil(RowPictures);
  RowPictures:= TRowComments.Create;
  if FWorkbook.IsWorkSheet(ActiveSheet-1) then
    for i:=0 to FWorkbook.WorkSheets[ActiveSheet-1].DrawingCount-1 do
      RowPictures.Add(FWorkbook.WorkSheets[ActiveSheet-1].DrawingRow[i]+1, i);
end;


procedure TXLSFile.BeginSheet;
begin
  ParsePictures;
end;

function TXLSFile.CellCount(const aRow: integer): integer;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=0; exit; end;
  if aRow-1<FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Count then
    Result:=LastColumn-FirstColumn+1
  else Result:=0;
end;

procedure TXLSFile.CloseFile;
begin
  //Nothing
end;

procedure TXLSFile.Connect;
begin
  FWorkbook:= TWorkbook.Create;
end;

constructor TXLSFile.Create(const aAdapter: TXLSAdapter);
begin
  inherited Create;
  FAdapter:= aAdapter;
end;

procedure TXLSFile.DeleteMarkedRows(const Mark: widestring);
var
  i:integer;
  s: widestring;
  Cl: TCellList;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Cl:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList;
  for i:=Cl.Count -1 downto 0 do
  try
    s:= Cl.Value[i,0].Value;
    if (s=Mark) then
      FWorkbook.DeleteRows(FActiveSheet-1, i, 1);
  except
    //nothing
  end;//except
end;

procedure TXLSFile.MakePageBreaks(const Mark: widestring);
var
  i:integer;
  s: widestring;
  V: TXlsCellValue;
  Cl: TCellList;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  V.Value:=Unassigned; V.XF:=-1;
  Cl:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList;
  for i:=Cl.Count -1 downto 0 do
  try
    s:= Cl.Value[i,0].Value;
    if (s=Mark) then
    begin
      FWorkbook.InsertHPageBreak(FActiveSheet-1, i);
      FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[i,0]:=V;
    end;
  except
    //nothing
  end;//except
end;

procedure TXLSFile.DeleteRows(const aRow, aCount: integer);
begin
  FWorkbook.DeleteRows(FActiveSheet-1, aRow-1, aCount);
end;

destructor TXLSFile.Destroy;
begin
  FreeAndNil(RowPictures);
  FreeAndNil(FTmpTemplate);
  inherited;
end;

procedure TXLSFile.Disconnect;
begin
  FreeAndNil(FWorkbook);
end;

procedure TXLSFile.EndSheet(const RowOffset: integer);
begin
  //Nothing
end;

function TXLSFile.GetActiveSheet: integer;
begin
  Result:= FActiveSheet;
end;

function TXLSFile.GetActiveSheetName: WideString;
begin
  Result:= FWorkbook.Globals.SheetName[FActiveSheet-1];
end;

function TXLSFile.GetCellData(const aRow, aColOffset: integer): variant;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=unassigned; exit; end;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1,FirstColumn+aColOffset].Value;
end;

function TXLSFile.GetCellDataX(const aRow, aColOffset: integer): TXlsCellValue;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result.Value:=unassigned; Result.XF:=-1; exit; end;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1,FirstColumn+aColOffset];
end;

function TXLSFile.GetCommentsCount(Row: integer): integer;
begin
  if FWorkbook.IsWorkSheet(ActiveSheet-1) then
    if Row-1<FWorkbook.WorkSheets[ActiveSheet-1].Notes.Count then
      Result:=FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1].Count
    else
      Result:=0
  else
    Result:=0;
end;

function TXLSFile.GetCommentText(Row, aPos: integer): widestring;
begin
  if FWorkbook.IsWorkSheet(ActiveSheet-1)
    and (Row-1<FWorkbook.WorkSheets[ActiveSheet-1].Notes.Count) then
      Result:=FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1][aPos].Text
    else
      Result:='';
end;

function TXLSFile.GetExcelNameCount: integer;
begin
  Result:=FWorkbook.Globals.Names.Count;
end;

function TXLSFile.GetPictureName(Row, aPos: integer): widestring;
var
  MyPos: integer;
begin
  if Row>0 then MyPos:=RowPictures[Row][aPos] else MyPos:=aPos;
  Result:= '';
  if not FWorkbook.IsWorksheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].DrawingName[MyPos];
end;

function TXLSFile.GetPicturesCount(Row: integer): integer;
begin
  Result:=0;
  if not FWorkbook.IsWorksheet(FActiveSheet-1) then exit;
  if Row>0 then Result:=RowPictures[Row].Count else
    Result:= FWorkbook.WorkSheets[ActiveSheet-1].DrawingCount;
end;

function TXLSFile.GetRangeName(index: integer): widestring;
begin
  Result:= FWorkbook.Globals.Names[index-1].Name;
end;

function TXLSFile.GetRangeR1(index: integer): integer;
begin
  Result:= FWorkbook.Globals.Names[index-1].R1+1;
end;

function TXLSFile.GetRangeR2(index: integer): integer;
begin
  Result:= FWorkbook.Globals.Names[index-1].R2+1;
end;

function TXLSFile.GetRangeC1(index: integer): integer;
begin
  Result:= FWorkbook.Globals.Names[index-1].C1+1;
end;

function TXLSFile.GetRangeC2(index: integer): integer;
begin
  Result:= FWorkbook.Globals.Names[index-1].C2+1;
end;

function TXLSFile.GetRangeSheet(index: integer): integer;
begin
  Result:= FWorkbook.Globals.Names[index-1].RefersToSheet(FWorkbook.Globals.References.GetSheet)+1;
end;

procedure TXLSFile.InsertAndCopyRows(const FirstRow, LastRow, DestRow,
  aCount: integer; const OnlyFormulas: boolean);
begin
  FWorkbook.InsertAndCopyRows(FActiveSheet-1, FirstRow-1, LastRow-1, DestRow-1, aCount, OnlyFormulas)
end;

procedure TXLSFile.InsertAndCopySheets(const CopyFrom, InsertBefore,
  SheetCount: integer);
begin
  FWorkbook.InsertSheets(CopyFrom-1, InsertBefore-1, SheetCount);
end;

procedure TXLSFile.OpenFileOrStream(const FileName: TFileName; const aStream: TStream);
var
  WorkbookStr: widestring;
  DocIN: TOle2Storage;
  StreamIN: TOle2Stream;
  Fn: string;
begin
  WorkbookStr:=WorkbookStrS;
  FTemplate:=nil;
  FreeAndNil(FTmpTemplate);

  if (FAdapter<>nil) and (FAdapter.TemplateStore<>nil) then
  begin
    FTemplate:=FAdapter.TemplateStore.Storages[FileName];
    FWorkbook.LoadFromStream(FTemplate.Stream[WorkbookStr]);
  end
  else
  begin
    FTmpTemplate:=TXlsStorageList.Create;
    if Trim(FileName)<>'' then Fn:=SearchPathStr(FileName) else Fn:='';
    //This is to load all storages except workbook. For reading big files, makes no sense to keep workbook on memory 2 times
    DocIN:= TOle2Storage.Create(Fn, Ole2_Read, aStream);
    try
      FTmpTemplate.LoadStorage(DocIN, false);
      StreamIn:= TOle2Stream.Create( DocIN, WorkbookStr);
      try
        FWorkbook.LoadFromStream(StreamIn);
      finally
        FreeAndNil(StreamIn);
      end; //finally
    finally
      FreeAndNil(DocIN);
    end; //finally
    FTemplate:=FTmpTemplate;

  end;
  FActiveSheet:=FWorkbook.ActiveSheet+1;
end;

procedure TXLSFile.OpenFile(const FileName: TFileName);
begin
  OpenFileOrStream(FileName, nil);
end;

procedure TXLSFile.LoadFromStream(const aStream: TStream);
begin
  OpenFileOrStream('', aStream);
end;

procedure TXLSFile.RefreshPivotTables;
begin
  //Nothing
end;



procedure TXLSFile.SaveAsXls(const FileName: string; const DataStream: TStream);
var
  WorkbookStr: widestring;

  i:integer;
  DocOUT: TOle2Storage;
  StreamOUT: TOle2Stream;
begin
  WorkbookStr:=WorkbookStrS;
  //Create output file
  DocOUT:= TOle2Storage.Create(FileName, Ole2_Write, DataStream);
  try
    for i:=0 to FTemplate.Count-1 do
      if FTemplate[i].Name<>WorkbookStr then
      begin
        FTemplate[i].SaveToDoc(DocOUT);
      end;

    StreamOUT:= TOle2Stream.Create(DocOUT, WorkbookStr);
    try
      FWorkbook.SaveToStream(StreamOUT);
    finally
      FreeAndNil(StreamOut);
    end; //finally
  finally
    FreeAndNil(DocOUT);
  end; //Finally
end;

procedure TXLSFile.SaveAsTextDelimited(const FileName: string;
  const DataStream: TStream; const Delim: char);
{$IFNDEF TMSASG}
var
  OutStream: TFileStream;
{$ENDIF}
begin
{$IFNDEF TMSASG}
  if DataStream=nil then
  begin
    OutStream:=TFileStream.Create(FileName, fmCreate);
    try
      SaveAsTextDelim(OutStream, Self, Delim);
    finally
      FreeAndNil(OutStream);
    end; //finally
  end
  else
    SaveAsTextDelim(DataStream, Self, Delim);
{$ENDIF}
end;


procedure TXLSFile.Save(const AutoClose: boolean; const FileName: string; const OnGetFileName: TOnGetFileNameEvent; const OnGetOutStream: TOnGetOutStreamEvent=nil; const DataStream: TStream=nil);
var
  aFileName: TFileName;
  OutStream: TStream;
  SF: TExcelSaveFormatNative;
begin
  for SF:=Low(TExcelSaveFormatNative) to High(TExcelSaveFormatNative) do
    if ((FAdapter<>nil) and (SF in FAdapter.SaveFormat))or
       ((FAdapter=nil) and (SF = snXLS)) then
    begin
      aFileName:=Filename;
      OutStream:=nil;
      if Assigned(DataStream) then
      begin
        //Save to stream
        OutStream:=DataStream;
      end
      else
      if Assigned (OnGetOutStream) then
      begin
        //SaveToStream
        OnGetOutStream(Self,integer(SF),OutStream);
      end else
      begin
        //SaveToFile
        if Assigned (OnGetFileName) then OnGetFileName(Self,integer(SF),aFilename);
        if FileExists(aFileName) then raise Exception.CreateFmt(ErrCantWriteToFile, [aFileName]);  //this is to avoid a criptic ole xxxx error...
      end;

      case SF of
        snXLS: SaveAsXls(aFileName, OutStream);
        snCSVComma: SaveAsTextDelimited(aFileName, OutStream, ',');
        snCSVSemiColon: SaveAsTextDelimited(aFileName, OutStream, ';');
        snTabDelimited: SaveAsTextDelimited(aFileName, OutStream, #9);
        else raise Exception.Create(ErrInternal);
      end; //case
    end;
end;

procedure TXLSFile.SelectSheet(const SheetNo:integer);
begin
  FWorkbook.ActiveSheet:=SheetNo-1;
end;

procedure TXLSFile.SetActiveSheet(const Value: integer);
begin
  FActiveSheet:=Value;
end;

procedure TXLSFile.SetActiveSheetName(const Value: WideString);
begin
  FWorkbook.Globals.SheetName[FActiveSheet-1]:= Value;
end;

procedure TXLSFile.SetBounds(const aRangePos: integer);
begin
  FirstColumn:=FWorkbook.Globals.Names[aRangePos-1].C1;
  LastColumn:=FWorkbook.Globals.Names[aRangePos-1].C2;
end;

function TXLSFile.SheetCount: integer;
begin
  Result:=FWorkbook.Globals.SheetCount;
end;

procedure TXLSFile.AssignBlockData(const Row, Col: integer; const v: variant);
begin
  AssignCellData(Row, Col, v);
end;

procedure TXLSFile.PasteBlockData;
begin
  // Nothing
end;

procedure TXLSFile.PrepareBlockData(const R1, C1, R2, C2: integer);
begin
  // Nothing
end;

function TXLSFile.MaxRow: integer;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=0;exit;end;
  Result:= FWorkbook.WorkSheets[FActiveSheet-1].Cells.RowList.Count;
end;

function TXLSFile.MaxCol: integer;
var
  i: integer;
begin
  Result:=0;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;

  with FWorkbook.WorkSheets[FActiveSheet-1].Cells.RowList do
    for i:=0 to Count-1 do
      if HasRow(i) then
        if Items[i].MaxCol> Result then Result:= Items[i].MaxCol; //MaxCol is 0 based, but references the last used col +1
end;

function TXLSFile.GetCellValue(aRow, aCol: integer): Variant;
begin
  Result:= GetCellData(aRow, aCol-FirstColumn-1);
end;

procedure TXLSFile.SetCellValue(aRow, aCol: integer; const Value: Variant);
begin
  AssignCellData(aRow, aCol-FirstColumn-1, Value);
end;

function TXLSFile.IsEmptyRow(const aRow: integer): boolean;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=true;exit;end;
  Result:=
    (aRow-1<0) or (aRow-1>= FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Count) or
    not FWorkbook.WorkSheets[FActiveSheet-1].Cells.RowList.HasRow(aRow-1);
end;


function TXLSFile.CanOptimizeRead: boolean;
begin
  Result:=true;
end;

procedure TXLSFile.RefreshChartRanges(const VarStr: string);
begin
  //not implemented
end;

function TXLSFile.IsWorksheet(const index: integer): boolean;
begin
  Result:= FWorkbook.Sheets[index-1] is TWorkSheet;
end;


function TXLSFile.GetColumnWidth(aCol: integer): integer;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=0;exit;end;
  Result:= FWorkbook.WorkSheets[FActiveSheet-1].GetColWidth(aCol-1);
end;

function TXLSFile.GetRowHeight(aRow: integer): integer;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=0;exit;end;
  Result:= FWorkbook.WorkSheets[FActiveSheet-1].GetRowHeight(aRow-1);
end;

procedure TXLSFile.SetColumnWidth(aCol: integer; const Value: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].SetColWidth(aCol-1, Value);
end;

procedure TXLSFile.SetRowHeight(aRow: integer; const Value: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].SetRowHeight(aRow-1, Value);
end;

function TXLSFile.GetFirstColumn: integer;
begin
  Result:=FirstColumn+1;
end;

function TXLSFile.GetCellValueX(aRow, aCol: integer): TXlsCellValue;
begin
  Result:= GetCellDataX(aRow, aCol-FirstColumn-1);
end;

procedure TXLSFile.SetCellValueX(aRow, aCol: integer;
  const Value: TXlsCellValue);
begin
  AssignCellDataX(aRow, aCol-FirstColumn-1, Value);
end;

function TXLSFile.GetAutoRowHeight(Row: integer): boolean;
begin
  Result:=true;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.RowList.IsAutoRowHeight(Row-1);
end;

procedure TXLSFile.SetAutoRowHeight(Row: integer; const Value: boolean);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].Cells.RowList.AutoRowHeight(Row-1, Value);
end;

function TXLSFile.GetColorPalette(Index: TColorPaletteRange): LongWord;
begin
  Result:=FWorkbook.Globals.ColorPalette[Index-1];
end;

procedure TXLSFile.SetColorPalette(Index: TColorPaletteRange;
  const Value: LongWord);
begin
  FWorkbook.Globals.ColorPalette[Index-1]:=Value;
end;

function TXLSFile.GetColumnFormat(aColumn: integer): integer;
begin
  Result:=-1;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].GetColFormat(aColumn-1);
end;

function TXLSFile.GetRowFormat(aRow: integer): integer;
begin
  Result:=0;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].GetRowFormat(aRow-1);
end;

procedure TXLSFile.SetColumnFormat(aColumn: integer; const Value: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].SetColFormat(aColumn-1, Value);
end;

procedure TXLSFile.SetRowFormat(aRow: integer; const Value: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].SetRowFormat(aRow-1, Value);
end;

function TXLSFile.FormatListCount: integer;
begin
  Result:=FWorkbook.Globals.XF.Count;
end;

function TXLSFile.GetFormatList(index: integer): TFlxFormat;
begin
  if (Index<0) or (Index>=FWorkbook.Globals.XF.Count) then Index:=0;
  Result:=FWorkbook.Globals.XF[index].FlxFormat(FWorkbook.Globals.Fonts, FWorkbook.Globals.Formats);
end;

function TXLSFile.AddFormat(const Fmt: TFlxFormat): integer;
var
  XF: TXFRecord;
begin
  XF:= TXFRecord.CreateFromFormat(Fmt, FWorkbook.Globals.Fonts, FWorkbook.Globals.Formats);
  try
    if FWorkbook.Globals.XF.FindFormat(XF, Result) then
    begin
      FreeAndNil(XF);
      exit;
    end;

    Result:=FWorkbook.Globals.XF.Add(XF);
  except
    FreeAndNil(XF);
    raise;
  end; //Except

end;

function TXLSFile.ColByIndex(const Row, ColIndex: integer): integer;
begin
  Result:=0;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  if IsEmptyRow(Row) then exit;
  if (ColIndex<=0) or (ColIndex>FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList[Row-1].Count) then exit;
  Result:= FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList[Row-1][ColIndex-1].Column+1;
end;

function TXLSFile.ColIndexCount(const Row: integer): integer;
begin
  Result:=0;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  if IsEmptyRow(Row) then exit;
  Result:= FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList[Row-1].Count;
end;

function TXLSFile.ColIndex(const Row, Col: integer): integer;
begin
  Result:=0;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  if IsEmptyRow(Row) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList[Row-1].Find(Col, Result);
  inc(Result);
end;

function TXLSFile.GetDefaultColWidth: integer;
begin
  Result:=$A;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].DefColWidth;
end;

function TXLSFile.GetDefaultRowHeight: integer;
begin
  Result:=$FF;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].DefRowHeight;
end;


function TXLSFile.GetShowGridLines: boolean;
begin
  Result:=true;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].ShowGridLines;
end;

procedure TXLSFile.SetShowGridLines(const Value: boolean);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].ShowGridLines:=value;
end;

function TXLSFile.GetPrintGridLines: boolean;
begin
  Result:=true;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].PrintGridLines;
end;

procedure TXLSFile.SetPrintGridLines(const Value: boolean);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].PrintGridLines:=value;
end;


function TXLSFile.GetCellMergedBounds(aRow, aCol: integer): TXlsCellRange;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].CellMergedBounds(aRow-1, aCol-1);
  inc(Result.Left);
  inc(Result.Top);
  inc(Result.Right);
  inc(Result.Bottom);
end;

{$IFDEF FLX_VCL}
procedure TXLSFile.CopyToClipboard(const Range: TXlsCellRange);
{$IFNDEF TMSASG}
var
  MyHandle: THandle;
  BiffPtr: pointer;
  MemStream: TMemoryStream;
  FreeHandle: boolean;
  AsText: TStringStream;

  DocOUT: TOle2Storage;
  StreamOUT: TOle2Stream;
  WorkbookStr: widestring;
  Range0: TXlsCellRange;
{$ENDIF}
begin
{$IFNDEF TMSASG}
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  WorkbookStr:=WorkbookStrS;

  AsText:=TStringStream.Create('');
  try
    SaveRangeAsTextDelim(AsText, Self ,#9,Range);

    Range0:=Range;
    Dec(Range0.Left); Dec(Range0.Top); Dec(Range0.Right); Dec(Range0.Bottom);
    if (Range0.Left<0)or(Range0.Top<0)or(Range0.Right<Range0.Left)or(Range0.Bottom<Range0.Top)then exit;

    MemStream:=TMemoryStream.Create;
    try
      DocOUT:= TOle2Storage.Create('', Ole2_Write, MemStream);
      try
        StreamOUT:= TOle2Stream.Create(DocOUT, WorkbookStr);
        try
          FWorkbook.SaveRangeToStream(StreamOUT, FActiveSheet-1, Range0);
        finally
          FreeAndNil(StreamOut);
        end; //finally
      finally
        FreeAndNil(DocOUT);
      end; //Finally

      MemStream.Position:=0;

      FreeHandle:=true;
      MyHandle:=GlobalAlloc(GMEM_MOVEABLE, MemStream.Size);
      try
        BiffPtr:=GlobalLock(MyHandle);
        try
          MemStream.Read(BiffPtr^, MemStream.Size);
        finally
          GlobalUnlock(MyHandle);
        end; //finally

        Clipboard.Clear;
        ClipBoard.Open;
        try
          Clipboard.SetAsHandle(RegisterClipboardFormat('Biff8'), MyHandle);
          FreeHandle:=false;       //Note that we dont have to free MyHandle if the clipboard takes care of it
          //MADE: Add Text Format
          Clipboard.SetTextBuf(PChar(AsText.DataString));
          //PENDING: Add HTML format.
        finally
          Clipboard.Close;
        end; //Finally
      except
        if FreeHandle then GlobalFree(MyHandle);
        raise
      end; //except
    finally
      FreeAndNil(MemStream);
    end;
  finally
    FreeAndNil(AsText);
  end;
{$ENDIF}
end;
{$ENDIF}

{$IFDEF FLX_CLX}
procedure TXLSFile.CopyToClipboard(const Range: TXlsCellRange);
var
  MemStream: TMemoryStream;
  AsText: TStringStream;

  DocOUT: TOle2Storage;
  StreamOUT: TOle2Stream;
  WorkbookStr: widestring;
  Range0: TXlsCellRange;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  WorkbookStr:=WorkbookStrS;

  AsText:=TStringStream.Create('');
  try
    SaveRangeAsTextDelim(AsText, Self ,#9,Range);
    AsText.Position:=0;

    Range0:=Range;
    Dec(Range0.Left); Dec(Range0.Top); Dec(Range0.Right); Dec(Range0.Bottom);
    if (Range0.Left<0)or(Range0.Top<0)or(Range0.Right<Range0.Left)or(Range0.Bottom<Range0.Top)then exit;

    MemStream:=TMemoryStream.Create;
    try
      DocOUT:= TOle2Storage.Create('', Ole2_Write, MemStream);
      try
        StreamOUT:= TOle2Stream.Create(DocOUT, WorkbookStr);
        try
          FWorkbook.SaveRangeToStream(StreamOUT, FActiveSheet-1, Range0);
        finally
          FreeAndNil(StreamOut);
        end; //finally
      finally
        FreeAndNil(DocOUT);
      end; //Finally

      MemStream.Position:=0;

      ClipBoard.SetFormat('Biff8', MemStream);
      ClipBoard.AddFormat('text/plain', AsText)
      //MADE: Add text format
    finally
      FreeAndNil(MemStream);
    end;
  finally
    FreeAndNil(AsText);
  end; //finally
end;
{$ENDIF}

procedure TXLSFile.CopyToClipboard;
var
  Range: TXlsCellRange;
begin
  Range.Left:=1;
  Range.Top:=1;
  Range.Right:= MaxCol;
  Range.Bottom:= MaxRow;
  CopyToClipboard(Range);
end;

procedure TXlsFile.PasteFromStream(const Row, Col: integer; const Stream: TStream);
var
  TempWorkbook: TWorkbook;
  r,c: integer;
  Value: TXlsCellValue;
  XF: TXFRecord;
  DocIN: TOle2Storage;
  StreamIN: TOle2Stream;
  WorkbookStr: widestring;
  d: TDimensionsRec;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  WorkbookStr:=  WorkbookStrS;

  TempWorkbook:=TWorkbook.Create;
  try
    DocIN:= TOle2Storage.Create('', Ole2_Read, Stream);
    try
      StreamIn:= TOle2Stream.Create( DocIN, WorkbookStr);
      try
        TempWorkbook.LoadFromStream(StreamIn);
        if (TempWorkbook.Sheets.Count<=0) or (not TempWorkbook.IsWorksheet(0)) then exit; //Biff8 only pastes one sheet
        d:=TempWorkbook.WorkSheets[0].OriginalDimensions;
        for r:= d.FirstRow to d.LastRow-1 do
          for c:= d.FirstCol to d.LastCol-1 do
          begin
            Value:=TempWorkbook.WorkSheets[0].Cells.CellList.Value[r,c];
            if Value.XF<0 then XF:=TempWorkbook.Globals.XF[0] else XF:= TempWorkbook.Globals.XF[Value.XF];
            if not FWorkbook.Globals.XF.FindFormat( XF, Value.XF) then
              Value.XF:=FWorkbook.Globals.XF.Add(TXFRecord.CreateFromFormat(XF.FlxFormat(TempWorkbook.Globals.Fonts, TempWorkbook.Globals.Formats), FWorkbook.Globals.Fonts, FWorkbook.Globals.Formats));

            FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[int64(Row)-1+r-d.FirstRow, int64(Col)-1+c-d.FirstCol]:=Value;
          end;
      finally
        FreeAndNil(StreamIn);
      end; //finally
    finally
      FreeAndNil(DocIn);
    end; //finally
  finally
    FreeAndNil(TempWorkbook);
  end; //Finally

end;

{$IFDEF FLX_VCL}
procedure TXlsFile.PasteFromBiff8(const Row, Col: integer);
var
  MyHandle: THandle;
  BiffPtr: pointer;
  BiffSize: Cardinal;
  MemStream: TMemoryStream;
begin
  ClipBoard.Open;
  try
    MyHandle := Clipboard.GetAsHandle(RegisterClipboardFormat('Biff8'));
    BiffPtr := GlobalLock(MyHandle);
    try
      BiffSize:=GlobalSize(MyHandle);
      MemStream:=TMemoryStream.Create;
      try
        MemStream.Write(BiffPtr^, BiffSize);
        MemStream.Position:=0;
        PasteFromStream(Row, Col, MemStream);
      finally
        FreeAndNil(MemStream);
      end; //finally
    finally
      GlobalUnlock(MyHandle);
    end;
  finally
    Clipboard.Close;
  end;
end;
{$ENDIF}

procedure TXlsFile.PasteFromText(const Row, Col: integer);
{$IFNDEF TMSASG}
var
  InStream: TStringStream;
{$ENDIF}
begin
{$IFNDEF TMSASG}
  InStream:=TStringStream.Create(ClipBoard.AsText);
  try
    LoadFromTextDelim(InStream, Self, #9, Row, Col,[]);
  finally
    FreeAndNil(InStream);
  end; //finally
{$ENDIF}
end;

{$IFDEF FLX_VCL}
procedure TXLSFile.PasteFromClipboard(const Row, Col: integer);
begin
  if Clipboard.HasFormat(RegisterClipboardFormat('Biff8')) then PasteFromBiff8(Row, Col) else
  if Clipboard.HasFormat(CF_TEXT) then PasteFromText(Row, Col);
end;
{$ENDIF}


{$IFDEF FLX_CLX}
procedure TXlsFile.PasteFromBiff8(const Row, Col: integer);
var
  MemStream: TMemoryStream;
begin
  MemStream:=TMemoryStream.Create;
  try
    ClipBoard.GetFormat('Biff8', MemStream);
    MemStream.Position:=0;
    PasteFromStream(Row, Col, MemStream);
  finally
    FreeAndNil(MemStream);
  end; //finally
end;

procedure TXLSFile.PasteFromClipboard(const Row, Col: integer);
begin
  if Clipboard.Provides('Biff8') then PasteFromBiff8(Row, Col) else
  if Clipboard.Provides('text/plain') then PasteFromText(Row, Col);
end;
{$ENDIF}
function TXLSFile.GetCellFormat(aRow, aCol: integer): integer;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=-1; exit; end;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1,aCol-1].XF;
end;

procedure TXLSFile.SetCellFormat(aRow, aCol: integer; const Value: integer);
var
  V: TXlsCellValue;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  V:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1, aCol-1];
  V.XF:=Value;
  FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Value[aRow-1, aCol-1]:=V;
end;

procedure TXLSFile.NewFile;
var
  P: Pointer;
  H: THandle;
  MemStream: TMemoryStream;
begin
  H:=FindResource(0, 'FLXEMPTYSHEET', RT_RCDATA);
  P:=LockResource(LoadResource(0, H));
  MemStream:=TMemoryStream.Create;
  try
    MemStream.Write(P^, SizeofResource(0, H));
    MemStream.Position:=0;
    OpenFileOrStream('', MemStream);
  finally
    FreeAndNil(MemStream);
  end; //finally
end;

procedure TXLSFile.DeleteHPageBreak(const Row: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].DeleteHPageBreak(Row);
end;

procedure TXLSFile.DeleteVPageBreak(const Col: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].DeleteVPageBreak(Col);
end;

procedure TXLSFile.InsertHPageBreak(const Row: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].InsertHPageBreak(Row);
end;

procedure TXLSFile.InsertVPageBreak(const Col: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].InsertVPageBreak(Col);
end;


function TXLSFile.HasHPageBreak(const Row: integer): boolean;
begin
  Result:=false;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].HasHPageBreak(Row); //Page break arrays are 1-based
end;

function TXLSFile.HasVPageBreak(const Col: integer): boolean;
begin
  Result:=false;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].HasVPageBreak(Col); //Page break arrays are 1-based
end;

function TXLSFile.GetMargins: TXlsMargins;
begin
  Result:=FWorkbook.Sheets[FActiveSheet-1].Margins;
end;

procedure TXLSFile.SetMargins(const Value: TXlsMargins);
begin
  FWorkbook.Sheets[FActiveSheet-1].Margins:=Value;
end;


function TXLSFile.GetPrintNumberOfHorizontalPages: word;
begin
  Result:=1;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].PrintNumberOfHorizontalPages;
end;

function TXLSFile.GetPrintNumberOfVerticalPages: word;
begin
  Result:=1;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].PrintNumberOfVerticalPages;
end;

function TXLSFile.GetPrintScale: integer;
begin
  Result:=100;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].PrintScale;
end;

function TXLSFile.GetPrintToFit: boolean;
begin
  Result:=false;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].PrintToFit;
end;

procedure TXLSFile.SetPrintNumberOfHorizontalPages(const Value: word);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].PrintNumberOfHorizontalPages:=Value;
end;

procedure TXLSFile.SetPrintNumberOfVerticalPages(const Value: word);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].PrintNumberOfVerticalPages:=Value;
end;

procedure TXLSFile.SetPrintScale(const Value: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].PrintScale:=Value;
end;

procedure TXLSFile.SetPrintToFit(const Value: boolean);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].PrintToFit:=Value;
end;

function TXLSFile.GetPageFooter: WideString;
begin
  Result:=FWorkbook.Sheets[FActiveSheet-1].PageFooter;
end;

function TXLSFile.GetPageHeader: WideString;
begin
  Result:=FWorkbook.Sheets[FActiveSheet-1].PageHeader;
end;

procedure TXLSFile.SetPageFooter(const Value: WideString);
begin
  FWorkbook.Sheets[FActiveSheet-1].PageFooter:=Value;
end;

procedure TXLSFile.SetPageHeader(const Value: WideString);
begin
  FWorkbook.Sheets[FActiveSheet-1].PageHeader:=Value;
end;

function TXLSFile.GetCellFormula(aRow, aCol: integer): widestring;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then begin; Result:=unassigned; exit; end;
  Result:=FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Formula[aRow-1,aCol-1];
end;

procedure TXLSFile.SetCellFormula(aRow, aCol: integer;
  const Value: widestring);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
    FWorkbook.WorkSheets[FActiveSheet-1].Cells.CellList.Formula[aRow-1, aCol-1]:=Value;
end;

procedure TXLSFile.AddImage(const Data: string; const DataType: TXlsImgTypes; 
  const Properties: TImageProperties;const Anchor: TFlxAnchorType);
var
  Props: TImageProperties;
begin
  Props:=Properties;
  dec(Props.Col1);
  dec(Props.Col2);
  dec(Props.Row1);
  dec(Props.Row2);

  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.Globals.DrawingGroup.EnsureDwgGroup;
  FWorkbook.WorkSheets[FActiveSheet-1].AddImage(Data, DataType, Props, Anchor);
end;

procedure TXLSFile.ClearImage(const Index: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  if (Index<0) or (Index>=FWorkbook.WorkSheets[ActiveSheet-1].DrawingCount) then
    raise exception.CreateFmt(ErrIndexOutBounds,[Index, 'ImageIndex', 0, FWorkbook.WorkSheets[ActiveSheet-1].DrawingCount]);
  FWorkbook.WorkSheets[FActiveSheet-1].ClearImage(Index);
end;

procedure TXLSFile.DeleteImage(const Index: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  if (Index<0) or (Index>=FWorkbook.WorkSheets[ActiveSheet-1].DrawingCount) then
    raise exception.CreateFmt(ErrIndexOutBounds,[Index, 'ImageIndex', 0, FWorkbook.WorkSheets[ActiveSheet-1].DrawingCount]);
  FWorkbook.WorkSheets[FActiveSheet-1].DeleteImage(Index);
end;

function TXLSFile.GetCellComment(Row, Col: integer): widestring;
var
  Index: integer;
begin
  Result:='';
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  if not (Row-1<FWorkbook.WorkSheets[ActiveSheet-1].Notes.Count) then exit;

  if FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1].Find(Col-1, Index) then
    Result:=FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1][Index].Text;
end;

function TXLSFile.GetCommentColumn(Row, aPos: integer): integer;
begin
  Result:=1;
  if not FWorkbook.IsWorkSheet(FActiveSheet-1)
  or not (Row-1<FWorkbook.WorkSheets[ActiveSheet-1].Notes.Count)
    then exit;

  Result:=FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1][aPos].Column+1;
end;

procedure TXLSFile.SetCellComment(Row, Col: integer;
  const Value: widestring; const Properties: TImageProperties);
var
  Index: integer;
  Found: boolean;
  Prop:TImageProperties;
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  Found:= (Row-1<FWorkbook.WorkSheets[ActiveSheet-1].Notes.Count) and
           FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1].Find(Col-1, Index);

  if Value='' then
    if found then FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1].Delete(Index) else
  else
    if Found then
      FWorkbook.WorkSheets[ActiveSheet-1].Notes[Row-1][Index].Text:= Value
    else
    begin
      Prop:=Properties;
      dec(Prop.Row1);dec(Prop.Row2);dec(Prop.Col1);dec(Prop.Col2);
      FWorkbook.WorkSheets[ActiveSheet-1].AddNewComment(Row-1, Col-1, Value, Prop);
    end;
end;

function TXLSFile.GetSheetZoom: integer;
begin
  //This doesn't have to be a worksheet
  Result:=FWorkbook.Sheets[FActiveSheet-1].SheetZoom;
end;

procedure TXLSFile.SetSheetZoom(const Value: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].SheetZoom:=Value;
end;

procedure TXLSFile.MergeCells(const FirstRow, FirstCol, LastRow, LastCol: integer);
begin
  if not FWorkbook.IsWorkSheet(FActiveSheet-1) then exit;
  FWorkbook.WorkSheets[FActiveSheet-1].MergeCells(FirstRow-1, FirstCol-1, LastRow-1, LastCol-1);
end;

procedure TXLSFile.ParseComments;
begin
  //Nothing
end;


end.

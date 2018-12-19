unit UXlsBaseRecords;

interface
uses Sysutils, Contnrs, Classes,
    {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants,{$IFEND}{$ENDIF} //Delphi 6 or above
     XlsMessages;

type
  TContinueRecord=class;

  TBaseRecord = class (TObject)
  public
    Id: word;
    Data: PArrayOfByte;
    DataSize: word;

    Continue: TContinueRecord;

    procedure SaveDataToStream(const Workbook: TStream; const aData: PArrayOfByte);
  protected
    function DoCopyTo: TBaseRecord; virtual;
  public
    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);virtual;
    destructor Destroy; override;
    procedure AddContinue(const aContinue: TContinueRecord);

    procedure SaveToStream(const Workbook: TStream); virtual;
    function CopyTo: TBaseRecord;  //this should be non-virtual
    function TotalSize: integer;virtual;
    function TotalSizeNoHeaders: integer;virtual;
  end;

  ClassOfTBaseRecord= Class of TBaseRecord;

  TContinueRecord=class(TBaseRecord)
  end;

  TIgnoreRecord = class (TBaseRecord)
    function TotalSize: integer; override;
    procedure SaveToStream(const Workbook: TStream); override;
  end;

  TSubListRecord = class (TBaseRecord)  //This is a "virtual" record used to save sublists to stream
  private
    FSubList: TObjectList;
  protected
    function DoCopyTo: TBaseRecord; override;

  public
    constructor  CreateAndAssign(const aSubList: TObjectList);
    function TotalSize: integer; override;
    procedure SaveToStream(const Workbook: TStream); override;
  end;

  TBaseRowColRecord = class(TBaseRecord)
  private
    function GetColumn: word;
    function GetRow: word;
    procedure SetColumn( Value: word );
    procedure SetRow( Value: word );
  public
    property Row: word read GetRow write SetRow;
    property Column: word read GetColumn write SetColumn;

    procedure ArrangeInsert(const aPos, aCount:integer; const SheetInfo: TSheetInfo);virtual;
    procedure ArrangeCopy(const NewRow: Word);virtual;
  public
    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
  end;

  TCellRecord=class(TBaseRowColRecord)
  private
    function GetXF: word;
    procedure SetXF(const Value: word);
  protected
    function GetValue: Variant; virtual;
    procedure SetValue(const Value: Variant); virtual;
  public
    property XF: word read GetXF write SetXF;
    property Value:Variant read GetValue write SetValue;
    constructor CreateFromData(const aId, aDataSize, aRow, aCol, aXF: word);
  end;

  TRowRecord=class(TBaseRowColRecord)
  private
    function GetHeight: word;
    function GetMaxCol: word;
    function GetMinCol: word;
    function GetXF: word;
    procedure SetHeight(const Value: word);
    procedure SetMaxCol(const Value: word);
    procedure SetMinCol(const Value: word);
    procedure SetXF(const Value: word);
  public
    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
    constructor CreateStandard(const Row: word);
    function GetRow: Word;

    property MaxCol: word read GetMaxCol write SetMaxCol;
    property MinCol: word read GetMinCol write SetMinCol;
    property Height: word read GetHeight write SetHeight;
    property XF: word read GetXF write SetXF;
    function IsFormatted: boolean;
    function IsModified: boolean;

    procedure ManualHeight;
    procedure AutoHeight;
    function IsAutoHeight: boolean;
    procedure SaveRangeToStream(const DataStream: TStream; const aMinCol, aMaxCol: integer);
  end;

  TDimensionsRec=packed record
    FirstRow, LastRow: LongWord;
    FirstCol, LastCol: Word;
    Extra: word;
  end;
  PDimensionsRec=^TDimensionsRec;
  
  TDimensionsRecord=class(TBaseRecord)
    function Dim: PDimensionsRec;
  end;

  TStringRecord=class(TBaseRecord)
  public
    procedure SaveToStream(const Workbook: TStream); override;
    function TotalSize: integer; override;
    function Value: widestring;
  end;

  TWindow1Record=class(TBaseRecord)
  private
    function GetActiveSheet: integer;
    procedure SetActiveSheet(const Value: integer);
  public
    property ActiveSheet: integer read GetActiveSheet write SetActiveSheet;
  end;

  TWindow2Record=class(TBaseRecord)
  private
    function GetSelected: boolean;
    procedure SetSelected(const Value: boolean);
    function GetShowGridLines: boolean;
    procedure SetShowGridLines(const Value: boolean);
    procedure SetSheetZoom(const Value: integer);
    function GetSheetZoom: integer;
  protected
    function DoCopyTo: TBaseRecord; override;
  public
    property Selected: boolean read GetSelected write SetSelected;
    property ShowGridLines: boolean read GetShowGridLines write SetShowGridLines;
    property SheetZoom: integer read GetSheetZoom write SetSheetZoom;
  end;

  TSCLRecord=class(TBaseRecord)
  private
    function GetZoom: integer;
    procedure SetZoom(const Value: integer);
  public
    constructor CreateFromData(const aZoom: integer);
    property Zoom: integer read GetZoom write SetZoom;
  end;

  TDefColWidthRecord = class(TBaseRecord)
  public
    function Width: Word;
  end;

  TDefRowHeightRecord = class(TBaseRecord)
  public
    function Height: Word;
  end;

  TPageHeaderFooterRecord = class(TBaseRecord)
  private
    function GetText: WideString;
    procedure SetText(const Value: WideString);
  public
    property Text: WideString read GetText write SetText;
  end;

  TPageHeaderRecord = class(TPageHeaderFooterRecord)
  end;

  TPageFooterRecord = class(TPageHeaderFooterRecord)
  end;

  TPrintGridLinesRecord = class(TPageHeaderFooterRecord)
  private
    function GetValue: boolean;
    procedure SetValue(const Value: boolean);
  public
    property Value: boolean read GetValue write SetValue;
  end;


  TMarginRecord=class(TBaseRecord)
  private
    function GetValue: double;
    procedure SetValue(const Value: double);
  public
    property Value: double read GetValue write SetValue;
  end;

  TSetupRec=packed record
    PaperSize: word;
    Scale: word;
    PageStart: word;
    FitWidth: word;
    FitHeight: word;
    GrBit: word;
    Resolution: word;
    VResolution: word;
    HeaderMargin: double;
    FooterMargin: double;
    Copies: word;
  end;
  PSetupRec=^TSetupRec;

  TSetupRecord=class(TBaseRecord)
  private
    function GetValue: TSetupRec;
    procedure SetValue(const Value: TSetupRec);
    function GetScale: word;
    procedure SetScale(const Value: word);
    function GetFitHeight: word;
    function GetFitWidth: word;
    procedure SetFitHeight(const Value: word);
    procedure SetFitWidth(const Value: word);
    function GetFooterMargin: extended;
    function GetHeaderMargin: extended;
    procedure SetFooterMargin(const Value: extended);
    procedure SetHeaderMargin(const Value: extended);
  public
    property Value: TSetupRec read GetValue write SetValue;
    property Scale: word read GetScale write SetScale;
    property FitWidth: word read GetFitWidth write SetFitWidth;
    property FitHeight: word read GetFitHeight write SetFitHeight;

    property HeaderMargin: extended read GetHeaderMargin write SetHeaderMargin;
    property FooterMargin: extended read GetFooterMargin write SetFooterMargin;
  end;

  TWsBoolRecord=class(TBaseRecord)
  private
    function GetValue: word;
    procedure SetValue(const Value: word);
    function GetFitToPage: boolean;
    procedure SetFitToPage(const Value: boolean);
  public
    property Value: word read GetValue write SetValue;
    property FitToPage: boolean read GetFitToPage write SetFitToPage;
  end;


////////////////////////////// Utility functions
  function LoadRecord(const DataStream: TStream; const RecordHeader: TRecordHeader): TBaseRecord;
  procedure ReadMem(var aRecord: TBaseRecord; var aPos: integer; const aSize: integer; const pResult: pointer);
  procedure ReadStr(var aRecord: TBaseRecord; var aPos: integer; var ShortData: string; var WideData: WideString; var OptionFlags, ActualOptionFlags: byte; var DestPos: integer; const StrLen: integer );

implementation
uses UXlsFormula, UXlsOtherRecords, UXlsSST, UXlsReferences, UXlsCondFmt, UXlsChart, UXlsEscher,
     UXlsNotes, UXlsCellRecords, UXlsPageBreaks, UXlsStrings, UXlsColInfo, UXlsXF,
     UXlsBaseRecordLists, UXlsPalette;

////////////////////////////// Utility functions

procedure ReadMem(var aRecord: TBaseRecord; var aPos: integer; const aSize: integer; const pResult: pointer);
//Read memory taking in count "Continue" Records
var
  l: integer;
begin
  l:= aRecord.DataSize-aPos;

  if l<0 then raise Exception.Create(ErrReadingRecord);
  if (l=0) and (aSize>0) then
  begin
    aPos:=0;
    aRecord:=aRecord.Continue;
    if aRecord=nil then raise Exception.Create(ErrReadingRecord);
  end;

  l:= aRecord.DataSize-aPos;

  if aSize<=l then
  begin
    if pResult<>nil then Move(aRecord.Data^[aPos], pResult^, aSize);
    inc(aPos, aSize);
  end else
  begin
    ReadMem(aRecord, aPos, l, pResult);
    if pResult<>nil then ReadMem(aRecord, aPos, aSize-l, PCHAR(pResult)+ l)
    else ReadMem(aRecord, aPos, aSize-l, nil);
  end
end;

procedure ReadStr(var aRecord: TBaseRecord; var aPos: integer; var ShortData: string; var WideData: WideString; var OptionFlags, ActualOptionFlags: byte; var DestPos: integer; const StrLen: integer );
//Read a string taking in count "Continue" Records
var
  l,i: integer;
  pResult: pointer;
  aSize, CharSize: integer;
begin
  l:= aRecord.DataSize-aPos;

  if l<0 then raise Exception.Create(ErrReadingRecord);
  if (l=0) and (StrLen>0) then
    if DestPos=0 then  //we are beginning the record
    begin
      aPos:=0;
      if aRecord.Continue=nil then raise Exception.Create(ErrReadingRecord);
      aRecord:=aRecord.Continue;
    end else
    begin       //We are in the middle of a string
      aPos:=1;
      if aRecord.Continue=nil then raise Exception.Create(ErrReadingRecord);
      aRecord:=aRecord.Continue;
      ActualOptionFlags:=aRecord.Data[0];
      if (ActualOptionFlags=1) and ((OptionFlags and 1)=0 ) then
      begin
        WideData:=StringToWideStringNoCodePage(ShortData);
        OptionFlags:= OptionFlags or 1;
      end;
    end;

  l:= aRecord.DataSize-aPos;

  if (ActualOptionFlags and 1)=0 then
  begin
    aSize:= StrLen-DestPos;
    pResult:= @ShortData[DestPos+1];
    CharSize:=1;
  end else
  begin
    aSize:= (StrLen-DestPos)*2;
    pResult:= @WideData[DestPos+1];
    CharSize:=2;
  end;

  if aSize<=l then
  begin
    if (ActualOptionFlags and 1=0) and (OptionFlags and 1=1) then
      //We have to move result to widedata
      for i:=0 to aSize div CharSize -1 do WideData[DestPos+1+i]:=WideChar(aRecord.Data^[aPos+i])
      //We are either reading widedata or shortdata
      else Move(aRecord.Data^[aPos], pResult^, aSize);

    inc(aPos, aSize);
    inc(DestPos, aSize div CharSize);
  end else
  begin
    if (ActualOptionFlags and 1=0) and (OptionFlags and 1=1) then
      //We have to move result to widedata
      for i:=0 to l div CharSize -1 do WideData[DestPos+1+i]:=WideChar(aRecord.Data^[aPos+i])
      //We are either reading widedata or shortdata
      else  Move(aRecord.Data^[aPos], pResult^, l);
    inc(aPos, l);
    inc(DestPos, l div CharSize);
    ReadStr(aRecord, aPos, ShortData, WideData, OptionFlags, ActualOptionFlags, DestPos ,StrLen);
  end
end;

function LoadRecord(const DataStream: TStream; const RecordHeader: TRecordHeader): TBaseRecord;
var
  Data: PArrayOfByte;
  R: TBaseRecord;
  NextRecordHeader: TRecordHeader;
begin
  GetMem(Data, RecordHeader.Size);
  try
    if DataStream.Read(Data^, RecordHeader.Size) <> RecordHeader.Size then
      raise Exception.Create(ErrExcelInvalid);
  except
    FreeMem(Data);
    raise;
  end; //except

  //From here, if there is an exception, the mem will be freed by the object
  case RecordHeader.Id of
    xlr_BOF         : R:= TBOFRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_EOF         : R:= TEOFRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_FORMULA     : R:= TFormulaRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_SHRFMLA     : R:= TShrFmlaRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_OBJ         : R:= TObjRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_MSODRAWING  : R:= TDrawingRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_MSODRAWINGGROUP
                    : R:= TDrawingGroupRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_TXO         : R:= TTXORecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_NOTE        : R:= TNoteRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_RECALCID,   //So the workbook gets recalculated
    xlr_EXTSST,     // We will have to generate this again
    xlr_DBCELL,     //To find rows in blocks... we need to calculate it again
    xlr_INDEX,      //Same as DBCELL
    xlr_MSODRAWINGSELECTION   // Object selection. We do not need to select any drawing
                    : R:= TIgnoreRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_DIMENSIONS  //Used range of a sheet
                    : R:= TDimensionsRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_SST         : R:= TSSTRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_BoundSheet  : R:= TBoundSheetRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_Array       : R:= TArrayRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Blank       : R:= TBlankRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_BoolErr     : R:= TBoolErrRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Number      : R:= TNumberRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_MulBlank    : R:= TMulBlankRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_MulRK       : R:= TMulRKRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_RK          : R:= TRKRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_STRING      : R:= TStringRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);//String record saves the result of a formula

    xlr_XF          : R:= TXFRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_FONT        : R:= TFontRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_FORMAT      : R:= TFormatRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Palette     : R:= TPaletteRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Style       : R:= TStyleRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_LabelSST    : R:= TLabelSSTRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Label       : R:= TLabelRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Row         : R:= TRowRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_NAME        : R:= TNameRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_TABLE       : R:= TTableRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_CELLMERGING : R:= TCellMergingRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_CONDFMT     : R:= TCondFmtRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_CF          : R:= TCFRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_DVAL        : R:= TDValRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Continue    : R:= TContinueRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_FOOTER      : R:= TPageFooterRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_HEADER      : R:= TPageHeaderRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_PRINTGRIDLINES : R:= TPrintGridLinesRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_LEFTMARGIN,
    xlr_RIGHTMARGIN,
    xlr_TOPMARGIN,
    xlr_BOTTOMMARGIN: R:= TMarginRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_SETUP       : R:= TSetupRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_WSBOOL      : R:= TWsBoolRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_XCT,        // Cached values of a external workbook... not supported yet
    xlr_CRN         // Cached values also
                    : R:=TIgnoreRecord.Create(RecordHeader.Id, Data, RecordHeader.Size); //raise Exception.Create (ErrExtRefsNotSupported);
    xlr_SUPBOOK     : R:= TSupBookRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_EXTERNSHEET : R:= TExternSheetRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_ChartAI     : R:= TChartAIRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Window1     : R:= TWindow1Record.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_Window2     : R:= TWindow2Record.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_SCL         : R:= TSCLRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_HORIZONTALPAGEBREAKS: R:= THPageBreakRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_VERTICALPAGEBREAKS  : R:= TVPageBreakRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_COLINFO     : R:= TColInfoRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_DEFCOLWIDTH : R:= TDefColWidthRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
    xlr_DEFAULTROWHEIGHT: R:= TDefRowHeightRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);

    xlr_FILEPASS: raise Exception.Create(ErrFileIsPasswordProtected);

    else              R:= TBaseRecord.Create(RecordHeader.Id, Data, RecordHeader.Size);
  end; //case

  //Peek at the next record...
  if DataStream.Read(NextRecordHeader, SizeOf(NextRecordHeader))= SizeOf(NextRecordHeader) then
  begin
    if NextRecordHeader.Id = xlr_Continue then R.AddContinue(LoadRecord(DataStream, NextRecordHeader) as TContinueRecord)
    else if NextRecordHeader.Id=xlr_Table then
      if (R is TFormulaRecord) then
      begin
        (R as TFormulaRecord).TableRecord:=LoadRecord(DataStream, NextRecordHeader) as TTableRecord;
      end
      else Exception.Create(ErrExcelInvalid)
    else if NextRecordHeader.Id=xlr_Array then
      if (R is TFormulaRecord) then
      begin
        (R as TFormulaRecord).ArrayRecord:=LoadRecord(DataStream, NextRecordHeader) as TArrayRecord;
      end
      else Exception.Create(ErrExcelInvalid)
    else
    begin
      if NextRecordHeader.Id = xlr_String then
      begin
        if not (R is TFormulaRecord) and not (R is TShrFmlaRecord) and not (R is TArrayRecord) and not (R is TTableRecord) then raise Exception.Create(ErrExcelInvalid);
      end;
      DataStream.Seek(-SizeOf(NextRecordHeader),soFromCurrent);
    end;
  end;

  Result:=R;
end;

{ TBaseRecord }

procedure TBaseRecord.AddContinue(const aContinue: TContinueRecord);
begin
  if Continue<>nil then raise Exception.Create(ErrInvalidContinue);
  Continue:=aContinue;
end;

function TBaseRecord.CopyTo: TBaseRecord;
begin
  if Self=nil then Result:= nil   //for this to work, this cant be a virtual method
  else Result:=DoCopyTo;
end;

constructor TBaseRecord.Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);
begin
  inherited Create;
  Id := aId;
  Data := aData;
  DataSize := aDataSize;
end;

destructor TBaseRecord.Destroy;
begin
  if Data<>nil then FreeMem(Data);
  FreeAndNil(Continue);
  inherited;
end;

function TBaseRecord.DoCopyTo: TBaseRecord;
var
  NewData: PArrayOfByte;
begin
  GetMem(NewData, DataSize);
  try
    Move(Data^, NewData^, DataSize);
    Result:= ClassOfTBaseRecord(ClassType).Create(Id, NewData, DataSize);
  except
    FreeMem(NewData);
    raise;
  end;
  if Continue<>nil then Result.Continue:= Continue.CopyTo as TContinueRecord;
end;

procedure TBaseRecord.SaveDataToStream(const Workbook: TStream;
  const aData: PArrayOfByte);
begin
  if Workbook.Write(Id, Sizeof(Id)) <> Sizeof(Id) then raise Exception.Create(ErrCantWrite);
  if Workbook.Write(DataSize, Sizeof(DataSize)) <> Sizeof(DataSize) then raise Exception.Create(ErrCantWrite);
  if DataSize > 0 then
    if Workbook.Write(aData^, DataSize) <> DataSize then
      raise Exception.Create(ErrCantWrite);
end;

procedure TBaseRecord.SaveToStream(const Workbook: TStream);
begin
  SaveDataToStream(Workbook, Data);
  if Continue<>nil then Continue.SaveToStream(Workbook);
end;

function TBaseRecord.TotalSize: integer;
begin
  Result:=SizeOf(TRecordHeader)+ DataSize;
  if Continue<>nil then Result:=Result+Continue.TotalSize;
end;

function TBaseRecord.TotalSizeNoHeaders: integer;
begin
  Result:=DataSize;
  if Continue<>nil then Result:=Result+Continue.TotalSizeNoHeaders;
end;

{ TBaseRowColRecord }

procedure TBaseRowColRecord.ArrangeInsert(const aPos, aCount:integer; const SheetInfo: TSheetInfo);
begin
  if DataSize<4 then raise Exception.CreateFmt(ErrWrongExcelRecord,[Id]);
  if (SheetInfo.InsSheet<0) or (SheetInfo.FormulaSheet<> SheetInfo.InsSheet) then exit;
  if aPos<= Row then IncWord(Data, 0, aCount, Max_Rows);  //row;
end;

constructor TBaseRowColRecord.Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);
begin
  inherited;
  if DataSize<4 then raise Exception.CreateFmt(ErrWrongExcelRecord,[Id]);
end;

procedure TBaseRowColRecord.ArrangeCopy(const NewRow: Word);
begin
  if DataSize<4 then raise Exception.CreateFmt(ErrWrongExcelRecord,[Id]);
  SetWord(Data, 0, NewRow);  //row;
end;

function TBaseRowColRecord.GetColumn: word;
begin
  GetColumn:=GetWord(Data,2);
end;

function TBaseRowColRecord.GetRow: word;
begin
  GetRow:=GetWord(Data,0);
end;

procedure TBaseRowColRecord.SetColumn(Value: word);
begin
  SetWord(Data,2,Value);
end;

procedure TBaseRowColRecord.SetRow(Value: word);
begin
  SetWord(Data,0,Value);
end;

{ TIgnoreRecord }

procedure TIgnoreRecord.SaveToStream(const Workbook: TStream);
begin
  //nothing
end;

function TIgnoreRecord.TotalSize: integer;
begin
  Result:=0;
end;

{ TStringRecord }
//We won't write out this record

procedure TStringRecord.SaveToStream(const Workbook: TStream);
begin
  //Nothing.
end;

function TStringRecord.TotalSize: integer;
begin
  Result:=0;
end;

function TStringRecord.Value: widestring;
var
  xs: TExcelString;
  Myself: TBaseRecord;
  Ofs: integer;
begin
  Myself:=Self;Ofs:=0;
  xs:=TExcelString.Create(2, Myself, Ofs);
  try
    Result:=Xs.Value;
  finally
    freeAndNil(xs);
  end;
end;


{ TRowRecord }

constructor TRowRecord.Create(const aId: word; const aData: PArrayOfByte;
  const aDataSize: integer);
begin
  inherited;
  //Set irwMac=0
  SetWord(Data, 8, 0);
end;

constructor TRowRecord.CreateStandard(const Row: word);
var
  MyData: PArrayOfByte;
begin
  GetMem(myData, 16);
  FillChar(myData^,16, 0);
  SetWord(myData, 0, Row);
  SetWord(myData, 6, $FF);
  myData[13]:=1;
  myData[14]:=$0F; //Default format.
  inherited Create(xlr_ROW, myData, 16);
end;

function TRowRecord.GetHeight: word;
begin
  Result:=GetWord(Data, 6);
end;

function TRowRecord.GetMaxCol: word;
begin
  Result:=GetWord(Data, 4);
end;

function TRowRecord.GetMinCol: word;
begin
  Result:=GetWord(Data, 2);
end;

function TRowRecord.GetXF: word;
begin
  if IsFormatted then Result:=GetWord(Data, 14) and $FFF else Result:=15;
end;

function TRowRecord.GetRow: Word;
begin
  Result:= GetWord(Data, 0);
end;

procedure TRowRecord.SetHeight(const Value: word);
begin
  SetWord( Data, 6, Value);
end;

procedure TRowRecord.SetMaxCol(const Value: word);
begin
  SetWord( Data, 4, Value);
end;

procedure TRowRecord.SetMinCol(const Value: word);
begin
  SetWord( Data, 2, Value);
end;

procedure TRowRecord.ManualHeight;
begin
  Data[12]:= Data[12] or $40;
end;

procedure TRowRecord.AutoHeight;
begin
  Data[12]:= Data[12] and not $40;
end;

function TRowRecord.IsAutoHeight: boolean;
begin
  Result:=  not (Data[12] and $40 = $40);
end;

procedure TRowRecord.SetXF(const Value: word);
begin
  Data[12]:= Data[12] or $80;
  Data[13]:= Data[13] or $01;
  SetWord(Data, 14, Value);
end;

procedure TRowRecord.SaveRangeToStream(const DataStream: TStream; const aMinCol, aMaxCol: integer);
var
  sMinCol, sMaxCol: integer;
begin
  sMinCol:=MinCol;
  sMaxCol:=MaxCol;
  try
    if sMinCol<aMinCol then MinCol:=aMinCol;
    if sMaxCol>aMaxCol+1 then MaxCol:=aMaxCol+1;
    inherited SaveToStream(DataStream);
  finally
    MinCol:=sMinCol;
    MaxCol:=sMaxCol;
  end; //Finally

end;

function TRowRecord.IsFormatted: boolean;
begin
  Result:=Data[12] and $80= $80;
end;

function TRowRecord.IsModified: boolean;
begin
  Result:=(Data[12]<>0) or (Data[13]<>1);
end;

{ TCellRecord }

constructor TCellRecord.CreateFromData(const aId, aDataSize, aRow, aCol, aXF: word);
begin
  GetMem(Data, aDataSize);
  Create(aId, Data, aDataSize);
  Row:=aRow;
  Column:=aCol;
  XF:=aXF;
end;

function TCellRecord.GetValue: Variant;
begin
  Result:=unassigned;
end;

function TCellRecord.GetXF: word;
begin
  Result:= GetWord(Data, 4);
end;

procedure TCellRecord.SetValue(const Value: Variant);
begin
  //Nothing
end;

procedure TCellRecord.SetXF(const Value: word);
begin
  SetWord(Data, 4, Value);
end;

{ TWindow1Record }

function TWindow1Record.GetActiveSheet: integer;
begin
  Result:= GetWord(Data, 10);
end;

procedure TWindow1Record.SetActiveSheet(const Value: integer);
begin
  SetWord(Data, 10, Value);
  SetWord(Data, 12, 0);
  SetWord(Data, 14, 1);
end;

{ TWindow2Record }


function TWindow2Record.DoCopyTo: TBaseRecord;
begin
  Result:= inherited DoCopyTo;
  (Result as TWindow2Record).Selected:=False;
end;

function TWindow2Record.GetSelected: boolean;
begin
  Result:=GetWord(Data, 0) and (1 shl 9) = (1 shl 9);
end;

function TWindow2Record.GetSheetZoom: integer;
begin
  Result:=GetWord(Data, 12);
end;

function TWindow2Record.GetShowGridLines: boolean;
begin
  Result:=GetWord(Data, 0) and $2 = $2;
end;

procedure TWindow2Record.SetSelected(const Value: boolean);
begin
  if Value then SetWord(Data, 0, GetWord(Data, 0) or (1 shl 9)) //Selected=true
  else SetWord(Data, 0, GetWord(Data, 0) and not (1 shl 9)); //Selected=false
end;

procedure TWindow2Record.SetSheetZoom(const Value: integer);
begin
  if Value<10 then SetWord(Data, 12, 10) else
    if Value>400 then SetWord(Data, 12, 400)else
    SetWord(Data, 12, Value);
end;

procedure TWindow2Record.SetShowGridLines(const Value: boolean);
begin
  if Value then SetWord(Data, 0, GetWord(Data, 0) or $2) //GridLines=true
  else SetWord(Data, 0, GetWord(Data, 0) and not $2); //GridLines=false
end;

{ TDefColWidthRecord }

function TDefColWidthRecord.Width: Word;
begin
  Result:= GetWord(Data, 0);
end;

{ TDefRowHeightRecord }

function TDefRowHeightRecord.Height: Word;
begin
  Result:= GetWord(Data, 2);
end;

{ TSubListRecord }

constructor TSubListRecord.CreateAndAssign(const aSubList: TObjectList);
begin
  inherited Create(0,nil,0);
  FSubList:=aSubList;
end;

function TSubListRecord.DoCopyTo: TBaseRecord;
begin
  Assert(true, 'Sublist record can''t be copied'); //To copy, it should change the reference to FList
  Result:=inherited DoCopyTo;
end;

procedure TSubListRecord.SaveToStream(const Workbook: TStream);
begin
  (FSubList as TBaseRecordList).SaveToStream(Workbook);
end;

function TSubListRecord.TotalSize: integer;
begin
  Result:=0;
end;

{ TDimensionsRecord }

function TDimensionsRecord.Dim: PDimensionsRec;
begin
  Result:=PDimensionsRec(Data);
end;

{ TPageHeaderFooterRecord }

function TPageHeaderFooterRecord.GetText: WideString;
var
  Xs: TExcelString;
  MySelf: TBaseRecord;
  Ofs: integer;
begin
  if Data=nil then
  begin
    Result:='';
    exit;
  end;
  MySelf:=Self;
  Ofs:= 0;
  Xs:=TExcelString.Create(2, MySelf, Ofs );
  try
    Result:=Xs.Value;
  finally
    FreeAndNil(Xs);
  end; //finally
end;

procedure TPageHeaderFooterRecord.SetText(const Value: WideString);
  //Important: This method changes the size of the record without notifying it's parent list
  //It's necessary to adapt the Totalsize in the parent list.
var
  Xs: TExcelString;
  NewDataSize: integer;
begin
  Xs:=TExcelString.Create(2, Value);
  try
    NewDataSize:=Xs.TotalSize;
    ReallocMem( Data, NewDataSize);
    DataSize:=NewDataSize;
    Xs.CopyToPtr( Data, 0 );
  finally
    FreeAndNil(Xs);
  end;  //finally
end;

{ TPrintGridLinesRecord }

function TPrintGridLinesRecord.GetValue: boolean;
begin
  Result:=GetWord(Data,0)=1;
end;

procedure TPrintGridLinesRecord.SetValue(const Value: boolean);
begin
  if Value then SetWord(Data,0,1) else SetWord(Data,0,0) 
end;

{ TMarginRecord }

function TMarginRecord.GetValue: double;
begin
  move(Data[0], Result, SizeOf(Result));
end;

procedure TMarginRecord.SetValue(const Value: double);
begin
  Assert(SizeOf(Value)=DataSize,'Error in Margin Record');
  move(Value,Data[0],sizeof(Value));
end;

{ TSetupRecord }

function TSetupRecord.GetFitHeight: word;
begin
  Result:=PSetupRec(Data).FitHeight;
end;

function TSetupRecord.GetFitWidth: word;
begin
  Result:=PSetupRec(Data).FitWidth;
end;

function TSetupRecord.GetFooterMargin: extended;
begin
  Result:=PSetupRec(Data).FooterMargin;
end;

function TSetupRecord.GetHeaderMargin: extended;
begin
  Result:=PSetupRec(Data).HeaderMargin;
end;

function TSetupRecord.GetScale: word;
begin
  if (PSetupRec(Data).GrBit and $4)=$4 then Result:=100 else
  Result:=PSetupRec(Data).Scale;
end;

function TSetupRecord.GetValue: TSetupRec;
begin
  move(Data[0], Result, SizeOf(Result));
end;

procedure TSetupRecord.SetFitHeight(const Value: word);
begin
  PSetupRec(Data).FitHeight:=Value;
end;

procedure TSetupRecord.SetFitWidth(const Value: word);
begin
  PSetupRec(Data).FitWidth:=Value;
end;

procedure TSetupRecord.SetFooterMargin(const Value: extended);
begin
  PSetupRec(Data).FooterMargin:=Value;
end;

procedure TSetupRecord.SetHeaderMargin(const Value: extended);
begin
  PSetupRec(Data).HeaderMargin:=Value;
end;

procedure TSetupRecord.SetScale(const Value: word);
begin
  PSetupRec(Data).GrBit:=PSetupRec(Data).GrBit or $4;
  PSetupRec(Data).Scale:=Value;
end;

procedure TSetupRecord.SetValue(const Value: TSetupRec);
begin
  Assert(SizeOf(Value)=DataSize,'Error in Setup Record');
  move(Value, Data[0], SizeOf(Value));
end;

{ TWsBoolRecord }

function TWsBoolRecord.GetFitToPage: boolean;
begin
  Result:= Data[1] and 1=1;
end;

function TWsBoolRecord.GetValue: word;
begin
  Result:=GetWord(Data,0);
end;

procedure TWsBoolRecord.SetFitToPage(const Value: boolean);
begin
  if Value then Data[1]:=Data[1] or 1 else Data[1]:=Data[1] and $FF-1;
end;

procedure TWsBoolRecord.SetValue(const Value: word);
begin
  SetWord(Data, 0, Value);
end;

{ TSCLRecord }

constructor TSCLRecord.CreateFromData(const aZoom: integer);
begin
  GetMem(Data, 4);
  Create(xlr_SCL, Data, 4);
  SetZoom(aZoom);
end;

function TSCLRecord.GetZoom: integer;
begin
  if GetWord(Data,2)= 0 then Result:=100 else
    Result:=Round(100*GetWord(Data,0)/GetWord(Data,2));
end;

procedure TSCLRecord.SetZoom(const Value: integer);
var
  v: integer;
begin
  if Value<10 then v:=10 else if Value>400 then v:=400 else v:=Value;
  SetWord(Data,0,v);
  SetWord(Data,2,100);
end;

end.

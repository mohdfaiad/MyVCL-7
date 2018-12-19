unit UXlsColInfo;

interface
uses Classes, SysUtils, UXlsBaseRecords, UXlsBaseList, XlsMessages, UFlxMessages;

type
  TColInfoDat=packed record
    FirstColumn: word;
    LastColumn: word;
    Width: word;
    XF: word;
    Options: word;
    Reserved: Word;
  end;
  PColInfoDat=^TColInfoDat;

  TColInfo=class
  public
    Column: word;
    Width: Word;
    XF: Word;
    Options: Word;

    constructor Create (const aColumn, aWidth, aXF, aOptions: word);

    function IsEqual(const aColInfo: TColInfo): boolean;
  end;

  TColInfoRecord=class(TBaseRecord)
    function D: TColInfoDat;
  end;

  TColInfoList= class(TBaseList)  //Items are TColInfo
  {$INCLUDE TColInfoListHdr.inc}
  private
    procedure SaveOneRecord(const i, k: integer; const DataStream: TStream);
    procedure SaveToStreamExt(const DataStream: TStream; const FirstRecord, RecordCount: integer);
    procedure CalcIncludedRangeRecords(const CellRange: TXlsCellRange; var FirstRecord, RecordCount: integer);
    function TotalSizeExt(const FirstRecord, RecordCount:integer): int64;
  public
    procedure CopyFrom(const aColInfoList: TColInfoList);

    procedure AddRecord(const R: TColInfoRecord);
    procedure SaveToStream(const DataStream: TStream);
    procedure SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
    function TotalSize: int64;
    function TotalRangeSize(const CellRange: TXlsCellRange): int64;
  end;

implementation
{$INCLUDE TColInfoListImp.inc}

{ TColInfoList }

procedure TColInfoList.AddRecord(const R: TColInfoRecord);
var
  i: integer;
begin
  for i:=R.D.FirstColumn to R.D.LastColumn do
    Add(TColInfo.Create(i, R.D.Width, R.D.XF, R.D.Options ));
  R.Free;
end;

procedure TColInfoList.CalcIncludedRangeRecords(
  const CellRange: TXlsCellRange; var FirstRecord, RecordCount: integer);
var
  LastRecord, i: integer;
begin
  Sort; //just in case...
  FirstRecord:=-1;
  LastRecord:=-1;
  for i:=0 to Count-1 do
  begin
    if (FirstRecord<0) and (Items[i].Column>=CellRange.Left) then FirstRecord:=i;
    if Items[i].Column<=CellRange.Right then LastRecord:=i;
  end;
  if (FirstRecord>=0) and (LastRecord>=0) and (FirstRecord<=LastRecord) then
    RecordCount:=LastRecord-FirstRecord+1
  else
  begin
    FirstRecord:=0;
    RecordCount:=0;
  end;
end;

procedure TColInfoList.CopyFrom(const aColInfoList: TColInfoList);
var
  i: integer;
begin
  Clear;
  for i:=0 to aColInfoList.Count-1 do Add(TColInfo.Create(aColInfoList[i].Column, aColInfoList[i].Width, aColInfoList[i].XF, aColInfoList[i].Options));
end;

procedure TColInfoList.SaveOneRecord(const i,k: integer; const DataStream: TStream);
var
  RecordHeader: TRecordHeader;
  Info: TColInfoDat;
begin
  RecordHeader.Id:= xlr_COLINFO;
  RecordHeader.Size:=SizeOf(TColInfoDat);
  DataStream.Write(RecordHeader, SizeOf(RecordHeader));
  Info.FirstColumn:=Items[i].Column;
  Info.LastColumn:=Items[k].Column;
  Info.Width:=Items[i].Width;
  Info.XF:=Items[i].XF;
  Info.Options:=Items[i].Options;
  Info.Reserved:=0;
  DataStream.Write(Info, SizeOf(Info));
end;

procedure TColInfoList.SaveToStreamExt(const DataStream: TStream; const FirstRecord, RecordCount: integer);
var
  i,k: integer;
begin
  //Mix similar columns
  Sort;
  i:=FirstRecord;
  while i<RecordCount do
  begin
    k:=i+1;
    while (k<FirstRecord+RecordCount) and Items[i].IsEqual(Items[k]) do inc(k);
    SaveOneRecord(i, k-1,DataStream);
    i:=k;
  end;
end;

procedure TColInfoList.SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
var
  FirstRecord, RecordCount: integer;
begin
  CalcIncludedRangeRecords(CellRange, FirstRecord, RecordCount);
  SaveToStreamExt(DataStream, FirstRecord, RecordCount);
end;

procedure TColInfoList.SaveToStream(const DataStream: TStream);
begin
  SaveToStreamExt(DataStream, 0, Count);
end;

function TColInfoList.TotalSize: int64;
var
  i,k: integer;
begin
  Sort; //just in case

  Result:=0;
  //Mix similar columns
  i:=0;
  while i<Count do
  begin
    k:=i+1;
    while (k<Count) and Items[i].IsEqual(Items[k]) do inc(k);
    inc(Result, SizeOf(TRecordHeader)+SizeOf(TColInfoDat));
    i:=k;
  end;
end;

function TColInfoList.TotalSizeExt(const FirstRecord, RecordCount: integer): int64;
var
  i,k: integer;
begin
  Sort; //just in case
  Result:=0;
  //Mix similar columns
  i:=FirstRecord;
  while i<FirstRecord+RecordCount do
  begin
    k:=i+1;
    while (k<Count) and Items[i].IsEqual(Items[k]) do inc(k);
    inc(Result, SizeOf(TRecordHeader)+SizeOf(TColInfoDat));
    i:=k;
  end;
end;

function TColInfoList.TotalRangeSize(const CellRange: TXlsCellRange): int64;
var
  FirstRecord, RecordCount: integer;
begin
  CalcIncludedRangeRecords(CellRange, FirstRecord, RecordCount);
  Result:=TotalSizeExt(FirstRecord, RecordCount);
end;

{ TColInfoRecord }

function TColInfoRecord.D: TColInfoDat;
begin
  Result:= PColInfoDat(Data)^;
end;

{ TColInfo }

constructor TColInfo.Create(const aColumn, aWidth, aXF, aOptions: word);
begin
  inherited Create;
  Column:=aColumn;
  Width:=aWidth;
  XF:=aXF;
  Options:=aOptions;
end;

function TColInfo.IsEqual(const aColInfo: TColInfo): boolean;
begin
  Result:= // don't compare the column .... (Column = aColInfo.Column) and
           (Width  = aColInfo.Width)  and
           (XF     = aColInfo.XF)     and
           (Options= acolInfo.Options);
end;

end.

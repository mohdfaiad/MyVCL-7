unit UXlsEscher;

interface
uses UXlsBaseRecords, UXlsBaseRecordLists, UXlsOtherRecords,
     XlsMessages, UFlxMessages, Classes, SysUtils, UEscherRecords, UXlsSST, UBreakList,
     UEscherOtherRecords;

type

  TXlsEscherRecord = class (TBaseRecord)
  end;

  TDrawingGroupRecord = class (TXlsEscherRecord)
  end;

  TDrawingRecord = class (TXlsEscherRecord)
  end;


  TDrawingSelectionRecord = class (TXlsEscherRecord)
  end;

  TDrawingGroup= class
  private
    FDggContainer: TEscherContainerRecord;
    FRecordCache: TEscherDwgGroupCache;
    function GetRecordCache: PEscherDwgGroupCache;
  public
    property  RecordCache: PEscherDwgGroupCache read GetRecordCache;

    constructor Create;
    procedure Clear;
    destructor Destroy; override;
    procedure LoadFromStream(const DataStream: TStream; const First: TDrawingGroupRecord);
    procedure SaveToStream(const DataStream: TStream);
    function TotalSize: int64;

    procedure AddDwg;
    procedure EnsureDwgGroup;
  end;

  TDrawing=class
  private
    FDgContainer: TEscherContainerRecord;
    FRecordCache: TEscherDwgCache;
    FDrawingGroup: TDrawingGroup;
    function GetDrawingName(index: integer): widestring;
    function GetDrawingRow(index: integer): integer;
    procedure CreateBasicDrawingInfo;

  public
    procedure Clear;
    constructor Create(const aDrawingGroup: TDrawingGroup);
    destructor Destroy; override;

    procedure CopyFrom(const aDrawing: TDrawing);
    procedure LoadFromStream(const DataStream: TStream; const First: TDrawingRecord; const SST: TSST);
    procedure SaveToStream(const DataStream: TStream);
    function TotalSize: int64;

    procedure ArrangeInsert(const aPos, aCount:integer; const SheetInfo: TSheetInfo);
    procedure ArrangeCopySheet(const SheetInfo: TSheetInfo);
    procedure InsertAndCopyRows(const FirstRow, LastRow, DestRow, aCount: integer; const SheetInfo: TSheetInfo);
    procedure DeleteRows(const aRow, aCount: word;const SheetInfo: TSheetInfo);

    function FindObjId(const ObjId: word): TEscherClientDataRecord;

    function DrawingCount: integer;
    procedure AssignDrawing(const Index: integer; const Data: string; const DataType: TXlsImgTypes);
    function GetAnchor(const Index: integer): TClientAnchor;
    procedure GetDrawingFromStream(const Index: integer; const Data: TStream; var DataType: TXlsImgTypes);
    property DrawingRow[index: integer]: integer read GetDrawingRow;
    property DrawingName[index: integer]: widestring read GetDrawingName;

    procedure DeleteImage(const Index: integer);
    procedure ClearImage(const Index: integer);
    procedure AddImage(Data: string; DataType: TXlsImgTypes; const Properties: TImageProperties;const Anchor: TFlxAnchorType);

    function AddNewComment(const Properties: TImageProperties): TEscherClientDataRecord;
  end;

implementation
uses UXlsBaseClientData, UXlsClientData;
const
  EmptyBmp= #$28#$0#$0#$0#$1#$0+
            #$0#$0#$1#$0#$0#$0#$1#$0#$1#$0#$0#$0#$0#$0#$0#$0#$0#$0#$12#$B#$0+
            #$0#$12#$B#$0#$0#$0#$0#$0#$0#$0#$0#$0#$0#$FF#$FF#$FF#$0#$0#$0+
            #$0#$0#$0#$0#$0#$0#$0#$0;

{ TDrawingGroup }

procedure TDrawingGroup.AddDwg;
begin
  if FRecordCache.Dgg<>nil then inc(FRecordCache.Dgg.FDgg.DwgSaved);
  //PENDING: fix sheets

end;

procedure TDrawingGroup.Clear;
begin
  FreeAndNil(FDggContainer);
end;

constructor TDrawingGroup.Create;
begin
  inherited Create;
end;

destructor TDrawingGroup.Destroy;
begin
  Clear;
  inherited;
end;

procedure TDrawingGroup.EnsureDwgGroup;
const
  DwgCache: TEscherDwgCache= ( MaxObjId:0; Dg: nil; Solver: nil; Patriarch:nil; Anchor: nil; Shape: nil; Obj: nil; Blip: nil);
var
  EscherHeader: TEscherRecordHeader;
  FDgg: TEscherDggRecord;
  BStoreContainer: TEscherBStoreRecord;
  OPTRec:TEscherOPTRecord;
  SplitMenu: TEscherSplitMenuRecord;
begin
  if FDggContainer=nil then  // there is already a DwgGroup
  begin
    //DggContainer
    EscherHeader.Pre:=$F;
    EscherHeader.Id:=MsofbtDggContainer;
    EscherHeader.Size:=0;
    FDggContainer:=TEscherContainerRecord.Create(EscherHeader, RecordCache, @DwgCache ,nil);
    FDggContainer.LoadedDataSize:=EscherHeader.Size;
  end;

  if FDggContainer.FindRec(TEscherDggRecord)=nil then
  begin
    //Dgg
    FDgg:=TEscherDggRecord.CreateFromData(RecordCache, @DwgCache ,FDggContainer);
    FDggContainer.ContainedRecords.Add(FDgg);
  end;

  if FDggContainer.FindRec(TEscherBStoreRecord)=nil then
  begin
    // BStoreContainer
    EscherHeader.Pre:=$2F;
    EscherHeader.Id:=MsofbtBstoreContainer;
    EscherHeader.Size:=0;
    BStoreContainer:=TEscherBStoreRecord.Create(EscherHeader, RecordCache, @DwgCache ,FDggContainer);
    BStoreContainer.LoadedDataSize:=EscherHeader.Size;
    FDggContainer.ContainedRecords.Add(BStoreContainer);
  end;

  if FDggContainer.FindRec(TEscherOPTRecord)=nil then
  begin
    //OPT
    OPTRec:=TEscherOPTRecord.GroupCreateFromData(RecordCache, @DwgCache, FDggContainer);
    FDggContainer.ContainedRecords.Add(OPTRec);
  end;

  if FDggContainer.FindRec(TEscherSplitMenuRecord)=nil then
  begin
    //SplitMenuColors
    SplitMenu:=TEscherSplitMenuRecord.CreateFromData(RecordCache, @DwgCache, FDggContainer);
    FDggContainer.ContainedRecords.Add(SplitMenu);
  end;

end;

function TDrawingGroup.GetRecordCache: PEscherDwgGroupCache;
begin
  Result:=@FRecordCache;
end;

procedure TDrawingGroup.LoadFromStream(const DataStream: TStream; const First: TDrawingGroupRecord);
const
  DwgCache: TEscherDwgCache= ( MaxObjId:0; Dg: nil; Solver: nil; Patriarch:nil; Anchor: nil; Shape: nil; Obj: nil; Blip: nil);
var
  aPos: integer;
  EscherHeader: TEscherRecordHeader;
  RecordHeader: TRecordHeader;
  MyRecord, CurrentRecord: TBaseRecord;
begin
  if FDggContainer<>nil then raise Exception.Create(ErrExcelInvalid);
  aPos:=0;
  MyRecord:= First; CurrentRecord:= First;
  try
    ReadMem(MyRecord, aPos, SizeOf(EscherHeader), @EscherHeader);
    FDggContainer:= TEscherContainerRecord.Create(EscherHeader, RecordCache, @DwgCache ,nil);
    while not FDggContainer.Loaded do
    begin
      if (MyRecord.Continue=nil) and (aPos=MyRecord.DataSize) then
      begin
        if CurrentRecord<> First then FreeAndNil(CurrentRecord);
        if (DataStream.Read(RecordHeader, sizeof(RecordHeader)) <> sizeof(RecordHeader)) then
          raise Exception.Create(ErrExcelInvalid);
        CurrentRecord:=LoadRecord(DataStream, RecordHeader);
        MyRecord:= CurrentRecord;
        aPos:=0;
        if not(MyRecord is TDrawingGroupRecord) then raise Exception.Create(ErrExcelInvalid);
      end;

      FDggContainer.Load(MyRecord, aPos);

    end; //while
  finally
    if CurrentRecord<>First then FreeAndNil(CurrentRecord);
  end; //finally

  First.Free;   //last statment
end;

procedure TDrawingGroup.SaveToStream(const DataStream: TStream);
var
  BreakList: TBreakList;
  NextPos, RealSize, NewDwg: integer;
begin
  if FDggContainer=nil then exit;
  BreakList:= TBreakList.Create(DataStream.Position);
  try
    NextPos:=0;
    RealSize:=0;
    NewDwg:= xlr_MSODRAWINGGROUP;
    FDggContainer.SplitRecords(NextPos, RealSize, NewDwg, BreakList);
    BreakList.Add(0, NextPos);
    FDggContainer.SaveToStream(DataStream, BreakList);
  finally
    FreeAndNil(BreakList);
  end; //finally
end;

function TDrawingGroup.TotalSize: int64;
var
  NextPos, RealSize, NewDwg: integer;
begin
  if FDggContainer=nil then begin Result:=0; exit;end;

  NextPos:=0; RealSize:=0; NewDwg:= xlr_MSODRAWINGGROUP;
  FDggContainer.SplitRecords(NextPos, RealSize, NewDwg, nil);
  Result:=RealSize;
end;

{ TDrawing }

procedure TDrawing.ArrangeCopySheet(const SheetInfo: TSheetInfo);
begin
  if (FRecordCache.Obj<> nil) then
    FRecordCache.Obj.ArrangeCopySheet(SheetInfo);
end;

procedure TDrawing.ArrangeInsert(const aPos, aCount: integer; const SheetInfo: TSheetInfo);
begin
  if (FRecordCache.Anchor<> nil) and (SheetInfo.FormulaSheet= SheetInfo.InsSheet)then
    FRecordCache.Anchor.ArrangeInsert(aPos, aCount, SheetInfo, false);
  if (FRecordCache.Obj<> nil) then
    FRecordCache.Obj.ArrangeInsert(aPos, aCount, SheetInfo, false);
end;

procedure TDrawing.AssignDrawing(const Index: integer; const Data: string;
  const DataType: TXlsImgTypes);
begin
  if Data='' then ClearImage(Index)  //XP crashes with a 0 byte image.
  else FRecordCache.Blip[Index].ReplaceImg(Data, DataType);
end;

procedure TDrawing.DeleteImage(const Index: integer);
begin
  if FRecordcache.Anchor=nil then exit;
  if (FRecordCache.Patriarch=nil) then raise Exception.Create(ErrLoadingEscher);
  FRecordCache.Patriarch.ContainedRecords.Remove(FRecordCache.Anchor[Index].FindRoot);
end;

procedure TDrawing.ClearImage(const Index: integer);
begin
  FRecordCache.Blip[Index].ReplaceImg(EmptyBmp, xli_Bmp);
end;

procedure TDrawing.Clear;
begin
  FreeAndNil(FDgContainer);
  //Order is important... Cache should be freed after DgContainer
  FreeAndNil(FRecordCache.Anchor);
  FreeAndNil(FRecordCache.Obj);
  FreeAndNil(FRecordCache.Shape);
  FreeAndNil(FRecordCache.Blip);
end;

procedure TDrawing.CopyFrom(const aDrawing: TDrawing);
begin
  Clear;
  FRecordCache.MaxObjId:=0;
  FRecordCache.Dg:=nil; FRecordCache.Patriarch:=nil;

  if aDrawing.FRecordCache.Anchor<>nil then
  begin
    FRecordCache.Anchor:= TEscherAnchorCache.Create;
    FRecordCache.Obj:= TEscherObjCache.Create;
    FRecordCache.Shape:= TEscherShapeCache.Create;
    FRecordCache.Blip:=TEscherOPTCache.Create;
  end;

  if aDrawing.FDgContainer=nil then FreeAndNil(FDgcontainer) else
  begin
    aDrawing.FDgContainer.ClearCopiedTo;
    FDgContainer:=aDrawing.FDgContainer.CopyTo(@FRecordCache, 0) as TEscherContainerRecord;
    FRecordCache.Shape.Sort; // only here the values are loaded...
    if FRecordCache.Solver<>nil then FRecordCache.Solver.CheckMax(aDrawing.FRecordCache.Solver.MaxRuleId);

    FDrawingGroup.AddDwg;
  end;
  //MADE: change cache
end;

constructor TDrawing.Create(const aDrawingGroup: TDrawingGroup);
begin
  inherited Create;
  FDrawingGroup:=aDrawingGroup;
  FRecordCache.Destroying:=false;
end;

procedure TDrawing.DeleteRows(const aRow, aCount: word;
  const SheetInfo: TSheetInfo);
var i: integer;
begin
  //MADE: delete rows
  //MADE: Arreglar los continues...
  //MADE: Conectores
  if FRecordcache.Anchor=nil then exit;
  for i:= FRecordCache.Anchor.Count-1 downto 0 do
    if FRecordCache.Anchor[i].AllowDelete(aRow, aRow+aCount-1)then
    begin
      if (FRecordCache.Patriarch=nil) then raise Exception.Create(ErrLoadingEscher);
      FRecordCache.Patriarch.ContainedRecords.Remove(FRecordCache.Anchor[i].FindRoot);
    end;

  ArrangeInsert(aRow, -aCount, SheetInfo);
end;

destructor TDrawing.Destroy;
begin
  FRecordCache.Destroying:=true;
  Clear;
  inherited;
end;

function TDrawing.DrawingCount: integer;
begin
  if FRecordCache.Blip<>nil then Result:=FRecordCache.Blip.Count else Result:=0;
end;

function TDrawing.FindObjId(const ObjId: word): TEscherClientDataRecord;
var
  i: integer;
begin
  for i:=0 to FRecordCache.Obj.Count-1 do if FRecordCache.Obj[i].ObjId=ObjId then
  begin
    Result:=FRecordCache.Obj[i];
    exit;
  end;
  Result:=nil;
end;

function TDrawing.GetAnchor(const Index: integer): TClientAnchor;
begin
  Assert(Index<FRecordCache.Blip.Count,'Index out of range');
  Result:=FRecordCache.Blip[index].GetAnchor;
end;

procedure TDrawing.GetDrawingFromStream(const Index: integer; const Data: TStream; var DataType: TXlsImgTypes);
begin
  Assert(Index<FRecordCache.Blip.Count,'Index out of range');
  FRecordCache.Blip[index].GetImageFromStream(Data, DataType);
end;

function TDrawing.GetDrawingName(index: integer): widestring;
begin
  Assert(Index<FRecordCache.Blip.Count,'Index out of range');
  Result:=FRecordCache.Blip[index].ShapeName;
end;

function TDrawing.GetDrawingRow(index: integer): integer;
begin
  Assert(Index<FRecordCache.Blip.Count,'Index out of range');
  Result:=FRecordCache.Blip[index].Row;
end;

procedure TDrawing.InsertAndCopyRows(const FirstRow, LastRow, DestRow,
  aCount: integer; const SheetInfo: TSheetInfo);
var
  i,k, myDestRow, myFirstRow, myLastRow: integer;
begin
  if (FDgContainer=nil) or (FRecordCache.Anchor= nil) then exit;  //no drawings on this sheet

  if DestRow>FirstRow then
  begin
    myFirstRow:=FirstRow; myLastRow:=LastRow;
  end else
  begin
    myFirstRow:=FirstRow+aCount*(LastRow-FirstRow+1);
    myLastRow:=LastRow+aCount*(LastRow-FirstRow+1);
  end;

  //Insert cells
  ArrangeInsert(DestRow, aCount*(LastRow-FirstRow+1), SheetInfo);

  //Copy the images
  myDestRow:=DestRow;
  for k:= 0 to aCount-1 do
  begin
    FDgContainer.ClearCopiedTo;
    for i:= 0 to FRecordCache.Anchor.Count-1 do
      if FRecordCache.Anchor[i].AllowCopy(myFirstRow, myLastRow)then
      begin
         FRecordCache.Anchor[i].CopyDwg(myDestRow-myFirstRow);
      end;
    inc(myDestRow, (LastRow-FirstRow+1));
    if FRecordCache.Solver<>nil then FRecordCache.Solver.ArrangeCopyRows;
  end;

end;

procedure TDrawing.CreateBasicDrawingInfo;
var
  EscherHeader: TEscherRecordHeader;
  Dg: TEscherDgRecord;
  SPRec: TEscherSpContainerRecord;
  SPgrRec:TEscherDataRecord;
  SP: TEscherSPRecord;
begin
  Assert (FDrawingGroup<>nil,'DrawingGroup can''t be nil');
  FRecordCache.MaxObjId:=0;
  FRecordCache.Dg:=nil; FRecordCache.Patriarch:=nil; FRecordCache.Solver:=nil;

  FRecordCache.Anchor:= TEscherAnchorCache.Create;
  FRecordCache.Obj:= TEscherObjCache.Create;
  FRecordCache.Shape:= TEscherShapeCache.Create;
  FRecordCache.Blip:=TEscherOPTCache.Create;

  EscherHeader.Pre:=$F;
  EscherHeader.Id:=MsofbtDgContainer;
  EscherHeader.Size:=0;
  FDgContainer:=TEscherContainerRecord.Create(EscherHeader, FDrawingGroup.RecordCache, @FRecordCache ,nil);
  FDrawingGroup.AddDwg;

  //Add required records...
  Dg:=TEscherDgRecord.CreateFromData(0,$401,FDrawingGroup.RecordCache, @FRecordCache, FDgContainer);
  FDgContainer.ContainedRecords.Add(Dg);

  EscherHeader.Pre:=$F;
  EscherHeader.Id:=MsofbtSpgrContainer;
  EscherHeader.Size:=0;
  FRecordCache.Patriarch:= TEscherSpgrContainerRecord.Create(EscherHeader, FDrawingGroup.RecordCache, @FRecordCache, FDgContainer);
  FDgContainer.ContainedRecords.Add(FRecordCache.Patriarch);

  EscherHeader.Id:=MsofbtSpContainer;
  EscherHeader.Pre:=$F;
  EscherHeader.Size:=0; //Size for a container is calculated later
  SPRec:=TEscherSpContainerRecord.Create(EscherHeader, FDrawingGroup.RecordCache, @FRecordCache, FRecordCache.Patriarch);
  SPRec.LoadedDataSize:=EscherHeader.Size;
  FRecordCache.Patriarch.ContainedRecords.Add(SPRec);

  EscherHeader.Id:=MsofbtSpgr;
  EscherHeader.Pre:=$1;
  EscherHeader.Size:=16;
  SPgrRec:=TEscherDataRecord.Create(EscherHeader, FDrawingGroup.RecordCache, @FRecordCache, FRecordCache.Patriarch);
  SPgrRec.LoadedDataSize:=EscherHeader.Size;
  SPgrRec.ClearData;
  SPRec.ContainedRecords.Add(SPgrRec);

  SP:=TEscherSPRecord.CreateFromData($2,FRecordCache.Dg.IncMaxShapeId, $5 , FDrawingGroup.RecordCache, @FRecordCache, SPRec);
  SPRec.ContainedRecords.Add(SP);


end;

procedure TDrawing.AddImage(Data: string; DataType: TXlsImgTypes; const Properties: TImageProperties;const Anchor: TFlxAnchorType);
var
  SPRec: TEscherSpContainerRecord;
  AnchorRec: TEscherClientAnchorRecord;
  RecordHeader: TEscherRecordHeader;
  ClientAnchor: TClientAnchor;
  ClientData: TEscherClientDataRecord;
  SP: TEscherSPRecord;
  OPTRec:TEscherOPTRecord;
begin
  if Data='' then
  begin
    Data:=EmptyBmp;
    DataType:=xli_Bmp;
  end;
  if (FDgContainer=nil) or (FRecordCache.Anchor= nil) then //no drawings on this sheet
    CreateBasicDrawingInfo;

  if (FRecordCache.Patriarch=nil) then raise Exception.Create(ErrLoadingEscher);

  RecordHeader.Id:=MsofbtSpContainer;
  RecordHeader.Pre:=$F;
  RecordHeader.Size:=0; //Size for a container is calculated later
  SPRec:=TEscherSpContainerRecord.Create(RecordHeader, FDrawingGroup.RecordCache, @FRecordCache, FRecordCache.Patriarch);
  SPRec.LoadedDataSize:=RecordHeader.Size;

  SP:=TEscherSPRecord.CreateFromData($04B2, FRecordCache.Dg.IncMaxShapeId, $A00 , FDrawingGroup.RecordCache, @FRecordCache, SPRec);
  SPRec.ContainedRecords.Add(SP);

  OPTRec:=TEscherOPTRecord.CreateFromDataImg(Data, DataType, Properties.FileName, FDrawingGroup.RecordCache, @FRecordCache, SPRec);
  SPRec.ContainedRecords.Add(OPTRec);

  RecordHeader.Id:=MsofbtClientAnchor;
  RecordHeader.Pre:=0;
  RecordHeader.Size:=SizeOf(TClientAnchor);
  case Anchor of
    at_MoveAndResize: ClientAnchor.Flag:=00;
    at_DontMoveAndDontResize: ClientAnchor.Flag:=03;
    else ClientAnchor.Flag:=02;
  end; //case

  ClientAnchor.Col1:=Properties.Col1;
  ClientAnchor.Dx1:=Properties.dx1;
  ClientAnchor.Col2:=Properties.Col2;
  ClientAnchor.Dx2:=Properties.dx2;
  ClientAnchor.Row1:=Properties.Row1;
  ClientAnchor.Dy1:=Properties.dy1;
  ClientAnchor.Row2:=Properties.Row2;
  ClientAnchor.Dy2:=Properties.dy2;
  AnchorRec:=TEscherClientAnchorRecord.CreateFromData(ClientAnchor, RecordHeader, FDrawingGroup.RecordCache, @FRecordCache, SPRec);
  SPRec.ContainedRecords.Add(AnchorRec);


  RecordHeader.Id:=MsofbtClientData;
  RecordHeader.Pre:=0;
  RecordHeader.Size:=0;
  ClientData:= TEscherClientDataRecord.Create(RecordHeader, FDrawingGroup.RecordCache, @FRecordCache, SPRec);
  ClientData.AssignClientData(TMsObj.CreateEmptyImg(FRecordCache.MaxObjId));
  ClientData.LoadedDataSize:=RecordHeader.Size;
  SPRec.ContainedRecords.Add(ClientData);
  FRecordCache.Patriarch.ContainedRecords.Add(SPRec);
end;

procedure TDrawing.LoadFromStream(const DataStream: TStream;
  const First: TDrawingRecord; const SST: TSST);
var
  aPos, CdPos: integer;
  EscherHeader: TEscherRecordHeader;
  RecordHeader: TRecordHeader;
  MyRecord, CurrentRecord, R, CdRecord: TBaseRecord;
  FClientData: TBaseClientData;
  ClientType: ClassOfTBaseClientData;
begin
  Assert (FDrawingGroup<>nil,'DrawingGroup can''t be nil');
  if FDgContainer<>nil then raise Exception.Create(ErrExcelInvalid);

  FRecordCache.MaxObjId:=0;
  FRecordCache.Dg:=nil; FRecordCache.Patriarch:=nil; FRecordCache.Solver:=nil;
  FRecordCache.Anchor:= TEscherAnchorCache.Create;
  FRecordCache.Obj:= TEscherObjCache.Create;
  FRecordCache.Shape:= TEscherShapeCache.Create;
  FRecordCache.Blip:= TEscherOPTCache.Create;

  aPos:=0;
  MyRecord:= First; CurrentRecord:= First;
  try
    ReadMem(MyRecord, aPos, SizeOf(EscherHeader), @EscherHeader);
    FDgContainer:= TEscherContainerRecord.Create(EscherHeader, FDrawingGroup.RecordCache, @FRecordCache ,nil);
    while (not FDgContainer.Loaded) or FDgContainer.WaitingClientData(ClientType) do
    begin
      if not FDgContainer.WaitingClientData(ClientType) then
      begin
        if (MyRecord.Continue=nil) and (aPos=MyRecord.DataSize) then
        begin
          if CurrentRecord<> First then FreeAndNil(CurrentRecord);
          if (DataStream.Read(RecordHeader, sizeof(RecordHeader)) <> sizeof(RecordHeader)) then
            raise Exception.Create(ErrExcelInvalid);
          CurrentRecord:=LoadRecord(DataStream, RecordHeader);
          MyRecord:= CurrentRecord;
          aPos:=0;
          if not(MyRecord is TDrawingRecord) then raise Exception.Create(ErrExcelInvalid);
        end;
        FDgContainer.Load(MyRecord, aPos);
      end else
      begin
        if not ((MyRecord.Continue=nil) and (aPos=MyRecord.DataSize)) then raise Exception.Create(ErrExcelInvalid);
        if (DataStream.Read(RecordHeader, sizeof(RecordHeader)) <> sizeof(RecordHeader)) then
          raise Exception.Create(ErrExcelInvalid);

         R:=LoadRecord(DataStream, RecordHeader);
         try
           if (R is ClientType.ObjRecord) then
           begin
             FClientData:= ClientType.Create;
             try
               FClientData.LoadFromStream(DataStream, R , SST);
               FDgContainer.AssignClientData(FClientData);
               if FClientData.RemainingData<>nil then
               begin
                 CdRecord:=FClientData.RemainingData; //we dont have to free this
                 CdPos:=0;
                 FDgContainer.Load(CdRecord, CdPos);
               end;
             except
               FreeAndNil(FClientData);
               raise;
             end; //except
           end else raise Exception.Create(ErrInvalidDrawing);
         except
           FreeAndNil(R);
           raise;
         end; //Except
      end;

    end; //while
  finally
    if CurrentRecord<>First then FreeAndNil(CurrentRecord);
  end; //finally

  FRecordCache.Shape.Sort; // only here the values are loaded...
  if FRecordCache.Solver <>nil then FRecordCache.Solver.FixPointers;


  //PENDING: Wmf, emf

  First.Free;   //last statment
end;

procedure TDrawing.SaveToStream(const DataStream: TStream);
var
  BreakList: TBreakList;
  NextPos, RealSize, NewDwg: integer;
begin
  if FDgContainer=nil then exit;
  BreakList:= TBreakList.Create(DataStream.Position);
  try
    NextPos:=0;
    RealSize:=0;
    NewDwg:= xlr_MSODRAWING;
    FDgContainer.SplitRecords(NextPos, RealSize, NewDwg, BreakList);
    BreakList.Add(0, NextPos);
    FDgContainer.SaveToStream(DataStream, BreakList);
  finally
    FreeAndNil(BreakList);
  end; //finally
end;

function TDrawing.TotalSize: int64;
var
  NextPos, RealSize, NewDwg: integer;
begin
  if FDgContainer=nil then begin Result:=0; exit;end;

  NextPos:=0; RealSize:=0; NewDwg:= xlr_MSODRAWINGGROUP;
  FDgContainer.SplitRecords(NextPos, RealSize, NewDwg, nil);
  Result:=RealSize;
end;

function TDrawing.AddNewComment(const Properties: TImageProperties): TEscherClientDataRecord;
var
  aTXO: TTXO;
  aMsObj: TMsObj;
  SP: TEscherSPRecord;
  SPRec: TEscherSpContainerRecord;
  RecordHeader: TEscherRecordHeader;
  TXORec: TEscherClientTextBoxRecord;
  Obj: TEscherClientDataRecord;
  ClientAnchor: TClientAnchor;
  AnchorRec: TEscherClientAnchorRecord;
  OPTRec:TEscherOPTRecord;
begin
  FDrawingGroup.EnsureDwgGroup;
  if (FDgContainer=nil) or (FRecordCache.Anchor= nil) then //no drawings on this sheet
    CreateBasicDrawingInfo;

  RecordHeader.Id:=MsofbtSpContainer;
  RecordHeader.Pre:=$F;
  RecordHeader.Size:=0; //Size for a container is calculated later
  SPRec:=TEscherSpContainerRecord.Create(RecordHeader, FDrawingGroup.RecordCache, @FRecordCache, FRecordCache.Patriarch);
  try
    SPRec.LoadedDataSize:=RecordHeader.Size;

    SP:=TEscherSPRecord.CreateFromData($0CA2, FRecordCache.Dg.IncMaxShapeId, $A00 , FDrawingGroup.RecordCache, @FRecordCache, SPRec);
    try
      SPRec.ContainedRecords.Add(SP);
    except
      FreeAndNil(SP);
      raise;
    end; //except

    OPTRec:=TEscherOPTRecord.CreateFromDataNote(FDrawingGroup.RecordCache, @FRecordCache, SPRec);
    try
      SPRec.ContainedRecords.Add(OPTRec);
    except
      FreeAndNil(OPTRec);
      raise;
    end; //except
    
    RecordHeader.Id:=MsofbtClientAnchor;
    RecordHeader.Pre:=0;
    RecordHeader.Size:=SizeOf(TClientAnchor);
    ClientAnchor.Flag:=03;

    ClientAnchor.Col1:=Properties.Col1;
    ClientAnchor.Dx1:=Properties.dx1;
    ClientAnchor.Col2:=Properties.Col2;
    ClientAnchor.Dx2:=Properties.dx2;
    ClientAnchor.Row1:=Properties.Row1;
    ClientAnchor.Dy1:=Properties.dy1;
    ClientAnchor.Row2:=Properties.Row2;
    ClientAnchor.Dy2:=Properties.dy2;
    AnchorRec:=TEscherClientAnchorRecord.CreateFromData(ClientAnchor, RecordHeader, FDrawingGroup.RecordCache, @FRecordCache, SPRec);
    try
      SPRec.ContainedRecords.Add(AnchorRec);
    except
      FreeAndNil(AnchorRec);
      raise;
    end;

    Obj:=TEscherClientDataRecord.CreateFromData(FDrawingGroup.RecordCache, @FRecordCache, SPRec);
    try
      aMsObj:=TMsObj.CreateEmptyNote(FRecordCache.MaxObjId);
      try
        Obj.AssignClientData(aMsObj);
      except
        FreeAndNil(aMsObj);
        raise;
      end; //Except

      SPRec.ContainedRecords.Add(Obj);
    except
      FreeAndNil(Obj);
      raise;
    end;

    TXORec:= TEscherClientTextBoxRecord.CreateFromData(FDrawingGroup.RecordCache, @FRecordCache, SPRec);
    try
      aTXO:=TTXO.CreateFromData;
      try
        TXORec.AssignClientData(aTXO);
      except
        FreeAndNil(aTXO);
        raise;
      end;
      SPRec.ContainedRecords.Add(TXORec);
    except
      FreeAndNil(TXORec);
      raise;
    end; //except

    FRecordCache.Patriarch.ContainedRecords.Add(SPRec);
  except
    FreeAndNil(SPRec);
    raise;
  end; //except

  Result:=Obj;
end;

end.

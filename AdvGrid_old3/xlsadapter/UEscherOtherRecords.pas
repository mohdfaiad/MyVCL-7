unit UEscherOtherRecords;

interface
uses SysUtils, Classes, UbreakList, UEscherRecords, XlsMessages, UXLSBaseClientData;
type

  TEscherRegroupRecord = class (TEscherDataRecord)
    //PENDING: Erase regroups
  end;


  TRuleRecord = class(TEscherDataRecord)
  public
    function DeleteRef(const aShape: TEscherSPRecord): boolean;virtual;abstract;
    procedure FixPointers;virtual;abstract;
    procedure ArrangeCopyRows; virtual; abstract;
  end;

  TConnectorRule= packed record
    RuleId: Cardinal;
    SpIds: array['A'..'C'] of Cardinal;
    CpA, CpB: Cardinal;
  end;

  PConnectorRule= ^TConnectorRule;

  TEscherConnectorRuleRecord = class (TRuleRecord)
  private
    FConnectorRule: PConnectorRule;
    Shapes: array['A'..'C'] of TEscherSPRecord;
  protected
    function DoCopyTo(const NewDwgCache: PEscherDwgCache; const RowOfs: integer): TEscherRecord;override;

  public
    constructor Create(const aEscherHeader: TEscherRecordHeader; const aDwgGroupCache: PEscherDwgGroupCache; const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord); override;
    function DeleteRef(const aShape: TEscherSPRecord): boolean;override;
    procedure FixPointers;override;
    procedure ArrangeCopyRows; override;
  end;

  TAlignRule= packed record
    RuleId: Cardinal;
    Align:  Cardinal;
    nProxies: Cardinal;
  end;

  PAlignRule= ^TAlignRule;

  TEscherAlignRuleRecord = class (TRuleRecord)
  private
    FAlignRule: PAlignRule;
    //Shapes: array of TEscherSPRecord;
  protected
    function DoCopyTo(const NewDwgCache: PEscherDwgCache; const RowOfs: integer): TEscherRecord;override;

  public
    constructor Create(const aEscherHeader: TEscherRecordHeader; const aDwgGroupCache: PEscherDwgGroupCache; const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord); override;
    function DeleteRef(const aShape: TEscherSPRecord): boolean;override;
    procedure FixPointers;override;
    procedure ArrangeCopyRows; override;
  end;

  TArcRule= packed record
    RuleId: Cardinal;
    SpId:   Cardinal;
  end;

  PArcRule= ^TArcRule;

  TEscherArcRuleRecord = class (TRuleRecord)
  private
    FArcRule: PArcRule;
    Shape: TEscherSPRecord;
  protected
    function DoCopyTo(const NewDwgCache: PEscherDwgCache; const RowOfs: integer): TEscherRecord;override;

  public
    constructor Create(const aEscherHeader: TEscherRecordHeader; const aDwgGroupCache: PEscherDwgGroupCache; const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord); override;
    function DeleteRef(const aShape: TEscherSPRecord): boolean;override;
    procedure FixPointers;override;
    procedure ArrangeCopyRows; override;
  end;

  TCalloutRule= packed record
    RuleId: Cardinal;
    SpId:   Cardinal;
  end;

  PCalloutRule= ^TCalloutRule;

  TEscherCalloutRuleRecord = class (TRuleRecord)
  private
    FCalloutRule: PCalloutRule;
    Shape: TEscherSPRecord;
  protected
    function DoCopyTo(const NewDwgCache: PEscherDwgCache; const RowOfs: integer): TEscherRecord;override;

  public
    constructor Create(const aEscherHeader: TEscherRecordHeader; const aDwgGroupCache: PEscherDwgGroupCache; const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord); override;
    function DeleteRef(const aShape: TEscherSPRecord): boolean;override;
    procedure FixPointers;override;
    procedure ArrangeCopyRows; override;
  end;

  TEscherClientTextBoxRecord= class(TEscherClientDataRecord)
  private
    function GetValue: WideString;
    procedure SetValue(const aValue: WideString);
  public
    property Value: WideString read GetValue write SetValue;
    function WaitingClientData(var ClientType: ClassOfTBaseClientData): boolean;override;

    constructor CreateFromData(const aDwgGroupCache: PEscherDwgGroupCache; const aDwgCache:PEscherDwgCache; const aParent: TEscherContainerRecord);
  end;


implementation
uses UXlsClientData;
{ TEscherConnectorRuleRecord }

procedure TEscherConnectorRuleRecord.ArrangeCopyRows;
begin
  if (Shapes['C'] <> nil) and (Shapes['C'].CopiedTo <> nil) then
    DwgCache.Solver.ContainedRecords.Add(CopyTo(DwgCache, 0));
end;

constructor TEscherConnectorRuleRecord.Create(
  const aEscherHeader: TEscherRecordHeader;
  const aDwgGroupCache: PEscherDwgGroupCache;
  const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord);
begin
  inherited;
  FConnectorRule:=PConnectorRule(Data);
end;

function TEscherConnectorRuleRecord.DeleteRef(const aShape: TEscherSPRecord) : boolean;
var
  c: char;
begin
  for c:='A' to 'C' do
    if Shapes[c]= aShape then
    begin
      Shapes[c]:=nil;
      FConnectorRule.SpIds[c]:=0;
    end;
  DeleteRef:= Shapes['C']=nil;

end;

function TEscherConnectorRuleRecord.DoCopyTo(
  const NewDwgCache: PEscherDwgCache;
  const RowOfs: integer): TEscherRecord;
var
  R: TEscherConnectorRuleRecord;
  c:char;
begin
  R:= inherited DoCopyTo(NewDwgCache, RowOfs) as TEscherConnectorRuleRecord;
  for c:='A' to 'C' do
    if Shapes[c] <> nil then
    begin
      R.Shapes[c]:= Shapes[c].CopiedTo as TEscherSPRecord;
      if R.Shapes[c]<>nil then  R.FConnectorRule.SpIds[c]:= R.Shapes[c].ShapeId^ else R.FConnectorRule.SpIds[c]:=0;
    end;
  R.FConnectorRule.RuleId:= DwgCache.Solver.IncMaxRuleId;
  Result:=R;
end;

procedure TEscherConnectorRuleRecord.FixPointers;
var
  c:char;
  Index: integer;
begin
  if DwgCache <>nil then DwgCache.Solver.CheckMax(FConnectorRule.RuleId);
  for c:='A' to 'C' do if DwgCache.Shape.Find( FConnectorRule.SpIds[c] , Index) then
    Shapes[c]:=DwgCache.Shape[Index] else Shapes[c]:=nil;
end;

{ TEscherAlignRuleRecord }

procedure TEscherAlignRuleRecord.ArrangeCopyRows;
begin
  raise Exception.CreateFmt(ErrNotImplemented,['Align Rule']);
end;

constructor TEscherAlignRuleRecord.Create(
  const aEscherHeader: TEscherRecordHeader;
  const aDwgGroupCache: PEscherDwgGroupCache;
  const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord);
begin
  inherited;
  FAlignRule:=PAlignRule(Data);
  raise Exception.CreateFmt(ErrNotImplemented,['Align Rule']);
end;

function TEscherAlignRuleRecord.DeleteRef(
  const aShape: TEscherSPRecord): boolean;
begin
  //PENDING: align deleteref
  raise Exception.CreateFmt(ErrNotImplemented,['Align Rule']);
end;

function TEscherAlignRuleRecord.DoCopyTo(
  const NewDwgCache: PEscherDwgCache;
  const RowOfs: integer): TEscherRecord;
begin
  raise Exception.CreateFmt(ErrNotImplemented,['Align Rule']);
end;

procedure TEscherAlignRuleRecord.FixPointers;
begin
  raise Exception.CreateFmt(ErrNotImplemented,['Align Rule']);
end;

{ TEscherArcRuleRecord }

procedure TEscherArcRuleRecord.ArrangeCopyRows;
begin
  if (Shape <> nil) and (Shape.CopiedTo <> nil) then
    DwgCache.Solver.ContainedRecords.Add(CopyTo(DwgCache, 0));
end;

constructor TEscherArcRuleRecord.Create(
  const aEscherHeader: TEscherRecordHeader;
  const aDwgGroupCache: PEscherDwgGroupCache;
  const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord);
begin
  inherited;
  FArcRule:=PArcRule(Data);
end;

function TEscherArcRuleRecord.DeleteRef(
  const aShape: TEscherSPRecord): boolean;
begin
  if Shape= aShape then
  begin
    Shape:=nil;
    FArcRule.SpId:=0;
  end;
  DeleteRef:= Shape=nil;
end;

function TEscherArcRuleRecord.DoCopyTo(const NewDwgCache: PEscherDwgCache;
  const RowOfs: integer): TEscherRecord;
var
  R: TEscherArcRuleRecord;
begin
  R:= inherited DoCopyTo(NewDwgCache, RowOfs) as TEscherArcRuleRecord;

  if Shape <> nil then
  begin
    R.Shape:= Shape.CopiedTo as TEscherSPRecord;
    if R.Shape<>nil then  R.FArcRule.SpId:= R.Shape.ShapeId^ else R.FArcRule.SpId:=0;
  end;
  R.FArcRule.RuleId:= DwgCache.Solver.IncMaxRuleId;
  Result:=R;
end;

procedure TEscherArcRuleRecord.FixPointers;
var
  Index: integer;
begin
  if DwgCache <>nil then DwgCache.Solver.CheckMax(FArcRule.RuleId);
  if DwgCache.Shape.Find( FArcRule.SpId , Index) then
    Shape:=DwgCache.Shape[Index] else Shape:=nil;
end;

{ TEscherCalloutRuleRecord }

procedure TEscherCalloutRuleRecord.ArrangeCopyRows;
begin
  if (Shape <> nil) and (Shape.CopiedTo <> nil) then
    DwgCache.Solver.ContainedRecords.Add(CopyTo(DwgCache, 0));
end;

constructor TEscherCalloutRuleRecord.Create(
  const aEscherHeader: TEscherRecordHeader;
  const aDwgGroupCache: PEscherDwgGroupCache;
  const aDwgCache: PEscherDwgCache; const aParent: TEscherContainerRecord);
begin
  inherited;
  FCalloutRule:=PCalloutRule(Data);
end;

function TEscherCalloutRuleRecord.DeleteRef(
  const aShape: TEscherSPRecord): boolean;
begin
  if Shape= aShape then
  begin
    Shape:=nil;
    FCalloutRule.SpId:=0;
  end;
  DeleteRef:= Shape=nil;
end;

function TEscherCalloutRuleRecord.DoCopyTo(const NewDwgCache: PEscherDwgCache;
  const RowOfs: integer): TEscherRecord;
var
  R: TEscherCalloutRuleRecord;
begin
  R:= inherited DoCopyTo(NewDwgCache, RowOfs) as TEscherCalloutRuleRecord;

  if Shape <> nil then
  begin
    R.Shape:= Shape.CopiedTo as TEscherSPRecord;
    if R.Shape<>nil then  R.FCalloutRule.SpId:= R.Shape.ShapeId^ else R.FCalloutRule.SpId:=0;
  end;
  R.FCalloutRule.RuleId:= DwgCache.Solver.IncMaxRuleId;
  Result:=R;
end;

procedure TEscherCalloutRuleRecord.FixPointers;
var
  Index: integer;
begin
  if DwgCache <>nil then DwgCache.Solver.CheckMax(FCalloutRule.RuleId);
  if DwgCache.Shape.Find( FCalloutRule.SpId , Index) then
    Shape:=DwgCache.Shape[Index] else Shape:=nil;
end;

{ TEscherClientTextBoxRecord }

constructor TEscherClientTextBoxRecord.CreateFromData(const aDwgGroupCache: PEscherDwgGroupCache; const aDwgCache:PEscherDwgCache; const aParent: TEscherContainerRecord);
var
  aEscherHeader: TEscherRecordHeader;
begin
  aEscherHeader.Pre:=0;
  aEscherHeader.Id:=MsofbtClientTextbox;
  aEscherHeader.Size:=0;
  Create( aEscherHeader, aDwgGroupCache, aDwgCache, aParent);
  LoadedDataSize:=0;
end;

function TEscherClientTextBoxRecord.GetValue: WideString;
begin
  Result:=(ClientData as TTXO).Value;
end;

procedure TEscherClientTextBoxRecord.SetValue(const aValue: WideString);
begin
  (Clientdata as TTXO).Value:=aValue;
end;

function TEscherClientTextBoxRecord.WaitingClientData(
  var ClientType: ClassOfTBaseClientData): boolean;
begin
    Result:= inherited WaitingClientData(ClientType);
    ClientType:=TTXO;
end;

end.

unit USheetNameList;

interface
uses Classes, SysUtils, XlsMessages, Contnrs;

type
  TWideContainer= record
    S: WideString;
    n: integer;
  end;
  PWideContainer= ^TWideContainer;

  TSheetNameList=class(TList) //Items are TWideContainer
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    function GetFullName(const S: WideString; const N: integer): WideString;
  public
    procedure Add(const aName: WideString); //Error if duplicated entry
    function AddUniqueName(const aName: WideString): WideString;

    function FindRootString(const S: WideString; var Index: Integer): Boolean; virtual;
    function FindFullString(const S: WideString; var Index: Integer): Boolean; virtual;
  end;

implementation

{ TSheetNameList }

procedure TSheetNameList.Add(const aName: WideString);
var
  InsPos: integer;
  Itm: PWideContainer;
begin
  if FindFullString(AName, InsPos) then raise Exception.CreateFmt(ErrDuplicatedSheetName, [string(aName)]);
  New(Itm);
  Itm.S:=aName;
  Itm.n:=0;
  Insert( InsPos, Itm );
end;

function TSheetNameList.AddUniqueName(const aName: WideString): WideString;
var
  InsPos, Dummy: integer;
  Itm: PWideContainer;
  n:integer;
begin
  n:=0;
  if FindRootString(aName, InsPos) then
  begin
    n:=PWideContainer(Items[InsPos]).n+1;
    while FindFullString(GetFullName(aName, n), Dummy) do inc(n);
  end;
  New(Itm);
  Itm.S:=aName;
  Itm.n:=n;
  Insert( InsPos, Itm );
  Result:=GetFullName(aName,n);
end;

function MyCompareWideStrings(const s1,s2: WideString): integer;
var
  i:integer;
begin
  Result:=0;
  if Length(S1)<Length(S2) then Result:=-1 else if Length(S1)>Length(S2) then Result:=1
  else
  for i:=1 to Length(S1) do
  begin
    if S1[i]=S2[i] then continue
    else if S1[i]<S2[i] then Result:=-1 else Result:=1;
    exit;
  end;
end;

function TSheetNameList.FindFullString(const S: WideString;
  var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := MyCompareWideStrings(GetFullName(PWideContainer(Items[I]).S, PWideContainer(Items[I]).N), S);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
      end;
    end;
  end;
  Index := L;
end;

function TSheetNameList.FindRootString(const S: WideString;
  var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := MyCompareWideStrings(PWideContainer(Items[I]).S, S);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
      end;
    end;
  end;
  Index := L;
end;


function TSheetNameList.GetFullName(const S: WideString; const N: integer): WideString;
begin
  if n=0 then Result:= S else Result:= S+IntToStr(n);
end;

procedure TSheetNameList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then Dispose(PWideContainer(Ptr));
  inherited Notify(Ptr, Action);
end;

end.

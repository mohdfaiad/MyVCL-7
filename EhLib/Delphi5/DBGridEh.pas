{*******************************************************}
{                                                       }
{                       EhLib v2.0                      }
{                   TDBGridEh component                 }
{                                                       }
{   Copyright (c) 1998, 2001 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit DBGridEh;

{$R-}
{$I EhLib.Inc}

interface

uses Windows, SysUtils, Messages, Classes, Controls, Forms, StdCtrls,
  Graphics, Grids, DBCtrls, Db, Menus, DBGrids, Registry, DBSumLst,
  IniFiles, ToolCtrlsEh, ImgList, StdActns
{$IFDEF EH_LIB_6} ,Variants {$ENDIF}
  {,dbugintf};

type
  TColumnEhValue = (cvColor, cvWidth, cvFont, cvAlignment, cvReadOnly, cvTitleColor,
    cvTitleCaption, cvTitleAlignment, cvTitleFont, cvTitleButton, cvTitleEndEllipsis,
    cvTitleToolTips, cvTitleOrientation, cvImeMode, cvImeName, cvWordWrap,
    cvLookupDisplayFields, cvCheckboxes, cvAlwaysShowEditButton, cvEndEllipsis,
    cvAutoDropDown, cvDblClickNextVal, cvToolTips, cvDropDownSizing,
    cvDropDownShowTitles);
  TColumnEhValues = set of TColumnEhValue;

  TColumnFooterEhValue = (cvFooterAlignment, cvFooterFont, cvFooterColor);
  TColumnFooterValues = set of TColumnFooterEhValue;

  TColumnEhRestoreParam = (crpColIndexEh,crpColWidthsEh,crpSortMarkerEh,crpColVisibleEh,
     crpDropDownRowsEh, crpDropDownWidthEh);
  TColumnEhRestoreParams = set of TColumnEhRestoreParam;

  TDBGridEhRestoreParam = (grpColIndexEh,grpColWidthsEh,grpSortMarkerEh,grpColVisibleEh,
    grpRowHeightEh, grpDropDownRowsEh, grpDropDownWidthEh);
  TDBGridEhRestoreParams = set of TDBGridEhRestoreParam;

const
  ColumnEhTitleValues = [cvTitleColor..cvTitleOrientation];
  ColumnEhFooterValues = [cvFooterAlignment..cvFooterColor];
(*  cm_DeferLayout = WM_USER + 100; *)

{ TColumnEh defines internal storage for column attributes.  If IsStored is
  True, values assigned to properties are stored in this object, the grid-
  or field-based default sources are not modified.  Values read from
  properties are the previously assigned value, if any, or the grid- or
  field-based default values if nothing has been assigned to that property.
  This class also publishes the column attribute properties for persistent
  storage.

  If IsStored is True, the column does not maintain local storage of
  property values.  Assignments to column properties are passed through to
  the underlying grid- or field-based default sources.  }

type
  TColumnEh = class;
  TCustomDBGridEh = class;

  TSortMarkerEh = (smNoneEh, smDownEh, smUpEh);
  TTextOrientationEh = (tohHorizontal, tohVertical);

{ TColumnTitleEh }

  TColumnTitleEh = class(TPersistent)
  private
    FColumn: TColumnEh;
    FCaption: string;
    FFont: TFont;
    FColor: TColor;
    FAlignment: TAlignment;
    FEndEllipsis: Boolean;
    FSortIndex: Integer;
    FHint: string;
    FImageIndex: Integer;
    FToolTips: Boolean;
    FOrientation:TTextOrientationEh;
    function GetAlignment: TAlignment;
    function GetCaption: string;
    function GetColor: TColor;
    function GetEndEllipsis: Boolean;
    function GetFont: TFont;
    function GetOrientation: TTextOrientationEh;
    function GetTitleButton: Boolean;
    function GetToolTips:Boolean;
    function IsAlignmentStored: Boolean;
    function IsCaptionStored: Boolean;
    function IsColorStored: Boolean;
    function IsEndEllipsisStored: Boolean;
    function IsFontStored: Boolean;
    function IsOrientationStored: Boolean;
    function IsTitleButtonStored: Boolean;
    function IsToolTipsStored: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetAlignment(Value: TAlignment);
    procedure SetCaption(const Value: string); virtual;
    procedure SetColor(Value: TColor);
    procedure SetEndEllipsis(const Value: Boolean);
    procedure SetFont(Value: TFont);
    procedure SetImageIndex(const Value: Integer);
    procedure SetOrientation(const Value: TTextOrientationEh);
    procedure SetSortIndex(Value: Integer);
    procedure SetToolTips(const Value: Boolean);
  protected
    FSortMarker: TSortMarkerEh;
    FTitleButton: Boolean;
    function  GetSortMarkingWidth:Integer;
    procedure RefreshDefaultFont;
    procedure SetSortMarker(Value: TSortMarkerEh);
    procedure SetTitleButton(Value: Boolean);
  public
    constructor Create(Column: TColumnEh);
    destructor Destroy; override;
    function DefaultAlignment: TAlignment;
    function DefaultCaption: string;
    function DefaultColor: TColor;
    function DefaultEndEllipsis: Boolean;
    function DefaultFont: TFont;
    function DefaultOrientation: TTextOrientationEh;
    function DefaultTitleButton: Boolean;
    function DefaultToolTips: Boolean;
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; virtual;
    procedure SetNextSortMarkerValue(KeepMulti:Boolean);
    property Column: TColumnEh read FColumn;
  published
    property Alignment: TAlignment read GetAlignment write SetAlignment stored IsAlignmentStored;
    property Caption: string read GetCaption write SetCaption stored IsCaptionStored;
    property Color: TColor read GetColor write SetColor stored IsColorStored;
    property EndEllipsis: Boolean read GetEndEllipsis write SetEndEllipsis stored IsEndEllipsisStored;
    property Font: TFont read GetFont write SetFont stored IsFontStored;
    property Hint: string read FHint write FHint;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Orientation: TTextOrientationEh read GetOrientation write SetOrientation stored IsOrientationStored;
    property SortIndex: Integer read FSortIndex write SetSortIndex default 0;
    property SortMarker: TSortMarkerEh read FSortMarker write SetSortMarker default smNoneEh;
    property TitleButton: Boolean read GetTitleButton write SetTitleButton stored IsTitleButtonStored;
    property ToolTips: Boolean read GetToolTips write SetToolTips stored IsToolTipsStored;
  end;


{ TColumnFooterEh }

  TFooterValueType = (fvtNon,fvtSum,fvtAvg,fvtCount,fvtFieldValue,fvtStaticText);

  TColumnFooterEh = class(TCollectionItem)
  private
    FAlignment: TAlignment;
    FAssignedValues: TColumnFooterValues;
    FColor: TColor;
    FColumn: TColumnEh;
    FEndEllipsis: Boolean;
    FFieldName: string;
    FFont: TFont;
    FValue:String;
    FValueType: TFooterValueType;
    FWordWrap: Boolean;
    function GetAlignment: TAlignment;
    function GetColor: TColor;
    function GetFont: TFont;
    function IsAlignmentStored: Boolean;
    function IsColorStored: Boolean;
    function IsFontStored: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetAlignment(Value: TAlignment);
    procedure SetColor(Value: TColor);
    procedure SetEndEllipsis(const Value: Boolean);
    procedure SetFieldName(const Value: String);
    procedure SetFont(Value: TFont);
    procedure SetValue(const Value: String);
    procedure SetValueType(const Value: TFooterValueType);
    procedure SetWordWrap(const Value: Boolean);
  protected
    FDBSum:TDBSum;
    procedure RefreshDefaultFont;
  public
    constructor Create(Collection: TCollection); override;
    constructor CreateApart(Column: TColumnEh);
    destructor Destroy; override;
    function DefaultAlignment: TAlignment;
    function DefaultColor: TColor;
    function DefaultFont: TFont;
    procedure Assign(Source: TPersistent); override;
    procedure EnsureSumValue;
    procedure RestoreDefaults; virtual;
    property  AssignedValues: TColumnFooterValues read FAssignedValues;
    property Column: TColumnEh read FColumn;
  published
    property Alignment: TAlignment read GetAlignment write SetAlignment stored IsAlignmentStored;
    property Color: TColor read GetColor write SetColor stored IsColorStored;
    property EndEllipsis: Boolean read FEndEllipsis write SetEndEllipsis default False;
    property FieldName: String read FFieldName write SetFieldName;
    property Font: TFont read GetFont write SetFont stored IsFontStored;
    property Value: String read FValue write SetValue;
    property ValueType: TFooterValueType read FValueType write SetValueType default fvtNon;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  end;

  TColumnFooterEhClass = class of TColumnFooterEh;

 { TColumnFootersEh }

  TColumnFootersEh = class(TCollection)
  private
    FColumn: TColumnEh;
    function GetFooter(Index: Integer): TColumnFooterEh;
    procedure SetFooter(Index: Integer; Value: TColumnFooterEh);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(Column: TColumnEh; FooterClass: TColumnFooterEhClass);
    function Add: TColumnFooterEh;
    property Column: TColumnEh read FColumn;
    property Items[Index: Integer]: TColumnFooterEh read GetFooter write SetFooter; default;
  end;

  TColumnEhType = (ctCommon, ctPickList, ctLookupField, ctKeyPickList, ctKeyImageList,
    ctCheckboxes);
  TColumnButtonStyleEh = (cbsAuto, cbsEllipsis, cbsNone, cbsUpDown, cbsDropDown);

{ TColumnTitleDefValuesEh }

  TColumnDefValuesEh = class;

  TColumnTitleDefValuesEhValue = (cvdpTitleColorEh, cvdpTitleAlignmentEh);
  TColumnTitleDefValuesEhValues = set of TColumnTitleDefValuesEhValue;

  TColumnTitleDefValuesEh = class(TPersistent)
  private
    FAlignment: TAlignment;
    FAssignedValues: TColumnTitleDefValuesEhValues;
    FColor: TColor;
    FColumnDefValues: TColumnDefValuesEh;
    FEndEllipsis: Boolean;
    FOrientation: TTextOrientationEh;
    FTitleButton: Boolean;
    FToolTips: Boolean;
    function DefaultAlignment: TAlignment;
    function DefaultColor: TColor;
    function GetAlignment: TAlignment;
    function GetColor: TColor;
    function IsAlignmentStored: Boolean;
    function IsColorStored: Boolean;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetColor(const Value: TColor);
    procedure SetEndEllipsis(const Value: Boolean);
    procedure SetOrientation(const Value: TTextOrientationEh);
  public
    procedure Assign(Source: TPersistent); override;
    property  AssignedValues: TColumnTitleDefValuesEhValues read FAssignedValues;
  published
    constructor Create(ColumnDefValues: TColumnDefValuesEh);
    property Alignment: TAlignment read GetAlignment write SetAlignment stored IsAlignmentStored;
    property Color: TColor read GetColor write SetColor stored IsColorStored;
    property EndEllipsis: Boolean read FEndEllipsis write SetEndEllipsis default False;
    property Orientation: TTextOrientationEh read FOrientation write SetOrientation default tohHorizontal;
    property TitleButton: Boolean read FTitleButton write FTitleButton default False;
    property ToolTips: Boolean read FToolTips write FToolTips default False;
  end;

{ TColumnDefValuesEh }

  TColumnDefValuesEh = class(TPersistent)
  private
    FAlwaysShowEditButton: Boolean;
    FAutoDropDown: Boolean;
    FDblClickNextVal: Boolean;
    FDropDownShowTitles: Boolean;
    FDropDownSizing: Boolean;
    FEndEllipsis: Boolean;
    FGrid: TCustomDBGridEh;
    FTitle: TColumnTitleDefValuesEh;
    FToolTips: Boolean;
    procedure SetAlwaysShowEditButton(const Value: Boolean);
    procedure SetEndEllipsis(const Value: Boolean);
    procedure SetTitle(const Value: TColumnTitleDefValuesEh);
  public
    procedure Assign(Source: TPersistent); override;
  published
    constructor Create(Grid: TCustomDBGridEh);
    destructor Destroy; override;
    property AlwaysShowEditButton: Boolean read FAlwaysShowEditButton write SetAlwaysShowEditButton default False;
    property AutoDropDown: Boolean read FAutoDropDown write FAutoDropDown  default False;
    property DblClickNextVal: Boolean read FDblClickNextVal write FDblClickNextVal default False;
    property DropDownShowTitles: Boolean read FDropDownShowTitles write FDropDownShowTitles default False;
    property DropDownSizing: Boolean read FDropDownSizing write FDropDownSizing default False;
    property EndEllipsis: Boolean read FEndEllipsis write SetEndEllipsis default False;
    property Title: TColumnTitleDefValuesEh read FTitle write SetTitle;
    property ToolTips: Boolean read FToolTips write FToolTips default False;
  end;

{ TColumnEh }

  TColCellParamsEh = class
  protected
    FAlignment: TAlignment;
    FBackground: TColor;
    FCheckboxState: TCheckBoxState;
    FCol: Longint;
    FFont: TFont;
    FImageIndex: Integer;
    FReadOnly: Boolean;
    FRow: Longint;
    FState: TGridDrawState;
    FText: String;
  public
    property Alignment: TAlignment read FAlignment write FAlignment;
    property Background: TColor read FBackground write FBackground;
    property CheckboxState: TCheckBoxState read FCheckboxState write FCheckboxState;
    property Col: Longint read FCol;
    property Font: TFont read FFont;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property Row: Longint read FRow;
    property State: TGridDrawState read FState;
    property Text: String read FText write FText;
  end;

  TGetColCellParamsEventEh = procedure (Sender: TObject; EditMode: Boolean;
    Params: TColCellParamsEh) of object;
  TColCellUpdateDataEventEh = procedure(Sender: TObject; var Text: String;
    var Value: Variant; var UseText: Boolean; var Handled: Boolean) of object;

  TColumnEh = class(TCollectionItem)
  private
    FAlignment: TAlignment;
    FAssignedValues: TColumnEhValues;
    FButtonStyle: TColumnButtonStyleEh;
    FCheckboxes: Boolean;
    FColor: TColor;
    FDblClickNextVal: Boolean;
    FDropDownRows: Cardinal;
    FDropDownShowTitles: Boolean;
    FDropDownSizing: Boolean;
    FField: TField;
    FFieldName: string;
    FFont: TFont;
    FFooter: TColumnFooterEh;
    FFooters: TColumnFootersEh;
    FImageList: TCustomImageList;
    FImeMode: TImeMode;
    FImeName: TImeName;
    FIncrement: Extended;
    FKeyList: TStrings;
    FMaxWidth: Integer;
    FMinWidth: Integer;
    FNotInKeyListIndex: Integer;
    FNotInWidthRange:Boolean;
    FOnButtonClick: TButtonClickEventEh;
    FOnButtonDown: TButtonDownEventEh;
    FOnGetCellParams: TGetColCellParamsEventEh;
    FOnNotInList: TNotInListEventEh;
    FPickList: TStrings;
    FPopupMenu: TPopupMenu;
    FReadonly: Boolean;
    FStored: Boolean;
    FTag: Longint;
    FTitle: TColumnTitleEh;
    FToolTips: Boolean;
    FUpdateData: TColCellUpdateDataEventEh;
    FVisible: Boolean;
    FWidth: Integer;
    function  IsCheckboxesStored: Boolean;
    function DefaultCheckboxes: Boolean;
    function GetAlignment: TAlignment;
    function GetAlwaysShowEditButton: Boolean;
    function GetAutoDropDown: Boolean;
    function GetCheckboxes: Boolean;
    function GetCheckboxState: TCheckBoxState;
    function GetColor: TColor;
    function GetDblClickNextVal: Boolean;
    function GetDropDownShowTitles: Boolean;
    function GetDropDownSizing: Boolean;
    function GetEndEllipsis: Boolean;
    function GetField: TField;
    function GetFont: TFont;
    function GetImeMode: TImeMode;
    function GetImeName: TImeName;
    function GetKeykList: TStrings;
    function GetPickList: TStrings;
    function GetReadOnly: Boolean;
    function GetToolTips:Boolean;
    function GetWidth: Integer;
    function IsAlignmentStored: Boolean;
    function IsAlwaysShowEditButtonStored: Boolean;
    function IsAutoDropDownStored: Boolean;
    function IsColorStored: Boolean;
    function IsDblClickNextValStored: Boolean;
    function IsDropDownShowTitlesStored: Boolean;
    function IsDropDownSizingStored: Boolean;
    function IsEndEllipsisStored: Boolean;
    function IsFontStored: Boolean;
    function IsImeModeStored: Boolean;
    function IsImeNameStored: Boolean;
    function IsIncrementStored: Boolean;
    function IsReadOnlyStored: Boolean;
    function IsToolTipsStored: Boolean;
    function IsWidthStored: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetAlignment(Value: TAlignment); virtual;
    procedure SetButtonStyle(Value: TColumnButtonStyleEh);
    procedure SetCheckboxes(const Value: Boolean);
    procedure SetCheckboxState(const Value: TCheckBoxState);
    procedure SetColor(Value: TColor);
    procedure SetDblClickNextVal(const Value: Boolean);
    procedure SetDropDownShowTitles(const Value: Boolean);
    procedure SetDropDownSizing(const Value: Boolean);
    procedure SetField(Value: TField); virtual;
    procedure SetFieldName(const Value: String);
    procedure SetFont(Value: TFont);
    procedure SetFooter(const Value: TColumnFooterEh);
    procedure SetFooters(const Value: TColumnFootersEh);
    procedure SetImageList(const Value: TCustomImageList);
    procedure SetImeMode(Value: TImeMode); virtual;
    procedure SetImeName(Value: TImeName); virtual;
    procedure SetKeykList(const Value: TStrings);
    procedure SetMaxWidth(const Value: Integer);
    procedure SetMinWidth(const Value: Integer);
    procedure SetNotInKeyListIndex(const Value: Integer);
    procedure SetOnGetCellParams(const Value: TGetColCellParamsEventEh);
    procedure SetPickList(Value: TStrings);
    procedure SetPopupMenu(Value: TPopupMenu);
    procedure SetReadOnly(Value: Boolean); virtual;
    procedure SetTitle(Value: TColumnTitleEh);
    procedure SetToolTips(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetWidth(Value: Integer); virtual;
  protected
    FAlwaysShowEditButton: Boolean;
    FAutoDropDown: Boolean;
    FAutoFitColWidth:Boolean;
    FDropDownWidth: Integer;
    FEndEllipsis: Boolean;
    FInitWidth:Integer;
    FLookupDisplayFields:String;
    FWordWrap:Boolean;
    function  AllowableWidth(TryWidth:Integer):Integer;
    function  CreateFooter: TColumnFooterEh; virtual;
    function  CreateFooters: TColumnFootersEh; virtual;
    function  CreateTitle: TColumnTitleEh; virtual;
    function  DefaultAlwaysShowEditButton: Boolean;
    function  DefaultAutoDropDown: Boolean;
    function  DefaultDblClickNextVal: Boolean;
    function  DefaultDropDownShowTitles: Boolean;
    function  DefaultDropDownSizing: Boolean;
    function  DefaultEndEllipsis: Boolean;
    function  DefaultLookupDisplayFields: String;
    function  DefaultToolTips: Boolean;
    function  DefaultWordWrap: Boolean;
    function  GetAutoFitColWidth: Boolean;
    function  GetGrid: TCustomDBGridEh;
    function  GetLookupDisplayFields: String;
    function  GetWordWrap: Boolean;
    function  IsLookupDisplayFieldsStored: Boolean;
    function  IsWordWrapStored: Boolean;
    function GetDisplayName: string; override;
    procedure EnsureSumValue;
    procedure RefreshDefaultFont;
    procedure SetAlwaysShowEditButton(Value: Boolean);
    procedure SetAutoDropDown(Value: Boolean);
    procedure SetAutoFitColWidth(Value: Boolean); virtual;
    procedure SetDropDownWidth(Value: Integer);
    procedure SetEndEllipsis(const Value: Boolean);
    procedure SetIndex(Value: Integer); override;
    procedure SetLookupDisplayFields(Value:String); virtual;
    procedure SetNextFieldValue(Increment: Extended);
    procedure SetWordWrap(Value: Boolean); virtual;
    procedure UpdateDataValues(Text: String; Value: Variant; UseText: Boolean);
    property IsStored: Boolean read FStored write FStored default True;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function CanModify(TryEdit:Boolean):Boolean;
    function DefaultAlignment: TAlignment;
    function DefaultColor: TColor;
    function DefaultFont: TFont;
    function DefaultImeMode: TImeMode;
    function DefaultImeName: TImeName;
    function DefaultReadOnly: Boolean;
    function DefaultWidth: Integer;
    function DisplayText: String;
    function GetColumnType: TColumnEhType;
    function GetImageIndex: Integer;
    function UsedFooter(Index: Integer): TColumnFooterEh;
    procedure Assign(Source: TPersistent); override;
    procedure DropDown;
    procedure FillColCellParams(ColCellParamsEh: TColCellParamsEh);
    procedure GetColCellParams(EditMode: Boolean; ColCellParamsEh: TColCellParamsEh); virtual;
    procedure RestoreDefaults; virtual;
    property AssignedValues: TColumnEhValues read FAssignedValues;
    property CheckboxState: TCheckBoxState read GetCheckboxState write SetCheckboxState;
    property Field: TField read GetField write SetField;
    property Grid: TCustomDBGridEh read GetGrid;
  published
    property Alignment: TAlignment read GetAlignment write SetAlignment stored IsAlignmentStored;
    property AlwaysShowEditButton: Boolean read GetAlwaysShowEditButton write SetAlwaysShowEditButton stored IsAlwaysShowEditButtonStored;
    property AutoDropDown: Boolean read GetAutoDropDown write SetAutoDropDown stored IsAutoDropDownStored;
    property AutoFitColWidth: Boolean read GetAutoFitColWidth write SetAutoFitColWidth default True;
    property ButtonStyle: TColumnButtonStyleEh read FButtonStyle write SetButtonStyle default cbsAuto;
    property Checkboxes: Boolean read GetCheckboxes write SetCheckboxes stored IsCheckboxesStored;
    property Color: TColor read GetColor write SetColor stored IsColorStored;
    property DblClickNextVal: Boolean read GetDblClickNextVal write SetDblClickNextVal stored IsDblClickNextValStored;
    property DropDownRows: Cardinal read FDropDownRows write FDropDownRows default 7;
    property DropDownShowTitles: Boolean read GetDropDownShowTitles write SetDropDownShowTitles stored IsDropDownShowTitlesStored;
    property DropDownSizing: Boolean read GetDropDownSizing write SetDropDownSizing stored IsDropDownSizingStored;
    property DropDownWidth: Integer read FDropDownWidth write SetDropDownWidth  default 0;
    property EndEllipsis: Boolean read GetEndEllipsis write SetEndEllipsis stored IsEndEllipsisStored;
    property FieldName: String read FFieldName write SetFieldName;
    property Font: TFont read GetFont write SetFont stored IsFontStored;
    property Footer: TColumnFooterEh read FFooter write SetFooter;
    property Footers:TColumnFootersEh read FFooters write SetFooters;
    property ImageList: TCustomImageList read FImageList write SetImageList;
    property ImeMode: TImeMode read GetImeMode write SetImeMode stored IsImeModeStored;
    property ImeName: TImeName read GetImeName write SetImeName stored IsImeNameStored;
    property Increment: Extended read FIncrement write FIncrement stored IsIncrementStored;
    property KeyList: TStrings read GetKeykList write SetKeykList;
    property LookupDisplayFields: String read GetLookupDisplayFields write SetLookupDisplayFields stored IsLookupDisplayFieldsStored;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 0;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property NotInKeyListIndex: Integer read FNotInKeyListIndex write SetNotInKeyListIndex default -1;
    property PickList: TStrings read GetPickList write SetPickList;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly stored IsReadOnlyStored;
    property Tag: Longint read FTag write FTag default 0;
    property Title: TColumnTitleEh read FTitle write SetTitle;
    property ToolTips: Boolean read GetToolTips write SetToolTips stored IsToolTipsStored;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read GetWidth write SetWidth stored IsWidthStored;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap stored IsWordWrapStored;
    property OnEditButtonClick: TButtonClickEventEh read FOnButtonClick write FOnButtonClick;
    property OnEditButtonDown: TButtonDownEventEh read FOnButtonDown write FOnButtonDown;
    property OnGetCellParams: TGetColCellParamsEventEh read FOnGetCellParams write SetOnGetCellParams;
    property OnNotInList: TNotInListEventEh read FOnNotInList write FOnNotInList;
    property OnUpdateData: TColCellUpdateDataEventEh read FUpdateData write FUpdateData;
  end;

  TColumnEhClass = class of TColumnEh;


{ TDBGridColumnsEh }

  TDBGridColumnsEh = class(TCollection)
  private
    FGrid: TCustomDBGridEh;
    function GetColumn(Index: Integer): TColumnEh;
    function GetState: TDBGridColumnsState;
    function InternalAdd: TColumnEh;
    procedure SetColumn(Index: Integer; Value: TColumnEh);
    procedure SetState(NewState: TDBGridColumnsState);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(Grid: TCustomDBGridEh; ColumnClass: TColumnEhClass);
    function Add: TColumnEh;
    function ExistFooterValueType(AFooterValueType:TFooterValueType):Boolean;
    procedure LoadFromFile(const Filename: string);
    procedure LoadFromStream(S: TStream);
    procedure RebuildColumns;
    procedure RestoreDefaults;
    procedure SaveToFile(const Filename: string);
    procedure SaveToStream(S: TStream);
    property Grid: TCustomDBGridEh read FGrid;
    property Items[Index: Integer]: TColumnEh read GetColumn write SetColumn; default;
    property State: TDBGridColumnsState read GetState write SetState;
  end;

{ TColumnsEhList }

  TColumnsEhList = class(TList)
  private
    function GetColumn(Index: Integer): TColumnEh;
    procedure SetColumn(Index: Integer; const Value: TColumnEh);
  public
    property Items[Index: Integer]: TColumnEh read GetColumn write SetColumn; default;
  end;

{ TGridDataLinkEh }

  TGridDataLinkEh = class(TDataLink)
  private
    FFieldCount: Integer;
    FFieldMap: Pointer;
    FFieldMapSize: Integer;
    FGrid: TCustomDBGridEh;
    FInUpdateData: Boolean;
    FModified: Boolean;
    FSparseMap: Boolean;
    function GetDefaultFields: Boolean;
    function GetFields(I: Integer): TField;
  protected
    function GetMappedIndex(ColIndex: Integer): Integer;
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure EditingChanged; override;
    procedure FocusControl(Field: TFieldRef); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
    procedure UpdateData; override;
  public
    constructor Create(AGrid: TCustomDBGridEh);
    destructor Destroy; override;
    function AddMapping(const FieldName: string): Boolean;
    procedure ClearMapping;
    procedure Modified;
    procedure Reset;
    property DefaultFields: Boolean read GetDefaultFields;
    property FieldCount: Integer read FFieldCount;
    property Fields[I: Integer]: TField read GetFields;
    property SparseMap: Boolean read FSparseMap write FSparseMap;
  end;

{ TBookmarkListEh }

  TBookmarkListEh = class
  private
    FCache: TBookmarkStr;
    FCacheFind: Boolean;
    FCacheIndex: Integer;
    FGrid: TCustomDBGridEh;
    FLinkActive: Boolean;
    FList: TStringList;
    function GetCount: Integer;
    function GetCurrentRowSelected: Boolean;
    function GetItem(Index: Integer): TBookmarkStr;
    procedure SetCurrentRowSelected(Value: Boolean);
    procedure StringsChanged(Sender: TObject);
  protected
    function Compare(const Item1, Item2: TBookmarkStr): Integer;
    function CurrentRow: TBookmarkStr;
    procedure LinkActive(Value: Boolean);
  public
    constructor Create(AGrid: TCustomDBGridEh);
    destructor Destroy; override;
    function  Find(const Item: TBookmarkStr; var Index: Integer): Boolean;
    function  IndexOf(const Item: TBookmarkStr): Integer;
    function  Refresh: Boolean;// drop orphaned bookmarks; True = orphans found
    procedure Clear;           // free all bookmarks
    procedure Delete;          // delete all selected rows from dataset
    procedure SelectAll;
    property Count: Integer read GetCount;
    property CurrentRowSelected: Boolean read GetCurrentRowSelected
      write SetCurrentRowSelected;
    property Items[Index: Integer]: TBookmarkStr read GetItem; default;
  end;


{ THeadTreeNode }

  THeadTreeNode = class;
  TDBGridEh = class;

  LeafCol = record
    FLeaf:THeadTreeNode;
    FColumn:TColumnEh;
  end;

  PLeafCol = ^LeafCol;
  TLeafCol = array[0..MaxListSize - 1] of LeafCol;
  PTLeafCol = ^TLeafCol;

  THeadTreeProc = procedure (node:THeadTreeNode) of object;

  THeadTreeNode = class(TObject)
  public
    Child:THeadTreeNode;
    Column:TColumnEh;
    Drawed:Boolean;
    Height:Integer;
    HeightPrn:Integer;
    Host:THeadTreeNode;
    Next:THeadTreeNode;
    Text:String;
    VLineWidth:Integer;
    Width:Integer;
    WidthPrn:Integer;
    WIndent:Integer;
    constructor Create;
    constructor CreateText(AText:String;AHeight,AWidth:Integer);
    destructor Destroy; override;
    function Add(AAfter:THeadTreeNode;AText:String;AHeight,AWidth:Integer):THeadTreeNode ;
    function AddChild(ANode:THeadTreeNode;AText:String;AHeight,AWidth:Integer):THeadTreeNode ;
    function Find(ANode:THeadTreeNode):Boolean;
    procedure CreateFieldTree(AGrid:TCustomDBGridEh);
    procedure DoForAllNode(proc:THeadTreeProc);
    procedure FreeAllChild;
    procedure Union(AFrom,ATo :THeadTreeNode; AText:String;AHeight:Integer);
  end;

{ TDBGridEhSumList }

  TDBGridEhSumList = class(TDBSumListProducer)
  private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  protected
    procedure ReturnEvents; override;
  public
    constructor Create(AOwner:TComponent);
    procedure SetDataSetEvents; override;
  published
    property Active: Boolean read GetActive write SetActive default False;
    property ExternalRecalc default False;
    property SumListChanged;
    property VirtualRecords default False;
    property OnRecalcAll;
  end;

  {TDBGridEhScrollBar}

  TDBGridEhScrollBar = class(TPersistent)
  private
    FDBGridEh: TCustomDBGridEh;
    FKind: TScrollBarKind;
    FTracking: Boolean;
    FVisible: Boolean;
    procedure SetVisible(Value: Boolean);
  public
    constructor Create(AGrid: TCustomDBGridEh; AKind: TScrollBarKind);
    function IsScrollBarVisible: Boolean;
    procedure Assign(Source: TPersistent); override;
    property Kind: TScrollBarKind read FKind;
  published
    property Tracking: Boolean read FTracking write FTracking default False;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TDBGridEhSelectionType = (gstNon, gstRecordBookmarks, gstRectangle, gstColumns, gstAll);
  TDBGridEhAllowedSelection = gstRecordBookmarks..gstAll;
  TDBGridEhAllowedSelections = set of TDBGridEhAllowedSelection;

  TDBCell = record
    Col : Longint;
    Row : TBookmarkStr;
  end;

{ TDBGridEhSelectionRect }

  TDBGridEhSelectionRect = class(TObject)
  private
    FAnchor:TDBCell;
    FGrid:TCustomDBGridEh;
    FShiftCell:TDBCell;
    function BoxRect(ALeft:Longint; ATop:TBookmarkStr; ARight:Longint; ABottom:TBookmarkStr): TRect;
    function CheckState:Boolean;
    function GetBottomRow: TBookmarkStr;
    function GetLeftCol: Longint;
    function GetRightCol: Longint;
    function GetTopRow: TBookmarkStr;
  public
    constructor Create(AGrid:TCustomDBGridEh);
    function DataCellSelected(DataCol :Longint; DataRow :TBookmarkStr):Boolean;
    procedure Clear;
    procedure Select(ACol :Longint; ARow :TBookmarkStr; AddSel:Boolean);
    property BottomRow: TBookmarkStr read GetBottomRow;
    property LeftCol: Longint read GetLeftCol;
    property RightCol: Longint read GetRightCol;
    property TopRow: TBookmarkStr read GetTopRow;
  end;

{ TDBGridEhSelectionCols }

  TDBGridEhSelectionCols = class(TColumnsEhList)
  private
    FAnchor:TColumnEh;
    FGrid:TCustomDBGridEh;
    FShiftCol:TColumnEh;
    FShiftSelectedCols:TColumnsEhList;
    procedure Add(ACol: TColumnEh);
  public
    constructor Create(AGrid:TCustomDBGridEh);
    destructor Destroy; override;
    procedure Clear; override;
    procedure InvertSelect(ACol: TColumnEh);
    procedure Refresh;
    procedure Select(ACol: TColumnEh; AddSel:Boolean);
    procedure SelectShift(ACol: TColumnEh{; Clear:Boolean});
  end;

{ TDBGridEhSelection }

  TDBGridEhSelection = class
  private
    FColumns:TDBGridEhSelectionCols;
    FGrid:TCustomDBGridEh;
    FRect:TDBGridEhSelectionRect;
    FSelectionType:TDBGridEhSelectionType;
    function GetRows: TBookmarkListEh;
    procedure LinkActive(Value: Boolean);
    procedure SetSelectionType(ASelType:TDBGridEhSelectionType);
  public
    constructor Create(AGrid:TCustomDBGridEh);
    destructor Destroy; override;
    function DataCellSelected(DataCol :Longint; DataRow :TBookmarkStr):Boolean;
    procedure Clear;
    procedure Refresh;
    procedure SelectAll;
    procedure UpdateState;
    property Columns: TDBGridEhSelectionCols read FColumns;
    property Rect: TDBGridEhSelectionRect read FRect;
    property Rows: TBookmarkListEh read GetRows;
    property SelectionType:TDBGridEhSelectionType read FSelectionType;
  end;

{ TCustomDBGridEh }

  TDBGridEhOption = (dghFixed3D, dghFrozen3D, dghFooter3D, dghData3D, dghResizeWholeRightPart,
                     dghHighlightFocus, dghClearSelection, dghFitRowHeightToText, dghAutoSortMarking,
                     dghMultiSortMarking, dghEnterAsTab, dghTraceColSizing, dghIncSearch,
                     dghPreferIncSearch, dghRowHighlight);
  TDBGridEhOptions = set of TDBGridEhOption;

  TDBGridEhState = (dgsNormal, dgsRowSelecting, dgsColSelecting, dgsRectSelecting,
                    dgsPosTracing, dgsTitleDown, dgsColSizing);

  TDBGridEhAllowedOperation = (alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh);
  TDBGridEhAllowedOperations = set of TDBGridEhAllowedOperation;

  TDBGridEhEditAction = (geaCutEh, geaCopyEh, geaPasteEh, geaDeleteEh, geaSelectAllEh);
  TDBGridEhEditActions = set of TDBGridEhEditAction;

  TInpsDirectionEh = (inpsFromFirstEh,inpsToNextEh,inpsToPriorEh);

  { The DBGridEh's DrawDataCell virtual method and OnDrawDataCell event are only
    called when the grid's Columns.State is csDefault.  This is for compatibility
    with existing code. These routines don't provide sufficient information to
    determine which column is being drawn, so the column attributes aren't
    easily accessible in these routines.  Column attributes also introduce the
    possibility that a column's field may be nil, which would break existing
    DrawDataCell code.   DrawDataCell, OnDrawDataCell, and DefaultDrawDataCell
    are obsolete, retained for compatibility purposes. }
(*  TDrawDataCellEvent = procedure (Sender: TObject; const Rect: TRect; Field: TField;
    State: TGridDrawState) of object; *)

  { The DBGridEh's DrawColumnCell virtual method and OnDrawColumnCell event are
    always called, when the grid has defined column attributes as well as when
    it is in default mode.  These new routines provide the additional
    information needed to access the column attributes for the cell being
    drawn, and must support nil fields.  }


  TDrawColumnEhCellEvent = procedure (Sender: TObject; const Rect: TRect;
    DataCol: Integer; Column: TColumnEh; State: TGridDrawState) of object;
  TDBGridEhClickEvent = procedure (Column: TColumnEh) of object;
  TDrawFooterCellEvent = procedure (Sender: TObject; DataCol, Row: Longint;
    Column: TColumnEh; Rect: TRect; State: TGridDrawState) of object;
  TGetFooterParamsEvent = procedure (Sender: TObject; DataCol, Row: Longint;
    Column: TColumnEh; AFont: TFont; var Background: TColor;
    var Alignment : TAlignment; State: TGridDrawState; var Text:String) of object;

  TTitleEhClickEvent = procedure (Sender: TObject; ACol: Longint;
    Column: TColumnEh) of object;
  TCheckTitleEhBtnEvent = procedure (Sender: TObject; ACol: Longint;
    Column: TColumnEh; var Enabled: Boolean) of object;
  TGetBtnEhParamsEvent = procedure (Sender: TObject; Column: TColumnEh;
    AFont: TFont; var Background: TColor; var SortMarker: TSortMarkerEh;
    IsDown: Boolean) of object;
  TGetCellEhParamsEvent = procedure (Sender: TObject; Column: TColumnEh;
    AFont: TFont; var Background: TColor; State: TGridDrawState) of object;

  { Internal grid types }
  TGridAxisDrawInfoEh = record
    EffectiveLineWidth: Integer;
    FirstGridCell: Integer;
    FixedBoundary: Integer;
    FixedCellCount: Integer;
    FooterExtent:Integer;
    FrozenExtent:Integer;
    FullVisBoundary: Integer;
    GetExtent: TGetExtentsFunc;
    GridBoundary: Integer;
    GridCellCount: Integer;
    GridExtent: Integer;
    LastFullVisibleCell: Longint;
  end;

  TGridDrawInfoEh = record
    Horz, Vert: TGridAxisDrawInfoEh;
  end;

  TCustomDBGridEh = class(TCustomGrid)
  private
    FAllowedOperations: TDBGridEhAllowedOperations;
    FAllowedSelections: TDBGridEhAllowedSelections;
    FAutoDrag, FSelectedCellPressed:Boolean;
    FBookmarks: TBookmarkListEh;
    FBorderWidth:Integer;
    FColumnDefValues: TColumnDefValuesEh;
    FColumns: TDBGridColumnsEh;
    FDataLink: TGridDataLinkEh;
    FDefaultDrawing: Boolean;
    FEditActions: TDBGridEhEditActions;
    FEditKeyValue: Variant; // For lookup fields and KeyList based column
    FEditText: string;
    FFlat: Boolean;
    FFooterColor: TColor;
    FFooterFont: TFont;
    FHintFont:TFont;
    FHorzScrollBar: TDBGridEhScrollBar;
    FInColExit: Boolean;
    FIndicators: TImageList;
    FInterlinear:Integer;
    FLayoutFromDataset: Boolean;
    FLayoutLock: Byte;
    FOnCellClick: TDBGridEhClickEvent;
    FOnColEnter: TNotifyEvent;
    FOnColExit: TNotifyEvent;
    FOnColumnMoved: TMovedEvent;
    FOnColWidthsChanged: TNotifyEvent;
    FOnDrawColumnCell: TDrawColumnEhCellEvent;
    FOnDrawDataCell: TDrawDataCellEvent;
    FOnEditButtonClick: TNotifyEvent;
    FOnGetCellParams: TGetCellEhParamsEvent;
    FOnGetFooterParams: TGetFooterParamsEvent;
    FOnSortMarkingChanged: TNotifyEvent;
    FOnSumListRecalcAll: TNotifyEvent;
    FOnTitleClick:TDBGridEhClickEvent;
    FOptions: TDBGridOptions;
    FOptionsEh: TDBGridEhOptions;
    FOriginalImeMode: TImeMode;
    FOriginalImeName: TImeName;
    FReadOnly: Boolean;
    FSelecting: Boolean;
    FSelection: TDBGridEhSelection;
    FSelectionAnchor: TBookmarkStr;
    FSelfChangingFooterFont: Boolean;
    FSelfChangingTitleFont: Boolean;
    FSelRow: Integer;
    FSizingIndex: Longint;
    FSizingPos, FSizingOfs: Integer;
    FSortMarking:Boolean;
    FSumListRecalcing:Boolean;
    FTitleFont: TFont;
    FTitleImages: TCustomImageList;
    FTitleOffset, FIndicatorOffset: Byte;
    FTopLeftVisible:Boolean;
    FUpdateLock: Byte;
    FUserChange: Boolean;
    FVertScrollBar: TDBGridEhScrollBar;
    ThumbTracked:Boolean;
    FOnSelectionChange: TNotifyEvent;
    function GetCol: Longint;
    function AcquireFocus: Boolean;
    function GetDataSource: TDataSource;
    function GetFieldCount: Integer;
    function GetFields(FieldIndex: Integer): TField;
    function GetRowHeights(Index: Longint): Integer;
    function GetSelectedField: TField;
    function GetSelectedIndex: Integer;
    function IsActiveControl: Boolean;
    procedure CalcDrawInfoXYEh(var DrawInfo: TGridDrawInfoEh; UseWidth, UseHeight: Integer);
    procedure ChangeGridOrientation(RightToLeftOrientation: Boolean);
    procedure ClearSelection;
    procedure CMDeferLayout(var Message); message cm_DeferLayout;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CMExit(var Message: TMessage); message CM_EXIT;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure CMHintsShowPause(var Message: TCMHintShowPause); message CM_HINTSHOWPAUSE;
    procedure CMParentColorChanged(var Message: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure DataChanged;
    procedure DoSelection(Select: Boolean; Direction: Integer; MaxDirection,RowOnly: Boolean);
    procedure DrawEdgeEh(ACanvas:TCanvas; qrc: TRect; IsDown,IsSelected:Boolean; NeedLeft,NeedRight:Boolean);
    procedure EditingChanged;
    procedure FooterFontChanged(Sender: TObject);
    procedure InternalLayout;
    procedure MoveCol(RawCol, Direction: Integer; Select:Boolean);
    procedure ReadColumns(Reader: TReader);
    procedure RecordChanged(Field: TField);
    procedure SetAllowedSelections(const Value: TDBGridEhAllowedSelections);
    procedure SetCol(Value: Longint);
    procedure SetColumnDefValues(const Value: TColumnDefValuesEh);
    procedure SetColumns(Value: TDBGridColumnsEh);
    procedure SetDataSource(Value: TDataSource);
    procedure SetDrawMemoText(const Value: Boolean);
    procedure SetFlat(const Value: Boolean);
    procedure SetFooterColor(Value: TColor);
    procedure SetFooterFont(Value: TFont);
    procedure SetHorzScrollBar(const Value: TDBGridEhScrollBar);
    procedure SetIme;
    procedure SetOptions(Value: TDBGridOptions);
    procedure SetOptionsEh(const Value: TDBGridEhOptions);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetSelectedField(Value: TField);
    procedure SetSelectedIndex(Value: Integer);
    procedure SetSumList(const Value: TDBGridEhSumList);
    procedure SetTitleFont(Value: TFont);
    procedure SetTitleImages(const Value: TCustomImageList);
    procedure SetVertScrollBar(const Value: TDBGridEhScrollBar);
    procedure TitleFontChanged(Sender: TObject);
    procedure UpdateActive;
    procedure UpdateData;
    procedure UpdateIme;
    procedure UpdateRowCount;
    procedure UpdateScrollBar;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND; //tmp
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMIMEStartComp(var Message: TMessage); message WM_IME_STARTCOMPOSITION;
    procedure WMKillFocus(var Message: TMessage); message WM_KillFocus;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint(var Message: TMessage);  message WM_NCPAINT;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SetFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WriteColumns(Writer: TWriter);
    procedure DoOnSelectionChange;
  protected
    FAcquireFocus: Boolean;
    FAllowWordWrap: Boolean; // True if RowHeight + 3 > TextHeight
    FAntiSelection:Boolean;
    FAutoFitColWidths:Boolean;
    FColCellParamsEh: TColCellParamsEh;
    FDataTracking:Boolean;
    FDBGridEhState: TDBGridEhState;
    FDefaultRowChanged: Boolean;
    FDownMousePos: TPoint;
    FDrawMemoText: Boolean;
    FFooterRowCount: Integer;
    FFrozenCol:Integer;
    FFrozenCols: Integer;
    FHeadTree:THeadTreeNode;
    FHTitleMargin: Integer;
    FIndicatorPressed:Boolean;
    FInitColWidth:TList;
    FInplaceEditorButtonHeight: Integer;
    FInplaceEditorButtonWidth: Integer;
    FInplaceSearching:Boolean;
    FInplaceSearchingInProcess:Boolean;
    FInplaceSearchText:String;
    FInplaceSearchTimeOut:Integer;
    FInplaceSearchTimerActive:Boolean;
    FLeafFieldArr:PTLeafCol;
    FLockedBookmark:TBookmarkStr;
    FLockPaint:Boolean;
    FLookedOffset:Integer;
    FMarginText:Boolean;
    FMinAutoFitWidth:Integer;
    FMouseShift:TShiftState;
    FMoveMousePos: TPoint;
    FNewRowHeight: Integer;
    FOnCheckButton: TCheckTitleEhBtnEvent;
    FOnDrawFooterCell:TDrawFooterCellEvent;
    FOnGetBtnParams: TGetBtnEhParamsEvent;
    FOnTitleBtnClick: TTitleEhClickEvent;
    FPresedRecord:TBookMarkStr;
    FPressed: Boolean;
    FPressedCell:TGridCoord;
    FPressedCol: Longint;
    FRowLines: Integer;
    FRowSizingAllowed : Boolean;
    FSelectionAnchorSelected:Boolean;
    FSortMarkedColumns:TColumnsEhList;
    FSortMarkerImages:TImageList;
    FSumList:TDBGridEhSumList;
    FSwapButtons: Boolean;
    FTimerActive:Boolean;
    FTimerInterval:Integer;
    FTitleHeight: Integer;
    FTitleHeightFull: Integer;
    FTitleLines: Integer;
    FTracking: Boolean;
    FUpdateFields: Boolean;
    FUpdatingEditor: Boolean;
    FUseMultiTitle: Boolean;
    FVisibleColumns:TColumnsEhList;
    FVTitleMargin: Integer;
    function AcquireLayoutLock: Boolean;
    function AllowedOperationUpdate:Boolean;
    function CanEditAcceptKey(Key: Char): Boolean; override;
    function CanEditModify: Boolean; override;
    function CanEditModifyColumn(Index:Integer):Boolean;
    function CanEditModifyText: Boolean;
    function CanEditShow: Boolean; override;
    function CanSelectType(const Value: TDBGridEhSelectionType):Boolean;
    function CreateColumns: TDBGridColumnsEh; dynamic;
    function CreateEditor: TInplaceEdit; override;
    function DataToRawColumn(ACol: Integer): Integer;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function FrozenSizing(X, Y: Integer): Boolean;
    function GetColField(DataCol: Integer): TField;
    function GetColWidths(Index: Longint): Integer;
    function GetEditLimit: Integer; override;
    function GetEditMask(ACol, ARow: Longint): string; override;
    function GetEditText(ACol, ARow: Longint): string; override;
    function GetFieldValue(ACol: Integer): string;
    function GetFooterRowCount: Integer;
    function GetRowHeight: Integer;
    function GetRowLines: Integer;
    function HighlightCell(DataCol, DataRow: Integer; const Value: string;
      AState: TGridDrawState): Boolean; virtual;
    function InplaceEditorVisible:Boolean;
    function RawToDataColumn(ACol: Integer): Integer;
    function ReadTitleHeight: Integer;
    function ReadTitleLines: Integer;
    function SetChildTreeHeight(ANode:THeadTreeNode):Integer;
    function StdDefaultRowHeight: Integer;
    function StoreColumns: Boolean;
    function VisibleDataRowCount: Integer;
    procedure BeginLayout;
    procedure BeginUpdate;
    procedure CalcDrawInfoEh(var DrawInfo: TGridDrawInfoEh);
    procedure CalcFixedInfoEh(var DrawInfo: TGridDrawInfoEh);
    procedure CalcFrozenSizingState(X, Y: Integer; var State: TDBGridEhState;
      var Index: Longint; var SizingPos, SizingOfs: Integer);
    procedure CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer;
      var FixedInfo: TGridDrawInfo); override;
    procedure CancelLayout;
    procedure CellClick(Column: TColumnEh); dynamic;
    procedure ChangeScale(M, D: Integer); override;
    procedure CheckTitleButton(ACol: Longint; var Enabled: Boolean); dynamic;
    procedure ClearPainted(node:THeadTreeNode);
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CancelMode;
    procedure ColEnter; dynamic;
    procedure ColExit; dynamic;
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
    procedure ColWidthsChanged; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DeferLayout;
    procedure DefineFieldMap; virtual;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoSortMarkingChanged; dynamic;
    procedure DoTitleClick(ACol: Longint; AColumn: TColumnEh); dynamic;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumnEh; State: TGridDrawState); dynamic;
    procedure DrawDataCell(const Rect: TRect; Field: TField; State: TGridDrawState); dynamic; { obsolete }
    procedure DrawSizingLine(HorzGridBoundary, VertGridBoundary: Integer);
    procedure EditButtonClick; dynamic;
    procedure EndLayout;
    procedure EndUpdate;
    procedure GetCellParams(Column: TColumnEh; AFont: TFont;
      var Background: TColor; State: TGridDrawState ); dynamic;
    procedure GetFooterParams(DataCol, Row: Longint; Column: TColumnEh; AFont: TFont;
      var Background: TColor; var Alignment : TAlignment; State: TGridDrawState; var Text:String); dynamic;
    procedure InvalidateEditor;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure LayoutChanged; virtual;
    procedure LinkActive(Value: Boolean); virtual;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure PaintButtonControl(DC: HDC; ARect:TRect;ParentColor:TColor;
               Style:TDrawButtonControlStyleEh; DownButton:Integer;
               Flat,Active,Enabled:Boolean; State: TCheckBoxState);
    procedure RecreateInplaceSearchIndicator;
    procedure ResetTimer(Interval: Integer);
    procedure RestoreColumnsLayoutProducer(ARegIni: TObject; Section: String;
      RestoreParams:TColumnEhRestoreParams);
    procedure RestoreGridLayoutProducer(ARegIni: TObject; Section: String;
      RestoreParams:TDBGridEhRestoreParams);
    procedure RowHeightsChanged; override;
    procedure SaveColumnsLayoutProducer(ARegIni: TObject; Section: String; DeleteSection: Boolean);
    procedure SaveGridLayoutProducer(ARegIni: TObject; Section: String; DeleteSection: Boolean);
    procedure Scroll(Distance: Integer); virtual;
    procedure SetColumnAttributes; virtual;
    procedure SetColWidths(Index: Longint; Value: Integer);
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    procedure SetFooterRowCount(Value: Integer);
    procedure SetFrozenCols(Value: Integer);
    procedure SetRowHeight(Value: Integer);
    procedure SetRowLines(Value: Integer);
    procedure SetRowSizingAllowed(Value:Boolean);
    procedure StartInplaceSearch(ss:String; TimeOut:Integer; InpsDirection:TInpsDirectionEh);
    procedure StartInplaceSearchTimer;
    procedure StopInplaceSearch;
    procedure StopInplaceSearchTimer;
    procedure StopTimer;
    procedure StopTracking;
    procedure SumListChanged(Sender: TObject);
    procedure SumListRecalcAll(Sender: TObject);
    procedure TimedScroll(Direction: TGridScrollDirection); override;
    procedure TimerScroll;
    procedure TitleClick(Column: TColumnEh); dynamic;
    procedure TopLeftChanged; override;
    procedure TrackButton(X, Y: Integer);
    procedure WMCancelMode(var Message: TMessage); message WM_CANCELMODE;
    procedure WndProc(var Message: TMessage); override;
    procedure WriteAutoFitColWidths(Value:Boolean);
    procedure WriteCellText(ACanvas: TCanvas; ARect: TRect; FillRect:Boolean; DX, DY: Integer;
                 Text: string; Alignment: TAlignment; Layout: TTextLayout; MultyL:Boolean;
                 EndEllipsis:Boolean; LeftMarg, RightMarg:Integer);
    procedure WriteHTitleMargin(Value: Integer);
    procedure WriteMarginText(IsMargin:Boolean);
    procedure WriteMinAutoFitWidth(Value:Integer);
    procedure WriteTitleHeight(th: Integer);
    procedure WriteTitleLines(tl: Integer);
    procedure WriteUseMultiTitle(Value:Boolean);
    procedure WriteVTitleMargin(Value: Integer);
    property DataLink: TGridDataLinkEh read FDataLink;
    property DefaultDrawing: Boolean read FDefaultDrawing write FDefaultDrawing default True;
    property FooterColor: TColor read FFooterColor write SetFooterColor;
    property FooterFont: TFont read FFooterFont write SetFooterFont;
    property LayoutLock: Byte read FLayoutLock;
    property OnCellClick: TDBGridEhClickEvent read FOnCellClick write FOnCellClick;
    property OnColEnter: TNotifyEvent read FOnColEnter write FOnColEnter;
    property OnColExit: TNotifyEvent read FOnColExit write FOnColExit;
    property OnColumnMoved: TMovedEvent read FOnColumnMoved write FOnColumnMoved;
    property OnDrawColumnCell: TDrawColumnEhCellEvent read FOnDrawColumnCell write FOnDrawColumnCell;
    property OnDrawDataCell: TDrawDataCellEvent read FOnDrawDataCell write FOnDrawDataCell; { obsolete }
    property OnEditButtonClick: TNotifyEvent read FOnEditButtonClick write FOnEditButtonClick;
    property OnTitleClick: TDBGridEhClickEvent read FOnTitleClick write FOnTitleClick;
    property ParentColor default False;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property SelectedRows: TBookmarkListEh read FBookmarks;
    property UpdateLock: Byte read FUpdateLock;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CellRect(ACol, ARow: Longint): TRect;
    function CheckCopyAction:Boolean;
    function CheckCutAction:Boolean;
    function CheckDeleteAction:Boolean;
    function CheckPasteAction:Boolean;
    function CheckSelectAllAction:Boolean;
    function DataRect:TRect;
    function DataRowCount:Integer;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function GetFooterValue(Row: Integer; Column: TColumnEh): String; virtual;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function ValidFieldIndex(FieldIndex: Integer): Boolean;
    procedure DefaultDrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumnEh; State: TGridDrawState);
    procedure DefaultDrawDataCell(const Rect: TRect; Field: TField; State: TGridDrawState); { obsolete }
    procedure DefaultDrawFooterCell(const Rect: TRect; DataCol, Row: Integer;
      Column: TColumnEh; State: TGridDrawState);
    procedure DefaultHandler(var Msg); override;
    procedure InvalidateFooter;
    procedure RestoreBookmark;
    procedure RestoreColumnsLayout(ACustIni: TCustomIniFile; Section:String;
      RestoreParams:TColumnEhRestoreParams); overload;
    procedure RestoreColumnsLayout(ARegIni: TRegIniFile; RestoreParams:TColumnEhRestoreParams); overload;
    procedure RestoreColumnsLayoutIni(IniFileName: String; Section: String;
      RestoreParams:TColumnEhRestoreParams);
    procedure RestoreGridLayout(ARegIni: TCustomIniFile; Section:String;
      RestoreParams:TDBGridEhRestoreParams); overload;
    procedure RestoreGridLayout(ARegIni: TRegIniFile; RestoreParams:TDBGridEhRestoreParams); overload;
    procedure RestoreGridLayoutIni(IniFileName: String; Section: String;
      RestoreParams:TDBGridEhRestoreParams);
    procedure SaveBookmark;
    procedure SaveColumnsLayout(ACustIni: TCustomIniFile; Section:String); overload;
    procedure SaveColumnsLayout(ARegIni: TRegIniFile); overload;
    procedure SaveColumnsLayoutIni(IniFileName: String; Section: String; DeleteSection: Boolean);
    procedure SaveGridLayout(ACustIni: TCustomIniFile; Section:String); overload;
    procedure SaveGridLayout(ARegIni: TRegIniFile); overload;
    procedure SaveGridLayoutIni(IniFileName: String; Section: String; DeleteSection: Boolean);
    procedure SetSortMarkedColumns;
    property AllowedOperations: TDBGridEhAllowedOperations read FAllowedOperations
      write FAllowedOperations default [alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh];
    property AllowedSelections: TDBGridEhAllowedSelections read FAllowedSelections
      write SetAllowedSelections default [gstRecordBookmarks .. gstAll];
    property AutoFitColWidths: Boolean read FAutoFitColWidths
      write WriteAutoFitColWidths default False;
    property Canvas;
    property Col read GetCol write SetCol;
    property ColumnDefValues: TColumnDefValuesEh read FColumnDefValues write SetColumnDefValues;
    property Columns: TDBGridColumnsEh read FColumns write SetColumns;
    property Ctl3D;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DrawMemoText:Boolean read FDrawMemoText write SetDrawMemoText default false;
    property EditActions: TDBGridEhEditActions read FEditActions write FEditActions default [];
    property EditorMode;
    property FieldCount: Integer read GetFieldCount;
    property Fields[FieldIndex: Integer]: TField read GetFields;
    property FixedColor;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
    property FooterRowCount: Integer read GetFooterRowCount write SetFooterRowCount default 0;
    property FrozenCols: Integer read FFrozenCols write SetFrozenCols default 0;
    property HeadTree: THeadTreeNode read FHeadTree;
    property HorzScrollBar: TDBGridEhScrollBar read FHorzScrollBar write SetHorzScrollBar;
    property IndicatorOffset: Byte read FIndicatorOffset;
    property InplaceEditor;
    property LeafFieldArr: PTLeafCol read FLeafFieldArr;
    property LeftCol;
    property MinAutoFitWidth: Integer read FMinAutoFitWidth write WriteMinAutoFitWidth default 0;
    property OnCheckButton: TCheckTitleEhBtnEvent read FOnCheckButton write FOnCheckButton;
    property OnColWidthsChanged: TNotifyEvent read FOnColWidthsChanged write FOnColWidthsChanged;
    property OnDrawFooterCell:TDrawFooterCellEvent read FOnDrawFooterCell write FOnDrawFooterCell;
    property OnGetBtnParams: TGetBtnEhParamsEvent read FOnGetBtnParams write FOnGetBtnParams;
    property OnGetCellParams: TGetCellEhParamsEvent read FOnGetCellParams write FOnGetCellParams;
    property OnGetFooterParams: TGetFooterParamsEvent read FOnGetFooterParams write FOnGetFooterParams;
    property OnSortMarkingChanged: TNotifyEvent read FOnSortMarkingChanged write FOnSortMarkingChanged;
    property OnSumListRecalcAll: TNotifyEvent read FOnSumListRecalcAll write FOnSumListRecalcAll;
    property OnTitleBtnClick: TTitleEhClickEvent read FOnTitleBtnClick write FOnTitleBtnClick;
    property Options: TDBGridOptions read FOptions write SetOptions
      default [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines,
      dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit];
    property OptionsEh: TDBGridEhOptions read FOptionsEh write SetOptionsEh
      default [dghFixed3D,dghHighlightFocus,dghClearSelection];
    property Row;
    property RowHeight: Integer read GetRowHeight write SetRowHeight default 0;
    property RowLines: Integer read GetRowLines write SetRowLines default 0;
    property RowSizingAllowed:Boolean read FRowSizingAllowed write SetRowSizingAllowed default False;
    property SelectedField: TField read GetSelectedField write SetSelectedField;
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    property Selection:TDBGridEhSelection read FSelection;
    property SortMarkedColumns: TColumnsEhList read FSortMarkedColumns write FSortMarkedColumns;
    property SumList:TDBGridEhSumList read FSumList write SetSumList;
    property TimerActive: Boolean read FTimerActive;
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property TitleHeight: Integer read ReadTitleHeight write WriteTitleHeight default 0;
    property TitleImages:TCustomImageList read FTitleImages write SetTitleImages;
    property TitleLines: Integer read ReadTitleLines write WriteTitleLines default 0;
    property TitleOffset: Byte read FTitleOffset;
    property UseMultiTitle: Boolean read FUseMultiTitle write WriteUseMultiTitle default False;
    property VertScrollBar: TDBGridEhScrollBar read FVertScrollBar write SetVertScrollBar;
    property VisibleColCount;
    property VisibleColumns: TColumnsEhList read FVisibleColumns write FVisibleColumns;
    property VisibleRowCount;
    property VTitleMargin: Integer read FVTitleMargin write WriteVTitleMargin default 10;
//    property HTitleMargin: Integer read FHTitleMargin write WritEhTitleMargin default 0;
  end;

{ TDBGridEh }

  TDBGridEh = class(TCustomDBGridEh)
  public
    property GridHeight;
    property RowCount;
    property Canvas;
    property SelectedRows;
  published
    property Align;
    property AllowedOperations;
    property AllowedSelections;
    property Anchors;
    property AutoFitColWidths;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property ColumnDefValues;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DrawMemoText;
    property EditActions;
    property Enabled;
    property FixedColor;
    property Flat;
    property Font;
    property FooterColor;
    property FooterFont;
    property FooterRowCount;
    property FrozenCols;
    property HorzScrollBar;
    property ImeMode;
    property ImeName;
    property MinAutoFitWidth;
    property Options;
    property OptionsEh;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RowHeight;
    property RowLines;
    property RowSizingAllowed;
    property ShowHint;
    property SumList;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property TitleHeight;
    property TitleImages;
    property TitleLines;
    property UseMultiTitle;
    property VertScrollBar;
    property Visible;
    property VTitleMargin;
//    property HTitleMargin;
    property OnCellClick;
    property OnCheckButton;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnColWidthsChanged;
    {$IFDEF EH_LIB_5}
    property OnContextPopup;
    {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawColumnCell;
    property OnDrawDataCell;  { obsolete }
    property OnDrawFooterCell;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetBtnParams;
    property OnGetCellParams;
    property OnGetFooterParams;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnSortMarkingChanged;
    property OnStartDock;
    property OnStartDrag;
    property OnSumListRecalcAll;
    property OnTitleBtnClick;
    property OnTitleClick;
    property OnSelectionChange;
  end;

{const
  IndicatorWidth = 11;}
var
  SortMarkerFont :TFont;

  DBGridEhInplaceSearchKey :TShortCut;
  DBGridEhInplaceSearchNextKey :TShortCut;
  DBGridEhInplaceSearchPriorKey :TShortCut;
  DBGridEhInplaceSearchTimeOut: Integer; // in millisecond
  DBGridEhInplaceSearchColor: TColor;
  DBGridEhInplaceSearchTextColor: TColor;

const
  ColSelectionAreaHeight : Integer = 7;

procedure WriteTextEh(ACanvas: TCanvas;      // Canvas
                      ARect: TRect;          // Draw rect and ClippingRect
                      FillRect:Boolean;      // Fill rect Canvas.Brash.Color
                      DX, DY: Integer;       // InflateRect(Rect, -DX, -DY) for text
                      Text: string;          // Draw text
                      Alignment: TAlignment; // Text alignment
                      Layout: TTextLayout;   // Text layout
                      MultyL:Boolean;        // Word break
                      EndEllipsis:Boolean;   // Truncate long text by ellipsis
                      LeftMarg,              // Left margin
                      RightMarg:Integer);    // Right margin

function WriteTextVerticalEh(ACanvas:TCanvas;
                          ARect: TRect;          // Draw rect and ClippingRect
                          FillRect:Boolean;      // Fill rect Canvas.Brash.Color
                          DX, DY: Integer;       // InflateRect(Rect, -DX, -DY) for text
                          Text: string;          // Draw text
                          Alignment: TAlignment; // Text alignment
                          Layout: TTextLayout;   // Text layout
                          EndEllipsis:Boolean;   // Truncate long text by ellipsis
                          CalcTextExtent:Boolean   //
                          ):Integer;

implementation

uses DBConsts, Dialogs, Comctrls, CommCtrl, DBGridEhImpExp, Clipbrd;

{$R DBGRIDEH.RES}

const
  bmArrow = 'DBGARROWEH';
  bmEdit = 'DBEDITEH';
  bmInsert = 'DBINSERTEH';
  bmMultiDot = 'DBMULTIDOTEH';
  bmMultiArrow = 'DBMULTIARROWEH';
  bmSmDown = 'DBSMDOWNEH';
  bmSmUp = 'DBSMUPEH';
  bmEditWhite = 'DBGARROWEHW';
  MaxMapSize = (MaxInt div 2) div SizeOf(Integer);  { 250 million }

var
  hcrDownCurEh: HCursor = 0;
  hcrRightCurEh: HCursor = 0;
  hcrLeftCurEh: HCursor = 0;

var
  FCheckBoxWidth, FCheckBoxHeight: Integer;

function FieldsCanModify(Fields: TList): Boolean;
var i:Integer;
begin
  Result := True;
  for i := 0 to Fields.Count-1 do
    if not TField(Fields[i]).CanModify then
    begin
      Result := False;
      Exit;
    end;
end;

procedure GetCheckSize;
begin
  with TBitmap.Create do
    try
      Handle := LoadBitmap(0, PChar(32759));
      FCheckBoxWidth := Width div 4;
      FCheckBoxHeight := Height div 3;
    finally
      Free;
    end;
end;

{ Error reporting }


procedure RaiseGridError(const S: string);
begin
  raise EInvalidGridOperation.Create(S);
end;

procedure KillMessage(Wnd: HWnd; Msg: Integer);
// Delete the requested message from the queue, but throw back
// any WM_QUIT msgs that PeekMessage may also return
var
  M: TMsg;
begin
  M.Message := 0;
  if PeekMessage(M, Wnd, Msg, Msg, pm_Remove) and (M.Message = WM_QUIT) then
    PostQuitMessage(M.wparam);
end;

type
  TCharSet = Set of Char;

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string; forward;

function GetDefaultSection(Component: TComponent): string;
var
  F: TCustomForm;
  Owner: TComponent;
begin
  if Component <> nil then
  begin
    if Component is TCustomForm then Result := Component.ClassName
    else
    begin
      Result := Component.Name;
      if Component is TControl then
      begin
        F := GetParentForm(TControl(Component));
        if F <> nil then Result := F.ClassName + Result
        else
        begin
          if TControl(Component).Parent <> nil then
            Result := TControl(Component).Parent.Name + Result;
        end;
      end
      else
      begin
        Owner := Component.Owner;
        if Owner is TForm then
          Result := Format('%s.%s', [Owner.ClassName, Result]);
      end;
    end;
  end else Result := '';
end;

function Max(A, B: Longint): Longint;
begin
  if A > B
    then Result := A
    else Result := B;
end;

function Min(A, B: Longint): Longint;
begin
  if A < B
    then Result := A
    else Result := B;
end;

function iif(Condition:Boolean;V1,V2:Integer):Integer;
begin
  if (Condition) then Result := V1 else Result := V2;
end;

procedure GridInvalidateRow(Grid: TCustomDBGridEh; Row: Longint);
var
  I: Longint;
begin
  for I := 0 to Grid.ColCount - 1 do Grid.InvalidateCell(I, Row);
end;

{function DefineCursor(Identifier: PChar): TCursor;
var Handle:HCursor;
begin
  Handle := LoadCursor(hInstance, Identifier);
  if Handle = 0 then raise EOutOfResources.Create('Cannot load cursor resource');
  for Result := 1 to High(TCursor) do
    if Screen.Cursors[Result] = Screen.Cursors[crArrow]  then
    begin
      Screen.Cursors[Result] := Handle;
      Exit;
    end;
  raise EOutOfResources.Create('Too many user-defined cursors');
end;}

function GetTextWidth(Canvas:TCanvas; Text:String):Integer;
var ARect:TRect;
    uFormat:Integer;
begin
  uFormat := DT_CALCRECT or DT_LEFT or DT_NOPREFIX;
  ARect := Rect(0,0,1,0);
  DrawText(Canvas.Handle, PChar(Text), Length(Text), ARect, uFormat);
  Result := ARect.Right - ARect.Left;
end;

function PointInGridRect(Col, Row: Longint; const Rect: TGridRect): Boolean;
begin
  Result := (Col >= Rect.Left) and (Col <= Rect.Right) and (Row >= Rect.Top)
    and (Row <= Rect.Bottom);
end;

{ TDBGridInplaceEdit }

{ TDBGridInplaceEdit adds support for a button on the in-place editor,
  which can be used to drop down a table-based lookup list, a stringlist-based
  pick list, or (if button style is esEllipsis) fire the grid event
  OnEditButtonClick.  }

const
  InitRepeatPause:Integer = 500;  { pause before repeat timer (ms) }
  RepeatPause:Integer     = 100;  { pause before hint window displays (ms)}

type
  TEditStyle = (esSimple, esEllipsis, esPickList, esDataList, esDateCalendar ,esUpDown, esDropDown);
  TPopupListbox = class;
  TPopupMonthCalendar = class;

  TDBGridInplaceEdit = class(TInplaceEdit)
  private
    FActiveList: TWinControl;
    FButtonHeight:Integer;
    FButtonWidth: Integer;
    FDataList: TPopupDataListEh;
    FDownButton: Integer;
    FEditStyle: TEditStyle;
    FListVisible: Boolean;
    FLockCloseList:Boolean;
    FLookupSource: TDatasource;
    FPickList: TPopupListbox;
    FPopupMonthCalendar: TPopupMonthCalendar;
    FPressed: Boolean;
    FTimerActive:Boolean;
    FTimerInterval:Integer;
    FTracking: Boolean;
    FWordWrap: Boolean;
    FReadOnlyStored: Boolean;
    function DeleteSeletedText:String;
    function GetColumn: TColumnEh;
    function GetGrid: TCustomDBGridEh;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CancelMode;
    procedure ListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LocateListText;
    procedure ResetTimer(Interval: Integer);
    procedure SetEditStyle(Value: TEditStyle);
    procedure SetWordWrap(const Value: Boolean);
    procedure StopTimer;
    procedure StopTracking;
    procedure TrackButton(X,Y: Integer);
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure WMCancelMode(var Message: TMessage); message WM_CancelMode;
    procedure WMKillFocus(var Message: TMessage); message WM_KillFocus;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message wm_LButtonDblClk;
    procedure WMPaint(var Message: TWMPaint); message wm_Paint;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SetCursor;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
  protected
    procedure BoundsChanged; override;
    procedure CloseUp(Accept: Boolean);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DefaultHandler(var Message); override;
    procedure DoDropDownKeys(var Key: Word; Shift: TShiftState);
    procedure DropDown;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure PaintWindow(DC: HDC); override;
    procedure UpdateContents; override;
    procedure WndProc(var Message: TMessage); override;
    property ActiveList: TWinControl read FActiveList write FActiveList;
    property Column: TColumnEh read GetColumn;
    property DataList: TPopupDataListEh read FDataList;
    property EditStyle: TEditStyle read FEditStyle write SetEditStyle;
    property Grid: TCustomDBGridEh read GetGrid;
    property PickList: TPopupListbox read FPickList;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
  public
    constructor Create(Owner: TComponent); override;
  end;

{ TPopupListbox }

  TPopupListbox = class(TCustomListbox)
  private
    FOnResize: TNotifyEvent;
    FSearchText: String;
    FSearchTickCount: Longint;
    FSizeGrip:TSizeGripEh;
    FSizeGripResized:Boolean;
    function  CheckNewSize(var NewWidth, NewHeight: Integer): Boolean;
    procedure CMSetSizeGripChangePosition(var Message:TMessage); message cm_SetSizeGripChangePosition;
    procedure UpdateSizeGripPosition(Sender: TObject);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    //procedure SizeGripResized(Sender:TObject);
  protected
    constructor Create(Owner: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateSizeGrip;
    procedure CreateWnd; override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure ResizeEh; dynamic;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
  end;

{ TPopupMonthCalendar }

  TPopupMonthCalendar = class(TMonthCalendar)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

{ TPopupListbox }

constructor TPopupListBox.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  OnResize := UpdateSizeGripPosition;
  CreateSizeGrip;
end;

procedure TPopupListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_BORDER or WS_CLIPCHILDREN;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TPopupListbox.CreateWnd;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TPopupListbox.Keypress(var Key: Char);
var
  TickCount: Integer;
begin
  case Key of
    #8, #27: FSearchText := '';
    #32..#255:
      begin
        TickCount := GetTickCount;
        if TickCount - FSearchTickCount > 2000 then FSearchText := '';
        FSearchTickCount := TickCount;
        if Length(FSearchText) < 32 then FSearchText := FSearchText + Key;
        SendMessage(Handle, LB_SelectString, WORD(-1), Longint(PChar(FSearchText)));
        Key := #0;
      end;
  end;
  inherited Keypress(Key);
end;

procedure TPopupListbox.MouseMove(Shift: TShiftState; X, Y: Integer);
var Index:Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if [ssLeft, ssRight, ssMiddle] * Shift = [] then
  begin
    Index := ItemAtPos(Point(X,Y),True);
    if Index >= 0 then ItemIndex := Index;
  end;
end;

procedure TPopupListbox.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  TDBGridInPlaceEdit(Owner).CloseUp((X >= 0) and (Y >= 0) and
      (X < Width) and (Y < Height));
end;

procedure TPopupListbox.CreateSizeGrip;
begin
  FSizeGrip := TSizeGripEh.Create(Self);
  with FSizeGrip do
  begin
    Parent := Self;
    TriangleWindow := True;
  end;
end;

{procedure TPopupListbox.SizeGripResized(Sender:TObject);
begin
  FSizeGripResized := true;
end;}

procedure TPopupListbox.UpdateSizeGripPosition(Sender: TObject);
begin
  if FSizeGrip <> nil then FSizeGrip.UpdatePosition;
end;

procedure TPopupListbox.CMSetSizeGripChangePosition(var Message:TMessage);
begin
  if FSizeGrip <> nil then FSizeGrip.ChangePosition(TSizeGripChangePosition(Message.WParam));
end;

procedure TPopupListbox.WMWindowPosChanging(var Message: TWMWindowPosChanging);
begin
  if ComponentState * [csReading, csDestroying] = [] then
    with Message.WindowPos^ do
      if (flags and SWP_NOSIZE = 0) and not CheckNewSize(cx, cy) then
        flags := flags or SWP_NOSIZE;
  inherited;
end;

function TPopupListbox.CheckNewSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if NewWidth < GetSystemMetrics(SM_CXVSCROLL) then
    NewWidth := GetSystemMetrics(SM_CXVSCROLL);
  if NewHeight < GetSystemMetrics(SM_CYVSCROLL) then
    NewHeight := GetSystemMetrics(SM_CYVSCROLL);
end;

procedure TPopupListbox.ResizeEh;
begin
  if Assigned(FOnResize) then FOnResize(Self);
  FSizeGripResized := True;
end;

procedure TPopupListbox.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csLoading in ComponentState) then ResizeEh;
end;

{ TPopupMonthCalendar }

procedure TPopupMonthCalendar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TPopupMonthCalendar.CreateWnd;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TPopupMonthCalendar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var MCHInfo:TMCHitTestInfo;
begin
  inherited MouseUp(Button, Shift, X, Y);
  MCHInfo.cbSize := SizeOf(TMCHitTestInfo);
  MCHInfo.pt.x := X;
  MCHInfo.pt.y := Y;
  MonthCal_HitTest(Handle,MCHInfo);
  if ((MCHInfo.uHit and MCHT_CALENDARDATE) > 0) and  (MCHInfo.uHit <> MCHT_CALENDARDAY) and
   (MCHInfo.uHit <> MCHT_TITLEBTNNEXT) and (MCHInfo.uHit <> MCHT_TITLEBTNPREV) then
    TDBGridInPlaceEdit(Owner).CloseUp(True)
  else if (MCHInfo.uHit and MCHT_NOWHERE > 0) then
    TDBGridInPlaceEdit(Owner).CloseUp(False)
  else if not ((X >= 0) and (Y >= 0) and
      (X < Width) and (Y < Height)) then
    TDBGridInPlaceEdit(Owner).CloseUp(False);
end;

{ TDBGridInplaceEdit }

constructor TDBGridInplaceEdit.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FLookupSource := TDataSource.Create(Self);
  FEditStyle := esSimple;
end;

function TDBGridInplaceEdit.DeleteSeletedText:String;
begin
  Result := Text;
  Delete(Result,SelStart+1,SelLength);
end;

procedure TDBGridInplaceEdit.BoundsChanged;
var
  R: TRect;
begin
  if Grid.Flat
    then SetRect(R, 2, 1, Width - 2, Height-1)
    else SetRect(R, 2, 2, Width - 2, Height);
  if FEditStyle <> esSimple then
    if Grid.UseRightToLeftAlignment
      then Inc(R.Left, FButtonWidth)
      else Dec(R.Right, FButtonWidth);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@R));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  if SysLocale.FarEast
    then SetImeCompositionWindow(Font, R.Left, R.Top);
  if Height > Round(FButtonWidth * 3 / 2)
    then FButtonHeight := FButtonWidth
    else FButtonHeight := Height;
end;

procedure TDBGridInplaceEdit.CloseUp(Accept: Boolean);
var
  MasterFields: TList;
  ListValue: Variant;
  CurColumn:TColumnEh;
  CanChange:Boolean;
begin
  CurColumn := Grid.Columns[Grid.SelectedIndex];
  if FListVisible then
  begin
    if FLockCloseList then Exit;
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    if FActiveList = FDataList then
    begin
      ListValue := FDataList.KeyValue;
      if FDataList.SizeGripResized then
      begin
        CurColumn.DropDownRows := FDataList.RowCount;
        CurColumn.DropDownWidth := FDataList.Width;
      end;
    end else if FActiveList = FPopupMonthCalendar then
    begin //MonthCalendar
    end else
    begin
      if FPickList.ItemIndex <> -1 then
      begin
        if Assigned(CurColumn.KeyList)  and (CurColumn.KeyList.Count > 0)
          then ListValue := CurColumn.KeyList.Strings[FPicklist.ItemIndex]
          else ListValue := FPickList.Items[FPicklist.ItemIndex];
      end;
      if PickList.FSizeGripResized then
      begin
        CurColumn.DropDownRows := PickList.ClientHeight div FPickList.ItemHeight;
        CurColumn.DropDownWidth := PickList.Width;
      end;
    end;
    SetWindowPos(FActiveList.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    //FActiveList.Visible := False;
    FListVisible := False;
    if Assigned(FDataList) then
      FDataList.ListSource := nil;
    FLookupSource.Dataset := nil;
    Invalidate;
    if Accept then
    begin
      if FActiveList = FDataList then  // Lookup
        with Grid, Columns[SelectedIndex].Field do
        begin
          MasterFields := TList.Create;
          try
            Dataset.GetFieldList(MasterFields,KeyFields);
            if FieldsCanModify(MasterFields) and CurColumn.CanModify(True) then
            begin
              DataSet.Edit;
              try
                CanChange := Grid.Datalink.Editing;
                if CanChange then
                begin
                  Grid.Datalink.Modified;
                  //Dataset.FieldValues[KeyFields] := ListValue;
                  Grid.FEditKeyValue := ListValue;
                  Grid.FEditText := FDataList.SelectedItem;
                  //MasterField.Value := ListValue;
                end;
              except
                 on Exception do
                 begin
                   Self.Text := CurColumn.Field.Text + ' '; //May be delphi bag. But without ' ' don't assign
                   raise;
                 end;
              end;
              Self.Text := FDataList.SelectedItem;
              SelectAll;
            end;
          finally
            MasterFields.Free;
          end;
        end
      else
      if (FActiveList = FPopupMonthCalendar) then
      begin
        with Grid, CurColumn.Field do
          if CurColumn.CanModify(True) then
          begin
            DataSet.Edit;
            AsDateTime := FPopupMonthCalendar.Date;
          end;
      end
      else
        if (not VarIsNull(ListValue)) and {dddEditCanModify}Grid.CanEditModifyText  then
          with Grid, CurColumn.Field do
            if Assigned(CurColumn) and Assigned(CurColumn.KeyList)  and (CurColumn.KeyList.Count > 0) then
            begin
              if (FPicklist.ItemIndex >= 0) then
              begin
                Self.Text := FPickList.Items[FPicklist.ItemIndex];
                Grid.FEditText := Self.Text;
              end
            end else
            begin
              Self.Text := ListValue;
              Grid.FEditText := ListValue;
            end;
    end else if FActiveList = FDataList then
      Text := Grid.FEditText
    else if FActiveList = FPickList then
      if CurColumn.GetColumnType = ctKeyPickList then
      begin
        Text := Grid.FEditText;
      end else
        Text := Grid.FEditText;
  end;
end;

procedure TDBGridInplaceEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if WordWrap then
    Params.Style:=Params.Style and (not ES_AUTOHSCROLL)  or ES_MULTILINE  or ES_LEFT;
  if Grid.Flat then
    FButtonWidth := FlatButtonWidth
  else
    FButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
end;

procedure TDBGridInplaceEdit.DoDropDownKeys(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP, VK_DOWN:
      if ssAlt in Shift then
      begin
        if FListVisible then CloseUp(True) else DropDown;
        Key := 0;
      end;
    VK_RETURN, VK_ESCAPE:
      if FListVisible and not (ssAlt in Shift) then
      begin
        CloseUp(Key = VK_RETURN);
        Key := 0;
      end
      else if not FListVisible and (Key = VK_RETURN) and ([ssCtrl] = Shift) then
      begin
        DropDown;
        Key := 0;
      end;
  end;
end;

procedure TDBGridInplaceEdit.DropDown;
var
  P: TPoint;
  I,J,Y: Integer;
  Column: TColumnEh;
  TM: TTextMetric;
  RestoreCanvas: Boolean;
  fList:TList;
  dlcw:Integer;
  WorkArea,R: TRect;
begin
  if not FListVisible and Assigned(FActiveList) then
  begin
    FActiveList.Width := Width;
    with Grid do
      Column := Columns[SelectedIndex];
    if FActiveList = FDataList then //DataList
    with Column.Field do
    begin
      //for delete FDataList.FSizeGrip.Visible := Column.DropDownSizing;
      FDataList.Color := Color;
      FDataList.Font := Font;
//      FDataList.RowCount := Column.DropDownRows;
      if LookupDataSet.IsSequenced and
        (LookupDataSet.RecordCount > 0) and
        (Integer(Column.DropDownRows) > LookupDataSet.RecordCount)
      then
        FDataList.RowCount := LookupDataSet.RecordCount
      else
        FDataList.RowCount := Column.DropDownRows;
      FDataList.ShowTitles := Column.DropDownShowTitles;
      FLookupSource.DataSet := LookupDataSet;
      FDataList.KeyField := LookupKeyFields;
//ddd      FDataList.ListField := {ddd LookupResultField}Column.LookupDisplayFields;
      FDataList.ListFieldIndex := 0;
      if (Column.DropDownWidth = -1) then
      begin
        RestoreCanvas := not HandleAllocated;
        if RestoreCanvas then
          Grid.Canvas.Handle := GetDC(0);
        try
          fList := TList.Create;
          try
            LookupDataSet.GetFieldList(fList,Column.LookupDisplayFields);
            Grid.Canvas.Font := Self.Font;
            GetTextMetrics(Grid.Canvas.Handle, TM);
            dlcw := 0;
            for i := 0 to fList.Count - 1 do begin
              Inc(dlcw,TField(fList[i]).DisplayWidth * (Grid.Canvas.TextWidth('0') - TM.tmOverhang)
                                          + TM.tmOverhang + 4);
              if (TField(fList[i]).FieldName = LookupResultField) then FDataList.ListFieldIndex := i;
            end;
            FDataList.ClientWidth := dlcw;
            if (FDataList.Width < Self.Width) then FDataList.Width := Self.Width;
          finally
            fList.Free;
          end;
        finally
          if RestoreCanvas then
          begin
            ReleaseDC(0,Grid.Canvas.Handle);
            Grid.Canvas.Handle := 0;
          end;
        end
      end
      else if (Column.DropDownWidth > 0) then
        FDataList.ClientWidth := Column.DropDownWidth;
      FDataList.ListField := Column.LookupDisplayFields;  // Assignment ListField must be after ListFieldIndex
      FDataList.ListSource := FLookupSource;
      FDataList.KeyValue := Grid.FEditKeyValue {DataSet.FieldByName(KeyFields).Value ddd};
{      J := Column.DefaultWidth;
      if J > FDataList.ClientWidth then
        FDataList.ClientWidth := J;
}    end
    else
    if (FActiveList = FPopupMonthCalendar) then begin
      FPopupMonthCalendar.Color := Color;
      FPopupMonthCalendar.Font := Font;
      {try
        FPopupMonthCalendar.Date := StrToDate(Text);
      except
        FPopupMonthCalendar.Date := Grid.Columns[CurColumn.Field.AsDateTime;
      end;}
      try
        if Text = '' then
          FPopupMonthCalendar.Date := Date
        else
         FPopupMonthCalendar.Date := StrToDate(Text);
      except
        if Column.Field.AsDateTime = 0 then
          FPopupMonthCalendar.Date := Date
        else
          FPopupMonthCalendar.Date := Column.Field.AsDateTime;
      end;
      MonthCal_GetMinReqRect(FPopupMonthCalendar.Handle, R);
      FPopupMonthCalendar.Width := R.Right - R.Left;
      FPopupMonthCalendar.Height := R.Bottom - R.Top;
    end else
    begin
      //for delete FPickList.FSizeGripResized := False;
      //for delete FPickList.FSizeGrip.Visible := Column.DropDownSizing;
      FPickList.Color := Color;
      FPickList.Font := Font;
        if Assigned(Column.KeyList)  and (Column.KeyList.Count > 0) then
        begin
          FPickList.Items.BeginUpdate;
          FPickList.Items.Clear;
          for i := 0 to Min(Column.KeyList.Count,Column.Picklist.Count) - 1 do
             FPickList.Items.AddObject(Column.Picklist.Strings[i], Column.Picklist.Objects[i]);
          FPickList.Items.EndUpdate;
        end else
          FPickList.Items := Column.Picklist;
      if FPickList.Items.Count >= Integer(Column.DropDownRows) then
        FPickList.Height := Integer(Column.DropDownRows) * FPickList.ItemHeight + 4
      else
        FPickList.Height := FPickList.Items.Count * FPickList.ItemHeight + 4;
      if Column.Field.IsNull then
        FPickList.ItemIndex := -1
      else if Assigned(Column.KeyList)  and (Column.KeyList.Count > 0)
        then FPickList.ItemIndex := Column.PickList.IndexOf(Text)
        else FPickList.ItemIndex := FPickList.Items.IndexOf({dddColumn.Field.Value}Text);
      J := FPickList.ClientWidth;
      for I := 0 to FPickList.Items.Count - 1 do
      begin
        Y := FPickList.Canvas.TextWidth(FPickList.Items[I]);
        if Y > J then J := Y;
      end;
      FPickList.ClientWidth := J+4;
    end;
    P := Parent.ClientToScreen(Point(Left, Top));
    Y := P.Y + Height;
    SystemParametersInfo(SPI_GETWORKAREA,0,Pointer(@WorkArea),0);
    if ((Y + FActiveList.Height > WorkArea.Bottom) and (P.Y - FActiveList.Height >= WorkArea.Top)) or
       ((P.Y - FActiveList.Height < WorkArea.Top) and (WorkArea.Bottom - Y < P.Y - WorkArea.Top))
    then
    begin
      if P.Y - FActiveList.Height < WorkArea.Top then
        FActiveList.Height := P.Y - WorkArea.Top;
      Y := P.Y - FActiveList.Height;
      FActiveList.Perform(cm_SetSizeGripChangePosition,Ord(sgcpToTop),0);
    end else
    begin
      if Y + FActiveList.Height > WorkArea.Bottom then
        FActiveList.Height := WorkArea.Bottom - Y;
      FActiveList.Perform(cm_SetSizeGripChangePosition,Ord(sgcpToBottom),0);
    end;
    //ddd Drop Down Width
    if (FActiveList.Width > WorkArea.Right - WorkArea.Left) then
      FActiveList.Width := WorkArea.Right - WorkArea.Left;
    if (P.X + FActiveList.Width > WorkArea.Right) then
    begin
      P.X := WorkArea.Right - FActiveList.Width;
      FActiveList.Perform(cm_SetSizeGripChangePosition,Ord(sgcpToLeft),0);
    end else
      FActiveList.Perform(cm_SetSizeGripChangePosition,Ord(sgcpToRight),0);

    SetWindowPos(FActiveList.Handle, HWND_TOP, P.X, Y, 0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);

    if FActiveList = FDataList then
      FDataList.SizeGrip.Visible := Column.DropDownSizing
    else if FActiveList = FPickList then
      FPickList.FSizeGrip.Visible := Column.DropDownSizing;

    if FActiveList = FDataList then
      FDataList.SizeGripResized := False
    else if FActiveList = FPickList then
      FPickList.FSizeGripResized := False;
    //FActiveList.Visible := True;
    FListVisible := True;
    Invalidate;
    Windows.SetFocus(Handle);
  end;
end;

function StringsLocate(StrList:TStrings; Str: String; Options: TLocateOptions):Integer;
  function Compare(S1,S2:String): Integer;
  begin
    if loCaseInsensitive in Options
      then Result := AnsiCompareText(S1,S2)
      else Result := AnsiCompareStr(S1,S2);
  end;
var i:Integer;
    S:String;
begin
  Result :=  -1;
  for i := 0 to StrList.Count - 1 do
  begin
    if loPartialKey in Options
      then S := Copy(StrList.Strings[i],1,Length(Str))
      else S := StrList.Strings[i];
    if  AnsiCompareText(S,Str) = 0 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TDBGridInplaceEdit.LocateListText;
var AColumn: TColumnEh;
begin
  with Grid do AColumn := Columns[SelectedIndex];
  if not AColumn.CanModify(True) then Exit;
  if (EditStyle = esDataList) then
  begin
    Grid.FEditText := Text;
    if AColumn.Field.LookupDataSet.Locate(AColumn.Field.LookupResultField, Text, [loCaseInsensitive]) then
      Grid.FEditKeyValue :=
        AColumn.Field.LookupDataSet.FieldValues[AColumn.Field.LookupKeyFields]
    else
      Grid.FEditKeyValue := Null;
  end else
    Grid.FEditText := Text;
end;

type
  TWinControlCracker = class(TWinControl) end;

procedure TDBGridInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);
var MasterFields: TList;
    Field: TField;
    Y: Integer;
    S: String;

  procedure SendToParent;
  begin
    Grid.KeyDown(Key, Shift);
    Key := 0;
  end;

begin
  if (EditStyle in [esEllipsis,esDropDown]) and (Key = VK_RETURN) and (Shift = [ssCtrl]) then
  begin
    KillMessage(Handle, WM_CHAR);
    Grid.EditButtonClick;
  end else
  if (Key = VK_DELETE) and (Shift = []) and (EditStyle in [esDataList,esPickList])
     and Column.CanModify(False) then
  begin
    if (SelStart = 0) and (SelLength = Length(Text)) and Column.CanModify(True) then // All text seleted
    begin
      if EditStyle = esDataList then //lookup
      begin
        Field := Column.Field;
        MasterFields := TList.Create;
        try
          Field.Dataset.GetFieldList(MasterFields,Field.KeyFields);
          if FieldsCanModify(MasterFields) then
          begin
            Field.DataSet.Edit;
            //for i := 0 to MasterFields.Count-1 do TField(MasterFields[i]).Clear;
            //MasterField.Clear;
            Grid.Datalink.Modified;
            Grid.FEditKeyValue := Null;
            Grid.FEditText := '';
            Text := '';
             if Assigned(FDataList) then FDataList.KeyValue := Grid.FEditKeyValue;
            //Field.Clear;
          end;
        finally
          MasterFields.Free;
        end;
      end
      else if (EditStyle = esPickList) and
             (Column.GetColumnType = ctKeyPickList) then
      begin  // keypicklist
        Text := '';
        Grid.FEditText := Text;
      end
    end else if Assigned(Column.OnNotInlist) then
    begin
      S := DeleteSeletedText;
      Y := SelStart;
      if Column.CanModify(True) then
      begin
        Text := S;
        SelStart := Y;
        LocateListText;
        if Assigned(FDataList) then
          FDataList.KeyValue := Grid.FEditKeyValue
        else if Assigned(FPickList) then
          FPickList.ItemIndex :=
            StringsLocate(FPickList.Items,Grid.FEditText,[loCaseInsensitive]);
      end;
    end;
  end
  else if (Key = VK_BACK) and
     (Column.GetColumnType in [ctLookupField, ctKeyPickList]) then
  begin
    if not Assigned(Column.OnNotInlist) then
    begin
      Key := VK_LEFT;
      inherited KeyDown(Key, Shift);
    end else
    begin
      S := DeleteSeletedText;
      Y := SelStart;
      if Column.CanModify(True) then
      begin
        Field := Column.Field;
        Field.DataSet.Edit;
        Delete(S,Y,1);
        Text := S;
        SelStart := Y-1;
        LocateListText;
        if Assigned(FDataList) then
          FDataList.KeyValue := Grid.FEditKeyValue
        else if Assigned(FPickList) then
          FPickList.ItemIndex :=
            StringsLocate(FPickList.Items,Grid.FEditText,[loCaseInsensitive]);
      end;
    end;
  end
  else if WordWrap and (Key in [VK_UP, VK_DOWN]) then
  begin
    if not (dgAlwaysShowEditor in Grid.Options) then Exit;
    Y := Perform(EM_LINEFROMCHAR, SelStart, 0);
    if (Y = 0) and (Key = VK_UP) then
      inherited KeyDown(Key, Shift)
    else if (Y+1 = Perform(EM_GETLINECOUNT, 0, 0)) and (Key = VK_DOWN) then
      inherited KeyDown(Key, Shift)
    else if SelLength = Length(Text) then
      inherited KeyDown(Key, Shift);
  end
  else if (Key = VK_RETURN) and (dghEnterAsTab in Grid.OptionsEh) then
    SendToParent
  else if (ShortCut(Key,Shift) = DBGridEhInplaceSearchKey) and (dghIncSearch in Grid.OptionsEh) then
    Grid.StartInplaceSearch('',-1,inpsFromFirstEh)
  else
    inherited KeyDown(Key, Shift);
end;

procedure TDBGridInplaceEdit.ListMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    CloseUp(PtInRect(FActiveList.ClientRect, Point(X, Y)));
end;

procedure TDBGridInplaceEdit.ListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
//  if (FEditStyle = esDataList) and (FDataList <> nil) and (ssLeft in Shift) then
//    Text := FDataList.SelectedItem;
end;

procedure TDBGridInplaceEdit.ListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//  if (FEditStyle = esDataList) and (FDataList <> nil) and (ssLeft in Shift) then
//    Text := FDataList.SelectedItem;
end;

procedure TDBGridInplaceEdit.UpDownClick(Sender: TObject; Button: TUDBtnType);
var Col: TColumnEh;
    Znak: Integer;
begin
  Col := Grid.Columns[Grid.SelectedIndex];
  if not Col.CanModify(True) then Exit;
  Znak := 1;
  if (Col.Grid.GetEditText(Col.Grid.Col,0) <> Text) then
  begin
    Col.Grid.SetEditText(Col.Grid.Col,0,Text);
    Col.Grid.UpdateData;
  end;
  if Button = btNext then
  begin
    if Col.GetColumnType <> ctCommon then Znak := -1;
    Col.SetNextFieldValue(Col.Increment * Znak);
  end else
  begin
    if Col.GetColumnType <> ctCommon then Znak := -1;
    Col.SetNextFieldValue(-Col.Increment * Znak);
  end;
end;

procedure TDBGridInplaceEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var AutoRepeat, Handled:Boolean;
  ButtonRect: TRect;
begin
  if Grid.UseRightToLeftAlignment
    then ButtonRect := Rect(0, 0, FButtonWidth, FButtonHeight)
    else ButtonRect := Rect(Width - FButtonWidth, 0, Width, FButtonHeight);
  if (Button = mbLeft) and (FEditStyle in [esEllipsis..esDropDown]) and
    PtInRect(ButtonRect, Point(X,Y)) then
  begin

    if FEditStyle = esUpDown then
    begin
      if Y < (FButtonHeight div 2) then
      begin
        FDownButton := 1;
      end else if Y > (FButtonHeight - FButtonHeight div 2) then
      begin
        FDownButton := 2;
      end;
      AutoRepeat := True;
    end else
    begin
      FDownButton := 2;
      AutoRepeat := False;
    end;

    if FDownButton <> 0 then
    begin
      MouseCapture := True;
      FTracking := True;
      TrackButton(X, Y);
      Handled := False;
      if Assigned(Column.OnEditButtonDown) then
        Column.OnEditButtonDown(Self,FDownButton <> 2,AutoRepeat,Handled);
      //if not MouseCapture then Exit;
      if not Handled then
      begin
        if FListVisible then
          CloseUp(False)
        else
        begin
          if FEditStyle = esUpDown then
          begin
            if FDownButton = 1 then UpDownClick(nil,btNext)
            else if FDownButton = 2 then UpDownClick(nil,btPrev);
          end;
          if Assigned(FActiveList) then
            DropDown;
        end;
      end;

      if AutoRepeat then ResetTimer(InitRepeatPause);
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
  if Column.DblClickNextVal and (ssDouble in Shift) then
    if (ssShift in Shift)
      then Column.SetNextFieldValue(-1)
      else Column.SetNextFieldValue(1);
end;

procedure TDBGridInplaceEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ListPos: TPoint;
  MousePos: TSmallPoint;
begin
  if FTracking then
  begin
    TrackButton(X, Y);
    if FListVisible then
    begin
      ListPos := FActiveList.ScreenToClient(ClientToScreen(Point(X, Y)));
      if PtInRect(FActiveList.ClientRect, ListPos) then
      begin
        StopTracking;
        MousePos := PointToSmallPoint(ListPos);
        SendMessage(FActiveList.Handle, WM_LBUTTONDOWN, 0, Integer(MousePos));
        Exit;
      end;
    end;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TDBGridInplaceEdit.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  WasPressed, Handled: Boolean;
begin
  Handled := False;
  WasPressed := FPressed;
  StopTimer;
  StopTracking;
  if (Button = mbLeft) and WasPressed then
  begin
    if (FEditStyle in [esEllipsis,esDropDown])
      then Grid.EditButtonClick;
    if Assigned(Column.OnEditButtonClick) then
      Column.OnEditButtonClick(Self, Handled);
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure PaintInplaceButton(DC:HDC; EditStyle:TEditStyle; Rect:TRect;
  DownButton:Integer; Active, Flat, Enabled: Boolean; ParentColor:TColor);
var LineRect:TRect;
    Brush: HBRUSH;
begin
  if EditStyle <> esSimple then
  begin
    if Flat then  // Draw left button line
    begin
      LineRect := Rect;
      LineRect.Right := LineRect.Left + 1;
      Inc(Rect.Left,1);
      if Active then
        FrameRect(DC, LineRect,GetSysColorBrush(COLOR_BTNFACE))
       else
       begin
         Brush := CreateSolidBrush(ColorToRGB(ParentColor));
         FrameRect(DC, LineRect,Brush);
         DeleteObject(Brush);
       end;
    end;
    case EditStyle of
      esDataList, esPickList, esDateCalendar, esDropDown:
        PaintButtonControlEh(DC,Rect,ParentColor,bcsDropDownEh,DownButton,Flat,Active,Enabled,cbUnchecked);
      esEllipsis:
        PaintButtonControlEh(DC,Rect,ParentColor,bcsEllipsisEh,DownButton,Flat,Active,Enabled,cbUnchecked);
      esUpDown:
        PaintButtonControlEh(DC,Rect,ParentColor,bcsUpDownEh,DownButton,Flat,Active,Enabled,cbUnchecked);
    end;
  end;
end;

procedure TDBGridInplaceEdit.PaintWindow(DC: HDC);
var
  R: TRect;
  ADownButton:Integer;
begin
  if (FEditStyle <> esSimple) then
  begin
    SetRect(R, Width - FButtonWidth, 0, Width, FButtonHeight);
    if Grid.UseRightToLeftAlignment then
      OffsetRect(R,FButtonWidth - ClientWidth,0);
    if (FEditStyle =  esUpDown) and FPressed
      then ADownButton := FDownButton
      else ADownButton := Ord(FPressed);
    PaintInplaceButton(DC, FEditStyle, R, ADownButton, True, Grid.Flat, True, Color);
    ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
  end;
  inherited PaintWindow(DC);
end;

procedure TDBGridInplaceEdit.SetEditStyle(Value: TEditStyle);
begin
  if Value <> FEditStyle then
  begin
    FEditStyle := Value;
    case Value of
      esPickList:
        begin
          if FPickList = nil then
          begin
            FPickList := TPopupListbox.Create(Self);
            FPickList.Visible := False;
            FPickList.Parent := Self;
            FPickList.OnMouseUp := ListMouseUp;
            FPickList.IntegralHeight := True;
            FPickList.ItemHeight := 11;
          end;
          FActiveList := FPickList;
        end;
      esDataList:
        begin
          if FDataList = nil then
          begin
            FDataList := TPopupDataListEh.Create(Self);
            FDataList.Visible := False;
            FDataList.Parent := Self;
            FDataList.OnMouseUp := ListMouseUp;
            FDataList.OnMouseMove := ListMouseMove;
            FDataList.OnMouseDown := ListMouseDown;
          end;
          FActiveList := FDataList;
        end;
      esDateCalendar:
        begin
          if FPopupMonthCalendar = nil then
          begin
            FPopupMonthCalendar := TPopupMonthCalendar.Create(Self);
            FPopupMonthCalendar.Visible := False;
            FPopupMonthCalendar.Parent := Self;
          end;
          FActiveList := FPopupMonthCalendar;
        end;
      esUpDown:
          FActiveList := nil;
    else  { cbsNone, cbsEllipsis, or read only field }
      FActiveList := nil;
    end;
  end;
  with Grid do
    Self.ReadOnly := Column.ReadOnly;
  Repaint;
end;

procedure TDBGridInplaceEdit.StopTracking;
begin
  if FTracking then
  begin
    TrackButton(-1, -1);
    FTracking := False;
    MouseCapture := False;
    FDownButton := 0;
  end;
end;

procedure TDBGridInplaceEdit.TrackButton(X,Y: Integer);
var
  NewState: Boolean;
  R: TRect;
begin
  if Grid.UseRightToLeftAlignment
    then SetRect(R, 0, 0, FButtonWidth, FButtonHeight)
    else SetRect(R, ClientWidth - FButtonWidth, 0, ClientWidth, FButtonHeight);
  if FEditStyle = esUpDown then
  begin
    if FDownButton = 1 then R.Bottom := FButtonHeight div 2
    else if FDownButton = 2 then R.Top := FButtonHeight - FButtonHeight div 2
    else R.Bottom := R.Top-1;
  end;
  NewState := PtInRect(R, Point(X, Y));
  if FPressed <> NewState then
  begin
    FPressed := NewState;
    InvalidateRect(Handle, @R, False);
  end;
end;

function GetColumnEditStile(Column: TColumnEh):TEditStyle;
var MasterFields: TList;
    ACanModify: Boolean;
begin
  Result := esSimple;
  case Column.ButtonStyle of
    cbsEllipsis: Result := esEllipsis;
    cbsDropDown: Result := esDropDown;
    cbsUpDown: Result := esUpDown;
    cbsAuto:
      if Assigned(Column.Field) then
      with Column.Field do
      begin
        { Show the dropdown button only if the field is editable }
        if FieldKind = fkLookup then
        begin
          //MasterField := Dataset.FieldByName(KeyFields);
          MasterFields := TList.Create;
           try
            Dataset.GetFieldList(MasterFields,KeyFields);
            { Column.DefaultReadonly will always be True for a lookup field.
              Test if Column.ReadOnly has been assigned a value of True }
            ACanModify := FieldsCanModify(MasterFields) or (Assigned(Column.Grid) and (csDesigning in Column.Grid.ComponentState));
            if (MasterFields.Count>0) and {ddd MasterField.CanModify} ACanModify and
              not ((cvReadOnly in Column.AssignedValues) and Column.ReadOnly) then
              with Column.Grid do
                if not ReadOnly and DataLink.Active and not Datalink.ReadOnly then
                  Result := esDataList;
          finally
            MasterFields.Free;
          end;
        end
        else
        if Assigned(Column.Picklist) and (Column.PickList.Count > 0) and
          not Column.Readonly and not Assigned(Column.ImageList)
          then Result := esPickList
        else if (DataType in [ftDate,ftDateTime{$IFDEF EH_LIB_6},ftTimeStamp{$ENDIF}]) and not Column.Readonly
          then Result := esDateCalendar;
      end;
  end;
end;

procedure TDBGridInplaceEdit.UpdateContents;
var
  Column: TColumnEh;
  NewStyle: TEditStyle;
  MasterFields: TList;

  function MasterFieldsCanModify: Boolean;
  var i: Integer;
  begin
    Result := True;
    for i := 0 to MasterFields.Count-1 do
      if not TField(MasterFields[i]).CanModify then
      begin
        Result := False;
        Exit;
      end;
  end;

begin
  with Grid do
    Column := Columns[SelectedIndex];
  NewStyle := esSimple;
  case Column.ButtonStyle of
    cbsEllipsis: NewStyle := esEllipsis;
    cbsDropDown: NewStyle := esDropDown;
    cbsAuto:
      if Assigned(Column.Field) then
      with Column.Field do
      begin
        { Show the dropdown button only if the field is editable }
        if FieldKind = fkLookup then
        begin
         MasterFields := TList.Create;
          try
            Dataset.GetFieldList(MasterFields,KeyFields);
            { Column.DefaultReadonly will always be True for a lookup field.
              Test if Column.ReadOnly has been assigned a value of True }
            if (MasterFields.Count>0) and MasterFieldsCanModify and
              not ((cvReadOnly in Column.AssignedValues) and Column.ReadOnly) then
               with Grid do
                if not ReadOnly and DataLink.Active and not Datalink.ReadOnly then
                  NewStyle := esDataList;
          finally
            MasterFields.Free;
          end;
        end
        else
        if Assigned(Column.Picklist) and (Column.PickList.Count > 0) and
          not Column.Readonly then
          NewStyle := esPickList
        else if (DataType in [ftDate,ftDateTime{$IFDEF EH_LIB_6},ftTimeStamp{$ENDIF}]) and not Column.Readonly then
          NewStyle := esDateCalendar;
     end;
    cbsUpDown: NewStyle := esUpDown;
  end;
  EditStyle := NewStyle;
  Self.Font.Assign(Column.Font);
  Column.FillColCellParams(Grid.FColCellParamsEh);
  with Grid.FColCellParamsEh do
  begin
    FBackground := Column.Color;
    FFont := Self.Font;
    FState := [gdFocused];
    FText := Grid.GetEditText(Grid.Col, Grid.Row);
    FReadOnly := not Column.CanModify(False);
    Grid.GetCellParams(Column,FFont,FBackground,FState);
    Column.GetColCellParams(True, Grid.FColCellParamsEh);
    Self.Color := FBackground;
    if not Column.CanModify(False) <> FReadOnly then
    begin
      FReadOnlyStored := True;
      Self.ReadOnly := FReadOnly;
    end else
      FReadOnlyStored := False;
  end;
  WordWrap := Column.WordWrap and Grid.FAllowWordWrap;
//  inherited UpdateContents;
  Text := '';
  EditMask := Grid.GetEditMask(Grid.Col, Grid.Row);
  Text := Grid.FColCellParamsEh.FText;
  MaxLength := Grid.GetEditLimit;
end;

procedure TDBGridInplaceEdit.CMCancelMode(var Message: TCMCancelMode);
  function CheckActiveListChilds:Boolean;
  var i: Integer;
  begin
    Result := False;
    if FActiveList <> nil then
      for i := 0 to FActiveList.ControlCount - 1 do
        if FActiveList.Controls[I] = Message.Sender then
        begin
          Result := True;
          Exit;
        end;
  end;
begin
  if (Message.Sender <> Self) and (Message.Sender <> FActiveList) and
   not CheckActiveListChilds
   then CloseUp(False);
end;

procedure TDBGridInplaceEdit.WMCancelMode(var Message: TMessage);
begin
  StopTracking;
  inherited;
end;

procedure TDBGridInplaceEdit.WMKillFocus(var Message: TMessage);
begin
  if not SysLocale.FarEast then inherited
  else
  begin
    ImeName := Screen.DefaultIme;
    ImeMode := imDontCare;
    inherited;
    if HWND(Message.WParam) <> Grid.Handle then
      ActivateKeyboardLayout(Screen.DefaultKbLayout, KLF_ACTIVATE);
  end;
  CloseUp(False);
end;

procedure TDBGridInplaceEdit.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var ButtonRect: TRect;
begin
  if Grid.UseRightToLeftAlignment
    then ButtonRect := Rect(0, 0, FButtonWidth, Height)
    else ButtonRect := Rect(Width - FButtonWidth, 0, Width, Height);
  with Message do
  if (FEditStyle <> esSimple) and PtInRect(ButtonRect, Point(XPos, YPos))
    then Exit;
  inherited;
end;

procedure TDBGridInplaceEdit.WMPaint(var Message: TWMPaint);
begin
  PaintHandler(Message);
end;

procedure TDBGridInplaceEdit.WMSetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
  ButtonRect: TRect;
begin
  GetCursorPos(P);
  if Grid.UseRightToLeftAlignment
    then ButtonRect := Rect(0, 0, FButtonWidth, Height)
    else ButtonRect := Rect(Width - FButtonWidth, 0, Width, Height);
  if (FEditStyle <> esSimple) and
    PtInRect(ButtonRect, ScreenToClient(P))
    then Windows.SetCursor(LoadCursor(0, idc_Arrow))
  else
    inherited;
end;

procedure TDBGridInplaceEdit.WndProc(var Message: TMessage);
var AColumn: TColumnEh;
begin
  case Message.Msg of
    wm_KeyDown, wm_SysKeyDown, wm_Char:
      if EditStyle in [esPickList, esDataList, esDateCalendar] then
      with TWMKey(Message) do
      begin
        DoDropDownKeys(CharCode, KeyDataToShiftState(KeyData));
        AColumn := Grid.Columns[Grid.SelectedIndex];
        if (CharCode <> 0) and (Message.Msg = wm_Char) and (Char(CharCode) in [#32..#255]) and not FListVisible
              and AColumn.AutoDropDown then
        begin
          //AColumn.CanModify(True);
          DropDown;
        end;
        if (CharCode <> 0) and FListVisible then
        begin
          with TMessage(Message) do
          begin
             if (CharCode in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT]) or
               ((CharCode in [VK_HOME,VK_END]) and (ssCtrl in KeyDataToShiftState(KeyData))) or
               ((CharCode in [VK_LEFT, VK_RIGHT]) and (EditStyle = esDateCalendar)) then
               begin
                 SendMessage(FActiveList.Handle, Msg, WParam, LParam);
                 if (FEditStyle = esDataList) and (FDataList <> nil) then
                   Text := FDataList.SelectedItem
                 else if (FEditStyle = esPickList) then
                   if (FPickList.ItemIndex <> -1) and (Text <> FPickList.Items[FPickList.ItemIndex]) then
                       Text := FPickList.Items[FPickList.ItemIndex];
                 Exit;
               end;
          end;
        end;
      end
  end;
  inherited;
end;

procedure TDBGridInplaceEdit.DefaultHandler(var Message);
begin
  with TWMMouse(Message) do
    case Msg of
      WM_LBUTTONDBLCLK,WM_LBUTTONDOWN,WM_LBUTTONUP,
      WM_MBUTTONDBLCLK,WM_MBUTTONDOWN,WM_MBUTTONUP,
      WM_RBUTTONDBLCLK,WM_RBUTTONDOWN,WM_RBUTTONUP:
        if (FEditStyle <> esSimple) and
           PtInRect(Rect(Width - FButtonWidth, 0, Width, Height),Point(XPos,YPos))
          then Exit;
    end;
  inherited DefaultHandler(Message);
end;

function GetShiftState: TShiftState;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end;

procedure TDBGridInplaceEdit.KeyPress(var Key: Char);
var AColumn: TColumnEh;
    CurPosition,Idx: Integer;
    FSearchText: String;
    CanChange: Boolean;
    EditKeyValue: Variant;
begin
  if (Key = #10) and not WordWrap and (GetShiftState = [ssCtrl])
    then Key := #0
  else if (EditStyle = esDataList) and (Key in [#32..#255]) and
      Grid.AllowedOperationUpdate then // lookup
  begin
    with Grid do AColumn := Columns[SelectedIndex];
    CurPosition := SelStart;
    FSearchText := Copy(Text,1,CurPosition) + Key;
    if AColumn.Field.LookupDataSet.Locate(AColumn.Field.LookupResultField, FSearchText,
      [loCaseInsensitive, loPartialKey]) then
    begin
      Key := #0;
      Text := AColumn.Field.LookupDataSet.FieldByName(AColumn.Field.LookupResultField).Text;
      EditKeyValue := AColumn.Field.LookupDataSet.FieldValues[AColumn.Field.LookupKeyFields];
      Grid.DataLink.Edit;
      CanChange := Grid.Datalink.Editing;
      if CanChange then
      begin
        Grid.Datalink.Modified;
        SelStart := Length(Text);
        SelLength := Length(FSearchText) - SelStart;

        Grid.FEditKeyValue := EditKeyValue;
        Grid.FEditText := Text;
        if Assigned(FDataList) then FDataList.KeyValue := Grid.FEditKeyValue;
      end;
    end else if Assigned(AColumn.OnNotInList) then
    begin
      Grid.DataLink.Edit;
      CanChange := Grid.Datalink.Editing;
      if CanChange then
      begin
        Grid.Datalink.Modified;
        Text := FSearchText;
        SelStart := Length(Text);
        SelLength := 0;

        Grid.FEditKeyValue := Null;
        Grid.FEditText := Text;
        if Assigned(FDataList) then FDataList.KeyValue := Grid.FEditKeyValue;
      end;
      Key := #0;
    end
  end else if ((Column.GetColumnType = ctKeyPickList) or
     (EditStyle = esPickList)) and (Key in [#32..#255]) then // picklist or keypicklist
  begin
    CurPosition := SelStart;
    FSearchText := Copy(Text,1,CurPosition) + Key;
    AColumn := Grid.Columns[Grid.SelectedIndex];
    Idx := StringsLocate(AColumn.PickList,FSearchText,[loCaseInsensitive, loPartialKey]);
    if (Idx <> -1) and Grid.CanEditModifyText then
    begin
      Key := #0;
      Text := AColumn.PickList[Idx];
      SelStart := Length(Text);
      SelLength := Length(FSearchText) - SelStart;

      Grid.DataLink.Edit;
      CanChange := Grid.Datalink.Editing;
      if CanChange then Grid.Datalink.Modified;

      Grid.FEditText := Text;
      if Assigned(FPickList) then FPickList.ItemIndex := Idx;
    end else if Assigned(AColumn.OnNotInList) then
    begin
      Grid.DataLink.Edit;
      CanChange := Grid.Datalink.Editing;
      if CanChange then
      begin
        Grid.Datalink.Modified;
        Text := FSearchText;
        SelStart := Length(Text);
        SelLength := 0;

        Grid.FEditKeyValue := Null;
        Grid.FEditText := Text;
        if Assigned(FPickList) then FPickList.ItemIndex := -1;
      end;
      Key := #0;
    end;
  end;
  inherited;
end;

procedure TDBGridInplaceEdit.SetWordWrap(const Value: Boolean);
begin
  if Value <> FWordWrap then
  begin
    FWordWrap := Value;
    RecreateWnd;
  end;
end;

procedure TDBGridInplaceEdit.StopTimer;
begin
  if FTimerActive then
  begin
    KillTimer(Handle, 1);
    FTimerActive := False;
    FTimerInterval := -1;
  end;
end;

procedure TDBGridInplaceEdit.ResetTimer(Interval: Integer);
begin
  if FTimerActive = False then
    SetTimer(Handle, 1, Interval, nil)
  else if Interval <> FTimerInterval then
  begin
    StopTimer;
    SetTimer(Handle, 1, Interval, nil);
  end;
  FTimerInterval := Interval;
  FTimerActive := True;
end;

procedure TDBGridInplaceEdit.WMTimer(var Message: TWMTimer);
var AutoRepeat, Handled: Boolean;
begin
  inherited ;
  if FTimerInterval = InitRepeatPause then ResetTimer(RepeatPause);
  AutoRepeat := True;
  Handled := False;
  if FPressed and Assigned(Column.OnEditButtonDown) then
    Column.OnEditButtonDown(Self,FDownButton <> 2,AutoRepeat,Handled);
  if not Handled then
    if (FEditStyle = esUpDown) and FPressed then
      if FDownButton = 1 then UpDownClick(nil,btNext)
      else if FDownButton = 2 then UpDownClick(nil,btPrev);
end;

function TDBGridInplaceEdit.GetGrid: TCustomDBGridEh;
begin
  Result := TCustomDBGridEh(inherited Grid);
end;

function TDBGridInplaceEdit.GetColumn: TColumnEh;
begin
  if (Grid <> nil) and (Grid.Columns.Count > 0)
    then Result := Grid.Columns[Grid.SelectedIndex]
    else Result := nil;
end;

{ TGridDataLinkEh }

type
  TIntArray = array[0..MaxMapSize] of Integer;
  PIntArray = ^TIntArray;

constructor TGridDataLinkEh.Create(AGrid: TCustomDBGridEh);
begin
  inherited Create;
  FGrid := AGrid;
end;

destructor TGridDataLinkEh.Destroy;
begin
  ClearMapping;
  inherited Destroy;
end;

function TGridDataLinkEh.GetDefaultFields: Boolean;
var
  I: Integer;
begin
  Result := True;
  if DataSet <> nil then Result := DataSet.DefaultFields;
  if Result and SparseMap then
  for I := 0 to FFieldCount-1 do
    if PIntArray(FFieldMap)^[I] < 0 then
    begin
      Result := False;
      Exit;
    end;
end;

function TGridDataLinkEh.GetFields(I: Integer): TField;
begin
  if (0 <= I) and (I < FFieldCount) and (PIntArray(FFieldMap)^[I] >= 0)
    then Result := DataSet.Fields[PIntArray(FFieldMap)^[I]]
    else Result := nil;
end;

function TGridDataLinkEh.AddMapping(const FieldName: string): Boolean;
var
  Field: TField;
  NewSize: Integer;
begin
  Result := True;
  if FFieldCount >= MaxMapSize then RaiseGridError(STooManyColumns);
  if SparseMap
    then Field := DataSet.FindField(FieldName)
    else Field := DataSet.FieldByName(FieldName);

  if FFieldCount = FFieldMapSize then
  begin
    NewSize := FFieldMapSize;
    if NewSize = 0
      then NewSize := 8
      else Inc(NewSize, NewSize);
    if (NewSize < FFieldCount) then
      NewSize := FFieldCount + 1;
    if (NewSize > MaxMapSize) then
      NewSize := MaxMapSize;
    ReallocMem(FFieldMap, NewSize * SizeOf(Integer));
    FFieldMapSize := NewSize;
  end;
  if Assigned(Field) then
  begin
    PIntArray(FFieldMap)^[FFieldCount] := Field.Index;
    Field.FreeNotification(FGrid);
  end else
    PIntArray(FFieldMap)^[FFieldCount] := -1;
  Inc(FFieldCount);
end;

procedure TGridDataLinkEh.ActiveChanged;
begin
  FGrid.LinkActive(Active);
  FModified := False;
end;

procedure TGridDataLinkEh.ClearMapping;
begin
  if FFieldMap <> nil then
  begin
    FreeMem(FFieldMap, FFieldMapSize * SizeOf(Integer));
    FFieldMap := nil;
    FFieldMapSize := 0;
    FFieldCount := 0;
  end;
end;

procedure TGridDataLinkEh.Modified;
begin
  FModified := True;
end;

procedure TGridDataLinkEh.DataSetChanged;
begin
  FGrid.DataChanged;
  FModified := False;
end;

procedure TGridDataLinkEh.DataSetScrolled(Distance: Integer);
begin
  FGrid.Scroll(Distance);
end;

procedure TGridDataLinkEh.LayoutChanged;
var
  SaveState: Boolean;
begin
  { FLayoutFromDataset determines whether default column width is forced to
    be at least wide enough for the column title.  }
  SaveState := FGrid.FLayoutFromDataset;
  FGrid.FLayoutFromDataset := True;
  try
    FGrid.LayoutChanged;
  finally
    FGrid.FLayoutFromDataset := SaveState;
  end;
  inherited LayoutChanged;
end;

procedure TGridDataLinkEh.FocusControl(Field: TFieldRef);
begin
  if Assigned(Field) and Assigned(Field^) then
  begin
    FGrid.SelectedField := Field^;
    if (FGrid.SelectedField = Field^) and FGrid.AcquireFocus then
    begin
      Field^ := nil;
      FGrid.ShowEditor;
    end;
  end;
end;

procedure TGridDataLinkEh.EditingChanged;
begin
  FGrid.EditingChanged;
end;

procedure TGridDataLinkEh.RecordChanged(Field: TField);
begin
  FGrid.RecordChanged(Field);
  FModified := False;
end;

procedure TGridDataLinkEh.UpdateData;
begin
  FInUpdateData := True;
  try
    if FModified then FGrid.UpdateData;
    FModified := False;
  finally
    FInUpdateData := False;
  end;
end;

function TGridDataLinkEh.GetMappedIndex(ColIndex: Integer): Integer;
begin
  if (0 <= ColIndex) and (ColIndex < FFieldCount)
    then Result := PIntArray(FFieldMap)^[ColIndex]
    else Result := -1;
end;

procedure TGridDataLinkEh.Reset;
begin
  if FModified then RecordChanged(nil) else Dataset.Cancel;
end;


{ TColumnTitleEh }
constructor TColumnTitleEh.Create(Column: TColumnEh);
begin
  inherited Create;
  FColumn := Column;
  FFont := TFont.Create;
  FFont.Assign(DefaultFont);
  FFont.OnChange := FontChanged;
  FTitleButton := False;
  SortMarker := smNoneEh;
  ImageIndex := -1;
end;

destructor TColumnTitleEh.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TColumnTitleEh.Assign(Source: TPersistent);
begin
  if Source is TColumnTitleEh then
  begin
    if cvTitleAlignment in TColumnTitleEh(Source).FColumn.FAssignedValues then
      Alignment := TColumnTitleEh(Source).Alignment;
    if cvTitleColor in TColumnTitleEh(Source).FColumn.FAssignedValues then
      Color := TColumnTitleEh(Source).Color;
    if cvTitleCaption in TColumnTitleEh(Source).FColumn.FAssignedValues then
      Caption := TColumnTitleEh(Source).Caption;
    if cvTitleFont in TColumnTitleEh(Source).FColumn.FAssignedValues then
      Font := TColumnTitleEh(Source).Font;
    TitleButton := TColumnTitleEh(Source).TitleButton;
    SortMarker := TColumnTitleEh(Source).SortMarker;
    EndEllipsis := TColumnTitleEh(Source).EndEllipsis;
    ToolTips := TColumnTitleEh(Source).ToolTips;
    Orientation := TColumnTitleEh(Source).Orientation;
  end else
    inherited Assign(Source);
end;

function TColumnTitleEh.DefaultAlignment: TAlignment;
begin
  if FColumn.GetGrid <> nil
    then Result := FColumn.GetGrid.ColumnDefValues.Title.Alignment
    else Result := taLeftJustify;
end;

function TColumnTitleEh.DefaultColor: TColor;
var
  Grid: TCustomDBGridEh;
begin
  Grid := FColumn.GetGrid;
  if Assigned(Grid)
    then Result := Grid.ColumnDefValues.Title.Color
    else Result := clBtnFace;
end;

function TColumnTitleEh.DefaultFont: TFont;
var
  Grid: TCustomDBGridEh;
begin
  Grid := FColumn.GetGrid;
  if Assigned(Grid)
    then Result := Grid.TitleFont
    else Result := FColumn.Font;
end;

function TColumnTitleEh.DefaultCaption: string;
var
  Field: TField;
begin
  Field := FColumn.Field;
  if Assigned(Field)
    then Result := Field.DisplayName
    else Result := FColumn.FieldName;
end;

procedure TColumnTitleEh.FontChanged(Sender: TObject);
begin
  Include(FColumn.FAssignedValues, cvTitleFont);
  FColumn.Changed(True);
end;

function TColumnTitleEh.GetAlignment: TAlignment;
begin
  if cvTitleAlignment in FColumn.FAssignedValues
    then Result := FAlignment
    else Result := DefaultAlignment;
end;

function TColumnTitleEh.GetColor: TColor;
begin
  if cvTitleColor in FColumn.FAssignedValues
    then Result := FColor
    else Result := DefaultColor;
end;

function TColumnTitleEh.GetCaption: string;
begin
  if cvTitleCaption in FColumn.FAssignedValues
    then Result := FCaption
    else Result := DefaultCaption;
end;

function TColumnTitleEh.GetFont: TFont;
var
  Save: TNotifyEvent;
  Def: TFont;
begin
  if not (cvTitleFont in FColumn.FAssignedValues) then
  begin
    Def := DefaultFont;
    if (FFont.Handle <> Def.Handle) or (FFont.Color <> Def.Color) then
    begin
      Save := FFont.OnChange;
      FFont.OnChange := nil;
      FFont.Assign(DefaultFont);
      FFont.OnChange := Save;
    end;
  end;
  Result := FFont;
end;

function TColumnTitleEh.IsAlignmentStored: Boolean;
begin
  Result := (cvTitleAlignment in FColumn.FAssignedValues) and (FAlignment <> DefaultAlignment);
end;

function TColumnTitleEh.IsColorStored: Boolean;
begin
  Result := (cvTitleColor in FColumn.FAssignedValues) and (FColor <> DefaultColor);
end;

function TColumnTitleEh.IsFontStored: Boolean;
begin
  Result := (cvTitleFont in FColumn.FAssignedValues);
end;

function TColumnTitleEh.IsCaptionStored: Boolean;
begin
  Result := (cvTitleCaption in FColumn.FAssignedValues) and (FCaption <> DefaultCaption);
end;

procedure TColumnTitleEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if (cvTitleFont in FColumn.FAssignedValues) then Exit;
  Save := FFont.OnChange;
  FFont.OnChange := nil;
  try
    FFont.Assign(DefaultFont);
  finally
    FFont.OnChange := Save;
  end;
end;

procedure TColumnTitleEh.RestoreDefaults;
var
  FontAssigned: Boolean;
begin
  FontAssigned := cvTitleFont in FColumn.FAssignedValues;
  FColumn.FAssignedValues := FColumn.FAssignedValues - ColumnEhTitleValues;
  FCaption := '';
  RefreshDefaultFont;
  { If font was assigned, changing it back to default may affect grid title
    height, and title height changes require layout and redraw of the grid. }
  FColumn.Changed(FontAssigned);
end;

procedure TColumnTitleEh.SetAlignment(Value: TAlignment);
begin
  if (cvTitleAlignment in FColumn.FAssignedValues) and (Value = FAlignment) then Exit;
  FAlignment := Value;
  Include(FColumn.FAssignedValues, cvTitleAlignment);
  FColumn.Changed(False);
end;

procedure TColumnTitleEh.SetColor(Value: TColor);
begin
  if (cvTitleColor in FColumn.FAssignedValues) and (Value = FColor) then Exit;
  FColor := Value;
  Include(FColumn.FAssignedValues, cvTitleColor);
  FColumn.Changed(False);
end;

procedure TColumnTitleEh.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TColumnTitleEh.SetCaption(const Value: string);
var
  Grid: TCustomDBGridEh;
begin
  if Column.IsStored then
  begin
    if (cvTitleCaption in FColumn.FAssignedValues) and (Value = FCaption) then Exit;
    FCaption := Value;
    Include(Column.FAssignedValues, cvTitleCaption);
    Column.Changed(False);
  end else
  begin
    Grid := Column.GetGrid;
    if Assigned(Grid) and (Grid.Datalink.Active) and Assigned(Column.Field) then
      Column.Field.DisplayLabel := Value;
  end;
end;


procedure TColumnTitleEh.SetTitleButton(Value: Boolean);
begin
  if (cvTitleButton in FColumn.FAssignedValues) and (Value = FTitleButton) then Exit;
  FTitleButton := Value;
  Include(FColumn.FAssignedValues, cvTitleButton);
  FColumn.Changed(False);
end;

procedure TColumnTitleEh.SetEndEllipsis(const Value: Boolean);
begin
  if (cvTitleEndEllipsis in FColumn.FAssignedValues) and (Value = FEndEllipsis) then Exit;
  FEndEllipsis := Value;
  Include(FColumn.FAssignedValues, cvTitleEndEllipsis);
  FColumn.Changed(False);
end;

procedure TColumnTitleEh.SetSortMarker(Value: TSortMarkerEh);
var AColumns: TDBGridColumnsEh;
    i, ASortIndex: Integer;
    Grid: TCustomDBGridEh;
begin
  if (Value = FSortMarker) then Exit;
  FSortMarker := Value;
  Grid := FColumn.GetGrid;
  if Assigned(Grid) and (csLoading in Grid.ComponentState) then Exit;
  AColumns := TDBGridColumnsEh(FColumn.Collection);
  if not (dghMultiSortMarking in Grid.OptionsEh) then
  begin
    if FSortMarker = smNoneEh then
    begin
      FSortIndex := 0;
      Grid.FSortMarkedColumns.Clear;
    end else
    begin
      for i := 0 to AColumns.Count-1 do
        if (AColumns[i].Title.SortMarker <> smNoneEh) and (AColumns[i] <> FColumn)
          then AColumns[i].Title.SortMarker := smNoneEh;
      FSortIndex := 1;
      Grid.FSortMarkedColumns.Clear;
      Grid.FSortMarkedColumns.Add(FColumn);
    end;
  end else if (FSortMarker <> smNoneEh) and (SortIndex = 0) then
  begin
    ASortIndex := 1;
    for i := 0 to AColumns.Count-1 do
      if AColumns[i].Title.SortIndex <> 0 then Inc(ASortIndex);
    FSortIndex := ASortIndex;
    Grid.FSortMarkedColumns.Add(FColumn);
  end else if (FSortMarker = smNoneEh) and (SortIndex <> 0) then
  begin
    for i := 0 to AColumns.Count-1 do
      if AColumns[i].Title.SortIndex > SortIndex then Dec(AColumns[i].Title.FSortIndex);
    Grid.FSortMarkedColumns.Remove(FColumn);
    FSortIndex := 0;
  end;
  FColumn.Changed(False);
end;

procedure TColumnTitleEh.SetSortIndex(Value: Integer);
var AColumns: TDBGridColumnsEh;
    i: Integer;
begin
  if (Value < 0) then Value := 0;
  if Value = FSortIndex then Exit;
  if (FColumn.GetGrid <> nil) and (csLoading in FColumn.GetGrid.ComponentState) then
  begin
    FSortIndex := Value;
    Exit;
  end;
  if SortMarker = smNoneEh then Exit;
  AColumns := TDBGridColumnsEh(FColumn.Collection);
  for i := 0 to AColumns.Count-1 do
  begin
    if (AColumns[i].Title.SortIndex <> 0) and
       (AColumns[i].Title.SortIndex = Value) and (AColumns[i] <> FColumn) then
    begin
      AColumns[i].Title.FSortIndex := FSortIndex;
      FSortIndex := Value;
      with  FColumn.GetGrid.FSortMarkedColumns do
        Exchange(IndexOf(AColumns[i]),IndexOf(FColumn));
      FColumn.Changed(False);
      Exit;
    end;
  end;
end;

procedure TColumnTitleEh.SetNextSortMarkerValue(KeepMulti:Boolean);
var
  Grid: TCustomDBGridEh;
  i: Integer;
begin
  if not KeepMulti then
  begin
    Grid := FColumn.GetGrid;
    for i := 0 to Grid.Columns.Count-1 do
      if (Grid.Columns[i].Title.SortMarker <> smNoneEh) and (Grid.Columns[i] <>FColumn)
        then Grid.Columns[i].Title.SortMarker := smNoneEh;
  end;
  case SortMarker of
    smNoneEh: SortMarker := smDownEh;
    smDownEh: SortMarker := smUpEh;
    smUpEh: if KeepMulti then SortMarker := smNoneEh else SortMarker := smDownEh;
  end;
end;

procedure TColumnTitleEh.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  if FColumn.GetGrid <> nil then
    FColumn.GetGrid.LayoutChanged;
end;

function TColumnTitleEh.GetToolTips:Boolean;
begin
  if cvTitleToolTips in FColumn.FAssignedValues
    then Result := FToolTips
    else Result := DefaultToolTips;
end;

procedure TColumnTitleEh.SetToolTips(const Value: Boolean);
begin
  if (cvTitleToolTips in FColumn.FAssignedValues) and (Value = FToolTips) then Exit;
  FToolTips := Value;
  Include(FColumn.FAssignedValues, cvTitleToolTips);
end;

function TColumnTitleEh.GetSortMarkingWidth:Integer;
var SMTMarg: Integer;
    Canvas: TCanvas;
begin
  Result := 0;
  if SortIndex <> 0 then
  begin
    Inc(Result,16);
    Canvas := FColumn.GetGrid.Canvas;
    if (FColumn.GetGrid.SortMarkedColumns.Count > 1) then
    begin
      Canvas.Font := SortMarkerFont;
      SMTMarg := Canvas.TextWidth(IntToStr(SortIndex));
      Inc(Result,SMTMarg);
    end else
      SMTMarg := 0;
    if FColumn.Width - 4 < Result then
      Dec(Result,14);
    if FColumn.Width - 4 < Result then
      Dec(Result,2+SMTMarg);
  end;
end;

procedure TColumnTitleEh.SetOrientation(const Value: TTextOrientationEh);
begin
  if (cvTitleOrientation in FColumn.FAssignedValues) and (Value = FOrientation) then Exit;
  FOrientation := Value;
  Include(FColumn.FAssignedValues, cvTitleOrientation);
  FColumn.Changed(False);
end;

function TColumnTitleEh.GetTitleButton: Boolean;
begin
  if cvTitleButton in FColumn.FAssignedValues
    then Result := FTitleButton
    else Result := DefaultTitleButton;
end;

function TColumnTitleEh.IsTitleButtonStored: Boolean;
begin
  Result := (cvTitleButton in FColumn.FAssignedValues) and (FTitleButton <> DefaultTitleButton);
end;

function TColumnTitleEh.DefaultTitleButton: Boolean;
begin
  if FColumn.GetGrid <> nil
    then Result := FColumn.GetGrid.ColumnDefValues.Title.TitleButton
    else Result := False;
end;

function TColumnTitleEh.GetEndEllipsis: Boolean;
begin
  if cvTitleEndEllipsis in FColumn.FAssignedValues
    then Result := FEndEllipsis
    else Result := DefaultEndEllipsis;
end;

function TColumnTitleEh.IsEndEllipsisStored: Boolean;
begin
  Result := (cvTitleEndEllipsis in FColumn.FAssignedValues) and (FEndEllipsis <> DefaultEndEllipsis);
end;

function TColumnTitleEh.DefaultEndEllipsis: Boolean;
begin
  if FColumn.GetGrid <> nil
    then Result := FColumn.GetGrid.ColumnDefValues.Title.EndEllipsis
    else Result := False;
end;

function TColumnTitleEh.DefaultToolTips: Boolean;
begin
  if FColumn.GetGrid <> nil
    then Result := FColumn.GetGrid.ColumnDefValues.Title.ToolTips
    else Result := False;
end;

function TColumnTitleEh.IsToolTipsStored: Boolean;
begin
  Result := (cvTitleToolTips in FColumn.FAssignedValues) and (FToolTips <> DefaultToolTips);
end;

function TColumnTitleEh.DefaultOrientation:TTextOrientationEh;
begin
  if FColumn.GetGrid <> nil
    then Result := FColumn.GetGrid.ColumnDefValues.Title.Orientation
    else Result := tohHorizontal;
end;

function TColumnTitleEh.GetOrientation: TTextOrientationEh;
begin
  if cvTitleOrientation in FColumn.FAssignedValues
    then Result := FOrientation
    else Result := DefaultOrientation;
end;

function TColumnTitleEh.IsOrientationStored: Boolean;
begin
  Result := (cvTitleOrientation in FColumn.FAssignedValues) and (FOrientation <> DefaultOrientation);
end;

{ TColumnEh }

constructor TColumnEh.Create(Collection: TCollection);
var
  Grid: TCustomDBGridEh;
begin
  Grid := nil;
  if Assigned(Collection) and (Collection is TDBGridColumnsEh) then
    Grid := TDBGridColumnsEh(Collection).Grid;
  if Assigned(Grid) then
    Grid.BeginLayout;
  try
    inherited Create(Collection);
    FDropDownRows := 7;
    FButtonStyle := cbsAuto;
    FFont := TFont.Create;
    FFont.Assign(DefaultFont);
    FFont.OnChange := FontChanged;
    FImeMode := imDontCare;
    FImeName := Screen.DefaultIme;
    FTitle := CreateTitle;
    FFooter := CreateFooter;
    FFooters := CreateFooters;
    FAutoFitColWidth := True;
    FInitWidth := Width;
    FVisible := True;
    FNotInKeyListIndex := -1;
    FIncrement := 1.0;
    FStored := True;
  finally
    if Assigned(Grid) then
      Grid.EndLayout;
  end;
end;

destructor TColumnEh.Destroy;
var
//  Designer: IDesignerNotify;
  Form: TCustomForm;
begin
  FTitle.Free;
  FFont.Free;
  FPickList.Free;
  FFooter.Free;
{  Designer := FindRootDesigner(Self);
  if Designer <> nil then Designer.Notification(FFooters,opRemove);}
  Form := nil;
  if Grid <> nil then
    Form := GetParentForm(Grid);
  if (Form <> nil) and (Form.Designer <> nil)
    then Form.Designer.Notification(TComponent(FFooters),opRemove);

  FFooters.Free;
  FKeyList.Free;
  inherited Destroy;
end;

procedure TColumnEh.Assign(Source: TPersistent);
begin
  if Source is TColumnEh then
  begin
    if Assigned(Collection) then Collection.BeginUpdate;
    try
      RestoreDefaults;
      FieldName := TColumnEh(Source).FieldName;
      if cvColor in TColumnEh(Source).AssignedValues then
        Color := TColumnEh(Source).Color;
      if cvWidth in TColumnEh(Source).AssignedValues then
        Width := TColumnEh(Source).Width;
      if cvFont in TColumnEh(Source).AssignedValues then
        Font := TColumnEh(Source).Font;
      if cvImeMode in TColumnEh(Source).AssignedValues then
        ImeMode := TColumnEh(Source).ImeMode;
      if cvImeName in TColumnEh(Source).AssignedValues then
        ImeName := TColumnEh(Source).ImeName;
      if cvAlignment in TColumnEh(Source).AssignedValues then
        Alignment := TColumnEh(Source).Alignment;
      if cvReadOnly in TColumnEh(Source).AssignedValues then
        ReadOnly := TColumnEh(Source).ReadOnly;
      Title := TColumnEh(Source).Title;
      DropDownRows := TColumnEh(Source).DropDownRows;
      ButtonStyle := TColumnEh(Source).ButtonStyle;
      PickList := TColumnEh(Source).PickList;
      PopupMenu := TColumnEh(Source).PopupMenu;
      FInitWidth := TColumnEh(Source).FInitWidth;
      AutoFitColWidth := TColumnEh(Source).AutoFitColWidth;
      if cvWordWrap in TColumnEh(Source).AssignedValues then
        WordWrap := TColumnEh(Source).WordWrap;
      EndEllipsis := TColumnEh(Source).EndEllipsis;
      DropDownWidth := TColumnEh(Source).DropDownWidth;
      if cvLookupDisplayFields in TColumnEh(Source).AssignedValues then
        LookupDisplayFields := TColumnEh(Source).LookupDisplayFields;
      AutoDropDown := TColumnEh(Source).AutoDropDown;
      AlwaysShowEditButton := TColumnEh(Source).AlwaysShowEditButton;
      WordWrap := TColumnEh(Source).WordWrap;
      Footer := TColumnEh(Source).Footer;
      KeyList := TColumnEh(Source).KeyList;
      if cvCheckboxes in TColumnEh(Source).AssignedValues then
        Checkboxes := TColumnEh(Source).Checkboxes;
      Increment := TColumnEh(Source).Increment;
      ToolTips := TColumnEh(Source).ToolTips;
      Footers := TColumnEh(Source).Footers;
      Tag := TColumnEh(Source).Tag;
      Visible := TColumnEh(Source).Visible;
      ImageList := TColumnEh(Source).ImageList;
      NotInKeyListIndex := TColumnEh(Source).NotInKeyListIndex;
      MinWidth := TColumnEh(Source).MinWidth;
      MaxWidth := TColumnEh(Source).MaxWidth;
      DblClickNextVal := TColumnEh(Source).DblClickNextVal;
      DropDownSizing := TColumnEh(Source).DropDownSizing;
      DropDownShowTitles := TColumnEh(Source).DropDownShowTitles;
      OnGetCellParams := TColumnEh(Source).OnGetCellParams;
      OnNotInList := TColumnEh(Source).OnNotInList;
      OnUpdateData := TColumnEh(Source).OnUpdateData;
      OnEditButtonClick := TColumnEh(Source).OnEditButtonClick;
      OnEditButtonDown := TColumnEh(Source).OnEditButtonDown;
    finally
      if Assigned(Collection) then Collection.EndUpdate;
    end;
  end else
    inherited Assign(Source);
end;

function TColumnEh.CreateTitle: TColumnTitleEh;
begin
  Result := TColumnTitleEh.Create(Self);
end;

function TColumnEh.DefaultAlignment: TAlignment;
begin
  if Assigned(Field)
    then Result := FField.Alignment
    else Result := taLeftJustify;
end;

function TColumnEh.DefaultColor: TColor;
var
  Grid: TCustomDBGridEh;
begin
  Grid := GetGrid;
  if Assigned(Grid)
    then Result := Grid.Color
    else Result := clWindow;
end;

function TColumnEh.DefaultFont: TFont;
var
  Grid: TCustomDBGridEh;
begin
  Grid := GetGrid;
  if Assigned(Grid)
    then Result := Grid.Font
    else Result := FFont;
end;

function TColumnEh.DefaultImeMode: TImeMode;
var
  Grid: TCustomDBGridEh;
begin
  Grid := GetGrid;
  if Assigned(Grid)
    then Result := Grid.ImeMode
    else Result := FImeMode;
end;

function TColumnEh.DefaultImeName: TImeName;
var
  Grid: TCustomDBGridEh;
begin
  Grid := GetGrid;
  if Assigned(Grid)
    then Result := Grid.ImeName
    else Result := FImeName;
end;

function TColumnEh.DefaultReadOnly: Boolean;
var
  Grid: TCustomDBGridEh;
begin
  Grid := GetGrid;
  Result := (Assigned(Grid) and Grid.ReadOnly) or (Assigned(Field) and FField.ReadOnly);
end;

function TColumnEh.DefaultWidth: Integer;
var
  RestoreCanvas: Boolean;
  TM: TTextMetric;
begin
  if GetGrid = nil then
  begin
    Result := 64;
    Exit;
  end;
  with GetGrid do
  begin
    if Assigned(Field) then
    begin
      RestoreCanvas := not HandleAllocated;
      if RestoreCanvas
        then Canvas.Handle := GetDC(0);
      try
        Canvas.Font := Self.Font;
        GetTextMetrics(Canvas.Handle, TM);
        Result := Field.DisplayWidth * (Canvas.TextWidth('0') - TM.tmOverhang) + TM.tmOverhang + 4;
        {if dgTitles in Options then  //ddd
        begin
          Canvas.Font := Title.Font;
          W := Canvas.TextWidth(Title.Caption) + 4;
          if Result < W then
            Result := W;
        end;}                       //\\\
      finally
        if RestoreCanvas then
        begin
          ReleaseDC(0,Canvas.Handle);
          Canvas.Handle := 0;
        end;
      end;
    end else
      Result := DefaultColWidth;
  end;
end;

procedure TColumnEh.FontChanged;
begin
  Include(FAssignedValues, cvFont);
  Title.RefreshDefaultFont;
  Changed(False);
end;

function TColumnEh.GetAlignment: TAlignment;
begin
  if cvAlignment in FAssignedValues
    then Result := FAlignment
    else Result := DefaultAlignment;
end;

function TColumnEh.GetColor: TColor;
begin
  if cvColor in FAssignedValues
    then Result := FColor
    else Result := DefaultColor;
end;

function TColumnEh.GetField: TField;
var
  Grid: TCustomDBGridEh;
begin    { Returns Nil if FieldName can't be found in dataset }
  Grid := GetGrid;
  if (FField = nil) and (Length(FFieldName) > 0) and Assigned(Grid) and
    Assigned(Grid.DataLink.DataSet) then
  with Grid.Datalink.Dataset do
    if Active or (not DefaultFields) then
    begin
      // SetField(FindField(FieldName));
      if FField <> FindField(FieldName) then
      begin
        FField := FindField(FieldName);
        if Assigned(FindField(FieldName))
          then FFieldName := FindField(FieldName).FieldName;
        EnsureSumValue;
      end;
    end;
  Result := FField;
end;

function TColumnEh.GetFont: TFont;
var
  Save: TNotifyEvent;
begin
  if not (cvFont in FAssignedValues) and (FFont.Handle <> DefaultFont.Handle) then
  begin
    Save := FFont.OnChange;
    FFont.OnChange := nil;
    FFont.Assign(DefaultFont);
    FFont.OnChange := Save;
  end;
  Result := FFont;
end;

function TColumnEh.GetGrid: TCustomDBGridEh;
begin
  if Assigned(Collection) and (Collection is TDBGridColumnsEh)
    then Result := TDBGridColumnsEh(Collection).Grid
    else Result := nil;
end;

function TColumnEh.GetDisplayName: string;
begin
  Result := FFieldName;
  if Result = ''
    then Result := inherited GetDisplayName;
end;

function TColumnEh.GetImeMode: TImeMode;
begin
  if cvImeMode in FAssignedValues
    then Result := FImeMode
    else Result := DefaultImeMode;
end;

function TColumnEh.GetImeName: TImeName;
begin
  if cvImeName in FAssignedValues
    then Result := FImeName
    else Result := DefaultImeName;
end;

function TColumnEh.GetPickList: TStrings;
begin
  if FPickList = nil then
    FPickList := TStringList.Create;
  Result := FPickList;
end;

function TColumnEh.GetReadOnly: Boolean;
begin
  if cvReadOnly in FAssignedValues
    then Result := FReadOnly
    else Result := DefaultReadOnly;
end;

function TColumnEh.GetWidth: Integer;
begin
  if cvWidth in FAssignedValues
    then Result := FWidth
    else Result := DefaultWidth;
(*  //ddd
  if Assigned(Grid) and (Grid.AutoFitColWidths = True) and
    (csWriting in Grid.ComponentState) {and (AutoFitColWidth = True)} then begin
    Result := FInitWidth;
   //\\\
  end;*)
end;

function TColumnEh.IsAlignmentStored: Boolean;
begin
  Result := (cvAlignment in FAssignedValues) and (FAlignment <> DefaultAlignment);
end;

function TColumnEh.IsColorStored: Boolean;
begin
  Result := (cvColor in FAssignedValues) and (FColor <> DefaultColor);
end;

function TColumnEh.IsFontStored: Boolean;
begin
  Result := (cvFont in FAssignedValues);
end;

function TColumnEh.IsImeModeStored: Boolean;
begin
  Result := (cvImeMode in FAssignedValues) and (FImeMode <> DefaultImeMode);
end;

function TColumnEh.IsImeNameStored: Boolean;
begin
  Result := (cvImeName in FAssignedValues) and (FImeName <> DefaultImeName);
end;

function TColumnEh.IsReadOnlyStored: Boolean;
begin
  Result := (cvReadOnly in FAssignedValues) and (FReadOnly <> DefaultReadOnly);
end;

function TColumnEh.IsWidthStored: Boolean;
begin
  Result := (cvWidth in FAssignedValues) and (FWidth <> DefaultWidth);
end;

procedure TColumnEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if cvFont in FAssignedValues then Exit;
  Save := FFont.OnChange;
  FFont.OnChange := nil;
  try
    FFont.Assign(DefaultFont);
  finally
    FFont.OnChange := Save;
  end;
end;

procedure TColumnEh.RestoreDefaults;
var
  FontAssigned: Boolean;
begin
  FontAssigned := cvFont in FAssignedValues;
  FTitle.RestoreDefaults;
  FAssignedValues := [];
  RefreshDefaultFont;
  FPickList.Free;
  FPickList := nil;
  ButtonStyle := cbsAuto;
  Changed(FontAssigned);
//  FInitWidth := Width;
  FKeyList.Free;
  FKeyList := nil;
end;

procedure TColumnEh.SetAlignment(Value: TAlignment);
var
  Grid: TCustomDBGridEh;
begin
  if IsStored then
  begin
    if (cvAlignment in FAssignedValues) and (Value = FAlignment) then Exit;
    FAlignment := Value;
    Include(FAssignedValues, cvAlignment);
    Changed(False);
  end
  else
  begin
    Grid := GetGrid;
    if Assigned(Grid) and (Grid.Datalink.Active) and Assigned(Field)
      then Field.Alignment := Value;
  end;
end;

procedure TColumnEh.SetButtonStyle(Value: TColumnButtonStyleEh);
begin
  if Value = FButtonStyle then Exit;
  FButtonStyle := Value;
  Changed(False);
end;

procedure TColumnEh.SetColor(Value: TColor);
begin
  if (cvColor in FAssignedValues) and (Value = FColor) then Exit;
  FColor := Value;
  Include(FAssignedValues, cvColor);
  Changed(False);
end;

procedure TColumnEh.SetField(Value: TField);
begin
  if FField = Value then Exit;
  FField := Value;
  if Assigned(Value) then
    FFieldName := Value.FieldName;
  if not IsStored then
  begin
    if Value = nil then FFieldName := '';
    RestoreDefaults;
    FInitWidth := Width;
  end;
  {ddd} EnsureSumValue;
  Changed(False);
end;

procedure TColumnEh.SetFieldName(const Value: String);
var
  AField: TField;
  Grid: TCustomDBGridEh;
begin
  AField := nil;
  Grid := GetGrid;
  if Assigned(Grid) and Assigned(Grid.DataLink.DataSet) and
    not (csLoading in Grid.ComponentState) and (Length(Value) > 0)
    then AField := Grid.DataLink.DataSet.FindField(Value); { no exceptions }
  FFieldName := Value;
  SetField(AField);
  FInitWidth := Width;
  Changed(False);
end;

procedure TColumnEh.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
  Include(FAssignedValues, cvFont);
  Changed(False);
end;

procedure TColumnEh.SetImeMode(Value: TImeMode);
begin
  if (cvImeMode in FAssignedValues) or (Value <> DefaultImeMode) then
  begin
    FImeMode := Value;
    Include(FAssignedValues, cvImeMode);
  end;
  Changed(False);
end;

procedure TColumnEh.SetImeName(Value: TImeName);
begin
  if (cvImeName in FAssignedValues) or (Value <> DefaultImeName) then
  begin
    FImeName := Value;
    Include(FAssignedValues, cvImeName);
  end;
  Changed(False);
end;

procedure TColumnEh.SetIndex(Value: Integer);
var
  Grid: TCustomDBGridEh;
  Fld: TField;
begin
  if not IsStored then
  begin
    Grid := GetGrid;
    if Assigned(Grid) and Grid.Datalink.Active then
    begin
      Fld := Grid.Datalink.Fields[Value];
      if Assigned(Fld) then
        Field.Index := Fld.Index;
    end;
  end;
  inherited SetIndex(Value);
end;

procedure TColumnEh.SetPickList(Value: TStrings);
begin
  if Value = nil then
  begin
    FPickList.Free;
    FPickList := nil;
    Exit;
  end;
  PickList.Assign(Value);
end;

procedure TColumnEh.SetPopupMenu(Value: TPopupMenu);
begin
  FPopupMenu := Value;
  if Value <> nil then Value.FreeNotification(GetGrid);
end;

procedure TColumnEh.SetReadOnly(Value: Boolean);
var
  Grid: TCustomDBGridEh;
begin
  Grid := GetGrid;
  if not IsStored and Assigned(Grid) and Grid.Datalink.Active and Assigned(Field)
    then Field.ReadOnly := Value
  else
  begin
    if (cvReadOnly in FAssignedValues) and (Value = FReadOnly) then Exit;
    FReadOnly := Value;
    Include(FAssignedValues, cvReadOnly);
    Changed(False);
  end;
end;

procedure TColumnEh.SetTitle(Value: TColumnTitleEh);
begin
  FTitle.Assign(Value);
end;

procedure TColumnEh.SetWidth(Value: Integer);
var
  Grid: TCustomDBGridEh;
  TM: TTextMetric;
  DoSetWidth: Boolean;
begin     
  DoSetWidth := IsStored;
  if not DoSetWidth then
  begin
    Grid := GetGrid;
    if Assigned(Grid) then
    begin
      if Grid.HandleAllocated and Assigned(Field) and Grid.FUpdateFields then
      with Grid do
      begin
        Canvas.Font := Self.Font;
        GetTextMetrics(Canvas.Handle, TM);
        Field.DisplayWidth := (Value + (TM.tmAveCharWidth div 2) - TM.tmOverhang - 3)
          div {VCL BUG TM.tmAveCharWidth} Canvas.TextWidth('0');
      end;
      if (not Grid.FLayoutFromDataset) or (cvWidth in FAssignedValues) then
        DoSetWidth := True;
    end
    else
      DoSetWidth := True;
  end;
  if DoSetWidth then
  begin
    if ((cvWidth in FAssignedValues) or (Value <> DefaultWidth))
      and (Value <> -1) then
    begin
      FWidth := Value;
      Include(FAssignedValues, cvWidth);
      if (MaxWidth > 0) and (FWidth > MaxWidth) then FWidth := MaxWidth;
      if (FWidth < MinWidth) then FWidth := MinWidth;
    end;
//  if (AutoFitColWidth = False) then FInitWidth := Width;
    Changed(False);
  end;
end;

function TColumnEh.GetAutoFitColWidth: Boolean;
begin
  Result := FAutoFitColWidth;
end;

procedure TColumnEh.SetAutoFitColWidth(Value: Boolean);
begin
  FAutoFitColWidth := Value;
  if Assigned(Grid) and (Grid.AutoFitColWidths = True) and
    not (csLoading in Grid.ComponentState) and not (csDesigning in Grid.ComponentState)
    then Width := FInitWidth;
  Changed(False);
end;

procedure TColumnEh.SetAlwaysShowEditButton(Value: Boolean);
begin
  if (cvAlwaysShowEditButton in FAssignedValues) and (Value = FAlwaysShowEditButton)
    then Exit;
  FAlwaysShowEditButton := Value;
  Include(FAssignedValues, cvAlwaysShowEditButton);
  Changed(False);
end;

procedure TColumnEh.SetWordWrap(Value: Boolean);
begin
  if (cvWordWrap in FAssignedValues) or (Value <> DefaultWordWrap) or
       (Assigned(Grid) and (csLoading in Grid.ComponentState)) then
  begin
    FWordWrap := Value;
    Include(FAssignedValues, cvWordWrap);
  end;
  Changed(False);
end;

function  TColumnEh.GetWordWrap: Boolean;
begin
  if cvWordWrap in FAssignedValues
    then Result := FWordWrap
    else Result := DefaultWordWrap;
end;

function  TColumnEh.IsWordWrapStored: Boolean;
begin
  Result := (cvWordWrap in FAssignedValues) and (FWordWrap <> DefaultWordWrap);
end;

function TColumnEh.DefaultWordWrap: Boolean;
begin
  if GetGrid = nil then
  begin
    Result := False;
    Exit;
  end;
  with GetGrid do
  begin
    if Assigned(Field) then
    begin
      case Field.DataType of
        ftString,ftMemo,ftFmtMemo: Result := True;
      else
        Result := False;
      end;
    end
    else Result := False;
  end;
end;

procedure TColumnEh.SetEndEllipsis(const Value: Boolean);
begin
  if (cvEndEllipsis in FAssignedValues) and (Value = FEndEllipsis) then Exit;
  FEndEllipsis := Value;
  Include(FAssignedValues, cvEndEllipsis);
  Changed(False);
end;

procedure TColumnEh.SetDropDownWidth(Value: Integer);
begin
  if (Value = FDropDownWidth) then Exit;
  FDropDownWidth := Value;
  Changed(False);
end;

function TColumnEh.DefaultLookupDisplayFields: String;
begin
  if Assigned(Field)
    then Result := FField.LookupResultField
    else Result := '';
end;

function TColumnEh.GetLookupDisplayFields: String;
begin
  if cvLookupDisplayFields in FAssignedValues
    then Result := FLookupDisplayFields
    else Result := DefaultLookupDisplayFields;
end;

procedure TColumnEh.SetLookupDisplayFields(Value: String);
begin
  if (cvLookupDisplayFields in FAssignedValues) or (Value <> DefaultLookupDisplayFields) then
  begin
    FLookupDisplayFields := Value;
    Include(FAssignedValues, cvLookupDisplayFields);
  end;
  Changed(False);
end;

function TColumnEh.IsLookupDisplayFieldsStored: Boolean;
begin
  Result := (cvLookupDisplayFields in FAssignedValues) and
            (FLookupDisplayFields <> DefaultLookupDisplayFields);
end;

procedure TColumnEh.SetAutoDropDown(Value: Boolean);
begin
  if (cvAutoDropDown in FAssignedValues) and (Value = FAutoDropDown) then Exit;
  FAutoDropDown := Value;
  Include(FAssignedValues, cvAutoDropDown);
//  Changed(False);
end;

function TColumnEh.CreateFooter: TColumnFooterEh;
begin
  Result := TColumnFooterEh.CreateApart(Self);
end;

procedure TColumnEh.SetFooter(const Value: TColumnFooterEh);
begin
  FFooter.Assign(Value);
end;

procedure TColumnEh.SetVisible(const Value: Boolean);
begin
  if (Value = FVisible) then Exit;
  FVisible := Value;
  Changed(True);
end;

function TColumnEh.GetKeykList: TStrings;
begin
  if FKeyList = nil then
    FKeyList := TStringList.Create;
  Result := FKeyList;
end;

procedure TColumnEh.SetKeykList(const Value: TStrings);
begin
  if Value = nil then
  begin
    FKeyList.Free;
    FKeyList := nil;
    Exit;
  end;
  KeyList.Assign(Value);
  if GetGrid <> nil then GetGrid.Invalidate;
end;

function TColumnEh.GetColumnType: TColumnEhType;
begin
// ctCommon, ctPickList, ctLookupField, ctKeyPickList, ctKeyImageList
  Result := ctCommon;
  if Checkboxes
    then Result := ctCheckboxes
  else if Assigned(Field) and (Field.FieldKind = fkLookup)
    then Result := ctLookupField
  else if Assigned(FPickList) and (FPickList.Count > 0) and not (Assigned(FKeyList) and (FKeyList.Count > 0))
    then Result := ctPickList
  else if Assigned(FKeyList) and (FKeyList.Count > 0)
    then
      if Assigned(ImageList) then
        Result := ctKeyImageList
      else if Assigned(FPickList) then
        Result := ctKeyPickList;
end;

procedure TColumnEh.SetNotInKeyListIndex(const Value: Integer);
begin
  if (FNotInKeyListIndex = Value) then Exit;
  FNotInKeyListIndex := Value;
  if GetGrid <> nil then
    GetGrid.Invalidate;
end;

procedure TColumnEh.SetImageList(const Value: TCustomImageList);
begin
  FImageList := Value;
  if GetGrid <> nil then
    GetGrid.Invalidate;
end;

procedure TColumnEh.SetNextFieldValue(Increment: Extended);
var CanEdit: Boolean;
    ki: Integer;
    AColType: TColumnEhType;
    AField: TField;
    AFields: TList;
    AValue: Variant;
    Text: String;
begin
  CanEdit := True;
  AField := nil;
  if Assigned(Grid) then
    CanEdit := CanEdit and  not Grid.ReadOnly
       and  Grid.FDatalink.Active and not Grid.FDatalink.ReadOnly;
  CanEdit := CanEdit and not ReadOnly;
  if Assigned(Field) then
    if (Field.FieldKind = fkLookUp) then
    begin
      CanEdit := CanEdit and (Field.KeyFields <> '');
      AFields := TList.Create;
      try
        Field.Dataset.GetFieldList(AFields,Field.KeyFields);
        AField := TField(AFields[0]);
        CanEdit := CanEdit and FieldsCanModify(AFields);
      finally
        AFields.Free;
      end;
      //AField := Field.DataSet.FieldByName(Field.KeyFields);
    end else AField := Field
  else CanEdit := False;

  if CanEdit then
   CanEdit := CanEdit and AField.CanModify
    and (not AField.IsBlob or Assigned(AField.OnSetText))
    and Grid.AllowedOperationUpdate;

  if CanEdit and Assigned(Grid) then
  begin
    Grid.FDatalink.Edit;
    CanEdit := Grid.FDatalink.Editing;
    if CanEdit then Grid.FDatalink.Modified;
  end;

  if not CanEdit then Exit;

  AColType := GetColumnType;
  if Grid.InplaceEditorVisible
    then Text := Grid.InplaceEditor.Text
    else Text := Field.Text;
  if (AColType = ctCheckboxes) then
    if CheckboxState = cbChecked
      then CheckboxState := cbUnchecked
      else CheckboxState := cbChecked
  else if (AColType in [ctKeyPickList, ctKeyImageList]) then
  begin
    ki := KeyList.IndexOf(Field.Text);
    if ((ki = -1) or (ki = KeyList.Count-1)) and (Increment = 1) then
      //Field.Text := KeyList.Strings[0]
      UpdateDataValues(Text,KeyList.Strings[0],False)
    else if ((ki = -1) or (ki = 0)) and not (Increment = 1) then
      //Field.Text := KeyList.Strings[KeyList.Count-1]
      UpdateDataValues(Text,KeyList.Strings[KeyList.Count-1],False)
    else if (Increment = 1) then
      //Field.Text := KeyList.Strings[ki+1]
      UpdateDataValues(Text,KeyList.Strings[ki+1],False)
    else
     //Field.Text := KeyList.Strings[ki-1];
      UpdateDataValues(Text,KeyList.Strings[ki-1],False)
  end else if AColType = ctPickList then
  begin
    ki := PickList.IndexOf(Field.Text);
    if ((ki = -1) or (ki = PickList.Count-1)) and (Increment = 1)
      then Field.Text := PickList.Strings[0]
    else if ((ki = -1) or (ki = 0)) and not (Increment = 1)
      then Field.Text := PickList.Strings[PickList.Count-1]
    else if (Increment = 1) then
      //Field.Text := PickList.Strings[ki+1]
      UpdateDataValues(PickList.Strings[ki+1],PickList.Strings[ki+1],True)
    else
      //Field.Text := PickList.Strings[ki-1];
      UpdateDataValues(PickList.Strings[ki-1],PickList.Strings[ki-1],True)
  end else if AColType = ctLookupField then
  begin
    if AField.IsNull or
        not Field.LookupDataSet.Locate(Field.LookUpKeyFields, Field.DataSet.FieldValues[Field.{LookUp}KeyFields], [])
      then Field.LookupDataSet.First
    else if (Increment = 1) then
    begin //Go Forward
      if not Field.LookupDataSet.EOF then
      begin
        Field.LookupDataSet.Next;
        if Field.LookupDataSet.EOF then Field.LookupDataSet.First;
      end else
        Field.LookupDataSet.First;
    end else
    begin //Go Backward
      if not Field.LookupDataSet.BOF then
      begin
        Field.LookupDataSet.Prior;
        if Field.LookupDataSet.BOF then Field.LookupDataSet.Last;
      end else
        Field.LookupDataSet.Last;
    end;
    //Field.DataSet.FieldValues[Field.KeyFields] := Field.LookupDataSet.FieldValues[Field.LookUpKeyFields];
    UpdateDataValues(Text,Field.LookupDataSet.FieldValues[Field.LookUpKeyFields],False);
    Field.Text := Field.LookupDataSet.FieldByName(Field.LookUpResultField).Text;
  end else if Field.DataType in [ftSmallint,ftInteger,ftWord,ftFloat,ftCurrency,ftBCD{$IFDEF EH_LIB_6},ftFMTBcd{$ENDIF}] then
  begin
    if Field.IsNull
      then AValue := -Increment
      else AValue := Field.Value;
    try
      //Field.Value := AValue + Increment;
      UpdateDataValues(Text,AValue + Increment,False);
    except
      on EDatabaseError do ; //Noshow RangeError
      else
       raise;
    end;
  end;
{    if Field.IsNull
     then Field.Value := 0
     else Field.Value := Field.Value + Increment;}
{     else if (Increment = 1) then Field.Value := Field.Value + 1
     else Field.Value := Field.Value - 1;}
//  if Assigned(Grid) and Assigned(Grid.InplaceEditor) and  Grid.InplaceEditor.Visible then
//   GetGrid.InplaceEditor.SelectAll;
end;

procedure TColumnEh.SetMaxWidth(const Value: Integer);
begin
  FMaxWidth := Value;
  if (FMaxWidth > 0) and (Width > FMaxWidth) then
    Width := FMaxWidth;
end;

procedure TColumnEh.SetMinWidth(const Value: Integer);
begin
  FMinWidth := Value;
  if (FMinWidth > 0) and (Width < FMinWidth) then
    Width := FMinWidth;
end;

function TColumnEh.CanModify(TryEdit: Boolean): Boolean;
var AField: TField;
    AFields: TList;
begin
  Result := True;
  AField := nil;
  if Assigned(Grid) then
    Result := Result and  not Grid.ReadOnly
       and  Grid.FDatalink.Active and not Grid.FDatalink.ReadOnly;
  Result := Result and not ReadOnly;
  if Assigned(Field) then
    if (Field.FieldKind = fkLookUp) then
    begin
      Result := Result and (Field.KeyFields <> '');
      AFields := TList.Create;
      try
        Field.Dataset.GetFieldList(AFields,Field.KeyFields);
        AField := TField(AFields[0]);
        Result := Result and FieldsCanModify(AFields);
      finally
        AFields.Free;
      end;
      //AField := Field.DataSet.FieldByName(Field.KeyFields);
    end else
     AField := Field
  else
    Result := False;

  if Result then
   Result := Result and AField.CanModify and
             ((not AField.IsBlob or Assigned(AField.OnSetText)) or
              ((Grid.DrawMemoText = True) and (AField.DataType = ftMemo))) and
             Grid.AllowedOperationUpdate;

  if TryEdit and Result and Assigned(Grid) then
  begin
    Grid.FDatalink.Edit;
    Result := Grid.FDatalink.Editing;
    if Result then Grid.FDatalink.Modified;
  end;
end;

function TColumnEh.AllowableWidth(TryWidth: Integer): Integer;
begin
  Result := TryWidth;
  if (MaxWidth > 0) and (TryWidth > MaxWidth) then Result := MaxWidth;
  if (MinWidth > 0) and (TryWidth < MinWidth) then Result := MinWidth;
end;

function TColumnEh.DisplayText: String;
var KeyIndex:Integer;
begin
  Result := '';
  if not Assigned(Field) then Exit;
  if GetColumnType = ctKeyImageList then Exit;
  if Assigned(KeyList)  and (KeyList.Count > 0) then
  begin
    KeyIndex := KeyList.IndexOf(Field.Text);
    if (KeyIndex > -1) and (KeyIndex < PickList.Count) then
      Result := PickList.Strings[KeyIndex]
    else if (NotInKeylistIndex >= 0) and (NotInKeylistIndex < PickList.Count) then
      Result := PickList.Strings[NotInKeylistIndex];
  end
  else if Assigned(Grid) and (Grid.DrawMemoText = True) and (Field.DataType = ftMemo)
    then Result := Field.AsString
  else
    Result := Field.DisplayText;
end;

procedure TColumnEh.EnsureSumValue;
var i:Integer;
begin
  Footer.EnsureSumValue;
  for i := 0 to Footers.Count-1 do
    Footers[i].EnsureSumValue;
end;

function TColumnEh.GetCheckboxes: Boolean;
begin
  if cvCheckboxes in FAssignedValues
    then Result := FCheckboxes
    else Result := DefaultCheckboxes;
end;

procedure TColumnEh.SetCheckboxes(const Value: Boolean);
begin
  if (cvCheckboxes in FAssignedValues) and (Value = FCheckboxes) then Exit;
  FCheckboxes := Value;
  Include(FAssignedValues, cvCheckboxes);
  Changed(False);
end;

function TColumnEh.DefaultCheckboxes: Boolean;
begin
  if Assigned(Field) and (Field.DataType = ftBoolean)
    then Result := True
    else Result := False;
end;

function TColumnEh.GetCheckboxState: TCheckBoxState;
var
  Text: string;

  function ValueMatch(const ValueList, Value: string): Boolean;
  var
    Pos: Integer;
  begin
    Result := False;
    Pos := 1;
    while Pos <= Length(ValueList) do
      if AnsiCompareText(ExtractFieldName(ValueList, Pos), Value) = 0 then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  if Field <> nil then
    if Field.IsNull then
      Result := cbGrayed
    else if Field.DataType = ftBoolean then
      if Field.AsBoolean
        then Result := cbChecked
        else Result := cbUnchecked
    else
    begin
      Result := cbGrayed;
      Text := Field.Text;
      if (KeyList.Count > 0) and ValueMatch(KeyList[0], Text)
        then Result := cbChecked
      else if (KeyList.Count > 1) and ValueMatch(KeyList[1], Text)
        then Result := cbUnchecked;
    end
  else
    Result := cbUnchecked;
end;

procedure TColumnEh.SetCheckboxState(const Value: TCheckBoxState);
var S:String;
    Pos:Integer;
begin
  if not Assigned(Field) then Exit;
  if Value = cbGrayed then
    //Field.Clear
    UpdateDataValues('',Null,False)
  else
    if (Field.DataType = ftBoolean) then
      if Value = cbChecked
        then UpdateDataValues('',True,False)
        else UpdateDataValues('',False,False)
    else
    begin
      if Value = cbChecked then
        if KeyList.Count > 0 then S := KeyList[0] else S := ''
      else
        if KeyList.Count > 1 then S := KeyList[1] else S := '';
      Pos := 1;
      //Field.Text := ExtractFieldName(S, Pos);
      S := ExtractFieldName(S, Pos);
      UpdateDataValues(S,S,True);
    end;
end;

function TColumnEh.IsCheckboxesStored: Boolean;
begin
  Result := (cvCheckboxes in FAssignedValues);
end;

function TColumnEh.IsIncrementStored: Boolean;
begin
  Result := FIncrement <> 1.0;
end;

function TColumnEh.GetToolTips:Boolean;
begin
  if cvToolTips in FAssignedValues
    then Result := FToolTips
    else Result := DefaultToolTips;
end;

procedure TColumnEh.SetToolTips(const Value: Boolean);
begin
  if (cvToolTips in FAssignedValues) and (Value = FToolTips) then Exit;
  FToolTips := Value;
  Include(FAssignedValues, cvToolTips);
//  Changed(False);
end;

procedure TColumnEh.SetFooters(const Value: TColumnFootersEh);
begin
  FFooters.Assign(Value);
end;

function TColumnEh.CreateFooters: TColumnFootersEh;
begin
  Result := TColumnFootersEh.Create(Self,TColumnFooterEh);
end;

function TColumnEh.UsedFooter(Index: Integer): TColumnFooterEh;
begin
  if Index < Footers.Count
    then Result := Footers[Index]
    else Result := Footer;
end;

function TColumnEh.GetAlwaysShowEditButton: Boolean;
begin
  if cvAlwaysShowEditButton in FAssignedValues
    then Result := FAlwaysShowEditButton
    else Result := DefaultAlwaysShowEditButton;
end;

function TColumnEh.IsAlwaysShowEditButtonStored: Boolean;
begin
  Result := (cvAlwaysShowEditButton in FAssignedValues) and
            (FAlwaysShowEditButton <> DefaultAlwaysShowEditButton);
end;

function TColumnEh.DefaultAlwaysShowEditButton: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.AlwaysShowEditButton
    else Result := False;
end;

function TColumnEh.GetEndEllipsis: Boolean;
begin
  if cvEndEllipsis in FAssignedValues
    then Result := FEndEllipsis
    else Result := DefaultEndEllipsis;
end;

function TColumnEh.IsEndEllipsisStored: Boolean;
begin
  Result := (cvEndEllipsis in FAssignedValues) and (FEndEllipsis <> DefaultEndEllipsis);
end;

function TColumnEh.DefaultEndEllipsis: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.EndEllipsis
    else Result := False;
end;

function TColumnEh.GetAutoDropDown: Boolean;
begin
  if cvAutoDropDown in FAssignedValues
    then Result := FAutoDropDown
    else Result := DefaultAutoDropDown;
end;

function TColumnEh.IsAutoDropDownStored: Boolean;
begin
  Result := (cvAutoDropDown in FAssignedValues) and (FAutoDropDown <> DefaultAutoDropDown);
end;

function TColumnEh.DefaultAutoDropDown: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.AutoDropDown
    else Result := False;
end;

function TColumnEh.GetDblClickNextVal: Boolean;
begin
  if cvDblClickNextVal in FAssignedValues
    then Result := FDblClickNextVal
    else Result := DefaultDblClickNextVal;
end;

function TColumnEh.IsDblClickNextValStored: Boolean;
begin
  Result := (cvDblClickNextVal in FAssignedValues) and (FDblClickNextVal <> DefaultDblClickNextVal);
end;

procedure TColumnEh.SetDblClickNextVal(const Value: Boolean);
begin
  if (cvDblClickNextVal in FAssignedValues) and (Value = FDblClickNextVal) then Exit;
  FDblClickNextVal := Value;
  Include(FAssignedValues, cvDblClickNextVal);
//  Changed(False);
end;

function TColumnEh.DefaultDblClickNextVal: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.DblClickNextVal
    else Result := False;
end;

function TColumnEh.IsToolTipsStored: Boolean;
begin
  Result := (cvToolTips in FAssignedValues) and (FToolTips <> DefaultToolTips);
end;

function TColumnEh.DefaultToolTips: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.ToolTips
    else Result := False;
end;

function TColumnEh.GetDropDownSizing: Boolean;
begin
  if cvDropDownSizing in FAssignedValues
    then Result := FDropDownSizing
    else Result := DefaultDropDownSizing;
end;

function TColumnEh.IsDropDownSizingStored: Boolean;
begin
  Result := (cvDropDownSizing in FAssignedValues) and (FDropDownSizing <> DefaultDropDownSizing);
end;

procedure TColumnEh.SetDropDownSizing(const Value: Boolean);
begin
  if (cvDropDownSizing in FAssignedValues) and (Value = FDropDownSizing) then Exit;
  FDropDownSizing := Value;
  Include(FAssignedValues, cvDropDownSizing);
//  Changed(False);
end;

function TColumnEh.DefaultDropDownSizing: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.DropDownSizing
    else Result := False;
end;

function TColumnEh.GetDropDownShowTitles: Boolean;
begin
  if cvDropDownShowTitles in FAssignedValues
    then Result := FDropDownShowTitles
    else Result := DefaultDropDownShowTitles;
end;

function TColumnEh.IsDropDownShowTitlesStored: Boolean;
begin
  Result := (cvDropDownShowTitles in FAssignedValues) and (FDropDownShowTitles <> DefaultDropDownShowTitles);
end;

procedure TColumnEh.SetDropDownShowTitles(const Value: Boolean);
begin
  if (cvDropDownShowTitles in FAssignedValues) and (Value = FDropDownShowTitles) then Exit;
  FDropDownShowTitles := Value;
  Include(FAssignedValues, cvDropDownShowTitles);
//  Changed(False);
end;

function TColumnEh.DefaultDropDownShowTitles: Boolean;
begin
  if GetGrid <> nil
    then Result := GetGrid.ColumnDefValues.DropDownShowTitles
    else Result := False;
end;

procedure TColumnEh.SetOnGetCellParams(const Value: TGetColCellParamsEventEh);
begin
  if @FOnGetCellParams <> @Value then
  begin
    FOnGetCellParams := Value;
    if GetGrid <> nil then GetGrid.Invalidate;
  end;
end;

procedure TColumnEh.GetColCellParams(EditMode: Boolean; ColCellParamsEh: TColCellParamsEh);
begin
  if Assigned(OnGetCellParams) then
    OnGetCellParams(Self, EditMode,  ColCellParamsEh);
end;

procedure TColumnEh.FillColCellParams(ColCellParamsEh: TColCellParamsEh);
begin
  with ColCellParamsEh do
  begin
    FRow := -1;
    FCol := -1;
    FState := [];
    FFont := Self.Font;
    Background := Self.Color;
    Alignment := Self.Alignment;
    ImageIndex := Self.GetImageIndex;
    Text := Self.DisplayText;
    CheckboxState := Self.CheckboxState;
    FReadOnly := Self.ReadOnly;
  end;
end;

function  TColumnEh.GetImageIndex: Integer;
begin
  Result := -1;
  if (GetColumnType = ctKeyImageList) and Assigned(Field) then
  begin
    Result := KeyList.IndexOf(Field.Text);
    if Result = -1 then Result := NotInKeyListIndex;
  end;
end;

procedure TColumnEh.UpdateDataValues(Text: String; Value: Variant; UseText: Boolean);
var Processed: Boolean;
begin
  if Grid <> nil then
  begin
    Processed := False;
    if Assigned(FUpdateData) then FUpdateData(Self,Text,Value,UseText,Processed);
    if Processed then Exit;
    if Field = nil then Exit;
    if not UseText then
    begin
      if (Field.FieldKind = fkLookup) and (Field.KeyFields <> '')
        then DataSetSetFieldValues(Field.DataSet, Field.KeyFields, Value)
        else Field.Value := Value;
    end else if (Grid.DrawMemoText = True) and (Field.DataType = ftMemo)
      then Field.AsString := Text
    else
      Field.Text := Text;
  end;
end;

procedure TColumnEh.DropDown;
begin
  if Assigned(Grid) and Grid.InplaceEditorVisible and
     (Grid.InplaceEditor is TDBGridInplaceEdit) then
    TDBGridInplaceEdit(Grid.InplaceEditor).DropDown;
end;

{ TDBGridColumnsEh }

constructor TDBGridColumnsEh.Create(Grid: TCustomDBGridEh; ColumnClass: TColumnEhClass);
begin
  inherited Create(ColumnClass);
  FGrid := Grid;
end;

function TDBGridColumnsEh.Add: TColumnEh;
begin
  Result := TColumnEh(inherited Add);
end;

function TDBGridColumnsEh.GetColumn(Index: Integer): TColumnEh;
begin
  Result := TColumnEh(inherited Items[Index]);
end;

function TDBGridColumnsEh.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

function TDBGridColumnsEh.GetState: TDBGridColumnsState;
begin
  Result := TDBGridColumnsState((Count > 0) and Items[0].IsStored);
end;

procedure TDBGridColumnsEh.LoadFromFile(const Filename: string);
var
  S: TFileStream;
begin
  S := TFileStream.Create(Filename, fmOpenRead);
  try
    LoadFromStream(S);
  finally
    S.Free;
  end;
end;

type
  TColumnsWrapper = class(TComponent)
  private
    FColumns: TDBGridColumnsEh;
  published
    property Columns: TDBGridColumnsEh read FColumns write FColumns;
  end;

procedure TDBGridColumnsEh.LoadFromStream(S: TStream);
var
  Wrapper: TColumnsWrapper;
begin
  Wrapper := TColumnsWrapper.Create(nil);
  try
    Wrapper.Columns := FGrid.CreateColumns;
    S.ReadComponent(Wrapper);
    Assign(Wrapper.Columns);
  finally
    Wrapper.Columns.Free;
    Wrapper.Free;
  end;
end;

procedure TDBGridColumnsEh.RestoreDefaults;
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Count-1 do
      Items[I].RestoreDefaults;
  finally
    EndUpdate;
  end;
end;

procedure TDBGridColumnsEh.RebuildColumns;
var
  I: Integer;
begin
  if Assigned(FGrid) and Assigned(FGrid.DataSource) and
    Assigned(FGrid.Datasource.Dataset) then
  begin
    FGrid.BeginLayout;
    try
      Clear;
      with FGrid.Datasource.Dataset do
        for I := 0 to FieldCount-1 do
          Add.FieldName := Fields[I].FieldName
    finally
      FGrid.EndLayout;
    end
  end
  else
    Clear;
end;

procedure TDBGridColumnsEh.SaveToFile(const Filename: string);
var
  S: TStream;
begin
  S := TFileStream.Create(Filename, fmCreate);
  try
    SaveToStream(S);
  finally
    S.Free;
  end;
end;

procedure TDBGridColumnsEh.SaveToStream(S: TStream);
var
  Wrapper: TColumnsWrapper;
begin
  Wrapper := TColumnsWrapper.Create(nil);
  try
    Wrapper.Columns := Self;
    S.WriteComponent(Wrapper);
  finally
    Wrapper.Free;
  end;
end;

procedure TDBGridColumnsEh.SetColumn(Index: Integer; Value: TColumnEh);
begin
  Items[Index].Assign(Value);
end;

procedure TDBGridColumnsEh.SetState(NewState: TDBGridColumnsState);
begin
  if NewState = State then Exit;
  if NewState = csDefault
    then Clear
    else RebuildColumns;
end;

procedure TDBGridColumnsEh.Update(Item: TCollectionItem);
var
  Raw: Integer;
  OldWidth: Integer;
begin
  if (FGrid = nil) or (csLoading in FGrid.ComponentState) then Exit;
  if (Item = nil) then
  begin
    FGrid.LayoutChanged;
  end else
  begin
    Raw := FGrid.DataToRawColumn(Item.Index);
    FGrid.InvalidateCol(Raw);
    //FGrid.ColWidths[Raw] := TColumnEh(Item).Width;
    if (FGrid.AutoFitColWidths = False) or (csDesigning in FGrid.ComponentState) then
    begin
       //dddFGrid.ColWidths[Raw] := TColumnEh(Item).Width;
      if (FGrid.ColWidths[Raw] <> TColumnEh(Item).Width)
        then FGrid.ColWidths[Raw] :=
          iif(TColumnEh(Item).Visible,TColumnEh(Item).Width,iif(dgColLines in FGrid.Options,-1,0))
       else if (FGrid.UseMultiTitle = True) {and not (csDesigning in FGrid.ComponentState)}
         then FGrid.LayoutChanged; // If Title.Caption was changed
    end else if FGrid.ColWidths[Raw] <> -1 then
    begin
      OldWidth := TColumnEh(Item).FInitWidth;
      TColumnEh(Item).FInitWidth :=
        MulDiv(TColumnEh(Item).FInitWidth,TColumnEh(Item).Width,FGrid.ColWidths[Raw]);
      if (Raw <> FGrid.ColCount - 1) then
      begin
        Inc(FGrid.Columns[Raw - FGrid.FIndicatorOffset + 1].FInitWidth,
            OldWIdth - FGrid.FColumns[Raw - FGrid.FIndicatorOffset].FInitWidth);
        if (FGrid.Columns[Raw - FGrid.FIndicatorOffset + 1].FInitWidth < 0)
          then FGrid.Columns[Raw - FGrid.FIndicatorOffset + 1].FInitWidth := 0;
       end;
       FGrid.LayoutChanged;
    end;
  end;
  if (Items[FGrid.SelectedIndex].Visible = False) and (FGrid.VisibleColumns.Count > 0)
    then FGrid.SelectedIndex := FGrid.VisibleColumns[0].Index;
  FGrid.InvalidateEditor;
end;

function TDBGridColumnsEh.InternalAdd: TColumnEh;
begin
  Result := Add;
  Result.IsStored := False;
end;

function TDBGridColumnsEh.ExistFooterValueType(AFooterValueType: TFooterValueType): Boolean;
var i:Integer;
begin
  Result := False;
  for i:=0 to Count-1 do
  begin
    if (Items[i].Footer.ValueType = AFooterValueType) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{ TBookmarkListEh }

constructor TBookmarkListEh.Create(AGrid: TCustomDBGridEh);
begin
  inherited Create;
  FList := TStringList.Create;
  FList.OnChange := StringsChanged;
  FGrid := AGrid;
end;

destructor TBookmarkListEh.Destroy;
begin
  Clear;
  {ddd}FGrid.Selection.UpdateState;
  FList.Free;
  inherited Destroy;
end;

procedure TBookmarkListEh.Clear;
begin
  if FList.Count = 0 then Exit;
  FList.Clear;
 {ddd}FGrid.Selection.UpdateState;
  FGrid.Invalidate;
end;

function TBookmarkListEh.Compare(const Item1, Item2: TBookmarkStr): Integer;
begin
  with FGrid.Datalink.Datasource.Dataset do
    Result := CompareBookmarks(TBookmark(Item1), TBookmark(Item2));
end;

function TBookmarkListEh.CurrentRow: TBookmarkStr;
begin
  if not FLinkActive then RaiseGridError(sDataSetClosed);
  Result := FGrid.Datalink.Datasource.Dataset.Bookmark;
end;

function TBookmarkListEh.GetCurrentRowSelected: Boolean;
var
  Index: Integer;
begin
  Result := Find(CurrentRow, Index);
end;

function TBookmarkListEh.Find(const Item: TBookmarkStr; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  if (Item = FCache) and (FCacheIndex >= 0) then
  begin
    Index := FCacheIndex;
    Result := FCacheFind;
    Exit;
  end;
  Result := False;
  L := 0;
  H := FList.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Compare(FList[I], Item);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
  FCache := Item;
  FCacheIndex := Index;
  FCacheFind := Result;
end;

function TBookmarkListEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TBookmarkListEh.GetItem(Index: Integer): TBookmarkStr;
begin
  Result := FList[Index];
end;

function TBookmarkListEh.IndexOf(const Item: TBookmarkStr): Integer;
begin
  if not Find(Item, Result) then
    Result := -1;
end;

procedure TBookmarkListEh.LinkActive(Value: Boolean);
begin
  Clear;
  {ddd}FGrid.Selection.UpdateState;
  FLinkActive := Value;
end;

procedure TBookmarkListEh.Delete;
var
  I: Integer;
begin
  with FGrid.Datalink.Datasource.Dataset do
  begin
    DisableControls;
    try
      for I := FList.Count-1 downto 0 do
      begin
        Bookmark := FList[I];
        Delete;
        FList.Delete(I);
      end;
    finally
      EnableControls;
    end;
  end;
 {ddd}FGrid.Selection.UpdateState;
end;

function TBookmarkListEh.Refresh: Boolean;
var
  I: Integer;
begin
  Result := False;
  with FGrid.DataLink.Datasource.Dataset do
  try
    CheckBrowseMode;
    for I := FList.Count - 1 downto 0 do
      if not BookmarkValid(TBookmark(FList[I])) then
      begin
        Result := True;
        FList.Delete(I);
      end;
  finally
    {ddd}FGrid.Selection.UpdateState;
    UpdateCursorPos;
    if Result then FGrid.Invalidate;
  end;
end;

procedure TBookmarkListEh.SetCurrentRowSelected(Value: Boolean);
var
  Index: Integer;
  Current: TBookmarkStr;
begin
  Current := CurrentRow;
  if {(Length(Current) = 0) or allow select new rec} (Find(Current, Index) = Value)
    then Exit;
  if Value
    then FList.Insert(Index, Current)
    else FList.Delete(Index);
  GridInvalidateRow(FGrid,FGrid.Row);// FGrid.InvalidateRow(FGrid.Row); vcl bug??
  //ddd
  if (FGrid.Selection.FSelectionType <> gstRecordBookmarks) and (Count > 0) then
  begin
    FGrid.Selection.Clear;
    FGrid.Selection.FSelectionType := gstRecordBookmarks;
  end;
  FGrid.Selection.UpdateState;
  //\\\
end;

procedure TBookmarkListEh.StringsChanged(Sender: TObject);
begin
  FCache := '';
  FCacheIndex := -1;
end;


procedure TBookmarkListEh.SelectAll;
var bm:TBookMarkStr;
begin
  if not FLinkActive then Exit;
  with FGrid.Datalink.Datasource.Dataset do
  begin
    DisableControls;
    try
      bm := Bookmark;
      First;
      while EOF = False do
      begin
        SetCurrentRowSelected(True);
        Next;
      end;
      Bookmark := bm;
    finally
      EnableControls;
    end;
  end;
end;

{ TCustomDBGridEh }

var
  DrawBitmap: TBitmap;
  UserCount: Integer;

procedure UsesBitmap;
begin
  if UserCount = 0 then
    DrawBitmap := TBitmap.Create;
  Inc(UserCount);
end;

procedure ReleaseBitmap;
begin
  Dec(UserCount);
  if UserCount = 0 then DrawBitmap.Free;
end;

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
var
  B, R: TRect;
  Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOut for solid colors }
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;
    ExtTextOut(ACanvas.Handle, Left, ARect.Top + DY, ETO_OPAQUE or
      ETO_CLIPPED, @ARect, PChar(Text), Length(Text), nil);
  end else
  begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        DrawText(Handle, PChar(Text), Length(Text), R, AlignFlags[Alignment]);
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

function MinimizeText(const Text: string; Canvas: TCanvas; MaxWidth: Integer): string;
var
  I: Integer;
begin
  Result := Text;
  I := 1;
  while (I <= Length(Text)) and (Canvas.TextWidth(Result) > MaxWidth) do
  begin
    Inc(I);
    Result := Copy(Text, 1, Max(0, Length(Text) - I)) + '...';
  end;
end;

{new WriteTextEh}{}
procedure WriteTextEh(ACanvas: TCanvas; ARect: TRect; FillRect:Boolean; DX, DY: Integer;
  Text: string; Alignment: TAlignment; Layout: TTextLayout; MultyL:Boolean; EndEllipsis:Boolean; LeftMarg,RightMarg:Integer);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_EXPANDTABS or DT_NOPREFIX );
var
  rect1: TRect;
  txth, DrawFlag, Left, TextWidth: Integer;
  lpDTP :  TDrawTextParams;
  B: TRect;
//  TM: TTextMetric;
  I: TColorRef;
begin

(*
  if (FillRect = True) then ACanvas.FillRect(ARect);

  DrawFlag := 0;
  if (MultyL = True) then DrawFlag := DrawFlag or DT_WORDBREAK;
  if (EndEllipsis = True) then DrawFlag := DrawFlag or DT_END_ELLIPSIS;
  DrawFlag := DrawFlag or AlignFlags[Alignment];

   {}
  rect1.Left := 0; rect1.Top := 0; rect1.Right := 0; rect1.Bottom := 0;
  rect1 := ARect;  {}

  lpDTP.cbSize := SizeOf(lpDTP);
  lpDTP.uiLengthDrawn := Length(Text);
  lpDTP.iLeftMargin := LeftMarg;
  lpDTP.iRightMargin := RightMarg;

  InflateRect(rect1, -DX, -DY);

  if (Layout <> tlTop) {and (MultyL = True)} then
    txth := DrawTextEx(ACanvas.Handle,PChar(Text), Length(Text),    {}
       rect1, DrawFlag or DT_CALCRECT,@lpDTP) // �������� �������.
  else txth := 0;
  rect1 := ARect;  {}
  InflateRect(rect1, -DX, -DY);

  case Layout of
   tlTop: ;
   tlBottom: rect1.top := rect1.Bottom - txth;
   tlCenter: rect1.top := rect1.top + ((rect1.Bottom-rect1.top) div 2) - (txth div 2);
  end;

  if DX > 0 then rect1.Bottom := rect1.Bottom + 1;
  DrawTextEx(ACanvas.Handle,PChar(Text), Length(Text),    {}
     rect1, DrawFlag,@lpDTP); {}
*)
  I := ColorToRGB(ACanvas.Brush.Color);
  if (GetNearestColor(ACanvas.Handle, I) = I) and not MultyL then
  begin                       { Use ExtTextOut for solid colors and single-line text}
    if EndEllipsis then Text := MinimizeText(Text,ACanvas,ARect.Right - ARect.Left - DX);
    if (Alignment <> taLeftJustify) and (ACanvas.Font.Style * [fsBold, fsItalic] <> []) then
    begin
      TextWidth := GetTextWidth(ACanvas,Text)
    end else
      TextWidth := ACanvas.TextWidth(Text);

    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - TextWidth - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1 - (TextWidth shr 1) ;
    end;
    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end
  else begin
    DrawBitmap.Canvas.Lock;
    try
      DrawBitmap.Width := Max(DrawBitmap.Width, ARect.Right - ARect.Left);
      DrawBitmap.Height := Max(DrawBitmap.Height, ARect.Bottom - ARect.Top);
      B := Rect(0,0,ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
      DrawBitmap.Canvas.Font := ACanvas.Font;
      DrawBitmap.Canvas.Font.Color := ACanvas.Font.Color;
      DrawBitmap.Canvas.Brush := ACanvas.Brush;
      DrawBitmap.Canvas.Brush.Style := bsSolid;

      SetBkMode(DrawBitmap.Canvas.Handle, TRANSPARENT); 

      {if (FillRect = True) then }DrawBitmap.Canvas.FillRect(B);

      DrawFlag := 0;
      if (MultyL = True) then DrawFlag := DrawFlag or DT_WORDBREAK;
      if (EndEllipsis = True) then DrawFlag := DrawFlag or DT_END_ELLIPSIS;
      DrawFlag := DrawFlag or AlignFlags[Alignment];

      rect1 := B;  {}

      lpDTP.cbSize := SizeOf(lpDTP);
      lpDTP.uiLengthDrawn := Length(Text);
      lpDTP.iLeftMargin := LeftMarg;
      lpDTP.iRightMargin := RightMarg;

      InflateRect(rect1, -DX, -DY);

      if (Layout <> tlTop) {and (MultyL = True)} then
        txth := DrawTextEx(ACanvas.Handle,PChar(Text), Length(Text),    {}
           rect1, DrawFlag or DT_CALCRECT,@lpDTP) // �������� �������.
      else txth := 0;
      rect1 := B;  {}
      InflateRect(rect1, -DX, -DY);

      case Layout of
       tlTop: ;
       tlBottom: rect1.top := rect1.Bottom - txth;
       tlCenter: rect1.top := rect1.top + ((rect1.Bottom-rect1.top) div 2) - (txth div 2);
      end;

      if DX > 0 then rect1.Bottom := rect1.Bottom + 1;
        DrawTextEx(DrawBitmap.Canvas.Handle,PChar(Text), Length(Text), rect1, DrawFlag,@lpDTP);

      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

function CreateVerticalFont(Font: TFont): HFont;
var
  LogFont:TLogFont;
begin
  with LogFont do
  begin
    lfEscapement := 900;
    lfOrientation := 900;

    lfHeight := Font.Height;
    lfWidth := 0; { have font mapper choose }
    if fsBold in Font.Style
      then lfWeight := FW_BOLD
      else lfWeight := FW_NORMAL;
    lfItalic := Byte(fsItalic in Font.Style);
    lfUnderline := Byte(fsUnderline in Font.Style);
    lfStrikeOut := Byte(fsStrikeOut in Font.Style);
    lfCharSet := Byte(Font.Charset);
    if AnsiCompareText(Font.Name, 'Default') = 0 // do not localize
      then StrPCopy(lfFaceName, DefFontData.Name)
      else StrPCopy(lfFaceName, Font.Name);
    lfQuality := DEFAULT_QUALITY;
    { Everything else as default }
    lfOutPrecision := OUT_TT_ONLY_PRECIS; //OUT_DEFAULT_PRECIS;
    lfClipPrecision := CLIP_DEFAULT_PRECIS;
    case Font.Pitch of
      fpVariable: lfPitchAndFamily := VARIABLE_PITCH;
      fpFixed: lfPitchAndFamily := FIXED_PITCH;
    else
      lfPitchAndFamily := DEFAULT_PITCH;
    end;
  end;

  Result := CreateFontIndirect(LogFont);
end;

procedure Swap(var a,b:Integer);
var c:Integer;
begin
  c := a;
  a := b;
  b := c;
end;

function WriteTextVerticalEh(ACanvas:TCanvas;
                          ARect: TRect;          // Draw rect and ClippingRect
                          FillRect:Boolean;      // Fill rect Canvas.Brash.Color
                          DX, DY: Integer;       // InflateRect(Rect, -DX, -DY) for text
                          Text: string;          // Draw text
                          Alignment: TAlignment; // Text alignment
                          Layout: TTextLayout;   // Text layout
                          EndEllipsis:Boolean;   // Truncate long text by ellipsis
                          CalcTextExtent:Boolean   //
                          ):Integer;
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
var
  B, R: TRect;
  Left, Top, TextWidth: Integer;
  I: TColorRef;
  tm: TTextMetric;
  otm:TOutlineTextMetric;
  Overhang:Integer;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  Swap(ARect.Top,ARect.Bottom);

  ACanvas.Font.Handle := CreateVerticalFont(ACanvas.Font);
  try
  GetTextMetrics(ACanvas.Handle,tm);
  Overhang := tm.tmOverhang;
  if (tm.tmPitchAndFamily and TMPF_TRUETYPE <> 0) and
     (ACanvas.Font.Style * [fsItalic] <> []) then
  begin
    otm.otmSize := SizeOf(otm);
    GetOutlineTextMetrics(ACanvas.Handle,otm.otmSize,@otm);
    Overhang := (tm.tmHeight-tm.tmInternalLeading) * otm.otmsCharSlopeRun div otm.otmsCharSlopeRise;
  end;

  TextWidth := ACanvas.TextWidth(Text);
  Result := TextWidth + Overhang;
  if CalcTextExtent then Exit;

  if (not FillRect) or (GetNearestColor(ACanvas.Handle, I) = I) then
  begin                       { Use ExtTextOut for solid colors }
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextHeight(Text);
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - ((ACanvas.TextHeight(Text)+tm.tmOverhang) shr 1);
    end;
    case Layout of
      tlTop: Top := ARect.Bottom + TextWidth + Overhang;// + 3;
      tlBottom: Top := ARect.Top - DY;
    else
      Top := ARect.Top - (ARect.Top - ARect.Bottom) shr 1
        + ((TextWidth+Overhang) shr 1);
    end;
    ACanvas.TextRect(ARect, Left, Top, Text);
  end else
  begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Top - Bottom);
        R := Rect(DX, Top - Bottom - 1, Right - Left - 1, DY);
        B := Rect(0, 0, Right - Left, Top - Bottom);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment]);
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
  finally
    ACanvas.Font.Height := ACanvas.Font.Height;
  end;
end;

procedure DrawClipped(imList: TCustomImageList;
                      ACanvas:TCanvas; ARect:TRect; Index,
                      ALeftMarg: Integer; Align:TAlignment);
var CheckedRect,AUnionRect:TRect;
    OldRectRgn,RectRgn:HRGN;
    r,x,y:Integer;
begin
  case Align of
    taLeftJustify: x := ARect.Left + ALeftMarg;
    taRightJustify: x := ARect.Right - imList.Width + ALeftMarg;
  else
    x := (ARect.Right + ARect.Left - imList.Width) div 2 + ALeftMarg;
  end;
  y := (ARect.Bottom + ARect.Top - imList.Height) div 2;
  CheckedRect := Rect(X,Y,X+imList.Width,Y+imList.Height);
  UnionRect(AUnionRect,CheckedRect,ARect);
  if EqualRect(AUnionRect,ARect) then // ARect containt image
    imList.Draw(ACanvas, X, Y, Index)
  else
  begin                          // Need clip
    OldRectRgn := CreateRectRgn(0,0,0,0);
    r := GetClipRgn(ACanvas.Handle, OldRectRgn);
    RectRgn := CreateRectRgn(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom);
    SelectClipRgn(ACanvas.Handle, RectRgn);
    DeleteObject(RectRgn);

    imList.Draw(ACanvas, X, Y, Index);

    if r = 0
      then SelectClipRgn(ACanvas.Handle, 0)
      else SelectClipRgn(ACanvas.Handle, OldRectRgn);
    DeleteObject(OldRectRgn);
  end;
end;

constructor TCustomDBGridEh.Create(AOwner: TComponent);
var
  Bmp: TBitmap;
begin
{$ifdef eval}
  {$INCLUDE eval}
{$endif}

  inherited Create(AOwner);
  inherited DefaultDrawing := False;
  FAcquireFocus := True;
  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromResourceName(HInstance, bmArrow);
    FIndicators := TImageList.CreateSize(Bmp.Width, Bmp.Height);
    FIndicators.AddMasked(Bmp, clWhite);
    Bmp.LoadFromResourceName(HInstance, bmEdit);
    FIndicators.AddMasked(Bmp, clWhite);
    Bmp.LoadFromResourceName(HInstance, bmInsert);
    FIndicators.AddMasked(Bmp, clWhite);
    Bmp.LoadFromResourceName(HInstance, bmMultiDot);
    FIndicators.AddMasked(Bmp, clWhite);
    Bmp.LoadFromResourceName(HInstance, bmMultiArrow);
    FIndicators.AddMasked(Bmp, clWhite);
    Bmp.LoadFromResourceName(HInstance, bmEditWhite);
    FIndicators.AddMasked(Bmp, clTeal);

    RecreateInplaceSearchIndicator;
    Bmp.LoadFromResourceName(HInstance, bmSmDown);
    FSortMarkerImages := TImageList.CreateSize(Bmp.Width, Bmp.Height);
    FSortMarkerImages.AddMasked(Bmp, clFuchsia);
    Bmp.LoadFromResourceName(HInstance, bmSmUp);
    FSortMarkerImages.AddMasked(Bmp, clFuchsia);
  finally
    Bmp.Free;
  end;
  FTitleOffset := 1;
  FIndicatorOffset := 1;
  FUpdateFields := True;
  FOptions := [dgEditing, dgTitles, dgIndicator, dgColumnResize,
    dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit];
  DesignOptionsBoost := [goColSizing];
  VirtualView := True;
  UsesBitmap;
  ScrollBars := ssHorizontal;
  inherited Options := [goFixedHorzLine, goFixedVertLine, goHorzLine,
    goVertLine, goColSizing, goColMoving, goTabs, goEditing];
  FColumnDefValues := TColumnDefValuesEh.Create(Self);
  FColumns := CreateColumns;
  {ddd} FVisibleColumns := TColumnsEhList.Create;
  inherited RowCount := 2;
  inherited ColCount := 2;
  FDataLink := TGridDataLinkEh.Create(Self);
  Color := clWindow;
  {ddd} FooterColor  := clWindow;
  ParentColor := False;
  FTitleFont := TFont.Create;
  FTitleFont.OnChange := TitleFontChanged;
  FSaveCellExtents := False;
  FUserChange := True;
  FDefaultDrawing := True;
  FUpdatingEditor := False;
  FBookmarks := TBookmarkListEh.Create(Self);
  HideEditor;

  FTitleHeight := 0;
  FTitleHeightFull := 0;
  FTitleLines := 0;
  FLeafFieldArr := nil;
  FHeadTree := THeadTreeNode.CreateText('Root',10,0);
  FVTitleMargin := 10;
  FHTitleMargin := 0;
  FUseMultiTitle := False;
  FInitColWidth := TList.Create;
  FRowSizingAllowed := False;
  FDefaultRowChanged := False;
  FSumList := TDBGridEhSumList.Create(Self);
  FSumList.SumListChanged := SumListChanged;
  FSumList.OnRecalcAll := SumListRecalcAll;
  FHorzScrollBar := TDBGridEhScrollBar.Create(Self,sbHorizontal);
  FVertScrollBar := TDBGridEhScrollBar.Create(Self,sbVertical);
  FOptionsEh := [dghFixed3D,dghHighlightFocus,dghClearSelection];
  FSortMarkedColumns := TColumnsEhList.Create;
  FPressedCol := -1;
  FTopLeftVisible := True;
  FSelection := TDBGridEhSelection.Create(Self);
  FAllowedOperations := [alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh];
  FFooterFont := TFont.Create;
  FFooterFont.OnChange := FooterFontChanged;
  FInterlinear := 4;
  FAllowedSelections := [gstRecordBookmarks .. gstAll];
  FColCellParamsEh := TColCellParamsEh.Create;
end;

destructor TCustomDBGridEh.Destroy;
begin
  FColCellParamsEh.Free;
  Selection.Clear;
  FColumns.Free; FColumns := nil;
  FColumnDefValues.Free;
  FVisibleColumns.Free; FVisibleColumns := nil;
  FSortMarkedColumns.Free; FSortMarkedColumns := nil;
  FHorzScrollBar.Free; FHorzScrollBar := nil;
  FVertScrollBar.Free; FVertScrollBar := nil;
  FDataLink.Free; FDataLink := nil;
  FIndicators.Free; FIndicators := nil;
  FTitleFont.Free; FTitleFont := nil;
  FBookmarks.Free; FBookmarks := nil;
  inherited Destroy;
  ReleaseBitmap;
  FSortMarkerImages.Free;
  if FLeafFieldArr <> nil then FreeMem(FLeafFieldArr);
  FHeadTree.Free;
  FInitColWidth.Free;
  FSumList.Free;
  Selection.Free;
  FFooterFont.Free; FFooterFont := nil;
  if FHintFont <> nil then FHintFont.Free;
end;

function TCustomDBGridEh.AcquireFocus: Boolean;
begin
  Result := True;
  if FAcquireFocus and CanFocus and not (csDesigning in ComponentState) then
  begin
    SetFocus;
    Result := Focused or (InplaceEditor <> nil) and InplaceEditor.Focused;
    // VCL Bug is fixed
    if not Result and (Screen.ActiveForm  <> nil) and
      (Screen.ActiveForm.FormStyle = fsMDIForm) then
    begin
      Windows.SetFocus(Handle);
      Result := Focused or (InplaceEditor <> nil) and InplaceEditor.Focused;
    end;
    // VCL Bug is fixed\\
  end;
end;

function TCustomDBGridEh.RawToDataColumn(ACol: Integer): Integer;
begin
  Result := ACol - FIndicatorOffset;
end;

function TCustomDBGridEh.DataToRawColumn(ACol: Integer): Integer;
begin
  Result := ACol + FIndicatorOffset;
end;

function TCustomDBGridEh.AcquireLayoutLock: Boolean;
begin
  Result := (FUpdateLock = 0) and (FLayoutLock = 0);
  if Result then BeginLayout;
end;

procedure TCustomDBGridEh.BeginLayout;
begin
  BeginUpdate;
  if FLayoutLock = 0 then Columns.BeginUpdate;
  Inc(FLayoutLock);
end;

procedure TCustomDBGridEh.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TCustomDBGridEh.CancelLayout;
begin
  if FLayoutLock > 0 then
  begin
    if FLayoutLock = 1 then
      Columns.EndUpdate;
    Dec(FLayoutLock);
    EndUpdate;
  end;
end;

function TCustomDBGridEh.CanEditAcceptKey(Key: Char): Boolean;
begin
  with Columns[SelectedIndex] do
    if FDatalink.Active and Assigned(Field) then
    begin
      if TDBGridInplaceEdit(InplaceEditor).FReadOnlyStored
        then Result := not TDBGridInplaceEdit(InplaceEditor).ReadOnly
        else Result := True;
      if Assigned(KeyList) and (KeyList.Count > 0)
        then Result := Result
        else Result := Result and Field.IsValidChar(Key);
    end else
    begin
      if TDBGridInplaceEdit(InplaceEditor).FReadOnlyStored
        then Result := not TDBGridInplaceEdit(InplaceEditor).ReadOnly
        else Result := False;
    end;
end;

function TCustomDBGridEh.CanEditModifyColumn(Index:Integer):Boolean;
begin
  Result := Columns[Index].CanModify(False) and (dgEditing in Options);
end;

function TCustomDBGridEh.CanEditModifyText: Boolean;
begin
  Result := False;
  if TDBGridInplaceEdit(InplaceEditor).FReadOnlyStored then
  begin
    Result := not TDBGridInplaceEdit(InplaceEditor).ReadOnly;
    if Result then
    begin
      FDatalink.Edit;
      FDatalink.Modified;
    end else
      Exit;
  end;
  if not ReadOnly and FDatalink.Active and not FDatalink.Readonly then
  with Columns[SelectedIndex] do
    if (not ReadOnly) and Assigned(Field) and Field.CanModify
      and (not Field.IsBlob or Assigned(Field.OnSetText)
            {d/}or ((DrawMemoText = True) and (Field.DataType = ftMemo)) {d\})
      and CanModify(False) then
    begin
      FDatalink.Edit;
      Result := FDatalink.Editing;
      if Result then FDatalink.Modified;
    end;
end;

function TCustomDBGridEh.CanEditModify: Boolean;
begin
  {Result := False;
  if not ReadOnly and FDatalink.Active and not FDatalink.Readonly then
  with Columns[SelectedIndex] do
    if (not ReadOnly) and Assigned(Field) and Field.CanModify
      and (not Field.IsBlob or Assigned(Field.OnSetText)) then
    begin
      FDatalink.Edit;
      Result := FDatalink.Editing;
      if Result then FDatalink.Modified;
    end;}
  Result := not (Columns[SelectedIndex].GetColumnType in [ctKeyPickList,ctCheckboxes]) and
            not FInplaceSearching and CanEditModifyText;
end;

function TCustomDBGridEh.CanEditShow: Boolean;
begin
  Result := (LayoutLock = 0) and inherited CanEditShow;
  if Result then
  begin
    Result := Result and (SelectedIndex < Columns.Count);
    Result := Result and not (Columns[SelectedIndex].GetColumnType in [ctKeyImageList..ctCheckboxes]);
    Result := Result and ((Selection.SelectionType = gstNon) or not (dghClearSelection in OptionsEh));
    Result := Result and not FInplaceSearching;
    if not Result then
      HideEditor;
  end;
end;

procedure TCustomDBGridEh.CellClick(Column: TColumnEh);
begin
  if Assigned(FOnCellClick) then FOnCellClick(Column);
end;

procedure TCustomDBGridEh.ColEnter;
begin
  UpdateIme;
  if Assigned(FOnColEnter) then FOnColEnter(Self);
end;

procedure TCustomDBGridEh.ColExit;
begin
  if Assigned(FOnColExit) then FOnColExit(Self);
end;

procedure TCustomDBGridEh.ColumnMoved(FromIndex, ToIndex: Longint);
begin
  FromIndex := RawToDataColumn(FromIndex);
  ToIndex := RawToDataColumn(ToIndex);
  Columns[FromIndex].Index := ToIndex;
  if Assigned(FOnColumnMoved) then FOnColumnMoved(Self, FromIndex, ToIndex);
end;

procedure TCustomDBGridEh.ColWidthsChanged;
var
  I,J, vi: Integer;
  OldWidth:Integer;

  procedure RecalcAutoFitRightCols(ForColumn:Integer);
  var i,RightWidth,Delta:Integer;
  begin
    (*RightWidth := 0; RightInitWidth := 0;
    for i := ForColumn to Columns.Count - 1 do begin
      if FColumns[i].Visible and FColumns[i].AutoFitColWidth then begin
        Inc(RightWidth,FColumns[i].Width);
        if (i <> ForColumn) then Inc(RightInitWidth,FColumns[i].FInitWidth);
      end;
    end;
    Dec(RightWidth,ColWidths[ForColumn + FIndicatorOffset]);
    if (RightWidth <= 0) then RightWidth := 1;

    FColumns[ForColumn].FInitWidth := MulDiv(RightInitWidth,ColWidths[ForColumn + FIndicatorOffset],RightWidth);*)


    RightWidth := 0;
    Delta := ColWidths[ForColumn + FIndicatorOffset] - FColumns[ForColumn].Width;
    if (FColumns[ForColumn].AutoFitColWidth) then
      FColumns[ForColumn].FInitWidth :=
        MulDiv(ColWidths[ForColumn+FIndicatorOffset],
          FColumns[ForColumn].FInitWidth,FColumns[ForColumn].Width)
    else
      FColumns[ForColumn].Width := ColWidths[ForColumn+FIndicatorOffset];
    for i := ForColumn + 1 to Columns.Count - 1 do
      if FColumns[i].Visible and FColumns[i].AutoFitColWidth
        then Inc(RightWidth,FColumns[i].Width);

    for i := ForColumn + 1 to Columns.Count - 1 do
     if FColumns[i].Visible and FColumns[i].AutoFitColWidth then
     begin
       FColumns[i].FInitWidth :=
          MulDiv(RightWidth-Delta,FColumns[i].FInitWidth,RightWidth);
       if (FColumns[i].FInitWidth <= 0) then FColumns[i].FInitWidth := 1;
     end;
  end;
begin
  if (FDatalink.Active or (FColumns.State = csCustomized)) and AcquireLayoutLock then
  try
    inherited ColWidthsChanged;

    for I := FIndicatorOffset to ColCount - 1 do
      ColWidths[I] := Columns[I - FIndicatorOffset].AllowableWidth(ColWidths[I]);
    for I := FIndicatorOffset to ColCount - 1 do
    begin
      // FColumns[I - FIndicatorOffset].Width := ColWidths[I];
      if not FColumns[I - FIndicatorOffset].Visible then Continue;
      if (AutoFitColWidths = False) or (csDesigning in ComponentState) then
        FColumns[I - FIndicatorOffset].Width := ColWidths[I]
      else
        if (FColumns[I - FIndicatorOffset].Width <> ColWidths[I]) then
        begin
          if (dghResizeWholeRightPart in OptionsEh) then
          begin
            RecalcAutoFitRightCols(I-FIndicatorOffset);
          end else
          begin
            vi := -1;
            for j := 0 to VisibleColumns.Count-1 do
              if (VisibleColumns[j] =  FColumns[I - FIndicatorOffset]) then
              begin
                 vi := j; Break;
              end;
            if vi <> -1 then
            begin
              if VisibleColumns[vi].AutoFitColWidth then
              begin
                OldWidth := VisibleColumns[vi].FInitWidth;
                VisibleColumns[vi].FInitWidth :=
                  MulDiv(VisibleColumns[vi].FInitWidth,ColWidths[I],VisibleColumns[vi].Width);
                if (vi <> VisibleColumns.Count - 1) then
                begin
                  Inc(VisibleColumns[vi + 1].FInitWidth,
                   OldWIdth - VisibleColumns[vi].FInitWidth);
                  if (VisibleColumns[vi + 1].FInitWidth < 0)
                    then VisibleColumns[vi + 1].FInitWidth := 0;
                end;
              end
              else
                FColumns[I - FIndicatorOffset].Width := ColWidths[I];
            end;
          end;
        end;
    end;
  finally
    EndLayout;
  end else
    inherited ColWidthsChanged;
  InvalidateEditor;
  if Assigned(FOnColWidthsChanged) then FOnColWidthsChanged(Self);
end;

function TCustomDBGridEh.CreateColumns: TDBGridColumnsEh;
begin
  Result := TDBGridColumnsEh.Create(Self,TColumnEh);
end;

function TCustomDBGridEh.CreateEditor: TInplaceEdit;
begin
  Result := TDBGridInplaceEdit.Create(Self);
end;

procedure TCustomDBGridEh.CreateWnd;
begin
  BeginUpdate;   { prevent updates in WMSize message that follows WMCreate }
  try
    inherited CreateWnd;
  finally
    EndUpdate;
  end;
  if Flat
    then FInplaceEditorButtonWidth := FlatButtonWidth
    else FInplaceEditorButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
  UpdateRowCount;
  UpdateActive;
  UpdateScrollBar;
  FOriginalImeName := ImeName;
  FOriginalImeMode := ImeMode;
end;

procedure TCustomDBGridEh.DataChanged;
var VertSBVis: Boolean;
begin
  if not HandleAllocated or FSumListRecalcing then Exit;
  if (csDesigning in ComponentState) and SumList.Active then
  begin
    FSumListRecalcing := True;
    try
      SumList.RecalcAll;
    finally
      FSumListRecalcing := False;
    end;
  end;
  UpdateRowCount;
  VertSBVis := VertScrollBar.IsScrollBarVisible;
  UpdateScrollBar;
  if (VertSBVis <> VertScrollBar.IsScrollBarVisible) then
  begin
    if (FAutoFitColWidths = True) {and (UpdateLock = 0)} and
       not (csDesigning in ComponentState)
     then DeferLayout;
    //Update;
    //LayoutChanged;
  end;
  UpdateActive;
  InvalidateEditor;
  ValidateRect(Handle, nil);
  Invalidate;
end;

procedure TCustomDBGridEh.DefaultHandler(var Msg);
var
  P: TPopupMenu;
  Cell: TGridCoord;
begin
  inherited DefaultHandler(Msg);
  if TMessage(Msg).Msg = wm_RButtonUp then
    with TWMRButtonUp(Msg) do
    begin
      Cell := MouseCoord(XPos, YPos);
      if (Cell.X < FIndicatorOffset) or (Cell.Y < 0) then Exit;
      P := Columns[RawToDataColumn(Cell.X)].PopupMenu;
      if (P <> nil) and P.AutoPopup then
      begin
        SendCancelMode(nil);
        P.PopupComponent := Self;
        with ClientToScreen(SmallPointToPoint(Pos)) do
          P.Popup(X, Y);
        Result := 1;
      end;
    end;
end;

procedure TCustomDBGridEh.DeferLayout;
var
  M: TMsg;
begin
  if HandleAllocated and
    not PeekMessage(M, Handle, cm_DeferLayout, cm_DeferLayout, pm_NoRemove) then
    PostMessage(Handle, cm_DeferLayout, 0, 0);
  CancelLayout;
end;

procedure TCustomDBGridEh.DefineFieldMap;
var
  I: Integer;
begin
  if FColumns.State = csCustomized then
  begin   { Build the column/field map from the column attributes }
    DataLink.SparseMap := True;
    for I := 0 to FColumns.Count-1 do
      FDataLink.AddMapping(FColumns[I].FieldName);
  end else   { Build the column/field map from the field list order }
  begin
    FDataLink.SparseMap := False;
    with Datalink.Dataset do
      for I := 0 to FieldCount - 1 do
        with Fields[I] do if Visible then Datalink.AddMapping(FieldName);
  end;
end;

procedure TCustomDBGridEh.DefaultDrawDataCell(const Rect: TRect; Field: TField;
  State: TGridDrawState);
var
  Alignment: TAlignment;
  Value: string;
begin
  Alignment := taLeftJustify;
  Value := '';
  if Assigned(Field) then
  begin
    Alignment := Field.Alignment;
    Value := Field.DisplayText;
  end;
  WriteText(Canvas, Rect, 2, 2, Value, Alignment);
end;

procedure TCustomDBGridEh.DefaultDrawColumnCell(const Rect: TRect;
  DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
var
  Value: string;
  ARect,ARect1:TRect;
  XFrameOffs,YFrameOffs,KeyIndex:Integer;
begin
  ARect := Rect;
  if (dghFooter3D in OptionsEh) then
  begin
    XFrameOffs := 1;
    InflateRect(ARect, -1, -1);
  end else XFrameOffs := 2;
  YFrameOffs := XFrameOffs;
  if Flat then Dec(YFrameOffs);
  Value := Column.DisplayText;

  if Column.GetColumnType in [ctCommon..ctKeyPickList] then
    WriteTextEh(Canvas, ARect, True, XFrameOffs, YFrameOffs, Value,
      Column.Alignment,tlTop,Column.WordWrap and FAllowWordWrap, Column.EndEllipsis,0,0)
  else if Column.GetColumnType = ctKeyImageList then
  begin
    Canvas.FillRect(ARect);
    KeyIndex := Column.KeyList.IndexOf(Column.Field.Text);
    if KeyIndex = -1
      then KeyIndex := Column.NotInKeyListIndex;
    DrawClipped(Column.ImageList,Canvas,ARect,KeyIndex,0,taCenter);
  end else if Column.GetColumnType = ctCheckboxes then
  begin
    Canvas.FillRect(ARect);
    ARect1.Left := ARect.Left + iif(ARect.Right - ARect.Left < FCheckBoxWidth,0,
          (ARect.Right - ARect.Left) shr 1 - FCheckBoxWidth shr 1);
    ARect1.Right :=  iif(ARect.Right - ARect.Left < FCheckBoxWidth,ARect.Right,
           ARect1.Left + FCheckBoxWidth);
    ARect1.Top := ARect.Top + iif(ARect.Bottom - ARect.Top < FCheckBoxHeight,0,
          (ARect.Bottom - ARect.Top) shr 1 - FCheckBoxHeight shr 1);
    ARect1.Bottom := iif(ARect.Bottom - ARect.Top < FCheckBoxHeight,ARect.Bottom,
          ARect1.Top + FCheckBoxHeight);

    //DrawCheck(Canvas.Handle,ARect1,Column.CheckboxState,True,Flat);
    PaintButtonControl{Eh}(Canvas.Handle,ARect1,Canvas.Brush.Color,bcsCheckboxEh,
      0,Flat,True,True,Column.CheckboxState);
  end;

  //WriteTextEh(Canvas, ARect, True, XFrameOffs, YFrameOffs, Value, Column.Alignment,tlTop,Column.WordWrap and FAllowWordWrap, Column.EndEllipsis,0,0);
end;

procedure TCustomDBGridEh.ReadColumns(Reader: TReader);
begin
  Columns.Clear;
  Reader.ReadValue;
  Reader.ReadCollection(Columns);
end;

procedure TCustomDBGridEh.WriteColumns(Writer: TWriter);
begin
  Writer.WriteCollection(Columns);
end;

procedure TCustomDBGridEh.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty('Columns', ReadColumns, WriteColumns,
    ((Columns.State = csCustomized) and (Filer.Ancestor = nil)) or
    ((Filer.Ancestor <> nil) and
     ((Columns.State <> TCustomDBGridEh(Filer.Ancestor).Columns.State) or
{$IFDEF EH_LIB_6}
      (not CollectionsEqual(Columns, TCustomDBGridEh(Filer.Ancestor).Columns, Self, TCustomDBGridEh(Filer.Ancestor)))
{$ELSE}
      (not CollectionsEqual(Columns, TCustomDBGridEh(Filer.Ancestor).Columns))
{$ENDIF}
    )));
end;

{ ddd new DrawCell}
procedure TCustomDBGridEh.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
const
  CheckBoxFlags: array [TCheckBoxState] of Integer =
    ( DFCS_BUTTONCHECK,  DFCS_BUTTONCHECK or DFCS_CHECKED,  DFCS_BUTTON3STATE or DFCS_CHECKED );
var
  OldActive, KeyIndex, ImageWidth{, SorCol, SorRow}: Integer;
  Highlight: Boolean;
  Value: string;
  DrawColumn: TColumnEh;
  XFrameOffs,YFrameOffs: Byte;
  ARect1: TRect;
  Down: Boolean;
  MultiSelected, SMImageFit: Boolean;
  Indicator,LeftMarg,RightMarg: Integer;
  BackColor: TColor;
  ASortMarker: TSortMarkerEh;
  SortMarkerIdx,SMTMarg: Integer;
  AEditStyle: TEditStyle;
  NewAlignment: TAlignment;
  The3DRect: Boolean;
  TitleText: String;
  Footer: TColumnFooterEh;

  function RowIsMultiSelected: Boolean;
  begin
    Result := (dgMultiSelect in Options) and Datalink.Active and
      Selection.DataCellSelected(ACol,Datalink.Datasource.Dataset.Bookmark);
  end;

  procedure DrawHost(ALeaf:THeadTreeNode; DHRect:TRect; AEndEllipsis: Boolean);
  var curLeaf: THeadTreeNode;
     curW: Integer;
     leftM,RightM: Integer;
     drawRec,drawRec1: TRect;
     OldColor: TColor;
  begin
    DHRect.Bottom := DHRect.Top;
    if dgRowLines in Options then Dec(DHRect.Bottom);

    Dec(DHRect.Top,ALeaf.Host.Height);

    curLeaf := ALeaf.Host.Child;
    curW := 0;
    while curLeaf <> ALeaf do
    begin
       Inc(curW,curLeaf.Width);
       if dgColLines in Options then Inc(curW,1);
       curLeaf := curLeaf.Next;
    end;
    Dec(DHRect.Left,curW); DHRect.Right := DHRect.Left + ALeaf.Host.Width;

    LeftM := DHRect.Left - ARect.Left; RightM := ARect.Right - DHRect.Right;

//1.51    leftM := 0;
    drawRec := DHRect;
    drawRec.Left := ARect.Left; drawRec.Right := ARect.Right;

    if (RightM <> 0) then begin
      if ACol+IndicatorOffset = (FixedCols-1) then
      begin
        if (LeftCol = FixedCols) then
        begin
         Inc(RightM);
         Inc(drawRec.Right);
        end;
      end else
      begin
        Inc(RightM);
        Inc(drawRec.Right);
      end;
    end;

    if (gdFixed in AState) and (dghFixed3D in OptionsEh) then
    begin
      InflateRect(drawRec, 0, -1);
    end;


    drawRec1 := drawRec;
    if(leftM  = 0) then
    begin
      Canvas.FillRect(Rect(drawRec1.Left,drawRec1.Top,drawRec1.Left+2,drawRec1.Bottom));
      Inc(drawRec1.Left,2);
    end else Inc(LeftM,2);
    if(RightM = 0) then
    begin
      Canvas.FillRect(Rect(drawRec1.Right-2,drawRec1.Top,drawRec1.Right,drawRec1.Bottom));
      Dec(drawRec1.Right,2);
    end
    else Inc(RightM,2);

    WriteCellText{WriteTextEh}(Canvas, drawRec1, False, 0, YFrameOffs, ALeaf.Host.Text, taCenter,tlCenter,True,AEndEllipsis,leftM,RightM);

    ALeaf.Host.Drawed := True;

    if (gdFixed in AState) and (dghFixed3D in OptionsEh) then
    begin
      InflateRect(drawRec, 0, 1);
      DrawEdgeEh(Canvas,drawRec,False,Highlight,leftM = 0,RightM  = 0);
//      InflateRect(DHRect, 1, 1);
    end;

    if ( dgRowLines in Options) then
    begin
      OldColor := Canvas.Pen.Color;
      if Flat
        then Canvas.Pen.Color := clGray
        else Canvas.Pen.Color := clBlack;
      Canvas.MoveTo(drawRec.Left,drawRec.Bottom);
      Canvas.LineTo(drawRec.Right,drawRec.Bottom);
      Canvas.Pen.Color := OldColor;
    end;

    if(ALeaf.Host.Host <> nil) {and (ALeaf.Host.Host.Drawed = False)} then
    begin
      DrawHost(ALeaf.Host,DHRect,AEndEllipsis);
      ALeaf.Host.Host.Drawed := True;
    end;
  end;

  procedure DrawInplaceSearchText;
  const
    AlignFlags : array [TAlignment] of Integer =
      ( DT_LEFT or DT_EXPANDTABS or DT_NOPREFIX,
        DT_RIGHT or DT_EXPANDTABS or DT_NOPREFIX,
        DT_CENTER or DT_EXPANDTABS or DT_NOPREFIX );
  var
    rect1: TRect;
    DrawFlag: Integer;
    lpDTP :  TDrawTextParams;
  begin
    Canvas.Brush.Color := DBGridEhInplaceSearchColor;
    Canvas.Font.Color := DBGridEhInplaceSearchTextColor;

    DrawFlag := AlignFlags[DrawColumn.Alignment];
    if (DrawColumn.WordWrap and FAllowWordWrap) then
      DrawFlag := DrawFlag or DT_WORDBREAK;

    rect1 := ARect;

    lpDTP.cbSize := SizeOf(lpDTP);
    lpDTP.uiLengthDrawn := Length(FInplaceSearchText);
    lpDTP.iLeftMargin := 0;
    lpDTP.iRightMargin := 0;

    InflateRect(rect1, -XFrameOffs, -YFrameOffs);

    if XFrameOffs > 0 then rect1.Bottom := rect1.Bottom + 1;
    if DrawColumn.Alignment <> taLeftJustify then
      lpDTP.iRightMargin :=
        Canvas.TextWidth(Copy(Value,Length(FInplaceSearchText)+1,Length(Value)));

    DrawTextEx(Canvas.Handle,PChar(FInplaceSearchText),
      Length(FInplaceSearchText), rect1, DrawFlag,@lpDTP);
  end;

  procedure PaintInplaceButton(DC:HDC; EditStyle:TEditStyle; Rect:TRect;
    DownButton:Integer; Active, Flat, Enabled: Boolean; ParentColor:TColor);
  var LineRect:TRect;
      Brush: HBRUSH;
  begin
    if EditStyle <> esSimple then
    begin
      if Flat then  // Draw left button line
      begin
        LineRect := Rect;
        if UseRightToLeftAlignment then
        begin
          LineRect.Right := LineRect.Left;
          LineRect.Left := LineRect.Left + 1;
        end else
          LineRect.Right := LineRect.Left + 1;
        Inc(Rect.Left,1);
        if Active then
          FrameRect(DC, LineRect,GetSysColorBrush(COLOR_BTNFACE))
         else
         begin
           Brush := CreateSolidBrush(ColorToRGB(ParentColor));
           FrameRect(DC, LineRect,Brush);
           DeleteObject(Brush);
         end;
      end;
      if UseRightToLeftAlignment then
      begin
        LPtoDP(Canvas.Handle,Rect,2);
        Swap(Rect.Left,Rect.Right);
        ChangeGridOrientation(False);
      end;

      case EditStyle of
        esDataList, esPickList, esDateCalendar, esDropDown:
          PaintButtonControlEh(DC,Rect,ParentColor,bcsDropDownEh,DownButton,Flat,Active,Enabled,cbUnchecked);
        esEllipsis:
          PaintButtonControlEh(DC,Rect,ParentColor,bcsEllipsisEh,DownButton,Flat,Active,Enabled,cbUnchecked);
        esUpDown:
          PaintButtonControlEh(DC,Rect,ParentColor,bcsUpDownEh,DownButton,Flat,Active,Enabled,cbUnchecked);
      end;

      if UseRightToLeftAlignment then
        ChangeGridOrientation(True);
    end;
  end;

begin
  FColCellParamsEh.FCol := ACol;
  FColCellParamsEh.FRow := ARow;
  Highlight := False;
  if (ARect.Left >= ARect.Right) then Exit;
  DrawColumn := nil;
  Down := False;
  if csLoading in ComponentState then
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
    Exit;
  end;

  Dec(ARow, FTitleOffset);
  Dec(ACol, IndicatorOffset);

  The3DRect := (gdFixed in AState) and (dghFixed3D in OptionsEh) and
    ((FFooterRowCount = 0) or ((FFooterRowCount > 0) and
    (ARow <> RowCount - FFooterRowCount - 1 - FTitleOffset)) ) and
    ((ACol < 0) or (ARow < 0));
  if not The3DRect then
    The3DRect := The3DRect or ((dghFooter3D in OptionsEh) and
      (FFooterRowCount > 0) and (ARow > RowCount - FFooterRowCount - 1 - FTitleOffset));
  if not The3DRect then
    The3DRect := The3DRect or ((dghData3D in OptionsEh) and not (gdFixed in AState)
       and not ((FFooterRowCount > 0) and (ARow > RowCount - FFooterRowCount - 1 - FTitleOffset)));
  if not The3DRect then
    The3DRect := The3DRect or ( (dghFixed3D in OptionsEh) and
      ((dghData3D in OptionsEh) or (dghFrozen3D in OptionsEh)) and
      ((FFooterRowCount > 0) and (ARow = RowCount - FFooterRowCount - 1 - FTitleOffset) and (ACol < 0)));
  if not The3DRect then
    The3DRect := The3DRect or ((dghFrozen3D in OptionsEh) and (gdFixed in AState) and (ACol >= 0) and (ARow >= 0));

  if The3DRect then
  begin
    InflateRect(ARect, -1, -1);
    XFrameOffs := 1;
  end else
    XFrameOffs := 2;
  YFrameOffs := XFrameOffs;

  if Flat then Dec(YFrameOffs);

  if (gdFixed in AState) and (ACol < 0) then // Indicator col
  begin
     if ((FFooterRowCount = 0) or ((FFooterRowCount > 0) and
        (ARow <> RowCount - FFooterRowCount - 1 - FTitleOffset))) or (dghFrozen3D in OptionsEh)
       then Canvas.Brush.Color := FixedColor
       else Canvas.Brush.Color := Color;
//    Canvas.FillRect(ARect);
    if Assigned(DataLink) and DataLink.Active  then
    begin
      MultiSelected := (Selection.SelectionType = gstAll);
      if (ARow >= 0)   and ( (ARow < FDatalink.RecordCount) or (FFooterRowCount = 0) ) then // Indicator
      begin
        OldActive := FDataLink.ActiveRecord;
        try
          FDatalink.ActiveRecord := ARow;
          MultiSelected := RowIsMultiselected;
        finally
          FDatalink.ActiveRecord := OldActive;
        end;
      end;
      if MultiSelected then
      begin
        Canvas.Brush.Color := RGB(64,64,64);
        Highlight := True;
      end;
      Canvas.FillRect(ARect);
      if (ARow = FDataLink.ActiveRecord) or MultiSelected then
      begin
        Indicator := -1;
        //FIndicators.BkColor := FixedColor; //??? to avoid ImageListChange event
        if FDataLink.DataSet <> nil then
          case FDataLink.DataSet.State of
            dsEdit: Indicator := 1;
            dsInsert: Indicator := 2;
            dsBrowse:
              if (ARow = FDatalink.ActiveRecord) then
               if MultiSelected then
                  Indicator := 5
               else if FInplaceSearching then
                  Indicator := 6
               else
                  Indicator := 0;
              else Indicator := 0;  // multiselected and current row
          end;
        if MultiSelected then
          //FIndicators.BkColor := RGB(64,64,64) //??? to avoid ImageListChange event
        else
          ;//FIndicators.BkColor := FixedColor; //??? to avoid ImageListChange event
        FIndicators.Draw(Canvas, ARect.Right - FIndicators.Width - XFrameOffs,
          (ARect.Top + ARect.Bottom - FIndicators.Height) shr 1, Indicator);
        if ARow = FDatalink.ActiveRecord then
          FSelRow := ARow + FTitleOffset;
      end;
    end
    else Canvas.FillRect(ARect);
  end
  else with Canvas do
  begin
    DrawColumn := Columns[ACol];
    if (gdFixed in AState) and ((ACol < 0) or (ARow < 0)) then
    begin
      Font := DrawColumn.Title.Font;
      Brush.Color := DrawColumn.Title.Color;
    end
    else
    begin
      Font := DrawColumn.Font;
      Brush.Color := DrawColumn.Color;
    end;
    if ARow < 0
      then with DrawColumn.Title do // draw headline
      begin
// new --
        Down := (FPressedCol-IndicatorOffset  = ACol) and FPressed;
        ImageWidth := 0;
        if (FUseMultiTitle = True) then
        begin
          ARect.Top := ARect.Bottom - FLeafFieldArr[ACol].FLeaf.Height + 3;
          TitleText := FLeafFieldArr[ACol].FLeaf.Text;
        end else
          TitleText := Caption;
        if (TitleImages <> nil) and (ImageIndex <> -1) then
        begin
          TitleText := '';
          ImageWidth := TitleImages.Width;
        end;
        ARect1 := ARect;
        ASortMarker := DrawColumn.Title.SortMarker;
        if (DrawColumn.Field <> nil) and Assigned(FOnGetBtnParams) then
        begin
          BackColor := Canvas.Brush.Color;
          FOnGetBtnParams(Self, DrawColumn, Canvas.Font, BackColor, ASortMarker, Down);
          Canvas.Brush.Color := BackColor;
        end;
        if Down then
        begin
          if (FUseMultiTitle = True) or (TitleHeight <> 0) or (TitleLines <> 0) then
          begin
            LeftMarg := 2; RightMarg := -2; Inc(ARect1.Top,2);
          end else
          begin
            LeftMarg := 1; RightMarg := -1; Inc(ARect1.Top,1);
          end;
        end else
        begin
          LeftMarg := 0;
          RightMarg := 0;
        end;
        case ASortMarker of
          smDownEh: SortMarkerIdx := 0;
          smUpEh: SortMarkerIdx := 1;
          else SortMarkerIdx := -1;
        end;
        SMTMarg := 0; SMImageFit := True;
        if SortMarkerIdx <> -1 then
        begin
          Dec(ARect1.Right,16);
          if (SortMarkedColumns.Count > 1) then
          begin
            Canvas.Font := SortMarkerFont;
            SMTMarg := Canvas.TextWidth(IntToStr(SortIndex));
          end else
            SMTMarg := 0;
          if ARect1.Right < ARect1.Left + ImageWidth then
          begin
            ARect1.Right := ARect1.Right + 14 - SMTMarg;
            SMImageFit := False;
          end;
          if ARect1.Right < ARect1.Left + ImageWidth then
          begin
            ARect1.Right := ARect1.Right + 2 + SMTMarg;
            SMTMarg := 0;
          end;
        end;
        {if FUseMultiTitle = True then Canvas.Font := TitleFont else} Canvas.Font := Font;
        if (DrawColumn.Field <> nil) and Assigned(FOnGetBtnParams) then // To resotre changed in FOnGetBtnParams font
          FOnGetBtnParams(Self, DrawColumn, Canvas.Font, BackColor, ASortMarker, Down);
        if (Selection.Columns.IndexOf(DrawColumn) <> -1) or (Selection.SelectionType = gstAll) then
        begin
          Canvas.Brush.Color := RGB(64,64,64);
          Canvas.Font.Color := clWhite;
          Highlight := True;
        end;
        Canvas.FillRect(Rect(ARect1.Right,ARect.Top,ARect.Right,ARect.Bottom));
        if (FUseMultiTitle = True) then
        begin
           //Canvas.Font := TitleFont;
          if Orientation = tohVertical then
            WriteTextVerticalEh(Canvas, ARect1, False, XFrameOffs, YFrameOffs+2,
              TitleText, taCenter, tlBottom, EndEllipsis,False)
          else
            WriteCellText{WriteTextEh}(Canvas, ARect1, False, XFrameOffs, YFrameOffs, TitleText,
              taCenter,tlCenter,True,EndEllipsis,LeftMarg,RightMarg);
          //Canvas.Pen.Color := clWindowFrame;
        end
        else if (TitleHeight <> 0) or (TitleLines <> 0) then
        begin
          if Orientation = tohVertical then
            WriteTextVerticalEh(Canvas, ARect1, False, XFrameOffs, YFrameOffs+2,
              TitleText, Alignment, tlBottom, EndEllipsis,False)
          else
            WriteCellText{WriteTextEh}(Canvas, ARect1, False, XFrameOffs, YFrameOffs, TitleText,
              Alignment,tlCenter,True,EndEllipsis,LeftMarg,RightMarg)
        end else
        begin
          ARect1.Left := ARect1.Left + LeftMarg;
          ARect1.Right := ARect1.Right - RightMarg;
          if Orientation = tohVertical then
            WriteTextVerticalEh(Canvas, ARect1, False, XFrameOffs, YFrameOffs+2,
              TitleText, Alignment, tlBottom, EndEllipsis,False)
          else
            WriteCellText{WriteTextEh}(Canvas, ARect1, False, XFrameOffs, YFrameOffs, TitleText,
              Alignment,tlTop,False,EndEllipsis,LeftMarg,RightMarg);
        end;
        if (TitleImages <> nil) and (ImageIndex <> -1) then
        begin
          with TitleImages do
          begin
            //BkColor := Canvas.Brush.Color; //??? to avoid ImageListChange event
//            Draw(Canvas, (ARect1.Right + ARect1.Left - Width) div 2 + LeftMarg,
//                          (ARect1.Bottom + ARect1.Top - Height) div 2, ImageIndex);
            if FUseMultiTitle
              then DrawClipped(TitleImages,Canvas,ARect1,ImageIndex,LeftMarg,taCenter)
              else DrawClipped(TitleImages,Canvas,ARect1,ImageIndex,LeftMarg,Alignment);
          end;
        end;
        if SortMarkerIdx <> -1 then
        begin
          if SMImageFit <> False then
          begin
            //FSortMarkerImages.BkColor := Canvas.Brush.Color; //??? to avoid ImageListChange event
             FSortMarkerImages.Draw(Canvas, ARect.Right - FSortMarkerImages.Width - 2 - SMTMarg + LeftMarg,
            (ARect.Bottom + ARect.Top - FSortMarkerImages.Height) div 2 + LeftMarg, SortMarkerIdx);
          end;
          if SMTMarg <> 0 then
          begin
            Canvas.Font := SortMarkerFont;
            if Highlight = True
              then Canvas.Font.Color := clWhite;
            Canvas.TextOut(ARect.Right - SMTMarg - 2 + LeftMarg,
               (ARect.Bottom + ARect.Top - FSortMarkerImages.Height) div 2 + LeftMarg - 1,
               IntToStr(SortIndex));
            Canvas.Font := TitleFont;
            if Highlight = True
              then Canvas.Font.Color := clWhite;
          end;
        end;
    end
//\\
    else if (DataLink = nil) or not DataLink.Active
      then FillRect(ARect)
    else
    begin  // Draw contents
      Value := '';
      OldActive := DataLink.ActiveRecord;
      try
        if ((ARow >= 0) and (ARow < FDatalink.RecordCount)) or (FFooterRowCount = 0) then
        begin
          DataLink.ActiveRecord := ARow;

          AEditStyle := esSimple;
          if (DrawColumn.AlwaysShowEditButton) then // Draw edit button
          begin
            AEditStyle := GetColumnEditStile(DrawColumn);
            if (AEditStyle <> esSimple) then
              ARect.Right := ARect.Right - FInplaceEditorButtonWidth;
          end;

          if Assigned(DrawColumn.Field) then
            if Assigned(DrawColumn.KeyList)  and (DrawColumn.KeyList.Count > 0) then
            begin
              KeyIndex := DrawColumn.KeyList.IndexOf(DrawColumn.Field.Text);
              if (KeyIndex > -1) and (KeyIndex < DrawColumn.PickList.Count)
                then Value := DrawColumn.PickList.Strings[KeyIndex]
              else if (DrawColumn.NotInKeylistIndex >= 0) and
                      (DrawColumn.NotInKeylistIndex < DrawColumn.PickList.Count)
                then Value := DrawColumn.PickList.Strings[DrawColumn.NotInKeylistIndex];
            end else if (DrawMemoText = True) and (DrawColumn.Field.DataType = ftMemo)
              then Value := DrawColumn.Field.AsString
            else
              Value := DrawColumn.Field.DisplayText;
          Highlight := HighlightCell(ACol, ARow, Value, AState);
          if Highlight then
          begin
            Brush.Color := clHighlight;
            Font.Color := clHighlightText;
            AState := AState + [gdSelected];
          end;
          FColCellParamsEh.FState := AState;
          FColCellParamsEh.FFont := Font;
          FColCellParamsEh.FAlignment := DrawColumn.Alignment;
          FColCellParamsEh.FBackground := Canvas.Brush.Color;
          FColCellParamsEh.FText := Value;
          if DefaultDrawing then
            if DrawColumn.GetColumnType = ctKeyImageList then
            begin
              FColCellParamsEh.FImageIndex := DrawColumn.KeyList.IndexOf(DrawColumn.Field.Text);
              if FColCellParamsEh.FImageIndex = -1 then FColCellParamsEh.FImageIndex := DrawColumn.NotInKeyListIndex;
            end else if DrawColumn.GetColumnType = ctCheckboxes
              then FColCellParamsEh.FCheckboxState := DrawColumn.CheckboxState;

          GetCellParams(DrawColumn,Font,FColCellParamsEh.FBackground,AState);
          DrawColumn.GetColCellParams(False, FColCellParamsEh);

          Canvas.Brush.Color := FColCellParamsEh.FBackground;

          if DefaultDrawing then
            if DrawColumn.GetColumnType in [ctCommon..ctKeyPickList] then
              with FColCellParamsEh do
                WriteCellText{WriteTextEh}(Canvas, ARect, True, XFrameOffs, YFrameOffs, FText,
                  FAlignment,tlTop,DrawColumn.WordWrap and FAllowWordWrap, DrawColumn.EndEllipsis,0,0)
            else if DrawColumn.GetColumnType = ctKeyImageList then
            begin
              FillRect(ARect);
              DrawClipped(DrawColumn.ImageList,Canvas,ARect,FColCellParamsEh.FImageIndex,0,taCenter);
            end else if DrawColumn.GetColumnType = ctCheckboxes then
            begin
              FillRect(ARect);
              ARect1.Left := ARect.Left + iif(ARect.Right - ARect.Left < FCheckBoxWidth,0,
                    (ARect.Right - ARect.Left) shr 1 - FCheckBoxWidth shr 1);
              ARect1.Right :=  iif(ARect.Right - ARect.Left < FCheckBoxWidth,ARect.Right,
                     ARect1.Left + FCheckBoxWidth);
              ARect1.Top := ARect.Top + iif(ARect.Bottom - ARect.Top < FCheckBoxHeight,0,
                    (ARect.Bottom - ARect.Top) shr 1 - FCheckBoxHeight shr 1);
              ARect1.Bottom := iif(ARect.Bottom - ARect.Top < FCheckBoxHeight,ARect.Bottom,
                    ARect1.Top + FCheckBoxHeight);
              PaintButtonControl{Eh}(Canvas.Handle,ARect1,Canvas.Brush.Color,bcsCheckboxEh,
                 0,Flat,True,True,FColCellParamsEh.FCheckboxState);
            end;

          if DrawColumn.AlwaysShowEditButton then // Draw edit button
            if (AEditStyle <> esSimple) then
            begin
              SetRect(ARect1, ARect.Right, ARect.Top,
                ARect.Right + FInplaceEditorButtonWidth, ARect.Top + FInplaceEditorButtonHeight);
              if The3DRect then OffsetRect(ARect1,1,-1); // InflateRect(ARect1, -1, -1);
              {if AEditStyle = esUpDown then
                Canvas.Draw(ARect1.Left,ARect1.Top,UpDownBitmap)
              else}
              PaintInplaceButton(Canvas.Handle, AEditStyle, ARect1,
                0, False, Flat, DataLink.Active, Canvas.Brush.Color);
              if Flat and The3DRect then
                FillRect(Rect(ARect1.Left-1,ARect1.Top,ARect1.Left,ARect.Bottom));
              if FInplaceEditorButtonHeight < DefaultRowHeight then
                FillRect(Rect(ARect1.Left,ARect1.Bottom,ARect1.Right,ARect.Bottom));
            end;

          if Columns.State = csDefault then
            DrawDataCell(ARect, DrawColumn.Field, AState);
          DrawColumnCell(ARect, ACol, DrawColumn, AState);
          if       FInplaceSearching
              and (gdSelected in AState)
              and  (ACol+IndicatorOffset = Col)
              and ((dgAlwaysShowSelection in Options) or Focused)
              and not (csDesigning in ComponentState)
              and (UpdateLock = 0)
              and (ValidParentForm(Self).ActiveControl = Self)
          then DrawInplaceSearchText;
          if DrawColumn.AlwaysShowEditButton and (AEditStyle <> esSimple) and Flat
            then ARect.Right := ARect.Right + FInplaceEditorButtonWidth;
        end
        else
        //ddd                                         Draw Footer Cells
        if {Assigned(OnDrawFooterCell) and}
           (FFooterRowCount > 0) and
           (ARow > RowCount - FFooterRowCount - 1 - FTitleOffset) then
          begin

            Footer := DrawColumn.UsedFooter(FFooterRowCount - RowCount + ARow + FTitleOffset);
            Font := Footer.Font;
            Brush.Color := Footer.Color;

            if FDefaultDrawing then
            begin
              FColCellParamsEh.FBackground := Brush.Color;
              NewAlignment := Footer.Alignment;
              Value := GetFooterValue(FFooterRowCount - RowCount + ARow + FTitleOffset, DrawColumn);

              GetFooterParams(ACol,  FFooterRowCount - RowCount + ARow + FTitleOffset, DrawColumn, Font,
                               FColCellParamsEh.FBackground, NewAlignment, AState, Value);

              Canvas.Brush.Color := FColCellParamsEh.FBackground;

              if (Selection.Columns.IndexOf(DrawColumn) <> -1) or (Selection.SelectionType = gstAll) then
              begin
                Canvas.Brush.Color := clHighlight;
                Canvas.Font.Color := clHighlightText;
                Highlight := True;
              end;
              WriteCellText{WriteTextEh}(Canvas, ARect, True, XFrameOffs, YFrameOffs, Value,
                NewAlignment,tlTop, Footer.WordWrap and FAllowWordWrap, Footer.EndEllipsis,0,0);
            end;

            if Assigned(OnDrawFooterCell) then
              OnDrawFooterCell(Self,ACol,FFooterRowCount - RowCount + ARow + FTitleOffset,DrawColumn,ARect,AState);
        end
        else
        begin
          if (Selection.Columns.IndexOf(DrawColumn) <> -1) or
             (Selection.SelectionType = gstAll) then
          begin
            Canvas.Brush.Color := clHighlight;
            Canvas.Font.Color := clHighlightText;
            Highlight := True;
          end;
          FillRect(ARect);
        end;

      finally
        DataLink.ActiveRecord := OldActive;
      end;
      if DefaultDrawing and (gdFocused in AState)
        and ((dgAlwaysShowSelection in Options) or Focused)
        and not (csDesigning in ComponentState)
        and not (dgRowSelect in Options)
        and (UpdateLock = 0)
        and (ValidParentForm(Self).ActiveControl = Self) then
        Windows.DrawFocusRect(Handle, ARect);
    end;
  end;

  if The3DRect then
  begin
    InflateRect(ARect, 1, 1);
    DrawEdgeEh(Canvas,ARect,Down,Highlight,True,True);
  end;

  if (ARow < 0) and (ACol >= 0) and (FUseMultiTitle = True) then
  with DrawColumn.Title do
  begin // Draw mastertitle
    Canvas.Font := TitleFont;
    if Highlight then
    begin
      Canvas.Brush.Color := RGB(64,64,64);
      Canvas.Font.Color := clWhite;
    end else
      Canvas.Brush.Color := FixedColor;
    if(FLeafFieldArr[ACol].FLeaf.Host <> nil) {and (FLeafFieldArr[ACol].FLeaf.Host.Drawed = False)} then
    begin
       DrawHost(FLeafFieldArr[ACol].FLeaf,ARect,EndEllipsis);
    end;
  end;
end;

procedure TCustomDBGridEh.DrawDataCell(const Rect: TRect; Field: TField; State: TGridDrawState);
begin
  if Assigned(FOnDrawDataCell) then FOnDrawDataCell(Self, Rect, Field, State);
end;

procedure TCustomDBGridEh.DrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumnEh; State: TGridDrawState);
begin
  if Assigned(OnDrawColumnCell)
    then OnDrawColumnCell(Self, Rect, DataCol, Column, State);
end;

procedure TCustomDBGridEh.EditButtonClick;
begin
  if Assigned(FOnEditButtonClick) then FOnEditButtonClick(Self);
end;

procedure TCustomDBGridEh.EditingChanged;
begin
  if dgIndicator in Options then InvalidateCell(0, FSelRow);
end;

procedure TCustomDBGridEh.EndLayout;
begin
  if FLayoutLock > 0 then
  begin
    try
      try
        if FLayoutLock = 1 then
          InternalLayout;
      finally
        if FLayoutLock = 1 then
          FColumns.EndUpdate;
      end;
    finally
      Dec(FLayoutLock);
      EndUpdate;
    end;
  end;
end;

procedure TCustomDBGridEh.EndUpdate;
begin
  if FUpdateLock > 0
    then Dec(FUpdateLock);
end;

function TCustomDBGridEh.GetColField(DataCol: Integer): TField;
begin
  Result := nil;
  if (DataCol >= 0) and FDatalink.Active and (DataCol < Columns.Count)
    then Result := Columns[DataCol].Field;
end;

function TCustomDBGridEh.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TCustomDBGridEh.GetEditLimit: Integer;
begin
  Result := 0;
   if {not} (Assigned(Columns[SelectedIndex].KeyList) and (Columns[SelectedIndex].KeyList.Count > 0)) {ddd\\\} then
   else
   if Assigned(SelectedField) and (SelectedField.DataType = ftString) then
     Result := SelectedField.Size;
end;

function TCustomDBGridEh.GetEditMask(ACol, ARow: Longint): string;
begin
  Result := '';
  if FDatalink.Active then
    with Columns[RawToDataColumn(ACol)] do
      if Assigned(Field) and not (Assigned(KeyList) and (KeyList.Count > 0)) then
        Result := Field.EditMask;
end;

function TCustomDBGridEh.GetEditText(ACol, ARow: Longint): string;
var KeyIndex: Integer;
begin
  Result := '';
  if FDatalink.Active then
  with Columns[RawToDataColumn(ACol)] do
    if Assigned(Field) then
    begin
      if Assigned(KeyList)  and (KeyList.Count > 0) then
      begin
        KeyIndex := KeyList.IndexOf(Field.Text);
        if (KeyIndex > -1) and (KeyIndex < PickList.Count) then
          Result := PickList.Strings[KeyIndex];
      end
      else if (DrawMemoText = True) and (Field.DataType = ftMemo) then
         Result := AdjustLineBreaks(Field.AsString)
      else
        Result := Field.Text;
      if (Field.FieldKind = fkLookup) and (Field.KeyFields <> '') then
      begin
        FEditKeyValue := Field.DataSet.FieldValues[Field.KeyFields];
      end
      else FEditKeyValue := NULL;
    end;
  FEditText := Result;
end;

function TCustomDBGridEh.GetFieldCount: Integer;
begin
  Result := FDatalink.FieldCount;
end;

function TCustomDBGridEh.GetFields(FieldIndex: Integer): TField;
begin
  Result := FDatalink.Fields[FieldIndex];
end;

function TCustomDBGridEh.GetFieldValue(ACol: Integer): string;
var
  Field: TField;
begin
  Result := '';
  Field := GetColField(ACol);
  if Field <> nil then Result := Field.DisplayText;
end;

function TCustomDBGridEh.GetSelectedField: TField;
var
  Index: Integer;
begin
  Index := SelectedIndex;
  if Index <> -1
    then Result := Columns[Index].Field
    else Result := nil;
end;

function TCustomDBGridEh.GetSelectedIndex: Integer;
begin
  Result := RawToDataColumn(Col);
end;

function TCustomDBGridEh.HighlightCell(DataCol, DataRow: Integer;
  const Value: string; AState: TGridDrawState): Boolean;
var AFocused:Boolean;
//  Index: Integer;
begin
  Result := False;
  if (dgMultiSelect in Options) and Datalink.Active then
  begin
    Result := Selection.DataCellSelected(DataCol,Datalink.Datasource.Dataset.Bookmark);
  //    if Result then
  //    Include(AState,gdSelected);
  end;
  {  if Selection.SelectionType = dgsRecordBookmarks then
      Result := FBookmarks.Find(Datalink.Datasource.Dataset.Bookmark, Index)
    else if Selection.SelectionType = dgsRectangle then
      Result := Selection.Rect.CellSelected(DataCol,Datalink.Datasource.Dataset.Bookmark);
  if not Result then
    if Selection.Columns.IndexOf(Columns[DataCol]) <> -1 then
      Result := True
     else
      Result := False;}
  if not Result then
  begin
    AFocused := Focused and (dghHighlightFocus in OptionsEh);
    if (dghRowHighlight in OptionsEh) and (DataRow + FTitleOffset = Row) and
       (Selection.SelectionType = gstNon) and not (DataCol + FIndicatorOffset = Col) then
    begin
      AFocused := True;
      AState := AState + [gdSelected];
    end;
    Result := ((gdSelected in AState) {ddd//}or ((DataRow + FTitleOffset) = Row ) and (dgRowSelect in Options))
      and ((dgAlwaysShowSelection in Options) or (AFocused {ddd//}))
        { updatelock eliminates flicker when tabbing between rows }
      and ((UpdateLock = 0) or (dgRowSelect in Options));
  end;
end;


procedure TCustomDBGridEh.ClearSelection;
begin
  if (dgMultiSelect in Options) and (dghClearSelection in OptionsEh) then
  begin
    FBookmarks.Clear;
    FSelecting := False;
  end
  else FSelecting := False;
  if (Selection.SelectionType <> gstNon) and (dghClearSelection in OptionsEh) then
  begin
    Selection.Clear;
    Invalidate;
  end;
end;

procedure TCustomDBGridEh.DoSelection(Select: Boolean; Direction: Integer;
                                      MaxDirection, RowOnly: Boolean);
var
  AddAfter: Boolean;
  DisabledControls: Boolean;
begin
  if RowOnly or (dgRowSelect in Options) then
  begin
    AddAfter := False;
    Select := Select and CanSelectType(gstRecordBookmarks);
    DisabledControls := False;
    BeginUpdate;
    try
      if ((Abs(Direction) >= FDataLink.RecordCount) or MaxDirection) and
         (((Direction > 0) and not DataSource.DataSet.EOF) or
          ((Direction < 0) and not DataSource.DataSet.BOF)) then
      begin
        //DisabledControls := True;
        //DataSource.DataSet.DisableControls;
      end;
      try
        while (Direction <> 0) {or (MaxDirection and not FDatalink.EOF and not FDatalink.BOF)} do
        begin
          if (dgMultiSelect in Options) and FDatalink.Active then
            if Select {ddd and (ssShift in Shift)} then
            begin
              if not FSelecting then
              begin
                FSelectionAnchor := FBookmarks.CurrentRow;
                {ddd//}
                FSelectionAnchorSelected := FBookmarks.CurrentRowSelected;
                if FAntiSelection then
                  FBookmarks.CurrentRowSelected := not FSelectionAnchorSelected
                else
                {ddd\\\}
                  FBookmarks.CurrentRowSelected := True;
                FSelecting := True;
                AddAfter := True;
              end
              else
              with FBookmarks do
              begin
                AddAfter := Compare(CurrentRow, FSelectionAnchor) <> -(Direction div Abs(Direction));
                if not AddAfter then
                  if FAntiSelection
                    then CurrentRowSelected := FSelectionAnchorSelected
                    else CurrentRowSelected := False;
              end
            end
            else
              ClearSelection;
          if FDatalink.Dataset.MoveBy(Direction div Abs(Direction)) = 0 then Exit;
////ddd      if AddAfter then FBookmarks.CurrentRowSelected := True;
          if AddAfter then
            if FAntiSelection
              then FBookmarks.CurrentRowSelected := not FSelectionAnchorSelected
              else FBookmarks.CurrentRowSelected := True;
          if not MaxDirection then
            if (Direction > 0) then Dec(Direction) else Inc(Direction);
        end;
////ddd\\\
      finally
        if DisabledControls then DataSource.DataSet.EnableControls;
      end;
    finally
      EndUpdate;
    end
  end else   //Rectangle select
  begin
    Select := Select and CanSelectType(gstRectangle);
    if not Select then
      FDatalink.Dataset.MoveBy(Direction)
    else
    begin
      BeginUpdate;
      try
        if Selection.FSelectionType <> gstRectangle then
        begin
          Selection.Rect.Clear;
          Selection.Rect.Select(RawToDataColumn(Col),Datalink.Datasource.Dataset.Bookmark,True);
        end;
        if MaxDirection then
          if Direction = 1
            then FDatalink.Dataset.Last
            else FDatalink.Dataset.First
        else
          FDatalink.Dataset.MoveBy(Direction);
        Selection.Rect.Select(RawToDataColumn(Col),Datalink.Datasource.Dataset.Bookmark,True);
      finally
        EndUpdate;
      end;
    end;
  end;
  if UpdateLock = 0 then Update;
end;


procedure TCustomDBGridEh.KeyDown(var Key: Word; Shift: TShiftState);
var
  KeyDownEvent: TKeyEvent;

  procedure NextRow(Select: Boolean);
  begin
    with FDatalink.Dataset do
    begin
      if (State = dsInsert) and not Modified and not FDatalink.FModified then
        if EOF then Exit else Cancel
      else {ddd//} if ssShift in Shift then
          DoSelection(Select, 1,False,False)
      {ddd//} else begin DoSelection(False, 1,False,True) end;
      if EOF and CanModify and (not ReadOnly) and
         (dgEditing in Options) and (alopAppendEh in AllowedOperations)
        then Append;
    end;
  end;

  procedure PriorRow(Select: Boolean);
  begin
    with FDatalink.Dataset do
      if (State = dsInsert) and not Modified and EOF and
        not FDatalink.FModified then
        Cancel
      else {ddd//} if ssShift in Shift then
          DoSelection(Select, -1,False,False)
      {ddd//} else begin DoSelection(False, -1,False,True) end;
  end;

  procedure Tab(GoForward: Boolean);
  var
    ACol, Original: Integer;
  begin
    ACol := Col;
    Original := ACol;
    ClearSelection;
    BeginUpdate;    { Prevent highlight flicker on tab to next/prior row }
    try
      while True do
      begin
        if GoForward then
          Inc(ACol) else
          Dec(ACol);
        if ACol >= ColCount then
        begin
          NextRow(False);
          ACol := {//dddFIndicatorOffset} IndicatorOffset {\\\};
        end
        else if ACol < {//dddFIndicatorOffset} IndicatorOffset {\\\} then
        begin
          PriorRow(False);
          ACol := ColCount {d/}-FIndicatorOffset{\};
        end;
        if ACol = Original then Exit;
        if TabStops[ACol] then
        begin
          MoveCol(ACol,0,False);
          Exit;
        end;
      end;
    finally
      EndUpdate;
    end;
  end;

  function DeletePrompt: Boolean;
  var
    Msg: string;
  begin
    if (FBookmarks.Count > 1)
      then Msg := SDeleteMultipleRecordsQuestion
      else Msg := SDeleteRecordQuestion;
    Result := not (dgConfirmDelete in Options) or
      (MessageDlg(Msg, mtConfirmation, mbOKCancel, 0) <> idCancel);
  end;

const
  RowMovementKeys = [VK_UP, VK_PRIOR, VK_DOWN, VK_NEXT, VK_HOME, VK_END];

begin
  KeyDownEvent := OnKeyDown;
  {ddd//} FAntiSelection := (ssCtrl in Shift) or not (dghClearSelection in OptionsEh);
  if Assigned(KeyDownEvent) then KeyDownEvent(Self, Key, Shift);
  if UseRightToLeftAlignment then
    if Key = VK_LEFT then
      Key := VK_RIGHT
    else if Key = VK_RIGHT then
      Key := VK_LEFT;
  if not FDatalink.Active or not CanGridAcceptKey(Key, Shift)
    then Exit;
  if (ShortCut(Key,Shift) = DBGridEhInplaceSearchKey) and (dghIncSearch in OptionsEh)
    then StartInplaceSearch('',-1,inpsFromFirstEh)
  else if FInplaceSearching then
    if (Key in [VK_ESCAPE,VK_RETURN,VK_F2]) and (Shift = [])
      then StopInplaceSearch
    else if (Key = VK_BACK) and (Shift = []) then
    begin
      FInplaceSearchText := Copy(FInplaceSearchText,1,Length(FInplaceSearchText)-1);
      GridInvalidateRow(Self,Row);
      StartInplaceSearchTimer;
    end else if ShortCut(Key,Shift) = DBGridEhInplaceSearchNextKey
      then StartInplaceSearch('',FInplaceSearchTimeOut,inpsToNextEh)
    else if ShortCut(Key,Shift) = DBGridEhInplaceSearchPriorKey
      then StartInplaceSearch('',FInplaceSearchTimeOut,inpsToPriorEh);
  with FDatalink.DataSet do
    if ssCtrl in Shift then
    begin
      if (Key in RowMovementKeys) and not (ssShift in Shift) then ClearSelection;
      case Key of
        VK_UP, VK_PRIOR: {d/} if (ssShift in Shift) and (dgMultiSelect in Options)
                                then DoSelection(True,-FDatalink.ActiveRecord,False,False)
                                else {d\} MoveBy(-FDatalink.ActiveRecord);
        VK_DOWN, VK_NEXT: {d/} if (ssShift in Shift) and (dgMultiSelect in Options)
                                 then DoSelection(True,FDatalink.BufferCount - FDatalink.ActiveRecord - 1,False,False)
                                 else {d\} MoveBy(FDatalink.BufferCount - FDatalink.ActiveRecord - 1);
//ddd        VK_LEFT: MoveCol(FIndicatorOffset);
        VK_LEFT: MoveCol({//dddFIndicatorOffset} IndicatorOffset {\\\},1,False);
        VK_RIGHT: MoveCol(ColCount - 1,-1,False);
        VK_HOME: {d/} if (ssShift in Shift) and (dgMultiSelect in Options)
                        then DoSelection(True,-1,True,False)
                        else {d\} First;
        VK_END:  {d/} if (ssShift in Shift) and (dgMultiSelect in Options)
                      then DoSelection(True,1,True,False)
                      else {d\} Last;
        VK_DELETE:
          if (geaDeleteEh in EditActions) and (Selection.SelectionType <> gstNon) then
          begin
            if CheckDeleteAction then
              DBGridEh_DoDeleteAction(Self,False);
          end
          else if (not Self.ReadOnly) and (not ReadOnly) and not IsEmpty
               and CanModify and (alopDeleteEh in AllowedOperations) and DeletePrompt then
            if FBookmarks.Count > 0
              then FBookmarks.Delete
              else Delete;
        VK_INSERT,Word('C'):
          if CheckCopyAction and (geaCopyEh in EditActions) then
            DBGridEh_DoCopyAction(Self,False);
        Word('X'):
          if CheckCutAction and (geaCutEh in EditActions) then
            DBGridEh_DoCutAction(Self,False);
        Word('V'):
          if FInplaceSearching then
            StartInplaceSearch(ClipBoard.AsText,FInplaceSearchTimeOut,inpsFromFirstEh)
          else if CheckPasteAction and (geaPasteEh in EditActions) then
            DBGridEh_DoPasteAction(Self,False);
        Word('A'):
          if CheckSelectAllAction and (geaSelectAllEh in EditActions) then
            Selection.SelectAll;
      end
    end
    else
      case Key of
        VK_UP: PriorRow(True);
        VK_DOWN: NextRow(True);
        VK_LEFT:
          if dgRowSelect in Options then
          begin
             if(LeftCol > {//dddIndicatorOffset} FixedCols {\\\}) then LeftCol := LeftCol - 1
          end
            {PriorRow(False)} else if (dgMultiSelect in Options) and (ssShift in Shift) then
              MoveCol(Col - 1,-1,True)
            else
            begin
              ClearSelection;
              MoveCol(Col - 1,-1,False);
            end;
        VK_RIGHT:
          if dgRowSelect in Options then
          begin
            if(VisibleColCount + LeftCol < ColCount ) then
                LeftCol := LeftCol + 1;  {new}
           { NextRow(False) }
           end else if (dgMultiSelect in Options) and (ssShift in Shift)
            then MoveCol(Col + 1,1,True)
           else
           begin
             ClearSelection;
             MoveCol(Col + 1,1,False);
           end;
        VK_HOME:
          if (ColCount = FIndicatorOffset+1) or (dgRowSelect in Options) then
          begin
            if (ssShift in Shift) and (dgMultiSelect in Options)
              then DoSelection(True,-1,True,False)
            else
            begin
              ClearSelection;
              First;
            end;
          end else if (dgMultiSelect in Options) and (ssShift in Shift) then
            MoveCol(FIndicatorOffset,1,True)
          else
            MoveCol(FIndicatorOffset,1,False);
        VK_END:
          if (ColCount = FIndicatorOffset+1)
            or (dgRowSelect in Options) then
          begin
            if (ssShift in Shift) and (dgMultiSelect in Options) then
              DoSelection(True,1,True,False)
            else
            begin
              ClearSelection;
              Last;
            end;
          end else if (dgMultiSelect in Options) and (ssShift in Shift) then
            MoveCol(ColCount - 1,-1,True)
          else
            MoveCol(ColCount - 1,-1,False);
        VK_NEXT:
          begin
            if (ssShift in Shift) and (dgMultiSelect in Options) then
              DoSelection(True,VisibleDataRowCount,False,False)
            else
            begin
              ClearSelection;
              MoveBy({ddd//VisibleRowCount} VisibleDataRowCount {ddd\\});
            end;
          end;
        VK_PRIOR:
          begin
            //ddd
            if (ssShift in Shift) and (dgMultiSelect in Options) then
              DoSelection(True,-VisibleDataRowCount,False,False)
            else begin
              ClearSelection;
              MoveBy({ddd//VisibleRowCount} -VisibleDataRowCount {ddd\\});
            end;
            //\\\
          end;
        VK_INSERT:
          if (ssShift in Shift) then
          begin
            if FInplaceSearching then
              StartInplaceSearch(ClipBoard.AsText,FInplaceSearchTimeOut,inpsFromFirstEh)
            else if CheckPasteAction and (geaPasteEh in EditActions) then
              DBGridEh_DoPasteAction(Self,False)
          end
          else if CanModify and (not ReadOnly) and (dgEditing in Options) then
          begin
            ClearSelection;
            if alopInsertEh in AllowedOperations then Insert
            else if alopAppendEh in AllowedOperations then Append;
          end;
        VK_TAB: if not (ssAlt in Shift) then Tab(not (ssShift in Shift));
        VK_RETURN: if dghEnterAsTab in OptionsEh then Tab(not (ssShift in Shift));
        VK_ESCAPE:
          begin
            FDatalink.Reset;
            ClearSelection;
            if not (dgAlwaysShowEditor in Options) then HideEditor;
            if (FGridState in [gsColMoving,gsRowSizing,gsColSizing]) or
               (FDBGridEhState = dgsColSizing)
               then Perform(WM_CANCELMODE,0,0);
          end;
        VK_F2: EditorMode := True;
        VK_DELETE:
          if (ssShift in Shift) and CheckCutAction and (geaCutEh in EditActions) then
            DBGridEh_DoCutAction(Self,False);
      end;
  if (Columns[SelectedIndex].GetColumnType in [ctKeyImageList..ctCheckboxes]) and
      (Key = VK_DELETE) and not (dgRowSelect in Options) then
    if Assigned(Columns[SelectedIndex].Field) and
      not Columns[SelectedIndex].Field.Required and
      Columns[SelectedIndex].CanModify(True) then
         //Columns[SelectedIndex].Field.Clear;
         Columns[SelectedIndex].UpdateDataValues('',Null,False);
end;

procedure TCustomDBGridEh.KeyPress(var Key: Char);
begin
  if (dghEnterAsTab in OptionsEh) and (Integer(Key) = VK_RETURN) then Key:= #9;
  if not (dgAlwaysShowEditor in Options) and (Key = #13) then
    FDatalink.UpdateData
  else if (FInplaceSearching or
          ((dghIncSearch in OptionsEh) and not CanEditModifyColumn(SelectedIndex)) or
           ((dghPreferIncSearch in OptionsEh) and not (dgAlwaysShowEditor in Options)
            and not InplaceEditorVisible)
               ) and (Key >= #32)
  then
  begin
    if FInplaceSearching
      then StartInplaceSearch(Key,FInplaceSearchTimeOut,inpsFromFirstEh)
      else StartInplaceSearch(Key,DBGridEhInplaceSearchTimeOut,inpsFromFirstEh);
  end;
  inherited KeyPress(Key);
end;

procedure TCustomDBGridEh.WMChar(var Message: TWMChar);
begin
  {Don't use KeyPress because KeyPress is invoked only after
  first showing of inplace editor}
  if (Columns[SelectedIndex].GetColumnType in [ctKeyImageList..ctCheckboxes]) and
                  ((Char(Message.CharCode) = ' ') and not (dgRowSelect in Options)) then
  begin
    DoKeyPress(Message);
    if Char(Message.CharCode) = ' ' then
      if ssShift in KeyDataToShiftState(Message.KeyData)
        then Columns[SelectedIndex].SetNextFieldValue(-1)
        else Columns[SelectedIndex].SetNextFieldValue(1);
  end
  else if (FInplaceSearching or
          ((dghIncSearch in OptionsEh) and not CanEditModifyColumn(SelectedIndex)) or
          ((dghPreferIncSearch in OptionsEh) and not (dgAlwaysShowEditor in Options)
            and not InplaceEditorVisible )
               ) and (Char(Message.CharCode) >= #32)
  then
  begin
    DoKeyPress(Message);
  end else
    inherited;
end;


{ InternalLayout is called with layout locks and column locks in effect }
procedure TCustomDBGridEh.InternalLayout;
var
  I, J, K, OldLeftCol: Integer;
  Fld: TField;
  Column: TColumnEh;
  SeenPassthrough: Boolean;
  RestoreCanvas: Boolean;

  tm: TTEXTMETRIC;
  CW, CountedWidth, FirstInvisibleColumns, ColWidth: Integer;
  AFont: TFont;
  NotInWidthRange: Boolean;

  function FieldIsMapped(F: TField): Boolean;
  var
    X: Integer;
  begin
    Result := False;
    if F = nil then Exit;
    for X := 0 to FDatalink.FieldCount-1 do
      if FDatalink.Fields[X] = F then
      begin
        Result := True;
        Exit;
      end;
  end;

begin
  if (csLoading in ComponentState) then Exit;

  if HandleAllocated then KillMessage(Handle, cm_DeferLayout);

  { Check for Columns.State flip-flop }
  SeenPassthrough := False;
  for I := 0 to FColumns.Count-1 do
  begin
    if not FColumns[I].IsStored then
      SeenPassthrough := True
    else
      if SeenPassthrough then
      begin   { We have both custom and passthrough columns. Kill the latter }
        for J := FColumns.Count-1 downto 0 do
        begin
          Column := FColumns[J];
          if not Column.IsStored then
            Column.Free;
        end;
        Break;
      end;
  end;

  FIndicatorOffset := 0;
  if dgIndicator in Options
    then Inc(FIndicatorOffset);
  FDatalink.ClearMapping;
  if FDatalink.Active then DefineFieldMap;
  if FColumns.State = csDefault then
  begin
     { Destroy columns whose fields have been destroyed or are no longer
       in field map }
    if (not FDataLink.Active) and (FDatalink.DefaultFields) then
      FColumns.Clear
    else
      for J := FColumns.Count-1 downto 0 do
        with FColumns[J] do
        if not Assigned(Field)
          or not FieldIsMapped(Field) then Free;
    I := FDataLink.FieldCount;
    if (I = 0) and (FColumns.Count = 0) then Inc(I);
    for J := 0 to I-1 do
    begin
      Fld := FDatalink.Fields[J];
      if Assigned(Fld) then
      begin
        K := J;
         { Pointer compare is valid here because the grid sets matching
           column.field properties to nil in response to field object
           free notifications.  Closing a dataset that has only default
           field objects will destroy all the fields and set associated
           column.field props to nil. }
        while (K < FColumns.Count) and (FColumns[K].Field <> Fld) do
          Inc(K);
        if K < FColumns.Count then
          Column := FColumns[K]
        else
        begin
          Column := FColumns.InternalAdd;
          Column.Field := Fld;
        end;
      end
      else
        Column := FColumns.InternalAdd;
      Column.Index := J;
    end;
  end else
  begin
    { Force columns to reaquire fields (in case dataset has changed) }
    for I := 0 to FColumns.Count-1 do
      FColumns[I].Field := nil;
  end;
  FVisibleColumns.Clear;

  FirstInvisibleColumns := 0;
  for I := 0 to FColumns.Count-1 do
    if FColumns[I].Visible = True then
    begin
      FVisibleColumns.Add(FColumns[I]);
    end
    else if (FrozenCols + FirstInvisibleColumns> I)
      then Inc(FirstInvisibleColumns);

  for I := FrozenCols + FirstInvisibleColumns to FColumns.Count-1 do
   if (FColumns[I].Visible = False)
    then Inc(FirstInvisibleColumns)
    else Break;

  if VisibleColumns.Count = 0 then Dec(FirstInvisibleColumns);

  ColCount := FColumns.Count + FIndicatorOffset;
//  inherited FixedCols := FIndicatorOffset + FrozenCols + FirstInvisibleColumns;
  if not FDataLink.Active and (Columns.State = csDefault)
    then inherited FixedCols := FIndicatorOffset + FirstInvisibleColumns
    else inherited FixedCols := FIndicatorOffset + FrozenCols + FirstInvisibleColumns;

  FTitleOffset := 0;
  if dgTitles in Options then FTitleOffset := 1;
  RestoreCanvas := not HandleAllocated;
  if RestoreCanvas then
    Canvas.Handle := GetDC(0);
  try
    Canvas.Font := Font;
    if Flat
      then J := 1
      else J := 3;
    if dgRowLines in Options then
      Inc(J, GridLineWidth);
    K := Canvas.TextHeight('Wg');
    // DefaultRowHeight := K;
    GetTextMetrics(Canvas.Handle, tm);
    if (FNewRowHeight > 0) or (FRowLines > 0)
      then DefaultRowHeight := FNewRowHeight + (tm.tmExternalLeading + tm.tmHeight)*FRowLines
      else DefaultRowHeight := K + J;

    if (dghFitRowHeightToText in OptionsEh) then
    begin
      I := (DefaultRowHeight - J) mod K;
      if (I > K div 2) or ((DefaultRowHeight - J) div K = 0)
        then DefaultRowHeight := ((DefaultRowHeight - J) div K + 1) * K + J
        else DefaultRowHeight := (DefaultRowHeight - J) div K * K + J;
      FRowLines := (DefaultRowHeight - J) div K;
      FNewRowHeight := J;
    end;

    if DefaultRowHeight > Round(FInplaceEditorButtonWidth * 3 / 2)
      then FInplaceEditorButtonHeight := FInplaceEditorButtonWidth
      else FInplaceEditorButtonHeight := DefaultRowHeight;

    if (tm.tmExternalLeading + tm.tmHeight + tm.tmInternalLeading + FInterlinear < DefaultRowHeight)
      then FAllowWordWrap := True
      else FAllowWordWrap := False;

    if dgTitles in Options then
    begin
      K := 0;
      for I := 0 to FColumns.Count-1 do
      begin
        Canvas.Font := FColumns[I].Title.Font;
        J := Canvas.TextHeight('Wg') + FInterlinear;
        if J > K then K := J;
      end;
      if K = 0 then
      begin
        Canvas.Font := FTitleFont;
        K := Canvas.TextHeight('Wg') + FInterlinear;
      end;
      RowHeights[0] := K;
    end;
  finally
    if RestoreCanvas then
    begin
      ReleaseDC(0,Canvas.Handle);
      Canvas.Handle := 0;
    end;
  end;

   // ScrollBars
  if (not AutoFitColWidths or (csDesigning in ComponentState)) and HorzScrollBar.Visible
    then ScrollBars := ssHorizontal
    else ScrollBars := ssNone;

  // AutoFitColWidths
  SetColumnAttributes;
  if (FAutoFitColWidths = True) and not (csDesigning in ComponentState) then
  begin

    for i := 0 to VisibleColumns.Count - 1 do VisibleColumns[i].FNotInWidthRange := False;

    CountedWidth := 0;
    CW := 0;

    for j := 0 to VisibleColumns.Count - 1 do
    begin
      CW := 0;
      K := 0;

      UpdateScrollBar;

      for i := 0 to VisibleColumns.Count - 1 do
      begin
        if (VisibleColumns[i].AutoFitColWidth = False) or (VisibleColumns[i].FNotInWidthRange = True)
          then Inc(CW,VisibleColumns[i].Width)
          else Inc(K, VisibleColumns[i].FInitWidth);
      end;

      if (ClientWidth > FMinAutoFitWidth)
        then CW := ClientWidth - CW
        else CW := FMinAutoFitWidth - CW;
      if (CW < 0) then CW := 0;
      if (dgIndicator in Options) then Dec(CW,ColWidths[0]);
      if (dgColLines in Options) then Dec(CW,VisibleColumns.Count);
      if (dgIndicator in Options) and (dgColLines in Options) then Dec(CW,1);

      CountedWidth := 0;
      NotInWidthRange := False;

      for i := 0 to VisibleColumns.Count - 1 do
      begin
       if (VisibleColumns[i].AutoFitColWidth = True) and (VisibleColumns[i].FNotInWidthRange = False) then
       begin
         ColWidth := MulDiv(VisibleColumns[i].FInitWidth,CW,K);
         VisibleColumns[i].Width := ColWidth;
         if (ColWidth <> VisibleColumns[i].Width) then
         begin
           NotInWidthRange := True;
           VisibleColumns[i].FNotInWidthRange := True;
         end;
//         if (VisibleColumns[i].Width < 0) then VisibleColumns[i].Width := 0;
         Inc(CountedWidth,VisibleColumns[i].Width);
       end;
      end;

      if (NotInWidthRange = False) then Break;
    end;

    if (CountedWidth <> CW) then // Correct last AutoFitColWidth column
    begin
      for i := VisibleColumns.Count - 1 downto 0 do
        if (VisibleColumns[i].AutoFitColWidth = True) and (VisibleColumns[i].FNotInWidthRange = False) then
        begin
          VisibleColumns[i].Width := VisibleColumns[i].Width + CW - CountedWidth;
          if (VisibleColumns[i].Width < 0)
            then VisibleColumns[i].Width := 0;
          Break;
        end;
    end;
  end
  else HandleNeeded;

  // Title and MultyTitle
  if  (dgTitles in Options) then
  begin
    if (TitleHeight <> 0) or (TitleLines <> 0) then
    begin
      K := 0;
      for I := 0 to Columns.Count-1 do
      begin
        Canvas.Font := Columns[I].Title.Font;
        J := Canvas.TextHeight('Wg') + FInterlinear;
        if J > K then
          begin K := J; GetTextMetrics(Canvas.Handle, tm); end;
      end;
      if K = 0 then
      begin
       Canvas.Font := TitleFont;
       GetTextMetrics(Canvas.Handle, tm);
      end;

      FTitleHeightFull :=  tm.tmExternalLeading + tm.tmHeight*FTitleLines+2 +
                                FTitleHeight;

      if dgRowLines in Options
        then FTitleHeightFull := FTitleHeightFull + 1;

      RowHeights[0] := FTitleHeightFull;
    end;

    if (UseMultiTitle = True) then
    begin
      ReallocMem(FLeafFieldArr,SizeOf(LeafCol)*Columns.Count);
      AFont := Canvas.Font;
      Canvas.Font := TitleFont;
      for i := 0 to Columns.Count - 1 do
        FLeafFieldArr[i].FColumn := Columns[i];
      FHeadTree.CreateFieldTree(Self);
      RowHeights[0] := SetChildTreeHeight(FHeadTree) - iif(dghFixed3D in OptionsEh,1,3); // +2;
      Canvas.Font := AFont;
    end;
  end;


  //tmp UpdateRowCount;
  SetColumnAttributes;
  if dgRowSelect in Options then
  begin
    OldLeftCol := LeftCol;
    FLockPaint := True;
    try
     UpdateRowCount;
    finally
      LeftCol := OldLeftCol;
      FLockPaint := False;
    end;
  end else
    UpdateRowCount;
  UpdateActive;
  Invalidate;
  if Selection.SelectionType = gstColumns
    then Selection.Columns.Refresh;
end;

procedure TCustomDBGridEh.LayoutChanged;
begin
  if AcquireLayoutLock
    then EndLayout;
end;

procedure TCustomDBGridEh.LinkActive(Value: Boolean);
begin
  if not Value then HideEditor;
  //new FBookmarks.LinkActive(Value);
  Selection.LinkActive(Value);
  if (Assigned(DataSource))
    then SumList.DataSet := DataSource.DataSet
    else SumList.DataSet := nil;
  LayoutChanged;
  if Value and (dgAlwaysShowEditor in Options)
    then ShowEditor;
  UpdateScrollBar;
end;

procedure TCustomDBGridEh.Loaded;
var i:Integer;
begin
  inherited Loaded;
  if FColumns.Count > 0 then
  begin
    ColCount := FColumns.Count;
    if (FAutoFitColWidths = True) and not (csDesigning in ComponentState) then
    begin
      Columns.BeginUpdate;
      for i := 0  to Columns.Count - 1 do
      begin
        Columns[i].FInitWidth := Columns[i].Width;
      end;
      Columns.EndUpdate;
      ScrollBars := ssNone;
    end;
    SetSortMarkedColumns;
    if SortMarkedColumns.Count > 0 then DoSortMarkingChanged;
  end;
  if Assigned(DataSource) then
//    FSumList.DataSet := DataSource.DataSet;
    FSumList.Loaded;
  LayoutChanged;
  DeferLayout;
end;

procedure TCustomDBGridEh.ChangeScale(M, D: Integer);
var
  Flags: TScalingFlags;
  i,j: Integer;
  WidthInc,WidthIncScaled,OldWidthIncScaled: Integer;
begin
  if M <> D then
  begin
    if csLoading in ComponentState
      then Flags := ScalingFlags
      else Flags := [sfFont];
    if not ParentFont and (sfFont in Flags) then
    begin
      TitleFont.Size := MulDiv(Font.Size, M, D);
      FooterFont.Size := MulDiv(FooterFont.Size, M, D);
    end;
    if sfFont in Flags then
      try
        WidthInc := 0;
        OldWidthIncScaled := 0;
        Columns.BeginUpdate;
        for i := 0 to Columns.Count-1 do
          with Columns[i] do
          begin
            if cvFont in AssignedValues
              then Font.Size := MulDiv(Font.Size, M, D);
            if cvTitleFont in AssignedValues
              then Title.Font.Size := MulDiv(Title.Font.Size, M, D);
            if cvFooterFont in Footer.AssignedValues
              then Footer.Font.Size := MulDiv(Footer.Font.Size, M, D);
            for j := 0 to Footers.Count-1 do
              if cvFooterFont in Footers[j].AssignedValues
                then Footers[j].Font.Size := MulDiv(Footers[j].Font.Size, M, D);
            Inc(WidthInc,Width);
            WidthIncScaled := MulDiv(WidthInc, M, D);
            Width := WidthIncScaled - OldWidthIncScaled;
            OldWidthIncScaled := WidthIncScaled;
          end;
      finally
        Columns.EndUpdate;
      end;
  end;
  inherited ChangeScale(M, D);
end;

function PointInRect(const P: TPoint; const R: TRect): Boolean;
begin
  with R do
    Result := (Left <= P.X) and (Top <= P.Y) and
      (Right >= P.X) and (Bottom >= P.Y);
end;

procedure TCustomDBGridEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Cell: TGridCoord;
  OldCol,OldRow, Xm,Ym: Integer;
  EnableClick: Boolean;
  ARect, ButtonRect: TRect;
  Flag: Boolean;
  MouseDownEvent: TMouseEvent;
  AEditStyle: TEditStyle;
  APointInRect: Boolean;
  TargetWC: TWinControl;
  OldBM: TBookmarkStr;
  DrawInfo: TGridDrawInfo;
begin
  if Button = mbRight then MouseCapture := True;
  Xm := X; Ym := Y;
  FPressedCell.X := -1; FPressedCell.Y := -1;
  FDownMousePos := Point(X, Y);
  if not AcquireFocus then Exit;
  if (ssDouble in Shift) and (Button = mbLeft) then
  begin
    DblClick;
    Cell := MouseCoord(X, Y);
    if (Cell.X > IndicatorOffset-1) and (Cell.Y > FTitleOffset-1) and
       (Cell.Y < iif(FooterRowCount > 0,RowCount-FooterRowCount-1,MaxInt)) and
       (Columns[Cell.X - IndicatorOffset].GetColumnType in [ctKeyImageList..ctCheckboxes]) then
      begin
        if Columns[Cell.X - IndicatorOffset].DblClickNextVal and (ssDouble in Shift)
        then
          if (ssShift in Shift)
            then Columns[Cell.X - IndicatorOffset].SetNextFieldValue(-1)
            else Columns[Cell.X - IndicatorOffset].SetNextFieldValue(1);
      end;

    MouseDownEvent := OnMouseDown;
    if Assigned(MouseDownEvent)
      then MouseDownEvent(Self, Button, Shift, X, Y);
    Exit;
  end
  else if (Button = mbLeft) then
  begin
    CalcFrozenSizingState(X, Y, FDBGridEhState, FSizingIndex, FSizingPos, FSizingOfs);
    if FDBGridEhState <> dgsNormal then
    begin
      if not (dghTraceColSizing in OptionsEh) then
        DrawSizingLine(GridWidth, GridHeight);
      Exit;
    end;
  end;
  if Sizing(X, Y) then
  begin
    FDatalink.UpdateData;

    if (dghTraceColSizing in OptionsEh) and (Button = mbLeft) then
    begin
      CalcDrawInfo(DrawInfo);
      { Check grid sizing }
      CalcSizingState(X, Y, FGridState, FSizingIndex, FSizingPos, FSizingOfs, DrawInfo);
      if FGridState = gsColSizing then
      begin
        if UseRightToLeftAlignment then
          FSizingPos := ClientWidth - FSizingPos;
        //DrawSizingLine(GridWidth, GridHeight);
        Exit;
      end
      else
        inherited MouseDown(Button, Shift, X, Y);
    end else
      inherited MouseDown(Button, Shift, X, Y)
  end else
  begin
    Cell := MouseCoord(X, Y);
    ARect := CellRect(Cell.X,Cell.Y);

    if (FUseMultiTitle =  True) and (dgTitles in Options) then
    begin
      if (Cell.X > IndicatorOffset-1) and
        (PtInRect(Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom - FLeafFieldArr[Cell.X-IndicatorOffset].FLeaf.Height + 1),
                  Point(X, Y)))
        then Flag := False
        else Flag := True;
    end
    else Flag := True;
    if GetCursor = hcrDownCurEh then //columns selection
    begin
      InvalidateCol(Cell.X);
      FDBGridEhState := dgsColSelecting;
      ResetTimer(60);
      //tmpSetTimer(Handle, 1, 60, nil);
      if ssShift in Shift
        then Selection.Columns.SelectShift(Columns[Cell.X - IndicatorOffset]{,False})
      else if ssCtrl in Shift
        then  Selection.Columns.InvertSelect(Columns[Cell.X - IndicatorOffset])
      else
      begin
        Invalidate;
        Selection.Columns.Select(Columns[Cell.X - IndicatorOffset],False);
      end;
      Exit;
    end
    else
    if {tmp(Datalink <> nil) and Datalink.Active and}
      (Cell.Y < TitleOffset) and (Cell.X >= IndicatorOffset) and
      not (csDesigning in ComponentState) and Flag then
    begin
      if (dgColumnResize in Options) and (Button = mbRight) then
      begin
        Button := mbLeft;
        FSwapButtons := True;
        //MouseCapture := True;
      end
      else if Button = mbLeft then
      begin
        EnableClick := Columns[Cell.X - IndicatorOffset].Title.TitleButton;
        CheckTitleButton(Cell.X - IndicatorOffset, EnableClick);
        if EnableClick then
        begin
          //MouseCapture := True;
          if not MouseCapture then Exit;
          FTracking := True;
          FPressedCol := Cell.X;
          TrackButton(X, Y);
          Exit;
        end;
      end;
    end;

    if ((csDesigning in ComponentState) or (dgColumnResize in Options)) and (Cell.Y < FTitleOffset) then
    begin
      //d top-left cell
      if (Cell.X < FIndicatorOffset) and (dgMultiSelect in Options) and
         (Cell.Y <> -1) and FDatalink.Active and (gstAll in AllowedSelections) then
       begin
        {if FBookmarks.Count > 0 then begin
          FBookmarks.Clear;
          FSelecting := False;
        end else
          FBookmarks.SelectAll;}
        if Selection.SelectionType <> gstNon then
          Selection.Clear
        else
          Selection.SelectAll;
        InvalidateEditor;
       end;
      FDataLink.UpdateData;
      Canvas.Pen.Color := clSilver; // Column move line fixup when no dgColLines
      inherited MouseDown(Button, Shift, X, Y)
    end
    else if Cell.Y < iif(FooterRowCount > 0,RowCount-FooterRowCount-1,MaxInt) then
    begin
      if FDatalink.Active then
        with Cell do
        begin
          BeginUpdate;   { eliminates highlight flicker when selection moves }
          try
            FDatalink.UpdateData; // validate before moving
            HideEditor;
            OldCol := Col;
            OldRow := Row;
            OldBM := DataSource.DataSet.Bookmark;
            if (Y >= FTitleOffset) and (Y - Row <> 0) then
              if not ({(ssAlt in Shift) and} {(ssShift in Shift) and (dgMultiSelect in Options)}
               (ssShift in Shift) and (dgMultiSelect in Options) {ddd//}
                 and ((dgRowSelect in Options) or (X < FIndicatorOffset)) ) then
                FDatalink.Dataset.MoveBy(Y - Row);
            if X >= FIndicatorOffset then
              MoveCol(X,0,False);
            if FAutoDrag and not (ssShift in Shift) and (Button = mbLeft) and (X >= FIndicatorOffset) and
               Selection.DataCellSelected(Cell.X - IndicatorOffset,DataSource.DataSet.Bookmark) then
            begin
              FSelectedCellPressed := True;
              Exit;
            end;
            if PtInRect(DataRect,Point(Xm,Ym)) and
                (not (dgMultiSelect in Options) or
                  ((dgMultiSelect in Options) and not (dgRowSelect in Options))) then
            begin
//              MouseCapture := True;
              if not MouseCapture then Exit;
              FTracking := True;
              FDataTracking := True;
              if not (ssCtrl in Shift) and not (ssShift in Shift) and (dghClearSelection in OptionsEh) and
                     ((Button = mbLeft) or (not Selection.DataCellSelected(Cell.X - IndicatorOffset,DataSource.DataSet.Bookmark))) then {FBookmarks.Clear}
                ClearSelection;
              if (X >= FIndicatorOffset) and CanSelectType(gstRectangle) {(dgMultiSelect in Options)} and
                 (Button = mbLeft) and not (DataSource.DataSet.Eof and DataSource.DataSet.Bof) then
                begin
                  if ssShift in Shift then
                    if Selection.SelectionType = gstRectangle then
                      Selection.Rect.Select(Cell.X - IndicatorOffset,DataSource.DataSet.Bookmark,True)
                    else
                    begin
                      Selection.Rect.Select(OldCol - IndicatorOffset,OldBM,False);
                      Selection.Rect.Select(Cell.X - IndicatorOffset,DataSource.DataSet.Bookmark,True);
                    end
                  else
                    Selection.Rect.Select(Cell.X - IndicatorOffset,DataSource.DataSet.Bookmark,False);
                  FDBGridEhState := dgsRectSelecting;
                end;
            end;
            if CanSelectType(gstRecordBookmarks)
                 and ((dgRowSelect in Options) or (X < FIndicatorOffset)) then
              with FBookmarks do
              begin
                FSelecting := False;
                if {(ssAlt in Shift) and} (ssShift in Shift) and (Y - Row <> 0) then
                begin
                  FSelecting := True;
                  FAntiSelection := True;
                  DoSelection(True, Y-Row,False,True);
                end
                else if ((ssCtrl in Shift) or not (dghClearSelection in OptionsEh)) and (Button = mbLeft)
                  then CurrentRowSelected := not CurrentRowSelected
                else
                begin
                  if (Button = mbLeft) {not ((Button = mbRight) and (CurrentRowSelected = True))} then
                  begin
                    if dghClearSelection in OptionsEh then ClearSelection; //newClear;
                    CurrentRowSelected := True;
                  end;
                end;
                if (dgRowSelect in Options) or
                   ((X < FIndicatorOffset) and not (dgRowSelect in Options)) then
                begin
                  FIndicatorPressed := True;
//                  MouseCapture := True;
                  if not MouseCapture then Exit;
                  FTracking := True;
                  FPresedRecord := DataSource.DataSet.Bookmark;
                  FSelecting := True;
                  FSelectionAnchorSelected := not CurrentRowSelected;
                  FSelectionAnchor := FBookmarks.CurrentRow;
                  FAntiSelection := (ssCtrl in Shift) or not (dghClearSelection in OptionsEh);
                  FDBGridEhState := dgsRowSelecting;
                end;
              end;

            if (Button = mbLeft) and
              (((X = OldCol) and (Y = OldRow)) or (dgAlwaysShowEditor in Options)) then
                ShowEditor;         { put grid in edit mode }
            if (Button = mbLeft) then
            begin
              if (Cell.X > IndicatorOffset-1) and (Columns[Cell.X - IndicatorOffset].AlwaysShowEditButton)
                then AEditStyle := GetColumnEditStile(Columns[Cell.X - IndicatorOffset])
                else AEditStyle := esSimple;

              if UseRightToLeftAlignment
                then ButtonRect := Rect(ARect.Left, ARect.Top, ARect.Left + FInplaceEditorButtonWidth, ARect.Bottom)
                else ButtonRect := Rect(ARect.Right - FInplaceEditorButtonWidth, ARect.Top, ARect.Right, ARect.Bottom);
              APointInRect := PointInRect(Point(Xm,Ym),ButtonRect);
              if (dgAlwaysShowEditor in Options) or ((AEditStyle <> esSimple) and APointInRect) or
                 ((X = OldCol) and (Y = OldRow))
                then ShowEditor;

              if (InplaceEditor <> nil) and InplaceEditor.Visible and
                 APointInRect and (Y >= FTitleOffset) and (X >= FIndicatorOffset) then
              begin
                if (Cell.X > IndicatorOffset-1) and (GetColumnEditStile(Columns[Cell.X - IndicatorOffset]) <> esSimple) then
                begin
                  StopTracking;
                   {if InplaceEditor.Visible then begin
                     AMousePoint := InplaceEditor.ScreenToClient(ClientToScreen(Point(Xm,Ym)));
                     TDBGridInplaceEdit(InplaceEditor).MouseDown(Button,Shift,AMousePoint.X,AMousePoint.Y);
                     //InplaceEditor.Perform(WM_LBUTTONDOWN,MK_LBUTTON,
                     //    Longint(PointToSmallPoint(InplaceEditor.ScreenToClient(ClientToScreen(Point(Xm,Ym))))));
                   end;}
                  TargetWC := FindVCLWindow(ClientToScreen(Point(Xm,Ym)));
                  if (TargetWC <> nil) and (TargetWC <> Self) then
                    TargetWC.Perform(WM_LBUTTONDOWN,MK_LBUTTON,
                         Longint(PointToSmallPoint(TargetWC.ScreenToClient(ClientToScreen(Point(Xm,Ym))))));
                end;
              end;


              if (Cell.X > IndicatorOffset-1) and
                  (Columns[Cell.X - IndicatorOffset].GetColumnType in [ctKeyImageList..ctCheckboxes])
                then FPressedCell := Cell;

{                if ((dgAlwaysShowEditor in Options) and (InplaceEditor <> nil) and (InplaceEditor.Visible)) then
                   InplaceEditor.Perform(WM_LBUTTONDOWN,MK_LBUTTON,
                     Longint(PointToSmallPoint(InplaceEditor.ScreenToClient(ClientToScreen(Point(Xm,Ym))))));}
            end else
              InvalidateEditor;  { draw editor, if needed }
          finally
            EndUpdate;
          end;
        end;
      MouseDownEvent := OnMouseDown;
      if Assigned(MouseDownEvent) then MouseDownEvent(Self, Button, Shift, X, Y);
    end else
    begin
      MouseDownEvent := OnMouseDown;
      if Assigned(MouseDownEvent) then
        MouseDownEvent(Self, Button, Shift, X, Y);
    end;
  end;
//  ClearSelection;
  DoOnSelectionChange;
end;

procedure TCustomDBGridEh.MouseMove(Shift: TShiftState; X, Y: Integer);
var Cell:TGridCoord;
    X1,Y1:Integer;
    WithSeleting:Boolean;
    OldMoveMousePos:TPoint;
    AddSel:Boolean;
    DrawInfo:TGridDrawInfo;
    NewSize: Integer;

  function ResizeLine(const AxisInfo: TGridAxisDrawInfo): Integer;
  var
    I: Integer;
  begin
    with AxisInfo do
    begin
      if FSizingIndex < FixedCols then
      begin
        Result := 0;
        for I := 0 to FSizingIndex - 1 do
          Inc(Result, GetExtent(I) + EffectiveLineWidth);
        Result := FSizingPos - Result;
      end else
      begin
        Result := FixedBoundary;
        for I := FirstGridCell to FSizingIndex - 1 do
          Inc(Result, GetExtent(I) + EffectiveLineWidth);
        Result := FSizingPos - Result;
      end;
    end;
  end;

begin
  X1 := X; Y1 := Y;
  OldMoveMousePos := FMoveMousePos;
  FMoveMousePos := Point(X, Y);
  Cell := MouseCoord(X1, Y1);
  if FSelectedCellPressed = True then
  begin
    FSelectedCellPressed := False;
    BeginDrag(Mouse.DragImmediate, Mouse.DragThreshold);
    BeginDrag(True);
    Exit;
  end;
  if (FTracking) and (FPressedCol <> -1) then
  begin
    TrackButton(X, Y);
    if (Abs(FDownMousePos.X - X) > 3) and (dgColumnResize in Options) then
    begin
      StopTracking;
 //     Perform(WM_LBUTTONDOWN,MK_LBUTTON,MakeWord(FMousePos.X,FMousePos.Y));
      if csCaptureMouse in ControlStyle then MouseCapture := True;
//      if csClickEvents in ControlStyle then Include(ControlState, csClicked);
      Canvas.Pen.Color := clSilver; // Column move line fixup when no dgColLines
      inherited MouseDown(mbLeft, Shift, FDownMousePos.X, FDownMousePos.Y);
    end;
  end;
  if (FIndicatorPressed or FDataTracking or (FDBGridEhState = dgsRectSelecting))
    {and not (FDBGridEhState = ghsRectSelecting)} then
  begin
//    X1 := X; Y1 := Y;
    if X1 < 0 then X1 := 0;
    if X1 >= GridWidth then X1 := GridWidth-1;
    if Y1 < 0 then Y1 := 0;
    if Y1 >= GridHeight then Y1 := GridHeight-1;
    Cell := MouseCoord(X1, Y1);
    AddSel := (OldMoveMousePos.X <> FMoveMousePos.X) or (OldMoveMousePos.Y <> FMoveMousePos.Y);
    if (Y > DataRect.Top) and (Y < DataRect.Bottom) then
    begin
      WithSeleting := ssLeft in Shift;
      if (Cell.Y < Row)
        then DoSelection(WithSeleting and AddSel, Cell.Y-Row,False,not (FDBGridEhState = dgsRectSelecting))
      else if (Cell.Y > Row)
        then DoSelection(WithSeleting and AddSel, Cell.Y-Row,False,not (FDBGridEhState = dgsRectSelecting));
    end;
    if FDataTracking and (X > DataRect.Left) and (X < DataRect.Right) and (Cell.X <> Col) then
    begin
      if Cell.X > Col
        then MoveCol(Cell.X,1,False)
        else MoveCol(Cell.X,-1,False);
      if (FDBGridEhState = dgsRectSelecting) then
        Selection.Rect.Select(RawToDataColumn(Cell.X),DataSource.DataSet.Bookmark,AddSel)
    end;
    FDownMousePos := Point(X, Y);
    FMouseShift := Shift;
    TimerScroll;
  end;
  if FDBGridEhState = dgsColSelecting then
  begin
    Cell := MouseCoord(X, Y);
    if (X > DataRect.Left) and (X < DataRect.Right) and (Cell.X <> -1) then
      if (ssCtrl in Shift) {and (Selection.Columns.IndexOf(Columns[RawToDataColumn(Cell.X)]) = -1)}
        then Selection.Columns.SelectShift(Columns[RawToDataColumn(Cell.X)]{,True})
        else Selection.Columns.SelectShift(Columns[RawToDataColumn(Cell.X)]{,False})
    else
      TimerScroll;
  end
  else if FDBGridEhState = dgsColSizing then //Frozen cols
  begin
    if (dghTraceColSizing in OptionsEh) then
    begin
      FSizingPos := X + FSizingOfs;
      if UseRightToLeftAlignment then
        FSizingPos := ClientWidth - FSizingPos;
      CalcDrawInfo(DrawInfo);
      NewSize := ResizeLine(DrawInfo.Horz);
      if NewSize < 1 then NewSize := 1;
      if not AutoFitColWidths or (csDesigning in ComponentState) or (AutoFitColWidths and
         (FSizingPos < DrawInfo.Horz.GridBoundary - (Columns.Count - FSizingIndex) -
                    DrawInfo.Horz.EffectiveLineWidth * (Columns.Count - FSizingIndex)))
        then ColWidths[FSizingIndex] := NewSize;
      UpdateDesigner;
    end else
    begin
      DrawSizingLine(GridWidth, GridHeight); { XOR it out }
      FSizingPos := X + FSizingOfs;
      DrawSizingLine(GridWidth, GridHeight); { XOR it back in }
    end;
  end
  else if (dghTraceColSizing in OptionsEh) and (FGridState = gsColSizing) then
  begin
    FSizingPos := X + FSizingOfs;
    if UseRightToLeftAlignment then
      FSizingPos := ClientWidth - FSizingPos;
    CalcDrawInfo(DrawInfo);
    NewSize := ResizeLine(DrawInfo.Horz);
    if NewSize < 1 then NewSize := 1;
    if not AutoFitColWidths or (csDesigning in ComponentState) or (AutoFitColWidths and
       (FSizingPos < DrawInfo.Horz.GridBoundary - (Columns.Count - FSizingIndex) -
                  DrawInfo.Horz.EffectiveLineWidth * (Columns.Count - FSizingIndex)))
      then ColWidths[FSizingIndex] := NewSize;
    UpdateDesigner;
    Exit;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TCustomDBGridEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Cell: TGridCoord;
  SaveState: TGridState;
  DoClick: Boolean;
  ACol: Longint;
  ARect: TRect;
  ADBGridEhState: TDBGridEhState;
  I, NewSize: Integer;
begin
  if (FDBGridEhState = dgsColSizing) and not (dghTraceColSizing in OptionsEh) then
  begin
    DrawSizingLine(GridWidth, GridHeight);
    NewSize := 0;
    {for I := 0 to IndicatorOffset-1 do
    begin
      Inc(NewSize, ColWidths[I]);
      Inc(NewSize, GridLineWidth);
    end;}
    for I := 0 to FSizingIndex - 1 do
      Inc(NewSize, ColWidths[I] + GridLineWidth);
    NewSize := FSizingPos - NewSize;
    if NewSize > 1 then
    begin
      ColWidths[FSizingIndex] := NewSize;
      UpdateDesigner;
    end;
  end;
  if FSelectedCellPressed = True then
  begin
    FSelectedCellPressed := False;
    if (ssCtrl in Shift) and (dgRowSelect in Options)
      then FBookmarks.CurrentRowSelected := not FBookmarks.CurrentRowSelected
    else if (dghClearSelection in OptionsEh)
      then ClearSelection;
  end
  else if (dghTraceColSizing in OptionsEh) and (FGridState = gsColSizing) then
  begin
    FGridState := gsNormal;
    Exit;
  end;
  ADBGridEhState := FDBGridEhState;  //in any exception new state ghsNormal
  FDBGridEhState := dgsNormal;
  SaveState := FGridState;
  //FIndicatorPressed := False;
  FSelecting := False;
  if (GetCursor = Screen.Cursors[crVSplit])
    then FDefaultRowChanged := True;  // Released after line resized

  if FTracking and (FPressedCol >= 0) then
  begin
    Cell := MouseCoord(X, Y);
    DoClick := PtInRect(Rect(0, 0, ClientWidth, ClientHeight), Point(X, Y))
      and (Cell.Y = 0) and (Cell.X = FPressedCol);
    if (FUseMultiTitle = True) and DoClick then
    begin
      ARect := CellRect(Cell.X,Cell.Y);
      DoClick := not (PtInRect(Rect(ARect.Left, ARect.Top,
                      ARect.Right, ARect.Bottom - FLeafFieldArr[Cell.X-IndicatorOffset].FLeaf.Height + 1),
                        Point(X, Y)));
    end;
    StopTracking;
    if DoClick then
    begin
      ACol := Cell.X;
      if (dgIndicator in Options) then Dec(ACol);
      if {tmp(DataLink <> nil) and DataLink.Active and} (ACol >= 0) and
        (ACol < Columns.Count) then
      begin
        DoTitleClick(ACol, Columns[ACol]);
        FSortMarking := ssCtrl in Shift;
        if (dghAutoSortMarking in OptionsEh)
          then Columns[ACol].Title.SetNextSortMarkerValue(FSortMarking);
        if not FSortMarking
          then DoSortMarkingChanged;
      end;
    end;
  end
  else if FSwapButtons then
  begin
    FSwapButtons := False;
    MouseCapture := False;
    if Button = mbRight then Button := mbLeft;
  end;

  if FIndicatorPressed or FDataTracking then StopTracking;
  if (ADBGridEhState <> dgsNormal) then StopTimer;

  inherited MouseUp(Button, Shift, X, Y);
  if (SaveState = gsRowSizing) or (SaveState = gsColSizing) or
    ((InplaceEditor <> nil) and (InplaceEditor.Visible) and
     (PtInRect(InplaceEditor.BoundsRect, Point(X,Y))))
    then Exit;
  Cell := MouseCoord(X,Y);
  if (Button = mbLeft) and (Cell.X >= FIndicatorOffset) and (Cell.Y >= 0) then
    if Cell.Y < FTitleOffset
      then TitleClick(Columns[RawToDataColumn(Cell.X)])
    else if Cell.Y <= VisibleDataRowCount
      then CellClick(Columns[SelectedIndex]);

  FDefaultRowChanged := False;
  if (FPressedCell.X = Cell.X) and (FPressedCell.Y = Cell.Y) and
    (Cell.X > IndicatorOffset-1) and
    (Columns[Cell.X - IndicatorOffset].GetColumnType in [ctKeyImageList..ctCheckboxes])
    then if not Columns[Cell.X - IndicatorOffset].DblClickNextVal and
            not (ssDouble in Shift) and Columns[Cell.X - IndicatorOffset].CanModify(True)
    then
      if (ssShift in Shift)
        then Columns[Cell.X - IndicatorOffset].SetNextFieldValue(-1)
        else Columns[Cell.X - IndicatorOffset].SetNextFieldValue(1);
end;

procedure TCustomDBGridEh.MoveCol(RawCol, Direction: Integer; Select:Boolean);
var
  OldCol: Integer;
begin
  if Select and not (dgRowSelect in Options) and CanSelectType(gstRectangle) then
    if Selection.FSelectionType <> gstRectangle then
    begin
      Selection.Rect.Clear;
      Selection.Rect.Select(RawToDataColumn(Col),Datalink.Datasource.Dataset.Bookmark,True);
    end;
  FDatalink.UpdateData;
  if RawCol >= ColCount then
    RawCol := ColCount - 1;
  if RawCol < {//dddFIndicatorOffset} FIndicatorOffset {\\\}
    then RawCol := {//dddFIndicatorOffset} FIndicatorOffset {\\\};
  if Direction <> 0 then
  begin
    while (RawCol < ColCount) and (RawCol >= {//dddFIndicatorOffset} FIndicatorOffset) and
      (ColWidths[RawCol] <= 0) do
      Inc(RawCol, Direction);
    if (RawCol >= ColCount) or (RawCol < {//dddFIndicatorOffset} FIndicatorOffset)
      then Exit;
  end;
  OldCol := Col;
  if RawCol <> OldCol then
  begin
    if not FInColExit then
    begin
      FInColExit := True;
      try
        ColExit;
      finally
        FInColExit := False;
      end;
      if Col <> OldCol then Exit;
    end;
    if not (dgAlwaysShowEditor in Options) then HideEditor;
    {tmp}//Col := RawCol;
    {tmp}if not (dgRowSelect in Options) then Col := RawCol;
    if not (Columns[SelectedIndex].GetColumnType in [ctKeyImageList..ctCheckboxes])
         and (dgAlwaysShowEditor in Options)
      then ShowEditor;
    ColEnter;
  end;
  if Select and not (dgRowSelect in Options) and CanSelectType(gstRectangle)
    then Selection.Rect.Select(RawToDataColumn(Col),Datalink.Datasource.Dataset.Bookmark,True);
  StopInplaceSearch;
end;

procedure TCustomDBGridEh.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
  NeedLayout: Boolean;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent is TPopupMenu) then
    begin
      for I := 0 to Columns.Count-1 do
        if Columns[I].PopupMenu = AComponent
          then Columns[I].PopupMenu := nil;
    end
    else if (FDataLink <> nil) then
      if (AComponent = DataSource)
        then  DataSource := nil
      else if (AComponent is TField) then
      begin
        NeedLayout := False;
        BeginLayout;
        try
          for I := 0 to Columns.Count-1 do
            with Columns[I] do
              if Field = AComponent then
              begin
                Field := nil;
                NeedLayout := True;
              end;
        finally
          if NeedLayout and Assigned(FDatalink.Dataset)
            and not FDatalink.Dataset.ControlsDisabled then
            EndLayout
          else
            DeferLayout;
        end;
      end
    else if (AComponent is TCustomImageList) then
    begin
      if TitleImages = AComponent then TitleImages := nil;
      for I := 0 to Columns.Count-1 do
        if Columns[I].ImageList = AComponent then
          Columns[I].ImageList := nil;
    end;
  end;
end;

procedure TCustomDBGridEh.RecordChanged(Field: TField);
var
  I: Integer;
  CField: TField;
  NeedInvalidateEditor:Boolean;
begin
  if not HandleAllocated then Exit;
  if Field = nil then
    Invalidate
  else
  begin
    for I := 0 to Columns.Count - 1 do
      if Columns[I].Field = Field then
        //InvalidateCol(DataToRawColumn(I));
      begin
      //tmp  InvalidateCol(DataToRawColumn(I));
      //  InvalidateRow(Row);
        GridInvalidateRow(Self,Row);
      end;
  end;
  CField := SelectedField;
  NeedInvalidateEditor := False;
  if ((Field = nil) or (CField = Field)) and
    Assigned(CField) then
    if (DrawMemoText = True) and (CField.DataType = ftMemo)
      then NeedInvalidateEditor := (AdjustLineBreaks(CField.AsString) <> FEditText)
      else NeedInvalidateEditor := (CField.Text <> FEditText);
  if NeedInvalidateEditor then
  begin
    InvalidateEditor;
    if InplaceEditor <> nil then
      InplaceEditor.Deselect;
  end;
end;

procedure TCustomDBGridEh.InvalidateEditor;
begin
  if (InplaceEditor <> nil) and TDBGridInplaceEdit(InplaceEditor).FListVisible then
    with TDBGridInplaceEdit(InplaceEditor) do
    begin
      FLockCloseList := True;
      try
        inherited InvalidateEditor;
      finally
        FLockCloseList := False;
      end;
    end
  else
    inherited InvalidateEditor;
end;

procedure TCustomDBGridEh.Scroll(Distance: Integer);
var
  OldRect, NewRect, ClipRegion: TRect;
  RowHeight: Integer;
  VertSBVis: Boolean;
begin
  if not HandleAllocated then Exit;
  OldRect := BoxRect(0, Row, ColCount - 1, Row);
  if (FDataLink.ActiveRecord >= RowCount - FTitleOffset)
    then UpdateRowCount;
  VertSBVis := VertScrollBar.IsScrollBarVisible;
  UpdateScrollBar;
  if (VertSBVis <> VertScrollBar.IsScrollBarVisible) then
  begin
    if (FAutoFitColWidths = True) {and (UpdateLock = 0)} and not (csDesigning in ComponentState)
      then DeferLayout;
  end;
  //UpdateScrollBar;
  UpdateActive;
  NewRect := BoxRect(0, Row, ColCount - 1, Row);
  ValidateRect(Handle, @OldRect);
  InvalidateRect(Handle, @OldRect, False);
  InvalidateRect(Handle, @NewRect, False);
  if Distance <> 0 then
  begin
    HideEditor;
    try
      if Abs(Distance) > {dddVisibleRowCount}VisibleDataRowCount then
      begin
        Invalidate;
        Exit;
      end else
      begin
        RowHeight := DefaultRowHeight;
        if dgRowLines in Options then Inc(RowHeight, GridLineWidth);
        if dgIndicator in Options then
        begin
          OldRect := BoxRect(0, FSelRow, ColCount - 1, FSelRow);
          InvalidateRect(Handle, @OldRect, False);
        end;
        NewRect := BoxRect(0, FTitleOffset, ColCount - 1, 1000);
        if (FFooterRowCount > 0) then
        begin
          ClipRegion := BoxRect(0, FTitleOffset, ColCount - 1, RowCount-FFooterRowCount-2);
          ScrollWindowEx(Handle, 0, -RowHeight * Distance, @NewRect, @ClipRegion,
            0, nil, SW_Invalidate);
        end else
          ScrollWindowEx(Handle, 0, -RowHeight * Distance, @NewRect, @NewRect,
            0, nil, SW_Invalidate);
        if dgIndicator in Options then
        begin
          NewRect := BoxRect(0, Row, ColCount - 1, Row);
          InvalidateRect(Handle, @NewRect, False);
        end;
      end;
    finally
      if dgAlwaysShowEditor in Options then ShowEditor;
    end;
  end;
  //ddd
  {if Columns.ExistFooterValueType(fvtFieldValue) then }InvalidateFooter;
  //\\\
  if UpdateLock = 0 then Update;
end;

procedure TCustomDBGridEh.SetColumns(Value: TDBGridColumnsEh);
begin
  Columns.Assign(Value);
end;

function ReadOnlyField(Field: TField): Boolean;
var
  MasterFields: TList;
  i:Integer;
begin
  Result := Field.ReadOnly;
  if not Result and (Field.FieldKind = fkLookup) and (Field.KeyFields <> '') then
  begin
    Result := True;
    if Field.DataSet = nil then Exit;
    MasterFields := TList.Create;
    try
      Field.Dataset.GetFieldList(MasterFields,Field.KeyFields);
      //MasterField := Field.Dataset.FindField(Field.KeyFields);
      //if MasterField = nil then Exit;
      for i := 0 to MasterFields.Count-1 do
        Result := Result and TField(MasterFields[i]).ReadOnly;
    finally
      MasterFields.Free;
    end;
  end;
end;

procedure TCustomDBGridEh.SetColumnAttributes;
var
  I: Integer;
begin
  for I := 0 to FColumns.Count-1 do
  with FColumns[I] do
  begin
    TabStops[I + FIndicatorOffset] := {d/}Visible{\} and not ReadOnly and DataLink.Active and
      Assigned(Field) and not (Field.FieldKind = fkCalculated) and not ReadOnlyField(Field);
//    ColWidths[I + FIndicatorOffset] := Width;
    ColWidths[I + FIndicatorOffset] := iif(Visible,Width,iif(dgColLines in Options,-1,0));
  end;
  if (dgIndicator in Options) then
    ColWidths[0] := IndicatorWidth;
end;

procedure TCustomDBGridEh.SetDataSource(Value: TDataSource);
begin
  if Value = FDatalink.Datasource then Exit;
  ClearSelection;
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
  LinkActive(FDataLink.Active);

  if (Assigned(DataSource))
    then SumList.DataSet := DataSource.DataSet
    else SumList.DataSet := nil;
end;

procedure TCustomDBGridEh.SetEditText(ACol, ARow: Longint; const Value: string);
begin
  FEditText := Value;
end;

procedure TCustomDBGridEh.SetOptions(Value: TDBGridOptions);
const
  LayoutOptions = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator,
    dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection];
var
  NewGridOptions: TGridOptions;
  ChangedOptions: TDBGridOptions;
begin
  if FOptions <> Value then
  begin
    NewGridOptions := [];
    if (RowSizingAllowed = True)
      then NewGridOptions := NewGridOptions + [goRowSizing];
    if dgColLines in Value then
    begin
      NewGridOptions := NewGridOptions + [goFixedVertLine, goVertLine];
//      NewGridOptions := NewGridOptions + [goVertLine];
//      if (FUseMultiTitle = False) then
//        NewGridOptions := NewGridOptions + [goFixedVertLine];
    end;
    if dgRowLines in Value
      then NewGridOptions := NewGridOptions + [goFixedHorzLine, goHorzLine];
    if dgColumnResize in Value then
      NewGridOptions := NewGridOptions + [goColSizing, goColMoving];
    if dgTabs in Value
      then Include(NewGridOptions, goTabs);
    if dgRowSelect in Value then
    begin
      Include(NewGridOptions, goRowSelect);
      Exclude(Value, dgAlwaysShowEditor);
      Exclude(Value, dgEditing);
    end;
    if dgEditing in Value then Include(NewGridOptions, goEditing);
    if dgAlwaysShowEditor in Value
      then Include(NewGridOptions, goAlwaysShowEditor);
    inherited Options := NewGridOptions;
    if dgMultiSelect in (FOptions - Value) then ClearSelection;
    ChangedOptions := (FOptions + Value) - (FOptions * Value);
    FOptions := Value;
    if ChangedOptions * LayoutOptions <> [] then LayoutChanged;
  end;
end;

procedure TCustomDBGridEh.SetSelectedField(Value: TField);
var
  I: Integer;
begin
  if Value = nil then Exit;
  for I := 0 to Columns.Count - 1 do
    if Columns[I].Field = Value then
      MoveCol(DataToRawColumn(I),0,False);
end;

procedure TCustomDBGridEh.SetSelectedIndex(Value: Integer);
begin
  MoveCol(DataToRawColumn(Value),0,False);
end;

procedure TCustomDBGridEh.SetTitleFont(Value: TFont);
begin
  FTitleFont.Assign(Value);
  if dgTitles in Options then LayoutChanged;
end;

function TCustomDBGridEh.StoreColumns: Boolean;
begin
  Result := Columns.State = csCustomized;
end;

procedure TCustomDBGridEh.TimedScroll(Direction: TGridScrollDirection);
begin
  if FDatalink.Active then
  begin
    with FDatalink do
    begin
      if sdUp in Direction then
      begin
        DataSet.MoveBy(-ActiveRecord - 1);
        Exclude(Direction, sdUp);
      end;
      if sdDown in Direction then
      begin
        DataSet.MoveBy(RecordCount - ActiveRecord);
        Exclude(Direction, sdDown);
      end;
    end;
    if Direction <> [] then inherited TimedScroll(Direction);
  end;
end;

procedure TCustomDBGridEh.TitleClick(Column: TColumnEh);
begin
  if Assigned(FOnTitleClick) then FOnTitleClick(Column);
end;

procedure TCustomDBGridEh.TitleFontChanged(Sender: TObject);
begin
  if (not FSelfChangingTitleFont) and not (csLoading in ComponentState) then
    ParentFont := False;
  if dgTitles in Options then LayoutChanged;
end;

procedure TCustomDBGridEh.UpdateActive;
var
  NewRow: Integer;
  Field: TField;
begin
  if not FInplaceSearchingInProcess then
    StopInplaceSearch;
  if FDatalink.Active and HandleAllocated and not (csLoading in ComponentState) then
  begin
    NewRow := FDatalink.ActiveRecord + FTitleOffset;
    if Row <> NewRow then
    begin
      if not (dgAlwaysShowEditor in Options) then HideEditor;
      MoveColRow(Col, NewRow, False, False);
      InvalidateEditor;
    end;
    Field := SelectedField;
    if Assigned(Field) and (Field.Text <> FEditText) then
      InvalidateEditor;
  end;
end;

procedure TCustomDBGridEh.UpdateData;
var
  Field: TField;
  KeyIndex: Integer;
  MasterFields: TList;
  RecheckInList:Boolean;
  Column:TColumnEh;
begin
  Field := SelectedField;
  Column := Columns[SelectedIndex];
  if not Assigned(Field) then
    Column.UpdateDataValues(FEditText,FEditText,True)
  else
  begin
    if (Column.GetColumnType = ctPickList) then  //PickList
    begin
      if Assigned(Column.OnNotInList) and
         (StringsLocate(Column.PickList,FEditText,[loCaseInsensitive]) = -1) then
      begin
        RecheckInList := False;
        Column.OnNotinList(Column, FEditText, RecheckInList);
      end;
      //Field.Text := FEditText;
      Column.UpdateDataValues(FEditText,FEditText,True);
    end
    else if (Column.GetColumnType = ctKeyPickList) then  //KeyPickList
    begin
      KeyIndex := Column.PickList.IndexOf(FEditText);
      if (KeyIndex > -1) and (KeyIndex < Column.KeyList.Count) then
        FEditKeyValue := Column.KeyList.Strings[KeyIndex]
      else if (KeyIndex = -1) then
        if Assigned(Column.OnNotInList) and (FEditText <> '') then
        begin
          RecheckInList := False;
          Column.OnNotinList(Column, FEditText, RecheckInList);
          if RecheckInList then
          begin
            KeyIndex := Column.PickList.IndexOf(FEditText);
            if (KeyIndex > -1) and (KeyIndex < Column.KeyList.Count)
              then FEditKeyValue := Column.KeyList.Strings[KeyIndex]
              else FEditKeyValue := Null;
          end else
            FEditKeyValue := Null;
        end else if (FEditText = '')
          then FEditKeyValue := Null;
      Column.UpdateDataValues(FEditText,FEditKeyValue,False);
    end
    else if (Field.FieldKind = fkLookup) and (Field.KeyFields <> '') then //LookUp
    begin
      MasterFields := TList.Create;
      if VarEquals(FEditKeyValue,Null) and (FEditText <> '') and
         Assigned(Column.OnNotInList) and
         not Field.LookupDataSet.Locate(Field.LookupResultField, FEditText, [loCaseInsensitive]) then
      begin
        RecheckInList := False;
        Column.OnNotinList(Column, FEditText, RecheckInList);
        if RecheckInList and Field.LookupDataSet.Locate(Field.LookupResultField, FEditText, [loCaseInsensitive]) then
        begin
          FEditKeyValue := Field.LookupDataSet.FieldValues[Field.LookupKeyFields];
        end;
      end;
      try
        Field.Dataset.GetFieldList(MasterFields,Field.KeyFields);
        //MasterField := Field.DataSet.FieldByName(Field.KeyFields);
        if FieldsCanModify(MasterFields) then
        begin
          Field.DataSet.Edit;
          Column.UpdateDataValues(FEditText,FEditKeyValue,False);
          //DataSetSetFieldValues(Field.DataSet,Field.KeyFields,FEditKeyValue);
          //Field.DataSet.FieldValues[Field.KeyFields] := FEditKeyValue; //MasterField.Value := FEditKeyValue;
        end;
      finally
        MasterFields.Free;
      end;
      if (DrawMemoText = True) and (Field.DataType = ftMemo)
        then Field.AsString := FEditText
        else Field.Text := FEditText;
    end
    else if (DrawMemoText = True) and (Field.DataType = ftMemo) then //Memo
      //  Field.AsString := FEditText
      Column.UpdateDataValues(FEditText,FEditText,True)
    else
      //Field.Text := FEditText;
      Column.UpdateDataValues(FEditText,FEditText,True);
  end;
end;


procedure TCustomDBGridEh.UpdateRowCount;
var BetweenRowHeight,FooterHeight, Delta,t: Integer;
    WinClientRect: TRect;
    AEditorMode: Boolean;
    OldRowCount: Integer;

  procedure SetRowCount(NewRowCount:Longint);
  begin
    if NewRowCount <= Row then
      MoveColRow(Col, NewRowCount-1, False, False);
    RowCount := NewRowCount;
  end;

begin
  OldRowCount := RowCount;
  if RowCount <= FTitleOffset then SetRowCount(FTitleOffset + 1);
  FixedRows := FTitleOffset;
  with FDataLink do
    if not Active or (RecordCount = 0) {or not HandleAllocated} then
    begin
      //if InplaceEditor <> nil then  InplaceEditor.Hide;
      MoveColRow(Col, TitleOffset, False, False);
      SetRowCount(1 + FTitleOffset);
      if (HandleAllocated) then
      begin
        t := RowHeights[0];
        DefaultRowHeight := DefaultRowHeight;
        RowHeights[0] := t;
        if (FFooterRowCount > 0) then
        begin
          BetweenRowHeight := ClientHeight - GridHeight;
          RowCount := RowCount + FooterRowCount + 1;
          FooterHeight := (DefaultRowHeight + iif(dgRowLines in Options,GridLineWidth,0)) * FFooterRowCount;
          RowHeights[iif(dgTitles in Options,2,1)] :=
             iif(FooterHeight + 1 < BetweenRowHeight,BetweenRowHeight - FooterHeight - 1,0);
        end;
      end;
    end else
    begin
      AEditorMode := False;
      if EditorMode then
      begin
        AEditorMode := True;
        //HideEditor;
      end;
      //BeginUpdate;
      try
        RowCount := 1000;
        t := RowHeights[0];
        DefaultRowHeight := DefaultRowHeight;
        RowHeights[0] := t;

        FDataLink.BufferCount := VisibleRowCount;
      finally
        //EndUpdate;
        if AEditorMode then
        begin
          //ShowEditor;
//          InplaceEditor.Move(CellRect(Col, Row));
//          ShowEditor;
{          if Assigned(InplaceEditor) then
            InplaceEditor.Invalidate;}
        end;
      end;

      //RowCount := RecordCount + FTitleOffset;
      SetRowCount(RecordCount + FTitleOffset);
      if dgRowSelect in Options then TopRow := FixedRows;

      Windows.GetClientRect(Handle, WinClientRect);
      if (FFooterRowCount > 0) then
      begin
        FooterHeight := (DefaultRowHeight + iif(dgRowLines in Options,GridLineWidth,0)) * FFooterRowCount;
        BetweenRowHeight := ClientHeight - GridHeight;
        if (FooterHeight < (ClientHeight - GridHeight)) then
        begin
          RowCount := RowCount + FooterRowCount + 1;
          RowHeights[RowCount - FooterRowCount - 1] := BetweenRowHeight - FooterHeight - 1;
        end else
        if ((ClientHeight - GridHeight) <= DefaultRowHeight) then
        begin
          if (BetweenRowHeight = 0) or (BetweenRowHeight = -1) then
          begin
            FDataLink.BufferCount := FDataLink.BufferCount - FFooterRowCount - 1;
            if (FDataLink.BufferCount <= 0) then
            begin
              FDataLink.BufferCount := 1;
              RowCount := 2 + iif(dgTitles in Options,1,0) + FFooterRowCount;
              RowHeights[iif(dgTitles in Options,2,1)] := 0;
            end else
            if (BetweenRowHeight = 0)
              then RowHeights[RowCount - FooterRowCount - 1] := DefaultRowHeight
              else RowHeights[RowCount - FooterRowCount - 1] := DefaultRowHeight-1;
          end else
          begin
            RowCount := RowCount + 1;
            FDataLink.BufferCount := FDataLink.BufferCount - FFooterRowCount;
            if (FDataLink.BufferCount <= 1) then
            begin
              FDataLink.BufferCount := 1;
              RowCount := 2 + iif(dgTitles in Options,1,0) + FFooterRowCount;
              t := ClientHeight - ( iif(dgTitles in Options,RowHeights[0],0) + RowHeights[1] +
                  iif(dgRowLines in Options,GridLineWidth,0)*(2+iif(dgTitles in Options,1,0)) +
                  FooterHeight);
              RowHeights[iif(dgTitles in Options,2,1)] := iif( t > 0,t,0);
            end else
            begin
              if (BetweenRowHeight = DefaultRowHeight)
                then FDataLink.BufferCount := FDataLink.BufferCount - 1;
              RowHeights[RowCount - FooterRowCount - 1] := BetweenRowHeight - 1;
            end;
          end;
        end else
        if (FooterHeight - (ClientHeight - GridHeight) <
            (DefaultRowHeight + iif(dgRowLines in Options,GridLineWidth,0))*RecordCount) then
        begin
          Delta := (FooterHeight - (ClientHeight - GridHeight)) div
            (DefaultRowHeight + iif(dgRowLines in Options,GridLineWidth,0)) + 1;
          BetweenRowHeight := (ClientHeight - GridHeight + 1) mod
            (DefaultRowHeight + iif(dgRowLines in Options,GridLineWidth,0));
          RowCount := RowCount + (FFooterRowCount - Delta) + 1;
          FDataLink.BufferCount := FDataLink.RecordCount - Delta;
          if (FDataLink.BufferCount <= 0) then
          begin
            FDataLink.BufferCount := 1;
            RowCount := 2 + iif(dgTitles in Options,1,0) + FFooterRowCount;
            RowHeights[iif(dgTitles in Options,2,1)] := 0;
          end else
          if (BetweenRowHeight = 1) or (BetweenRowHeight = 0) then
          begin
            RowHeights[RowCount - FooterRowCount - 1] := DefaultRowHeight - (1 - BetweenRowHeight);
          end
          else
            RowHeights[RowCount - FooterRowCount - 1] := BetweenRowHeight - 2;
        end else
        begin
          FDataLink.BufferCount := 1;
          RowCount := 2 + iif(dgTitles in Options,1,0) + FFooterRowCount;
          RowHeights[iif(dgTitles in Options,2,1)] := 0;
        end;
      end;
//ddd      if dgRowSelect in Options then TopRow := FixedRows;
      UpdateActive;
    end;
  if OldRowCount <> RowCount then Invalidate;
end;

procedure TCustomDBGridEh.UpdateScrollBar;
var
  SIOld, SINew: TScrollInfo;
begin
  if FDatalink.Active and HandleAllocated then
    with FDatalink.DataSet do
    begin
      SIOld.cbSize := sizeof(SIOld);
      SIOld.fMask := SIF_ALL;
      GetScrollInfo(Self.Handle, SB_VERT, SIOld);
      SINew := SIOld;
      if {dddIsSequenced}SumList.IsSequenced then
      begin
        SINew.nMin := 1;
        SINew.nPage := {//dddSelf.VisibleRowCount} VisibleDataRowCount ;
        SINew.nMax := Integer(DWORD({dddRecordCount}SumList.RecordCount) + SINew.nPage -1);
        if State in [dsInactive, dsBrowse, dsEdit] then
          SINew.nPos := {dddRecNo}SumList.RecNo;  // else keep old pos
      end
      else
      begin
        SINew.nMin := 0;
        SINew.nPage := 0;
        SINew.nMax := 4;
        if BOF then SINew.nPos := 0
        else if EOF then SINew.nPos := 4
        else SINew.nPos := 2;
      end;
{ddd} if not VertScrollBar.Visible then SINew.nMax := SINew.nMin;
      if (SINew.nMin <> SIOld.nMin) or (SINew.nMax <> SIOld.nMax) or
        (SINew.nPage <> SIOld.nPage) or (SINew.nPos <> SIOld.nPos) then
        SetScrollInfo(Self.Handle, SB_VERT, SINew, True);
    end;
end;

function TCustomDBGridEh.ValidFieldIndex(FieldIndex: Integer): Boolean;
begin
  Result := DataLink.GetMappedIndex(FieldIndex) >= 0;
end;

procedure TCustomDBGridEh.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  if ParentFont then
  begin
    FSelfChangingTitleFont := True;
    try
      TitleFont := Font;
    finally
      FSelfChangingTitleFont := False;
    end;
    FSelfChangingFooterFont := True;
    try
      FooterFont := Font;
    finally
      FSelfChangingFooterFont := False;
    end;
    LayoutChanged;
  end;
end;

procedure TCustomDBGridEh.CMExit(var Message: TMessage);
begin
  try
    if FDatalink.Active then
      with FDatalink.Dataset do
        if (dgCancelOnExit in Options) and (State = dsInsert) and
          not Modified and not FDatalink.FModified then
          Cancel else
          FDataLink.UpdateData;
  except
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TCustomDBGridEh.CMFontChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  BeginLayout;
  try
    for I := 0 to Columns.Count-1 do
      Columns[I].RefreshDefaultFont;
  finally
    EndLayout;
  end;
end;

procedure TCustomDBGridEh.CMDeferLayout(var Message);
begin
  if AcquireLayoutLock
    then EndLayout
    else DeferLayout;
end;

procedure TCustomDBGridEh.CMDesignHitTest(var Msg: TCMDesignHitTest);
begin
  inherited;
  if Msg.Result = 0 then
    Msg.Result := Longint(BOOL(FrozenSizing(Msg.Pos.X, Msg.Pos.Y)));
  if (Msg.Result = 1) and ((FDataLink = nil) or
    ((Columns.State = csDefault) and
     (FDataLink.DefaultFields or (not FDataLink.Active)))) then
    Msg.Result := 0;
end;

procedure TCustomDBGridEh.CMSysColorChange(var Message: TMessage);
begin
  inherited;
  ClearButtonsBitmapCache;
end;

procedure TCustomDBGridEh.WMSetCursor(var Msg: TWMSetCursor);
var Cell: TGridCoord;
    ARect: TRect;
    State: TDBGridEhState;
    Cur: HCURSOR;
    Index: Longint;
    Pos, Ofs: Integer;
begin
  if (csDesigning in ComponentState) and ((FDataLink = nil) or
     ((Columns.State = csDefault) and
      (FDataLink.DefaultFields or (not FDataLink.Active)))) then
  begin
    Windows.SetCursor(LoadCursor(0, IDC_ARROW));
    Exit;
  end;

  Cur := 0;
  if Msg.HitTest = HTCLIENT then
  begin
    if (FGridState = gsNormal) and (FDBGridEhState = dgsNormal) then
      CalcFrozenSizingState(HitTest.X, HitTest.Y, State, Index, Pos, Ofs)
    else State := FDBGridEhState;
    if State = dgsColSizing then
      Cur := Screen.Cursors[crHSplit];
  end;
  if Cur <> 0 then
  begin
    SetCursor(Cur);
    Exit;
  end;

//ddd  else inherited;
  if not (csDesigning in ComponentState) and FDataLink.Active and
      not Sizing(HitTest.X, HitTest.Y) and (dgMultiSelect in Options) then
  begin
    Cell := MouseCoord(HitTest.X, HitTest.Y);
    if (Cell.X >= 0) and (Cell.X < FIndicatorOffset) and (Cell.Y > TitleOffset-1) and
        FDatalink.Active and not ( DataSource.DataSet.Eof and DataSource.DataSet.Bof) and
       (gstRecordBookmarks in AllowedSelections)
      then
        if UseRightToLeftAlignment
          then Windows.SetCursor(hcrLeftCurEh)
          else Windows.SetCursor(hcrRightCurEh)
    else
    if (Cell.Y = TitleOffset-1) and (Cell.X > IndicatorOffset-1) and
     not (dgRowSelect in Options) then
     begin
      ARect := CellRect(Cell.X,Cell.Y);
      if (HitTest.Y <= ARect.Bottom) and (gstColumns in AllowedSelections) and
         (HitTest.Y >= iif((ARect.Bottom-ARect.Top) < ColSelectionAreaHeight,ARect.Top,ARect.Bottom-ColSelectionAreaHeight)) then
        Windows.SetCursor(hcrDownCurEh)
      else inherited;
    end
    else inherited;
  end
  else inherited;
end;

procedure TCustomDBGridEh.WMSize(var Message: TWMSize);
begin
  inherited;

  if UpdateLock = 0 then
    if ((FAutoFitColWidths = True) {or (FooterRowCount > 0)}) and
       not (csDesigning in ComponentState) then
    begin
      LayoutChanged;
      InvalidateEditor;
    end else
    begin
      UpdateRowCount;
      UpdateScrollBar;
    end;

{  if FAutoFitColWidths = True and (UpdateLock = 0) and not (csDesigning in ComponentState) then
    LayoutChanged;
  if UpdateLock = 0 then
  begin
    UpdateRowCount;
    UpdateScrollBar;
  end;}

////  if UpdateLock = 0 then UpdateRowCount;
end;

procedure TCustomDBGridEh.WMVScroll(var Message: TWMVScroll);
var
  SI: TScrollInfo;
begin
  if not AcquireFocus then Exit;
  if FDatalink.Active then
    with Message, FDataLink.DataSet do
      case ScrollCode of
        SB_LINEUP: MoveBy(-FDatalink.ActiveRecord - 1);
        SB_LINEDOWN: MoveBy(FDatalink.RecordCount - FDatalink.ActiveRecord);
        SB_PAGEUP: MoveBy({ddd//-VisibleRowCount} -VisibleDataRowCount {ddd\\});
        SB_PAGEDOWN: MoveBy({ddd//VisibleRowCount} VisibleDataRowCount {ddd\\});
        SB_THUMBTRACK:
           if VertScrollBar.Tracking then
           begin
              SI.cbSize := sizeof(SI);
              SI.fMask := SIF_TRACKPOS;
              GetScrollInfo(Self.Handle, SB_VERT, SI);
              MoveBy(SI.nTrackPos-SumList.RecNo);
              ThumbTracked := True;
              Exit;
           end;
        SB_THUMBPOSITION{,SB_THUMBTRACK}:
          begin
            //ddd
            if ThumbTracked then begin
              ThumbTracked := False;
              Exit;
            end;
            if ScrollCode = SB_THUMBTRACK then
              if not VertScrollBar.Tracking then Exit;
            //\\\
            if {dddIsSequenced}SumList.IsSequenced then
            begin
              SI.cbSize := sizeof(SI);
              SI.fMask := SIF_ALL;
              GetScrollInfo(Self.Handle, SB_VERT, SI);
              if SI.nTrackPos <= 1 then First
              else if SI.nTrackPos >= {dddRecordCount}SumList.RecordCount then Last
              else {dddRecNo}SumList.RecNo := SI.nTrackPos;
            end
            else
              case Pos of
                0: First;
                1: MoveBy({ddd//-VisibleRowCount} -VisibleDataRowCount {ddd\\});
                2: Exit;
                3: MoveBy({ddd//-VisibleRowCount} VisibleDataRowCount {ddd\\});
                4: Last;
              end;
          end;
        SB_BOTTOM: Last;
        SB_TOP: First;
      end;
end;

procedure TCustomDBGridEh.WMHScroll(var Message: TWMHScroll);
begin
  if HorzScrollBar.Tracking and (Message.ScrollCode = SB_THUMBTRACK) then
    Perform(Message.Msg,MakeLong(SB_THUMBPOSITION,Message.Pos),Message.ScrollBar)
  else
    inherited;
  //(Commented to avoid bug of changing text and press on scollbar) InvalidateEditor;
end;

procedure TCustomDBGridEh.SetIme;
var
  Column: TColumnEh;
begin
  if not SysLocale.FarEast then Exit;
  if Columns.Count = 0 then Exit;

  ImeName := FOriginalImeName;
  ImeMode := FOriginalImeMode;
  Column := Columns[SelectedIndex];
  if Column.IsImeNameStored then ImeName := Column.ImeName;
  if Column.IsImeModeStored then ImeMode := Column.ImeMode;

  if InplaceEditor <> nil then
  begin
    TDBGridInplaceEdit(Self).ImeName := ImeName;
    TDBGridInplaceEdit(Self).ImeMode := ImeMode;
  end;
end;

procedure TCustomDBGridEh.UpdateIme;
begin
  if not SysLocale.FarEast then Exit;
  SetIme;
  SetImeName(ImeName);
  SetImeMode(Handle, ImeMode);
end;

procedure TCustomDBGridEh.WMIMEStartComp(var Message: TMessage);
begin
  inherited;
  ShowEditor;
end;

procedure TCustomDBGridEh.WMSetFocus(var Message: TWMSetFocus);
var
  InvalidRect: TRect;
begin
  if not ((InplaceEditor <> nil) and
    (Message.FocusedWnd = InplaceEditor.Handle)) then SetIme;

  if HandleAllocated and (dgRowSelect in Options) then
  begin
    with inherited Selection do
      InvalidRect := BoxRect(Left-FrozenCols, Top, Right, Bottom);
    InvalidateRect(Handle, @InvalidRect, False);
  end;

  inherited;
end;

procedure TCustomDBGridEh.WMKillFocus(var Message: TMessage);
var
  InvalidRect: TRect;
begin
  if HandleAllocated and (dgRowSelect in Options) then
  begin
    with inherited Selection do
      InvalidRect := BoxRect(Left-FrozenCols, Top, Right, Bottom);
    InvalidateRect(Handle, @InvalidRect, False);
  end;

  if not SysLocale.FarEast
    then inherited
  else
  begin
    ImeName := Screen.DefaultIme;
    ImeMode := imDontCare;
    inherited;
    if not ((InplaceEditor <> nil) and (HWND(Message.WParam) = InplaceEditor.Handle))
      then ActivateKeyboardLayout(Screen.DefaultKbLayout, KLF_ACTIVATE);
  end;
end;

function  TCustomDBGridEh.GetFooterRowCount: Integer;
begin
 Result := FFooterRowCount;
end;

procedure TCustomDBGridEh.SetFooterRowCount(Value: Integer);
begin
  if (Value <> FFooterRowCount) and (Value >= 0) then
  begin
    FFooterRowCount := Value;
    LayoutChanged;
  end;
end;

function  TCustomDBGridEh.ReadTitleHeight: Integer;
begin
  Result :=  FTitleHeight;
end;

procedure TCustomDBGridEh.WriteTitleHeight(th: Integer);
begin
 FTitleHeight :=  th;
 LayoutChanged;
end;

function  TCustomDBGridEh.ReadTitleLines: Integer;
begin
  Result :=  FTitleLines;
end;

procedure TCustomDBGridEh.WriteTitleLines(tl: Integer);
begin
  FTitleLines := tl;
  LayoutChanged;
end;


procedure FillDWord(var Dest; Count, Value: Integer); register;
asm
  XCHG  EDX, ECX
  PUSH  EDI
  MOV   EDI, EAX
  MOV   EAX, EDX
  REP   STOSD
  POP   EDI
end;

{ StackAlloc allocates a 'small' block of memory from the stack by
  decrementing SP.  This provides the allocation speed of a local variable,
  but the runtime size flexibility of heap allocated memory.  }
function StackAlloc(Size: Integer): Pointer; register;
asm
  POP   ECX          { return address }
  MOV   EDX, ESP
  ADD   EAX, 3
  AND   EAX, not 3   // round up to keep ESP dword aligned
  CMP   EAX, 4092
  JLE   @@2
@@1:
  SUB   ESP, 4092
  PUSH  EAX          { make sure we touch guard page, to grow stack }
  SUB   EAX, 4096
  JNS   @@1
  ADD   EAX, 4096
@@2:
  SUB   ESP, EAX
  MOV   EAX, ESP     { function result = low memory address of block }
  PUSH  EDX          { save original SP, for cleanup }
  MOV   EDX, ESP
  SUB   EDX, 4
  PUSH  EDX          { save current SP, for sanity check  (sp = [sp]) }
  PUSH  ECX          { return to caller }
end;

{ StackFree pops the memory allocated by StackAlloc off the stack.
- Calling StackFree is optional - SP will be restored when the calling routine
  exits, but it's a good idea to free the stack allocated memory ASAP anyway.
- StackFree must be called in the same stack context as StackAlloc - not in
  a subroutine or finally block.
- Multiple StackFree calls must occur in reverse order of their corresponding
  StackAlloc calls.
- Built-in sanity checks guarantee that an improper call to StackFree will not
  corrupt the stack. Worst case is that the stack block is not released until
  the calling routine exits. }
procedure StackFree(P: Pointer); register;
asm
  POP   ECX                     { return address }
  MOV   EDX, DWORD PTR [ESP]
  SUB   EAX, 8
  CMP   EDX, ESP                { sanity check #1 (SP = [SP]) }
  JNE   @@1
  CMP   EDX, EAX                { sanity check #2 (P = this stack block) }
  JNE   @@1
  MOV   ESP, DWORD PTR [ESP+4]  { restore previous SP  }
@@1:
  PUSH  ECX                     { return to caller }
end;

procedure TCustomDBGridEh.Paint;
var
  LineColor: TColor;
  DrawInfo: TGridDrawInfoEh;
  Sel: TGridRect;
  UpdateRect: TRect;
  AFocRect, FocRect: TRect;
  PointsList: PIntArray;
  StrokeList: PIntArray;
  MaxStroke: Integer;
  FrameFlags1, FrameFlags2: DWORD;
  FixedLineColor: TColor;
  Vert_FooterExtent: Integer;

  procedure DrawLines(DoHorz, DoVert: Boolean; Col, Row: Longint;
    const CellBounds: array of Integer; OnColor, OffColor: TColor;
    DoHorzLastLine: Boolean = True; DoVertLastLine: Boolean = True);

  { Cellbounds is 4 integers: StartX, StartY, StopX, StopY
    Horizontal lines:  MajorIndex = 0
    Vertical lines:    MajorIndex = 1 }

  const
    FlatPenStyle = PS_Geometric or PS_Solid or PS_EndCap_Flat or PS_Join_Miter;

    procedure DrawAxisLines(const AxisInfo: TGridAxisDrawInfoEh;
      Cell, MajorIndex: Integer; UseOnColor: Boolean; DrawLastLine: Boolean = True);
    var
      Line: Integer;
      LogBrush: TLOGBRUSH;
      Index: Integer;
      Points: PIntArray;
      StopMajor, StartMinor, StopMinor: Integer;
    begin
      with Canvas, AxisInfo do
      begin
        if EffectiveLineWidth <> 0 then
        begin
          Pen.Width := GridLineWidth;
          if UseOnColor then
            Pen.Color := OnColor
          else
            Pen.Color := OffColor;
          if Pen.Width > 1 then
          begin
            LogBrush.lbStyle := BS_Solid;
            LogBrush.lbColor := Pen.Color;
            LogBrush.lbHatch := 0;
            Pen.Handle := ExtCreatePen(FlatPenStyle, Pen.Width, LogBrush, 0, nil);
          end;
          Points := PointsList;
          Line := CellBounds[MajorIndex] + EffectiveLineWidth shr 1 +
            GetExtent(Cell);
          //!!! ??? Line needs to be incremented for RightToLeftAlignment ???
          if UseRightToLeftAlignment and (MajorIndex = 0) then Inc(Line);
          StartMinor := CellBounds[MajorIndex xor 1];
          StopMinor := CellBounds[2 + (MajorIndex xor 1)];
          StopMajor := CellBounds[2 + MajorIndex] {ddd+ EffectiveLineWidth};
          Index := 0;
          //{ddd}if (Line >= StopMajor) or (Cell > LastFullVisibleCell) then Exit;
          repeat
            Points^[Index + MajorIndex] := Line;         { MoveTo }
            Points^[Index + (MajorIndex xor 1)] := StartMinor;
            Inc(Index, 2);
            Points^[Index + MajorIndex] := Line;         { LineTo }
            Points^[Index + (MajorIndex xor 1)] := StopMinor;
            Inc(Index, 2);
            Inc(Cell);
            // For hidden columns/rows, set extent to -EffectiveLineWidth
            Inc(Line, GetExtent(Cell) + EffectiveLineWidth);
            if not DrawLastLine and (Line = StopMajor)
              then Break;
          until (Line {ddd>}>{=} StopMajor) or (Cell > LastFullVisibleCell);
           { 2 integers per point, 2 points per line -> Index div 4 }
          PolyPolyLine(Canvas.Handle, Points^, StrokeList^, Index shr 2);
        end;
      end;
    end;

  begin
    if (CellBounds[0] = CellBounds[2]) or (CellBounds[1] = CellBounds[3]) then Exit;
    if not DoHorz then
    begin
      DrawAxisLines(DrawInfo.Vert, Row, 1, DoHorz, DoHorzLastLine);
      DrawAxisLines(DrawInfo.Horz, Col, 0, DoVert, DoVertLastLine);
    end
    else
    begin
      DrawAxisLines(DrawInfo.Horz, Col, 0, DoVert, DoVertLastLine);
      DrawAxisLines(DrawInfo.Vert, Row, 1, DoHorz, DoHorzLastLine);
    end;
  end;

  procedure DrawCells(ACol, ARow: Longint; StartX, StartY, StopX, StopY: Integer;
    Color: TColor; IncludeDrawState: TGridDrawState);
  var
    CurCol, CurRow: Longint;
    AWhere, Where, TempRect: TRect;
    DrawState: TGridDrawState;
    Focused: Boolean;
  begin
    CurRow := ARow;
    Where.Top := StartY;
    while (Where.Top < StopY) and (CurRow < RowCount) do
    begin
      CurCol := ACol;
      Where.Left := StartX;
      Where.Bottom := Where.Top + RowHeights[CurRow];
      while (Where.Left < StopX) and (CurCol < ColCount) do
      begin
        Where.Right := Where.Left + ColWidths[CurCol];
        if (Where.Right > Where.Left) and RectVisible(Canvas.Handle, Where) then
        begin
          DrawState := IncludeDrawState;
          Focused := IsActiveControl;
          if Focused and (CurRow = Row) and (CurCol = Col)  then
            Include(DrawState, gdFocused);
          if PointInGridRect(CurCol, CurRow, Sel) then
            Include(DrawState, gdSelected);
          if not (gdFocused in DrawState) or not (goEditing in inherited Options) or
            not EditorMode or (csDesigning in ComponentState) then
          begin
            if inherited DefaultDrawing or (csDesigning in ComponentState) then
              with Canvas do
              begin
                Font := Self.Font;
                if (gdSelected in DrawState) and
                  (not (gdFocused in DrawState) or
                  ([goDrawFocusSelected, goRowSelect] * inherited Options <> [])) then
                begin
                  Brush.Color := clHighlight;
                  Font.Color := clHighlightText;
                end
                else
                  Brush.Color := Color;
                FillRect(Where);
              end;
            DrawCell(CurCol, CurRow, Where, DrawState);
            if inherited DefaultDrawing and (gdFixed in DrawState) and Ctl3D and
              ((FrameFlags1 or FrameFlags2) <> 0) then
            begin
              TempRect := Where;
              if (FrameFlags1 and BF_RIGHT) = 0 then
                Inc(TempRect.Right, DrawInfo.Horz.EffectiveLineWidth)
              else if (FrameFlags1 and BF_BOTTOM) = 0 then
                Inc(TempRect.Bottom, DrawInfo.Vert.EffectiveLineWidth);
              DrawEdge(Canvas.Handle, TempRect, BDR_RAISEDINNER, FrameFlags1);
              DrawEdge(Canvas.Handle, TempRect, BDR_RAISEDINNER, FrameFlags2);
            end;
            if inherited DefaultDrawing and not (csDesigning in ComponentState) and
              (gdFocused in DrawState) and
              ([goEditing, goAlwaysShowEditor] * inherited Options <>
              [goEditing, goAlwaysShowEditor])
              and not (goRowSelect in inherited Options) then
            begin
              if not UseRightToLeftAlignment then
                DrawFocusRect(Canvas.Handle, Where)
              else
              begin
                AWhere := Where;
                AWhere.Left := Where.Right;
                AWhere.Right := Where.Left;
                DrawFocusRect(Canvas.Handle, AWhere);
              end;
            end;
          end;
        end;
        Where.Left := Where.Right + DrawInfo.Horz.EffectiveLineWidth;
        Inc(CurCol);
      end;
      Where.Top := Where.Bottom + DrawInfo.Vert.EffectiveLineWidth;
      Inc(CurRow);
    end;
  end;
begin
  if FLockPaint then Exit;
  if Flat then
    FixedLineColor := clGray
  else
    FixedLineColor := clBlack;

  if UseRightToLeftAlignment then ChangeGridOrientation(True);

  UpdateRect := Canvas.ClipRect;
  CalcDrawInfoEh(DrawInfo);
  with DrawInfo do
  begin
    if (Horz.EffectiveLineWidth > 0) or (Vert.EffectiveLineWidth > 0) then
    begin
      { Draw the grid line in the four areas (fixed, fixed), (variable, fixed),
        (fixed, variable) and (variable, variable) }
      LineColor := clSilver;
      MaxStroke := Max(Horz.LastFullVisibleCell - LeftCol + FixedCols,
                        Vert.LastFullVisibleCell - TopRow + FixedRows) + 3;
      PointsList := StackAlloc(MaxStroke * sizeof(TPoint) * 2);
      StrokeList := StackAlloc(MaxStroke * sizeof(Integer));
      FillDWord(StrokeList^, MaxStroke, 2);

      if (dghFooter3D in OptionsEh) or (FooterColor = clBtnFace) then
        Vert_FooterExtent := Vert.FooterExtent
      else
        Vert_FooterExtent := 0;

      if ColorToRGB(Color) = clSilver then LineColor := clGray;
      DrawLines(goFixedHorzLine in inherited Options, goFixedVertLine in inherited Options,
        0, 0, [0, 0, Horz.FixedBoundary, Vert.FixedBoundary], FixedLineColor, FixedColor);
      DrawLines(goFixedHorzLine in inherited Options, goFixedVertLine in inherited Options,
        LeftCol, 0, [Horz.FixedBoundary, 0, Horz.GridBoundary,
        Vert.FixedBoundary], FixedLineColor, FixedColor);
      DrawLines(goFixedHorzLine in inherited Options, goFixedVertLine in inherited Options,
        0, TopRow, [0, Vert.FixedBoundary, Horz.FixedBoundary,
        Vert.GridBoundary], FixedLineColor, FixedColor);
      if (FrozenCols > 0) and not (dghFrozen3D in OptionsEh) then
        DrawLines(goFixedHorzLine in inherited Options, goFixedVertLine in inherited Options,
          FixedCols-FrozenCols, TopRow,
          [Horz.FixedBoundary-Horz.FrozenExtent, Vert.FixedBoundary,
          Horz.FixedBoundary-1, Vert.GridBoundary-Vert_FooterExtent], LineColor,
          Color, True,False);
      DrawLines(goHorzLine in inherited Options, goVertLine in inherited Options, LeftCol,
        TopRow, [Horz.FixedBoundary, Vert.FixedBoundary, Horz.GridBoundary,
        Vert.GridBoundary], LineColor, Color);
      if (dghFooter3D in OptionsEh) or (FooterColor = clBtnFace) then
      begin
        DrawLines(goHorzLine in inherited Options, goVertLine in inherited Options, LeftCol,
        RowCount - FooterRowCount,
        [Horz.FixedBoundary, Vert.GridBoundary-Vert.FooterExtent, Horz.GridBoundary, Vert.GridBoundary],
        FixedLineColor, FixedColor);
        if goHorzLine in inherited Options then
          Canvas.Polyline([Point(Horz.FixedBoundary-Horz.FrozenExtent,Vert.GridBoundary-Vert.FooterExtent-1),
                           Point(Horz.GridBoundary,Vert.GridBoundary-Vert.FooterExtent-1)]);
      end;

      StackFree(StrokeList);
      StackFree(PointsList);
    end;

    { Draw the cells in the four areas }
    Sel := inherited Selection;
    FrameFlags1 := 0;
    FrameFlags2 := 0;
    if goFixedVertLine in inherited Options then
    begin
      FrameFlags1 := BF_RIGHT;
      FrameFlags2 := BF_LEFT;
    end;
    if goFixedHorzLine in inherited Options then
    begin
      FrameFlags1 := FrameFlags1 or BF_BOTTOM;
      FrameFlags2 := FrameFlags2 or BF_TOP;
    end;
    DrawCells(0, 0, 0, 0, Horz.FixedBoundary, Vert.FixedBoundary, FixedColor,
      [gdFixed]);
    DrawCells(LeftCol, 0, Horz.FixedBoundary {- FColOffset}, 0, Horz.GridBoundary,  //!! clip
      Vert.FixedBoundary, FixedColor, [gdFixed]);
    DrawCells(0, TopRow, 0, Vert.FixedBoundary, Horz.FixedBoundary,
      Vert.GridBoundary, FixedColor, [gdFixed]);
    DrawCells(LeftCol, TopRow, Horz.FixedBoundary {- FColOffset},                   //!! clip
      Vert.FixedBoundary, Horz.GridBoundary, Vert.GridBoundary, Color, []);

    if not (csDesigning in ComponentState) and
      (goRowSelect in inherited Options) and inherited DefaultDrawing and Focused then
    begin
      //dddGridRectToScreenRect(GetSelection, FocRect, False);
      with inherited Selection do
        FocRect := BoxRect(Left, Top, Right, Bottom);
      //\\\
      if not UseRightToLeftAlignment then
        Canvas.DrawFocusRect(FocRect)
      else
      begin
        AFocRect := FocRect;
        AFocRect.Left := FocRect.Right;
        AFocRect.Right := FocRect.Left;
        DrawFocusRect(Canvas.Handle, AFocRect);
      end;
    end;

    { Fill in area not occupied by cells }
    if Horz.GridBoundary < Horz.GridExtent then
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(Horz.GridBoundary, 0, Horz.GridExtent, Vert.GridBoundary));
    end;
    if Vert.GridBoundary < Vert.GridExtent then
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(0, Vert.GridBoundary, Horz.GridExtent, Vert.GridExtent));
    end;
  end;

  if UseRightToLeftAlignment then ChangeGridOrientation(False);

  //inherited Paint;

  if (dgTitles in Options) and UseMultiTitle then
   FHeadTree.DoForAllNode(ClearPainted);
  if not (csDesigning in ComponentState) and
    (dgRowSelect in Options) and DefaultDrawing and Focused then
  begin
    Canvas.Font.Color := clWindowText;
    Canvas.Brush.Color := clWindow;
    with inherited Selection do
      DrawFocusRect(Canvas.Handle, BoxRect(Left-FrozenCols, Top, Right, Bottom));
  end;
end;

procedure TCustomDBGridEh.ClearPainted(node:THeadTreeNode);
begin
 node.Drawed := false;
end;

procedure TCustomDBGridEh.WriteMarginText(IsMargin:Boolean);
begin
  if(IsMargin <> FMarginText) then
  begin
    FMarginText := IsMargin;
    LayoutChanged;
  end;
end;


procedure TCustomDBGridEh.WriteVTitleMargin(Value: Integer);
begin
  FVTitleMargin := Value;
  LayoutChanged;
end;

procedure TCustomDBGridEh.WritEhTitleMargin(Value: Integer);
begin
  FHTitleMargin := Value;
  LayoutChanged;
end;

procedure TCustomDBGridEh.WriteUseMultiTitle(Value:Boolean);
begin
 if (FUseMultiTitle <> Value)
  then FUseMultiTitle := Value;
 LayoutChanged;
end;

procedure TCustomDBGridEh.SetRowSizingAllowed(Value:Boolean);
begin
  if Value <> FRowSizingAllowed then
  begin
    FRowSizingAllowed := Value;
    if FRowSizingAllowed
      then inherited Options := inherited Options + [goRowSizing]
      else inherited Options := inherited Options - [goRowSizing];
  end;
end;

function TCustomDBGridEh.GetRowHeight:Integer;
begin
  Result := FNewRowHeight;
end;

procedure TCustomDBGridEh.SetRowHeight(Value: Integer);
begin
  if Value <> FNewRowHeight then
  begin
    FNewRowHeight := iif(Value < 0,0,Value);
    LayoutChanged;
  end;
end;

function  TCustomDBGridEh.GetRowLines: Integer;
begin
  Result := FRowLines;
end;

procedure TCustomDBGridEh.SetRowLines(Value: Integer);
begin
  if Value <> FRowLines then
  begin
    FRowLines := iif(Value < 0,0,Value);
    LayoutChanged;
  end;
end;


procedure TCustomDBGridEh.RowHeightsChanged;
var
  I, ThisHasChanged, Def: Integer;
begin
  if (FDefaultRowChanged = True) then
  begin
    FDefaultRowChanged := False;
    ThisHasChanged := -1;
    Def := DefaultRowHeight;
    for I := Ord(dgTitles in Options) to RowCount - iif(FooterRowCount > 0,FooterRowCount + 1,0) do
      if RowHeights[I] <> Def then
      begin
        ThisHasChanged := I;
        Break;
      end;
    if ThisHasChanged <> -1 then
    begin
      FRowLines := 0;
      SetRowHeight(RowHeights[ThisHasChanged]);
      UpdateScrollBar;
    end;
  end;
  inherited;
end;

function TCustomDBGridEh.StdDefaultRowHeight: Integer;
var K:Integer;
begin
  if not HandleAllocated then
    Canvas.Handle := GetDC(0);
  try
    Canvas.Font := Font;
    K := Canvas.TextHeight('Wg') + 3;
    if dgRowLines in Options then
      Inc(K, GridLineWidth);
    Result := K;
  finally
    if not HandleAllocated then
    begin
      ReleaseDC(0,Canvas.Handle);
      Canvas.Handle := 0;
    end;
  end;
end;

procedure TCustomDBGridEh.StopTracking;
begin
  if FTracking then
  begin
    StopTimer;
    FIndicatorPressed := False;
    TrackButton(-1, -1);
    FTracking := False;
    MouseCapture := False;
    FPressedCol := -1;
    FDataTracking := False;
    FDBGridEhState := dgsNormal;
  end;
end;

procedure TCustomDBGridEh.TrackButton(X, Y: Integer);
var
  Cell: TGridCoord;
  NewPressed: Boolean;
  ARect:TRect;
begin
  Cell := MouseCoord(X, Y);
  NewPressed := PtInRect(Rect(0, 0, ClientWidth, ClientHeight), Point(X, Y))
    and (FPressedCol = Cell.X) and (Cell.Y = 0);
  if (FUseMultiTitle = True) and NewPressed then
  begin
    ARect := CellRect(Cell.X,Cell.Y);
    NewPressed := not (PtInRect(Rect(ARect.Left, ARect.Top,
                    ARect.Right, ARect.Bottom - FLeafFieldArr[Cell.X-IndicatorOffset].FLeaf.Height + 1),
                      Point(X, Y)));
  end;
  if FPressed <> NewPressed then
  begin
      FPressed := NewPressed;
      GridInvalidateRow(Self,0);
  end;
end;

procedure TCustomDBGridEh.DoTitleClick(ACol: Longint; AColumn: TColumnEh);
begin
  if Assigned(FOnTitleBtnClick) then FOnTitleBtnClick(Self, ACol, AColumn);
end;

procedure TCustomDBGridEh.CheckTitleButton(ACol: Longint; var Enabled: Boolean);
begin
  if (ACol >= 0) and (ACol < Columns.Count) then
  begin
    if Assigned(FOnCheckButton) then FOnCheckButton(Self, ACol, Columns[ACol], Enabled);
  end
  else Enabled := False;
end;

function TCustomDBGridEh.SetChildTreeHeight(ANode:THeadTreeNode):Integer;
var htLast: THeadTreeNode;
    newh,maxh,th: Integer;
    rec: TRect;
    DefaultRowHeight: Integer;
    s: String;
begin
  DefaultRowHeight := 0;
  Result := 0;
  if(ANode.Child  = nil) then Exit;
  htLast := ANode.Child;
  maxh := 0;
  if(htLast.Child <> nil) then
   maxh := SetChildTreEheight(htLast);
  if htLast.Column <> nil
    then Canvas.Font := htLast.Column.Title.Font
    else Canvas.Font := TitleFont;

  rec := Rect(0,0,htLast.Width-4-htLast.WIndent,DefaultRowHeight);
  if (rec.Left >= rec.Right) then rec.Right := rec.Left + 1;//?????
  s := htLast.Text;
  if s = '' then s := ' ';
  if (htLast.Column <> nil) and (htLast.Column.Title.Orientation = tohVertical) then
    th := iif(htLast.Width>0,
      WriteTextVerticalEh(Canvas, rec, False, 0, 0, s, taLeftJustify, tlBottom, False,True)+6
            ,0)
  else
    th := iif(htLast.Width>0,
           DrawText(Canvas.Handle,PChar(s),
           Length(s), rec, DT_WORDBREAK or DT_CALCRECT), 0) + FVTitleMargin;

  if (th > DefaultRowHeight) then maxh := maxh + th
     else maxh := maxh + DefaultRowHeight;

  while True do
  begin
    if(ANode.Child = htLast.Next) then begin break; end;
    htLast := htLast.Next;
    newh := 0;
    if(htLast.Child <> nil) then
      newh := SetChildTreEheight(htLast);
    rec := Rect(0,0,htLast.Width-4-htLast.WIndent,DefaultRowHeight);
    if (rec.Left >= rec.Right)
      then rec.Right := rec.Left + 1;//?????
    s := htLast.Text;
    if s = '' then s := ' ';
    if htLast.Column <> nil then
      Canvas.Font := htLast.Column.Title.Font;
    if (htLast.Column <> nil) and (htLast.Column.Title.Orientation = tohVertical) then
      th := iif(htLast.Width>0,
        WriteTextVerticalEh(Canvas, rec, False, 0, 0, s, taLeftJustify, tlBottom, False,True)+6
                ,0)
    else
      th := iif(htLast.Width>0,
               DrawText(Canvas.Handle,PChar(s),
               Length(s), rec, DT_WORDBREAK or DT_CALCRECT), 0) + FVTitleMargin;
    if (th > DefaultRowHeight)
      then newh := newh + th
      else newh := newh + DefaultRowHeight;
    if(maxh < newh)
      then maxh := newh;
  end;

  htLast := ANode.Child;
  while ANode.Child <> htLast.Next do
  begin
    if(htLast.Child = nil)
      then htLast.Height := maxh
      else htLast.Height := maxh - htLast.Height;
    htLast := htLast.Next;
  end;
  if(htLast.Child = nil)
    then htLast.Height := maxh
    else htLast.Height := maxh - htLast.Height;

  ANode.Height := maxh; //save ChildTree height in Host
  Result := maxh;
end;


function TCustomDBGridEh.GetColWidths(Index: Longint): Integer;
begin
 Result := inherited ColWidths[Index];
end;

procedure TCustomDBGridEh.SetColWidths(Index: Longint; Value: Integer);
begin
  inherited ColWidths[Index] := Value;
  LayoutChanged;
end;


procedure TCustomDBGridEh.WriteAutoFitColWidths(Value:Boolean);
var i:Integer;
begin
  if (FAutoFitColWidths = Value) then Exit;
  FAutoFitColWidths := Value;
  if (csDesigning in ComponentState) then Exit;
  if (FAutoFitColWidths = True) then
  begin
    if not (csLoading in ComponentState) then
      for i := 0  to Columns.Count - 1 do Columns[i].FInitWidth := Columns[i].Width;
    ScrollBars := ssNone;
  end else
  begin
    for i := 0  to Columns.Count - 1 do Columns[i].Width := Columns[i].FInitWidth;
    ScrollBars := ssHorizontal;
  end;
  LayoutChanged;
end;

procedure TCustomDBGridEh.WriteMinAutoFitWidth(Value:Integer);
begin
  FMinAutoFitWidth := Value;
  LayoutChanged;
end;

procedure TCustomDBGridEh.SaveColumnsLayoutProducer(ARegIni: TObject; Section:
  String; DeleteSection: Boolean);
var
  I:Integer;
  S:String;
begin
  if (ARegIni is TRegIniFile) then
    TRegIniFile(ARegIni).EraseSection(Section)
  else if DeleteSection then
    TCustomIniFile(ARegIni).EraseSection(Section);

  with Columns do
  begin
    for I := 0 to Count - 1 do
    begin
      if ARegIni is TRegIniFile then
        TRegIniFile(ARegIni).WriteString(Section, Format('%s.%s', [Name, Items[I].FieldName]),
         Format('%d,%d,%d,%d,%d,%d,%d', [Items[I].Index, Items[I].Width, Integer(Items[I].Title.SortMarker),
           Integer(Items[I].Visible),Items[I].Title.SortIndex,Items[I].DropDownRows,Items[I].DropDownWidth]))
      else
      begin
        S := Format('%d,%d,%d,%d,%d,%d,%d', [Items[I].Index, Items[I].Width, Integer(Items[I].Title.SortMarker),
           Integer(Items[I].Visible),Items[I].Title.SortIndex,Items[I].DropDownRows,Items[I].DropDownWidth]);
        if S <> '' then
        begin
          if ((S[1] = '"') and (S[Length(S)] = '"')) or
            ((S[1] = '''') and (S[Length(S)] = '''')) then
            S := '"' + S + '"';
        end;
      end;
      if ARegIni is TCustomIniFile
        then TCustomIniFile(ARegIni).WriteString(Section, Format('%s.%s', [Name, Items[I].FieldName]), S);
    end;
  end;
end;

procedure TCustomDBGridEh.RestoreColumnsLayoutProducer(ARegIni: TObject;
  Section: String; RestoreParams:TColumnEhRestoreParams);
type
  TColumnInfo = record
    Column: TColumnEh;
    EndIndex: Integer;
    SortMarker:TSortMarkerEh;
    SortIndex: Integer;
  end;
  PColumnArray = ^TColumnArray;
  TColumnArray = array[0..0] of TColumnInfo;
const
  Delims = [' ',','];
var
  I, J: Integer;
  S: string;
  ColumnArray: PColumnArray;
  AAutoFitColWidth: Boolean;
begin
  AAutoFitColWidth := False;
  BeginUpdate;
  try
    if (AutoFitColWidths) then
    begin
      AutoFitColWidths := False;
      AAutoFitColWidth := True;
    end;
    with Columns do
    begin
      ColumnArray := AllocMem(Count * SizeOf(TColumnInfo));
      try
        for I := 0 to Count - 1 do
        begin
          if (ARegIni is TRegIniFile)
            then S := TRegIniFile(ARegIni).ReadString(Section, Format('%s.%s', [Name, Items[I].FieldName]), '')
            else S := TCustomIniFile(ARegIni).ReadString(Section, Format('%s.%s', [Name, Items[I].FieldName]), '');
          ColumnArray^[I].Column := Items[I];
          ColumnArray^[I].EndIndex := Items[I].Index;
          if S <> '' then
          begin
            ColumnArray^[I].EndIndex := StrToIntDef(ExtractWord(1, S, Delims),
              ColumnArray^[I].EndIndex);
            if (crpColWidthsEh in RestoreParams) then
              Items[I].Width := StrToIntDef(ExtractWord(2, S, Delims),
                Items[I].Width);
            if (crpSortMarkerEh in RestoreParams) then
              Items[I].Title.SortMarker := TSortMarkerEh(StrToIntDef(ExtractWord(3, S, Delims),
                Integer(Items[I].Title.SortMarker)));
            if (crpColVisibleEh in RestoreParams) then
              Items[I].Visible := Boolean(StrToIntDef(ExtractWord(4, S, Delims),Integer(Items[I].Visible)));
            if (crpSortMarkerEh in RestoreParams) then
              ColumnArray^[I].SortIndex := StrToIntDef(ExtractWord(5, S, Delims),0);
            if (crpDropDownRowsEh in RestoreParams) then
              Items[I].DropDownRows := StrToIntDef(ExtractWord(6, S, Delims),Items[I].DropDownRows);
            if (crpDropDownWidthEh in RestoreParams) then
              Items[I].DropDownWidth := StrToIntDef(ExtractWord(7, S, Delims),Items[I].DropDownWidth);
          end;
        end;
        if (crpSortMarkerEh in RestoreParams) then
          for I := 0 to Count - 1 do
            Items[I].Title.SortIndex := ColumnArray^[I].SortIndex;
        if (crpColIndexEh in RestoreParams) then
          for I := 0 to Count - 1 do
            for J := 0 to Count - 1 do
              if ColumnArray^[J].EndIndex = I then
              begin
                ColumnArray^[J].Column.Index := ColumnArray^[J].EndIndex;
                Break;
              end;

      finally
        FreeMem(Pointer(ColumnArray));
      end;
    end;
  finally
    EndUpdate;
    if (AAutoFitColWidth = True)
      then AutoFitColWidths := True
      else LayoutChanged;
  end;
end;

procedure TCustomDBGridEh.SaveColumnsLayoutIni(IniFileName: String;
  Section: String; DeleteSection: Boolean);
var IniFile:TIniFile;
begin
  IniFile := TIniFile.Create(IniFileName);
  try
    SaveColumnsLayoutProducer(IniFile,Section,DeleteSection);
  finally
   IniFile.Free;
  end;
end;

procedure TCustomDBGridEh.RestoreColumnsLayoutIni(IniFileName: String;
  Section: String; RestoreParams:TColumnEhRestoreParams);
var IniFile:TIniFile;
begin
  IniFile := TIniFile.Create(IniFileName);
  try
    RestoreColumnsLayoutProducer(IniFile,Section,RestoreParams);
  finally
   IniFile.Free;
  end;
end;

procedure TCustomDBGridEh.SaveColumnsLayout(ARegIni: TRegIniFile);
var
  Section: String;
begin
  Section := GetDefaultSection(Self);
  SaveColumnsLayoutProducer(ARegIni,Section,True);
end;

procedure TCustomDBGridEh.SaveColumnsLayout(ACustIni: TCustomIniFile; Section:String);
begin
  SaveColumnsLayoutProducer(ACustIni,Section,False);
end;

procedure TCustomDBGridEh.RestoreColumnsLayout(ARegIni: TRegIniFile; RestoreParams:TColumnEhRestoreParams);
var
  Section: String;
begin
  Section := GetDefaultSection(Self);
  RestoreColumnsLayoutProducer(ARegIni,Section,RestoreParams);
end;

procedure TCustomDBGridEh.RestoreColumnsLayout(ACustIni: TCustomIniFile;
                          Section:String; RestoreParams:TColumnEhRestoreParams);
begin
  RestoreColumnsLayoutProducer(ACustIni,Section,RestoreParams);
end;

procedure TCustomDBGridEh.SaveGridLayoutProducer(ARegIni: TObject;
  Section: String; DeleteSection: Boolean);
begin
  SaveColumnsLayoutProducer(ARegIni,Section,DeleteSection);
  if ARegIni is TRegIniFile then
    TRegIniFile(ARegIni).WriteString(Section, '', Format('%d,%d', [RowHeight,RowLines]))
  else if ARegIni is TCustomIniFile then
    TCustomIniFile(ARegIni).WriteString(Section, '(Default)', Format('%d,%d', [RowHeight,RowLines]));
end;

procedure TCustomDBGridEh.RestoreGridLayoutProducer(ARegIni: TObject; Section: String; RestoreParams:TDBGridEhRestoreParams);
const
  Delims = [' ',','];
var ColRestParams:TColumnEhRestoreParams;
    S:String;
begin
  ColRestParams := [];
  if grpColIndexEh in RestoreParams then Include(ColRestParams,crpColIndexEh);
  if grpColWidthsEh in RestoreParams then Include(ColRestParams,crpColWidthsEh);
  if grpSortMarkerEh in RestoreParams then Include(ColRestParams,crpSortMarkerEh);
  if grpColVisibleEh in RestoreParams then Include(ColRestParams,crpColVisibleEh);
  if grpDropDownRowsEh in RestoreParams then Include(ColRestParams,crpDropDownRowsEh);
  if grpDropDownWidthEh in RestoreParams then Include(ColRestParams,crpDropDownWidthEh);

  RestoreColumnsLayoutProducer(ARegIni,Section,ColRestParams);

  if (ARegIni is TRegIniFile)
    then S := TRegIniFile(ARegIni).ReadString(Section, '', '')
    else S := TCustomIniFile(ARegIni).ReadString(Section, '(Default)', '');

  if (grpRowHeightEh in RestoreParams) then
  begin
    RowHeight := StrToIntDef(ExtractWord(1, S, Delims),0);
    RowLines := StrToIntDef(ExtractWord(2, S, Delims),0);
  end;
end;

procedure TCustomDBGridEh.SaveGridLayout(ARegIni: TRegIniFile);
var
  Section: String;
begin
  Section := GetDefaultSection(Self);
  SaveGridLayoutProducer(ARegIni,Section,True);
end;

procedure TCustomDBGridEh.SaveGridLayout(ACustIni: TCustomIniFile; Section:String);
begin
  SaveGridLayoutProducer(ACustIni,Section,False);
end;

procedure TCustomDBGridEh.RestoreGridLayout(ARegIni: TRegIniFile;
  RestoreParams:TDBGridEhRestoreParams);
var
  Section: String;
begin
  Section := GetDefaultSection(Self);
  RestoreGridLayoutProducer(ARegIni,Section,RestoreParams);
end;

procedure TCustomDBGridEh.RestoreGridLayout(ARegIni: TCustomIniFile;
  Section:String; RestoreParams:TDBGridEhRestoreParams);
begin
  RestoreGridLayoutProducer(ARegIni,Section,RestoreParams);
end;

procedure TCustomDBGridEh.SaveGridLayoutIni(IniFileName: String;
  Section: String; DeleteSection: Boolean);
var IniFile:TIniFile;
begin
  IniFile := TIniFile.Create(IniFileName);
  try
    SaveGridLayoutProducer(IniFile,Section,DeleteSection);
  finally
   IniFile.Free;
  end;
end;

procedure TCustomDBGridEh.RestoreGridLayoutIni(IniFileName: String;
  Section: String; RestoreParams:TDBGridEhRestoreParams);
var IniFile:TIniFile;
begin
  IniFile := TIniFile.Create(IniFileName);
  try
    RestoreGridLayoutProducer(IniFile,Section,RestoreParams);
  finally
   IniFile.Free;
  end;
end;


procedure TCustomDBGridEh.SetFrozenCols(Value: Integer);
begin
  if (Value = FFrozenCols) and (Value < 0) then Exit;
  FFrozenCols := Value;
  LayoutChanged;
end;

procedure TCustomDBGridEh.SetFooterFont(Value: TFont);
begin
  FFooterFont.Assign(Value);
  if FooterRowCount > 0 then LayoutChanged;
end;

procedure TCustomDBGridEh.FooterFontChanged(Sender: TObject);
begin
  if (not FSelfChangingFooterFont) and not (csLoading in ComponentState) then
    ParentFont := False;
  if FooterRowCount > 0 then LayoutChanged;
end;

procedure TCustomDBGridEh.SetFooterColor(Value: TColor);
begin
  if not (csLoading in ComponentState) then
    ParentColor := False;
  FFooterColor := Value;
  if FooterRowCount > 0 then Invalidate;
end;

procedure TCustomDBGridEh.CMParentColorChanged(var Message: TMessage);
begin
  inherited;
  if ParentColor then
  begin
    FFooterColor := Color;
    Invalidate;
  end;
end;

function TCustomDBGridEh.IsActiveControl: Boolean;
var
  H: Hwnd;
  ParentForm: TCustomForm;
begin
  Result := False;
  ParentForm := GetParentForm(Self);
  if Assigned(ParentForm) then
  begin
    if (ParentForm.ActiveControl = Self) then
      Result := True
  end
  else
  begin
    H := GetFocus;
    while IsWindow(H) and (Result = False) do
    begin
      if H = WindowHandle
        then Result := True
        else H := GetParent(H);
    end;
  end;
end;

procedure TCustomDBGridEh.ChangeGridOrientation(RightToLeftOrientation: Boolean);
var
  Org: TPoint;
  Ext: TPoint;
begin
  if RightToLeftOrientation then
  begin
    Org := Point(ClientWidth,0);
    Ext := Point(-1,1);
    SetMapMode(Canvas.Handle, mm_Anisotropic);
    SetWindowOrgEx(Canvas.Handle, Org.X, Org.Y, nil);
    SetViewportExtEx(Canvas.Handle, ClientWidth, ClientHeight, nil);
    SetWindowExtEx(Canvas.Handle, Ext.X*ClientWidth, Ext.Y*ClientHeight, nil);
  end else
  begin
    Org := Point(0,0);
    Ext := Point(1,1);
    SetMapMode(Canvas.Handle, mm_Anisotropic);
    SetWindowOrgEx(Canvas.Handle, Org.X, Org.Y, nil);
    SetViewportExtEx(Canvas.Handle, ClientWidth, ClientHeight, nil);
    SetWindowExtEx(Canvas.Handle, Ext.X*ClientWidth, Ext.Y*ClientHeight, nil);
  end;
end;

procedure TCustomDBGridEh.CalcDrawInfoEh(var DrawInfo: TGridDrawInfoEh);
begin
  CalcDrawInfoXYEh(DrawInfo, ClientWidth, ClientHeight);
end;

procedure TCustomDBGridEh.CalcFixedInfoEh(var DrawInfo: TGridDrawInfoEh);

  procedure CalcFixedAxisEh(var Axis: TGridAxisDrawInfoEh; LineOptions: TGridOptions;
    FixedCount, FrozenCount, FirstCell, CellCount: Integer; GetExtentFunc: TGetExtentsFunc);
  var
    I: Integer;
  begin
    with Axis do
    begin
      if LineOptions * inherited Options = []
        then EffectiveLineWidth := 0
        else EffectiveLineWidth := GridLineWidth;

      FixedBoundary := 0;
      for I := 0 to FixedCount - 1 - FrozenCount do
        Inc(FixedBoundary, GetExtentFunc(I) + EffectiveLineWidth);

      FrozenExtent := FixedBoundary;

      for I := FixedCount - FrozenCount to FixedCount - 1 do
        Inc(FixedBoundary, GetExtentFunc(I) + EffectiveLineWidth);

      FrozenExtent := FixedBoundary - FrozenExtent;
      FixedCellCount := FixedCount;
      FirstGridCell := FirstCell;
      GridCellCount := CellCount;
      GetExtent := GetExtentFunc;
    end;
  end;

begin
  CalcFixedAxisEh(DrawInfo.Horz, [goFixedVertLine, goVertLine], FixedCols, FrozenCols,
    LeftCol, ColCount, GetColWidths);
  CalcFixedAxisEh(DrawInfo.Vert, [goFixedHorzLine, goHorzLine], FixedRows, 0,
    TopRow, RowCount, GetRowHeights);
end;

procedure TCustomDBGridEh.CalcDrawInfoXYEh(var DrawInfo: TGridDrawInfoEh; UseWidth, UseHeight: Integer);

  procedure CalcAxisEh(var AxisInfo: TGridAxisDrawInfoEh; UseExtent, FooterCount: Integer);
  var
    I: Integer;
    ToFooterBoundary: Integer;
  begin
    with AxisInfo do
    begin
      GridExtent := UseExtent;
      GridBoundary := FixedBoundary;
      FullVisBoundary := FixedBoundary;
      LastFullVisibleCell := FirstGridCell;
      FooterExtent := 0;
      ToFooterBoundary := 0;
      for I := FirstGridCell to GridCellCount - 1 do
      begin
        if (I >= GridCellCount - FooterCount) and (ToFooterBoundary = 0) then
          ToFooterBoundary := GridBoundary;
        Inc(GridBoundary, GetExtent(I) + EffectiveLineWidth);
        if GridBoundary > GridExtent + EffectiveLineWidth then
        begin
          GridBoundary := GridExtent;
          Break;
        end;
        LastFullVisibleCell := I;
        FullVisBoundary := GridBoundary;
      end;
      for I := GridCellCount - FooterCount to LastFullVisibleCell do
        Inc(FooterExtent, GetExtent(I) + EffectiveLineWidth);
      if ToFooterBoundary > 0 then
        Inc(FooterExtent,GridBoundary - FooterExtent - ToFooterBoundary);
    end;
  end;

begin
  CalcFixedInfoEh(DrawInfo);
  CalcAxisEh(DrawInfo.Horz, UseWidth, 0);
  CalcAxisEh(DrawInfo.Vert, UseHeight, FooterRowCount);
end;

function TCustomDBGridEh.GetRowHeights(Index: Longint): Integer;
begin
  Result := RowHeights[Index];
end;

procedure TCustomDBGridEh.WriteCellText(ACanvas: TCanvas; ARect: TRect;
  FillRect: Boolean; DX, DY: Integer; Text: string; Alignment: TAlignment;
  Layout: TTextLayout; MultyL, EndEllipsis: Boolean; LeftMarg,
  RightMarg: Integer);
begin
  if UseRightToLeftAlignment then
  begin
    LPtoDP(Canvas.Handle,ARect,2);
    Swap(ARect.Left,ARect.Right);
    ChangeGridOrientation(False);
    if Alignment = taLeftJustify then
      Alignment := taRightJustify
    else if Alignment = taRightJustify then
      Alignment := taLeftJustify;
    Swap(LeftMarg,RightMarg);
  end;
  WriteTextEh(Canvas, ARect, FillRect, DX, DY, Text, Alignment, Layout,
    MultyL, EndEllipsis, LeftMarg, RightMarg);
  if UseRightToLeftAlignment then
    ChangeGridOrientation(True);
end;

procedure TCustomDBGridEh.PaintButtonControl(DC: HDC; ARect: TRect;
  ParentColor: TColor; Style: TDrawButtonControlStyleEh;
  DownButton: Integer; Flat, Active, Enabled: Boolean;
  State: TCheckBoxState);
begin
  if UseRightToLeftAlignment then
  begin
    LPtoDP(Canvas.Handle,ARect,2);
    Swap(ARect.Left,ARect.Right);
    ChangeGridOrientation(False);
  end;
  PaintButtonControlEh(DC, ARect, ParentColor, Style, DownButton, Flat, Active, Enabled, State);
  if UseRightToLeftAlignment then
    ChangeGridOrientation(True);
end;

{ THeadTreeNode }

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet;
  var Pos: Integer): string; forward;

constructor THeadTreeNode.Create;
begin
   Child := Nil; Next := Self; Host := nil; WIndent := 0;
end;

constructor THeadTreeNode.CreateText(AText:String;AHeight,AWidth:Integer);
begin
  Create;
  Text := AText; Height := AHeight; Width := AWidth;
end;

destructor THeadTreeNode.Destroy;
begin
 inherited;
 if (Host = nil) then
 begin
   FreeAllChild;
 end;
end;

function THeadTreeNode.Add(AAfter:THeadTreeNode;AText:String;AHeight,AWidth:Integer):THeadTreeNode ;
var htLast,{htSelf,}th:THeadTreeNode;
begin
  if(Find(AAfter) = false)
    then raise Exception.Create('Node not in Tree');
  htLast := AAfter.Next;
//    while AAfter <> htLast.Next do htLast := htLast.Next; // find Last
  th := THeadTreeNode.CreateText(AText,AHeight,AWidth);
  th.Host := AAfter.Host;
  AAfter.Next := th;
  th.Next := htLast;
  Result := th;
end;

function THeadTreeNode.AddChild(ANode:THeadTreeNode;AText:String;AHeight,AWidth:Integer):THeadTreeNode ;
var htLast,th:THeadTreeNode;
begin
  if(Find(ANode) = false) then raise Exception.Create('Node not in Tree');

  if(ANode.Child = nil) then
  begin
   th := THeadTreeNode.CreateText(AText,AHeight,AWidth);
   th.Host := ANode;
   ANode.Child := th;
  end else
  begin
    htLast := ANode.Child;
    while ANode.Child <> htLast.Next
     do htLast := htLast.Next;
    th := THeadTreeNode.CreateText(AText,AHeight,AWidth);
    th.Host := ANode;
    htLast.Next := th;
    th.Next := ANode.Child;
  end;
  Result := th;
end;

procedure THeadTreeNode.FreeAllChild;
var htLast,htm:THeadTreeNode;
begin
  if(Child  = nil) then Exit;
  htLast := Child;

  while  true  do
  begin
    htLast.FreeAllChild;
    if(Child = htLast.Next)
      then begin htLast.Free; break; end;
    htm := htLast;
    htLast := htLast.Next;
    htm.Free;
  end;
  Child := nil;
end;



function THeadTreeNode.Find(ANode:THeadTreeNode):Boolean;
var htLast:THeadTreeNode;
begin
  Result := false;
//  if(Child  = nil) then Exit;
  htLast := Self;
  while True do
  begin
    if(htLast = ANode)
      then begin Result := true; break; end;
    if(htLast.Child <> nil) and (htLast.Child.Find(ANode) = true)
      then begin Result := true; break; end;
    if(Self = htLast.Next)
      then begin Result := false; break; end;
    htLast := htLast.Next;
  end;
end;


procedure THeadTreeNode.Union(AFrom,ATo :THeadTreeNode; AText:String;AHeight:Integer);
var th, tUn, TBeforFrom: THeadTreeNode;
    toFinded :Boolean;
    wid: Integer;
begin
  if(Find(AFrom) = false)
    then raise Exception.Create('Node not in Tree');
  toFinded := True;
  if (AFrom <> ATo)  then  //new
  begin
    th := AFrom; toFinded := false;
    while AFrom.HOst.Child <> th.Next do
    begin
      if(th.Next = ATo)
        then begin toFinded := true; break; end;
      th := th.Next;
    end;
  end;

  if(toFinded = false)
    then raise Exception.Create('ATo not in level');

  tUn := ATo.Add(ATo,AText,AHeight,0);
  tUn.VLineWidth := ATo.VLineWidth;
  TBeforFrom := AFrom.Host.Child;
  while TBeforFrom.Next <> AFrom
    do TBeforFrom := TBeforFrom.Next;

  TBeforFrom.Next := tUn;

  th := AFrom; tUn.Child := AFrom;
  if(th = AFrom.Host.Child)
    then AFrom.Host.Child := tUn;
  Wid := 0;
  while th <> ATo.Next do
  begin
    Inc(Wid,th.Width);
    Inc(Wid,tUn.VLineWidth);
    Dec(th.Height,AHeight);
    th.Host := TUn;
    th := th.Next;
  end;
  if (tUn.VLineWidth > 0) then Dec(Wid,tUn.VLineWidth);
  ATo.Next := AFrom;
  tUn.Width := Wid;
end;

procedure THeadTreeNode.CreateFieldTree(AGrid:TCustomDBGridEh);
var i,apos,j: Integer;
    node,nodeFrom,nodeTo: THeadTreeNode;
    ss,ss1: String;
    sameWord,GroupDid: Boolean;
begin
  FreeAllChild;

  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    node := AddChild(Self,AGrid.Columns[i].Title.Caption,
                 AGrid.RowHeights[0],
                 iif(AGrid.Columns[i].Visible,AGrid.Columns[i].Width,iif(dgColLines in AGrid.Options,-1,0)));
    node.Column := AGrid.Columns[i];
    if (AGrid.Columns[i].Title.SortMarker <> smNoneEh) then node.WIndent := 16;
    if (dgColLines in AGrid.Options)
      then node.VLineWidth := 1
      else node.VLineWidth := 0;
    AGrid.FLeafFieldArr[i].FLeaf := node;
  end;

  nodeTo := nil;
  // Group
  while True do  //for k := 0 to ListNodeField.Count - 1 do begin
  begin
    GroupDid := false;
    for i := 0 to AGrid.Columns.Count - 1 do
    begin
     ss1 := ExtractWordPos(2,AGrid.FLeafFieldArr[i].FLeaf.Text,['|'],apos);
     //napos := Pos('|',AGrid.FLeafFieldArr[i].FLeaf.Text);
     if {napos <> 0} ss1 <> ''  then
     begin
       //nInc(apos);
       ss1 := ExtractWord(1,AGrid.FLeafFieldArr[i].FLeaf.Text,['|']);
       nodeFrom := AGrid.FLeafFieldArr[i].FLeaf;
                           //      sameWord := false;
       sameWord := True;
       for j := i to AGrid.Columns.Count - 1 do
       begin
         if (AGrid.Columns.Count - 1 > j) and
            (ExtractWord(1,AGrid.FLeafFieldArr[j+1].FLeaf.Text,['|']) = ss1) then
         begin
           ss :=  AGrid.FLeafFieldArr[j].FLeaf.Text;
           Delete(ss,1,apos-1);
           AGrid.FLeafFieldArr[j].FLeaf.Text := ss;
           sameWord := true;
           GroupDid := true;
         end else
         begin
           if(sameWord = true) then
           begin
             ss := AGrid.FLeafFieldArr[j].FLeaf.Text;
             Delete(ss,1,apos-1);
 //            TLeafField(ListNodeField.Items[j]).Field.DisplayLabel := ss;
             AGrid.FLeafFieldArr[j].FLeaf.Text := ss;
             nodeTo := AGrid.FLeafFieldArr[j].FLeaf;
             GroupDid := true;
           end;
           Break;
         end;
       end;
       if(sameWord = true) then
       begin
         Union(nodeFrom,nodeTo,ss1,20);
         Break;
       end;
     end; //if
    end; //i
    if(GroupDid = false) then break;
  end; //k
end;

procedure THeadTreeNode.DoForAllNode(proc:THeadTreeProc);
var htLast:THeadTreeNode;
begin
  if(Child  = nil) then Exit;
  htLast := Child;
  while True do
  begin
    proc(htLast);
    if(htLast.Child <> nil )
      then htLast.DoForAllNode(proc);
    if(Child = htLast.Next)
      then begin break; end;
    htLast := htLast.Next;
  end;
end;

function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;
var
  Count, I: Integer;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> N) do
  begin
    { skip over delimiters }
//  while (I <= Length(S)) and (S[I] in WordDelims) do Inc(I);
    while (I <= Length(S))
        and ((ByteType(S,I)=mbSingleByte) and (S[I] in WordDelims)) do Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S) then Inc(Count);
    { if not finished, find the end of the current word }
    if Count <> N then
//    while (I <= Length(S)) and not (S[I] in WordDelims) do Inc(I)
      while (I <= Length(S))
        and not ((ByteType(S,I)=mbSingleByte) and (S[I] in WordDelims)) do Inc(I)
    else Result := I;
  end;
end;

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;
var
  I: Word;
  Len: Integer;
begin
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  if I <> 0 then
    { find the end of the current word }
//  while (I <= Length(S)) and not(S[I] in WordDelims) do begin
    while (I <= Length(S)) and not ((ByteType(S,I)=mbSingleByte) and (S[I] in WordDelims)) do
    begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet; var Pos: Integer): string;
var
  I, Len: Integer;
begin
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  Pos := I;
  if I <> 0 then
    { find the end of the current word }
//  while (I <= Length(S)) and not(S[I] in WordDelims) do begin
    while (I <= Length(S)) and not ((ByteType(S,I)=mbSingleByte) and (S[I] in WordDelims)) do
    begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;


procedure TCustomDBGridEh.SetDrawMemoText(const Value: Boolean);
begin
  FDrawMemoText := Value;
  Invalidate;
end;

procedure TCustomDBGridEh.GetCellParams(Column: TColumnEh; AFont: TFont;
  var Background: TColor; State: TGridDrawState);
begin
  if Assigned(FOnGetCellParams) then
    FOnGetCellParams(Self, Column, AFont, Background, State);
end;

{
procedure TCustomDBGridEh.EnsureFooterValueType(
  AFooterValueType: TFooterValueType; AFieldName: String);
var i,j:Integer;
    PresentGO:Boolean;
    ASum:TDBSum;
begin
  PresentGO := False;
  FSumList.SumCollection.BeginUpdate;
  if (AFooterValueType in [fvtSum..fvtCount]) then begin
    for i := 0 to FSumList.SumCollection.Count-1 do begin
      if ((FSumList.SumCollection[i].GroupOperation = goSum) and
         (AFooterValueType = fvtSum) and
         (FSumList.SumCollection[i].FieldName = AFieldName)) or
         ((FSumList.SumCollection[i].GroupOperation = goCount) and
         (AFooterValueType = fvtCount)) then
           PresentGO := True;
    end;
    if (PresentGO = False) then begin
      ASum := (FSumList.SumCollection.Add as TDBSum);
      case AFooterValueType of
        fvtSum: begin
                  ASum.GroupOperation := goSum;
                  ASum.FieldName := AFieldName;
                end;
        fvtCount: ASum.GroupOperation := goCount;
      end;
    end;
  end;

  for i := FSumList.SumCollection.Count-1 downto 0 do begin
    PresentGO := False;
    for j := 0 to Columns.Count - 1 do begin
      case Columns[j].Footer.ValueType of
        fvtSum: if (FSumList.SumCollection[i].GroupOperation = goSum) and
                   (FSumList.SumCollection[i].FieldName = Columns[j].FieldName) then begin
                     PresentGO := True;
                     Break;
                 end;
        fvtCount: if (FSumList.SumCollection[i].GroupOperation = goCount) then begin
                     PresentGO := True;
                     Break;
                 end;
      else
        PresentGO := True;
        Break;
      end;
    end;
    if (PresentGO = False) then FSumList.SumCollection[i].Free;
  end;
  FSumList.SumCollection.EndUpdate;
end;}

procedure TCustomDBGridEh.InvalidateFooter;
var i:Integer;
begin
  for i := 0 to FooterRowCount-1 do begin
    GridInvalidateRow(Self,RowCount-i-1);
  end;
end;

procedure TCustomDBGridEh.SetSumList(const Value: TDBGridEhSumList);
begin
  FSumList.Assign(Value);
end;

procedure TCustomDBGridEh.SumListChanged(Sender: TObject);
begin
  InvalidateFooter;
end;

function TCustomDBGridEh.CellRect(ACol, ARow: Integer): TRect;
begin
  Result := inherited CellRect(ACol, ARow);
end;

procedure TCustomDBGridEh.GetFooterParams(DataCol, Row: Integer;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  var Alignment: TAlignment; State: TGridDrawState; var Text: String);
begin
  if Assigned(FOnGetFooterParams) then
    FOnGetFooterParams(Self, DataCol, Row, Column, AFont, Background, Alignment, State, Text);
end;

procedure TCustomDBGridEh.DefaultDrawFooterCell(const Rect: TRect; DataCol,
  Row: Integer; Column: TColumnEh; State: TGridDrawState);
var
  Value: string;
  NewBackgrnd: TColor;
  NewAlignment: TAlignment;
  XFrameOffs,YFrameOffs: Integer;
  ARect:TRect;
begin
  ARect := Rect;
  if (dghFooter3D in OptionsEh) then
  begin
    XFrameOffs := 1;
    InflateRect(ARect, -1, -1);
  end
  else XFrameOffs := 2;
  YFrameOffs := XFrameOffs;
  if Flat then Dec(YFrameOffs);
  Value := GetFooterValue(Row,Column);
  NewBackgrnd := Canvas.Brush.Color;
  NewAlignment := Column.Footer.Alignment;
  Value := GetFooterValue(Row, Column);

  GetFooterParams(DataCol,  Row, Column, Font,
                  NewBackgrnd, NewAlignment, State, Value);

  Canvas.Brush.Color := NewBackgrnd;

  WriteTextEh(Canvas, ARect, True, XFrameOffs, YFrameOffs, Value, Column.Footer.Alignment,tlTop, Column.Footer.WordWrap and FAllowWordWrap, Column.Footer.EndEllipsis,0,0);
end;

function TCustomDBGridEh.GetFooterValue(Row: Integer; Column: TColumnEh): String;
const
  SumListArray: array [TFooterValueType] of TGroupOperation =
    (goSum, goSum, goAvg, goCount, goSum, goSum);
var
  FmtStr: string;
  Format: TFloatFormat;
  Digits: Integer;
  v: Variant;
  Field: TField;
  Footer: TColumnFooterEh;
begin
  Result := '';
  Field := nil;
  Footer := Column.UsedFooter(Row);
  case Footer.ValueType of
    //fgoNon: FillRect(ARect);
    fvtSum,fvtAvg:
    begin
      Result := '0';
      if Assigned(DataSource) and Assigned(DataSource.DataSet)
        then if Footer.FieldName <> ''
         then Field := DataSource.DataSet.FindField(Footer.FieldName)
         else Field := DataSource.DataSet.FindField(Column.FieldName);
      if Field = nil then Exit;
      with Field do
      begin
        v := SumList.SumCollection.GetSumByOpAndFName(SumListArray[Footer.ValueType],FieldName).SumValue;
        case DataType of
          ftSmallint, ftInteger, ftAutoInc, ftWord :
             with Field as TIntegerField do
             begin
               FmtStr := DisplayFormat;
               if FmtStr = '' then Str(Integer(v), Result) else Result := FormatFloat(FmtStr, v);
             end;
          ftBCD:
            with Field as TBCDField do
            begin
              //if EditFormat = '' then FmtStr := DisplayFormat else FmtStr := EditFormat;
              FmtStr := DisplayFormat;
              if FmtStr = '' then
              begin
                if Currency then
                begin
                  Format := ffCurrency;
                  Digits := CurrencyDecimals;
                end
                else begin
                  Format := ffGeneral;
                  Digits := 0;
                end;
                Result := CurrToStrF(v, Format, Digits);
              end else
                Result := FormatCurr(FmtStr, v);
            end;
          {$IFDEF EH_LIB_6}
          ftFMTBcd:
            with Field as TFMTBCDField do
            begin
              //if EditFormat = '' then FmtStr := DisplayFormat else FmtStr := EditFormat;
              FmtStr := DisplayFormat;
              if FmtStr = '' then
              begin
                if Currency then
                begin
                  Format := ffCurrency;
                  Digits := CurrencyDecimals;
                end
                else begin
                  Format := ffGeneral;
                  Digits := 0;
                end;
                Result := CurrToStrF(v, Format, Digits);
              end else
                Result := FormatCurr(FmtStr, v);
            end;
          {$ENDIF}
          ftFloat,ftCurrency:
            with Field as TFloatField do
            begin
              //if EditFormat = '' then FmtStr := DisplayFormat else FmtStr := EditFormat;
              FmtStr := DisplayFormat;
              if FmtStr = '' then
              begin
                if Currency then
                begin
                  Format := ffCurrency;
                  Digits := CurrencyDecimals;
                end
                else begin
                  Format := ffGeneral;
                  Digits := 0;
                end;
                 Result := FloatToStrF(v, Format, Precision, Digits);
              end else
                Result := FormatFloat(FmtStr, v);
            end;
        end;
      end;
        {Result := FloatToStr(SumList.SumCollection.GetSumByOpAndFName(goSum,Column.FieldName).SumValue);}
    end;
    fvtCount:
      Result := FloatToStr(SumList.SumCollection.GetSumByOpAndFName(goCount,'').SumValue);
    fvtFieldValue:
      if Assigned(DataSource) and Assigned(DataSource.DataSet) and
         DataSource.DataSet.Active and (Footer.FieldName <> '')
        then Result := DataSource.DataSet.FieldByName(Footer.FieldName).DisplayText;
    fvtStaticText: Result := Footer.Value;
  end;
end;

procedure TCustomDBGridEh.SumListRecalcAll(Sender: TObject);
begin
  if Assigned(FOnSumListRecalcAll) then
    FOnSumListRecalcAll(SumList);
end;

procedure TCustomDBGridEh.SetHorzScrollBar(const Value: TDBGridEhScrollBar);
begin
 FHorzScrollBar.Assign(Value);
end;

procedure TCustomDBGridEh.SetVertScrollBar(const Value: TDBGridEhScrollBar);
begin
  FVertScrollBar.Assign(Value);
end;

procedure TCustomDBGridEh.SetOptionsEh(const Value: TDBGridEhOptions);
var I: Integer;
begin
  if (OptionsEh = Value) then Exit;
  if ( dghMultiSortMarking in (FOptionsEh - Value)) then
    for i := FSortMarkedColumns.Count - 1 downto 1 do
      FSortMarkedColumns[i].Title.SortMarker := smNoneEh;
  FOptionsEh := Value;
  LayoutChanged;
end;

function TCustomDBGridEh.VisibleDataRowCount: Integer;
begin
  Result := VisibleRowCount;
  if FooterRowCount <= 0 then Exit;
  Result := Result - FooterRowCount-1;
  if Result < 1 then Result := 1;
end;


function TCustomDBGridEh.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := (DataLink <> nil) and DataLink.ExecuteAction(Action);
  if not Result and Focused then
  begin
    if (Action is TEditCopy) and (geaCopyEh in EditActions) and
        CheckCopyAction then
    begin
      DBGridEh_DoCopyAction(Self,False);
      Result := True;
    end
    else if (Action is TEditPaste) and (geaPasteEh in EditActions) and
            CheckPasteAction then
    begin
      DBGridEh_DoPasteAction(Self,False);
      Result := True;
    end
    else if (Action is TEditCut) and (geaCutEh in EditActions) and
            CheckCutAction then
    begin
      DBGridEh_DoCutAction(Self,False);
      Result := True;
    end
{$IFDEF EH_LIB_5}
    else if (Action is TEditSelectAll) and (geaSelectAllEh in EditActions) and
            CheckSelectAllAction then
    begin
      Selection.SelectAll;
      Result := True;
    end
    else if (Action is TEditDelete) and (geaDeleteEh in EditActions) and
            CheckDeleteAction then
    begin
      DBGridEh_DoDeleteAction(Self,False);
      Result := True;
    end;
{$ENDIF}
  end;
end;

function TCustomDBGridEh.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := (DataLink <> nil) and DataLink.UpdateAction(Action);
  if not Result and Focused then
  begin
    if (Action is TEditCopy) and (geaCopyEh in EditActions) then
    begin
      TEditCopy(Action).Enabled := CheckCopyAction;
      Result := True;
    end
    else if (Action is TEditPaste) and (geaPasteEh in EditActions) then
    begin
      TEditPaste(Action).Enabled := CheckPasteAction;
      Result := True;
    end
    else if (Action is TEditCut) and (geaCutEh in EditActions) then
    begin
      TEditCut(Action).Enabled := CheckCutAction;
      Result := True;
    end
{$IFDEF EH_LIB_5}
    else if (Action is TEditSelectAll) and (geaSelectAllEh in EditActions) then
    begin
      TEditCopy(Action).Enabled := CheckSelectAllAction;
      Result := True;
    end
    else if (Action is TEditDelete) and (geaDeleteEh in EditActions) then
    begin
      TEditDelete(Action).Enabled := CheckDeleteAction;
      Result := True;
    end;
{$ENDIF}
  end;
end;

function TCustomDBGridEh.CheckCopyAction:Boolean;
begin
  Result := FDatalink.Active and (Selection.SelectionType <> gstNon);
end;

function TCustomDBGridEh.CheckPasteAction:Boolean;
begin
  Result := FDatalink.Active and not ReadOnly and
            FDatalink.DataSet.CanModify and (
              Clipboard.HasFormat(CF_VCLDBIF) or Clipboard.HasFormat(CF_TEXT));
  if Result then
    if (FDatalink.DataSet.State <> dsInsert) and
       not (alopUpdateEh in AllowedOperations) then
         Result := False;
end;

function TCustomDBGridEh.CheckCutAction:Boolean;
begin
  Result := CheckCopyAction and CheckDeleteAction;
end;

function TCustomDBGridEh.CheckSelectAllAction:Boolean;
begin
  Result := FDatalink.Active and not FDatalink.DataSet.IsEmpty and (gstAll in AllowedSelections);
end;

function TCustomDBGridEh.CheckDeleteAction:Boolean;
begin
  Result := FDatalink.Active and not ReadOnly and not FDatalink.DataSet.IsEmpty and
            FDatalink.DataSet.CanModify and
            (
              ( (Selection.SelectionType in [gstRecordBookmarks,gstAll]) and
                (alopDeleteEh in AllowedOperations) )
              or
              ( (Selection.SelectionType in [gstRectangle,gstColumns]) and
                (alopUpdateEh in AllowedOperations) )
            );
end;

procedure TCustomDBGridEh.TimerScroll;
var
  Delta, Distance, Interval, DeltaX, DistanceX: Integer;
  ADataRect:Trect;
  WithSeleting:Boolean;
  Point:TPoint;
begin
  if FDBGridEhState = dgsColSelecting then
  begin
    GetCursorPos(Point);
    Point := ScreenToClient(Point);
//    Point := FMousePos;
    ADataRect := DataRect;
    if Point.X > ADataRect.Right then
    begin
      (*if Selection.Columns.FShiftCol.Index+1 < Columns.Count then
        if Selection.Columns.IndexOf(Columns[RawToDataColumn(LeftCol + VisibleColCount-1)]) = -1 then
          Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol + VisibleColCount-1)],True);
      if Selection.Columns.FShiftCol.Index+1 < Columns.Count then
         Selection.Columns.SelectShift(Columns[Selection.Columns.FShiftCol.Index+1],True);

      while RawToDataColumn(LeftCol + VisibleColCount) < Selection.Columns.FShiftCol.Index+1 do LeftCol := LeftCol + 1;*)
      if LeftCol + VisibleColCount {+ FixedCols - 1} < ColCount then
      begin
        LeftCol := LeftCol + 1;
        if LeftCol + VisibleColCount + FixedCols < ColCount
          then Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol + VisibleColCount+1)]{,True})
          else Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol + VisibleColCount-1)]{,True});
      end
      else
        Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol + VisibleColCount-1)]{,True});
      Interval := 200 - (Point.X - ADataRect.Right) * 10;
      if Interval < 0 then Interval := 0;
      ResetTimer(Interval);
    end
    else if Point.X < ADataRect.Left then
    begin
      (*if Selection.Columns.FShiftCol.Index > 0 then
        if Selection.Columns.IndexOf(Columns[RawToDataColumn(LeftCol)]) = -1 then
          Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol)],True);
      if Selection.Columns.FShiftCol.Index - 1 >= 0 then
         Selection.Columns.SelectShift(Columns[Selection.Columns.FShiftCol.Index-1],True);

      while RawToDataColumn(LeftCol) > Selection.Columns.FShiftCol.Index do LeftCol := LeftCol - 1;*)
      if LeftCol > FixedCols then
      begin
        LeftCol := LeftCol - 1;
        if LeftCol > FixedCols
          then Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol-1)]{,True})
          else Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol)]{,True});
      end
      else
        Selection.Columns.SelectShift(Columns[RawToDataColumn(LeftCol)]{,True});

      Interval := 200 - (ADataRect.Left - Point.X) * 10;
      if Interval < 0 then Interval := 0;
      ResetTimer(Interval);
    end
  end else
  begin
    Delta := 0;
    Distance := 0;
    ADataRect := DataRect;
    if FDownMousePos.Y < ADataRect.Top then
    begin
      Delta := -1;
      Distance := ADataRect.Top - FDownMousePos.Y;
    end;
    if FDownMousePos.Y >= ADataRect.Bottom then
    begin
      Delta := 1;
      Distance := FDownMousePos.Y - ADataRect.Bottom + 1;
    end;

    DeltaX := 0;
    DistanceX := 0;
    if FDownMousePos.X < ADataRect.Left then
    begin
      DeltaX := -1;
      DistanceX := ADataRect.Left - FDownMousePos.X;
    end;
    if FDownMousePos.X >= ADataRect.Right then
    begin
      DeltaX := 1;
      DistanceX := FDownMousePos.X - ADataRect.Right;
    end;
    Distance := Max(Distance,DistanceX);
    WithSeleting := ssLeft in FMouseShift;

    if (Delta = 0) and (DeltaX = 0)
      then StopTimer
    else
    begin
      BeginUpdate;
      try
        if (Delta <> 0) and not (FDBGridEhState = dgsRectSelecting) then
        begin
           {if (dgMultiSelect in Options) then}
               DoSelection(WithSeleting,iif(Distance div 6 > 8,8,Distance div 6)*Delta,False,True);
        end;
        if (DeltaX <> 0) and FDataTracking then
  //        if dgRowSelect in Options then begin
           if (DeltaX < 0) and (LeftCol > FixedCols ) then
              LeftCol := LeftCol + DeltaX
           else if (DeltaX > 0) and (VisibleColCount + LeftCol < ColCount ) then
              LeftCol := LeftCol + DeltaX;
  //        end else
        if FDBGridEhState <> dgsRowSelecting then
          if DeltaX > 0
            then MoveCol(Col+DeltaX,1,False)
            else MoveCol(Col+DeltaX,-1,False);
        if (FDBGridEhState = dgsRectSelecting) then
        begin
          FDatalink.Dataset.MoveBy(iif(Distance div 6 > 8,8,Distance div 6)*Delta);
          if (DeltaX < 0) and (LeftCol = FixedCols)
            then Selection.Rect.Select(RawToDataColumn(IndicatorOffset),DataSource.DataSet.Bookmark,True)
            else Selection.Rect.Select(RawToDataColumn(Col),DataSource.DataSet.Bookmark,True)
        end;
      finally
        EndUpdate;
      end;
      if UpdateLock = 0 then Update;
      Interval := 200 - Distance * 15;
      if Interval < 0 then Interval := 0;
////    KillTimer(Handle, 1);//??????tmp
////    SetTimer(Handle, 1, Interval, nil);
      ResetTimer(Interval);
////    FTimerActive := True;
    end;
  end;
end;

procedure TCustomDBGridEh.StopTimer;
begin
  if FTimerActive then
  begin
    KillTimer(Handle, 1);
    FTimerActive := False;
    FTimerInterval := -1;
  end;
end;

procedure TCustomDBGridEh.ResetTimer(Interval: Integer);
begin
  if FTimerActive = False then
    SetTimer(Handle, 1, Interval, nil)
  else if Interval <> FTimerInterval then
  begin
    StopTimer;
    SetTimer(Handle, 1, Interval, nil);
    FTimerInterval := Interval;
  end;
  FTimerActive := True;
end;

procedure TCustomDBGridEh.WMTimer(var Message: TWMTimer);
begin
  inherited ;
  case Message.TimerID of
    1: if FIndicatorPressed or FDataTracking or
          (FDBGridEhState =  dgsColSelecting)
         then TimerScroll;
    2: StopInplaceSearch;
   end;
end;

function TCustomDBGridEh.DataRect: TRect;
begin
  Result := BoxRect(IndicatorOffset, TitleOffset, ColCount-1,
    iif(FooterRowCount>0,RowCount-FooterRowCount-2,RowCount));
end;

procedure TCustomDBGridEh.DoSortMarkingChanged;
begin
  if (dghAutoSortMarking in OptionsEh) and Assigned(FOnSortMarkingChanged)
    then FOnSortMarkingChanged(Self);
end;

procedure TCustomDBGridEh.SetSortMarkedColumns;
var i: Integer;
begin
  SortMarkedColumns.Clear;
  for i := 0 to Columns.Count-1 do
    if Columns[i].Title.SortIndex > 0 then
    begin
      if SortMarkedColumns.Count < Columns[i].Title.SortIndex then
        SortMarkedColumns.Count := Columns[i].Title.SortIndex;
      SortMarkedColumns[Columns[i].Title.SortIndex-1] := Columns[i];
    end;
end;

procedure TCustomDBGridEh.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if FSortMarking and (Key = 17) then
  begin
    FSortMarking := False;
    DoSortMarkingChanged;
  end;
  inherited KeyUp(Key,Shift);
end;

procedure TCustomDBGridEh.TopLeftChanged;
  procedure InvalidateTitle;
  var i:Integer;
  begin
    for i := 0 to TitleOffset-1 do GridInvalidateRow(Self,i);
  end;
begin
  if FTopLeftVisible then
  begin
    if (LeftCol <> FixedCols) then
    begin
      InvalidateTitle;
      FTopLeftVisible := False;
    end;
  end
  else
  if (LeftCol = FixedCols) then
  begin
    InvalidateTitle;
    FTopLeftVisible := True;
  end;
  inherited TopLeftChanged;
end;

procedure TCustomDBGridEh.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
//  inherited;
end;

procedure TCustomDBGridEh.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
  StopTracking;
  if FDBGridEhState = dgsColSizing then
    DrawSizingLine(GridWidth, GridHeight)
  else if FDBGridEhState <> dgsNormal then StopTimer;
  FDBGridEhState := dgsNormal;
end;

procedure TCustomDBGridEh.WMCancelMode(var Message: TMessage);
begin
  inherited;
  StopTracking;
  if FDBGridEhState = dgsColSizing then
    DrawSizingLine(GridWidth, GridHeight)
  else if (FDBGridEhState <> dgsNormal) then StopTimer;
  FDBGridEhState := dgsNormal;
end;

procedure TCustomDBGridEh.WndProc(var Message: TMessage);
begin
  if (DragMode = dmAutomatic) and (dgMultiSelect in Options) and
     not (csDesigning in ComponentState) and
     ((Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONDBLCLK)) then
   begin
     DragMode := dmManual;
     FAutoDrag := True;
     try
       inherited WndProc(Message);
     finally
       FAutoDrag := False;
       DragMode := dmAutomatic;
     end;
   end
   else
     inherited WndProc(Message);
end;

procedure TCustomDBGridEh.SaveBookmark;
begin
  FLookedOffset := DataLink.ActiveRecord - (DataLink.RecordCount div 2) +
                     ((DataLink.RecordCount+1) mod 2){ - 1};
  DataLink.DataSet.MoveBy(-FLookedOffset);
  FLockedBookmark := DataLink.DataSet.Bookmark;
  DataLink.DataSet.MoveBy(FLookedOffset);
end;

procedure TCustomDBGridEh.RestoreBookmark;
begin
  DataLink.DataSet.Bookmark := FLockedBookmark;
  DataLink.DataSet.MoveBy(FLookedOffset);
end;

type
  TToolTipsWindow = class(THintWindow)
  public
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;
  end;

function TToolTipsWindow.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;
begin
  Canvas.Font.Assign(TFont(AData));
  Canvas.Font.Color := clWindowText;
  Result := inherited CalcHintRect(MaxWidth,AHint,AData);
end;

procedure OverturnUpRect(var ARect:TRect);
var Bottom:Integer;
begin
  Bottom := ARect.Bottom;
  ARect.Bottom := ARect.Top + (ARect.Right - ARect.Left);
  ARect.Right := ARect.Left + (Bottom - ARect.Top);
end;

procedure TCustomDBGridEh.CMHintShow(var Message: TCMHintShow);
var Cell: TGridCoord;
    Column: TColumnEh;
    OldActive, TextWidth, DataRight, RightIndent: Integer;
    s: String;
    ARect: TRect;
    WordWrap: Boolean;
    TextWider: Boolean;
    AAlignment: TAlignment;
    TopIndent: Integer;
    IsDataToolTips: Boolean;

  function CheckHintTextRect(ws:String; ARect:TRect; WordWrap:Boolean; var TextWidth:Integer):Boolean;
  var NewRect:TRect;
      uFormat:Integer;
  begin
    Result := False;
    uFormat := DT_CALCRECT or DT_LEFT or DT_NOPREFIX or DrawTextBiDiModeFlagsReadingOnly;
    if WordWrap then uFormat := uFormat or DT_WORDBREAK;

    NewRect := Rect(0,0,ARect.Right - ARect.Left - 2 - RightIndent,0);
    DrawText(Canvas.Handle, PChar(ws), Length(ws), NewRect, uFormat);
    TextWidth :=NewRect.Right - NewRect.Left;
    if (NewRect.Right-NewRect.Left > ARect.Right-ARect.Left-2-RightIndent) or
       (NewRect.Bottom-NewRect.Top > ARect.Bottom-ARect.Top-FInterlinear+1) then
      Result := True;
  end;

  function GetToolTipsColumnText(Column:TColumnEh): String;
  var KeyIndex:Integer;
  begin
    Result := '';
    if Column.GetColumnType in [ctKeyImageList,ctCheckboxes] then
    begin
      if Column.GetColumnType = ctKeyImageList
        then KeyIndex := Column.KeyList.IndexOf(Column.Field.Text)
        else KeyIndex := Integer(Column.CheckboxState);
      if (KeyIndex > -1) and (KeyIndex < Column.PickList.Count)
        then Result := Column.PickList.Strings[KeyIndex];
    end
    else if Column.Field <> nil
      then Result := Column.DisplayText;
  end;
begin
  inherited;
  if Message.Result = 0 then
  begin
    IsDataToolTips := False;
    Cell := MouseCoord(HitTest.X, HitTest.Y);
    if (Cell.X < IndicatorOffset) or (Cell.Y < 0) then Exit;
    Column := Columns[RawToDataColumn(Cell.X)];
    if (Cell.Y = TitleOffset-1) and (Column.Title.Hint <> '') then
    begin  // Title hint
      Message.HintInfo^.HintStr := GetShortHint(Columns[RawToDataColumn(Cell.X)].Title.Hint);
      Message.HintInfo^.CursorRect := CellRect(Cell.X,Cell.Y);
    end
    else if (((Cell.Y = TitleOffset-1) and Column.Title.ToolTips) or
            ((Cell.Y >= TitleOffset) and (Cell.Y < DataRowCount + TitleOffset) and DataLink.Active and
              Column.ToolTips)) and (Mouse.Capture = 0) and (GetKeyState(VK_CONTROL) >= 0) then
    begin  // Title tooltips
      ARect := CellRect(Cell.X, Cell.Y);
      DataRight := ARect.Left + Column.Width;
      if Cell.Y = TitleOffset-1 then
      begin
        if Column.Title.GetSortMarkingWidth > 2 then
        begin
          Dec(ARect.Right,Column.Title.GetSortMarkingWidth-2);
          Dec(DataRight,Column.Title.GetSortMarkingWidth-2);
        end;
        if UseMultiTitle = True then
        begin
          s := FLeafFieldArr[RawToDataColumn(Cell.X)].FLeaf.Text;
          ARect.Top := ARect.Bottom - FLeafFieldArr[Cell.X-IndicatorOffset].FLeaf.Height + 1;
          if HitTest.Y < ARect.Top then Exit;
        end
        else
          s := Column.Title.Caption;
        WordWrap := (FUseMultiTitle = True) or (TitleHeight <> 0) or (TitleLines <> 0);
        AAlignment := Column.Title.Alignment;
        if FHintFont = nil then
          FHintFont := TFont.Create;
        FHintFont.Assign(Column.Title.Font);
        Canvas.Font.Assign(FHintFont);
        if Column.Title.Orientation = tohVertical then
        begin
          WordWrap := False;
          OverturnUpRect(ARect);
        end;
      end else
      begin // Data tooltips
        IsDataToolTips := True;
        OldActive := DataLink.ActiveRecord;
        try
          DataLink.ActiveRecord := Cell.Y - TitleOffset;
          s := '';
          s := GetToolTipsColumnText(Column);
          if Column.AlwaysShowEditButton and (GetColumnEditStile(Column) <> esSimple) then
          begin
            DataRight := ARect.Left + Column.Width - FInplaceEditorButtonWidth;
            if DataRight < ARect.Right then
              ARect.Right := DataRight;
            if HitTest.X > ARect.Right then s := '';
          end else
            DataRight := ARect.Left + Column.Width;
          AAlignment := Column.Alignment;
          if Column.GetColumnType in [ctKeyImageList,ctCheckboxes] then
            AAlignment := taLeftJustify;
          WordWrap := Column.WordWrap and FAllowWordWrap;
          if FHintFont = nil then
            FHintFont := TFont.Create;

          FHintFont.Assign(Column.Font);
          //NoBackgrnd := Canvas.Brush.Color;
          //State := [];

          Column.FillColCellParams(FColCellParamsEh);
          with FColCellParamsEh do
          begin
            FBackground := Canvas.Brush.Color;
            FFont := FHintFont;
            FState := [];
            FAlignment := AAlignment;
            FText := s;
            FCol := Cell.X;
            FRow := Cell.Y;
            GetCellParams(Column,FFont,FBackground,FState);
            Column.GetColCellParams(False,FColCellParamsEh);
            s := FText;
            AAlignment := FAlignment;
          end;

          //GetCellParams(Column,FHintFont,NoBackgrnd,State);

          Canvas.Font.Assign(FHintFont);
        finally
          DataLink.ActiveRecord := OldActive;
        end;
      end;

      if WordWrap then RightIndent := 2 else RightIndent := 0;
      if IsDataToolTips and (Column.GetColumnType in [ctKeyImageList,ctCheckboxes])
        then TextWider := True
        else TextWider := CheckHintTextRect(s,ARect,WordWrap,TextWidth);

      if Flat then TopIndent := 2 else TopIndent := 1;

      with PHintInfo(Message.HintInfo)^ do
        if TextWider or ((AAlignment = taRightJustify) and (DataRight - 2 > ARect.Right )) then
        begin
          HintStr := s;
          CursorRect := ARect;
          case AAlignment of
            taLeftJustify:
              HintPos := ClientToScreen(Point(ARect.Left-1,ARect.Top-TopIndent));
            taRightJustify:
              HintPos := ClientToScreen(Point(DataRight + 1 - TextWidth - 7,ARect.Top-TopIndent));
            taCenter:
              HintPos := ClientToScreen(Point(DataRight + 1 - TextWidth - 6 +
                TextWidth div 2 - (DataRight - ARect.Left - 4) div 2, ARect.Top-TopIndent));
          end;
          HintWindowClass := TToolTipsWindow;
          HintData := FHintFont;
          if WordWrap then
            HintMaxWidth := ARect.Right - ARect.Left - 4;
        end
        else
          HintStr := '';
      end;
  end;
end;

procedure TCustomDBGridEh.CMHintsShowPause(var Message: TCMHintShowPause);
var Cell:TGridCoord;
    Column:TColumnEh;
begin
  with Message do
  begin
    Cell := MouseCoord(HitTest.X, HitTest.Y);
    if (Cell.X < IndicatorOffset) or (Cell.Y < 0) then Exit;
    Column := Columns[RawToDataColumn(Cell.X)];
    if ((Cell.Y >= TitleOffset) and (Cell.Y < DataRowCount + TitleOffset) and DataLink.Active and Column.ToolTips) or
       ((Cell.Y = TitleOffset-1) and Column.Title.ToolTips and (Column.Title.Hint = ''))
      then Pause^ := 0
      else Pause^ := Application.HintPause;
  end;
end;

procedure TCustomDBGridEh.SetTitleImages(const Value: TCustomImageList);
begin
  FTitleImages := Value;
  if Value <> nil then Value.FreeNotification(Self);
  LayoutChanged;
end;

function TCustomDBGridEh.AllowedOperationUpdate: Boolean;
begin
  Result := FDatalink.Active and ((alopUpdateEh in AllowedOperations) or
    (not (alopUpdateEh in AllowedOperations) and (FDatalink.DataSet.State = dsInsert)));
end;

function TCustomDBGridEh.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
//  if FDatalink.Active then FDatalink.DataSet.MoveBy(1{Mouse.WheelScrollLines});
  if FDatalink.Active then FDatalink.DataSet.Next;
  Result := True;
end;

function TCustomDBGridEh.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
//  if FDatalink.Active then FDatalink.DataSet.MoveBy(-1{Mouse.WheelScrollLines});
  if FDatalink.Active then FDatalink.DataSet.Prior;
  Result := True;
end;

procedure TCustomDBGridEh.CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer; var FixedInfo: TGridDrawInfo);
var I, IndicatorBoundary: Integer;
begin
  inherited ;
  if State = gsRowSizing then
  begin
    IndicatorBoundary := 0;
    for I := 0 to IndicatorOffset-1 do
      Inc(IndicatorBoundary, ColWidths[I] + GridLineWidth);
    if X >= IndicatorBoundary then State := gsNormal;
  end;
end;

procedure TCustomDBGridEh.CalcFrozenSizingState(X, Y: Integer;
  var State: TDBGridEhState; var Index: Longint; var SizingPos, SizingOfs: Integer);
var I, Line, Back, Range, VertFixedBoundary,HorzGridBoundary : Integer;
    EffectiveOptions: TGridOptions;
begin
  State := dgsNormal;
  Index := -1;
  EffectiveOptions := inherited Options;
  if csDesigning in ComponentState then
    EffectiveOptions := EffectiveOptions + DesignOptionsBoost;
  if not (goColSizing in EffectiveOptions) then Exit;
  if UseRightToLeftAlignment then
    X := ClientWidth - X;
  Line := 0;
  VertFixedBoundary := 0;
  HorzGridBoundary := GridWidth;
  for I := 0 to TitleOffset-1 do
  begin
    Inc(VertFixedBoundary, RowHeights[I] + GridLineWidth);
  end;
  if Y >= VertFixedBoundary then Exit;
  for I := 0 to IndicatorOffset-1 do
  begin
    Inc(Line, ColWidths[I] + GridLineWidth);
  end;
  Range := GridLineWidth;
  Back := 0;
  if Range < 7 then
  begin
    Range := 7;
    Back := (Range - GridLineWidth) shr 1;
  end;
  for I := IndicatorOffset to FixedCols-1 do
  begin
    Inc(Line, ColWidths[I]);
    if Line > HorzGridBoundary then
    begin
      Index := I;
      Break;
    end;
    if (X >= Line - Back) and (X <= Line - Back + Range) then
    begin
      State := dgsColSizing;
      SizingPos := Line;
      SizingOfs := Line - X;
      Index := I;
      Exit;
    end;
    Inc(Line, GridLineWidth);
  end;
  if (Line > HorzGridBoundary) and (HorzGridBoundary = ClientWidth) and
     (X >= ClientWidth - Back) and (X <= ClientWidth) then
  begin
    State := dgsColSizing;
    SizingPos := ClientWidth;
    SizingOfs := ClientWidth - X;
//    Index := LeftCol - VisibleColCount;
  end;
end;

function TCustomDBGridEh.FrozenSizing(X, Y: Integer): Boolean;
var
  State: TDBGridEhState;
  Index: Longint;
  Pos, Ofs: Integer;
begin
  State := FDBGridEhState;
  if State = dgsNormal then
  begin
    CalcFrozenSizingState(X, Y, State, Index, Pos, Ofs);
  end;
  Result := State <> dgsNormal;
end;

procedure TCustomDBGridEh.DrawSizingLine(HorzGridBoundary, VertGridBoundary: Integer);
var
  OldPen: TPen;
begin
  OldPen := TPen.Create;
  try
    with Canvas do
    begin
      OldPen.Assign(Pen);
      Pen.Style := psDot;
      Pen.Mode := pmXor;
      Pen.Width := 1;
      try
        if FGridState = gsRowSizing then
        begin
          MoveTo(0, FSizingPos);
          LineTo(HorzGridBoundary, FSizingPos);
        end else
        begin
          MoveTo(FSizingPos, 0);
          LineTo(FSizingPos, VertGridBoundary);
        end;
      finally
        Pen := OldPen;
      end;
    end;
  finally
    OldPen.Free;
  end;
end;

function  TCustomDBGridEh.GetCol: Longint;
begin
{  if FFrozenFocuse then
    Result := FFrozenCol
  else}
    Result := inherited Col;
end;

procedure TCustomDBGridEh.SetCol(Value: Longint);
begin
  if Value = Col then Exit;
  if (Value <= FixedCols-1) and (Value >= IndicatorOffset) then
  begin
    {FFrozenFocuse := True;
    FFrozenCol := Value;}
    MoveColRow(Value, Row, False, False);
  end else
  begin
    inherited Col := Value;
//    FFrozenFocuse := False;
  end;
end;

function TCustomDBGridEh.DataRowCount: Integer;
begin
  if FooterRowCount > 0
    then Result := RowCount - FooterRowCount - 1 - TitleOffset
    else Result := RowCount - TitleOffset;
end;

procedure TCustomDBGridEh.SetFlat(const Value: Boolean);
begin
  if FFlat = Value then Exit;
  FFlat := Value;
  if FFlat
    then FInterlinear := 2
    else FInterlinear := 4;
  RecreateWnd();
  LayoutChanged();
end;

procedure TCustomDBGridEh.DrawEdgeEh(ACanvas: TCanvas; qrc: TRect;
  IsDown, IsSelected: Boolean; NeedLeft,NeedRight:Boolean);
var ThreeDLine: Integer;
    TopLeftFlag, BottomRightFlag: Integer;
begin
  TopLeftFlag := BF_TOPLEFT;
  BottomRightFlag := BF_BOTTOMRIGHT;
  if UseRightToLeftAlignment then
  begin
    LPtoDP(Canvas.Handle,qrc,2);
    Swap(qrc.Left,qrc.Right);
    ChangeGridOrientation(False);
    TopLeftFlag := BF_TOPRIGHT;
    BottomRightFlag := BF_BOTTOMLEFT;
  end;

  if Flat then
  begin
    if IsSelected or IsDown
      then ThreeDLine := BDR_SUNKENINNER
      else ThreeDLine := BDR_RAISEDINNER;

    Canvas.Pen.Color := Canvas.Brush.Color;
    if UseRightToLeftAlignment then
    begin
      Canvas.Polyline([Point(qrc.Left,qrc.Bottom-1),Point(qrc.Right,qrc.Bottom-1)]);
      if NeedRight then
        DrawEdge(Canvas.Handle, qrc, ThreeDLine, BF_LEFT);
      DrawEdge(Canvas.Handle, qrc, ThreeDLine, BF_TOP);
      if NeedLeft
        then Canvas.Polyline([Point(qrc.Right-1,qrc.Bottom-1),Point(qrc.Right-1,qrc.Top-1)]);
    end else
    begin
      if NeedRight
        then Canvas.Polyline([Point(qrc.Left,qrc.Bottom-1),Point(qrc.Right-1,qrc.Bottom-1),Point(qrc.Right-1,qrc.Top-1)])
        else Canvas.Polyline([Point(qrc.Left,qrc.Bottom-1),Point(qrc.Right,qrc.Bottom-1)]);
      if NeedLeft
        then DrawEdge(Canvas.Handle, qrc, ThreeDLine, TopLeftFlag)
        else DrawEdge(Canvas.Handle, qrc, ThreeDLine, BF_TOP);
    end;
  end else
  begin
    if IsSelected or IsDown
      then ThreeDLine := BDR_SUNKENINNER
      else ThreeDLine := BDR_RAISEDINNER;
    if NeedLeft and NeedRight then
      DrawEdge(Canvas.Handle, qrc, ThreeDLine, BF_RECT)
    else
    begin
      if NeedLeft
        then DrawEdge(Canvas.Handle, qrc, ThreeDLine, TopLeftFlag)
        else DrawEdge(Canvas.Handle, qrc, ThreeDLine, BF_TOP);
      if NeedRight
        then DrawEdge(Canvas.Handle, qrc, ThreeDLine, BottomRightFlag)
        else DrawEdge(Canvas.Handle, qrc, ThreeDLine, BF_BOTTOM);
    end;
  end;
  if UseRightToLeftAlignment then ChangeGridOrientation(True);
end;

procedure TCustomDBGridEh.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if Flat and (Ctl3D = True) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
      if (BorderStyle = bsSingle) then
        FBorderWidth := 1 else FBorderWidth := 0;
    end else
      FBorderWidth := 0;
  end;
end;

(*
procedure TCustomDBGridEh.AdjustClientRect(var Rect: TRect);
begin
  inherited AdjustClientRect(Rect);
  if Flat and (BorderStyle = bsSingle) and (Ctl3D = True) then
    InflateRect(Rect, -1, -1);
end;
*)

procedure TCustomDBGridEh.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  inherited;
  with Message.CalcSize_Params^ do
    InflateRect(rgrc[0], -FBorderWidth, -FBorderWidth);
end;

procedure TCustomDBGridEh.WMNCPaint(var Message: TMessage);
var
  DC: HDC;
  R: TRect;
begin
  inherited;
  if Flat and (BorderStyle = bsSingle) and (Ctl3D = True) then
  begin
    DC := GetWindowDC(Handle);
    try
      GetWindowRect(Handle,R);
      OffsetRect(R,-R.Left,-R.Top);
      //DrawEdge(DC, R,BDR_SUNKENOUTER, BF_TOPLEFT);
      //DrawEdge(DC, R,BDR_SUNKENOUTER, BF_BOTTOMRIGHT);
      DrawEdge(DC, R,BDR_SUNKENOUTER, BF_RECT);
    finally
      ReleaseDC(Handle, DC);
    end;
  end;
end;

procedure TCustomDBGridEh.StartInplaceSearchTimer;
begin
  if FInplaceSearchTimerActive then StopTimer;
  if FInplaceSearchTimeOut > -1 then
  begin
    SetTimer(Handle, 2, FInplaceSearchTimeOut, nil);
    FInplaceSearchTimerActive := True;
  end;
end;

procedure TCustomDBGridEh.StopInplaceSearchTimer;
begin
  if FInplaceSearchTimerActive
    then KillTimer(Handle, 2);
  FInplaceSearchTimerActive := False;
end;

procedure TCustomDBGridEh.RecreateInplaceSearchIndicator;
var
  Bmp: TBitmap;
  il: TImageList;
begin
  il := nil;
  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromResourceName(HInstance, bmEditWhite);
    il := TImageList.CreateSize(Bmp.Width, Bmp.Height);
    il.BkColor := DBGridEhInplaceSearchColor;
    if il.BkColor = clTeal then il.BkColor := TColor(RGB(0,127,127));
    il.AddMasked(Bmp, clWhite);
    il.GetBitmap(0,Bmp);
    if FIndicators.Count = 7 then FIndicators.Delete(6);
    FIndicators.AddMasked(Bmp, clTeal);
  finally
    il.Free;
    Bmp.Free;
  end;
end;

procedure TCustomDBGridEh.StartInplaceSearch(ss: String;
  TimeOut: Integer; InpsDirection: TInpsDirectionEh);
var NesSs,OldSs:String;
    RecordFounded:Boolean;

    function CheckEofBof:Boolean;
    begin
      if InpsDirection = inpsToPriorEh
        then Result := DataSource.DataSet.Bof
        else Result := DataSource.DataSet.Eof;
    end;

    procedure ToNextRec;
    begin
      if InpsDirection = inpsToPriorEh
        then DataSource.DataSet.Prior
        else DataSource.DataSet.Next;
    end;

begin
  if not DataLink.Active then Exit;
  NesSs := FInplaceSearchText + ss;
  OldSs := FInplaceSearchText;
  RecordFounded := False;
  if NesSs <> '' then
    with DataSource.DataSet do
      if (AnsiUpperCase(Copy(Columns[SelectedIndex].DisplayText,1,Length(NesSs))) =
         AnsiUpperCase(NesSs)) and (InpsDirection = inpsFromFirstEh) then
      begin
        NesSs := Copy(Columns[SelectedIndex].DisplayText,1,Length(NesSs));
        RecordFounded := True;
      end else
      begin
        DisableControls;
        SaveBookmark;
        try
          if InpsDirection = inpsFromFirstEh then First else ToNextRec;
          while not CheckEofBof do
          begin
            if AnsiUpperCase(Copy(Columns[SelectedIndex].DisplayText,1,Length(NesSs))) =
               AnsiUpperCase(NesSs) then
            begin
              NesSs := Copy(Columns[SelectedIndex].DisplayText,1,Length(NesSs));
              RecordFounded := True;
              //Resync([rmCenter]); Need to use other methods to center founded record
              Break;
            end;
            ToNextRec;
          end;
          if not RecordFounded then RestoreBookmark;
        finally
          FInplaceSearchingInProcess := True;
          try
            EnableControls;
          finally
            FInplaceSearchingInProcess := False;
          end;
        end;
      end;
  HideEditor;
  FInplaceSearching := True;
  if RecordFounded
    then FInplaceSearchText := NesSs
    else FInplaceSearchText := OldSs;
  GridInvalidateRow(Self,Row);
  FInplaceSearchTimeOut := TimeOut;
  StartInplaceSearchTimer;
end;

procedure TCustomDBGridEh.StopInplaceSearch;
begin
  StopInplaceSearchTimer;
  FInplaceSearching := False;
  FInplaceSearchText := '';
  GridInvalidateRow(Self,Row);
  if (dgAlwaysShowEditor in Options) then ShowEditor;
end;

function TCustomDBGridEh.InplaceEditorVisible: Boolean;
begin
  Result := (InplaceEditor <> nil) and (InplaceEditor.Visible);
end;

procedure TCustomDBGridEh.SetReadOnly(const Value: Boolean);
begin
  if Value <> FReadOnly then
  begin
    FReadOnly := Value;
    Invalidate();
  end;
end;

procedure TCustomDBGridEh.SetAllowedSelections(const Value: TDBGridEhAllowedSelections);
begin
  if FAllowedSelections <> Value then
  begin
    FAllowedSelections := Value;
    if (Selection.SelectionType <> gstNon) and
      not (Selection.SelectionType in FAllowedSelections)
      then Selection.Clear;
  end;
end;

function TCustomDBGridEh.CanSelectType(const Value: TDBGridEhSelectionType): Boolean;
begin
  Result := (Value = gstNon) or
            ((dgMultiSelect in Options) and (Value in AllowedSelections)
              and
              ( ((Value in [gstRectangle, gstColumns]) and not (dgRowSelect in Options))
                or
                (Value in [gstRecordBookmarks, gstAll])
              ));
end;

procedure TCustomDBGridEh.SetColumnDefValues(const Value: TColumnDefValuesEh);
begin
  FColumnDefValues.Assign(Value);
end;

{ TColumnFooterEh }

constructor TColumnFooterEh.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  if Assigned(Collection) and (Collection is TColumnFootersEh) then
    FColumn := TColumnFootersEh(Collection).Column;
  FFont := TFont.Create;
  FFont.Assign(DefaultFont);
  FFont.OnChange := FontChanged;
  if Assigned(FColumn) and Assigned(FColumn.Grid) then
    FColumn.Grid.InvalidateFooter;
end;

constructor TColumnFooterEh.CreateApart(Column: TColumnEh);
begin
  inherited Create(nil);
  FColumn := Column;
  FFont := TFont.Create;
  FFont.Assign(DefaultFont);
  FFont.OnChange := FontChanged;
end;

destructor TColumnFooterEh.Destroy;
begin
  if Assigned(FColumn) and Assigned(FColumn.Grid) then
    FColumn.Grid.InvalidateFooter;
  FFont.Free;
  if FDBSum <> nil then FDBSum.Free;
  inherited Destroy;
end;


procedure TColumnFooterEh.Assign(Source: TPersistent);
begin
  if Source is TColumnFooterEh then
  begin
    if cvFooterAlignment in FAssignedValues then
      Alignment := TColumnFooterEh(Source).Alignment;
    if cvFooterColor in FAssignedValues then
      Color := TColumnFooterEh(Source).Color;
    if cvFooterFont in FAssignedValues then
      Font := TColumnFooterEh(Source).Font;
    EndEllipsis := TColumnFooterEh(Source).EndEllipsis;
    ValueType := TColumnFooterEh(Source).ValueType;
    FieldName := TColumnFooterEh(Source).FieldName;
    Value := TColumnFooterEh(Source).Value;
    WordWrap := TColumnFooterEh(Source).WordWrap;
  end
  else
    inherited Assign(Source);
end;

function TColumnFooterEh.DefaultAlignment: TAlignment;
var
  Field: TField;
begin
  Field := FColumn.Field;
  if Assigned(Field)
    then Result := Field.Alignment
    else Result := taLeftJustify;
end;

function TColumnFooterEh.DefaultColor: TColor;
var
  Grid: TCustomDBGridEh;
begin
  Grid := FColumn.GetGrid;
  if Assigned(Grid)
    then Result := Grid.FooterColor
    else Result := clWindow;
end;

function TColumnFooterEh.DefaultFont: TFont;
var
  Grid: TCustomDBGridEh;
begin
  Grid := FColumn.GetGrid;
  if Assigned(Grid)
    then Result := Grid.FooterFont
    else Result := FColumn.Font;
end;

procedure TColumnFooterEh.FontChanged(Sender: TObject);
begin
  Include(FAssignedValues, cvFooterFont);
  FColumn.Changed(True);
end;

function TColumnFooterEh.GetAlignment: TAlignment;
begin
  if cvFooterAlignment in FAssignedValues
    then Result := FAlignment
    else Result := DefaultAlignment;
end;

function TColumnFooterEh.GetColor: TColor;
begin
  if cvFooterColor in FAssignedValues
    then Result := FColor
    else Result := DefaultColor;
end;

function TColumnFooterEh.GetFont: TFont;
var
  Save: TNotifyEvent;
  Def: TFont;
begin
  if not (cvFooterFont in FAssignedValues) then
  begin
    Def := DefaultFont;
    if (FFont.Handle <> Def.Handle) or (FFont.Color <> Def.Color) then
    begin
      Save := FFont.OnChange;
      FFont.OnChange := nil;
      FFont.Assign(DefaultFont);
      FFont.OnChange := Save;
    end;
  end;
  Result := FFont;
end;

function TColumnFooterEh.IsAlignmentStored: Boolean;
begin
  Result := (cvFooterAlignment in FAssignedValues) and
    (FAlignment <> DefaultAlignment);
end;

function TColumnFooterEh.IsColorStored: Boolean;
begin
  Result := (cvFooterColor in FAssignedValues) and
    (FColor <> DefaultColor);
end;

function TColumnFooterEh.IsFontStored: Boolean;
begin
  Result := (cvFooterFont in FAssignedValues);
end;

procedure TColumnFooterEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if (cvFooterFont in FAssignedValues) then Exit;
  Save := FFont.OnChange;
  FFont.OnChange := nil;
  try
    FFont.Assign(DefaultFont);
  finally
    FFont.OnChange := Save;
  end;
end;

procedure TColumnFooterEh.RestoreDefaults;
var
  FontAssigned: Boolean;
begin
  FontAssigned := cvFooterFont in FAssignedValues;
  FAssignedValues := [];
  RefreshDefaultFont;
  { If font was assigned, changing it back to default may affect grid title
    height, and title height changes require layout and redraw of the grid. }
  FColumn.Changed(FontAssigned);
end;

procedure TColumnFooterEh.SetAlignment(Value: TAlignment);
begin
  if (cvFooterAlignment in FAssignedValues) and (Value = FAlignment)
    then Exit;
  FAlignment := Value;
  Include(FAssignedValues, cvFooterAlignment);
  FColumn.Changed(False);
end;

procedure TColumnFooterEh.SetColor(Value: TColor);
begin
  if (cvFooterColor in FAssignedValues) and (Value = FColor)
    then Exit;
  FColor := Value;
  Include(FAssignedValues, cvFooterColor);
  FColumn.Changed(False);
end;

procedure TColumnFooterEh.SetEndEllipsis(const Value: Boolean);
begin
  FEndEllipsis := Value;
  FColumn.Changed(False);
end;

procedure TColumnFooterEh.SetFieldName(const Value: String);
begin
  FFieldName := Value;
  FColumn.EnsureSumValue;
  FColumn.Changed(False);
end;

procedure TColumnFooterEh.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TColumnFooterEh.SetValueType(const Value: TFooterValueType);
//var
//  Grid: TCustomDBGridEh;
begin
  if (ValueType = Value) then Exit;
  FValueType := Value;
  FColumn.EnsureSumValue;
///  Grid := FColumn.GetGrid;
//ddd  if Assigned(Grid) then
//ddd    Grid.EnsureFooterValueType(ValueType,FColumn.FieldName);
  FColumn.Changed(False);
end;

procedure TColumnFooterEh.SetValue(const Value: String);
begin
  FValue := Value;
  FColumn.Changed(False);
end;

procedure TColumnFooterEh.SetWordWrap(const Value: Boolean);
begin
  FWordWrap := Value;
  FColumn.Changed(False);
end;


procedure TColumnFooterEh.EnsureSumValue;
begin
  if not Assigned(FColumn) or not Assigned(FColumn.Grid) then
    Exit;
  if FDBSum = nil then
  begin
    if ValueType in [fvtSum..fvtCount] then
    begin
      FColumn.Grid.FSumList.SumCollection.BeginUpdate;
      FDBSum := (FColumn.Grid.FSumList.SumCollection.Add as TDBSum);
      case ValueType of
        fvtSum,fvtAvg:
          begin
            if ValueType = fvtSum
              then FDBSum.GroupOperation := goSum
              else  FDBSum.GroupOperation := goAvg;
            if FieldName <> ''
              then FDBSum.FieldName := FieldName
              else FDBSum.FieldName := FColumn.FieldName;
          end;
        fvtCount: FDBSum.GroupOperation := goCount;
      end;
      FColumn.Grid.FSumList.SumCollection.EndUpdate;
    end;
  end else
  begin
    case ValueType of
      fvtSum,fvtAvg:
        begin
          if ValueType = fvtSum
            then FDBSum.GroupOperation := goSum
            else  FDBSum.GroupOperation := goAvg;
          if FieldName <> ''
            then FDBSum.FieldName := FieldName
            else FDBSum.FieldName := FColumn.FieldName;
        end;
      fvtCount:
        begin
          FDBSum.GroupOperation := goCount;
          FDBSum.FieldName := '';
        end;
     else
       FDBSum.Free;
       FDBSum := nil;
     end;
  end;
end;

{ TColumnFootersEh }

constructor TColumnFootersEh.Create(Column: TColumnEh; FooterClass: TColumnFooterEhClass);
begin
  inherited Create(FooterClass);
  FColumn := Column;
end;

function TColumnFootersEh.Add: TColumnFooterEh;
begin
  Result := TColumnFooterEh(inherited Add);
end;

function TColumnFootersEh.GetFooter(Index: Integer): TColumnFooterEh;
begin
  Result := TColumnFooterEh(inherited Items[Index]);
end;

function TColumnFootersEh.GetOwner: TPersistent;
begin
  Result := FColumn;
end;

procedure TColumnFootersEh.SetFooter(Index: Integer; Value: TColumnFooterEh);
begin
  Items[Index].Assign(Value);
end;

procedure TColumnFootersEh.Update(Item: TCollectionItem);
begin
  inherited;
end;

{ TColumnTitleDefValuesEh }

procedure TColumnTitleDefValuesEh.Assign(Source: TPersistent);
begin
  if Source is TColumnTitleDefValuesEh then
  begin
    if cvdpTitleAlignmentEh in FAssignedValues then
      Alignment := TColumnTitleDefValuesEh(Source).Alignment;
    if cvdpTitleColorEh in FAssignedValues then
      Color := TColumnTitleDefValuesEh(Source).Color;
    EndEllipsis := TColumnTitleDefValuesEh(Source).EndEllipsis;
    TitleButton := TColumnTitleDefValuesEh(Source).TitleButton;
    ToolTips := TColumnTitleDefValuesEh(Source).ToolTips;
    Orientation := TColumnTitleDefValuesEh(Source).Orientation;
  end else
    inherited Assign(Source);
end;

constructor TColumnTitleDefValuesEh.Create(ColumnDefValues: TColumnDefValuesEh);
begin
  FColumnDefValues := ColumnDefValues;
end;

function TColumnTitleDefValuesEh.DefaultAlignment: TAlignment;
begin
  if FColumnDefValues.FGrid.UseMultiTitle
    then Result := taCenter
    else Result := taLeftJustify;
end;

function TColumnTitleDefValuesEh.DefaultColor: TColor;
begin
  Result := FColumnDefValues.FGrid.FixedColor;
end;

function TColumnTitleDefValuesEh.GetAlignment: TAlignment;
begin
  if cvdpTitleAlignmentEh in FAssignedValues
    then Result := FAlignment
    else Result := DefaultAlignment;
end;

function TColumnTitleDefValuesEh.GetColor: TColor;
begin
  if cvdpTitleColorEh in FAssignedValues
    then Result := FColor
    else Result := DefaultColor;
end;

function TColumnTitleDefValuesEh.IsAlignmentStored: Boolean;
begin
  Result := (cvdpTitleAlignmentEh in FAssignedValues) and (FAlignment <> DefaultAlignment);
end;

function TColumnTitleDefValuesEh.IsColorStored: Boolean;
begin
  Result := (cvdpTitleColorEh in FAssignedValues) and (FColor <> DefaultColor);
end;

procedure TColumnTitleDefValuesEh.SetAlignment(const Value: TAlignment);
begin
  if (cvdpTitleAlignmentEh in FAssignedValues) and (Value = FAlignment) then Exit;
  FAlignment := Value;
  Include(FAssignedValues, cvdpTitleAlignmentEh);
  FColumnDefValues.FGrid.LayoutChanged;
end;

procedure TColumnTitleDefValuesEh.SetColor(const Value: TColor);
begin
  if (cvdpTitleColorEh in FAssignedValues) and (Value = FColor) then Exit;
  FColor := Value;
  Include(FAssignedValues, cvdpTitleColorEh);
  FColumnDefValues.FGrid.Invalidate;
end;

procedure TColumnTitleDefValuesEh.SetEndEllipsis(const Value: Boolean);
begin
  if FEndEllipsis <> Value then
  begin
    FEndEllipsis := Value;
    FColumnDefValues.FGrid.Invalidate;
  end;
end;

procedure TColumnTitleDefValuesEh.SetOrientation(const Value: TTextOrientationEh);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    FColumnDefValues.FGrid.LayoutChanged;
  end;
end;

{ TColumnDefValuesEh }

constructor TColumnDefValuesEh.Create(Grid: TCustomDBGridEh);
begin
  FGrid := Grid;
  FTitle := TColumnTitleDefValuesEh.Create(Self);
end;

destructor TColumnDefValuesEh.Destroy;
begin
  FTitle.Free;
  inherited;
end;

procedure TColumnDefValuesEh.Assign(Source: TPersistent);
begin
  if Source is TColumnDefValuesEh then
  begin
    Title := TColumnDefValuesEh(Source).Title;
    AlwaysShowEditButton := TColumnDefValuesEh(Source).AlwaysShowEditButton;
    EndEllipsis := TColumnDefValuesEh(Source).EndEllipsis;
    AutoDropDown := TColumnDefValuesEh(Source).AutoDropDown;
    DblClickNextVal := TColumnDefValuesEh(Source).DblClickNextVal;
    ToolTips := TColumnDefValuesEh(Source).ToolTips;
    DropDownSizing := TColumnDefValuesEh(Source).DropDownSizing;
    DropDownShowTitles := TColumnDefValuesEh(Source).DropDownShowTitles;
  end else
    inherited Assign(Source);
end;

procedure TColumnDefValuesEh.SetAlwaysShowEditButton(const Value: Boolean);
begin
  if FAlwaysShowEditButton <> Value then
  begin
    FAlwaysShowEditButton := Value;
    FGrid.Invalidate;
  end;
end;

procedure TColumnDefValuesEh.SetEndEllipsis(const Value: Boolean);
begin
  if FEndEllipsis <> Value then
  begin
    FEndEllipsis := Value;
    FGrid.Invalidate;
  end;
end;

procedure TColumnDefValuesEh.SetTitle(const Value: TColumnTitleDefValuesEh);
begin
  FTitle.Assign(Value);
end;

{ TDBGridEhSumList }

constructor TDBGridEhSumList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDesignTimeWork := True;
  Active := False;
end;

function TDBGridEhSumList.GetActive: Boolean;
begin
 Result := inherited Active;
end;

procedure TDBGridEhSumList.SetActive(const Value: Boolean);
begin
  inherited Active := Value;
end;

procedure TDBGridEhSumList.SetDataSetEvents;
begin
  if not (csDesigning in (FOwner as TCustomDBGridEh).ComponentState)
    then inherited SetDataSetEvents
    else FEventsOverloaded := True;
end;

procedure TDBGridEhSumList.ReturnEvents;
begin
  if not (csDesigning in (FOwner as TCustomDBGridEh).ComponentState)
    then inherited ReturnEvents
    else FEventsOverloaded := False;
end;

{ TColumnsEhList }

function TColumnsEhList.GetColumn(Index: Integer): TColumnEh;
begin
  Result := Get(Index);
end;

procedure TColumnsEhList.SetColumn(Index: Integer; const Value: TColumnEh);
begin
  Put(Index,Value);
end;

{ TControlScrollBarEh }

constructor TDBGridEhScrollBar.Create(AGrid: TCustomDBGridEh;
  AKind: TScrollBarKind);
begin
  FDBGridEh := AGrid;
  FKind := AKind;
  FVisible := True;
end;

procedure TDBGridEhScrollBar.Assign(Source: TPersistent);
begin
  if Source is TDBGridEhScrollBar then
  begin
    Visible := TControlScrollBar(Source).Visible;
    Tracking := TControlScrollBar(Source).Tracking;
  end
  else inherited Assign(Source);
end;

procedure TDBGridEhScrollBar.SetVisible(Value: Boolean);
begin
  if (FVisible = Value) then Exit;
  FVisible := Value;
  if Assigned(FDBGridEh) and (Kind = sbVertical) then FDBGridEh.UpdateScrollBar;
  if Assigned(FDBGridEh) then FDBGridEh.LayoutChanged;
end;

function TDBGridEhScrollBar.IsScrollBarVisible: Boolean;
var
  Style: Longint;
begin
  Style := WS_HSCROLL;
  if Kind = sbVertical then Style := WS_VSCROLL;
  Result := (Visible) and
            ((GetWindowLong(FDBGridEh.Handle, GWL_STYLE) and Style) <> 0);
end;

var Bmp:TBitmap;

{ TDBGridEhSelection }

function TDBGridEhSelection.DataCellSelected(DataCol :Longint; DataRow :TBookmarkStr):Boolean;
var
  Index: Integer;
begin
  Result := False;
  case SelectionType of
   gstAll:
     Result := True;
   gstRecordBookmarks:
     Result := Rows.Find(DataRow, Index);
   gstRectangle:
     if DataCol >= 0 then
       Result := Rect.DataCellSelected(DataCol,DataRow);
   gstColumns:
     if DataCol >= 0 then
       Result := (Columns.IndexOf(FGrid.Columns[DataCol]) <> -1);
  end;
end;

procedure TDBGridEhSelection.Clear;
begin
  try
    case SelectionType of
     gstRecordBookmarks:
       Rows.Clear;
     gstRectangle:
       FRect.Clear;           
     gstColumns:
       Columns.Clear;
     gstAll:
       FGrid.Invalidate;
    end;
  finally
    FSelectionType := gstNon;
    if dgAlwaysShowEditor in FGrid.Options then
      FGrid.ShowEditor;
  end;
end;

constructor TDBGridEhSelection.Create(AGrid: TCustomDBGridEh);
begin
  inherited Create;
  FGrid := AGrid;
  FColumns := TDBGridEhSelectionCols.Create(AGrid);
  FRect := TDBGridEhSelectionRect.Create(AGrid);
end;

destructor TDBGridEhSelection.Destroy;
begin
  FColumns.Free;
  FRect.Free;
  inherited;
end;

function TDBGridEhSelection.GetRows: TBookmarkListEh;
begin
  Result := FGrid.SelectedRows;
end;

procedure TDBGridEhSelection.LinkActive(Value: Boolean);
begin
  FGrid.SelectedRows.LinkActive(Value);
  Clear;
end;

procedure TDBGridEhSelection.Refresh;
begin
  case SelectionType of
    gstRecordBookmarks:
      FGrid.SelectedRows.Refresh;
    gstRectangle:
    begin
//      FRect := BlankRect;
    end;
    gstColumns:
      if Columns.Count = 0 then  begin
        FSelectionType := gstNon;
        FGrid.Invalidate;
      end;
   end;
end;

procedure TDBGridEhSelection.SelectAll;
begin
  if SelectionType = gstAll then Exit;
  if SelectionType <> gstNon then Clear;
  FSelectionType := gstAll;
  FGrid.Invalidate;
end;

procedure TDBGridEhSelection.SetSelectionType(ASelType: TDBGridEhSelectionType);
begin
  if FSelectionType = ASelType then Exit;
  FSelectionType := ASelType;
  if (ASelType = gstNon) and (dgAlwaysShowEditor in FGrid.Options)
    then FGrid.ShowEditor
    else FGrid.HideEditor;
end;

procedure TDBGridEhSelection.UpdateState;
begin
  case SelectionType of
    gstRecordBookmarks:
      if FGrid.SelectedRows.Count = 0 then
      begin
        FSelectionType := gstNon;
        FGrid.Invalidate;
      end;
    gstRectangle:
    begin
//      FRect := BlankRect;
    end;
    gstColumns:
      if Columns.Count = 0 then
      begin
        FSelectionType := gstNon;
        FGrid.Invalidate;
      end;
   end;
end;

{ TDBGridEhSelectionCols }

procedure TDBGridEhSelectionCols.Add(ACol: TColumnEh);
var i:Integer;
begin
  for i := 0 to Count-1 do
    if ACol.Index < Items[i].Index then
    begin
      Insert(i,ACol);
      Exit;
    end;
  inherited Add(ACol);
end;

procedure TDBGridEhSelectionCols.Clear;
var i:Integer;
begin
//  Refresh;
  for i := 0 to Count-1 do
    FGrid.InvalidateCol(FGrid.DataToRawColumn(Items[i].Index));
  inherited Clear;
  FAnchor := nil;
end;

constructor TDBGridEhSelectionCols.Create(AGrid:TCustomDBGridEh);
begin
  FAnchor := nil;
  FGrid := AGrid;
  FShiftSelectedCols := TColumnsEhList.Create;
end;

destructor TDBGridEhSelectionCols.Destroy;
begin
  FShiftSelectedCols.Free;
end;

{function TDBGridEhSelectionCols.Get(Index: Integer): TColumnEh;
begin
  Result := inherited Items[Index];
end;}

procedure TDBGridEhSelectionCols.InvertSelect(ACol: TColumnEh);
begin
  if FGrid.Selection.SelectionType <> gstColumns
    then FGrid.Selection.Clear;
  if IndexOf(ACol) = -1 then
  begin
    Add(ACol);
    FAnchor := ACol;
    FShiftCol := ACol;
  end
  else
  begin
    Remove(Pointer(ACol));
    FAnchor := ACol;
    FShiftCol := ACol;
  end;
  if Count = 0
    then FGrid.Selection.SetSelectionType(gstNon)
    else FGrid.Selection.SetSelectionType(gstColumns);
  FShiftSelectedCols.Clear;
end;

{procedure TDBGridEhSelectionCols.Put(Index: Integer; const Value: TColumnEh);
begin
  inherited Items[Index] := Value;
end;}

procedure TDBGridEhSelectionCols.Refresh;
var i,j:Integer;
    Found:Boolean;
  function CompareColums(Item1, Item2: Pointer): Integer;
  begin
    if TColumnEh(Item1).Index > TColumnEh(Item2).Index then
      Result := 1
    else if TColumnEh(Item1).Index < TColumnEh(Item2).Index then
      Result := -1
    else
      Result := 0;
  end;
begin
  for i := Count-1 downto 0 do
  begin
    Found := False;
    for j := 0 to FGrid.Columns.Count-1 do
      if FGrid.Columns[j] = Items[i] then
      begin
        Found := True;
        Break;
      end;
    if not Found then Delete(i);
  end;
  Sort(@CompareColums);
end;

procedure TDBGridEhSelectionCols.Select(ACol: TColumnEh; AddSel:Boolean);
begin
  if FGrid.Selection.SelectionType <> gstColumns then FGrid.Selection.Clear;
  if not AddSel then Clear;
  if IndexOf(ACol) = -1 then Add(ACol);
  FAnchor := ACol;
  FShiftCol := ACol;
  FGrid.Selection.SetSelectionType(gstColumns);
  FShiftSelectedCols.Clear;
end;

procedure TDBGridEhSelectionCols.SelectShift(ACol: TColumnEh{; Clear:Boolean});
var i:Integer;
    Step:Integer;
    FromIndex,ToIndex,RemoveIndex:Integer;
    NeedAdd:Boolean;
begin
//  FGrid.Invalidate; //tmp
  if FGrid.Selection.SelectionType <> gstColumns then FGrid.Selection.Clear;
  RemoveIndex := -1;
  Step := 1;
  NeedAdd := True;
  FromIndex := ACol.Index; ToIndex := ACol.Index;
  if FAnchor = nil then
  begin
    Select(ACol,True);
    FAnchor := ACol;
  end else
  begin
    if (FAnchor.Index < FShiftCol.Index) then
    begin
      if (FShiftCol.Index < ACol.Index) then
      begin
        FromIndex := FShiftCol.Index;
        ToIndex := ACol.Index;
        NeedAdd := True;
      end else if (FShiftCol.Index > ACol.Index) then
      begin
        FromIndex := FShiftCol.Index;
        if FAnchor.Index > ACol.Index then
          RemoveIndex := FAnchor.Index;
        ToIndex := ACol.Index + iif(RemoveIndex<>-1,0,1);
        Step := -1;
        NeedAdd := False;
      end
    end
    else if (FAnchor.Index > FShiftCol.Index) then
    begin
      if (FShiftCol.Index > ACol.Index) then
      begin
        FromIndex := FShiftCol.Index;
        ToIndex := ACol.Index;
        Step := -1;
        NeedAdd := True;
      end else if (FShiftCol.Index < ACol.Index) then
      begin
        FromIndex := FShiftCol.Index;
        if FAnchor.Index < ACol.Index then
          RemoveIndex := FAnchor.Index;
        ToIndex := ACol.Index - iif(RemoveIndex<>-1,0,1);
        NeedAdd := False;
      end;
    end else
    begin
      FromIndex := FAnchor.Index;
      if FAnchor.Index > ACol.Index then
        Step := -1;
    end;
    i := FromIndex;
//    if Clear then Clear := IndexOf(FGrid.Columns[FAnchor.Index]) = -1;
    while True do
    begin
      if i = RemoveIndex then NeedAdd := not NeedAdd;
      {if NeedAdd and not Clear then begin
        if (IndexOf(FGrid.Columns[i]) = -1) and FGrid.Columns[i].Visible then begin
          Add(FGrid.Columns[i]);
          FGrid.InvalidateCol(FGrid.DataToRawColumn(FGrid.Columns[i].Index));
        end
      end else begin
        if (IndexOf(FGrid.Columns[i]) <> -1) and (i <> FAnchor.Index) then begin
          Remove(FGrid.Columns[i]);
          FGrid.InvalidateCol(FGrid.DataToRawColumn(FGrid.Columns[i].Index));
        end;
      end;}
      if NeedAdd then
      begin
        if IndexOf(FGrid.Columns[FAnchor.Index]) <> -1 then
        begin
          if (IndexOf(FGrid.Columns[i]) = -1) and FGrid.Columns[i].Visible then
          begin
            Add(FGrid.Columns[i]);
            FGrid.InvalidateCol(FGrid.DataToRawColumn(FGrid.Columns[i].Index));
            FShiftSelectedCols.Add(FGrid.Columns[i]);
          end;
        end else
        begin
          if (IndexOf(FGrid.Columns[i]) <> -1) and (i <> FAnchor.Index) then
          begin
            Remove(FGrid.Columns[i]);
            FGrid.InvalidateCol(FGrid.DataToRawColumn(FGrid.Columns[i].Index));
            FShiftSelectedCols.Add(FGrid.Columns[i]);
          end;
        end
      end else
      begin
        if IndexOf(FGrid.Columns[FAnchor.Index]) <> -1 then
        begin
          if (IndexOf(FGrid.Columns[i]) <> -1) and (i <> FAnchor.Index) then
          begin
            if FShiftSelectedCols.IndexOf(FGrid.Columns[i]) <> -1 then
            begin
              Remove(FGrid.Columns[i]);
              FShiftSelectedCols.Remove(FGrid.Columns[i]);
            end;
            FGrid.InvalidateCol(FGrid.DataToRawColumn(FGrid.Columns[i].Index));
          end;
        end else
        begin
          if (IndexOf(FGrid.Columns[i]) = -1) and FGrid.Columns[i].Visible then
          begin
            if FShiftSelectedCols.IndexOf(FGrid.Columns[i]) <> -1 then
            begin
              Add(FGrid.Columns[i]);
              FShiftSelectedCols.Remove(FGrid.Columns[i]);
            end;
            FGrid.InvalidateCol(FGrid.DataToRawColumn(FGrid.Columns[i].Index));
          end;
        end
      end;
      if i = ToIndex then Break;
      Inc(i,Step);
    end;
  end;
  FShiftCol := ACol;
  if Count = 0
    then FGrid.Selection.SetSelectionType(gstNon)
    else FGrid.Selection.SetSelectionType(gstColumns);
end;

{ TDBGridEhSelectionRect }

function TDBGridEhSelectionRect.BoxRect(ALeft: Integer; ATop: TBookmarkStr;
  ARight: Integer; ABottom: TBookmarkStr): TRect;
var OldRec: Integer;
    TopGridBM,BottomGridBM: TBookmarkStr;
    TopRow,BottomRow: Integer;
    SwapCol: Integer;
    SwapBM: TBookmarkStr;

    function FindRecNumByBookmark(BM:TBookmarkStr):Integer;
    var i:Integer;
    begin
      Result := -1;
      for i := 0 to FGrid.FDataLink.RecordCount-1 do
      begin
        FGrid.FDataLink.ActiveRecord := i;
        with FGrid.DataSource.DataSet do
          if CompareBookmarks(Pointer(BM),Pointer(Bookmark)) = 0 then
          begin
            Result := i;
            Break;
          end;
      end;
    end;
begin
  if ALeft > ARight then
  begin
    SwapCol := ALeft;
    ALeft := ARight;
    ARight := SwapCol;
  end;
  if FGrid.DataSource.DataSet.CompareBookmarks(Pointer(ATop),Pointer(ABottom)) > 0 then
  begin
    SwapBM := ATop;
    ATop := ABottom;
    ABottom := SwapBM;
  end;
  OldRec := FGrid.FDataLink.ActiveRecord;
  try
    FGrid.FDataLink.ActiveRecord := 0;
    TopGridBM := FGrid.DataSource.DataSet.Bookmark;
    if FGrid.DataSource.DataSet.CompareBookmarks(Pointer(ATop),Pointer(TopGridBM)) < 0 then
      TopRow := 0
    else begin
      TopRow := FindRecNumByBookmark(ATop);
    end;
    if TopRow = -1 then TopRow := FGrid.FDataLink.RecordCount;
    TopRow := TopRow + FGrid.TitleOffset;

    FGrid.FDataLink.ActiveRecord := FGrid.FDataLink.RecordCount-1;
    BottomGridBM := FGrid.DataSource.DataSet.Bookmark;

    if FGrid.DataSource.DataSet.CompareBookmarks(Pointer(ABottom),Pointer(BottomGridBM)) > 0 then
      BottomRow := FGrid.VisibleDataRowCount
    else begin
      BottomRow := FindRecNumByBookmark(ABottom);
    end;
    BottomRow := BottomRow + FGrid.TitleOffset;// - 1;
  finally
    FGrid.FDataLink.ActiveRecord := OldRec;
  end;

  Result := FGrid.BoxRect(FGrid.DataToRawColumn(ALeft),TopRow,
                          FGrid.DataToRawColumn(ARight),BottomRow);
//
end;

function TDBGridEhSelectionRect.DataCellSelected(DataCol: Integer; DataRow: TBookmarkStr): Boolean;
begin
  Result := False;
  if CheckState then
      Result := (FGrid.DataSource.DataSet.CompareBookmarks(TBookmark(TopRow),
                                                           TBookmark(DataRow)) <= 0) and
                (FGrid.DataSource.DataSet.CompareBookmarks(TBookmark(BottomRow),
                                                           TBookmark(DataRow)) >= 0) and
                (RightCol >= DataCol) and (LeftCol <= DataCol)
  else
    RaiseGridError('Error in function TDBGridEhSelectionRect.CellSelected');
end;

function TDBGridEhSelectionRect.CheckState: Boolean;
begin
  Result :=
  Assigned(FGrid.DataSource) and
     Assigned(FGrid.DataSource.DataSet) and
     FGrid.DataLink.Active {and
     {(FAnchor.Row <> '') and (FShiftCell.Row <> '') and
     (FShiftCell.Row <> '') and (FShiftCell.Row <> '') ???};
end;

procedure TDBGridEhSelectionRect.Clear;
begin
 FAnchor.Col := -1;
 FAnchor.Row := '';
 FShiftCell.Col := -1;
 FShiftCell.Row := '';
 FGrid.Invalidate;
end;

constructor TDBGridEhSelectionRect.Create(AGrid: TCustomDBGridEh);
begin
  FAnchor.Col := -1;
  FAnchor.Row := '';
  FShiftCell.Col := -1;
  FShiftCell.Row := '';
  FGrid := AGrid;
end;

function TDBGridEhSelectionRect.GetBottomRow: TBookmarkStr;
begin
  if CheckState then
    if FGrid.DataSource.DataSet.CompareBookmarks(TBookmark(FAnchor.Row),
                                                TBookmark(FShiftCell.Row)) < 0
      then Result := FShiftCell.Row
      else Result := FAnchor.Row
  else
    RaiseGridError('Error in TDBGridEhSelectionRect.GetBottomRow');
end;

function TDBGridEhSelectionRect.GetLeftCol: Longint;
begin
  Result := -1;
  if CheckState then
    if FShiftCell.Col < FAnchor.Col
      then Result := FShiftCell.Col
      else Result := FAnchor.Col
  else
    RaiseGridError('Error in TDBGridEhSelectionRect.GetBottomRow');
end;

function TDBGridEhSelectionRect.GetRightCol: Longint;
begin
  Result := -1;
  if CheckState then
    if FShiftCell.Col > FAnchor.Col
      then Result := FShiftCell.Col
      else Result := FAnchor.Col
  else
    RaiseGridError('Error in TDBGridEhSelectionRect.GetBottomRow');
end;

function TDBGridEhSelectionRect.GetTopRow: TBookmarkStr;
begin
  if CheckState then
    if FGrid.DataSource.DataSet.CompareBookmarks(TBookmark(FAnchor.Row),
                                                TBookmark(FShiftCell.Row)) > 0
      then Result := FShiftCell.Row
      else Result := FAnchor.Row
  else
    RaiseGridError('Error in TDBGridEhSelectionRect.GetBottomRow');
end;

// XorRects from Grids.pas
type
  TXorRects = array[0..3] of TRect;

procedure XorRects(const R1, R2: TRect; var XorRects: TXorRects);
var
  Intersect, Union: TRect;

  function PtInRect(X, Y: Integer; const Rect: TRect): Boolean;
  begin
    with Rect do Result := (X >= Left) and (X <= Right) and (Y >= Top) and
      (Y <= Bottom);
  end;

  function Includes(const P1: TPoint; var P2: TPoint): Boolean;
  begin
    with P1 do
    begin
      Result := PtInRect(X, Y, R1) or PtInRect(X, Y, R2);
      if Result then P2 := P1;
    end;
  end;

  function Build(var R: TRect; const P1, P2, P3: TPoint): Boolean;
  begin
    Build := True;
    with R do
      if Includes(P1, TopLeft) then
      begin
        if not Includes(P3, BottomRight) then BottomRight := P2;
      end
      else if Includes(P2, TopLeft) then BottomRight := P3
      else Build := False;
  end;

begin
  FillChar(XorRects, SizeOf(XorRects), 0);
  if not Bool(IntersectRect(Intersect, R1, R2)) then
  begin
    { Don't intersect so its simple }
    XorRects[0] := R1;
    XorRects[1] := R2;
  end
  else
  begin
    UnionRect(Union, R1, R2);
    if Build(XorRects[0],
      Point(Union.Left, Union.Top),
      Point(Union.Left, Intersect.Top),
      Point(Union.Left, Intersect.Bottom)) then
      XorRects[0].Right := Intersect.Left;
    if Build(XorRects[1],
      Point(Intersect.Left, Union.Top),
      Point(Intersect.Right, Union.Top),
      Point(Union.Right, Union.Top)) then
      XorRects[1].Bottom := Intersect.Top;
    if Build(XorRects[2],
      Point(Union.Right, Intersect.Top),
      Point(Union.Right, Intersect.Bottom),
      Point(Union.Right, Union.Bottom)) then
      XorRects[2].Left := Intersect.Right;
    if Build(XorRects[3],
      Point(Union.Left, Union.Bottom),
      Point(Intersect.Left, Union.Bottom),
      Point(Intersect.Right, Union.Bottom)) then
      XorRects[3].Top := Intersect.Bottom;
  end;
end;

procedure TDBGridEhSelectionRect.Select(ACol :Longint; ARow :TBookmarkStr; AddSel: Boolean);
var OldAnchor, OldShiftCell:TDBCell;
    OldRect, NewRect: TRect;
    AXorRects: TXorRects;
    I: Integer;
begin
  if FGrid.Selection.SelectionType <> gstRectangle then FGrid.Selection.Clear;
  OldAnchor := FAnchor;
  OldShiftCell := FShiftCell;
  if (FAnchor.Col = -1) or not AddSel then
  begin
    FAnchor.Col := ACol;
    FAnchor.Row := ARow;
    FShiftCell.Col := ACol;
    FShiftCell.Row := ARow;
  end else
  begin
    FShiftCell.Col := ACol;
    FShiftCell.Row := ARow;
  end;
  if (FAnchor.Col <> FShiftCell.Col) or
     (FGrid.DataSource.DataSet.CompareBookmarks(TBookmark(FAnchor.Row),
                                                TBookmark(FShiftCell.Row)) <> 0) then
    FGrid.Selection.SetSelectionType(gstRectangle)
  else if FGrid.Selection.SelectionType = gstRectangle then
  begin
    FGrid.Selection.SetSelectionType(gstNon);
//    FAnchor.Col := -1;
  end;

  if not FGrid.HandleAllocated then Exit;
  OldRect := BoxRect(OldAnchor.Col,OldAnchor.Row,OldShiftCell.Col,OldShiftCell.Row);
  NewRect := BoxRect(FAnchor.Col,FAnchor.Row,FShiftCell.Col,FShiftCell.Row);
  XorRects(OldRect, NewRect, AXorRects);
  for I := Low(AXorRects) to High(AXorRects) do
    Windows.InvalidateRect(FGrid.Handle, @AXorRects[I], False);
//  FGrid.Invalidate;
  FGrid.DoOnSelectionChange;

end;

procedure TCustomDBGridEh.DoOnSelectionChange;
begin
  if Assigned(OnSelectionChange) then
    try
      OnSelectionChange(Self);
    except

    end;
end;


initialization
  SortMarkerFont := TFont.Create;
  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromResourceName(HInstance, bmSmDown);
    SortMarkerFont.Height := -Bmp.Height+1;
    SortMarkerFont.Name := 'Arial';
  finally
    Bmp.Free;
  end;
  GetCheckSize;

  hcrDownCurEh := LoadCursor(hInstance, 'DOWNCUREH');
  if hcrDownCurEh = 0 then
    raise EOutOfResources.Create('Cannot load cursor resource');

  hcrRightCurEh := LoadCursor(hInstance, 'RIGHTCUREH');
  if hcrRightCurEh= 0 then
    raise EOutOfResources.Create('Cannot load cursor resource');

  hcrLeftCurEh :=  LoadCursor(hInstance, 'LEFTCUREH');
  if hcrLeftCurEh = 0 then
    raise EOutOfResources.Create('Cannot load cursor resource');

  DBGridEhInplaceSearchKey := ShortCut(Word('F'), [ssCtrl]);
  DBGridEhInplaceSearchNextKey := ShortCut(VK_RETURN, [ssCtrl]);
  DBGridEhInplaceSearchPriorKey := ShortCut(VK_RETURN, [ssCtrl,ssShift]);
  DBGridEhInplaceSearchTimeOut := 1500; // 1.5 sec
  DBGridEhInplaceSearchColor := clYellow;
  DBGridEhInplaceSearchTextColor := clBlack;

{ crDownCurEh := DefineCursor('DOWNCUREH');
 crRightCurEh := DefineCursor('RIGHTCUREH');}
// SystemParametersInfo(SPI_GETKEYBOARDDELAY,0,@InitRepeatPause,0);
// SystemParametersInfo(SPI_GETKEYBOARDSPEED,0,@RepeatPause,0);
finalization
  SortMarkerFont.Free;
end.
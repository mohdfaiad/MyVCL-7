object fmMain: TfmMain
  Left = 222
  Top = 156
  Width = 696
  Height = 491
  Caption = 'ExpressMasterView - Runtime styles demo'
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MasterView: TdxMasterView
    Left = 0
    Top = 0
    Width = 688
    Height = 376
    Align = alClient
    TabOrder = 0
    object Style1: TdxMasterViewStyle
      Color = 16577485
      AssignedValues = [svColor]
    end
    object Style2: TdxMasterViewStyle
      Color = 8454143
      AssignedValues = [svColor]
    end
    object GroupStyle1: TdxMasterViewStyle
      Color = 12348214
      AssignedValues = [svColor]
    end
    object GroupStyle2: TdxMasterViewStyle
      Color = 13999443
      AssignedValues = [svColor]
    end
    object GroupStyle3: TdxMasterViewStyle
      Color = 14727819
      AssignedValues = [svColor]
    end
    object Level1: TdxMasterViewLevel
      DataSource = DataSource1
      ID = 'OrderNo'
      OptionsCustomize = [locColumnMoving, locColumnHorSizing, locColumnVerSizing, locColumnSorting, locColumnGrouping, locHideColumnOnGrouping, locShowColumnOnUngrouping]
      OptionsView = [lovGrid, lovGridWithPreview, lovGroupByBox, lovHeader, lovOccupyRestSpace]
      OnGetContentStyle = Level1GetContentStyle
      OnGetGroupStyle = Level1GetGroupStyle
      object dxMasterView1Level1OrderNo: TdxMasterViewColumn
        FieldName = 'OrderNo'
        RowIndex = 0
        ColIndex = 0
      end
      object dxMasterView1Level1CustNo: TdxMasterViewColumn
        FieldName = 'CustNo'
        RowIndex = 0
        ColIndex = 1
      end
      object dxMasterView1Level1SaleDate: TdxMasterViewColumn
        FieldName = 'SaleDate'
        RowIndex = 0
        ColIndex = 2
      end
      object dxMasterView1Level1ShipDate: TdxMasterViewColumn
        FieldName = 'ShipDate'
        RowIndex = 0
        ColIndex = 3
      end
      object dxMasterView1Level1EmpNo: TdxMasterViewColumn
        FieldName = 'EmpNo'
        RowIndex = 0
        ColIndex = 4
      end
      object dxMasterView1Level1ShipToContact: TdxMasterViewColumn
        FieldName = 'ShipToContact'
        RowIndex = 0
        ColIndex = 7
      end
      object dxMasterView1Level1ShipToAddr1: TdxMasterViewColumn
        FieldName = 'ShipToAddr1'
        RowIndex = 0
        ColIndex = 8
      end
      object dxMasterView1Level1ShipToAddr2: TdxMasterViewColumn
        FieldName = 'ShipToAddr2'
        RowIndex = 0
        ColIndex = 9
      end
      object dxMasterView1Level1ShipToCity: TdxMasterViewColumn
        FieldName = 'ShipToCity'
        RowIndex = 0
        ColIndex = 10
      end
      object dxMasterView1Level1ShipToState: TdxMasterViewColumn
        FieldName = 'ShipToState'
        RowIndex = 0
        ColIndex = 11
      end
      object dxMasterView1Level1ShipToZip: TdxMasterViewColumn
        FieldName = 'ShipToZip'
        RowIndex = 0
        ColIndex = 12
      end
      object dxMasterView1Level1ShipToCountry: TdxMasterViewColumn
        FieldName = 'ShipToCountry'
        RowIndex = 0
        ColIndex = 13
      end
      object dxMasterView1Level1ShipToPhone: TdxMasterViewColumn
        FieldName = 'ShipToPhone'
        RowIndex = 0
        ColIndex = 14
      end
      object dxMasterView1Level1ShipVIA: TdxMasterViewColumn
        FieldName = 'ShipVIA'
        RowIndex = 0
        ColIndex = 15
      end
      object dxMasterView1Level1PO: TdxMasterViewColumn
        FieldName = 'PO'
        RowIndex = 0
        ColIndex = 16
      end
      object dxMasterView1Level1Terms: TdxMasterViewColumn
        FieldName = 'Terms'
        RowIndex = 0
        ColIndex = 17
      end
      object dxMasterView1Level1PaymentMethod: TdxMasterViewColumn
        FieldName = 'PaymentMethod'
        RowIndex = 0
        ColIndex = 5
      end
      object dxMasterView1Level1ItemsTotal: TdxMasterViewColumn
        FieldName = 'ItemsTotal'
        RowIndex = 0
        ColIndex = 18
      end
      object dxMasterView1Level1TaxRate: TdxMasterViewColumn
        FieldName = 'TaxRate'
        RowIndex = 0
        ColIndex = 19
      end
      object dxMasterView1Level1Freight: TdxMasterViewColumn
        FieldName = 'Freight'
        RowIndex = 0
        ColIndex = 20
      end
      object dxMasterView1Level1AmountPaid: TdxMasterViewColumn
        FieldName = 'AmountPaid'
        RowIndex = 0
        ColIndex = 6
        OnGetContentStyle = dxMasterView1Level1AmountPaidGetContentStyle
      end
    end
  end
  object plBottom: TPanel
    Left = 0
    Top = 376
    Width = 688
    Height = 88
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 175
      Height = 13
      Caption = 'The node style will be set depending '
    end
    object Label2: TLabel
      Left = 8
      Top = 24
      Width = 171
      Height = 13
      Caption = 'upon the PaymentMethod meaning  '
    end
    object Label3: TLabel
      Left = 240
      Top = 8
      Width = 203
      Height = 13
      Caption = 'The AmoundPaid column style will be set if '
    end
    object Label4: TLabel
      Left = 240
      Top = 24
      Width = 208
      Height = 13
      Caption = 'its value is more than the predetermined one'
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 40
      Width = 225
      Height = 49
      Caption = 'PaymantMethod'
      TabOrder = 0
      object chbPaymantMethod: TCheckBox
        Left = 8
        Top = 20
        Width = 49
        Height = 17
        Caption = 'Apply'
        State = cbChecked
        TabOrder = 0
        OnClick = chbPaymantMethodClick
      end
      object cmbPaymentMethod: TComboBox
        Left = 103
        Top = 15
        Width = 105
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        Items.Strings = (
          'Credit'
          'Check'
          'Visa'
          'COD'
          'MC'
          'AmEx'
          'Cash')
        TabOrder = 1
        OnChange = chbPaymantMethodClick
      end
    end
    object GroupBox2: TGroupBox
      Left = 239
      Top = 40
      Width = 201
      Height = 49
      Caption = 'AmountPaid'
      TabOrder = 1
      object chbAmountPaid: TCheckBox
        Left = 8
        Top = 20
        Width = 97
        Height = 17
        Caption = 'Apply'
        State = cbChecked
        TabOrder = 0
        OnClick = chbPaymantMethodClick
      end
      object sedAmountPaid: TSpinEdit
        Left = 100
        Top = 16
        Width = 93
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 10000
        OnChange = chbPaymantMethodClick
      end
    end
  end
  object Table1: TTable
    Active = True
    DatabaseName = 'DBDEMOS'
    TableName = 'orders.db'
    Left = 528
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = Table1
    Left = 568
    Top = 8
  end
end
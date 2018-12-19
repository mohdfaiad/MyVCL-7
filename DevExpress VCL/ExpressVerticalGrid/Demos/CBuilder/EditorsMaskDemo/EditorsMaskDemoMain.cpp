//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "EditorsMaskDemoMain.h"
#include "EditorsMaskDemoData.h"
#include "cxEditMaskEditor.hpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "cxClasses"
#pragma link "cxControls"
#pragma link "cxCustomData"
#pragma link "cxData"
#pragma link "cxDBData"
#pragma link "cxEdit"
#pragma link "cxFilter"
#pragma link "cxGraphics"
#pragma link "cxStyles"
#pragma link "cxLookAndFeels"
#pragma link "DemoBasicMain"
#pragma link "cxButtonEdit"
#pragma link "cxContainer"
#pragma link "cxDBEdit"
#pragma link "cxDBNavigator"
#pragma link "cxDBVGrid"
#pragma link "cxInplaceContainer"
#pragma link "cxMaskEdit"
#pragma link "cxNavigator"
#pragma link "cxTextEdit"
#pragma link "cxVGrid"
#pragma link "cxEditMaskEditor"
#pragma resource "*.dfm"
TEditorsMaskDemoMainForm *EditorsMaskDemoMainForm;
//---------------------------------------------------------------------------
__fastcall TEditorsMaskDemoMainForm::TEditorsMaskDemoMainForm(TComponent* Owner)
  : TDemoBasicMainForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::edtEmailPropertiesButtonClick(TObject *Sender,
  int AButtonIndex)
{
  ShowEditMaskDialog(((TcxDBButtonEdit*)Sender)->Properties);
  ChangeLabel(lbInfoEmail,
    (TcxCustomMaskEditProperties*)((TcxDBButtonEdit*)Sender)->Properties);
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::edtFaxPropertiesButtonClick(TObject *Sender,
  int AButtonIndex)
{
  ShowEditMaskDialog(((TcxDBButtonEdit*)Sender)->Properties);
  ChangeLabel(lbInfoFax,
    (TcxCustomMaskEditProperties*)((TcxDBButtonEdit*)Sender)->Properties);
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::edtHomePagePropertiesButtonClick(TObject *Sender,
  int AButtonIndex)
{
  ShowEditMaskDialog(((TcxDBButtonEdit*)Sender)->Properties);
  ChangeLabel(lbInfoHomePage,
    (TcxCustomMaskEditProperties*)((TcxDBButtonEdit*)Sender)->Properties);
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::edtPhonePropertiesButtonClick(TObject *Sender,
  int AButtonIndex)
{
  ShowEditMaskDialog(((TcxDBButtonEdit*)Sender)->Properties);
  ChangeLabel(lbInfoPhone,
    (TcxCustomMaskEditProperties*)((TcxDBButtonEdit*)Sender)->Properties);
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::edtPostalCodePropertiesButtonClick(TObject *Sender,
  int AButtonIndex)
{
  ShowEditMaskDialog(((TcxDBButtonEdit*)Sender)->Properties);
  ChangeLabel(lbInfoPostalCode,
    (TcxCustomMaskEditProperties*)((TcxDBButtonEdit*)Sender)->Properties);
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::miDefaultMaskExecute(TObject *Sender)
{
  edtPostalCode->Properties->MaskKind = cxDefaultPostalCodeMaskKind;
  edtPostalCode->Properties->EditMask = cxDefaultPostalCodeEditMask;
  ChangeLabel(lbInfoPostalCode, edtPostalCode->Properties);
  edtPhone->Properties->MaskKind = cxDefaultPhoneMaskKind;
  edtPhone->Properties->EditMask = cxDefaultPhoneEditMask;
  ChangeLabel(lbInfoPhone, edtPhone->Properties);
  edtFax->Properties->MaskKind = cxDefaultFaxMaskKind;
  edtFax->Properties->EditMask = cxDefaultFaxEditMask;
  ChangeLabel(lbInfoFax, edtFax->Properties);
  edtHomePage->Properties->MaskKind = cxDefaultHomePageMaskKind;
  edtHomePage->Properties->EditMask = cxDefaultHomePageEditMask;
  ChangeLabel(lbInfoHomePage, edtHomePage->Properties);
  edtEmail->Properties->MaskKind = cxDefaultEmailMaskKind;
  edtEmail->Properties->EditMask = cxDefaultEmailEditMask;
  ChangeLabel(lbInfoEmail, edtEmail->Properties);
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::miShowEditMaskButtonsExecute(TObject *Sender)
{
  ((TMenuItem*)Sender)->Checked = !((TMenuItem*)Sender)->Checked;
  edtPostalCode->Properties->Buttons->Items[0]->Visible = ((TMenuItem*)Sender)->Checked;
  edtPhone->Properties->Buttons->Items[0]->Visible = ((TMenuItem*)Sender)->Checked;
  edtFax->Properties->Buttons->Items[0]->Visible = ((TMenuItem*)Sender)->Checked;
  edtHomePage->Properties->Buttons->Items[0]->Visible = ((TMenuItem*)Sender)->Checked;
  edtEmail->Properties->Buttons->Items[0]->Visible = ((TMenuItem*)Sender)->Checked;
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::vgDepartmentsLeftVisibleRecordIndexChanged(
  TObject *Sender)
{
  vgDepartments->DataController->FocusedRecordIndex = vgDepartments->LeftVisibleRecord;
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::ChangeLabel(TLabel* ALabel,
  TcxCustomEditProperties* AProperties)
{
  AnsiString AText;
  if(((TcxCustomMaskEditPropertiesAccessor*)AProperties)->EmptyMaskAccess(
    ((TcxCustomMaskEditPropertiesAccessor*)AProperties)->EditMaskAccess()))
    AText = "No mask";
  else
    AText =
      GetMaskKindLabel(((TcxCustomMaskEditPropertiesAccessor*)AProperties)->MaskKindAccess());
  ALabel->Caption = AText;
}
//---------------------------------------------------------------------------

AnsiString __fastcall TEditorsMaskDemoMainForm::GetMaskKindLabel(const TcxEditMaskKind AMaskKind)
{
  switch(AMaskKind)
  {
    case emkStandard:
      return "Delphi Standard Mask";
    case emkRegExpr:
      return "Regular Expression";
    case emkRegExprEx:
      return "Regular Expression with Auto Complete Function";
    default:
      return "Unknown";
  };
}
//---------------------------------------------------------------------------

void __fastcall TEditorsMaskDemoMainForm::ShowEditMaskDialog(
  TcxCustomEditProperties *AProperties)
{
  TcxEditMaskEditorDlg* ADialog = new TcxEditMaskEditorDlg((TComponent*)NULL);
  try {
    ADialog->MaskEditProperties = (TcxCustomMaskEditProperties*)AProperties;
    ADialog->ShowModal();
  }
  __finally {
    delete ADialog;
  }
}
//---------------------------------------------------------------------------


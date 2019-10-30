unit UnitTranslators;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, IdMultipartFormData, System.JSON,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IniFiles,
  Vcl.Menus, Vcl.Mask, Vcl.StdCtrls;

type
  TFormTranslators = class(TForm)
    Panel1: TPanel;
    lvTrasnlators: TListView;
    TranslatorHttp: TIdHTTP;
    pmTranslators: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    PanelTranslator: TPanel;
    lblCaption: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    ledName: TLabeledEdit;
    ledSurname: TLabeledEdit;
    ledEmail: TLabeledEdit;
    btnAdd: TButton;
    ledUsername: TLabeledEdit;
    ledPassword: TLabeledEdit;
    lbTrsDirecs: TListBox;
    btnAddDirection: TButton;
    cbTrDirect: TComboBox;
    ledPhone: TMaskEdit;
    lbTrsLangs: TListBox;
    cbTrLangs: TComboBox;
    btnAddLanguage: TButton;
    Button2: TButton;
    Button3: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N2Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateTable;
    procedure AddToListView(num, tid, surname, nm, languages, direction, email, phone, reg_date,
                            busy, login :string);
    procedure LoadConfigs;
    procedure SaveConfigs;
  public
    { Public declarations }
  end;

type
    TLanguages = record
        LanguageSolo,
        LanguageFrom,
        LanguageTo : string;
    end;

var
  FormTranslators: TFormTranslators;

implementation
uses Main;

{$R *.dfm}

procedure TFormTranslators.LoadConfigs;
var
    Ini : TIniFile;
begin
    if FileExists(ExtractFilePath(ParamStr(0))+INI_FILE) then begin
        Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+INI_FILE);
        FormTranslators.Width := Ini.ReadInteger('FormTranslatorsSize', 'Width', 600);
        FormTranslators.Height := Ini.ReadInteger('FormTranslatorsSize', 'Heigh', 300);
        FormTranslators.Left := Ini.ReadInteger('FormTranslatorsPosition', 'x', 100);
        FormMain.Top := Ini.ReadInteger('FormTranslatorsPosition', 'y', 100);
        lvTrasnlators.Columns.Items[0].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol0', 100);
        lvTrasnlators.Columns.Items[1].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol1', 100);
        lvTrasnlators.Columns.Items[2].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol2', 100);
        lvTrasnlators.Columns.Items[3].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol3', 100);
        lvTrasnlators.Columns.Items[4].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol4', 100);
        lvTrasnlators.Columns.Items[5].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol5', 100);
        lvTrasnlators.Columns.Items[6].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol6', 100);
        lvTrasnlators.Columns.Items[7].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol7', 100);
        lvTrasnlators.Columns.Items[8].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol8', 100);
        lvTrasnlators.Columns.Items[9].Width := Ini.ReadInteger('TranslatorsTable', 'WidthCol9', 100);
        Ini.Free;
    end;
end;


procedure TFormTranslators.N1Click(Sender: TObject);
begin
    ledName.Clear;
    ledSurname.Clear;
    ledPhone.Clear;
    ledEmail.Clear;
    lbTrsDirecs.Clear;
    lbTrsLangs.Clear;
    ledUsername.Clear;
    ledPassword.Clear;
    PanelTranslator.Visible := True;
end;

procedure TFormTranslators.N2Click(Sender: TObject);
var
    i: integer;
    directs,
    langs,
    tmp, str: string;
    TempLangs: TStringList;
    Languages: array[0..99] of TLanguages;
begin
    if lvTrasnlators.SelCount = 0 then
        Exit;
    lblCaption.Caption := 'Редактирование';
    ledName.Text := lvTrasnlators.Selected.SubItems[2];
    ledSurname.Text := lvTrasnlators.Selected.SubItems[1];
    ledPhone.Text := lvTrasnlators.Selected.SubItems[6];
    ledEmail.Text := lvTrasnlators.Selected.SubItems[5];
    directs := lvTrasnlators.Selected.SubItems[4];
    tmp := '';
    for i:=1 to Length(directs) do begin
        if directs[i] = ' ' then
            Continue;
        if directs[i] = ',' then begin
            lbTrsDirecs.Items.Add(tmp);
            tmp := '';
            Continue;
        end;
        tmp := tmp + directs[i];
    end;
    lbTrsDirecs.Items.Add(tmp);
    langs := lvTrasnlators.Selected.SubItems[3];
    tmp := '';
    for i:=1 to Length(langs) do begin
        if langs[i] = ' ' then
            Continue;
        if langs[i] = ',' then begin
            lbTrsLangs.Items.Add(tmp);
            tmp := '';
            Continue;
        end;
        tmp := tmp + langs[i];
    end;
    lbTrsLangs.Items.Add(tmp);
    TempLangs := TStringList.Create;
    TempLangs.LoadFromFile('languages.txt');
    LanguagesCount := TempLangs.Count;
    for i:=0 to TempLangs.Count-1 do begin
        str := TempLangs.Strings[i];
        cbTrLangs.Items.Add(Copy(str, 0, Pos(' ', str)-1));
//        Languages[i].LanguageSolo := Copy(str, 0, Pos(' ', str)-1);
//        Delete(str, 1, Length(cbTrLangs.Items.Strings[i])+1);
//        Languages[i].LanguageFrom := Copy(str, 0, Pos(' ', str)-1);
//        Delete(str, 1, Length(Languages[i].LanguageFrom)+1);
//        Languages[i].LanguageTo := str;
//        cbTranslatinglang.Items.Add(str);
    end;
    ledUsername.Text := lvTrasnlators.Selected.SubItems[9];
    PanelTranslator.Visible := True;
end;

procedure TFormTranslators.N3Click(Sender: TObject);
begin
    if lvTrasnlators.SelCount = 0 then
        Exit;
    if MessageDlg('Удалить переводчика?',mtError, mbOKCancel, 0) = mrOK then
        lvTrasnlators.Selected.Delete
    else
        Exit;
end;

procedure TFormTranslators.SaveConfigs;
var
    Ini : TIniFile;
    fl : TextFile;

begin
    if not FileExists(ExtractFilePath(ParamStr(0))+INI_FILE) then
    begin
        AssignFile(fl, INI_FILE);
        Rewrite(fl);
        CloseFile(fl);
    end;
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+INI_FILE);
    Ini.WriteInteger('FormTranslatorsSize', 'Width', FormTranslators.Width);
    Ini.WriteInteger('FormTranslatorsSize', 'Heigh', FormTranslators.Height);
    Ini.WriteInteger('FormTranslatorsPosition', 'x', FormTranslators.Left);
    Ini.WriteInteger('FormTranslatorsPosition', 'y', FormTranslators.Top);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol0', lvTrasnlators.Columns.Items[0].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol1', lvTrasnlators.Columns.Items[1].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol2', lvTrasnlators.Columns.Items[2].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol3', lvTrasnlators.Columns.Items[3].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol4', lvTrasnlators.Columns.Items[4].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol5', lvTrasnlators.Columns.Items[5].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol6', lvTrasnlators.Columns.Items[6].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol7', lvTrasnlators.Columns.Items[7].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol8', lvTrasnlators.Columns.Items[8].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol9', lvTrasnlators.Columns.Items[9].Width);
    Ini.WriteInteger('TranslatorsTable', 'WidthCol9', lvTrasnlators.Columns.Items[10].Width);
    Ini.Free;
end;



procedure TFormTranslators.btnCancelClick(Sender: TObject);
begin
    PanelTranslator.Visible := False;
end;

procedure TFormTranslators.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    SaveConfigs;
end;

procedure TFormTranslators.FormCreate(Sender: TObject);
var
    NewColumn: TListColumn;
begin
    with lvTrasnlators do begin
        NewColumn := Columns.Add;
        NewColumn.Caption := '№';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'ID';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Фамилия';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Имя';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Языки';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Область';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Почта';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Тел.';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Дата рег-ий';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Занятость';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Логин';
    end;
    cbTrDirect.Items.LoadFromFile('directions.txt');
    LoadConfigs;
end;

procedure TFormTranslators.FormShow(Sender: TObject);
begin
    UpdateTable;
end;

procedure TFormTranslators.UpdateTable;
var
    Result: string;
    Json: TJSONObject;
    JSONArray: TJSONArray;
    i : integer;
    s: string;
begin
    try
        result := TranslatorHttp.get(URL + '/management/get_all_translators/' +
                           '?token=' + token +
                           '&mid=' + mid);
    except on E: Exception do
        begin
            ShowMessage('Нет связи с сервером');
            Exit;
        end;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if Json.GetValue('response').Value = 'denied' then begin
      MessageDlg('Доступ запрещен!', mtWarning, [mbOK], 0);
      Exit;
    end;
    JSONArray := TJSONArray(json.GetValue('translators'));
    if JSONArray = nil then
        Exit;
    SelectedItem := lvTrasnlators.Selected;
    lvTrasnlators.Clear;
    for i := 0 to JSONArray.Count - 1 do
    begin
        s := TJSONArray(JSONArray.Items[i]).FindValue('name').Value;
        AddToListView(IntToStr(i+1),
                      TJSONArray(JSONArray.Items[i]).FindValue('tid').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('surname').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('name').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('languages').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('direction').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('email').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('phone').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('reg_date').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('busy').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('login').Value);
    end;
    lvTrasnlators.Selected := SelectedItem;
end;


procedure TFormTranslators.AddToListView(num, tid, surname, nm, languages, direction, email, phone,
                                         reg_date, busy, login :string);
var
    ListItem: TListItem;
begin
   with lvTrasnlators do begin
        ListItem := Items.Add;
        ListItem.Caption := num;
        ListItem.SubItems.Add(tid);
        ListItem.SubItems.Add(surname);
        ListItem.SubItems.Add(nm);
        ListItem.SubItems.Add(languages);
        ListItem.SubItems.Add(direction);
        ListItem.SubItems.Add(email);
        ListItem.SubItems.Add(phone);
        ListItem.SubItems.Add(reg_date);
        ListItem.SubItems.Add(busy);
        ListItem.SubItems.Add(login);
    end;
end;

end.

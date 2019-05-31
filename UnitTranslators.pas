unit UnitTranslators;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, IdMultipartFormData, System.JSON,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IniFiles;

type
  TFormTranslators = class(TForm)
    Panel1: TPanel;
    lvTrasnlators: TListView;
    TranslatorHttp: TIdHTTP;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure UpdateTable;
    procedure AddToListView(num, tid, surname, nm, languages, direction, email, phone, reg_date,
                            busy :string);
    procedure LoadConfigs;
    procedure SaveConfigs;
  public
    { Public declarations }
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
    Ini.Free;
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
    end;
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
                      TJSONArray(JSONArray.Items[i]).FindValue('busy').Value);
    end;
    lvTrasnlators.Selected := SelectedItem;
end;


procedure TFormTranslators.AddToListView(num, tid, surname, nm, languages, direction, email, phone,
                                         reg_date, busy :string);
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
    end;
end;

end.

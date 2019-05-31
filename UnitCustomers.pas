unit UnitCustomers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, IniFiles, System.JSON,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TFormCustomers = class(TForm)
    Panel1: TPanel;
    lvCustomers: TListView;
    CustomersHttp: TIdHTTP;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
      procedure UpdateTable;
      procedure AddToListView(num, tid, surname, nm, email, phone, reg_date, refused_orders,
                              completed_orders, rating:string);
      procedure LoadConfigs;
      procedure SaveConfigs;
  public
    { Public declarations }
  end;

var
  FormCustomers: TFormCustomers;

implementation
uses Main;

{$R *.dfm}

procedure TFormCustomers.LoadConfigs;
var
    Ini : TIniFile;
begin
    if FileExists(ExtractFilePath(ParamStr(0))+INI_FILE) then begin
        Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+INI_FILE);
        FormCustomers.Width := Ini.ReadInteger('FormCustomersSize', 'Width', 600);
        FormCustomers.Height := Ini.ReadInteger('FormCustomersSize', 'Heigh', 300);
        FormCustomers.Left := Ini.ReadInteger('FormCustomersPosition', 'x', 100);
        FormCustomers.Top := Ini.ReadInteger('FormCustomersPosition', 'y', 100);
        lvCustomers.Columns.Items[0].Width := Ini.ReadInteger('CustomersTable', 'WidthCol0', 100);
        lvCustomers.Columns.Items[1].Width := Ini.ReadInteger('CustomersTable', 'WidthCol1', 100);
        lvCustomers.Columns.Items[2].Width := Ini.ReadInteger('CustomersTable', 'WidthCol2', 100);
        lvCustomers.Columns.Items[3].Width := Ini.ReadInteger('CustomersTable', 'WidthCol3', 100);
        lvCustomers.Columns.Items[4].Width := Ini.ReadInteger('CustomersTable', 'WidthCol4', 100);
        lvCustomers.Columns.Items[5].Width := Ini.ReadInteger('CustomersTable', 'WidthCol5', 100);
        lvCustomers.Columns.Items[6].Width := Ini.ReadInteger('CustomersTable', 'WidthCol6', 100);
        lvCustomers.Columns.Items[7].Width := Ini.ReadInteger('CustomersTable', 'WidthCol7', 100);
        lvCustomers.Columns.Items[8].Width := Ini.ReadInteger('CustomersTable', 'WidthCol8', 100);
        lvCustomers.Columns.Items[9].Width := Ini.ReadInteger('CustomersTable', 'WidthCol9', 100);
        Ini.Free;
    end;
end;


procedure TFormCustomers.SaveConfigs;
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
    Ini.WriteInteger('FormCustomersSize', 'Width', FormCustomers.Width);
    Ini.WriteInteger('FormCustomersSize', 'Heigh', FormCustomers.Height);
    Ini.WriteInteger('FormCustomersPosition', 'x', FormCustomers.Left);
    Ini.WriteInteger('FormCustomersPosition', 'y', FormCustomers.Top);
    Ini.WriteInteger('CustomersTable', 'WidthCol0', lvCustomers.Columns.Items[0].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol1', lvCustomers.Columns.Items[1].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol2', lvCustomers.Columns.Items[2].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol3', lvCustomers.Columns.Items[3].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol4', lvCustomers.Columns.Items[4].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol5', lvCustomers.Columns.Items[5].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol6', lvCustomers.Columns.Items[6].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol7', lvCustomers.Columns.Items[7].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol8', lvCustomers.Columns.Items[8].Width);
    Ini.WriteInteger('CustomersTable', 'WidthCol9', lvCustomers.Columns.Items[9].Width);
    Ini.Free;
end;

procedure TFormCustomers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    SaveConfigs;
end;

procedure TFormCustomers.FormCreate(Sender: TObject);
var
    NewColumn: TListColumn;
begin
    with lvCustomers do begin
        NewColumn := Columns.Add;
        NewColumn.Caption := '№';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'ID';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Фамилия';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Имя';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Почта';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Тел.';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Дата рег-ий';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Отмененные заказы';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Завершенные заказы';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Рейтинг';
    end;
    LoadConfigs;
end;

procedure TFormCustomers.FormShow(Sender: TObject);
begin
    UpdateTable;
end;

procedure TFormCustomers.UpdateTable;
var
    Result: string;
    Json: TJSONObject;
    JSONArray: TJSONArray;
    i : integer;
begin
    try
        result := CustomersHttp.get(URL + '/management/get_all_customers/' +
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
    JSONArray := TJSONArray(json.GetValue('customers'));
    if JSONArray = nil then
        Exit;
    SelectedItem := lvCustomers.Selected;
    lvCustomers.Clear;
    for i := 0 to JSONArray.Count - 1 do
    begin
        AddToListView(IntToStr(i+1),
                      TJSONArray(JSONArray.Items[i]).FindValue('tid').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('surname').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('name').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('email').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('phone').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('reg_date').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('refused_orders').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('completed_orders').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('rating').Value);
    end;
    lvCustomers.Selected := SelectedItem;
end;

procedure TFormCustomers.AddToListView(num, tid, surname, nm, email, phone, reg_date,
                                       refused_orders, completed_orders, rating:string);
var
    ListItem: TListItem;
begin
   with lvCustomers do begin
        ListItem := Items.Add;
        ListItem.Caption := num;
        ListItem.SubItems.Add(tid);
        ListItem.SubItems.Add(surname);
        ListItem.SubItems.Add(nm);
        ListItem.SubItems.Add(email);
        ListItem.SubItems.Add(phone);
        ListItem.SubItems.Add(reg_date);
        ListItem.SubItems.Add(refused_orders);
        ListItem.SubItems.Add(completed_orders);
        ListItem.SubItems.Add(rating);
    end;
end;

end.

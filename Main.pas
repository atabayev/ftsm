unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls, IniFiles,
  System.ImageList, Vcl.ImgList, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  Vcl.StdCtrls, IdMultipartFormData, System.JSON, Vcl.WinXPickers, ShellAPI, Vcl.Mask,
  Vcl.Menus;

const
    INI_FILE = 'configs.ini';


type
  TFormMain = class(TForm)
    ToolBar1: TToolBar;
    tbConnection: TToolButton;
    tbFinishOrder: TToolButton;
    PanelTable: TPanel;
    MainTable: TListView;
    ilToolBar: TImageList;
    http: TIdHTTP;
    TimerUpdate: TTimer;
    StatusBar: TStatusBar;
    tbTranslators: TToolButton;
    tbCustomers: TToolButton;
    PanelAuth: TPanel;
    btnAuth: TButton;
    edLogin: TLabeledEdit;
    edPassword: TLabeledEdit;
    PanelOrdering: TPanel;
    Panel1: TPanel;
    btnClose: TButton;
    ilButtons: TImageList;
    btnDwnOrdersFile: TButton;
    btnOk: TButton;
    OrderingTable: TListView;
    edID: TEdit;
    edLanguage: TEdit;
    edDateStart: TEdit;
    edPages: TEdit;
    edFilesCount: TEdit;
    edUrgency: TEdit;
    edTranslator: TEdit;
    edCustomer: TEdit;
    edPriceToClient: TEdit;
    SaveDialog: TSaveDialog;
    Panel2: TPanel;
    ListView1: TListView;
    edTID: TEdit;
    edTSurname: TEdit;
    edTEmail: TEdit;
    edTName: TEdit;
    edTDirection: TEdit;
    edTPhone: TEdit;
    lbAllTranslators: TListBox;
    lbOrderTrasnlators: TListBox;
    btnToOrder: TButton;
    btnFromOrder: TButton;
    dpDateFinish: TDatePicker;
    PanelOrd: TPanel;
    PanelTr: TPanel;
    PanelBtns: TPanel;
    PanelAddTr: TPanel;
    FileOpenDialog: TFileOpenDialog;
    tbSeparator: TToolButton;
    UpdateHttp: TIdHTTP;
    ToolButton1: TToolButton;
    PanelAddTranslator: TPanel;
    ledName: TLabeledEdit;
    ledSurname: TLabeledEdit;
    ledEmail: TLabeledEdit;
    Button1: TButton;
    ledUsername: TLabeledEdit;
    ledPassword: TLabeledEdit;
    Label1: TLabel;
    cbDirection: TComboBox;
    lbTrsDirecs: TListBox;
    Label2: TLabel;
    btnAddDirection: TButton;
    cbTrDirect: TComboBox;
    Label3: TLabel;
    ledPhone: TMaskEdit;
    Label4: TLabel;
    lbTrsLangs: TListBox;
    cbTrLangs: TComboBox;
    Label5: TLabel;
    btnAddLanguage: TButton;
    Button2: TButton;
    Button3: TButton;
    edTLanguages: TEdit;
    edComment: TEdit;
    cbTranslatinglang: TComboBox;
    edPriceToTranslator: TEdit;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure btnAuthClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MainTableCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure tbConnectionClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure TimerUpdateTimer(Sender: TObject);
    procedure btnDwnOrdersFileClick(Sender: TObject);
    procedure edDirectionExit(Sender: TObject);
    procedure lbAllTranslatorsClick(Sender: TObject);
    procedure btnToOrderClick(Sender: TObject);
    procedure btnFromOrderClick(Sender: TObject);
    procedure lbOrderTrasnlatorsClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure tbFinishOrderClick(Sender: TObject);
    procedure tbTranslatorsClick(Sender: TObject);
    procedure tbCustomersClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbDirectionSelect(Sender: TObject);
    procedure btnAddDirectionClick(Sender: TObject);
    procedure btnAddLanguageClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure LoadConfigs;
    procedure SaveConfigs;
    procedure UpdateTable;
    procedure Auth;
    procedure Deauth;
    procedure AddToListView(num, oid, lang_from, lang_to, pages, dstart, dfinish, direction,
                            urgency, file_cnt, price_to_client, price_to_translator, customer_id,
                            translator_id, comment, rating, status :string);
    procedure PanelOrderingHide;
    procedure PanelOrderingShow(IsOrdering: boolean; IsForAddTr: boolean);
    procedure ChangeEdTranslators;
  public
    { Public declarations }
  end;

  TTranslator = record
      id,
      surname,
      name,
      email,
      phone,
      direction,
      languages: string;
  end;

  TLanguages = record
    LanguageSolo,
    LanguageFrom,
    LanguageTo : string;
  end;

var
  FormMain: TFormMain;
  URL,
  mid, Token: string;
  SelectedItem: TListItem;
  Translator: array of TTranslator;
  Languages: array[0..99] of TLanguages;
  LanguagesCount: integer;
  Username: string;
  IsNewOrder: boolean = True;


implementation
uses UnitTranslators, UnitCustomers;

{$R *.dfm}

procedure TFormMain.Auth;
begin
    PanelAuth.Visible := False;
    ToolBar1.Enabled := True;
    MainTable.Enabled := True;
    TimerUpdate.Enabled := True;
    tbConnection.Enabled := True;
    tbFinishOrder.Enabled := True;
    tbTranslators.Enabled := True;
    tbCustomers.Enabled := True;
    UpdateTable;
end;

procedure TFormMain.Deauth;
begin
    PanelAuth.Visible := True;
    ToolBar1.Enabled := False;
    MainTable.Enabled := False;
    TimerUpdate.Enabled := False;
    tbConnection.Enabled := False;
    tbFinishOrder.Enabled := False;
    tbTranslators.Enabled := False;
    tbCustomers.Enabled := False;
    MainTable.Clear;
end;


procedure TFormMain.btnAddDirectionClick(Sender: TObject);
var
    i: integer;
    isAdd: boolean;
begin
    isAdd := True;
    if cbTrDirect.ItemIndex = -1 then
        Exit;
    for i:=0 to lbTrsDirecs.Items.Count-1 do begin
        if lbTrsDirecs.Items.Strings[i] = cbTrDirect.Items.Strings[cbTrDirect.ItemIndex] then
            isAdd := False;
    end;
    if isAdd then
        lbTrsDirecs.Items.Add(cbTrDirect.Items.Strings[cbTrDirect.ItemIndex]);
end;

procedure TFormMain.btnAddLanguageClick(Sender: TObject);
var
    i: integer;
    isAdd: boolean;
begin
    isAdd := True;
    if cbTrLangs.ItemIndex = -1 then
        Exit;
    for i:=0 to lbTrsLangs.Items.Count-1 do begin
        if lbTrsLangs.Items.Strings[i] = cbTrLangs.Items.Strings[cbTrLangs.ItemIndex] then
            isAdd := False;
    end;
    if isAdd then
        lbTrsLangs.Items.Add(cbTrLangs.Items.Strings[cbTrLangs.ItemIndex]);
end;

procedure TFormMain.btnAuthClick(Sender: TObject);
var
    Result: string;
    Data: TIdMultiPartFormDataStream;
    Json: TJSONObject;
begin
    Data := TIdMultiPartFormDataStream.Create;
    Data.AddFormField('username', edLogin.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('password', edPassword.Text, 'utf-8').ContentTransfer:='8bit';
    try
        try
            Result := http.Post(URL + '/management/authentication/', Data)
        except on E: Exception do
            begin
                ShowMessage('Нет связи с сервером');
                TimerUpdate.Enabled := false;
                Exit;
            end;
        end;
    finally
        Data.Free;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if json.GetValue('response').Value = 'ok' then begin
        Username := edLogin.Text;
        mid := json.GetValue('id').Value;
        Token := json.GetValue('token').Value;
        Auth;
    end
    else if json.GetValue('response').Value = 'denied' then
        MessageDlg('Доступ запрещен!', mtWarning, [mbOk], 0);
end;

procedure TFormMain.btnCloseClick(Sender: TObject);
begin
    PanelOrderingHide;
end;

procedure TFormMain.btnDwnOrdersFileClick(Sender: TObject);
var
    Result: string;
    json: TJSONObject;
    FileName: string;
    MemoryStream: TMemoryStream;
begin
    try
        Result := http.get(URL + '/management/gofn/' + '?mid=' + mid +
                                                           '&token=' + Token +
                                                           '&oid=' + edID.Text);
    except on E: Exception do begin
        ShowMessage('Нет связи с сервером');
        TimerUpdate.Enabled := false;
        Exit;
        end;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if json.GetValue('response').Value <> 'ok' then begin
        ShowMessage('Ошибка: ' + json.GetValue('response').Value);
        Exit;
    end;
    FileName := ExtractFileName(json.GetValue('file_name').Value);
    SaveDialog.FileName := FileName;
    if SaveDialog.Execute then begin
        MemoryStream := TMemoryStream.Create;
        try
            http.get(URL + '/management/gof/' + '?mid=' + mid +
                                                         '&token=' + Token+
                                                         '&oid=' + edID.Text,
                              MemoryStream);
            MemoryStream.SaveToFile(SaveDialog.FileName);
        finally
            MemoryStream.Free;
        end;
    end;
end;

procedure TFormMain.btnFromOrderClick(Sender: TObject);
begin
    if lbOrderTrasnlators.ItemIndex = -1 then
        Exit;
    lbAllTranslators.Items.Add(lbOrderTrasnlators.Items.Strings[lbOrderTrasnlators.ItemIndex]);
    lbOrderTrasnlators.Items.Delete(lbOrderTrasnlators.ItemIndex);
    ChangeEdTranslators;
end;

procedure TFormMain.btnOkClick(Sender: TObject);
var
    Result,
    Msg: string;
    Json: TJSONObject;
    JSONTranslatorssArray: TJSONArray;
    i: integer;
    Data: TIdMultiPartFormDataStream;
    Translators: string;
begin
    if IsNewOrder then begin
        if lbOrderTrasnlators.Items.Count = 0 then begin
            MessageDlg('Добавьте переводчика', mtWarning, [mbYes], 0);
            Exit;
        end;
        if cbDirection.Text = '' then begin
            MessageDlg('Укажите тематику', mtWarning, [mbYes], 0);
            Exit;
        end;
        if cbTranslatinglang.ItemIndex = -1 then begin
            MessageDlg('Укажите язык текста', mtWarning, [mbYes], 0);
            Exit;
        end;
        if edPages.Text = '' then begin
            MessageDlg('Укажите количество страниц', mtWarning, [mbYes], 0);
            Exit;
        end;
        if edPriceToClient.Text = '' then begin
            MessageDlg('Укажите цену для заказчика', mtWarning, [mbYes], 0);
            Exit;
        end;
        if edPriceToTranslator.Text = '' then begin
            MessageDlg('Укажите цену для переводчика', mtWarning, [mbYes], 0);
            Exit;
        end;
        for i:=0 to lbOrderTrasnlators.Count-1 do begin
            Translators := Translators + Copy(lbOrderTrasnlators.Items.Strings[i], 0, 12) + ',';
        end;
        if StrToDate(edDateStart.Text) > dpDateFinish.Date then begin
            MessageDlg('Неправильно указана дата завершения заказа!', mtWarning, [mbYes], 0);
            Exit;
        end;

        Delete(Translators, Length(Translators), 1);
        Data := TIdMultiPartFormDataStream.Create;
        Data.AddFormField('oid', edID.Text, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('tid', Translators, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('token', Token, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('date_end', DateToStr(dpDateFinish.Date) , 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('price_to_client', edPriceToClient.Text, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('price_to_translator', edPriceToTranslator.Text, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('direction', cbDirection.Text, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('lang_from', cbTranslatinglang.Text, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('pages_count', edPages.Text, 'utf-8').ContentTransfer:='8bit';
        try
            try
                Result := http.post(URL + '/management/atto/', Data)
            except on E: Exception do begin
                ShowMessage('Нет связи с сервером');
                TimerUpdate.Enabled := false;
                Exit;
                end;
            end;
        finally
            Data.Free;
        end;
        json := TJSONObject.ParseJSONValue(result) as TJSONObject;
        Msg := 'Заказ обработан и отправлен заказчику.' + #13#10 + 'Ожидайте ответа';
        if json.GetValue('response').Value = 'ok' then begin
            MessageDlg(Msg, mtWarning, [mbYes], 0);
            PanelOrderingHide;
            UpdateTable;
            Exit;
        end;
        if json.GetValue('response').Value = 'denied' then begin
            MessageDlg('Доступ запрещен!', mtWarning, [mbYes], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_no_order' then begin
            MessageDlg('Ошибка: Не найти данный заказ!', mtError, [mbYes], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_unknown_translators' then begin
            MessageDlg('Ошибка: Неизвестный переводчик!', mtError, [mbYes], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_unknown_client' then begin
            MessageDlg('Ошибка: Неизвестный заказчик!', mtError, [mbYes], 0);
            Exit;
        end;
    end
    else begin
        if lbOrderTrasnlators.Items.Count = 0 then begin
            MessageDlg('Добавьте переводчика', mtWarning, [mbYes], 0);
            Exit;
        end;
        if cbDirection.Text = '' then begin
            MessageDlg('Укажите тематику', mtWarning, [mbYes], 0);
            Exit;
        end;
        if edPriceToClient.Text = '' then begin
            MessageDlg('Укажите цену', mtWarning, [mbYes], 0);
            Exit;
        end;
        for i:=0 to lbOrderTrasnlators.Count-1 do begin
            Translators := Translators + Copy(lbOrderTrasnlators.Items.Strings[i], 0, 12) + ',';
        end;
        if StrToDate(edDateStart.Text) > dpDateFinish.Date then begin
            MessageDlg('Неправильно указана дата завершения заказа!', mtWarning, [mbYes], 0);
            Exit;
        end;

        Delete(Translators, Length(Translators), 1);
        Data := TIdMultiPartFormDataStream.Create;
        Data.AddFormField('oid', edID.Text, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('tid', Translators, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('token', Token, 'utf-8').ContentTransfer:='8bit';
        try
            try
                Result := http.post(URL + '/management/add_new_translators/', Data)
            except on E: Exception do begin
                ShowMessage('Нет связи с сервером');
                TimerUpdate.Enabled := false;
                Exit;
                end;
            end;
        finally
            Data.Free;
        end;
        json := TJSONObject.ParseJSONValue(result) as TJSONObject;
        Msg := 'Заказ обработан и отправлен заказчику.' + #13#10 + 'Ожидайте ответа';
        if json.GetValue('response').Value = 'ok' then begin
            MessageDlg(Msg, mtWarning, [mbYes], 0);
            PanelOrderingHide;
            UpdateTable;
            Exit;
        end;
        if json.GetValue('response').Value = 'denied' then begin
            MessageDlg('Доступ запрещен!', mtWarning, [mbYes], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_no_order' then begin
            MessageDlg('Ошибка: Не найти данный заказ!', mtError, [mbYes], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_unknown_translators' then begin
            MessageDlg('Ошибка: Неизвестный переводчик!', mtError, [mbYes], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_unknown_client' then begin
            MessageDlg('Ошибка: Неизвестный заказчик!', mtError, [mbYes], 0);
            Exit;
        end;
    end;
end;

procedure TFormMain.ChangeEdTranslators;
var
    i: integer;
    s,
    tmpTr: string;
begin
    s := '';
    for i:=0 to lbOrderTrasnlators.Count-1 do begin
        tmpTr := lbOrderTrasnlators.Items.Strings[i];
        s := s + Copy(tmpTr, 14, Length(tmpTr)) + ', ';
    end;
    Delete(s, Length(s)-1, 2);
    edTranslator.Text := s;
end;

procedure TFormMain.cbDirectionSelect(Sender: TObject);
var
    Result: string;
    Json: TJSONObject;
    JSONTranslatorssArray: TJSONArray;
    i: integer;
    LangIndex: integer;
    Data: TIdMultiPartFormDataStream;
    str, LangFrom, LangTo: string;
begin
    str := edLanguage.Text;
    Delete(str, 1, 2);
    Data := TIdMultiPartFormDataStream.Create;
    Data.AddFormField('mid', mid, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('token', Token, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('direction', cbDirection.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('languages', edLanguage.Text+'-'+cbTranslatinglang.Text, 'utf-8').ContentTransfer:='8bit';
    try
        try
            Result := http.Post(URL + '/management/get_ready_translators/', Data)
        except on E: Exception do begin
            ShowMessage('Нет связи с сервером');
            TimerUpdate.Enabled := false;
            Exit;
            end;
        end;
    finally
        Data.Free;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if json.GetValue('response').Value <> 'ok' then begin
        ShowMessage('Ошибка: ' + json.GetValue('response').Value);
        Exit;
    end;
    JSONTranslatorssArray := TJSONArray(json.GetValue('translators'));
    SetLength(Translator, JSONTranslatorssArray.Count);
    lbAllTranslators.Clear;
    for i:=0 to JSONTranslatorssArray.Count-1 do begin
        Translator[i].id := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('tid').Value;
        Translator[i].surname := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('surname').Value;
        Translator[i].name := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('name').Value;
        Translator[i].email := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('email').Value;
        Translator[i].phone := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('phone').Value;
        Translator[i].direction := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('direction').Value;
        Translator[i].languages := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('languages').Value;
        lbAllTranslators.Items.Add(Translator[i].id + ' ' +
                                   Translator[i].surname + ' ' +
                                   Translator[i].name);
    end;
end;

procedure TFormMain.btnToOrderClick(Sender: TObject);
begin
    if lbAllTranslators.ItemIndex = -1 then
        Exit;
    lbOrderTrasnlators.Items.Add(lbAllTranslators.Items.Strings[lbAllTranslators.ItemIndex]);
    lbAllTranslators.Items.Delete(lbAllTranslators.ItemIndex);
    ChangeEdTranslators;
end;

procedure TFormMain.Button1Click(Sender: TObject);
var
    Result: string;
    Json: TJSONObject;
    JSONTranslatorssArray: TJSONArray;
    i: integer;
    Data: TIdMultiPartFormDataStream;
    Direction: string;
    Languages: string;
    Phone: string;
begin
    if ledName.Text = '' then begin
        MessageDlg('Заполните имя переводчика', mtWarning, mbOKCancel, 0);
        Exit;
    end;
    if ledSurname.Text = '' then begin
        MessageDlg('Заполните фамилию переводчика', mtWarning, mbOKCancel, 0);
        Exit;
    end;
    Phone := ledPhone.Text;
    Phone := Phone.Replace('(', '');
    Phone := Phone.Replace(')', '');
    Phone := Phone.Replace('-', '');
    if Phone = '' then begin
        MessageDlg('Заполните телефон переводчика', mtWarning, mbOKCancel, 0);
        Exit;
    end;
    if ledEmail.Text = '' then begin
        MessageDlg('Заполните почту переводчика', mtWarning, mbOKCancel, 0);
        Exit;
    end;
    Direction := lbTrsDirecs.Items.Text;
    Direction := Direction.Replace(#$D#$A, ', ');
    Delete(Direction, Length(Direction)-1, 2);
    Languages := lbTrsLangs.Items.Text;
    Languages := Languages.Replace(#$D#$A, ', ');
    Delete(Languages, Length(Languages)-1, 2);
    Phone := ledPhone.Text;
    Phone := Phone.Replace('(', '');
    Phone := Phone.Replace(')', '');
    Phone := Phone.Replace('-', '');
    Data := TIdMultiPartFormDataStream.Create;
    Data.AddFormField('name', ledName.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('surname', ledSurname.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('email', ledEmail.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('phone', Phone, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('direction', Direction, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('languages', Languages, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('username', ledUsername.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('password', ledPassword.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('mid', mid, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('token', Token, 'utf-8').ContentTransfer:='8bit';
    try
        try
            Result := http.Post(URL + '/translator/new/', Data)
        except on E: Exception do begin
            ShowMessage('Нет связи с сервером');
            TimerUpdate.Enabled := false;
            Exit;
            end;
        end;
    finally
        Data.Free;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if LowerCase(json.GetValue('response').Value) = 'denied' then begin
        MessageDlg('Доступ запрещен!', mtWarning, [mbOK], 0);
        Exit;
    end;
    if LowerCase(json.GetValue('response').Value) = 'ex_error' then begin
        MessageDlg('Данный переводчик уже существует!', mtWarning, [mbOK], 0);
        Exit;
    end;
    if LowerCase(json.GetValue('response').Value) = 'ok' then begin
        MessageDlg('Переводчик добавлен!', mtWarning, [mbOK], 0);
        PanelAddTranslator.Visible := False;
        Exit;
    end;
end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
    lbTrsDirecs.Items.Delete(lbTrsDirecs.ItemIndex);
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
    lbTrsLangs.Items.Delete(lbTrsLangs.ItemIndex);
end;

procedure TFormMain.Button4Click(Sender: TObject);
var
    Result: string;
    Data: TIdMultiPartFormDataStream;
    Json: TJSONObject;
begin
    Data := TIdMultiPartFormDataStream.Create;
    Data.AddFormField('username', edLogin.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('password', edPassword.Text, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('name', 'Ельдос', 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('surname', 'Атабаев', 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('email', 'E1dos@mail.ru', 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('phone', '7055552402', 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('pswd', 'for_add', 'utf-8').ContentTransfer:='8bit';
    try
        try
            Result := http.Post(URL + '/management/new/', Data)
        except on E: Exception do
            begin
                ShowMessage('Нет связи с сервером');
                TimerUpdate.Enabled := false;
                Exit;
            end;
        end;
    finally
        Data.Free;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if json.GetValue('response').Value = 'ok' then begin
        Username := edLogin.Text;
        mid := json.GetValue('id').Value;
    end
    else if json.GetValue('response').Value = 'denied' then
        MessageDlg('Доступ запрещен!', mtWarning, [mbOk], 0);
end;

procedure TFormMain.PanelOrderingHide;
begin
    PanelOrdering.Visible := False;
    edTID.Clear;
    edTSurname.Clear;
    edTEmail.Clear;
    edTName.Clear;
    edTDirection.Clear;
    edTPhone.Clear;
    edTLanguages.Clear;
    lbAllTranslators.Clear;
    lbOrderTrasnlators.Clear;
end;


procedure TFormMain.PanelOrderingShow(IsOrdering: boolean; IsForAddTr: boolean);
var
    ListItem: TListItem;
    Result: string;
    Json: TJSONObject;
    JSONTranslatorssArray: TJSONArray;
    i: integer;
begin
    PanelOrdering.Visible := True;
    with OrderingTable do begin
        edID.Text := MainTable.Selected.SubItems.Strings[0];
        cbTranslatinglang.Text := MainTable.Selected.SubItems.Strings[1];
        edLanguage.Text := MainTable.Selected.SubItems.Strings[2];
        edPages.Text := MainTable.Selected.SubItems.Strings[3];
        edDateStart.Text := MainTable.Selected.SubItems.Strings[4];
//        dpDateFinish.Text := MainTable.Selected.SubItems.Strings[4];
        cbDirection.Text := MainTable.Selected.SubItems.Strings[6];
        edUrgency.Text := MainTable.Selected.SubItems.Strings[7];
        edFilesCount.Text := MainTable.Selected.SubItems.Strings[8];
        edPriceToClient.Text := MainTable.Selected.SubItems.Strings[9];
        edPriceToTranslator.Text := MainTable.Selected.SubItems.Strings[10];
        edCustomer.Text := MainTable.Selected.SubItems.Strings[11];
        edTranslator.Text := MainTable.Selected.SubItems.Strings[12];
        edComment.Text := MainTable.Selected.SubItems.Strings[13];
    end;
    if IsOrdering then begin
        PanelAddTr.Visible := True;
        PanelTr.Visible := True;
        PanelBtns.Left := 1071;
        PanelOrdering.Width := 1160;
        PanelOrdering.Height := 597;
        btnDwnOrdersFile.Visible := True;
        btnOk.Visible := True;
        dpDateFinish.Enabled := True;
        dpDateFinish.Date:= Now;
        cbDirection.Enabled := True;
        edPriceToClient.Enabled := True;
        edPriceToTranslator.Enabled := True;
        cbTranslatinglang.Enabled := True;
        edPages.Enabled := True;
    end
    else begin
        PanelAddTr.Visible := False;
        PanelTr.Visible := False;
        PanelOrdering.Height := 370;
        PanelOrdering.Width := 636;
        PanelBtns.Height := 370;
        PanelBtns.Left := 536;
        btnDwnOrdersFile.Visible := False;
        btnOk.Visible := False;
        dpDateFinish.Enabled := False;
        dpDateFinish.Date:= StrToDate(MainTable.Selected.SubItems.Strings[4]);
        cbDirection.Enabled := False;
        edPriceToClient.Enabled := False;
        edPriceToTranslator.Enabled := False;
        edPages.Enabled := False;
        cbTranslatinglang.Enabled := False;
    end;
    if IsForAddTr then begin
          IsNewOrder := False;
    end;
end;



procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    SaveConfigs;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
    NewColumn: TListColumn;
    TempLangs: TStringList;
    f, i: integer;
    str: string;
begin
    with MainTable do begin
        NewColumn := Columns.Add;
        NewColumn.Caption := '№';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'ID';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Язык текста';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Язык перевода';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Страницы';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Старт';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Финиш';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Тематика';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Скорость';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Файлов';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Цена(клиента)';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Цена(переводчик)';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Заказчик';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Переводчик';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Комментарий';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Оценка';

        NewColumn := Columns.Add;
        NewColumn.Caption := 'Статус';
    end;
    LoadConfigs;
    MainTable.Columns.Items[16].Width := 0;
    cbDirection.Items.LoadFromFile('directions.txt');
    cbTrDirect.Items.LoadFromFile('directions.txt');
    TempLangs := TStringList.Create;
    TempLangs.LoadFromFile('languages.txt');
    LanguagesCount := TempLangs.Count;
    for i:=0 to TempLangs.Count-1 do begin
        str := TempLangs.Strings[i];
        cbTrLangs.Items.Add(Copy(str, 0, Pos(' ', str)-1));
        Languages[i].LanguageSolo := Copy(str, 0, Pos(' ', str)-1);
        Delete(str, 1, Length(cbTrLangs.Items.Strings[i])+1);
        Languages[i].LanguageFrom := Copy(str, 0, Pos(' ', str)-1);
        Delete(str, 1, Length(Languages[i].LanguageFrom)+1);
        Languages[i].LanguageTo := str;
        cbTranslatinglang.Items.Add(str);
    end;
    edLogin.Text := Username;
end;


procedure TFormMain.FormResize(Sender: TObject);
begin
    PanelAuth.Left := FormMain.Width div 2 - PanelAuth.Width div 2;
end;

procedure TFormMain.lbAllTranslatorsClick(Sender: TObject);
var
    i,
    index: integer;
    id: string;
begin
    if lbAllTranslators.ItemIndex = -1 then begin
        edTID.Text := '';
        edTSurname.Clear;
        edTName.Clear;
        edTEmail.Clear;
        edTPhone.Clear;
        edTDirection.Clear;
        edTLanguages.Clear;
        Exit;
    end;
    id := Copy(lbAllTranslators.Items.Strings[lbAllTranslators.ItemIndex], 0, 12);
    for i:=0 to Length(Translator)-1 do begin
        if id = Translator[i].id then begin
          index := i;
          edTID.Text := Translator[Index].id;
          edTSurname.Text := Translator[Index].surname;
          edTName.Text := Translator[Index].name;
          edTEmail.Text := Translator[Index].email;
          edTPhone.Text := Translator[Index].phone;
          edTDirection.Text := Translator[Index].direction;
          edTLanguages.Text := Translator[Index].languages;
          Break;
        end;
    end;
end;

procedure TFormMain.lbOrderTrasnlatorsClick(Sender: TObject);
var
    i,
    index: integer;
    id: string;
begin
    if lbOrderTrasnlators.ItemIndex = -1 then begin
        edTID.Text := '';
        edTSurname.Clear;
        edTName.Clear;
        edTEmail.Clear;
        edTPhone.Clear;
        EdTDirection.Clear;
        Exit;
    end;
    id := Copy(lbOrderTrasnlators.Items.Strings[lbOrderTrasnlators.ItemIndex], 0, 12);
    for i:=0 to Length(Translator)-1 do begin
        if id = Translator[i].id then begin
          index := i;
          edTID.Text := Translator[Index].id;
          edTSurname.Text := Translator[Index].surname;
          edTName.Text := Translator[Index].name;
          edTEmail.Text := Translator[Index].email;
          edTPhone.Text := Translator[Index].phone;
          EdTDirection.Text := Translator[Index].direction;
          Break
        end;
    end;
end;

procedure TFormMain.UpdateTable;
var
    Result: string;
    Json: TJSONObject;
    JSONArray: TJSONArray;
    i : integer;

begin
    try
        result := UpdateHttp.get(URL + '/management/getallorders/' +
                           '?token=' + token +
                           '&mid=' + mid);
    except on E: Exception do
        begin
            ShowMessage('Нет связи с сервером');
            TimerUpdate.Enabled := false;
            Exit;
        end;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    JSONArray := TJSONArray(json.GetValue('orders'));
    if JSONArray = nil then
        Exit;
//    if MainTable.Items.Count = JSONArray.Count then
//        Exit;
    SelectedItem := MainTable.Selected;
    MainTable.Clear;
    for i := 0 to JSONArray.Count - 1 do
    begin
        AddToListView(IntToStr(i+1),
                      TJSONArray(JSONArray.Items[i]).FindValue('o_id').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('lang_from').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('lang_to').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('pages').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('date_start').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('date_end').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('direction').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('urgency').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('file_count').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('price_to_client').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('price_to_translator').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('customer_id').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('translator_id').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('comment').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('rating').Value,
                      TJSONArray(JSONArray.Items[i]).FindValue('status').Value);
    end;
    MainTable.Selected := SelectedItem;
end;

procedure TFormMain.AddToListView(num, oid, lang_from, lang_to, pages, dstart, dfinish, direction,
                                  urgency, file_cnt, price_to_client, price_to_translator,
                                  customer_id, translator_id, comment, rating, status :string);
var
    ListItem: TListItem;
begin
   with MainTable do begin
        ListItem := Items.Add;
        ListItem.Caption := num;
        ListItem.SubItems.Add(oid);
        ListItem.SubItems.Add(lang_from);
        ListItem.SubItems.Add(lang_to);
        ListItem.SubItems.Add(pages);
        ListItem.SubItems.Add(dstart);
        ListItem.SubItems.Add(dfinish);
        ListItem.SubItems.Add(direction);
        ListItem.SubItems.Add(urgency);
        ListItem.SubItems.Add(file_cnt);
        ListItem.SubItems.Add(price_to_client);
        ListItem.SubItems.Add(price_to_translator);
        ListItem.SubItems.Add(customer_id);
        ListItem.SubItems.Add(translator_id);
        ListItem.SubItems.Add(comment);
        ListItem.SubItems.Add(rating);
        ListItem.SubItems.Add(status);
//        ListItem.SubItems.Add('');
//        ListItem.SubItemImages[4] := StrToInt(status);
    end;
end;

procedure TFormMain.edDirectionExit(Sender: TObject);
var
    Result: string;
    Json: TJSONObject;
    JSONTranslatorssArray: TJSONArray;
    i: integer;
    Data: TIdMultiPartFormDataStream;
begin
    Data := TIdMultiPartFormDataStream.Create;
    Data.AddFormField('mid', mid, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('token', Token, 'utf-8').ContentTransfer:='8bit';
    Data.AddFormField('direction', cbDirection.Text, 'utf-8').ContentTransfer:='8bit';
    try
        try
            Result := http.Post(URL + '/management/get_ready_translators/', Data)
        except on E: Exception do begin
            ShowMessage('Нет связи с сервером');
            TimerUpdate.Enabled := false;
            Exit;
            end;
        end;
    finally
        Data.Free;
    end;
    json := TJSONObject.ParseJSONValue(result) as TJSONObject;
    if json.GetValue('response').Value <> 'ok' then begin
        ShowMessage('Ошибка: ' + json.GetValue('response').Value);
        Exit;
    end;
    JSONTranslatorssArray := TJSONArray(json.GetValue('translators'));
    SetLength(Translator, JSONTranslatorssArray.Count);
    lbAllTranslators.Clear;
    for i:=0 to JSONTranslatorssArray.Count-1 do begin
        Translator[i].id := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('tid').Value;
        Translator[i].surname := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('surname').Value;
        Translator[i].name := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('name').Value;
        Translator[i].email := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('email').Value;
        Translator[i].phone := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('phone').Value;
        Translator[i].direction := TJSONArray(JSONTranslatorssArray.Items[i]).FindValue('direction').Value;
        lbAllTranslators.Items.Add(Translator[i].id + ' ' +
                                   Translator[i].surname + ' ' +
                                   Translator[i].name);
    end;
end;

procedure TFormMain.edPasswordKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #13 then
        btnAuth.OnClick(Sender);
end;


procedure TFormMain.LoadConfigs;
var
    Ini : TIniFile;
begin
    if FileExists(ExtractFilePath(ParamStr(0))+INI_FILE) then begin
        Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+INI_FILE);
        URL := Ini.ReadString('URL', 'address', 'http://192.168.1.62:8000');
        FormMain.Width := Ini.ReadInteger('FormSize', 'Width', 200);
        FormMain.Height := Ini.ReadInteger('FormSize', 'Heigh', 200);
        FormMain.Left := Ini.ReadInteger('FormPosition', 'x', 100);
        FormMain.Top := Ini.ReadInteger('FormPosition', 'y', 100);
        MainTable.Columns.Items[0].Width := Ini.ReadInteger('MainTable', 'WidthCol0', 100);
        MainTable.Columns.Items[1].Width := Ini.ReadInteger('MainTable', 'WidthCol1', 100);
        MainTable.Columns.Items[2].Width := Ini.ReadInteger('MainTable', 'WidthCol2', 100);
        MainTable.Columns.Items[3].Width := Ini.ReadInteger('MainTable', 'WidthCol3', 100);
        MainTable.Columns.Items[4].Width := Ini.ReadInteger('MainTable', 'WidthCol4', 100);
        MainTable.Columns.Items[5].Width := Ini.ReadInteger('MainTable', 'WidthCol5', 100);
        MainTable.Columns.Items[6].Width := Ini.ReadInteger('MainTable', 'WidthCol6', 100);
        MainTable.Columns.Items[7].Width := Ini.ReadInteger('MainTable', 'WidthCol7', 100);
        MainTable.Columns.Items[8].Width := Ini.ReadInteger('MainTable', 'WidthCol8', 100);
        MainTable.Columns.Items[9].Width := Ini.ReadInteger('MainTable', 'WidthCol9', 100);
        MainTable.Columns.Items[10].Width := Ini.ReadInteger('MainTable', 'WidthCol10', 100);
        MainTable.Columns.Items[11].Width := Ini.ReadInteger('MainTable', 'WidthCol11', 100);
        MainTable.Columns.Items[12].Width := Ini.ReadInteger('MainTable', 'WidthCol12', 100);
        MainTable.Columns.Items[13].Width := Ini.ReadInteger('MainTable', 'WidthCol13', 100);
        MainTable.Columns.Items[14].Width := Ini.ReadInteger('MainTable', 'WidthCol14', 100);
        MainTable.Columns.Items[15].Width := Ini.ReadInteger('MainTable', 'WidthCol15', 100);
        MainTable.Columns.Items[16].Width := Ini.ReadInteger('MainTable', 'WidthCol16', 100);
        Username := Ini.ReadString('Data', 'username', '');
        Ini.Free;
    end;
end;

procedure TFormMain.MainTableCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
    if Item.SubItems[15] = '1' then
        MainTable.Canvas.Brush.Color:=clYellow
    else if Item.SubItems[15] = '2' then
        MainTable.Canvas.Brush.Color:= clOlive
    else if Item.SubItems[15] = '25' then
        MainTable.Canvas.Brush.Color:= clGradientInactiveCaption
    else if Item.SubItems[15] = '26' then
        MainTable.Canvas.Brush.Color:= clGradientInactiveCaption
    else if Item.SubItems[15] = '3' then
        MainTable.Canvas.Brush.Color:= clAqua
    else if Item.SubItems[15] = '4' then
        MainTable.Canvas.Brush.Color:=clBlue
    else if Item.SubItems[15] = '5' then
        MainTable.Canvas.Brush.Color:=clNavy
    else if Item.SubItems[15] = '6' then
        MainTable.Canvas.Brush.Color:=clGreen
    else if Item.SubItems[15] = '7' then
        MainTable.Canvas.Brush.Color:=clSilver
    else if Item.SubItems[15] = '0' then
        MainTable.Canvas.Brush.Color:=clGray
end;

procedure TFormMain.SaveConfigs;
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
    Ini.WriteString('URL', 'address', URL);
    Ini.WriteInteger('FormSize', 'Width', FormMain.Width);
    Ini.WriteInteger('FormSize', 'Heigh', FormMain.Height);
    Ini.WriteInteger('FormPosition', 'x', FormMain.Left);
    Ini.WriteInteger('FormPosition', 'y', FormMain.Top);
    Ini.WriteInteger('MainTable', 'WidthCol0', MainTable.Columns.Items[0].Width);
    Ini.WriteInteger('MainTable', 'WidthCol1', MainTable.Columns.Items[1].Width);
    Ini.WriteInteger('MainTable', 'WidthCol2', MainTable.Columns.Items[2].Width);
    Ini.WriteInteger('MainTable', 'WidthCol3', MainTable.Columns.Items[3].Width);
    Ini.WriteInteger('MainTable', 'WidthCol4', MainTable.Columns.Items[4].Width);
    Ini.WriteInteger('MainTable', 'WidthCol5', MainTable.Columns.Items[5].Width);
    Ini.WriteInteger('MainTable', 'WidthCol6', MainTable.Columns.Items[6].Width);
    Ini.WriteInteger('MainTable', 'WidthCol7', MainTable.Columns.Items[7].Width);
    Ini.WriteInteger('MainTable', 'WidthCol8', MainTable.Columns.Items[8].Width);
    Ini.WriteInteger('MainTable', 'WidthCol9', MainTable.Columns.Items[9].Width);
    Ini.WriteInteger('MainTable', 'WidthCol10', MainTable.Columns.Items[10].Width);
    Ini.WriteInteger('MainTable', 'WidthCol11', MainTable.Columns.Items[11].Width);
    Ini.WriteInteger('MainTable', 'WidthCol12', MainTable.Columns.Items[12].Width);
    Ini.WriteInteger('MainTable', 'WidthCol13', MainTable.Columns.Items[13].Width);
    Ini.WriteInteger('MainTable', 'WidthCol14', MainTable.Columns.Items[14].Width);
    Ini.WriteInteger('MainTable', 'WidthCol15', MainTable.Columns.Items[15].Width);
    Ini.WriteInteger('MainTable', 'WidthCol16', MainTable.Columns.Items[16].Width);
    Ini.WriteString('Data', 'username', Username);
//    Ini.WriteInteger('OrderingTable', 'WidthCol1', OrderingTable.Columns.Items[0].Width);
//    Ini.WriteInteger('OrderingTable', 'WidthCol2', OrderingTable.Columns.Items[1].Width);
    Ini.Free;
end;

procedure TFormMain.tbConnectionClick(Sender: TObject);
begin
    if MainTable.Items.Count = 0 then
        Exit;
    if MainTable.Selected.SubItems.Strings[15] = '9' then
        IsNewOrder := False
    else
        IsNewOrder := True;
    if (PanelOrdering.Visible = False) and (MainTable.ItemIndex <> -1) and
       (MainTable.Selected.SubItems.Strings[15] = '1') then
        PanelOrderingShow(True, False)
    else if (PanelOrdering.Visible = False) and (MainTable.ItemIndex <> -1) and
            (MainTable.Selected.SubItems.Strings[15] <> '1') and
            (MainTable.Selected.SubItems.Strings[15] <> '9')
             then begin
                PanelOrderingShow(False, False);
            end;
    if MainTable.Selected.SubItems.Strings[15] = '9' then
        PanelOrderingShow(True, True);



end;

procedure TFormMain.tbCustomersClick(Sender: TObject);
begin
    FormCustomers.Show;
end;

procedure TFormMain.TimerUpdateTimer(Sender: TObject);
begin
    UpdateTable;
end;

procedure TFormMain.ToolButton1Click(Sender: TObject);
begin
    if PanelAddTranslator.Visible = False then begin
        ledName.Clear;
        ledSurname.Clear;
        ledEmail.Clear;
        ledPhone.Clear;
        lbTrsDirecs.Clear;
        lbTrsLangs.Clear;
        ledUsername.Clear;
        ledPassword.Clear;
        PanelAddTranslator.Visible := True;
    end
    else begin
        PanelAddTranslator.Visible := False;
    end;
end;



procedure TFormMain.tbTranslatorsClick(Sender: TObject);
begin
    FormTranslators.Show;
end;

procedure TFormMain.tbFinishOrderClick(Sender: TObject);
var
    Result: string;
    Json: TJSONObject;
    i: integer;
    Data: TIdMultiPartFormDataStream;
    fls: string;
    ArchName: string;
    cmd: string;
begin
    if MainTable.Items.Count = 0 then
        Exit;
    if (MainTable.Selected.SubItems.Strings[14] = '6') or
       (MainTable.Selected.SubItems.Strings[14] = '7') then begin
            MessageDlg('Заказ уже завершен!', mtError, [mbOK], 0);
            Exit;
       end;
    if not FileExists('C:\Program Files\WinRAR\rar.exe') then begin
        MessageDlg('Архиватор (C:\Program Files\WinRAR\rar.exe) отсутствует', mtError, [mbOK], 0);
        Exit;
    end;

    if FileOpenDialog.Execute then begin
        fls := '';
        for i:=0 to FileOpenDialog.Files.Count-1 do
            fls := fls + '"' + FileOpenDialog.Files.Strings[i] + '" ';
        Delete(fls, Length(fls), 1);
//        ArchName := 'D:\' + MainTable.Selected.SubItems.Strings[0] + '.rar';
        ArchName := ExtractFilePath(Application.ExeName) + MainTable.Selected.SubItems.Strings[0] + '.rar';
        cmd := 'C:\Program Files\WinRAR\rar.exe a ' + ArchName + ' ' + fls;
        ShellExecute(0,
                     'open',
                     'C:\Program Files\WinRAR\rar.exe',
                     PChar(' a -ep1 '+ArchName+' '+fls),
                     nil,
                     SW_HIDE);
        Sleep(2000);
        Data := TIdMultiPartFormDataStream.Create;
        Data.AddFormField('mid', mid, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('token', Token, 'utf-8').ContentTransfer:='8bit';
        Data.AddFormField('oid', MainTable.Selected.SubItems.Strings[0], 'utf-8').ContentTransfer:='8bit';
        Data.AddFile('file', ArchName, 'multipart/form-data');
        try
            try
                Result := http.Post(URL + '/management/finish_o/', Data)
            except on E: Exception do begin
                ShowMessage('Нет связи с сервером');
                TimerUpdate.Enabled := false;
                Exit;
                end;
            end;
        finally
            Data.Free;
        end;
        json := TJSONObject.ParseJSONValue(result) as TJSONObject;
        if json.GetValue('response').Value = 'ok' then begin
            MessageDlg('Заказ удачно отправлен заказчику', mtInformation, [mbOK], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'error_se' then begin
            MessageDlg('Ошибка при отправке файла на почту заказчика', mtError, [mbOK], 0);
            Exit;
        end;
        if json.GetValue('response').Value = 'order_finished' then begin
            MessageDlg('Данный заказ уже завершен', mtInformation, [mbOK], 0);
            Exit;
        end;
        if FileExists(ArchName) then
            DeleteFile(ArchName);
    end;
end;

end.

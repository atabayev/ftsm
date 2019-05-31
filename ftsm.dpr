program ftsm;

uses
  Vcl.Forms,
  Main in 'Main.pas' {FormMain},
  UnitTranslators in 'UnitTranslators.pas' {FormTranslators},
  UnitCustomers in 'UnitCustomers.pas' {FormCustomers};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormTranslators, FormTranslators);
  Application.CreateForm(TFormCustomers, FormCustomers);
  Application.Run;
end.

program setup;

uses
  Windows, Forms, Dialogs, Controls, ShellAPI;

{$R *.RES}

var
  ExePath: string;
  s: string;

begin
  Application.Initialize;

  ShellExecute(Application.Handle, nil, PChar(ExePath + 'setup\l3codecp.exe'),
    nil, nil, SW_NORMAL);

  s :=
    'Now we will update Windows Media Player so that your system can play '
  + 'MPEG Layer 3 files. But if you are using Windows 98 and/or Internet Explorer 4.0/5.0 '
  + ' (and higher) with built-in Windows Media Player, then you can skip this step '
  + 'by pressing [Cancel]. Otherwise, please press [OK].' + #13#10#13#10
  + 'Сейчас произойдет обновление "Универсального проигрывателя" Windows, чтобы '
  + 'в Вашей системе могли воспроизводиться файлы MPEG 3. Однако, если Вы '
  + 'уже установили Windows 98 и/или Internet Explorer версии 4.0/5.0 (или выше) '
  + 'со встроенным "Универсальным проигрывателем", то этот шаг можно пропустить '
  + 'нажатием кнопки [Cancel]. Иначе нажмите кнопку [OK].';

  if Application.MessageBox(PChar(s), 'CD Album Setup', MB_OKCANCEL + MB_DEFBUTTON2) = IDOK
  then
    ShellExecute(Application.Handle, nil, PChar(ExePath + 'setup\mpfull.exe'),
    nil, nil, SW_NORMAL);
end.

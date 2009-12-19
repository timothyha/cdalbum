                          TLanguage component
                          for Borland Delphi
                           by Serge Sushko,
                           sushko@iname.com
                    http://members.tripod.com/~sushko/

The TLanguage component was developed to add international language support to
Shareware Centrum -- the #1 tool for shareware programmers to track users and
reported bugs, register purchases, shareware archive uploads and much more. If
you like TLanguage component -- please support the author and download Shareware
Centrum from http://members.tripod.com/~sushko/sc/.

TLanguage is used to add international language support to existing and being
developing Delphi projects. TLanguage stores all language-specific string values
in separate INI files, one for each language, that adds your users ability to
create their own translations of your program interface.

Place a component to a form, set the Separator property to any string value
(supposelly, a comma or a semicolon) and fill the Properties property, listing
all component properties to be translated (current version of TLanguage
component supports only String and TStrings properties):
	MainForm.FileMenuItem.Caption
	MainForm.AboutMenuItem.Caption
	MainForm.HelpMenuItem.Caption
	MainForm.ExitMenuItem.Caption
	MainForm.FruitsLabel.Caption
	MainForm.LanguageLabel.Caption
	MainForm.AboutBtn.Caption
	MainForm.MessageBtn.Caption
	MainForm.AboutBtn.Hint
	MainForm.MessageBtn.Hint
	MainForm.FruitList.Items
Please note that you have to specify "full path" for every component property
you want to be translated, i.e. include property name, component name and all
component owner names up to and including it's form name.

For each language you want to add to your program create a separate ini file
with [Translations] and [Messages] sections. Write down the property names as
it was shown above to the [Translations] section of each file, and put the
property value translation after the equality symbol:
	[Translations]
	MainForm.FileMenuItem.Caption  = &File
	MainForm.AboutMenuItem.Caption = &About
	MainForm.HelpMenuItem.Caption = &Help
	MainForm.ExitMenuItem.Caption = &Exit
	MainForm.FruitsLabel.Caption = Fr&uits
	MainForm.LanguageLabel.Caption = &Select a language
	MainForm.AboutBtn.Caption = &About TLanguage
	MainForm.MessageBtn.Caption = &Show a message
	MainForm.AboutBtn.Hint = Please click here!
	MainForm.MessageBtn.Hint = Shows message in selected language
	MainForm.FruitList.Items = Apple,Strawberry,Cherry
Please be sure to put the translations to TStrings properties as a list of
values, separated by the symbol you used to store to the TLanguage.Separator
property (in the example above I used a comma symbol to separate item values
for the FruitList listbox).

In runtime, when user selects to change the interface language for your
application, set TLanguage.LanguageFile property to switch to specified
language, and Tlanguage.Translate method to perform translation for each listed
property:
	procedure TForm1.EnglishButtonClick(Sender : TObject);
	begin
	Language1.LanguageFile := 'english.ini';
	Language1.Translate;
	end;

To translate strings, other than component property values (for example, used in
MessageBox and MessageDlg functions), create [Messages] section in each language
file you provide with the application, and write down all the messages you use
with translation to the local language after the equality symbol:

	[messages]
	Selected fruit is = Selected fruit is
	No one fruit is selected = No one fruit is selected
	The program will now exit = The program will now exit
and then use TLanguage.TranslateUserMessage method to show messages in local
language:
	procedure TForm1.ExitMenuItemClick(Sender : TObject);
	begin
	ShowMessage(Language1.TranslateUserMessage('The program will now exit'));
	Application.Terminate;
	end;

To handle special translation cases, use OnBeforeTranslation, OnAfterTranslation and OnTranslate events.
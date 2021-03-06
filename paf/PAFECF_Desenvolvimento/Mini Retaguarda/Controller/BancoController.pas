{*******************************************************************************
Title: T2Ti ERP
Description: Unit de controle da tabela BANCO

The MIT License

Copyright: Copyright (C) 2010 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

       The author may be contacted at:
           t2ti.com@gmail.com</p>

@author Albert Eije (T2Ti.COM)
@version 1.0
*******************************************************************************}
unit BancoController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB, Windows, Forms, BancoVO, DBXCommon;

type
  TBancoController = class
  private
  protected
  public
    class Procedure Consulta(pFiltro: String; pPagina: Integer; pLookup: Boolean);
    class Procedure Insere(pBanco: TBancoVO);
    class Procedure Altera(pBanco: TBancoVO; pFiltro: String; pPagina: Integer);
    class Procedure Exclui(pId: Integer);
  end;

implementation

uses UDataModule, T2TiORM, Biblioteca;

var
  Banco: TBancoVO;

class procedure TBancoController.Consulta(pFiltro: String; pPagina: Integer; pLookup: Boolean);
var
  ResultSet : TDBXReader;
  i: integer;
begin
  try
    try
      pFiltro := StringReplace(pFiltro,'*','%',[rfReplaceAll]);
      ResultSet := TT2TiORM.Consultar(TBancoVO.Create, pFiltro, pPagina);

      if pLookup then
      begin
        FDataModule.CDSLookup.DisableControls;
        FDataModule.CDSLookup.EmptyDataSet;
        while ResultSet.Next do
        begin
          FDataModule.CDSLookup.Append;
          FDataModule.CDSLookup.FieldByName('ID').AsInteger := ResultSet.Value['ID'].AsInt32;
          FDataModule.CDSLookup.FieldByName('CODIGO').AsString := ResultSet.Value['CODIGO'].AsString;
          FDataModule.CDSLookup.FieldByName('NOME').AsString := ResultSet.Value['NOME'].AsString;
          FDataModule.CDSLookup.FieldByName('URL').AsString := ResultSet.Value['URL'].AsString;
          FDataModule.CDSLookup.Post;
        end;
        FDataModule.CDSLookup.Open;
        FDataModule.CDSLookup.EnableControls;
      end
      else
      begin
        FDataModule.CDSBanco.DisableControls;
        FDataModule.CDSBanco.EmptyDataSet;
        while ResultSet.Next do
        begin
          FDataModule.CDSBanco.Append;
          for I := 0 to FDataModule.CDSBanco.FieldCount -1 do
          begin
            if  ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].ValueType.DataType = 2 then
            begin
             if ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].GetDate > 0 then
                FDataModule.CDSBanco.Fields[i].AsString := DataParaTexto(ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].AsDateTime);
            end
            else
            if  ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].ValueType.DataType = 8 then
            begin
              if not ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].IsNull  then
              begin
                FDataModule.CDSBanco.Fields[i].AsFloat :=  ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].AsDouble;
              end
              else FDataModule.CDSBanco.Fields[i].AsFloat := 0;
            end
            else
            if ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].AsString <> '' then
              FDataModule.CDSBanco.Fields[i].AsString := ResultSet.Value[FDataModule.CDSBanco.FieldDefList[i].Name].AsString;
          end;
          FDataModule.CDSBanco.Post;
          {
          FDataModule.CDSBanco.Append;
          FDataModule.CDSBanco.FieldByName('ID').AsInteger := ResultSet.Value['ID'].AsInt32;
          FDataModule.CDSBanco.FieldByName('CODIGO').AsString := ResultSet.Value['CODIGO'].AsString;
          FDataModule.CDSBanco.FieldByName('NOME').AsString := ResultSet.Value['NOME'].AsString;
          FDataModule.CDSBanco.FieldByName('URL').AsString := ResultSet.Value['URL'].AsString;
          FDataModule.CDSBanco.Post;
          }
        end;
        //FDataModule.CDSBanco.Open;
        FDataModule.CDSBanco.EnableControls;
      end;
    except
    end;
  finally
    ResultSet.Free;
  end;
end;

class Procedure TBancoController.Insere(pBanco: TBancoVO);
var
  UltimoID:Integer;
begin
  try
    try
      UltimoID := TT2TiORM.Inserir(pBanco);
      Consulta('ID='+IntToStr(UltimoID),0, False);
    except
      Application.MessageBox('Ocorreu um erro. Inclus�o n�o realizada.', 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
  end;
end;

class Procedure TBancoController.Altera(pBanco: TBancoVO; pFiltro: String; pPagina: Integer);
begin
  try
    try
      TT2TiORM.Alterar(pBanco);
      Consulta(pFiltro, pPagina, False);
    except
      Application.MessageBox('Ocorreu um erro. Altera��o n�o realizada.', 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
  end;
end;

class Procedure TBancoController.Exclui(pId: Integer);
begin
  try
    try
      Banco := TBancoVO.Create;
      Banco.Id := pId;
      TT2TiORM.Excluir(Banco);
    except
      Application.MessageBox('Ocorreu um erro na exclus�o do cliente.', 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
  end;
end;

end.

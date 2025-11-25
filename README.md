# CustomTranspiler
Um transpilador que lê uma linguagem personalizada e traduz para um código PHP equivalente. 
Utiliza Lex para ler o texto, tranformando em tokens e Yacc para receber os tokens do Lex, verificar a gramática e executar as ações conforme a regra.

Nesse projeto foi criada uma nova linguagem onde o tradutor traduziu para a linguagem PHP.



### Requisitos para rodar
  - [WinFlexBison](https://github.com/lexxmark/winflexbison)
  - [GCC compiler](https://www.mingw-w64.org/)

### Como rodar
  Usando CMD

1. Gerar arquivo lexer
   ```
   win_flex main.l
   ```

3. Gerar arquivo parser
   ```
   win_bison -dy main.y
   ```

5. Compilar arquivos gerados com GCC
   ```
   gcc lex.yy.c y.tab.c -o tradutor.exe
   ```

7. Executar o compilador
   ```
   tradutor.exe input.txt
   ```

8. `output.php` representa a linguagem trazudida do `input.txt` para a linguagem PHP.

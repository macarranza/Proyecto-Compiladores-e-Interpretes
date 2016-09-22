
/* --------------------------Codigo de Usuario----------------------- */
package interpreteperlasintactico;

import java_cup.runtime.*;
import java.io.Reader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

//clase de los token devueltos
class Yytoken {
    Yytoken (int numToken,String token, String tipo, int linea, int columna)
    {
        //Contador para el número de tokens reconocidos
        this.numToken = numToken;
        //String del token reconocido
        this.token = new String(token);
        //Tipo de componente léxico encontrado
        this.tipo = tipo;
        //Número de linea
        this.linea = linea;
        //Columna donde empieza el primer carácter del token
        this.columna = columna;
    }
    //Métodos de los atributos de la clase
    public int numToken;
    public String token;
    public String tipo;
    public int linea;
    public int columna;
    //Metodo que devuelve los datos necesarios que escribiremos en un archive de salida
    public String toString() {
        return "Token #"+numToken+": "+token+"  "+tipo+" ["+(linea+1)
        + "," +(columna+1) + "]";
    }
}

%% //inicio de opciones  
/* ------ Seccion de opciones y declaraciones de JFlex -------------- */  
   
/* 
    Cambiamos el nombre de la clase del analizador a Lexer
*/

%class AnalizadorLexico

/*
    Activar el contador de lineas, variable yyline
    Activar el contador de columna, variable yycolumn
*/
%line
%column
    
/* 
   Activamos la compatibilidad con Java CUP para analizadores
   sintacticos(parser)
*/
%cup
  
 
/*
    Declaraciones

    El codigo entre %{  y %} sera copiado integramente en el 
    analizador generado.
*/
%{


    private int contador;
    private ArrayList<Yytoken> tokens;
    
    private void writeOutputFile(String file,Yytoken t) throws IOException
        {
            String filename = file;
            BufferedWriter out = new BufferedWriter(new FileWriter(filename,true));
           // System.out.println("\n*** Tokens guardados en archivo ***\n");
            
                System.out.println(t);
                out.write(t + "\n");
            
            out.close();
	}

        private void writeOutputFileError(String file,String error) throws IOException
        {
            String filenameerror = file;
            BufferedWriter out = new BufferedWriter(new FileWriter(filenameerror,true));
            //System.out.println("\n*** Tokens guardados en archivo ***\n");
            
            out.write(error + "\n");
            out.close();
            
	}

//Obtenemos lista de tokens
        public ArrayList<Yytoken> getListaTokens() throws IOException
        {
            System.out.println("\n*** Lista***\n");
            for(Yytoken t: this.tokens)
            {
                System.out.println(t);
                
            }
            return this.tokens;
	}





    /*  Generamos un java_cup.Symbol para guardar el tipo de token 
        encontrado */
    private Symbol symbol(int type) {
        
        return new Symbol(type, yyline, yycolumn);
    }
    
    /* Generamos un Symbol para el tipo de token encontrado 
       junto con su valor */
    private Symbol symbol(int type, Object value) {
        
        return new Symbol(type, yyline, yycolumn, value);
    }
    
%}


%init{
    try {
          contador = 0;
          tokens = new ArrayList<Yytoken>();
          BufferedWriter out = new BufferedWriter(new FileWriter("file.out"));
           out.close();

           BufferedWriter outError = new BufferedWriter(new FileWriter("error.out"));
           outError.close();
          
      } catch (IOException ex) 
        {
          System.out.println("error: "+ex);
        } 
%init}   


//Cuando se alcanza el fin del archivo de entrada
%eof{
	/*try
        {
            this.writeOutputFile("file.out");
            //System.exit(0);
	}
        catch(IOException ioe)
        {
            ioe.printStackTrace();
	}*/
%eof}
/*
    Macro declaraciones
  
    Declaramos expresiones regulares que despues usaremos en las
    reglas lexicas.
*/
   
/*  Un salto de linea es un \n, \r o \r\n dependiendo del SO   */
Salto = \r|\n|\r\n
   
/* Espacio es un espacio en blanco, tabulador \t, salto de linea 
    o avance de pagina \f, normalmente son ignorados */
Espacio     = {Salto} | [ \t\f]
   
/* Una literal entera es un numero 0 oSystem.out.println("\n*** Generado " + archNombre + "***\n"); un digito del 1 al 9 
    seguido de 0 o mas digitos del 0 al 9 */
NUMERO = 0 | [1-9][0-9]*
EXP_DIGITO = [0-9]
EXP_ALPHA = [A-Z]|[a-z]
EXP_ALPHANUMERIC={EXP_ALPHA}|{EXP_DIGITO}
IDENTIFICADOR={EXP_ALPHA}({EXP_ALPHANUMERIC})*
COMILLA=[\"]
COMILLASIMPLE=[']
STRINGCOMPLEJO = {COMILLA}[a-zA-Z0-9\-\+\*/\@\$\%\^\&\s]*{COMILLA}
INICIOCOMENTARIO = ["/*"]
CERRARCOMENTARIO = ["*/"]
COMENTARIO = {INICIOCOMENTARIO}.*{CERRARCOMENTARIO}

%% //fin de opciones
/* -------------------- Seccion de reglas lexicas ------------------ */
   
/*
   Esta seccion contiene expresiones regulares y acciones. 
   Las acciones son código en Java que se ejecutara cuando se
   encuentre una entrada valida para la expresion regular correspondiente */
   
   /* YYINITIAL es el estado inicial del analizador lexico al escanear.
      Las expresiones regulares solo serán comparadas si se encuentra
      en ese estado inicial. Es decir, cada vez que se encuentra una 
      coincidencia el scanner vuelve al estado inicial. Por lo cual se ignoran
      estados intermedios.*/
   
<YYINITIAL> {
    /*se establece la palabra reservada ASIGNACION*/
    "="            {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ASIGNACION",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" = ");
                            return symbol(sym.ASIGNACION);
                        }

    /*Se establece la palabra reservada EQUIVALENCIA*/
    "=="               {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"EQUIVALENCIA",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" == ");
                            return symbol(sym.EQUIVALENCIA);
                        }
    /*Se establece el token WRITE*/
    "!="             {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"DIFERENCIA",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" != ");
                            return symbol(sym.DIFERENCIA);
                        }

    /*Se establece el token AND*/
    "&"              {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"AND",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" & ");
                            return symbol(sym.AND);
                        }
    
    /*TOKEN para reconocer la ANDAND*/
    "&&"                 {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ANDAND",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" && ");
                            return symbol(sym.ANDAND);
                        }

    /* Regresa que el token PUNTOCOMA declarado en la clase sym fue encontrado. */
    "|"                { 
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"OR",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" | ");
                            return symbol(sym.OR); 
                        }

    "||"               {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"OROR",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" || ");
                            return symbol(sym.OROR);
                        }

    /* Regresa que el token MAS declarado en la clase sym fue encontrado. */
    "+"                {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MAS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" + ");
                            return symbol(sym.MAS); 
                        }
    /* Regresa que el token MASMAS declarado en la clase sym fue encontrado. */
    "++"                {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MASMAS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" ++ ");
                            return symbol(sym.MASMAS); 
                        }
   
    /* Regresa que el token MULTI declarado en la clase sym fue encontrado. */
    "*"                {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MULTI",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" * ");
                            return symbol(sym.MULTI); 
                        }
    /* Regresa que el token MENOS declarado en la clase sym fue encontrado. */
    "-"                { 
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MENOS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" - ");
                            return symbol(sym.MENOS); 
                        }
   
    /*MENOSMENOS*/
    "--"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MENOSMENOS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" -- ");
                            return symbol(sym.MENOSMENOS); 
                        }

    /*DIV*/
    "/"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"DIV",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" / ");
                            return symbol(sym.DIV); 
                        }

    "<"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MENORQUE",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" < ");
                            return symbol(sym.MENORQUE); 
                        }
    "<="
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MENORIGUALQUE",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" <= ");
                            return symbol(sym.MENORIGUALQUE); 
                        }
    ">"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MAYORQUE",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" > ");
                            return symbol(sym.MAYORQUE); 
                        }
    "=>"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MAYORIGUALQUE",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" => ");
                            return symbol(sym.MAYORIGUALQUE); 
                        }

    "("
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ABRIRPARENTESIS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" ( ");
                            return symbol(sym.ABRIRPARENTESIS); 
                        }
    ")"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CERRARPARENTESIS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" ) ");
                            return symbol(sym.CERRARPARENTESIS); 
                        }
    "["
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ABRIRBRACKETS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" [ \n");
                            return symbol(sym.ABRIRBRACKETS); 
                        }
    "]"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CERRARBRACKETS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" ]\n ");
                            return symbol(sym.CERRARBRACKETS); 
                        }
    "{"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ABRIRLLAVES",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" {\n ");
                            return symbol(sym.ABRIRLLAVES); 
                        }
    "}"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CERRARLLAVES",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("}\n");
                            return symbol(sym.CERRARLLAVES); 
                        }
    ";"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"PUNTOCOMA",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" ;\n");
                            return symbol(sym.PUNTOCOMA); 
                        }
    ","
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"COMA",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" , ");
                            return symbol(sym.COMA); 
                        }
    ":"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"DOSPUNTOS",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(": ");
                            return symbol(sym.DOSPUNTOS); 
                        }

    "$"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"DOLAR",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" $");
                            return symbol(sym.DOLAR); 
                        }
    "@"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"AT",yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(" @");
                            return symbol(sym.AT); 
                        }
    
    "my"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"MY",yyline,yycolumn);
                            tokens.add(t);

                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("MY");
                            return symbol(sym.MY); 
                        }
    "fun"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"FUN",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("FUN");
                            return symbol(sym.FUN); 
                        }
    "if"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CONDICIONIF",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("CONDICIONIF");
                            return symbol(sym.CONDICIONIF); 
                        }
    "else"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CONDICIONELSE",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("CONDICIONELSE");
                            return symbol(sym.CONDICIONELSE); 
                        }
    "elsif"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CONDICIONELSIF",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("CONDICIONELSIF");
                            return symbol(sym.CONDICIONELSIF); 
                        }
    "switch"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CONDICIONSWITCH",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("CONDICIONSWITCH");
                            return symbol(sym.CONDICIONSWITCH); 
                        }
    "case"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CONDICIONCASE",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("CONDICIONCASE");
                            return symbol(sym.CONDICIONCASE); 
                        }
    "default"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"CONDICIONDEFAULT",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("CONDICIONDEFAULT");
                            return symbol(sym.CONDICIONDEFAULT); 
                        }
    "while"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"BUCLEWHILE",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("BUCLEWHILE");
                            return symbol(sym.BUCLEWHILE); 
                        }
    "do"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"BUCLEDO",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("BUCLEDO");
                            return symbol(sym.BUCLEDO); 
                        }
    "for"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"BUCLEFOR",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("BUCLEFOR");
                            return symbol(sym.BUCLEFOR); 
                        }
    "foreach"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"BUCLEFOREACH",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("BUCLEFOREACH");
                            return symbol(sym.BUCLEFOREACH); 
                        }
    "return"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"RETORNO",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("RETORNO");
                            return symbol(sym.RETORNO); 
                        }
    "print"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"PRINT",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("PRINT");
                            return symbol(sym.PRINT); 
                        }
    "shift"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"SHIFT",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("SHIFT");
                            return symbol(sym.SHIFT); 
                        }
    "unshift"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"UNSHIFT",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("UNSHIFT");
                            return symbol(sym.UNSHIFT); 
                        }
    "pop"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"POP",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("POP");
                            return symbol(sym.POP); 
                        }
    "push"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"PUSH",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("PUSH");
                            return symbol(sym.PUSH); 
                        }
    "length"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"LARGOLISTA",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("LARGOLISTA");
                            return symbol(sym.LARGOLISTA); 
                        }
    "break"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"BREAK",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("BREAK");
                            return symbol(sym.BREAK); 
                        }
    "join"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"JOIN",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("JOIN");
                            return symbol(sym.JOIN); 
                        }
    "split"
                        {  
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"SPLIT",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print("SPLIT");
                            return symbol(sym.SPLIT); 
                        }
    
    
    
    /* Si se encuentra un entero, se imprime, se regresa un token numero
        que representa un entero y el valor que se obtuvo de la cadena yytext
        al convertirla a entero. yytext es el token encontrado. */
    {NUMERO}            {   
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"NUMERO",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(yytext()+" "); 
                            return symbol(sym.NUMERO, new Integer(yytext())); 
                        }

    /*IDENTIFICADOR*/
    {IDENTIFICADOR}     {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ID",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(yytext()); 
                            return symbol(sym.ID,new String(yytext()));
                        }
    /* No hace nada si encuentra el espacio en blanco */
    {Espacio}           {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"ESPACIO",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            //writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(yytext()); 
                            return symbol(sym.ESPACIO,new String(yytext()));
                        } 
    {COMENTARIO}  {/*ignorar el comentario*/}

    {STRINGCOMPLEJO}
                        {
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),"STRINGCOMPLEJO",yyline,yycolumn);
                            tokens.add(t);
                             /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            //System.out.print(yytext()); 
                            return symbol(sym.STRINGCOMPLEJO,new String(yytext()));
                        }

}



/* Si el token contenido en la entrada no coincide con ninguna regla
    entonces se marca un token ilegal */
[^]                    
                        { 
                            contador++;
                            Yytoken t = new Yytoken(contador,yytext(),
                            "Error Lexico, caracter desconocido: "+yytext()+" , en la linea "+(yyline+1) +" y la columna "+(yycolumn+1),
                            yyline,yycolumn);
                            tokens.add(t);
                            /*----------------- SAVE ----------------------*/
                            writeOutputFile("file.out",t);
                            /*---------------------------------------------*/
                            
                            this.writeOutputFileError("error.out",
                            "Error Lexico, caracter desconocido: "+yytext()+"  ,en la linea "+(yyline+1) +" y la columna "+(yycolumn+1));
                            //return symbol(sym.error);
                            //throw new Error("Caracter ilegal <"+yytext()+">"); 
                        }

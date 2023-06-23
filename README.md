# Laboratorio - Compilatori 2023

  

Questo progetto di Laboratorio per il corso di Compilatori consiste nella creazione di un analizzatore sintattico per un linguaggio semplificato che permette la manipolazione di insiemi e l'esecuzione di operazioni su di essi.

L'analizzatore inoltre traduce le operazioni fornite in input in un Abstract Syntax Tree (AST).

  

## Specifiche

Il programma accetta input da standard input e può elaborare le seguenti istruzioni:

1. **Assegnamento di un insieme a una variabile**: Permette di assegnare un insieme a una variabile rappresentata da un singolo carattere maiuscolo. L'istruzione segue il formato: 
`A = s11000000000000000000000000000001;`
Nell'esempio riportato, l'insieme A corrisponde a {0, 30, 31}.

2. **Aggiunta di un elemento a un insieme**: Consente di aggiungere un elemento a un insieme esistente.
L'istruzione ha il formato: ``Aggiungi i3 ad sA;``
Questa istruzione modifica l'insieme A aggiungendo l'elemento 3, quindi il nuovo valore di A diventa `11000000000000000000000000001001`. Nell'esempio, l'insieme A corrisponde a {0, 3, 30, 31}.

3. **Operazioni binarie e unarie sugli insiemi**: Supporta operazioni come *unione*, *intersezione*, *differenza* e *complemento* tra insiemi. Il risultato dell'operazione viene restituito come output. 
Sintassi delle operazioni: 
Ecco un esempio di istruzione: `A u B;`
Si assuma di avere `A = 11000000000000000000000000001001` e
`B = 11100000000000000000000000000001`
`A u B = 11100000000000000000000000001001`

Le istruzioni possono essere concatenate per formare espressioni più complesse, utilizzando anche le parentesi. Ecco alcuni esempi di espressioni valide:
-   `(A u B) u (B-A);`
-   `(Aggiungi i3 ad sA) u B u (C-D);`

*N.B.: Ogni istruzione è terminata da `;`* 

## Sintassi delle Operazioni Insiemistiche
Le operazioni insiemistiche supportate nel linguaggio sono definite utilizzando i seguenti simboli:
-   Unione: `u`
-   Intersezione: `in`
-   Differenza: `-`
-   Complemento: `~`

## Esempio di esecuzione
Per compilare:

    make

È possibile eseguire il programma d'esempio con il comando:

    ./set_language < test.txt

Codice di input:

    A = s11111000000000000000000000000011;
    B = s01110000001010101000000000000000;
    
    A u B;
    
    A in B;
    
    C = s10101010101010101010101010101010;
    D = s11111110000000000000000000000000;
    
    (Aggiungi i3 ad sA) u B u (D in ~C);

Output:

    A:  0 1 27 28 29 30 31
    B:  15 17 19 21 28 29 30
    
    Unione
      A
      B
    Result:  0 1 15 17 19 21 27 28 29 30 31
    
    
    Intersezione
      A
      B
    Result:  28 29 30
    
    C:  1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31
    D:  25 26 27 28 29 30 31
    
    Unione
      Unione
        Aggiungi
          3
          A
        B
      Intersezione
        D
        Complemento
          C
    Result:  0 1 3 15 17 19 21 26 27 28 29 30 31



Tema1-PP
========
Readme 
Claudia Rogoz

*Pentru partea 1:

Symbolic regression:
Calcularea lui errorii de aproximare s-a relizat cu ajutorul functionalelor map si foldl;
Pentru evaluarea functiei generate pentru fiecare x care apartine lui RANGE, m-am folosit de o functie numita eval-tree. Parametrii formali sunt ast(functia de evaluat), si val_x(valoarea x pentru care se va calcula functia).

Eval-tree este recursiva pe stiva si verifica pe rand daca elementul curent este un literar sau numar (=> s-a ajuns la un terminal);
daca ne aflam la o lista ce contine doar 3 elemente, inseamna ca este o expresie simpla de forma; (operator operand1 operand2) si se evalueaza functia recursiv pe cei 2 subarbori "operand1" si "operand2" cu radacina "operator".

In "deviation" se face suma erorilor diferentei dintre valorile celor 2 functii (cea generata si cea pe care dorim sa o gasim -> SAMPLE) cu ajutorul lui foldl.

Totodata, am lasat in acest fisier si functia comentata errorS care se poate folofi ca un substitut pentru eval-tree. (mi-a fost necesara pentru partea a 2-a).

Aceasta foloseste un alt sistem: si anume intarzierea evaluarii.
Am utilizat constructia let pentru legarea variabilei value-function de valoarea (eval `((eval `(λ(,'x) ,ast))val_x)). Aceasta valuare reprezinta exact valuarea functiei pentru x = val_x;

In acest scop am folosit quasiqoute. Am fortat ca evaluarea expresiei sa fie lenesa, mai putin asocierea variabilei x cu valoarea corespunzatoare(val_x), lucru realizat cu ajutorul ",";
Astfel substitutia se face numai pentru 'x, iar apoi expresia este evaluata in mod normal.

Cu aceasta implementare (errorS fata de eval-tree), am observat ca functia (evolve) este mai costisitoare ca timp.

Pentru size, m-am folosit de o functie ajutatoare size-recursive , recursiva pe stiva care daca ajunge la un terminal intoarce 1; altfel continua recursiv pe restul listei pana ajunge sa parcurga toata lista;

Totodata, am lasat in acest fisier si o alta varianta pentru calculul lungimii ast-ului: (length(flatten ast)); Prin flatten, "ast" este vazut ca un arbore binar ale carui perechi sunt noduri interne;prin flatten se obtine astfel o lista cu toate terminalele non-null ale lui ast. Lungimea lui ast este data de lungimea listei de terminali obtinuti prin flatten.

Pentru partea a doua:

**Genetic-images:

Am implementat mai multi terminali, 
XS = reprezinta cateva imagini care se pot alege la intamplare, un fel de RANGE din symbolic-regression

Am definit SAMPLE-width, SAMPLE-height, SAMPLE-length pentru definirea latimii, lungimii, respectiv benzii de culori ai imaginii fata de care se studiaza (SAMPLE).

Am definit random-angle care va returna un numar intreg aleator intre 1 si 360.
Am definit random-scale care va returna un numar real intre 0 si 2.0.

Am modificat generate pentru a putea fi compatibil cu noile tipuri: image, 360, 2.0;
In aceasta functie m-am folosit de 3 constructii let.Ideea ar fi urmatoarea; 
	Daca depth ajunge la 0 sau daca (metoda aleasa este grow si in urma unui random se obtine 0), atunci recursivitatea se opreste si se alege un terminal (o imagine);
	Altfel se alege o functie care sa fie aplicata din cadrul functiilor posibile
	aceasta functie se adauga la lista care va reprezenta in final tree-ul pentru genetic-images. intr-o constructie let se face legarea variabilei no_of_parameters la lungimea parametrilor necesari functiei alese (de exemplu pentru scale, lungimea va fi de 2 adica un parametru de tipul 0.2 si un paramentru de tipul image). Totodata se face legarea lui type la valoarea data de tipul primului operand (360, image sau 0.2);
	In functie de numarul de parametrii ramasi si de tipul primului parametru al functiei, se adauga la lista un nou subarbore.
	
	Pentru calcularea deviatiei m-am folosit de distanta euclidiana intre 2 imagini dupa formula : sqrt (sum [(red_img1-red_img2)^2 + (blue_img1-blue_img2)^2+ (green_img1 - green_img2)^2 ])
	Euclidian-image-distance este recurursiva pe coada. 
	
	Evaluarea tree-ului pentru una dintre valorile lu x din XS se face cu errorS (explicata mai devreme).
	
	Deviation se foloseste de euclidian-image-distance; Totodata pentru ca imaginile comparate sa aiba acelasi numar de valori in urma aplicarii lui image-.color-list, m-am ajutat de place-image ( plaseaza imaginea respectiva in mijlocul uni "scene" de aceeasi marime cu SAMPLE);
	
	
	Am modificat modify-random care compara pe rand tipurile pentru a inlocui subarborele ales cu tipul corespunzator;
	
	Cateva imagini in urma generarii se pot vedea in cadrul fisierului atasat some_images.rkt

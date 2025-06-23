%_____________________________________________________________________________________
%Trabalho 01 - Programação Lógica
%Docente: Luiz Eduardo da Silva
%Objetivo: Fazer um programa que implemente uma solução ao problema dos missionários
%		   e canibais, dados a quantidade de missionários/canibais e a capacidade do 
%		   barco
%Discente: Gean Marques
%Matrícula: 2019.1.08.006
%_____________________________________________________________________________________
%Implementação do estado seguro:
%Implementação do estado seguro geral:
seguro(M, C) :-
    M >= C;
    M == 0.

%Implementação do estado seguro em cada lado do rio:
%Legenda:	M/C   -> Missionários/Canibais
%			ME/CE -> Missionários/Canibais do lado esquerdo;
%			MD/CD -> Missionários/Canibais do lado direito.
estado_seguro(estado(ME, CE, MD, CD, _)) :-
    seguro(ME, CE),
    seguro(MD, CD).

%_____________________________________________________________________________________
%Impelementação dos movimentos possíveis para os barcos/pessoas:
%O primeiro 'estado' representa o estado inicial da operação;
%o segundo 'estado' representa o estado final, após a operação ser realizada.
%Cap representa a capacidade total do barco.
%'a' e 'b' representam a posição do barco naquele estado.
%Cada predicado mover/3 transfere o barco de uma margem à outra, por isso há 2.
%1º between garante que o barco fará o transporte com, no mínimo, 1 pessoa
%presente e, no máximo, a sua capacidade total.
%2º between define quantos missionários (M), irão no barco; entre total e 0.
mover(estado(ME, CE, MD, CD, a), estado(NME, NCE, NMD, NCD, b), Cap) :-
    between(1, Cap, Total),
    between(0, Total, M),
    C is Total - M,
    %Garantia de que há M/C suficientes para o embarque:
    ME >= M, CE >= C,
    %Cálculos do novo estado:
    NME is ME - M, NCE is CE - C,
    NMD is MD + M, NCD is CD + C,
    %Garantia de que o novo estado é seguro:
    estado_seguro(estado(NME, NCE, NMD, NCD, b)).

%Comentários relativos ao funcionamento acima; a única diferença é a posição atual
%do barco.
mover(estado(ME, CE, MD, CD, b), estado(NME, NCE, NMD, NCD, a), Cap) :-
    between(1, Cap, Total),
    between(0, Total, M),
    C is Total - M,
    MD >= M, CD >= C,
    NMD is MD - M, NCD is CD - C,
    NME is ME + M, NCE is CE + C,
    estado_seguro(estado(NME, NCE, NMD, NCD, a)).

%_____________________________________________________________________________________
%Implementação da execução do programa:
%Legenda:	N 			-> Número de missionários/canibais no estado inicial;
%			Cap 		-> Capacidade total do barco;
%			EstadoFinal -> Último estado do barco
solucao(N, Cap, EstadoFinal) :-
    %Estado inicial, com número de M/C refletido.
    EstadoInicial = estado(N, N, 0, 0, a),
    %Estado final, desejado.
    EstadoObjetivo = estado(0, 0, N, N, b),
    %Chamada da busca recursiva para encontrar os estados:
    busca(EstadoInicial, EstadoObjetivo, Cap, [EstadoInicial], Solucao),
    %Reverso da lista, explicação nas notas:
    reverse(SolucaoReversa, Solucao),
    %Impressão das iterações passo-a-passo e do último estado:
    imprimir_caminho(SolucaoReversa, Cap),
	last(SolucaoReversa, EstadoFinal).

%_____________________________________________________________________________________
%Implementação da busca recursiva dos estados.
%Fato:
busca(Estado, Estado, _, Visitados, Visitados).
%Regra: passando como parâmetros o estado atual e objetivo, a capacidade do barco,
%os estados já visitados e a solução, que é composta dos estados visitados junto
%do novo estado encontrado para a solução.
busca(Atual, Objetivo, Cap, Visitados, Solucao) :-
    mover(Atual, Proximo, Cap),
    %Para evitar um loop, temos a garantia de que o estado atual ainda não foi
    %visitado através da checagem:
    \+ member(Proximo, Visitados),
    %Chamada recursiva:
    busca(Proximo, Objetivo, Cap, [Proximo|Visitados], Solucao).

%_____________________________________________________________________________________
%Implementação da visualização do problema de forma mais clara.
%Imagino que o erro da nota (2) esteja aqui (não estava).
imprimir_caminho([], _).
imprimir_caminho([H|T], Cap) :-
    desenha(H, Cap),
    nl,
    %Chamada recursiva da impressão:
    imprimir_caminho(T, Cap).

%Predicado recursivo para substuir M/C por símbolos, muito importante!
repete(_, 0).
repete(Simbolo, N) :-
    N > 0,
    write(Simbolo),
    N1 is N - 1,
    repete(Simbolo, N1).

%Desenho quando o barco está do lado esquerdo.
desenha(estado(ME, CE, MD, CD, a), _) :-
    write('Margem Esquerda: '),
    repete('👨', ME),
    repete('😈', CE),
    write('   🚣 ~~~~~~~~   '),
    repete('👨', MD),
    repete('😈', CD),
    write(' :Margem Direita'), nl.

%Desenho quando o barco está do lado direito.
desenha(estado(ME, CE, MD, CD, b), _) :-
    write('Margem Esquerda: '),
    repete('👨', ME),
    repete('😈', CE),
    write('   ~~~~~~~~ 🚣   '),
    repete('👨', MD),
    repete('😈', CD),
    write(' :Margem Direita'), nl.

%_____________________________________________________________________________________
%Interessante:																		  
%(1) mesmo que o barco possa levar até 3 pessoas, como o algoritmo trabalha como
%uma busca em árvore de estados, é provável que ele irá optar pela opção de levar
%apenas 2 pessoas até que seja obrigatório o uso de 3 para chegar a um estado seguro.
%Isso fica claro no uso do between e ao usarmos um barco com capacidade maior, mas
%com a mesma quantidade de pessoas.
%(2) por alguma razão, a busca estava invertendo o lado direito com o esquerdo.
%Para evitar um trabalho maior, adicionei um reverse na impressão e deu tudo certo.
%Depois de um tempo refletindo, pensei em solucionar usando append para construir
%a lista de soluções dentro do predicado busca, porém, visto que o resultado não
%seria alterado, preferi deixar como está.
%(3) a ideia do uso de símbolos (emojis) na representação veio quando pedi ao
%ChatGPT para realizar a organização das etapas de forma mais visual. Decidi
%manter dessa forma.
%_____________________________________________________________________________________
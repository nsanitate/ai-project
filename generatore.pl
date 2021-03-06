/***
	@descr Generatore di sequenze di workflow comprendenti rumore a partire da un modello di workflow
	@author Nicola Sanitate
	@date 18/10/2011
*/
:- use_module(library(lists)).
:- use_module(library(random)).

/**
	@descr Start:
	 gestore dell'intero processo di generazione delle sequenze; provvede a:
	 <ol>
	  <li>leggere il modello di workflow da file wf-net-in</li>
	  <li>generare delle sequenze di workflow</li>
	  <li>stampare le sequenze ottenute su file workflow.log applicandovi il rumore</li>
	 </ol>
	@form start(,+PercentualeRumore)
*/
start(0) :-
	consult('wf-net-in'),
	generazione(1000,Sequenze),
	stampa(Sequenze,0),
	abolish(in/2),
	abolish(out/2).
start(PercentualeRumore) :-
	consult('wf-net-in'),
	generazione(1000,Sequenze),
	FrequenzaRumore is 100 // PercentualeRumore,
	stampa(Sequenze,FrequenzaRumore),
	abolish(in/2),
	abolish(out/2).

/**
	@descr Generazione delle sequenze:
	 genera delle sequenze di workflow
	@form generazione(+NumeroSequenze,-Sequenze)
*/
generazione(0,[]).
generazione(NumeroSequenze,[Sequenza|AltreSequenze]) :-
	NuovoNumeroSequenze is NumeroSequenze - 1,
	generazione_sequenza(sb,[sb],se,Sequenza),
	generazione(NuovoNumeroSequenze,AltreSequenze).

/**
	@descr Generazione di una sequenza:
	 genera una sequenza di workflow
	@form generazione_sequenza(+PostoPartenza,+ListaToken,+PostoArrivo,-Sequenza)
*/
generazione_sequenza(PostoArrivo,_,PostoArrivo,[]).
generazione_sequenza(PostoPartenza,ListaToken,PostoArrivo,[Transizione|AltreTransizioni]) :-
	setof(X,in(PostoPartenza,X),TransizioniRaggiungibili),
	elemento_random(TransizioniRaggiungibili,Transizione),
	setof(X,in(X,Transizione),PostiPrecedenti),
	differenza_liste(PostiPrecedenti,ListaToken,Resto),
	setof(X,out(Transizione,X),PostiSuccessivi),
	append(Resto,PostiSuccessivi,NuovaListaToken),
	elemento_random(ListaToken,NuovoPostoPartenza),
	generazione_sequenza(NuovoPostoPartenza,NuovaListaToken,PostoArrivo,AltreTransizioni).
generazione_sequenza(_,ListaToken,PostoArrivo,ListaTransizioni) :-
	elemento_random(ListaToken,NuovoPostoPartenza),
	generazione_sequenza(NuovoPostoPartenza,ListaToken,PostoArrivo,ListaTransizioni).

/**
	@descr Differenza tra liste:
	 ricava la lista differenza di due liste
	@form differenza_liste(+ListaSottraendo,+ListaMinuendo,-ListaDifferenza)
*/
differenza_liste([],ListaMinuendo,ListaMinuendo).
differenza_liste([Elemento|AltriElementi],ListaMinuendo,ListaDifferenza) :-
	select(Elemento,ListaMinuendo,ListaRimanente),!,
	differenza_liste(AltriElementi,ListaRimanente,ListaDifferenza).

/**
	@descr Selezione di un elemento casuale in una lista:
	 seleziona un elemento casuale in una lista
	@form elemento_random(+Lista,-ElementoEstratto)
*/
elemento_random(Lista,ElementoEstratto) :-
	length(Lista,Lunghezza),
	random(0,Lunghezza,Indice),
	nth0(Indice,Lista,ElementoEstratto).

/**
	@descr Stampa delle sequenze:
	 stampa le sequenze generate su file workflow.log
	@form stampa(+Sequenze,+FrequenzaRumore)
*/
stampa(Sequenze,FrequenzaRumore) :-
	open('workflow.log', write, OutputStream),
	stampa(OutputStream,FrequenzaRumore,FrequenzaRumore,Sequenze).	
/**
	@descr Stampa delle sequenze:
	 stampa le sequenze generate su file workflow.log
	@form stampa(+OutputStream,+FrequenzaRumore,+FrequenzaRumoreCorrente,+Sequenze)
*/
stampa(OutputStream,_,_,[]) :-
	close(OutputStream).
stampa(OutputStream,FrequenzaRumore,1,[Sequenza|AltreSequenze]) :-
	applicazione_rumore(Sequenza,[Transizione|AltreTransizioni]),
	write(OutputStream,Transizione),
	stampa_sequenza(OutputStream,AltreTransizioni),
	nl(OutputStream),
	stampa(OutputStream,FrequenzaRumore,FrequenzaRumore,AltreSequenze).
stampa(OutputStream,FrequenzaRumore,FrequenzaRumoreCorrente,[[Transizione|AltreTransizioni]|AltreSequenze]) :-
	write(OutputStream,Transizione),
	stampa_sequenza(OutputStream,AltreTransizioni),
	nl(OutputStream),
	NuovaFrequenzaRumore is FrequenzaRumoreCorrente - 1,
	stampa(OutputStream,FrequenzaRumore,NuovaFrequenzaRumore,AltreSequenze).

/**
	@descr Stampa di una sequenza:
	 stampa una sequenza su file workflow.log
	@form stampa_sequenza(+OutputStream,+Sequenza)
*/
stampa_sequenza(OutputStream,[]).
stampa_sequenza(OutputStream,[Transizione|AltreTransizioni]) :-
	write(OutputStream,','),
	write(OutputStream,Transizione),
	stampa_sequenza(OutputStream,AltreTransizioni).
	
/**
	@descr Applicazione di una tipologia di rumore:
	 sceglie a caso un tipo di rumore da applicare alla sequenza
	@form applicazione_rumore(+Sequenza,-SequenzaConRumore)
*/
applicazione_rumore(Sequenza,SequenzaConRumore) :-
	random(0,4,TipoRumore),
	applicazione_rumore(Sequenza,TipoRumore,SequenzaConRumore).
/**
	@descr Applicazione di una tipologia di rumore:
	 applica il rumore scelto alla sequenza
	@form applica_rumore(+Sequenza,+TipoRumore,-SequenzaConRumore)
*/
applicazione_rumore(Sequenza,0,SequenzaConRumore) :-
	length(Sequenza,Lunghezza),
	UnTerzoLunghezza is Lunghezza//3 + 1,
	random(1,UnTerzoLunghezza,NumeroEliminabili),
	rimozione_testa(Sequenza,NumeroEliminabili,SequenzaConRumore).
applicazione_rumore(Sequenza,1,SequenzaConRumore) :-
	length(Sequenza,Lunghezza),
	UnTerzoLunghezza is Lunghezza//3 + 1,
	random(1,UnTerzoLunghezza,NumeroEliminabili),
	rimozione_coda(Sequenza,NumeroEliminabili,SequenzaConRumore).
applicazione_rumore(Sequenza,2,SequenzaConRumore) :-
	length(Sequenza,Lunghezza),
	UnTerzoLunghezza is Lunghezza//3 + 1,
	random(1,UnTerzoLunghezza,NumeroEliminabili),
	rimozione_corpo(Sequenza,NumeroEliminabili,SequenzaConRumore).
applicazione_rumore(Sequenza,3,SequenzaConRumore) :-
	scambio_elementi(Sequenza,SequenzaConRumore).

/**
	@descr Rimozione della testa di una sequenza:
	 rimuove degli elementi dalla testa della sequenza
	@form rimozione_testa(+Sequenza,+NumeroEliminabili,-SequenzaConRumore)
*/
rimozione_testa(Sequenza,0,Sequenza).
rimozione_testa([_|AltreTransizioni],NumeroEliminabili,SequenzaConRumore) :-
	NuovoNumeroEliminabili is NumeroEliminabili - 1,
	rimozione_testa(AltreTransizioni,NuovoNumeroEliminabili,SequenzaConRumore).

/**
	@descr Rimozione della coda di una sequenza:
	 rimuove degli elementi dalla coda della sequenza
	@form rimozione_coda(+Sequenza,+NumeroEliminabili,-SequenzaConRumore)
*/
rimozione_coda(Sequenza,0,Sequenza).
rimozione_coda(Sequenza,NumeroEliminabili,SequenzaConRumore) :-
	length(Sequenza,Lunghezza),
	nth1(Lunghezza,Sequenza,_,ListaRimanente),
	NuovoNumeroEliminabili is NumeroEliminabili - 1,
	rimozione_coda(ListaRimanente,NuovoNumeroEliminabili,SequenzaConRumore).

/**
	@descr Rimozione del corpo di una sequenza:
	 rimuove degli elementi dalla corpo della sequenza
	@form rimozione_corpo(+Sequenza,+NumeroEliminabili,-SequenzaConRumore)
*/
rimozione_corpo(Sequenza,NumeroEliminabili,SequenzaConRumore) :-
	length(Sequenza,Lunghezza),
	MetaLunghezza is Lunghezza//2 + 1,
	divisione_lista(Sequenza,MetaLunghezza,TransizioniPrimaParte,TransizioneMedia,TransizioniSecondaParte),
	MetaNumeroEliminabili is NumeroEliminabili//2,
	rimozione_testa([TransizioneMedia|TransizioniSecondaParte],MetaNumeroEliminabili,UltimeTransizioniRimanenti),
	RestoNumeroEliminabili is NumeroEliminabili - MetaNumeroEliminabili,
	rimozione_coda(TransizioniPrimaParte,RestoNumeroEliminabili,PrimeTransizioniRimanenti),
	append(PrimeTransizioniRimanenti,UltimeTransizioniRimanenti,SequenzaConRumore).

/**
	@descr Scambio di due elementi di una sequenza:
	 scambia due elementi casuali all'interno della sequenza
	@form scambio_elementi(+Sequenza,-SequenzaConRumore)
*/
scambio_elementi(Sequenza,SequenzaConRumore) :-
	length(Sequenza,Lunghezza),
	random(1,Lunghezza,PosizioneTransizione1),
	random(0,PosizioneTransizione1,PosizioneTransizione2),
	divisione_lista(Sequenza,PosizioneTransizione1,TransizioniPrecedenti1,Transizione1,TransizioniSuccessive1),
	divisione_lista(TransizioniPrecedenti1,PosizioneTransizione2,TransizioniPrecedenti2,Transizione2,TransizioniSuccessive2),
	append(TransizioniPrecedenti2,[Transizione1|TransizioniSuccessive2],NuoveTransizioniPrecedenti1),
	append(NuoveTransizioniPrecedenti1,[Transizione2|TransizioniSuccessive1],SequenzaConRumore).

/**
	@descr Divisione di una lista:
	 seleziona un elemento da una lista e restituisce una lista con gli elementi precedenti ed una lista con gli elementi successivi
	@form divisione_lista(+Lista,+PosizioneElemento,-PrimaParte,-ElementoMedio,-SecondaParte)
*/
divisione_lista([Elemento|AltriElementi],0,[],Elemento,AltriElementi).
divisione_lista([Elemento|AltriElementi],PosizioneElemento,PrimaParte,ElementoMedio,SecondaParte) :-
	NuovaPosizioneElemento is PosizioneElemento - 1,
	divisione_lista(AltriElementi,NuovaPosizioneElemento,VecchiaPrimaParte,ElementoMedio,SecondaParte),
	append([Elemento],VecchiaPrimaParte,PrimaParte).

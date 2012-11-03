/***
	@descr Comparatore di due modelli di workflow basato sulla completezza e sulla correttezza delle connessioni nei due modelli
	@author Nicola Sanitate
	@date 28/10/2011
*/
:- use_module(library(lists)).

/**
	@descr Start:
	 gestore dell'intero processo di comparazione; provvede a:
	 <ol>
	  <li>caricare il modello iniziale da file wf-net-in</li>
	  <li>dividere tutte le connessioni del modello iniziale per tipi</li>
	  <li>caricare il modello ottenuto dal sistema di apprendimento da file wf-net-out</li>
	  <li>dividere tutte le connessioni del modello ottenuto dal sistema di apprendimento per tipi</li>
	  <li>confrontare le connessioni dei due modelli</li>
	  <li>stampare a schermo i risultati</li>
	 </ol>
	@form start
*/
start :-
	consult('wf-net-in'),
	setof([X,Y],in(X,Y),ArchiEntranti),
	prelevamento_transizioni(ArchiEntranti,TransizioniRegistrate),
	remove_duplicates(TransizioniRegistrate,Transizioni),
	divisioni_and(Transizioni,DivisioniAndIniziali),
	length(DivisioniAndIniziali,NumeroDivisioniAndIniziali),
	divisioni_or(Transizioni,DivisioniOrIniziali),
	length(DivisioniOrIniziali,NumeroDivisioniOrIniziali),
	unioni_and(Transizioni,UnioniAndIniziali),
	length(UnioniAndIniziali,NumeroUnioniAndIniziali),
	unioni_or(Transizioni,UnioniOrIniziali),
	length(UnioniOrIniziali,NumeroUnioniOrIniziali),
	NumeroConnessioniIniziali is NumeroDivisioniAndIniziali + NumeroDivisioniOrIniziali + NumeroUnioniAndIniziali + NumeroUnioniOrIniziali,
	abolish(in/2),
	abolish(out/2),
	consult('wf-net-out'),
	divisioni_and(Transizioni,DivisioniAndFinali),
	length(DivisioniAndFinali,NumeroDivisioniAndFinali),
	divisioni_or(Transizioni,DivisioniOrFinali),
	length(DivisioniOrFinali,NumeroDivisioniOrFinali),
	unioni_and(Transizioni,UnioniAndFinali),
	length(UnioniAndFinali,NumeroUnioniAndFinali),
	unioni_or(Transizioni,UnioniOrFinali),
	length(UnioniOrFinali,NumeroUnioniOrFinali),
	NumeroConnessioniFinali is NumeroDivisioniAndFinali + NumeroDivisioniOrFinali + NumeroUnioniAndFinali + NumeroUnioniOrFinali,
	abolish(in/2),
	abolish(out/2),
	write('\n\nCompletezza:\n\n'),
	comparazione(DivisioniAndIniziali,DivisioniAndFinali,DivisioniAndInizialiNonCoperte),
	length(DivisioniAndInizialiNonCoperte,NumeroDivisioniAndInizialiNonCoperte),
	stampa_divisioni_and(DivisioniAndInizialiNonCoperte),
	DivisioniAndInizialiCoperte is NumeroDivisioniAndIniziali - NumeroDivisioniAndInizialiNonCoperte,
	comparazione(DivisioniOrIniziali,DivisioniOrFinali,DivisioniOrInizialiNonCoperte),
	length(DivisioniOrInizialiNonCoperte,NumeroDivisioniOrInizialiNonCoperte),
	stampa_divisioni_or(DivisioniOrInizialiNonCoperte),
	DivisioniOrInizialiCoperte is NumeroDivisioniOrIniziali - NumeroDivisioniOrInizialiNonCoperte,
	comparazione(UnioniAndIniziali,UnioniAndFinali,UnioniAndInizialiNonCoperte),
	length(UnioniAndInizialiNonCoperte,NumeroUnioniAndInizialiNonCoperte),
	stampa_unioni_and(UnioniAndInizialiNonCoperte),
	UnioniAndInizialiCoperte is NumeroUnioniAndIniziali - NumeroUnioniAndInizialiNonCoperte,
	comparazione(UnioniOrIniziali,UnioniOrFinali,UnioniOrInizialiNonCoperte),
	length(UnioniOrInizialiNonCoperte,NumeroUnioniOrInizialiNonCoperte),
	stampa_unioni_or(UnioniOrInizialiNonCoperte),
	UnioniOrInizialiCoperte is NumeroUnioniOrIniziali - NumeroUnioniOrInizialiNonCoperte,
	ConnessioniInizialiCoperte is DivisioniAndInizialiCoperte + DivisioniOrInizialiCoperte + UnioniAndInizialiCoperte + UnioniOrInizialiCoperte,
	PercentualeCompletezza is round((ConnessioniInizialiCoperte/NumeroConnessioniIniziali)*100),
	nl,
	write(ConnessioniInizialiCoperte),
	write(' su '),
	write(NumeroConnessioniIniziali),
	write(' → '),
	write(PercentualeCompletezza),
	write('%\n'),
	write('\n\nCorrettezza:\n\n'),
	comparazione(DivisioniAndFinali,DivisioniAndIniziali,DivisioniAndFinaliNonCoperte),
	length(DivisioniAndFinaliNonCoperte,NumeroDivisioniAndFinaliNonCoperte),
	stampa_divisioni_and(DivisioniAndFinaliNonCoperte),
	DivisioniAndFinaliCoperte is NumeroDivisioniAndFinali - NumeroDivisioniAndFinaliNonCoperte,
	comparazione(DivisioniOrFinali,DivisioniOrIniziali,DivisioniOrFinaliNonCoperte),
	length(DivisioniOrFinaliNonCoperte,NumeroDivisioniOrFinaliNonCoperte),
	stampa_divisioni_or(DivisioniOrFinaliNonCoperte),
	DivisioniOrFinaliCoperte is NumeroDivisioniOrFinali - NumeroDivisioniOrFinaliNonCoperte,
	comparazione(UnioniAndFinali,UnioniAndIniziali,UnioniAndFinaliNonCoperte),
	length(UnioniAndFinaliNonCoperte,NumeroUnioniAndFinaliNonCoperte),
	stampa_unioni_and(UnioniAndFinaliNonCoperte),
	UnioniAndFinaliCoperte is NumeroUnioniAndFinali - NumeroUnioniAndFinaliNonCoperte,
	comparazione(UnioniOrFinali,UnioniOrIniziali,UnioniOrFinaliNonCoperte),
	length(UnioniOrFinaliNonCoperte,NumeroUnioniOrFinaliNonCoperte),
	stampa_unioni_or(UnioniOrFinaliNonCoperte),
	UnioniOrFinaliCoperte is NumeroUnioniOrFinali - NumeroUnioniOrFinaliNonCoperte,
	ConnessioniFinaliCoperte is DivisioniAndFinaliCoperte + DivisioniOrFinaliCoperte + UnioniAndFinaliCoperte + UnioniOrFinaliCoperte,
	PercentualeCorrettezza is round((ConnessioniFinaliCoperte/NumeroConnessioniFinali)*100),
	nl,
	write(ConnessioniFinaliCoperte),
	write(' su '),
	write(NumeroConnessioniFinali),
	write(' → '),
	write(PercentualeCorrettezza),
	write('%\n').

/**
	@descr Prelevamento delle transizioni di un modello: 
	 preleva tutte le transizioni presenti nel modello
	@form prelevamento_transizioni(+Archi,-Transizioni)
*/
prelevamento_transizioni([],[]).
prelevamento_transizioni([[Posto,Transizione]|AltriArchi],[Transizione|AltreTransizioni]) :-
	prelevamento_transizioni(AltriArchi,AltreTransizioni).

/**
	@descr Ritrovamento di tutti gli AND-split:
	 riconosce le divisioni di tipo AND
	@form divisioni_and(+Transizioni,-DivisioniAnd)
*/
divisioni_and([],[]).
divisioni_and([Transizione|AltreTransizioni],[[Transizione,TransizioniDestinazione]|AltreDivisioniAnd]) :-
	setof(X,out(Transizione,X),Posti),
	length(Posti,NumeroPosti),
	NumeroPosti>1,
	divisioni_and_dettaglio(Posti,TransizioniDestinazione),
	divisioni_and(AltreTransizioni,AltreDivisioniAnd).
divisioni_and([_|AltreTransizioni],DivisioniAnd) :-
	divisioni_and(AltreTransizioni,DivisioniAnd).

/**
	@descr Prelevamento delle transizioni di destinazione di un AND-split:
	 preleva le transizioni di destinazione di una divisione di tipo AND
	@form divisioni_and_dettaglio(+Posti,-TransizioniDestinazione)
*/
divisioni_and_dettaglio([],[]).
divisioni_and_dettaglio([Posto|AltriPosti],TransizioniDestinazione) :-
	setof(X,in(Posto,X),TransizioniDestinazionePosto),
	divisioni_and_dettaglio(AltriPosti,TransizioniDestinazioneAltriPosti),
	append(TransizioniDestinazionePosto,TransizioniDestinazioneAltriPosti,TransizioniDestinazione).

/**
	@descr Ritrovamento di tutti gli OR-split:
	 riconosce le divisioni di tipo OR
	@form divisioni_or(+Transizioni,-DivisioniOr)
*/
divisioni_or([],[]).
divisioni_or([Transizione|AltreTransizioni],DivisioniOr) :-
	setof(X,out(Transizione,X),Posti),
	divisioni_or_dettaglio(Transizione,Posti,DivisioniOrTransizione),
	length(DivisioniOrTransizione,NumeroDivisioniOrTransizione),
	NumeroDivisioniOrTransizione>0,
	divisioni_or(AltreTransizioni,AltreDivisioniOr),
	append(DivisioniOrTransizione,AltreDivisioniOr,DivisioniOr).
divisioni_or([_|AltreTransizioni],DivisioniOr) :-
	divisioni_or(AltreTransizioni,DivisioniOr).

/**
	@descr Ritrovamento degli OR-split a partire da alcuni posti di partenza:
	 preleva le divisione di tipo OR relativi ad una transizione
	@form divisioni_or_dettaglio(+Posti,-DivisioniOr)
*/
divisioni_or_dettaglio(_,[],[]).
divisioni_or_dettaglio(Transizione,[Posto|AltriPosti],[[Transizione,TransizioniDestinazione]|AltreDivisioniOr]) :-
	setof(X,in(Posto,X),TransizioniDestinazione),
	length(TransizioniDestinazione,NumeroTransizioni),
	NumeroTransizioni>1,
	divisioni_or_dettaglio(Transizione,AltriPosti,AltreDivisioniOr).
divisioni_or_dettaglio(Transizione,[_|AltriPosti],DivisioniOr) :-
	divisioni_or_dettaglio(Transizione,AltriPosti,DivisioniOr).

/**
	@descr Ritrovamento di tutti gli AND-join:
	 riconosce le unioni di tipo AND
	@form unioni_and(+Transizioni,-UnioniAnd)
*/
unioni_and([],[]).
unioni_and([Transizione|AltreTransizioni],[[Transizione,TransizioniPartenza]|AltreUnioniAnd]) :-
	setof(X,in(X,Transizione),Posti),
	length(Posti,NumeroPosti),
	NumeroPosti>1,
	unioni_and_dettaglio(Posti,TransizioniPartenza),
	unioni_and(AltreTransizioni,AltreUnioniAnd).
unioni_and([_|AltreTransizioni],UnioniAnd) :-
	unioni_and(AltreTransizioni,UnioniAnd).

/**
	@descr Prelevamento delle transizioni di partenza di un AND-join:
	 preleva le transizioni di partenza di una unione di tipo AND
	@form unioni_and_dettaglio(+Posti,-TransizioniPartenza)
*/
unioni_and_dettaglio([],[]).
unioni_and_dettaglio([Posto|AltriPosti],TransizioniPartenza) :-
	setof(X,out(X,Posto),TransizioniPartenzaPosto),
	unioni_and_dettaglio(AltriPosti,TransizioniPartenzaAltriPosti),
	append(TransizioniPartenzaPosto,TransizioniPartenzaAltriPosti,TransizioniPartenza).

/**
	@descr Ritrovamento di tutti gli OR-join:
	 riconosce le unioni di tipo OR
	@form unioni_or(+Transizioni,-UnioniOr)
*/
unioni_or([],[]).
unioni_or([Transizione|AltreTransizioni],UnioniOr) :-
	setof(X,in(X,Transizione),Posti),
	unioni_or_dettaglio(Transizione,Posti,UnioniOrTransizione),
	length(UnioniOrTransizione,NumeroUnioniOrTransizione),
	NumeroUnioniOrTransizione>0,
	unioni_or(AltreTransizioni,AltreUnioniOr),
	append(UnioniOrTransizione,AltreUnioniOr,UnioniOr).
unioni_or([_|AltreTransizioni],UnioniOr) :-
	unioni_or(AltreTransizioni,UnioniOr).

/**
	@descr Ritrovamento degli OR-join a partire da alcuni posti di destinazione:
	 preleva le unioni di tipo OR relativi ad una transizione
	@form unioni_or_dettaglio(+Posti,-UnioniOr)
*/
unioni_or_dettaglio(_,[],[]).
unioni_or_dettaglio(Transizione,[Posto|AltriPosti],[[Transizione,TransizioniPartenza]|AltreUnioniOr]) :-
	setof(X,out(X,Posto),TransizioniPartenza),
	length(TransizioniPartenza,NumeroTransizioni),
	NumeroTransizioni>1,
	unioni_or_dettaglio(Transizione,AltriPosti,AltreUnioniOr).
unioni_or_dettaglio(Transizione,[_|AltriPosti],UnioniOr) :-
	unioni_or_dettaglio(Transizione,AltriPosti,UnioniOr).

/**
	@descr Comparazione tra una lista di split (join) ed un altra di paragone:
	 ricava tutte le connessioni non coperte da un termine di paragone
	@form comparazione(+Connessioni,+TermineDiParagone,-ConnessioniNonCoperte)
*/
comparazione([],_,[]).
comparazione([[Transizione,TransizioniConnesse]|AltreConnessioni],TermineDiParagone,[ConnessioneNonCoperta|AltreConnessioniNonCoperte]) :-
	controllo(Transizione,TransizioniConnesse,TermineDiParagone,ConnessioneNonCoperta),
	length(ConnessioneNonCoperta,LunghezzaConnessioneNonCoperta),
	LunghezzaConnessioneNonCoperta > 0,
	comparazione(AltreConnessioni,TermineDiParagone,AltreConnessioniNonCoperte).
comparazione([_|AltreConnessioni],TermineDiParagone,AltreConnessioniNonCoperte) :-
	comparazione(AltreConnessioni,TermineDiParagone,AltreConnessioniNonCoperte).

/**
	@descr Controllo di uno split (join) tra gli split (join) di paragone:
	 controlla che tra le connessioni paragone ci sia una che contengano gli stessi elementi della connessione in esame
	@form controllo(+Transizione,+TransizioniConnesse,+ConnessioniParagone,-ConnessioniNonCoperte)
*/
controllo(Transizione,TransizioniConnesse,[],[Transizione,TransizioniConnesse]).
controllo(Transizione,TransizioniConnesse,[[Transizione,TransizioniConnesseParagone]|_],[]) :-
	sort(TransizioniConnesse,TransizioniConnesseOrdinate),
	sort(TransizioniConnesseParagone,TransizioniConnesseParagoneOrdinate),
	TransizioniConnesseOrdinate == TransizioniConnesseParagoneOrdinate,
	!.
controllo(Transizione,TransizioniConnesse,[_|AltreConnessioniParagone],ConnessioniNonCoperte) :-
	controllo(Transizione,TransizioniConnesse,AltreConnessioniParagone,ConnessioniNonCoperte).

/**
	@descr Stampa della lista di AND-split non coperti:
	 stampa a schermo delle divisione AND non riscontrate nel termine di paragone
	@form stampa_divisioni_and(+DivisioniAnd)
*/
stampa_divisioni_and([]).
stampa_divisioni_and([[Transizione,TransizioniConnesse]|AltreDivisioniAnd]) :-
	write('Divisione AND '),
	write(Transizione),
	write(' → '),
	stampa_transizioni(TransizioniConnesse),
	write('non coperta.'),
	nl,
	stampa_divisioni_and(AltreDivisioniAnd).

/**
	@descr Stampa della lista di OR-split non coperti:
	 stampa a schermo delle divisione OR non riscontrate nel termine di paragone
	@form stampa_divisioni_or(+DivisioniOr)
*/
stampa_divisioni_or([]).
stampa_divisioni_or([[Transizione,TransizioniConnesse]|AltreDivisioniOr]) :-
	write('Divisione OR '),
	write(Transizione),
	write(' → '),
	stampa_transizioni(TransizioniConnesse),
	write('non coperta.'),
	nl,
	stampa_divisioni_or(AltreDivisioniOr).

/**
	@descr Stampa della lista di AND-join non coperti:
	 stampa a schermo delle unioni AND non riscontrate nel termine di paragone
	@form stampa_unioni_and(+UnioniAnd)
*/
stampa_unioni_and([]).
stampa_unioni_and([[Transizione,TransizioniConnesse]|AltreUnioniAnd]) :-
	write('Unione AND '),
	stampa_transizioni(TransizioniConnesse),
	write('→ '),
	write(Transizione),
	write(' non coperta.'),
	nl,
	stampa_unioni_and(AltreUnioniAnd).

/**
	@descr Stampa della lista di OR-join non coperti:
	 stampa a schermo delle unioni OR non riscontrate nel termine di paragone
	@form stampa_unioni_or(+UnioniOr)
*/	
stampa_unioni_or([]).
stampa_unioni_or([[Transizione,TransizioniConnesse]|AltreUnioniOr]) :-
	write('Unione OR '),
	stampa_transizioni(TransizioniConnesse),
	write('→ '),
	write(Transizione),
	write(' non coperta.'),
	nl,
	stampa_unioni_or(AltreUnioniOr).

/**
	@descr Stampa di una lista di transizioni:
	 stampa a schermo una lista di transizioni
	@form stampa_transizioni(+Transizioni)
*/
stampa_transizioni([]).
stampa_transizioni([Transizione|AltreTransizioni]) :-
	write(Transizione),
	write(' '),
	stampa_transizioni(AltreTransizioni).


% ===========================================================
% Main loop:
% 1. Repeat "input-response" cycle until input starts with "bye"
%    Each "input-response" cycle consists of:
% 		1.1 Reading an input string and convert it to a tokenized list
% 		1.2 Processing tokenized list
% ===========================================================

chat:-
 repeat,
   readinput(Input),
   process(Input),
  (Input = [bye| _] ),!.


% ===========================================================
% Read input:
% 1. Read char string from keyboard.
% 2. Convert char string to atom char list.
% 3. Convert char list to lower case.
% 4. Tokenize (based on spaces).
% ===========================================================

readinput(TokenList):-
   read_line_to_codes(user_input,InputString),
   string_to_atom(InputString,CharList),
   string_lower(CharList,LoweredCharList),
   tokenize_atom(LoweredCharList,TokenList).


% ===========================================================
%  Process tokenized input
% 1. Parse morphology and syntax, to obtain semantic representation
% 2. Evaluate input in the model
% If input starts with "bye" terminate.
% ===========================================================

process(Input):-
	parse(Input,SemanticRepresentation),
	modelchecker(SemanticRepresentation,Evaluation),
	respond(Evaluation),!,
	nl,nl.

process([bye|_]):-
   write('> bye!').


% ===========================================================
%  Parse:
% 1. Morphologically parse each token and tag it.
% 2. Add semantic representation to each tagged token
% 3. Obtain FOL representation for input sentence
% ===========================================================

%parse(Input, SemanticRepresentation):-
% ...


% ===========================================================
% Grammar
% 1. List of lemmas
% 2. Lexical items
% 3. Phrasal rules
% ===========================================================

% --------------------------------------------------------------------
% Lemmas are uninflected, except for irregular inflection
% lemma(+Lemma,+Category)
% --------------------------------------------------------------------


lemma(is,be).
lemma(was,be).
lemma(are,be).
lemma(on,vacp).
lemma(to,vacp).

%%%%%%%%%% ------------ My Lemmas [Akshay Chopra]

%% Determiners
lemma(a,dtexists).
lemma(an,dtexists).
lemma(some,dtexists).
lemma(each,dtforall).
lemma(all,dtforall).
lemma(every,dtforall).
lemma(the,dt).

%% Numerals
lemma(no,dt).
lemma(one,dt).
lemma(two,dt).
lemma(three,dt).
lemma(four,dt).
lemma(five,dt).
lemma(six,dt).
lemma(seven,dt).
lemma(eight,dt).
lemma(nine,dt).
lemma(ten,dt).

%% Nouns
lemma(egg,n).
lemma(shelf,n).
lemma(fridge,n).
lemma(container,n).
lemma(sandwich,n).
lemma(meat,n).
lemma(tofu,n).
lemma(apple,n).
lemma(vegetable,n).
lemma(banana,n).
lemma(watermelon,n).
lemma(almond,n).
lemma(milk,n).
lemma(popsicle,n).
lemma(can,n).
lemma(skim,n).
lemma(box,n).

%% Proper Nouns
lemma(tom,pn).
lemma(mia,pn).

%% Adjectives
lemma(blue,adj).
lemma(yellow,adj).
lemma(white,adj).
lemma(green,adj).
lemma(top,adj).
lemma(middle,adj).
lemma(bottom,adj).
lemma(red,adj).
lemma(empty,adj).

%% Verbs
lemma(expire,iv).
lemma(drink,tv).
lemma(drank,tv).
lemma(drunk,tv).
lemma(contain,tv).
lemma(eat,tv).
lemma(ate,tv).

%% Prepositions
lemma(in,p).
lemma(inside,p).
lemma(under,p).

%% Interrogative Pronouns
lemma(who,ip).
lemma(which,ip).
lemma(what,ip).

%% Relative Clauses
%% lemma(that,rel).
%% lemma(there,rel).



%%%%%%%%%% ------------ End My Lemmas [Akshay Chopra]


% --------------------------------------------------------------------
% Constructing lexical items:
% word = lemma + suffix (for "suffix" of size 0 or bigger)
% --------------------------------------------------------------------


%%%%%%%%%% ------------ My Lexicons

lex(dt((X^P)^(X^Q)^forall(X,imp(P,Q))),Word):- lemma(Word,dtforall).
lex(dt((X^P)^(X^Q)^exists(X,and(P,Q))),Word):-lemma(Word,dtexists).
lex(n(X^P),Word):- lemma(Word,n), P =.. [Word,X].
lex(pn(Word^X)^X,Word):- lemma(Word,n).
lex(iv(X^P),Y):-lemma(Word,iv),atom_concat(Word,ed,Y),P=.. [Word,X].
lex(tv(K^W^P),Word):-lemma(Word,tv), P=.. [Word,K,W].
lex(adj((X^P)^X^and(P,Q)),Word):-lemma(Word,adj), Q=.. [Word,X].
lex(p((Y^Z)^Q^(X^P)^and(P,Q)),Word):- lemma(Word,p), Z=.. [Word,X,Y].

%%%%%%%%%% ------------ End My Lexicons

% ...

% --------------------------------------------------------------------
% Suffix types
% --------------------------------------------------------------------

% ...

% --------------------------------------------------------------------
% Phrasal rules
% rule(+LHS,+ListOfRHS)
% --------------------------------------------------------------------

%%%%%%%%%% ------------ Shubham's Rules

rule(np(Y),[dt(X^Y),n(X)]).
rule(np(X),[pn(X)]).
rule(n(A^C),[n(A^B),pp((A^B)^C)]).
rule(n(A),[adj(B^A),n(B)]).
rule(pp(C),[p(A^B^C),np(A^B)]).
rule(vp(A),[iv(A)]).
rule(vp(A^B),[tv(A^C),np(C^B)]).
rule(s(B),[np(A^B),vp(A)]).


%%%%%%%%%% ------------ End of Shubham's Rules
% ...


% ===========================================================
%  Modelchecker:
%  1. If input is a declarative, check if true
%  2. If input is a yes-no question, check if true
%  3. If input is a content question, find answer
% ===========================================================

% model(...,...)

% ===========================================================
%  Respond
%  For each input type, react appropriately.
% ===========================================================

% Declarative true in the model
respond(Evaluation) :-
		Evaluation = [true_in_the_model],
		write('That is correct'),!.

% Declarative false in the model
respond(Evaluation) :-
		Evaluation = [not_true_in_the_model],
		write('That is not correct'),!.

% Yes-No interrogative true in the model
respond(Evaluation) :-
		Evaluation = [yes_to_question],
		write('yes').

% Yes-No interrogative false in the model
respond(Evaluation) :-
		Evaluation = [no_to_question],
		write('no').

% wh-interrogative true in the model
% ...

% wh-interrogative false in the model
% ...

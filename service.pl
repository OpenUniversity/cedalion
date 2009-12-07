% Service utilities for the Cedalion commands
:- [cedalion, termio].
:- op(1200, xfy, '~>').
:- op(100, xfx, ':').
:- op(100, fx, '$').

% Insert a statement to the database
insert(Statement) :-
	translateStatement(Statement, Clause),
	assert(Clause).

% Remove a statement to the database
remove(Statement) :-
	translateStatement(Statement, Clause),
	retract(Clause).


translateStatement(Statement, Clause) :-
	if(Statement = (Head ~> Body),
		translateRewrite(Head, Body, Clause),
		Clause = Statement).

translateRewrite(Head, Body, Clause) :-
	if(Body = (H :- B),
		Clause = (H :- Head, B),
		Clause = (Body :- Head)).

% Load/Reload a file to the database
loadFile(FileName, Namespace) :-
	forall(retract(loadedStatement(FileName, Statement)), remove(Statement)),
	open(FileName, read, Stream),
	read(Stream, Term),
	insertTermsFromSteam(Stream, Term, FileName, [default=Namespace]).

insertTermsFromSteam(Stream, Term, FileName, NsList) :-
	if(Term=end_of_file,
		(
			close(Stream)
		),
		(
			interpretTerm(Term, FileName, NsList, NewNsList),
			read(Stream, NewTerm),
			insertTermsFromSteam(Stream, NewTerm, FileName, NewNsList)
		)).

interpretTerm(Term, FileName, NsList, NewNsList) :-
	if(Term = import(s(Alias), s(FullNs)),
		NewNsList = [Alias=FullNs | NsList],
		(
			NewNsList = NsList,
			localToGlobal(Term, NsList, GTerm),
			assert(loadedStatement(FileName, GTerm)),
			if(GTerm = (Statement ~> _), % Avoid exception if not implemented
				assert((Statement :- fail))),
			insert(GTerm)

		)).

% Translating from local terms (specific to this file) to their global representation
localToGlobal(Local, NsList, Global) :-
	if(nonCompoundTerm(Local),
		Global = Local,
		(
			if(Local = NsAlias:Term,
				(
					findNamespaceInList(NsAlias, NsList, Namespace),
					termLocalToGlobal(Term, Namespace, NsList, Global)
				),
				localToGlobal(default:Local, NsList, Global))
		)).

nonCompoundTerm(Term) :-
	var(Term).
nonCompoundTerm(Term) :-
	number(Term).
nonCompoundTerm(s(X)) :-
	atom(X).

termLocalToGlobal(Term, Namespace, NsList, Global) :-
	Term =.. [Func | Args],
	if(dontConvertFunc(Func),
		GFunc = Func,
		concat_atom([Namespace, '#', Func], GFunc)),
	localToGlobalList(Args, NsList, GArgs),
	Global =.. [GFunc | GArgs].

localToGlobalList([], _, []).
localToGlobalList([Local | Locals], NsList, [Global | Globals]) :-
	localToGlobal(Local, NsList, Global),
	localToGlobalList(Locals, NsList, Globals).

findNamespaceInList(Alias, [], Alias).
findNamespaceInList(Alias, [Alias=Namespace | _], Namespace).
findNamespaceInList(Alias, [BadAlias=_ | NsList], Namespace) :-
	\+(BadAlias = Alias),
	findNamespaceInList(Alias, NsList, Namespace).

dontConvertFunc('[]').
dontConvertFunc('.').
dontConvertFunc(Op) :- current_op(_, _, Op).
dontConvertFunc(Func) :- \+atom(Func).


% Read a file into a list of terms and variable names (translates to global terms).
readFile(FileName, Namespace, 'cedalion-services:fileContent'(Terms, NsListOut)) :-
	open(FileName, read, Stream),
	read_term(Stream, Term, [variable_names(VarNames)]),
	readFromSteam(Stream, Term, VarNames, FileName, [default=Namespace], NsListOut, Terms).

readFromSteam(Stream, Term, VarNames, FileName, NsList, NsListOut, Terms) :-
	if(Term = end_of_file,
		(
			Terms = [],
			close(Stream),
			NsListOut = NsList
		),
		(
			if(Term = import(s(Alias), s(Namespace)),
				(
					NewNsList = [Alias=Namespace | NsList],
					GTerm = Term
				),
				(
					NewNsList = NsList,
					localToGlobal(Term, NsList, GTerm)
				)),
			read_term(Stream, NewTerm, [variable_names(NewVarNames)]),
			readFromSteam(Stream, NewTerm, NewVarNames, FileName, NewNsList, NsListOut, OtherTerms),
			convertVarNames(VarNames, ConvVarNames),
			Terms = ['cedalion-services:statement'(GTerm, ConvVarNames) | OtherTerms]
		)).

convertVarNames([], []).
convertVarNames([Name=Var | RestIn], ['cedalion-services:varName'(Var::_, Name) | RestOut]) :-
	convertVarNames(RestIn, RestOut).

% Write a cedalion file
writeFile(FileName, 'cedalion-services:fileContent'(Terms, NsList)) :-
	open(FileName, write, Stream),
	writeToStream(Stream, Terms, NsList).

writeToStream(Stream, [], _) :-
	close(Stream).

writeToStream(Stream, ['cedalion-services:statement'(GTerm, VarNames) | OtherTerms], NsList) :-
	globalToLocal(GTerm, NsList, Term),
	writeTerm(Stream, Term, VarNames),
	writeToStream(Stream, OtherTerms, NsList).

globalToLocal(GTerm, NsList, Term) :-
	if(nonCompoundTerm(GTerm),
		Term = GTerm,
		(
			GTerm =.. [GFunc | GArgs],
			globalToLocalList(GArgs, NsList, Args),
			if(splitNamespace(GFunc, Namespace, Func),
				(
					LTerm =.. [Func | Args],
					findNamespaceAlias(Namespace, NsList, Alias),
					if(Alias = default,
						Term = LTerm,
						Term = Alias:LTerm)
				),
				Term =.. [GFunc | Args])
		)).

globalToLocalList([], _, []).
globalToLocalList([GArg | GArgs], NsList, [Arg | Args]) :-
	globalToLocal(GArg, NsList, Arg),
	globalToLocalList(GArgs, NsList, Args).

splitNamespace(GlobalName, NsAlias, LocalName) :-
	atom_chars(GlobalName, Chars),
	append(Pre, ['#' | Post], Chars),
	atom_chars(NsAlias, Pre),
	atom_chars(LocalName, Post).

findNamespaceAlias(Alias, [], Alias).
findNamespaceAlias(Namespace, [Alias1 = Namespace1 | NsList], Alias) :-
	if(Namespace = Namespace1,
		Alias = Alias1,
		findNamespaceAlias(Namespace, NsList, Alias)).

writeImports(_, []).
writeImports(Stream, [Alias = Namespace | NsList]) :-
	if(Alias = default,
		true,
		writeTerm(Stream, import(s(Alias), s(Namespace)), [])),
	writeImports(Stream, NsList).

% Take a term (global), trim it to a given depth, storing the trimmed subterms to the database,
% convert it to local and represent it textually as a string.
termToString(GTerm, VarNames, Depth, NsList, s(Atom)) :-
	trimTerm(GTerm, Depth, TrimmedGTerm),
	globalToLocal(TrimmedGTerm, NsList, TrimmedTerm),
	with_output_to(atom(Atom), writeTerm(current_output, TrimmedTerm, VarNames)).

trimTerm(Term, Depth, TrimmedTerm) :-
	if(nonCompoundTerm(Term),
		TrimmedTerm = Term,
		( % else
			if(Depth = 0,
				(
					storeTrimmedSubterm(Term, ID),
					TrimmedTerm = $ID
				),
				( % else
					Term =.. [Func | Args],
					NewDepth is Depth - 1,
					trimTerms(Args, NewDepth, TrimmedArgs),
					TrimmedTerm =.. [Func | TrimmedArgs]
				))
		)).

trimTerms([], _, []).
trimTerms([Term | Terms], Depth, [TrimmedTerm | TrimmedTerms]) :-
	trimTerm(Term, Depth, TrimmedTerm),
	trimTerms(Terms, Depth, TrimmedTerms).


storeTrimmedSubterm(Term, ID) :-
	uniqueTrimmedID(ID),
	assert(storedTrimmedSubterm(ID, Term)).

uniqueTrimmedID(ID) :-
	if(retract(lastTrimmedID(LastID)),
		true,
		%else
		LastID = 0),
	ID is LastID + 1,
	assert(lastTrimmedID(ID)).

% Take a string representing a local, potentially trimmed term, and reconstruct the global term it represents.
stringToTerm(s(Atom), NsList, GTerm, VarNames) :-
	atom_to_term(Atom, LTerm, Bindings),
	convertVarNames(Bindings, VarNames),
	localToGlobal(LTerm, NsList, TrimmedGTerm),
	untrimTerm(TrimmedGTerm, GTerm).

untrimTerm(TrimmedTerm, Term) :-
	if(nonCompoundTerm(TrimmedTerm),
		Term = TrimmedTerm,
		% else
		if(TrimmedTerm = $ID,
			storedTrimmedSubterm(ID, Term),
			% else
			(
				TrimmedTerm =.. [Func | TrimmedArgs],
				untrimTerms(TrimmedArgs, Args),
				Term =.. [Func | Args]
			))).

untrimTerms([], []).
untrimTerms([TrimmedArg | TrimmedArgs], [Arg | Args]) :-
	untrimTerm(TrimmedArg, Arg),
	untrimTerms(TrimmedArgs, Args).

% Test: readFile('grammar-example.ced', gram, 'cedalion-services:fileContent'([_, _, 'cedalion-services:statement'(T, V) | _], N)), termToString(T, V, 3, N, S).

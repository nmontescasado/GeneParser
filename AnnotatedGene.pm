package AnnotatedGene;
use Moose;


has 'ID' => (
    is  => 'rw',
    isa => 'Str', #Is a Identifier, son only acept that type of Str
    predicate => 'has_ID',
    );

has 'Name' => (
    is  => 'rw',  
    isa => 'Str',
    predicate => 'has_name', 
    );

has 'PosInicio' => (
    is  => 'rw',  
    isa => 'Int',
    );

has 'PosFinal' => (
    is  => 'rw',  
    isa => 'Int',
    );

has 'DNASeq' => (
	is  => 'rw',  
	isa => 'Str',
    predicate => 'has_DNA',  
	);

has 'aaID' => (
	is  => 'rw',  
	isa => 'Str',
    predicate => 'has_AAID',  
	);

has 'aaSeq' => (
	is  => 'rw',  
	isa => 'Str',
    predicate => 'has_AA',  
	);

has 'Especie' => (
    is  => 'rw',  
    isa => 'Str',
    );

has 'Taxonomia' => (
    is  => 'rw',  
    isa => 'Str',
    );




1;

package Gene;
use Moose;
use Moose::Util::TypeConstraints;


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



    

1;
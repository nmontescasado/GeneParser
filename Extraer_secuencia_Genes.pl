#! perl -w
# Iván Martín Hernández

use strict;
use Bio::SeqIO;
use AnnotatedGene;


	#### Programa ####


#Primero: Ver y almacenar los nombres de los archivos de todas la muestras que hay:
	#Recordar que en cadar archivo de GenBank están todas las secuencias para una especie de virus
my @DireccionesGenomas=`ls Repositorio/`;

#Ahora se va recorriendo cada uno de los archivos de la carpeta, generando una sub carpeta donde meteré todas las secuencias de slo ese virus
foreach my $nombrevirus(@DireccionesGenomas){
	
	chomp $nombrevirus;
	
	#La diferencia entre la direccion de entrada y salida es el caracter_ entre las palabras en blanco
	my $direccion_entrada = "Repositorio/$nombrevirus";
	my $direccion_salida = $direccion_entrada."/";
	
	$nombrevirus=~s/.gb//;
	$direccion_salida =~ s/\s/_/g;
	print "$nombrevirus\n";
	
	#Genero la carpeta donde metere cada uno todos las secuencias de esta especie de virus.
	system ("mkdir $direccion_salida");
	
	my $contenido = &abrir_archivo($direccion_entrada);
	
	my @muestras = split /\/\/\n/, $contenido;
	pop@muestras;
	
	my $temp =$direccion_salida."temp.txt";
	
	foreach my $muestra (@muestras){
		
		$muestra =~ s/ complement\(join\((\S+),\S+\)\)/$1/g;
		$muestra =~ s/ join\((\S+),\S+\)/$1/g;
		
		my $taxon;
		if ($muestra=~/Viruses; ssDNA viruses;\s(\S+;\s\S+)./){
			$taxon = $1;
		}
		else{
			$muestra=~/Viruses; Retro-transcribing viruses;\s(\S+;\s\S+)./;
			$taxon = $1;
		}
		
		$taxon =~ s/;//g;
		
		print "$taxon\n";
			
		open (OUTPUT, ">>$temp");
		print OUTPUT $muestra. "//";
		close(OUTPUT);
		
		
		my $seqio  = Bio::SeqIO->new (-format => 'GenBank',
								-file =>   "$temp");   #Se crea un objeto SeqIO de BioPerl
	
		my $objetoseq = $seqio->next_seq;  #Se. analizan una a una todas las secuencias contenidas en el archivo GeneBank
		
		my $ID=$objetoseq->display_id;   					#Se extrae el Accesion Number
		my $sequencia_total=$objetoseq->seq;  				#Se extrae la secuencia
		my $longitud_sequencia_total=$objetoseq->length();   	#Se extrae la longitud
		my @caracteristicas=$objetoseq->get_SeqFeatures();   	#Se extrae Todas las features en un array
		
		
		#Recorro cada una de las features de una en una:
		foreach my $caracteristica (@caracteristicas){
			#solo en el caso de ser CDS entro a analizarla (es donde esta la informacion de mis genes)
			if ($caracteristica->primary_tag =~ /CDS/){
				#Primero genero un objeto gen, donde guardo las caracteristicas de lo que voy encontrando
				print "1-$ID\n";
				print "2-$nombrevirus\n";
				print "3-$taxon\n";
				print "4-". $caracteristica->start."\n";
				print "4-". $caracteristica->end."\n";
				
				my $Gene = AnnotatedGene ->new (
					ID => $ID,
					Especie =>$nombrevirus,
					Taxonomia => $taxon,
					PosInicio => $caracteristica->start,
					PosFinal => $caracteristica->end,
					DNASeq => $objetoseq-> subseq($caracteristica->start,$caracteristica->end),
				);

				my @tags = $caracteristica->get_all_tags();    
				foreach my $tag (@tags){
					my @value = $caracteristica -> get_tag_values($tag);

					if ($tag=~ /gene/){$Gene->Name($value[0]);}
					elsif ($tag=~ /protein_id/){$Gene-> aaID($value[0]);}
					elsif ($tag=~ /translation/){$Gene-> aaSeq($value[0]);}	
				}
				
				unless ($Gene->has_name){
					foreach my $tag (@tags){
						my @value = $caracteristica -> get_tag_values($tag);
						if ($tag=~ /product/){$Gene->Name($value[0]);}
					}
					
				}
				
				if($Gene->has_name){
					my $comp = $Gene->Name;
					print "$comp\t";
					$comp=~s/"//g;
					$comp=~s/\/|\s|:/_/g;
					print "$comp\n";
					$Gene->Name($comp);
					}
				
				my $nombrearchivo= "DNA_".$Gene->Name.".fasta";
				my $output= $direccion_salida.$nombrearchivo;
				open (DNA, ">>$output");
				print DNA ">".$Gene->ID." ".$Gene->Name." ".$Gene->Taxonomia." ".$Gene->Especie."\n";
				print DNA $Gene->DNASeq. "\n";
				close(DNA);
				
				if ($Gene->has_AA){
					$nombrearchivo= "AA_".$Gene->Name.".fasta";
					$output= $direccion_salida.$nombrearchivo;
					open (AA, ">>$output");
					print AA ">".$Gene->ID." ".$Gene->Name." ".$Gene->Taxonomia." ".$Gene->Especie."\n";
					print AA $Gene->aaSeq. "\n";
					close(AA);
				}
			}
		}
		system ("rm $temp");
	}

		
		
	
}










		#####Funciones########
#Se mete la direccion como argumento y lo intenta abrir, si puede devuelve el contenido del archivo en un array.
sub abrir_archivo {
	my $nombrearchivo = $_[0];
	open (DATOS,$nombrearchivo) or die "La direcion dada del archivo no es correcta.\n";
	my @contenido = <DATOS>;
	close (DATOS);
	
	my $junto;
	foreach my $line (@contenido){
		$junto = $junto.$line;
	}
	
	return $junto;
	}

exit 1;
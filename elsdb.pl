#!/usr/bin/perl

# elsdb program used for truncating the super huge database dumps regularly received at Electric Easel

use Data::Dumper;
use Getopt::Long;

my $help = 0;
my $filename = 0;
my $dbname = 0;
my $dbtables = 0;
my $dbname_replace = 0;
GetOptions ('help|?' => \$help,
			'filename=s' => \$filename,
			'dbname=s' => \$dbname,
			'dbtables=s' => \$dbtables,
			'dbname_replace=s' => \$dbname_replace);


if ($help) {
	print "--filename -> source database file to be trimmed\n";
	print "--dbname -> name of database you wish to extract from the source dump\n";
	print "--dbname_replace -> replace the name of the chosen database with a new one (optional)\n";
	print "--dbtables -> comma separated name(s) of tables you wish to extract from the database (optional)\n";
	print "Example:\n";
	print "perl elsedb.pl --filename example.sql --dbname eebeta_rvotg --dbname_replace local_rvotg --tablename tbhl0_rv_resorts,tbhl0_rv_states,tbhl0_rv_regions\n";
	exit 1;
}

if (!$filename) {
	print "You must enter a filename for the database.\n";
	print "perl elsdb.pl --filename example.sql --dbname eebeta_rvotg\n";
	exit 0;
}

if (!dbname) {
	print "You must enter a database name, or this program does nothing!\n";
	print "perl elsdb.pl --filename example.sql --dbname eebeta_rvotg\n";
	exit 0;
}

@tables;
if ($dbtables) {
	@tables = split(",", $dbtables);
	foreach $table (@tables) {
		$table =~ s/^\s+//;
	}
}

print qq{Opening file $filename\n};
open(INPUT, "<$filename") || die "Couldn't open file $filename, $!";
@input = <INPUT>;
close(INPUT);


$truncated = $filename;
$truncated =~ s/.sql//;
$truncated = $truncated . "_truncated.sql";
$current_database = 0;
$use_table = 1;
open(OUTPUT, ">$truncated") || die "Couldn't create file $truncated, $!";
foreach $line (@input) {
	if (index($line, "-- Current Database:") != -1) {
		if (index($line, "`$dbname`") != -1) {
			$current_database = 1;
		}
		else {
			$current_database = 0;
		}
	}
	if ($current_database) {
		if ($dbtables) {
			if (index($line, "DROP TABLE IF EXISTS") != -1) {
				$use_table = 0;
				foreach $table (@tables) {
					if (index($line, "`$table`") != -1) {
						$use_table = 1;
						last;
					}
				}
			}
		}
		if ($use_table) {
			if ($dbname_replace) {
				$line =~ s/`$dbname`/`$dbname_replace`/ig;
			}
			print OUTPUT $line . "\n";
		}
	}
}
close(OUTPUT);
print qq{Data successfully extracted to $truncated\n};

exit 1;
#!/usr/bin/perl
#Get technical events from ClearStation
#Use pQuery to parse html.

use pQuery;
use LWP::UserAgent;
use HTTP::Cookies;

my $url = q{http://clearstation.etrade.com/cgi-bin/events?Cmd=techev};
my $agent = q{Mozilla/5.0 (Windows NT 6.1; WOW64; rv:7.0.1) Gecko/20100101 Firefox/7.0.12011-10-16 20:21:05};

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->agent($agent);

$cookie_jar = HTTP::Cookies->new(
'file' => 'cookies.lwp',
'autosave' => 1,
);


#html body table tbody tr td table tbody tr td font a
#:eq(41)>  td[3]/font/a
$ua->cookie_jar($cookie_jar);
$ua->default_header('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');

my $response = $ua->get($url);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$year +=1900; $mon +=1;

 if ($response->is_success) {
   	my $content = $response->decoded_content; 

	my $recfile = sprintf("%d%02d%02d_csTnB.html",$year,$mon,$mday);
	open FOUT ,">$recfile";
	local $/ = undef; 
	my $content = $response->decoded_content; 

	my $dom = pQuery($content);

	pQuery(" table",$dom)
	->eq(10)
	->find("tr") 
	#->find("td:eq(2)")
	#->find("table")
	#->find("tr")
	->each( sub{
			#my $html = pQuery($_)->html();
			pQuery($_)->find('tr[bgcolor="#F9F9F9"]')
			->each(
				sub{
					my $i = 0;
					print FOUT "\n";
					pQuery($_)->find('td')
					->each(
						sub{
							my $data = pQuery($_)->text();
							$data =~ s/Stocks//g;
							$data =~ s/{none}/0/;
							print FOUT $data;
							print FOUT "\t";
						
						}
						#my $html = pQuery($_)->html();
						#print $html;
					)
				}
			);
			#print $html;
		}
	);	

#	print $content;  # or whatever
 }
 else {
     die $response->status_line;
 }
#print F <<EOF;
#<html><header><title>$myfile</title></header>
#<body>
#EOF
#extract_msg($my_file);

#print F <<EOF;
#</body>
#</html>
#EOF
#close F;





sub extract_msg{
	my $file = shift;
	my ($msg,$to,$date,$from,$msgid);
	my $roi = pQuery($file)
	->find("table")
	->eq(6)
	->find("table")
	->eq(1)
	->find("table")
	->eq(2)
	->find("tr")
	->each( sub {
			my $i = shift;
			return if $i<2;
			unless($i%2) {
				pQuery($_)->find(".genmed")
				->each( sub {
						my $j = shift;
						#print "To:" unless $j;
						$to = pQuery($_)->html() unless $j;
						$msg = pQuery($_)->html() if $j;
						$msg =~ s/\n//g;
					}
				);
			}else{
				my $more = pQuery($_)->find(".genmed")->html();
				$more =~ /20\d\d\/\d+\/\d+/;
				$date = $&;
				$' =~ /\d\d\d+/;
				$msgid = $&;
				$' =~ />(.+)</; #from 
				$from = $1;
				print "mid: $msgid\n"; #mid
				print "Date: $date\n"; #date
				print "from:$from\n";
				#print To and Msg from previous match
				print "To:$to\n";
				$msg =~ s/\[quote:\w+\]/``/;
				$msg =~ s/\[\/quote:\w+\]/``/;
				print "Msg:\n>>>>\n$msg\n<<<<\n";
				print "====================\n\n";
				print_to_html($from,$to,$date,$msgid,$msg);
			}
		}

		);
	}


sub print_to_html{
my ($from,$to,$date,$msgid,$msg)= @_;

print F "<table>\n";
print F "<tr><td>Date:</td>\n";
print F "<td>$date</td>\n</tr>\n";
print F "<tr><td>From:</td>\n";
print F "<td>$from</td></tr>\n";
print F "<tr>\n<td>To:</td>\n";
print F "<td>$to</td>\n</tr>\n";

print F "<tr>\n<td>Message</td>\n";
print F "<td>$msg</td>\n</tr>\n";
print F "</table>\n<hr/>\n";
}








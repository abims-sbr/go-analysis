#!/bin/bash

# for file_i in `ls ../input/*GO.txt`; do ./goslimWrapper.sh $file_i; done

# head ../input/DESeq_DE_results_annotation_GO.txt
# XLOC_000033  Esi0000_0004  sctg_0:6141-12493  178.851651843987  56.4931772079136  301.210126480061  5.33179653485425  2.41462172720905  3.36600092546986e-08  hypothetical_protein  n/a;n/a;n/a
# XLOC_000064  Esi0000_0094  sctg_0:447666-482285  1429.52459662951  2214.95025267081  644.098940588212  0.290796120504987  -1.78192007241648  1.90062997159503e-06  nephroretinin_4_  GO:0005509;GO:0005509;GO:0005509
# XLOC_000090  Esi0000_0213  sctg_0:1133343-1145386  2173.52614923768  3525.86640621039  821.185892264957  0.232903291746544  -2.10219706481538  0.000290427451737621  conserved_unknown_protein  GO:0008270;n/a
# XLOC_000112  Esi0000_0311  sctg_0:1753989-1761699  219.43988405889  306.375402741933  132.504365375846  0.432490220135125  -1.20926058531044  0.00269188577736827  hypothetical_protein  GO:0005509
# XLOC_000135  Esi0000_0400  sctg_0:2290073-2296271  146.104619841429  83.77721485518  208.432024827678  2.48793213271628  1.31494713131695  0.00255461638304276  conserved_unknown_protein  GO:0006118;GO:0009055;GO:0016491;GO:0055114


input=$1
goslimobos=goslim_*.obo
gogenericobo="go-basic.obo"

# si DE
colGO=10
colFC=7

# si pas de DE
#colGO=3
#colFC="NA"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

inputbasename=`basename $input | sed "s/\.[a-z]\+$//"`
# echo $inputbasename
#
awk -F "\t" -v COLGO=$colGO -v COLFC=$colFC -v SEP=" " '(COLFC == "NA" || $(COLFC) >= 0 || $(COLFC) == "Inf") { FC=1 } (COLFC != "NA" && ($(COLFC) < 0 || $(COLFC) == "-Inf")) { FC=-1 }  { split($(COLGO),vals,SEP); for (val in vals) { print "unknow\t"$1"\t"$2"\t"FC"\t"vals[val] } }' $input | sort | uniq > $inputbasename.splitted.tab &&
mv $inputbasename.splitted.tab $inputbasename.formatted.tab &&

for goslimobo in ${goslimobos[*]}; do

  # goslim
  goslim=`basename $goslimobo | sed "s/\.obo$//"` &&

  echo -e "\t$goslim: map2slim" > /dev/stderr &&
  map2slim $goslimobo $gogenericobo $inputbasename.formatted.tab -o $inputbasename.$goslim.tab &&

  echo -e "\t$goslim: go2goterm" > /dev/stderr  &&
  $DIR/go2goterm.pl $inputbasename.$goslim.tab $gogenericobo | sort | uniq > $inputbasename.$goslim.term.tab &&
  mv $inputbasename.$goslim.term.tab $inputbasename.$goslim.tab &&

  echo -e "\t$goslim: counting" > /dev/stderr  &&
  awk -F "\t" '{ gsub(/ /,"_",$6) } { print $4,$5,$6,$7 }' $inputbasename.$goslim.tab | sort | uniq -c | awk '{ print $3"_"$4"\t"$5"\t"$1*$2 }' > $inputbasename.$goslim.count.tab &&
  sort $inputbasename.$goslim.tab | uniq | awk -F "\t" '{ gsub(/ /,"_",$6) } { print $4,$5,$6,$7 }' | sort | uniq -c | awk '{ print $3"_"$4"\t"$5"\t"$1*$2 }' > $inputbasename.$goslim.count.tab &&

  echo -e "\t$goslim: graph" > /dev/stderr  &&
  $DIR/goGraph.r $inputbasename.$goslim.count.tab

done

#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Shell
=== Directories
==== Navigation

```bash
# Print current directory path
pwd

# List directories
ls

# List directories including hidden
ls -a|--all

# List directories in long form
ls -l

# List directories in long form with human readable sizes
ls -l -h|--human-readable

# List directories by modification time, newest first
ls -t

# List size, created and modified timestamps for a file
stat foo.txt

# List size, created and modified timestamps for a directory
stat foo

# List directory and file tree
tree

# List directory and file tree including hidden
tree -a

# List directory tree
tree -d

# Go to foo sub-directory
cd foo

# Go to home directory
cd

# Go to home directory
cd ~

# Go to last directory
cd -
```

==== 2. Create directory

```bash

# Create a directory
mkdir foo

# Create multiple directories
mkdir foo bar

# Create nested directory
mkdir -p|--parents foo/bar

# Create multiple nested directories
mkdir -p|--parents {foo,bar}/baz


# Create a temporary directory
mktemp -d|--directory
```

==== 3. Moving Directories

```bash
# Copy directory
cp -R|--recursive foo bar

# Copy `file.txt` nella directory di destinazione
cp file.txt /path/to/destination/

# Crea una copia di `file.txt` con un nuovo nome
cp file.txt newfile.txt

# Chiede conferma prima di sovrascrivere file esistenti
cp -i file.txt /path/to/destination/

# Sovrascrive file esistenti senza chiedere conferma
cp -f file.txt /path/to/destination/

# Non sovrascrive mai file esistenti
cp -n file.txt /path/to/destination/

# Copia solo se il file sorgente è più recente o non esiste
cp -u file.txt /path/to/destination/

# Mostra ogni file mentre viene copiato
cp -v file.txt /path/to/destination/

# Copia una directory e tutto il suo contenuto ricorsivamente
cp -r dir/ /path/to/destination/


# Esempi pratici


# Copia tutti i file `.txt` nella directory di destinazione
cp *.txt /path/to/destination/

# Copia ricorsivamente `dir1` e tutti i file e subdirectory
cp -r dir1/ /path/to/destination/

# Copia tutti i `.txt` chiedendo conferma per eventuali duplicati
cp -i *.txt /path/to/destination/

# Move directory
mv foo bar

# Sposta `file.txt` nella directory specificata
mv file.txt /path/to/destination/

# Rinomina `file.txt` a `newname.txt`
mv file.txt newname.txt

# Rinomina `dir1` in `dir2`
mv dir1 dir2

# Chiede conferma se il file esiste già nella destinazione
mv -i file.txt /path/to/destination/

# Sovrascrive il file di destinazione senza conferma
mv -f file.txt /path/to/destination/

# Non sovrascrive mai file esistenti nella destinazione
mv -n file.txt /path/to/destination/

# Muove solo se il file sorgente è più recente di quello di destinazione
mv -u file.txt /path/to/destination/


# Esempi pratici


# Sposta tutti i file `.txt` nella directory specificata
mv *.txt /path/to/destination/

# Sposta tutti i contenuti di `dir1` nella destinazione chiedendo conferma per i duplicati
mv -i dir1/* /path/to/destination/
```

==== 4. Deleting Directories

```bash
# Delete non-empty directory
rmdir foo

# Delete directory including contents
rm -r|--recursive foo

# Delete directory including contents, ignore nonexistent files and never prompt
rm -r|--recursive -f|--force foo

# Rimuove un singolo file
rm file.txt

# Chiede conferma prima di rimuovere
rm -i file.txt

# Forza la rimozione senza chiedere conferma (utile per file con permessi di sola lettura)
rm -f file.txt

# Rimuove una directory e tutto il suo contenuto ricorsivamente
rm -r dir/

# Rimuove forzatamente una directory e tutto il suo contenuto ricorsivamente
rm -rf dir/

# Mostra i file e le directory mentre vengono rimossi
rm -v file.txt dir/

# Rimuove tutti i file con estensione `.txt` nella directory corrente
rm *.txt


# Esempi pratici


# Rimuove tutti i file `.txt` chiedendo conferma per ciascuno
rm -i *.txt

# Rimuove forzatamente la directory specificata e tutto il contenuto
rm -rf /path/to/dir
```

=== Files

==== 1. Creating Files

```bash
# Create file or update existing files modified timestamp
touch foo.txt

# Create multiple files
touch foo.txt bar.txt

# Create multiple files
touch {foo,bar}.txt

# Create test1, test2 and test3 files
touch test{1..3}

# Create testa, testb and testc files
touch test{a..c}


# Create a temporary file
mktemp
```

==== 2. stdin, stdout e stderr

```bash
# Overwrite file with content
echo "foo" > bar.txt

# Append to file with content
echo "foo" >> bar.txt


# Redirect the standard output to a file
ls exists 1> stdout.txt

# Redirect the standard error output to a file
ls noexist 2> stderror.txt

# Redirect standard output and error to a file
ls 2>&1 out.txt

# Discard standard output and error
ls > /dev/null

ls -lah
  # -l (Use a long listing format)
  # -a (List all entries including those starting with a dot)
  # -h (Print sizes in human readable format)

# Read from standard input and write to the variable foo
read foo
```

==== 3. Moving Files
```bash
# Copy file
cp foo.txt bar.txt

# Move file
mv foo.txt bar.txt

# Copy text files
cat file1 file2

# Combinate text files
cat file1 file2 > newcombinedfile

# Copy file1 to file2
cat < file1 > file2
```

==== 4. Deleting Files

```bash
# Delete file
rm foo.txt

# Delete file, ignore nonexistent files and never prompt
rm -f|--force foo.txt
```

==== 5. Reading Files

```bash
# Print all contents
cat foo.txt

# Print some contents at a time (g - go to top of file, SHIFT+g, go to bottom of file, /foo to search for 'foo')
less foo.txt

# Print top 10 lines of file
head foo.txt

# Print bottom 10 lines of file
tail foo.txt

# Open file in the default editor
open foo.txt

# List number of lines words and characters in the file
wc foo.txt
```

==== 6. File Permissions

#table(
  columns: (20pt, 1fr, 1fr, 1fr),
  [*\#*], [*Permission*], [*rwx*], [*Binary*],
  [7], [read, write and execute], [rwx], [111],
  [6], [read and write], [rw-], [110],
  [5], [read and execute], [r-x], [101],
  [4], [read only], [r--], [100],
  [3], [write and execute], [-wx], [011],
  [2], [write only], [-w-], [010],
  [1], [execute only], [--x], [001],
  [0], [none], [---], [000],
)

For a directory, execute means you can enter a directory.

#table(
  columns: 4,
  [*User*], [*Group*], [*Others*], [*Description*],
  [6],
  [4],
  [4],
  [User can read and write, everyone else can read (Default file permissions)],

  [7],
  [5],
  [5],
  [User can read, write and execute, everyone else can read and execute (Default directory permissions)],
)
- u - User
- g - Group
- o - Others
- a - All of the above

```bash
# List file permissions
ls -l /foo.sh

# Add 1 to the user permission
chmod +100 foo.sh

# Subtract 1 from the user permission
chmod -100 foo.sh

# Give the user execute permission
chmod u+x foo.sh

# Give the group execute permission
chmod g+x foo.sh

# Take away the user and group execute permission
chmod u-x,g-x foo.sh

# Give everybody execute permission
chmod u+x,g+x,o+x foo.sh

# Give everybody execute permission
chmod a+x foo.sh

# Give everybody execute permission
chmod +x foo.sh

# Edit proprietario o il gruppo di un file/directory.
chown [user][:nameoffile] nameoffile

# Permette di modificare il gruppo di un file/directory
chgrp group nameoffile
```

==== 7. Finding Files

Find binary files for a command.

```bash
# Find the binary
type wget

# Find the binary
which wget

# Find the binary, source, and manual page files
whereis wget
```

`locate` uses an index and is fast.

```bash
# Update the index
updatedb

# Find a file
locate foo.txt

# Find a file and ignore case
locate --ignore-case

# Find a text file starting with 'f'
locate f*.txt
```

`find` doesn't use an index and is slow.

```bash
# Find a file
find /path -name foo.txt

# Find a file with case insensitive search
find /path -iname foo.txt

# Find all text files
find /path -name "*.txt"

# Find a file and delete it
find /path -name foo.txt -delete

# Find all .png files and execute pngquant on it
find /path -name "*.png" -exec pngquant {}

# Find a file
find /path -type f -name foo.txt

# Find a directory
find /path -type d -name foo

# Find a symbolic link
find /path -type l -name foo.txt

# Find files that haven't been modified in 30 days
find /path -type f -mtime +30

# Delete files that haven't been modified in 30 days
find /path -type f -mtime +30 -delete
```

==== 8. Find in Files

```bash
# Search for 'foo' in file 'bar.txt'
grep 'foo' /bar.txt

# Search for 'foo' in directory 'bar'
grep 'foo' /bar -r|--recursive

# Search for 'foo' in directory 'bar' and follow symbolic links
grep 'foo' /bar -R|--dereference-recursive

# Show only files that match
grep 'foo' /bar -l|--files-with-matches

# Show only files that don't match
grep 'foo' /bar -L|--files-without-match

# Case insensitive search
grep 'Foo' /bar -i|--ignore-case

# Match the entire line
grep 'foo' /bar -x|--line-regexp

# Add N line of context above and below each search result
grep 'foo' /bar -C|--context 1

# Show only lines that don't match
grep 'foo' /bar -v|--invert-match

# Count the number lines that match
grep 'foo' /bar -c|--count

# Add line numbers
grep 'foo' /bar -n|--line-number

# Add colour to output
grep 'foo' /bar --colour

# Search for 'foo' or 'bar' in directory 'baz'
grep 'foo\\|bar' /baz -R

# Use regular expressions
grep --extended-regexp|-E 'foo|bar' /baz -R

# Use regular expressions
egrep 'foo|bar' /baz -R

# Show all lines that have a vowel as the third letter and start with s
grep '^s.[aeiou]'

# Cerca "pattern" in file.txt e stampa le righe corrispondenti
grep "pattern" file.txt

# Ricerca case-insensitive (ignora maiuscole/minuscole)
grep -i "pattern" file.txt

# Mostra le righe che *non* contengono "pattern"
grep -v "pattern" file.txt

# Ricerca ricorsiva in tutte le directory e file
grep -r "pattern" /path/to/dir/

# Elenca solo i nomi dei file che contengono il pattern
grep -l "pattern" *.txt

# Conta le righe che contengono il pattern
grep -c "pattern" file.txt

# Mostra le righe con numero di riga
grep -n "pattern" file.txt

# Mostra il nome del file nelle corrispondenze (utile per più file)
grep -H "pattern" file.txt

# Mostra solo le porzioni che corrispondono al pattern
grep -o "pattern" file.txt


# Regex avanzate


# Cerca righe che iniziano con "pattern"
grep "^pattern" file.txt

# Cerca righe che terminano con "pattern"
grep "pattern$" file.txt

# Cerca tre cifre consecutive (usando sintassi POSIX)
grep "[0-9]\{3\}" file.txt

# Cerca "one" o "two" (regex estesa)
grep -E "(one|two)" file.txt


# Esempi pratici


# Cerca "error" nei log di sistema, ignorando maiuscole/minuscole
grep -i "error" /var/log/syslog

# Cerca "TODO" in modo ricorsivo nella directory `projects`
grep -r "TODO" ~/projects/

# Conta le righe che iniziano con `#` (commenti)
grep -c "^#" script.sh
```

==== 9. Replace in Files

```bash
# Replace fox with bear in foo.txt and output to console
sed 's/fox/bear/g' foo.txt

# Replace fox (case insensitive) with bear in foo.txt and output to console
sed 's/fox/bear/gi' foo.txt

# Replace red with blue and fox with bear in foo.txt and output to console
sed 's/red fox/blue bear/g' foo.txt

# Replace fox with bear in foo.txt and save in bar.txt
sed 's/fox/bear/g' foo.txt > bar.txt

# Replace fox with bear and overwrite foo.txt
sed 's/fox/bear/g' foo.txt -i|--in-place


# Replace "fox" with "bear" in foo.txt and output to console
sed 's/fox/bear/g' foo.txt

# Replace "fox" (case insensitive) with "bear" in foo.txt and output to console
sed 's/fox/bear/gi' foo.txt

# Replace "red fox" with "blue bear" in foo.txt and output to console
sed 's/red fox/blue bear/g' foo.txt

# Replace "fox" with "bear" in foo.txt and save output to bar.txt
sed 's/fox/bear/g' foo.txt > bar.txt

# Replace "fox" with "bear" and overwrite foo.txt
sed -i 's/fox/bear/g' foo.txt


# Caratteri speciali


# Replace "a" followed by any character with "X"
sed 's/a./X/g' foo.txt

# Replace "f" followed by zero or more "o"s with "X"
sed 's/fo*/X/g' foo.txt

# Replace "fax" or "fox" with "bear"
sed 's/f[ao]x/bear/g' foo.txt

# Replace any vowel with "X"
sed 's/[aeiou]/X/g' foo.txt


# Classi e posizioni specifiche


# Replace "fox" only if it's at the end of the line
sed 's/fox$/bear/g' foo.txt

# Replace "fox" only if it's at the beginning of the line
sed 's/^fox/bear/g' foo.txt

# Replace any non-digit character with "X"
sed 's/[^0-9]/X/g' foo.txt

# Replace any uppercase letter with "X"
sed 's/[A-Z]/X/g' foo.txt


# Quantificatori


# Replace exactly "aaa" with "X"
sed -E 's/a{3}/X/g' foo.txt

# Replace "aa", "aaa", etc., with "X"
sed -E 's/a{2,}/X/g' foo.txt

# Replace "aa", "aaa", or "aaaa" with "X"
sed -E 's/a{2,4}/X/g' foo.txt


# Metacaratteri utili


# Replace any alphanumeric character with "X"
sed -E 's/\w/X/g' foo.txt

# Replace any non-alphanumeric character with "X"
sed -E 's/\W/X/g' foo.txt

# Replace any whitespace with "X"
sed -E 's/\s/X/g' foo.txt

# Replace any non-whitespace character with "X"
sed -E 's/\S/X/g' foo.txt


# Gruppi di cattura e riferimenti


# Replace "fox" with "bear" using capture group
sed -E 's/(fox)/bear/g' foo.txt

# Swap "fox" and "bear" in matching patterns
sed -E 's/(fox)(bear)/\2\1/g' foo.txt

# Reverse characters in "fox" to "xof"
sed -E 's/(f)(o)(x)/\3\2\1/g' foo.txt


# Sostituzioni condizionali


# Replace "fox" with "bear" only in lines containing "pattern"
sed '/pattern/s/fox/bear/' foo.txt

# Replace "fox" with "bear" only in the 5th line
sed '5s/fox/bear/' foo.txt

# Replace "fox" with "bear" only from lines 5 to 10
sed '5,10s/fox/bear/' foo.txt


# Aggiungere testo alla fine o all'inizio


# Append "END" at the end of each line
sed 's/$/ END/' foo.txt

# Add "START" at the beginning of each line
sed 's/^/START /' foo.txt


# Sostituire e duplicare con gruppi


# Duplicate "word" into "wordword"
sed -E 's/(word)/\1\1/g' foo.txt

# Replace "fox bear" with "bear fox"
sed -E 's/(fox) (bear)/\2 \1/g' foo.txt


# Eliminare righe e parole


# Delete lines that contain "pattern"
sed '/pattern/d' foo.txt

# Remove all digits
sed 's/[0-9]//g' foo.txt


# Modifiche In-Place con backup


# Replace "fox" with "bear" and create a backup file foo.txt.bak
sed -i.bak 's/fox/bear/g' foo.txt
```

#table(
  columns: 2,
  align: left,
  [*Simbolo*], [*Significato*],
  [`.`], [Corrisponde a qualsiasi singolo carattere],
  [`*`], [Corrisponde a zero o più occorrenze del carattere precedente],
  [`^`], [Inizio della riga],
  [`$`], [Fine della riga],
  [`[]`],
  [Corrisponde a qualsiasi carattere all'interno delle parentesi quadre],

  [`[^]`],
  [Corrisponde a qualsiasi carattere non presente nelle parentesi quadre],

  [`\`], [Escapes il carattere successivo],
  [`{n}`], [Corrisponde esattamente a `n` occorrenze del carattere precedente],
  [`{n,}`], [Corrisponde a `n` o più occorrenze del carattere precedente],
  [`{n,m}`], [Corrisponde tra `n` e `m` occorrenze del carattere precedente],
  [`()`],
  [Gruppi di cattura per le espressioni regolari, consentendo di trattare porzioni di testo come un'unica entità],

  [\```],
  [Indica un'espressione regolare letterale in alcune shell, utilizzata per racchiudere comandi o espressioni da eseguire (tuttavia, non è direttamente un metacarattere in `sed`)],

  [`?`], [Corrisponde a zero o una occorrenza del carattere precedente],
  [`+`],
  [Corrisponde a una o più occorrenze del carattere precedente (richiede l'uso di `-E` o `\+` in `sed`)],

  [`\b`], [Corrisponde a un confine di parola (inizio o fine di una parola)],
  [`\B`], [Corrisponde a un punto che non è un confine di parola],
)

==== Redirection Input/Ouput

```bash
# Redirect output on file
command > nameoffile

# Redirect output on file with append
command >> nameoffile

# Body of file passed to command (on stdin)
command < nameoffile

# stdout (command1) -> stdin (command 2)
command1 | command2

# Redirezioni di Output (Output Standard - STDOUT)



# Scrive "Hello World" in output.txt, sovrascrivendo il contenuto del file
echo "Hello World" > output.txt

# Aggiunge "Hello Again" alla fine di output.txt
echo "Hello Again" >> output.txt


# Redirezioni di Input (Input Standard - STDIN)


# Usa input.txt come input per il comando sort
sort < input.txt

# Conta le righe di input.txt e mostra il risultato
wc -l < input.txt


# Redirezione dell'Errore Standard (STDERR)


# Redirige solo l'errore (stderr) in error.txt
ls /nonexistent 2> error.txt

# Redirige stdout in output.txt e stderr in error.txt
ls /nonexistent > output.txt 2> error.txt

# Redirige sia stdout che stderr in all_output.txt (shorthand per `> output.txt 2>&1`)
ls /nonexistent &> all_output.txt


# Redirezioni Complesse con `2>&1`



# Redirige stderr (2) allo stesso file di stdout (1), output.txt
ls /nonexistent > output.txt 2>&1

# Scrive sia stdout che stderr in output.txt
echo "Text" > output.txt 2>&1

# Redirige stdout e stderr in output.txt e contemporaneamente su log.txt
command > output.txt 2>&1 | tee log.txt


# Append Output e Errore


# Aggiunge stdout a output.txt e stderr a error.txt
echo "Another line" >> output.txt 2>> error.txt

# Aggiunge sia stdout che stderr in all_output.txt
ls /nonexistent &>> all_output.txt


# /dev/null - Ignorare Output o Errori


# Scarta l'output standard (stdout)
command > /dev/null

# Scarta l'errore standard (stderr)
command 2> /dev/null

# Scarta sia stdout che stderr
command &> /dev/null


# Pipe e Subshell con Redirezioni


# Redirige separatamente stdout e stderr in subshell
(echo "stdout"; echo "stderr" >&2) > output.txt 2> error.txt

# Usa blocco con {} per redirigere stdout e stderr in un unico file
{ echo "stdout"; echo "stderr" >&2; } > all_output.txt 2>&1


# `tee` per Redirezione Multipla e Logging


# Mostra l'output e lo scrive in output.txt
echo "Logging info" | tee output.txt

# Mostra l'output e lo aggiunge a output.txt
echo "Append log" | tee -a output.txt

# Mostra, salva in output.txt e filtra con grep
command | tee output.txt | grep "pattern"


# Here Document (Input Multilinea)


cat << EOF > file.txt
Prima linea
Seconda linea

# Scrive il testo in file.txt
EOF


# Here Document con Esecuzione Comando


# Passa il contenuto come input a grep
cat << EOF | grep "pattern"
Prima linea
Seconda linea con pattern
EOF


# Here String (Passare Stringa come Input a un Comando)


# Cerca "pattern" in "Test string"
grep "pattern" <<< "Test string"

# Stampa il primo campo di una stringa
awk '{print $1}' <<< "campo1 campo2 campo3"


# Redirezioni in File Descriptor Personalizzati


# Apre il file descriptor 3 per la scrittura su custom_output.txt
exec 3> custom_output.txt

# Scrive "Test" su custom_output.txt tramite fd 3
echo "Test" >&3

# Chiude il file descriptor 3
exec 3>&-

# Apre il file descriptor 4 per la lettura da input.txt
exec 4< input.txt

# Legge una riga da fd 4 (input.txt)
read line <&4

# Chiude il file descriptor 4
exec 4<&-


# Redirezioni Complesse con File Descriptor e `exec`


# Apre fd 3 per stdout e fd 4 per stderr
exec 3> out.log 4> err.log

# Scrive su out.log tramite fd 3
echo "stdout" >&3

# Scrive su err.log tramite fd 4
echo "stderr" >&4

# Chiude i file descriptor 3 e 4
exec 3>&- 4>&-
```

=== AWK

```bash
# Struttura base: esegue l'azione su righe che corrispondono al pattern
awk 'pattern { action }' file.txt

# Usa la virgola come delimitatore; stampa la prima colonna
awk -F, '{ print $1 }' file.csv

# Stampa le righe che contengono "pattern"
awk '/pattern/' file.txt

# Stampa solo la prima riga del file
awk 'NR==1' file.txt

# Stampa il numero totale di righe nel file
awk 'END { print NR }' file.txt

# Somma i valori nella prima colonna
awk '{ sum += $1 } END { print sum }' file.txt

# Stampa le righe dove il primo campo è maggiore di 10
awk '{ if ($1 > 10) print $0 }' file.txt

# Stampa l'ultimo campo di ogni riga
awk '{ print $NF }' file.txt

# Stampa le righe con più di 80 caratteri
awk 'length($0) > 80' file.txt

# Cambia delimitatore da ':' a ',' e stampa le prime due colonne
awk 'BEGIN { FS=":"; OFS="," } { print $1, $2 }' file.txt

# Esegue l'azione all'inizio dell'esecuzione
awk 'BEGIN { print "Inizio" }'

# Esegue l'azione alla fine dell'esecuzione
awk 'END { print "Fine" }'

# Stampa il numero di riga e il contenuto di ogni riga
awk '{ print NR, $0 }' file.txt

# Usa variabili per confronti
awk -v var=10 '{ if ($1 > var) print $0 }' file.txt

# Modifica il primo campo e lo stampa
awk '{ $1 = $1 * 2; print }' file.txt

# Sostituisce "pattern" con "replacement" in ogni riga
awk 'gsub(/pattern/, "replacement")' file.txt

# Stampa le righe vuote
awk 'NF == 0' file.txt
```

=== Cut

```bash
# Estrae i primi 5 caratteri di ogni riga
cut -c 1-5 file.txt

# Estrae solo i caratteri 3 e 7 di ogni riga
cut -c 3,7 file.txt

# Estrae la seconda colonna in file delimitato da virgole
cut -d ',' -f 2 file.txt

# Estrae la prima e terza colonna
cut -d ',' -f 1,3 file.txt

# Estrae colonne da 2 a 4 (tab-separated di default)
cut -f 2-4 file.txt

# Estrae e unisce con delimitatore custom
cut -d ':' -f 1,3 --output-delimiter='-' /etc/passwd


# Usare `cut` con Pipe


# Estrae "campo2"
echo "campo1,campo2,campo3" | cut -d ',' -f 2

# Estrae il nome dell'utente
ps aux | cut -d ' ' -f 1

# Estrae filesystem e uso percentuale
df -h | cut -d ' ' -f 1,5

# Estrae colonne e cambia delimitatore a '|'
cat data.tsv | cut -f 1,3 --output-delimiter='|'
```

=== Sort

```bash
# Ordina alfabeticamente
sort file.txt

# Ordina in ordine inverso
sort -r file.txt

# Ordina numericamente
sort -n file.txt

# Ordina e rimuove le righe duplicate
sort -u file.txt

# Ordina file.txt e salva il risultato in sorted.txt
sort -o sorted.txt file.txt

# Ordina per seconda colonna usando "," come delimitatore
sort -t ',' -k 2 file.txt

# Ordina numericamente solo la terza colonna
sort -k 3,3n file.txt


# Ordinare con opzioni avanzate


# Ordina per seconda colonna, poi terza colonna numericamente
sort -k 2,2 -k 3,3n file.txt

# Ordina ignorando maiuscole e minuscole
sort -f file.txt

# Usa 4 thread per l’ordinamento
sort --parallel=4 file.txt


# Usare `sort` con pipe


# Ordina i processi per utilizzo CPU (decrescente)
ps aux | sort -k 3 -r

# Ordina i file per dimensione
ls -l | sort -k 5 -n

# Ordina CSV per prima colonna e rimuove duplicati
cat data.csv | sort -t ',' -k 1,1 -u
```

=== Head

```bash
# Mostra le prime 10 righe (default)
head file.txt

# Mostra le prime 5 righe
head -n 5 file.txt

# Mostra i primi 20 byte
head -c 20 file.txt

# Mostra le prime 10 righe di più file con nomi visibili
head -v file1.txt file2.txt

# Mostra i primi 10 righe di più file senza intestazioni
head -q file1.txt file2.txt


# Usare `head` con pipe


# Mostra i dettagli dei primi 3 file
ls -l | head -n 3

# Mostra le prime 10 righe della lista dei processi
ps aux | head
```

=== Tail

```bash
# Mostra le ultime 10 righe (default)
tail file.txt

# Mostra le ultime 5 righe
tail -n 5 file.txt

# Mostra gli ultimi 20 byte di file.txt
tail -c 20 file.txt

# Mostra le ultime 10 righe di più file con nomi visibili
tail -v file1.txt file2.txt


# Modalità di monitoraggio in tempo reale (molto utile per log)


# Mostra le nuove righe aggiunte a logfile.log in tempo reale
tail -f logfile.log

# Mostra le ultime 20 righe e poi continua a monitorare il file
tail -n 20 -f logfile.log

# Monitora anche dopo riavvii o ricreazioni del file
tail -F logfile.log


# Usare `tail` con pipe


# Mostra le ultime 20 righe del log del kernel
dmesg | tail -n 20

# Mostra i file più vecchi nella directory (ordinati per data)
ls -lt | tail
```

=== Word Count

```bash
# Conta righe, parole, e byte in file.txt
wc file.txt

# Conta solo le righe
wc -l file.txt

# Conta solo le parole
wc -w file.txt

# Conta solo i byte
wc -c file.txt

# Conta solo i caratteri (multibyte-safe)
wc -m file.txt

# Lunghezza della riga più lunga in file.txt
wc -L file.txt


# Contare file multipli


# Conta righe, parole, byte per ciascun file e totale combinato
wc file1.txt file2.txt


# Usare `wc` con pipe


# Conta parole nell'output di echo
echo "Hello World" | wc -w

# Conta il numero di file nella directory corrente
ls | wc -l
```

=== Compression/Decompression

==== 1a. zip

Compresses one or more files into \*.zip files.

```bash
# Compress bar.txt into foo.zip
zip foo.zip /bar.txt

# Compress bar.txt and baz.txt into foo.zip
zip foo.zip /bar.txt /baz.txt

# Compress bar.txt and baz.txt into foo.zip
zip foo.zip /{bar,baz}.txt

# Compress directory bar into foo.zip
zip -r|--recurse-paths foo.zip /bar
```

==== 2a. gzip

Compresses a single file into \*.gz files.

```bash
# Compress bar.txt into foo.gz and then delete bar.txt
gzip /bar.txt foo.gz

# Compress bar.txt into foo.gz
gzip -k|--keep /bar.txt foo.gz
```

==== 3a. tar -c

Compresses (optionally) and combines one or more files into a single *.tar, *.tar.gz, *.tpz or *.tgz file.

```bash
# Compress bar.txt and baz.txt into foo.tgz
tar -c|--create -z|--gzip -f|--file=foo.tgz /bar.txt /baz.txt

# Compress bar.txt and baz.txt into foo.tgz
tar -c|--create -z|--gzip -f|--file=foo.tgz /{bar,baz}.txt

# Compress directory bar into foo.tgz
tar -c|--create -z|--gzip -f|--file=foo.tgz /bar
```

==== 1b. unzip

```bash

# Unzip foo.zip into current directory
unzip foo.zip
```

==== 3b. tar -x

```bash
# Un-compress foo.tar.gz into current directory
tar -x|--extract -z|--gzip -f|--file=foo.tar.gz

# Un-combine foo.tar into current directory
tar -x|--extract -f|--file=foo.tar

# Verbosely list files processed
tar -xv
```

=== Identifying Processes

```bash
# List all processes interactively
top

# List all processes interactively
htop

# List all processes
ps all

# Return the PID of all foo processes
pidof foo

# Suspend a process running in the foreground
CTRL+Z

# Resume a suspended process and run in the background
bg

# Bring the last background process to the foreground
fg

# Bring the background process with the PID to the foreground
fg 1


# Sleep for 30 seconds and move the process into the background
sleep 30 &

# List all background jobs
jobs

# List all background jobs with their PID
jobs -p

# List all open files and the process using them
lsof

# Return the process listening on port 4000
lsof -itcp:4000
```

=== Process Priority

Process priorities go from -20 (highest) to 19 (lowest).

```bash
# Change process priority by name
nice -n -20 foo

# Change process priority by PID
renice 20 PID

# Return the process priority of PID
ps -o ni PID
```

=== Killing Processes

```bash
# Kill a process running in the foreground
CTRL+C

# Shut down process by PID gracefully. Sends TERM signal.
kill PID

# Force shut down of process by PID. Sends SIGKILL signal.
kill -9 PID

# Shut down process by name gracefully. Sends TERM signal.
pkill foo

# force shut down process by name. Sends SIGKILL signal.
pkill -9 foo

# Kill all process with the specified name gracefully.
killall foo
```

=== Secure Shell Protocol (SSH)

```bash
# Connect to hostname using your current user name over the default SSH port 22
ssh hostname

# Connect to hostname using the identity file
ssh -i foo.pem hostname

# Connect to hostname using the user over the default SSH port 22
ssh user@hostname

# Connect to hostname using the user over a custom port
ssh user@hostname -p 8765

# Connect to hostname using the user over a custom port
ssh ssh://user@hostname:8765
```

Set default user and port in `~/.ssh/config`, so you can just enter the name next time:

```bash
$ cat ~/.ssh/config
Host name
  User foo
  Hostname 127.0.0.1
  Port 8765
$ ssh name
```

=== Process management

```bash
# Process status, information about processes running in memory
ps

# Process viewer, find the CPU-intensive programs currently running (real-time)
top

# Process limit for single user
ulimit -u 300

# Sequential execution
./program1 ; ./program2

# Parallel execution
./program1 & ./program2

```

=== Command History

```bash
# Run the last command
!!

touch foo.sh

# !$ is the last argument of the last command i.e. foo.sh
chmod +x !$
```

=== Bash Script

==== Variables

```bash
# Initialize variable foo with 123
foo=123

# Initialize an integer foo with 123
declare -i foo=123

# Initialize readonly variable foo with 123
declare -r foo=123

# Print variable foo
echo $foo

# Print variable foo followed by _bar
echo ${foo}_'bar'

# Print variable foo if it exists otherwise print default
echo ${foo:-'default'}


# Make foo available to child processes
export foo

# Make foo unavailable to child processes
unset foo
```

==== Environment Variables

```bash

# List all environment variables
env

# Print PATH environment variable
echo $PATH

# Set an environment variable
export FOO=Bar
```

==== Functions

```bash
greet() {
  local world = "World"
  echo "$1 $world"
  return "$1 $world"
}
greet "Hello"
greeting=$(greet "Hello")
```

==== Exit Codes

```bash

# Exit the script successfully
exit 0

# Exit the script unsuccessfully
exit 1

# Print the last exit code
echo $?
```

==== Conditional Statements

==== Boolean Operators

- `$foo` - Is true
- `!$foo` - Is false

==== Numeric Operators

- `eq` - Equals
- `ne` - Not equals
- `gt` - Greater than
- `ge` - Greater than or equal to
- `lt` - Less than
- `le` - Less than or equal to
- `e` foo.txt - Check file exists
- `z` foo - Check if variable exists

==== String Operators

- `=` - Equals
- `==` - Equals
- `z` - Is null
- `n` - Is not null
- `<` - Is less than in ASCII alphabetical order
- `>` - Is greater than in ASCII alphabetical order

==== If Statements

```bash
if [[$foo = 'bar']]; then
  echo 'one'
elif [[$foo = 'bar']] || [[$foo = 'baz']]; then
  echo 'two'
elif [[$foo = 'ban']] && [[$USER = 'bat']]; then
  echo 'three'
else
  echo 'four'
fi
```

==== Inline If Statements

```bash
[[ $USER = 'rehan' ]] && echo 'yes' || echo 'no'
```

==== While Loops

```bash
declare -i counter
counter=10
while [$counter -gt 2]; do
  echo The counter is $counter
  counter=counter-1
done
```

==== For Loops

```bash
for i in {0..10..2}
  do
    echo "Index: $i"
  done

for filename in file1 file2 file3
  do
    echo "Content: " >> $filename
  done

for filename in *;
  do
    echo "Content: " >> $filename
  done
```

==== Case Statements

```bash
echo "What's the weather like tomorrow?"
read weather

case $weather in
  sunny | warm ) echo "Nice weather: " $weather
  ;;
  cloudy | cool ) echo "Not bad weather: " $weather
  ;;
  rainy | cold ) echo "Terrible weather: " $weather
  ;;
  * ) echo "Don't understand"
  ;;
esac
```
== Esercizi con pipeline
=== Esercizio 1
Trovare il file più grande in un ramo.
```bash
find /var -type f -print0 | xargs -0 du | sort -n | tail -1 | cut -f2 | xargs -I{} du -sh {}
```
+ `find /var -type f -print0`: Trova tutti i file sotto la directory /var.
  - -type f: Considera solo i file.
  - -print0: Stampa i percorsi dei file separandoli con un carattere nullo (\0), utile per evitare problemi con spazi nei nomi.
+ `xargs -0 du`: Passa l'elenco dei file a `du` per calcolarne la dimensione.
  - `-0`: Usa il carattere nullo come separatore (compatibile con -print0).
  - `du`: Calcola lo spazio occupato dai file.
+ `sort -n`: Ordina l'output numericamente (dimensioni crescenti).
+ `tail -1`: Prende l'ultima riga dell'output, corrispondente al file più grande.
+ `cut -f2`: Estrae il secondo campo della riga (il percorso del file).
+ `xargs -I{} du -sh {}`: Passa il percorso del file a du per ottenere la dimensione in formato leggibile (-sh).
=== Esercizio 2
Copiare file mantenendo la gerarchia

```bash
  find /usr/include/ -name 's\*.h' | xargs -I{} cp --parents {} ./localinclude
```

+ `find /usr/include/ -name 's\*.h`: Trova tutti i file con nomi che iniziano con s e terminano con .h.
+ `xargs -I{} cp --parents {} ./localinclude`: Copia i file mantenendo la struttura delle directory.
  - `--parents`: Preserva la gerarchia delle directory.
=== Esercizio 3
Calcolare lo spazio occupato dai file di un utente
```bash
find /home -user user -type f -exec du -k {} \; | awk '{ s = s+\$1 } END {print " Total used: ",s}'
```
+ `find /home -user user -type f -exec du -k {} \;`: Trova tutti i file di proprietà di user nella directory /home e calcola la loro dimensione:
  - `-user user`: Seleziona i file di un certo utente.
  - `-exec du -k {} \;`: Esegue du per calcolare la dimensione in KB.
+ `awk '{ s = s+$1 } END {print " Total used: ",s}'`: somma tutte le dimensioni calcolate da du e stampa il totale.
=== Esercizio 4
Contare il numero di file in un ramo (ramo home)
```bash
find /home -type f | wc -l
```
+ `find /home -type f`: Trova tutti i file nella directory /home.
+ `wc -l`: Conta il numero di righe nell'output di find, che corrisponde al numero di file.

=== Esercizio 5
Creare un archivio tar.gz contenente tutti i file minori di 50 KB
```bash
find / -type f -size -50k | tar --exclude "/dev/\*" --exclude "/sys/\*" --exclude "/proc/\*" -cz -f test.tgz -T -
```
+ `find / -type f -size -50k`: Trova tutti i file di dimensione inferiore a 50 KB.
  - `-size -50k`: Seleziona i file con dimensione < 50 KB.
  - `tar --exclude "/dev/\*" --exclude "/sys/\*" --exclude "/proc/\*" -cz -f test.tgz -T -`: Crea un archivio compresso (.tar.gz) con i file trovati:
- `--exclude`: Esclude alcune directory critiche (\/dev, /sys, /proc).
  - `-cz`: Crea (c) un archivio compresso con gzip (z).
  - `-f test.tgz`: Specifica il nome dell'archivio.
  - `-T -`: Usa l'elenco dei file dalla stdin (fornito da find).
=== Esercizio 6
Rinominare tutti i file .png in .jpg
```bash
find . -name '\*.png' | sed -e 's/.\*/mv & &/' -e 's/png$\/jpg/' | bash
```
+ `find . -name '\*.png'`: Trova tutti i file con estensione .png nella directory corrente.
+ `sed -e 's/.\*/mv & &/' -e 's/png\$/jpg/'`: Trasforma i nomi dei file in comandi mv:
  - `s/.\*/mv & &/`: Genera un comando mv per ogni file trovato.
  - `s/png\$/jpg/`: Cambia l'estensione .png in .jpg.
+ `bash`
Esegue i comandi mv generati.
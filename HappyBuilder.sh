#!/bin/bash

# Array to store type and format flag mappings
declare -A type_flags=(
    ["int"]="%i"
    ["char"]="%c"
    ["float"]="%f"
    ["char *"]="%s"
    ["double"]="%ld"
    ["unsigned int"]="%u"
)

# Function to get format flag for a type
get_format_flag() {
    local type="$1"
    echo "${type_flags[$type]}"
}

# Function to create sort.h header file
create_sort_header() {
    local project_name="$1"
    cat > "$project_name/sort.h" << 'EOF'
#ifndef SORT_H
#define SORT_H

void swap(int *a, int *b);
int naive_sort(int v[], int n);
int bubble_sort(int v[], int n);
int insertion_sort(int v[], int n);
int merge_sequences(int v[], int s1, int s2, int end);
int merge_sort(int v[], int n);
int quick_sort(int v[], int n);

#endif
EOF
}

# Function to create sort.c implementation file
create_sort_implementation() {
    local project_name="$1"
    cat > "$project_name/sort.c" << 'EOF'
#include "sort.h"

void swap(int *a, int *b) {
    int t = *a;
    *a = *b;
    *b = t;
}

int naive_sort(int v[], int n) {
    /* preparo un contatore per i confronti */
    int cnt = 0;
    /* Scorro l'intero array */
    int i, j, minidx;
    for(i = 0; i < n-1; ++i) {
        /* Determino il più piccolo degli elementi */
        minidx = i;
        for(j = i+1; j < n; ++j) {
            if(v[minidx] > v[j])
                minidx = j;
            /* un confronto in più */
            cnt++;
        }
        /* Scambio con l'elemento corrente */
        swap(&v[i], &v[minidx]);
    }
    /* restituisco il numero di confronti */
    return cnt;
}

int bubble_sort(int v[], int n) {
    /* Effettuo varie "passate" */
    int i, j;
    int cnt = 0;
    int ordinato;
    for(i = n; i > 1; --i) {    
        /* all'inizio ipotizzo che l'array sia ordinato */
        ordinato = 1;
        /* Ad ogni "passata" considero le coppie adiacenti */
        for(j = 0; j < i-1; ++j) {
            /* se l'ordine è invertito, scambio */
            if(v[j] > v[j+1]) {
                swap(&v[j], &v[j+1]);
                ordinato = 0;
            }
            /* un confronto in più */
            cnt++;
        }
        /* se l'array era veramente ordinato, posso interrompere */
        if(ordinato) break;
    }
    /* restituisco il numero di confronti */
    return cnt;
}

int insertion_sort(int v[], int n) {
    /* Considero tutte le posizioni dell'array */
    int i, j;
    int cnt = 0;
    for(i = 1; i < n; ++i) {
        /* Inserisco l'elemento attualmente in posizione
         * i-ma nella sua posizione corretta nella metà 
         * sx dell'array */
        for(j = i; j > 0; --j) {
            /* in ogni caso, facciamo un confronto in più */
            cnt++;
            /* se l'ordine è invertito, scambio */
            if(v[j-1] > v[j])
                swap(&v[j-1], &v[j]);
            /* altrimenti interrompo il processo */
            else
                break;
        }
    }
    /* restituisco il numero di confronti */
    return cnt;
}

/* Parametri:
 * - s1: inizio della prima sequenza
 * - s2: fine della prima sequenza ed inizio della seconda
 * - e2: fine della seconda sequenza */
int merge_sequences(int v[], int s1, int s2, int end) {
    int i;
    /* contatore dei confronti */
    int cnt = 0;
    /* proseguo finché almeno una delle sequenze non è esaurita  */
    while(s1 < s2 && s2 < end) {
        /* confronto i due elementi */
        cnt++;
        if(v[s1] < v[s2]) {
            /* in questo caso il primo elemento è già a posto */
            /* Adesso:
             * 1) La prima sequenza inizia una posizione più avanti
             * 2) La seconda sequenza è inalterata */
            s1++;
        }
        else {
            /* in questo caso l'elemento in s2 va messo in posizione
             * s1. Per farlo:
             * 1) Salvo il valore attualmente in v[s2] */
            int val = v[s2];
            /* 2) Faccio spazio in posizione s1 spostando tutta la
             *    prima sequenza in avanti */
            for(i = s2; i > s1; --i)
                v[i] = v[i-1];
            /* Ora posso inserire il valore salvato in posizione s1 */
            v[s1] = val;
            /* Adesso:
             * 1) La prima sequenza inizia una posizione più avanti
             * 2) ...e così anche la seconda sequenza */
            s1++;
            s2++;
        }
    }
    /* restituisco il numero di confroni effettuati */
    return cnt;
}

int merge_sort(int v[], int n) {
    /* contatore dei confronti */
    int cnt = 0;
    /* un vettore con un singolo elemento è sempre ordinato */
    if(n <= 1) return 0;
    /* altrimenti divido il vettore e riapplico l'algoritmo;
     * sfrutto il fatto che in C un array sia rappresentato
     * mediante un puntatore alla sua prima cella. Questo mi
     * permette di passare &v[mid], i.e. l'indirizzo della
     * cella in  mezzo */
    int mid = n/2;
    cnt += merge_sort(v, mid);
    cnt+= merge_sort(&v[mid], n-mid);
    /* fondo i risultati */
    cnt+= merge_sequences(v, 0, mid, n);
    /* restituisco il numero di confronti */
    return cnt;
}

int quick_sort(int v[], int n)  {
    /* contatore dei confronti */
    int cnt = 0;
    /* se l'array contiene 0 o 1 elementi, è già ordinato */
    if(n <= 1) return cnt;
    /* valore pivot */
    int pivot = v[n/2];
    /* Partiziono l'array in una sequenza "bassa" (i.e. < pivot) ed
     * "alta", i.e. > pivot.
     * Per farlo inizio dagli estremi e procedo verso il mezzo,
     * fino a trovare due elementi che si trovano entrambi nella
     * sequenza sbagliata: a questo punto gli elementi vengono
     * scambiati e si ripete il processo finché gli indici non si
     * incontrano */
    int s = 0, e = n-1;
    while(s < e) {
        /* sposto "s" in avanti finché non trovo un elemento
         * nella partizione sbagliata */
        while(v[s] < pivot) {
            s++;
            cnt++;
        }
        /* sposto "e" in indietro finché non trovo un elemento
         * nella partizione sbagliata */
        while(v[e] > pivot) {
            e--;
            cnt++;
        }
        /* Se i due indici non coincidono, uno scambio è necessario */
        if(s < e) {
            swap(&v[s], &v[e]);
            /* i due elementi sono a posto, quindi aggiorno s e e */
            s++;
            e--;
        }
    }
    /* "a" questo punto, "s" indica l'inizio della seconda sequenza e
     * la fine della prima sequenza. Posso invocare l'algoritmo sulle
     * due metà. */
    cnt += quick_sort(v, s);
    cnt += quick_sort(&v[s], n-s);
    /* restituisco il numero dei confronti */
    return cnt;
}
EOF
}

# Function to extract and transform sort function for struct
extract_and_transform_sort_function() {
    local order_type="$1"
    local order_struct="$2"
    local order_attribute="$3"
    
    # Create the struct-specific swap function
    cat << EOF

void swap_${order_struct}(${order_struct} *a, ${order_struct} *b) {
    ${order_struct} t = *a;
    *a = *b;
    *b = t;
}
EOF

    # Generate the specific sorting function based on order_type
    case "$order_type" in
        "naive")
            cat << EOF

int ${order_type}_sort(${order_struct} v[], int n) {
    /* preparo un contatore per i confronti */
    int cnt = 0;
    /* Scorro l'intero array */
    int i, j, minidx;
    for(i = 0; i < n-1; ++i) {
        /* Determino il più piccolo degli elementi */
        minidx = i;
        for(j = i+1; j < n; ++j) {
            if(v[minidx].${order_attribute} > v[j].${order_attribute})
                minidx = j;
            /* un confronto in più */
            cnt++;
        }
        /* Scambio con l'elemento corrente */
        swap_${order_struct}(&v[i], &v[minidx]);
    }
    /* restituisco il numero di confronti */
    return cnt;
}

void ordina(${order_struct} ${order_struct:0:4}[], int dim) {
    ${order_type}_sort(${order_struct:0:4}, dim);
}
EOF
            ;;
        "bubble")
            cat << EOF

int ${order_type}_sort(${order_struct} v[], int n) {
    /* Effettuo varie "passate" */
    int i, j;
    int cnt = 0;
    int ordinato;
    for(i = n; i > 1; --i) {    
        /* all'inizio ipotizzo che l'array sia ordinato */
        ordinato = 1;
        /* Ad ogni "passata" considero le coppie adiacenti */
        for(j = 0; j < i-1; ++j) {
            /* se l'ordine è invertito, scambio */
            if(v[j].${order_attribute} > v[j+1].${order_attribute}) {
                swap_${order_struct}(&v[j], &v[j+1]);
                ordinato = 0;
            }
            /* un confronto in più */
            cnt++;
        }
        /* se l'array era veramente ordinato, posso interrompere */
        if(ordinato) break;
    }
    /* restituisco il numero di confronti */
    return cnt;
}

void ordina(${order_struct} ${order_struct:0:4}[], int dim) {
    ${order_type}_sort(${order_struct:0:4}, dim);
}
EOF
            ;;
        "insertion")
            cat << EOF

int ${order_type}_sort(${order_struct} v[], int n) {
    /* Considero tutte le posizioni dell'array */
    int i, j;
    int cnt = 0;
    for(i = 1; i < n; ++i) {
        /* Inserisco l'elemento attualmente in posizione
         * i-ma nella sua posizione corretta nella metà 
         * sx dell'array */
        for(j = i; j > 0; --j) {
            /* in ogni caso, facciamo un confronto in più */
            cnt++;
            /* se l'ordine è invertito, scambio */
            if(v[j-1].${order_attribute} > v[j].${order_attribute})
                swap_${order_struct}(&v[j-1], &v[j]);
            /* altrimenti interrompo il processo */
            else
                break;
        }
    }
    /* restituisco il numero di confronti */
    return cnt;
}

void ordina(${order_struct} ${order_struct:0:4}[], int dim) {
    ${order_type}_sort(${order_struct:0:4}, dim);
}
EOF
            ;;
        "merge")
            cat << EOF

/* Parametri:
 * - s1: inizio della prima sequenza
 * - s2: fine della prima sequenza ed inizio della seconda
 * - e2: fine della seconda sequenza */
int merge_sequences_${order_struct}(${order_struct} v[], int s1, int s2, int end) {
    int i;
    /* contatore dei confronti */
    int cnt = 0;
    /* proseguo finché almeno una delle sequenze non è esaurita  */
    while(s1 < s2 && s2 < end) {
        /* confronto i due elementi */
        cnt++;
        if(v[s1].${order_attribute} < v[s2].${order_attribute}) {
            /* in questo caso il primo elemento è già a posto */
            /* Adesso:
             * 1) La prima sequenza inizia una posizione più avanti
             * 2) La seconda sequenza è inalterata */
            s1++;
        }
        else {
            /* in questo caso l'elemento in s2 va messo in posizione
             * s1. Per farlo:
             * 1) Salvo il valore attualmente in v[s2] */
            ${order_struct} val = v[s2];
            /* 2) Faccio spazio in posizione s1 spostando tutta la
             *    prima sequenza in avanti */
            for(i = s2; i > s1; --i)
                v[i] = v[i-1];
            /* Ora posso inserire il valore salvato in posizione s1 */
            v[s1] = val;
            /* Adesso:
             * 1) La prima sequenza inizia una posizione più avanti
             * 2) ...e così anche la seconda sequenza */
            s1++;
            s2++;
        }
    }
    /* restituisco il numero di confroni effettuati */
    return cnt;
}

int ${order_type}_sort(${order_struct} v[], int n) {
    /* contatore dei confronti */
    int cnt = 0;
    /* un vettore con un singolo elemento è sempre ordinato */
    if(n <= 1) return 0;
    /* altrimenti divido il vettore e riapplico l'algoritmo;
     * sfrutto il fatto che in C un array sia rappresentato
     * mediante un puntatore alla sua prima cella. Questo mi
     * permette di passare &v[mid], i.e. l'indirizzo della
     * cella in  mezzo */
    int mid = n/2;
    cnt += ${order_type}_sort(v, mid);
    cnt += ${order_type}_sort(&v[mid], n-mid);
    /* fondo i risultati */
    cnt += merge_sequences_${order_struct}(v, 0, mid, n);
    /* restituisco il numero di confronti */
    return cnt;
}

void ordina(${order_struct} ${order_struct:0:4}[], int dim) {
    ${order_type}_sort(${order_struct:0:4}, dim);
}
EOF
            ;;
        "quick")
            cat << EOF

int ${order_type}_sort(${order_struct} v[], int n)  {
    /* contatore dei confronti */
    int cnt = 0;
    /* se l'array contiene 0 o 1 elementi, è già ordinato */
    if(n <= 1) return cnt;
    /* valore pivot */
    int pivot = v[n/2].${order_attribute};
    /* Partiziono l'array in una sequenza "bassa" (i.e. < pivot) ed
     * "alta", i.e. > pivot.
     * Per farlo inizio dagli estremi e procedo verso il mezzo,
     * fino a trovare due elementi che si trovano entrambi nella
     * sequenza sbagliata: a questo punto gli elementi vengono
     * scambiati e si ripete il processo finché gli indici non si
     * incontrano */
    int s = 0, e = n-1;
    while(s < e) {
        /* sposto "s" in avanti finché non trovo un elemento
         * nella partizione sbagliata */
        while(v[s].${order_attribute} < pivot) {
            s++;
            cnt++;
        }
        /* sposto "e" in indietro finché non trovo un elemento
         * nella partizione sbagliata */
        while(v[e].${order_attribute} > pivot) {
            e--;
            cnt++;
        }
        /* Se i due indici non coincidono, uno scambio è necessario */
        if(s < e) {
            swap_${order_struct}(&v[s], &v[e]);
            /* i due elementi sono a posto, quindi aggiorno s e e */
            s++;
            e--;
        }
    }
    /* "a" questo punto, "s" indica l'inizio della seconda sequenza e
     * la fine della prima sequenza. Posso invocare l'algoritmo sulle
     * due metà. */
    cnt += ${order_type}_sort(v, s);
    cnt += ${order_type}_sort(&v[s], n-s);
    /* restituisco il numero dei confronti */
    return cnt;
}

void ordina(${order_struct} ${order_struct:0:4}[], int dim) {
    ${order_type}_sort(${order_struct:0:4}, dim);
}
EOF
            ;;
    esac
}

# Function to create project structure
create_project_structure() {
    # Ask for project folder name
    echo -n "Enter the name of the project folder: "
    read project_name
    mkdir -p "$project_name"
    
    # Collect .txt file names
    declare -a txt_files
    for i in {1..2}; do
        echo -n "Enter the name for the number $i .txt file (e.g., example): "
        read tmp
        txt_files+=("${tmp}.txt")
    done
    
    # Collect header and implementation file names
    echo -n "Enter the name for the header and implementation file (e.g., proc): "
    read name_files
    header_file="${name_files}.h"
    cpp_file="${name_files}.cpp"
    
    # Collect struct names and their fields
    declare -a structs
    declare -a dynamic
    declare -a struct_names
    declare -a struct_fields
    local array_num=0
    
    for i in {1..2}; do
        echo -n "Enter the name for struct $i: "
        read struct_name
        struct_names+=("$struct_name")
        
        echo -n "Does the struct need to be dynamically allocated? "
        read response
        dynamic+=("$response")
        
        echo -n "How many values for struct $struct_name? "
        read num_values
        
        echo -n "What is the maximum length of the array for this struct? "
        read array_num
        
        # Store field information
        declare -a current_fields
        for ((j=1; j<=num_values; j++)); do
            echo -n "Enter the type of value $j: "
            read value_type
            echo -n "Enter the name of value $j: "
            read value_name
            current_fields+=("$value_type|$value_name")
        done
        
        # Join fields with semicolon
        IFS=';' field_string="${current_fields[*]}"
        struct_fields+=("$field_string")
        unset current_fields
    done
    
    # Class information
    echo -n "Enter the name for your class: "
    read class_name
    echo -n "How many private variables you need? "
    read many_privates
    
    declare -a privates
    for ((j=1; j<=many_privates; j++)); do
        echo -n "Enter the type of value $j: "
        read private_type
        echo -n "Enter the name of value $j: "
        read private_name
        privates+=("$private_type|$private_name")
    done
    
    # Ordering information
    echo -n "What struct need to be ordered? "
    read order_struct
    echo -n "What attribute determines the order of the struct? "
    read order_attribute
    echo -n "What type of order algorithm you want to use (naive, bubble, insertion, merge, quick)? "
    read order_type
    
    # Create sort.h and sort.c files
    create_sort_header "$project_name"
    create_sort_implementation "$project_name"
    
    # Generate header file
    cat > "$project_name/$header_file" << EOF

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "sort.h"

#define MAX_LINE 512
#define FILE_DATI1 "${txt_files[0]}"
#define FILE_DATI2 "${txt_files[1]}"
EOF
    
    # Write structs to header file
    for i in {0..1}; do
        struct_name="${struct_names[$i]}"
        IFS=';' read -ra fields <<< "${struct_fields[$i]}"
        
        echo "" >> "$project_name/$header_file"
        echo "typedef struct $struct_name {" >> "$project_name/$header_file"
        
        for field in "${fields[@]}"; do
            IFS='|' read -r field_type field_name <<< "$field"
            echo "    $field_type $field_name;" >> "$project_name/$header_file"
        done
        
        echo "} $struct_name;" >> "$project_name/$header_file"
        
        if [[ "${dynamic[$i]}" == "no" ]]; then
            echo "int leggi$struct_name (const char * nomefile, $struct_name ${struct_name:0:2}[], int * dim);" >> "$project_name/$header_file"
        else
            echo "$struct_name* leggi$struct_name (const char * nomefile, int * dim);" >> "$project_name/$header_file"
        fi
        echo "void stampa$struct_name($struct_name ${struct_name:0:1});" >> "$project_name/$header_file"
    done
    
    # Add sorting and ordering functions
    echo "" >> "$project_name/$header_file"
    echo "int ${order_type}_sort($order_struct v[], int n);" >> "$project_name/$header_file"
    echo "void ordina ($order_struct ${order_struct:0:4}[], int dim);" >> "$project_name/$header_file"
    
    # Add class definition
    echo "" >> "$project_name/$header_file"
    echo "typedef class ${class_name}Class {" >> "$project_name/$header_file"
    for private in "${privates[@]}"; do
        IFS='|' read -r private_type private_name <<< "$private"
        echo "      $private_type $private_name;" >> "$project_name/$header_file"
    done
    echo "  public:" >> "$project_name/$header_file"
    echo "} $class_name;" >> "$project_name/$header_file"
    
    # Generate implementation file
    cat > "$project_name/$cpp_file" << EOF

#include "$header_file"

EOF
    
    # Generate struct functions
    for i in {0..1}; do
        struct_name="${struct_names[$i]}"
        IFS=';' read -ra fields <<< "${struct_fields[$i]}"
        
        # Print function
        cat >> "$project_name/$cpp_file" << EOF

void stampa$struct_name($struct_name ${struct_name:0:1}) {
    printf("\\v");
    printf("Dettagli $struct_name:\\n");
EOF
        
        for field in "${fields[@]}"; do
            IFS='|' read -r field_type field_name <<< "$field"
            format_flag=$(get_format_flag "$field_type")
            echo "    printf(\"\\t$field_name: $format_flag\\n\", ${struct_name:0:1}.$field_name);" >> "$project_name/$cpp_file"
        done
        
        cat >> "$project_name/$cpp_file" << EOF
    printf("\\v");
}

EOF
        
        # Read function
        if [[ "${dynamic[$i]}" == "no" ]]; then
            cat >> "$project_name/$cpp_file" << EOF

int leggi$struct_name (const char * nomefile, $struct_name ${struct_name:0:2}[], int * dim) {
    FILE* fp = fopen(nomefile, "r");
    if (fp == NULL) {
        printf("Errore durante l'apertura del file\\n");
        return -1;
    }

    char curr[MAX_LINE];
    int counter = 0;
    while (fgets(curr, MAX_LINE, fp)) {
EOF
            
            flags_string=""
            fields_string=""
            for field in "${fields[@]}"; do
                IFS='|' read -r field_type field_name <<< "$field"
                if [[ "$field_type" != "char *" ]]; then
                    fields_string+="&"
                fi
                fields_string+="${struct_name:0:2}[counter].$field_name, "
                format_flag=$(get_format_flag "$field_type")
                flags_string+="$format_flag "
            done
            fields_string=${fields_string%, }
            
            cat >> "$project_name/$cpp_file" << EOF

        sscanf(curr, "$flags_string", $fields_string);
        counter++;
    }

    *dim = counter;
    fclose(fp);
    return 0;
}
EOF
        else
            cat >> "$project_name/$cpp_file" << EOF

$struct_name* leggi$struct_name (const char * nomefile, int * dim) {
    FILE* fp = fopen(nomefile, "r");
    if (fp == NULL) {
        printf("Errore durante l'apertura del file\\n");
        return NULL;
    }

    $struct_name* newList = NULL;
    char curr_line[MAX_LINE];
    int counter = 0;
    while (fgets(curr_line, MAX_LINE, fp)) {
        $struct_name* temp = ($struct_name*) realloc(newList, sizeof($struct_name) * (size_t)(counter + 1));
        if (temp == NULL) {
            printf("Errore durante la reallocazione di memoria per la generazione della lista di strutture!\\n");
            return NULL;
        }

        newList = temp;
EOF
            
            flags_string=""
            fields_string=""
            for field in "${fields[@]}"; do
                IFS='|' read -r field_type field_name <<< "$field"
                if [[ "$field_type" != "char *" ]]; then
                    fields_string+="&"
                fi
                fields_string+="newList[counter].$field_name, "
                format_flag=$(get_format_flag "$field_type")
                flags_string+="$format_flag "
            done
            fields_string=${fields_string%, }
            
            cat >> "$project_name/$cpp_file" << EOF

        sscanf(curr_line, "$flags_string", $fields_string);
        counter++;
        }

    *dim = counter;
    return newList;
}
EOF
        fi
    done
    
    # Add the transformed sorting functions
    extract_and_transform_sort_function "$order_type" "$order_struct" "$order_attribute" >> "$project_name/$cpp_file"
    
    # Generate main.cpp
    cat > "$project_name/main.cpp" << EOF

#include "$header_file"

int main(void) {

    printf("Risoluzione primo esercizio...\\n");
    ${struct_names[0]} ${struct_names[0],,}[$array_num];
    int ${struct_names[0]:0:1}dim;
    if (leggi${struct_names[0]}(FILE_DATI1, ${struct_names[0],,}, &${struct_names[0]:0:1}dim) == -1) {
        return -1;
    }

    for (int i = 0; i < ${struct_names[0]:0:1}dim; i++) {
        stampa${struct_names[0]}(${struct_names[0],,}[i]);
    }

    int ${struct_names[1]:0:1}dim;
    ${struct_names[1]}* ${struct_names[1],,} = leggi${struct_names[1]}(FILE_DATI2, &${struct_names[1]:0:1}dim);
    if (${struct_names[1],,} == NULL) {
        return -1;
    }

    for (int k = 0; k < ${struct_names[1]:0:1}dim; k++) {
        stampa${struct_names[1]}(${struct_names[1],,}[k]);
    }
    printf("Termine del primo esercizio...\\n");
    printf("\\n");

    printf("Risoluzione secondo esercizio...\\n");

    printf("Termine del secondo esercizio...\\n");
    printf("\\n");

    printf("Risoluzione terzo esercizio...\\n");
    ordina(${struct_names[1],,}, ${struct_names[1]:0:1}dim);
    for (int g = 0; g < ${struct_names[1]:0:1}dim; g++) {
        stampa${struct_names[1]}(${struct_names[1],,}[g]);
    }
    printf("Termine del terzo esercizio...\\n");
    printf("\\n");

    printf("Risoluzione del quarto esercizio...\\n");

    printf("Termine risoluzione quarto esercizio...\\n");
    printf("\\n");

    printf("Risoluzione del quinto esercizio...\\n");
    free(${struct_names[1],,});
    printf("Termine risoluzione quinto esercizio...\\n");
    printf("\\n");

    return 0;
}
EOF
    
    echo "Project '$project_name' created successfully!"
    echo "Files created:"
    echo "  - $project_name/sort.h"
    
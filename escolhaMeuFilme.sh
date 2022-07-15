if [ $# -ne 1 ]; then
    echo "Comando: ./escolhaMeuFilme.sh listaDeFilmes.csv";
    exit 1;
fi

IFS=$'\n'

maxAverage=0.0
movieTitle=""
movieYear=0
movieIMDb=0.0
movieRotten=0.0
movieRating=""
movieGenre=""

for line in $(cat $1); do
    title=$(awk -F"," '{print $3;}' <<< "$line")

    if [ $title = "Title" ]; then
        continue;
    fi

    imdbValue=$(awk -F"," '{print $6;}' <<< "$line")
    rottenValue=$(awk -F"," '{print $7;}' <<< "$line")

    #Validar valores numéricos
    # echo "---Argumentos do if: $imdbValue ||| $rottenValue"
    if [ $imdbValue =~ [ ^a-zA-Z ] -o $imdbValue =~ "" -o $rottenValue =~ "" -o $rottenValue =~ [ ^a-zA-Z ] ]; then
    # if ! [ $imdbValue ^[0-9] -o $rottenValue ^[0-9] ]; then
        continue;
    fi

        
    imdbValue=$(echo "scale=1; $imdbValue / 1" | bc -l)    
    rottenValue=$(echo "scale=1; $rottenValue / 10" | bc -l)
    sum=$(echo "scale=1; $rottenValue + $imdbValue" | bc -l)
    average=$(echo "scale=1; $sum / 2" | bc -l)   

    # Adicionar aleatoriedade echo $(($RANDOM%2+1 - 1))
    if [ 1 -eq "$(echo "$average > $maxAverage" | bc -l)" ]; then
            maxAverage=$average
            movieTitle=$(awk -F"," '{print $3;}' <<< "$line")
            movieYear=$(awk -F"," '{print $4;}' <<< "$line")
            movieRating=$(awk -F"," '{print $5;}' <<< "$line")
            movieIMDb=$(awk -F"," '{print $6;}' <<< "$line")
            movieRotten=$(awk -F"," '{print $7;}' <<< "$line")
            movieGenre=$(awk -F"," '{print $8;}' <<< "$line")
    fi
done

echo "Filme com maior média de avaliações";
echo "Título: $movieTitle";
echo "Ano: $movieYear";
echo "Nota IMDb: $movieIMDb";
echo "Nota Rotten: $movieRotten";
echo "Classificação indicativa: $movieRating";
echo "Gênero: $movieGenre";
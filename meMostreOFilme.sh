if [ $# -ne 3 ]; then
    echo "Comando: ./meMostreOFilme.sh listaDeFilmes.csv '[Gênero]' [AnoMínimo]";
    exit 1;
fi

genres=("Action & Adventure" "Animation" "Anime" "Biography" "Comedy" "Crime" "Documentary" "Drama" "Family" "Fantasy" "Horror" "Mistery" "Romance" "Thriller")
compatibleGenre=0
minimunYear=$3
chosenGenre=$2
echo "Gênero escolhido: $chosenGenre" 
echo "Ano mínimo escolhido: $minimunYear" 

for genre in "${genres[@]}"; do    
    if [[ $chosenGenre = $genre ]]; then
        compatibleGenre=1;
        break;
    fi
done

if [ $compatibleGenre -eq 0 ]; then
    echo "Gênero não encontrado, os gêneros disponíveis são: "
    echo ${genres[*]}
    exit 1;
fi

if [ $minimunYear -lt 1931 -o $minimunYear -gt 2021 ]; then
    echo "Ano está fora do limite de dados 1931-2021"
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

    imdbValue=$(awk -F"," '{print $5;}' <<< "$line")
    rottenValue=$(awk -F"," '{print $6;}' <<< "$line")
    lineGenre=$(awk -F"," '{print $7;}' <<< "$line")
    lineYear=$(awk -F"," '{print $4;}' <<< "$line")

    numberRegex="[0-9.]$" 
    if [[ $imdbValue =~ numberRegex || $rottenValue =~ numberRegex ]]; then
        continue    
    fi

    if [[ $lineGenre != $chosenGenre ]]; then
        continue
    fi

    if [[ $lineYear -lt $minimunYear ]]; then
        continue
    fi

    imdbValue=$(echo "scale=1; $imdbValue / 1" | bc -l)    
    rottenValue=$(echo "scale=1; $rottenValue / 10" | bc -l)
    sum=$(echo "scale=1; $rottenValue + $imdbValue" | bc -l)
    average=$(echo "scale=1; $sum / 2" | bc -l)   

    if [ 1 -eq "$(echo "$average > $maxAverage" | bc -l)" ]; then
            maxAverage=$average
            movieTitle=$(awk -F"," '{print $3;}' <<< "$line")
            movieYear=$(awk -F"," '{print $4;}' <<< "$line")
            movieIMDb=$(awk -F"," '{print $5;}' <<< "$line")
            movieRotten=$(awk -F"," '{print $6;}' <<< "$line")
            movieGenre=$(awk -F"," '{print $7;}' <<< "$line")
    fi
done

if [[ $maxAverage < 1 ]]; then
    echo "Nenhum filme encontrado com os critérios estabelecidos"
else
    echo "Filme com maior média de avaliações";
    echo "Título: $movieTitle";
    echo "Ano: $movieYear";
    echo "Nota IMDb: $movieIMDb";
    echo "Nota Rotten: $movieRotten";
    echo "Gênero: $movieGenre";
fi
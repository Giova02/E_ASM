#include <stdio.h>
#include <string.h>

#define WORD_LEN 120


int main(){
    char nomefile[WORD_LEN+1];
    printf("inserisci nome del file:\n");

    scanf("%s",nomefile);
    FILE* Order = fopen(nomefile, "r");
    
    int ProductsNumber = 1;
    if(Order){
        while(!feof(Order)){
            char temp;
            fscanf(Order, "%c", &temp);
            if(temp == '\n') ProductsNumber++;
        }
        
        printf("products: %d\n\n", ProductsNumber);

        rewind(Order);
        int Products[ProductsNumber][4];

        while(!feof(Order)){
            char temp;
            int Pflag = 0;  // Product Flag
            fscanf(Order, "%c", &temp);

            printf("%c", temp);

            if(temp != '\n'){
                int Cflag = 0;  // Comma Flag
                int Nflag = 0;  // Number Flag  
                if(temp != ','){
                    if (Nflag>0){
                        Products[Pflag][Cflag] = (Products[Pflag][Cflag]*10)+(temp-48);
                    }
                    else{
                        Products[Pflag][Cflag] = temp-48;
                    }
                    Nflag++;
                }
                Cflag++;
            }
            Pflag++;
        }

        printf("\n\n");

        // debugging
        for(int i=0; i<ProductsNumber; i++){
                printf("ID: %d\tDur: %d\tExp: %d\tPrior: %d\n\n", Products[i][0], Products[i][1], Products[i][2], Products[i][3]);
        }

        fclose(Order);
        
    }
    else{
        printf("Errore di apertura del file");
    }

}

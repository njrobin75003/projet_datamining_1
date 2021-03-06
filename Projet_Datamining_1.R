# --------------------------------------------------------------------------------------------------
# Projet_Datamining_1.R
#
# Description   : Script R reproduisant les etapes vues avec le logiciel SPAD de Coheris Analytics
#                 destine au Data Mining et a l’analyse predictive.
#
#                 Sont reproduites les 3 etapes principales suivantes :
#                 - Etape 1 : le calcul des statistiques descriptives.
#                 - Etape 2 : le groupement des modalites interessantes.
#                 - Etape 3 : la regression logistique.

# Developpeurs  : Antoine GNIMASSOUN, Nicolas ROBIN.
# Date          : 2018-11-19
#
# --------------------------------------------------------------------------------------------------

# Chargement des bibliotheques R necessaires au projet.
# Assurez-vous que les bibliotheques suivantes ont bien ete installees dans RStudio.
library(xlsx)
library(dplyr)
library(stats)
library(tidyr)
library(DT)
library(glm2)

# Definition de l'espace de travail.
Espace_De_Travail_Antoine <- 'C:/Users/antoi/Desktop/MBA/Mes cours/Data Mining'
Espace_De_Travail_Nicolas <- '/Users/nrobin/Documents/GitHub/projet_datamining_1'

# CHOISIR VOTRE ESPACE DE TRAVAIL ICI, SI VOUS DESIREZ EXECUTER CE SCRIPT AVEC RSTUDIO.
Espace_De_Travail_Antoine_Eric <- 'C:/Users/TBD...'

# CHOISIR VOTRE ESPACE DE TRAVAIL ICI, SI VOUS DESIREZ EXECUTER CE SCRIPT AVEC RSTUDIO.
Espace_De_Travail_Choisi <- Espace_De_Travail_Nicolas

# Le nom du fichier de donnees a telecharger
Fichier_de_donnees <- "base_credit.xlsx"

# Mise en place de l'espace de travail de l'environnement pour l'execution des scripts R.
setwd(Espace_De_Travail_Choisi)

# Chargement du fichier de donnees dans une table nommee base_credit.
base_credit <- read.xlsx(Fichier_de_donnees, sheetIndex=1, header=TRUE, stringsAsFactors=TRUE, encoding="UTF-8")

# --------------------------------------------------------------------------------------------------
# ETAPE 1 - STATISTIQUES DESCRIPTIVES
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Statistiques descriptives initiales pouvant etre utilisees sur les variables continues.
#
# Fonction            : descriptives_stats_dataframe (colonne)
# Description         : Cette fonction retourne the statistiques descriptives (en tant que dataframe)
# Parametre en entree : colonne, une colonne renfermant un ensemble de variables continues.
# Valeur retournee    : un dataframe renfermant les statistiques de base equivalentes a celles
#                       rendues dans SPAD :
#                           - Moyenne,
#                             Ecart type, 
#                             Minimum, Maximum, 
#                             Min2, Max2,
#                             Coefficient de variation,
#                             Mediane.
# 
#                       Avec en plus :
#                           - Variance,
#                           - Valeurs manquantes,
#                           - Taux de valeurs manquantes.
# --------------------------------------------------------------------------------------------------
stats_descri_personnalise <- function(varname, x) {
  
  # Definition du nombre de virgules apres la virgule.
  # Valeur choisie a 3 comme dans SPAD.
  precision = 3
  
  # Fonction qui renvoie un dataframe avec l'ensemble des statistiques descriptives des valeurs de la table.
  data_frame_stats <- data.frame ( 
    Variable=varname,
    # Calcul du nombre de lignes, sans donnees manquantes
    Effectif=length(x[!is.na(x)]),
    # Calcul de la moyenne
    Moyenne=round(mean(x, na.rm=TRUE),precision),
    # Calcul de l'ecart-type
    'Ecart Type'=round(sd(x, na.rm=TRUE),precision),
    # Minimum
    Minimum=min(x,na.rm = TRUE),
    # Maximum
    Maximum=max(x,na.rm = TRUE),
    # Min2
    'Min 2'=sort(unique(x,na.rm = TRUE))[2],
    # Max2
    'Max 2'=sort(unique(x,na.rm = TRUE),decreasing = TRUE)[2],
    # Calcul du Coefficiant de Variation
    'CV'=round(sd(x, na.rm=TRUE) / mean(x, na.rm=TRUE), precision),
    # Calcul de la mediane
    Mediane=median(x, na.rm=TRUE)
    # Et en plus...
    # Calcul de la variance
    #Variance=round(var(x, na.rm=TRUE), precision),
    # Nombre de donnees manquantes
    #'Valeurs manquantes'=length(x[is.na(x)]),
    # Pourcentage de valeurs manquantes
    #'Taux de valeurs manquantes'=length(x[is.na(x)])
  )
  
  return(data_frame_stats)
}

# --------------------------------------------------------------------------------------------------
# Pour obtenir les statistiques descriptives des variables continues, appeler la fonction 
# stats_descri_personnalise() et lui preciser la colonne des variables continues dont on veut les statistiques.
table_column_names <- colnames(base_credit)
score1_column_index = 14
score2_column_index = 15

stat_score1 <- stats_descri_personnalise(table_column_names[score1_column_index], base_credit$Score.1) 
stat_score2 <- stats_descri_personnalise(table_column_names[score2_column_index], base_credit$Score.2)
stat_score <- rbind.data.frame(stat_score1, stat_score2)

# Affichage des statistiques dans un widget HTML
datatable(stat_score,
          rownames = FALSE,
          options = list(paging = FALSE, searching = FALSE, info = FALSE, scrollX = 400))

# --------------------------------------------------------------------------------------------------
# ETAPE 2 - REGROUPEMENT DES MODALITES INTERESSANTES
# --------------------------------------------------------------------------------------------------
#
# DESCRIPTION DES VARIABLES QUALITATIVES
# --------------------------------------------------------------------------------------------------
# 1 - Situation familiale
# 1a - Calcul des effectifs 
effectifs1=table(base_credit$Situation.familiale,useNA = "always")
# 1b - Calcul des frequences
frequences1=round(prop.table(effectifs1),3)
# 1c - Creation d'une table avec effectifs et calculs
effectifs_et_frequences_situation_familliale <- cbind(effectifs1, frequences1)

# Affichage du calcul des effectifs et des frequences de la situation familiale.
datatable(effectifs_et_frequences_situation_familliale,
          rownames = TRUE,
          options = list(paging = FALSE, searching = FALSE, info = FALSE))

# 2 - Domiciliation de l'epargne
# 2a - Calcul des effectifs 
effectifs2=table(base_credit$Domiciliation.de.l.épargne,useNA = "always")
# 2b - Calcul des frequences
frequences2=round(prop.table(effectifs2),3)
# 2c - Creation d'une table avec effectifs et calculs
effectifs_et_frequences_domiciliation_epargne <- cbind(effectifs2, frequences2)

# Affichage du calcul des effectifs et des frequences de la domiciliation de l'epargne.
datatable(effectifs_et_frequences_domiciliation_epargne,
          rownames = TRUE,
          options = list(paging = FALSE, searching = FALSE, info = FALSE))


# REGROUPEMENT DES MODALITES --> la table "base_credit" est modifiee.
# --------------------------------------------------------------------------------------------------
# Regroupement de modalites "divorce" et "veuf" sur la variable situation_familiale
base_credit$Situation.familiale<-recode(base_credit$Situation.familiale, 
                                        "célibataire" = "célibataire",
                                        "divorcé" = "divorcé/veuf",
                                        "marié" = "marié",
                                        "veuf" = "divorcé/veuf") 

# Regroupement de modalites "de 10 a 100K epargne" et "plus de 100K epargne" sur
# la variable domiciliation_de_lepargne
base_credit$Domiciliation.de.l.épargne<-recode(base_credit$Domiciliation.de.l.épargne,
                                                "moins de 10K épargne"="moins de 10K épargne", 
                                                "pas d'épargne"="pas d'épargne",
                                                "de 10 à 100K épargne"="plus de 10K épargne", 
                                                "plus de 100K épargne"="plus de 10K épargne")

# DESCRIPTION DES VARIABLES QUALITATIVES REGROUPEES
# --------------------------------------------------------------------------------------------------
# 1 - Situation familiale
# 1a - Calcul des effectifs 
effectifs_modifiees1=table(base_credit$Situation.familiale,useNA = "always")
# 1b - Calcul des frequences
frequences_modifiees1=round(prop.table(effectifs_modifiees1),3)
# 1c - Creation d'une table avec effectifs et calculs
effectifs_et_frequences_situation_familliale_modifiee <- cbind(effectifs_modifiees1, frequences_modifiees1)

# Affichage du calcul des effectifs et des frequences de la situation familiale.
datatable(effectifs_et_frequences_situation_familliale_modifiee,
          rownames = TRUE,
          options = list(paging = FALSE, searching = FALSE, info = FALSE))

# 2 - Domiciliation de l'epargne
# 2a - Calcul des effectifs 
effectifs_modifiee2=table(base_credit$Domiciliation.de.l.épargne,useNA = "always")
# 2b - Calcul des frequences
frequences_modifiees2=round(prop.table(effectifs_modifiee2),3)
# 2c - Creation d'une table avec effectifs et calculs
effectifs_et_frequences_domiciliation_epargne_modifiee <- cbind(effectifs_modifiee2, frequences_modifiees2)

# Affichage du calcul des effectifs et des frequences de la domiciliation de l'épargne.
datatable(effectifs_et_frequences_domiciliation_epargne_modifiee,
          rownames = TRUE,
          options = list(paging = FALSE, searching = FALSE, info = FALSE))

# --------------------------------------------------------------------------------------------------
# ETAPE 3 - REGRESSION LOGISTIQUE SUR LA BASE MODIFIEE
# --------------------------------------------------------------------------------------------------

# Discretisation de la variable a expliquer
base_credit$Type.de.client<- recode(base_credit$Type.de.client,
                                    "Bon client"= 1,
                                    "Mauvais client"= 0)

# On cree nos echantillons de test et d'apprentissage avec les valeurs 1 et 2
ind <- sample(2, nrow(base_credit), replace=T, prob=c(0.75,0.25))

# Training sur 75% de la population
tdata<- base_credit[ind==1,]

# Validation sur 25% de la population
vdata<- base_credit[ind==2,]

# Choix des modalites de reference
base_credit$Age.du.client <- relevel(base_credit$Age.du.client, ref = "moins de 23 ans")
base_credit$Situation.familiale <- relevel(base_credit$Situation.familiale, ref = "divorcé/veuf")
base_credit$Ancienneté <- relevel(base_credit$Ancienneté, ref = "anc. 1 an ou moins")
base_credit$Domiciliation.du.salaire <- relevel(base_credit$Domiciliation.du.salaire, ref = "Non domicilié")
base_credit$Domiciliation.de.l.épargne <- relevel(base_credit$Domiciliation.de.l.épargne, ref = "pas d'épargne")
base_credit$Profession <- relevel(base_credit$Profession, ref = "cadre")
base_credit$Moyenne.encours <- relevel(base_credit$Moyenne.encours, ref = "plus de 5 K encours")
base_credit$Moyenne.des.mouvements <- relevel(base_credit$Moyenne.des.mouvements, ref = "de 10 à 30K mouvt")
base_credit$Cumul.des.débits <- relevel(base_credit$Cumul.des.débits, ref = "plus de 100 débits")
base_credit$Autorisation.de.découvert <- relevel(base_credit$Autorisation.de.découvert, ref = "découvert autorisé")
base_credit$Interdiction.de.chéquier <- relevel(base_credit$Interdiction.de.chéquier, ref = "chéquier interdit")

# Estimation du modele avec les donnees d'entrainement
# On prend comme variable explicative, la variable "Type.de.Client" (index 2)
# Les autres variables sont considerees comme etant des variables explicatives (index 3 a 13).
# La premiere variable n'est pas prise en compte car il s'agit de l'"Identifiant.Client".
# On utilise la fonction glm() pour utiliser le modele lineaire generalise pour faire la regression logistique.
fit.glm = glm(tdata[,2]~.,data=tdata[,3:13],family=binomial)

# On affiche les resultats de la regression avec les variables
drop1(fit.glm,test ="F")

# Affiche un resume des coefficients utilises pour la regression.
# On affiche les modalites pour chaque variable.
summary(fit.glm)

# ---------------------------------------------------------------------------------------------------
# Donnees de test et d'entrainement
# ---------------------------------------------------------------------------------------------------
# Prediction avec les donnees de test
score.glm = predict(fit.glm, vdata[,3:13],type="response")
sum(as.numeric(predict.glm(fit.glm,vdata[,3:13],type="response")>=0.5))
class.glm=as.numeric(predict.glm(fit.glm,vdata[,3:13],type="response")>=0.5)
table(class.glm,vdata[,2])

# Prediction avec les donnees d'entrainement.
score.glm2 = predict(fit.glm, tdata[,3:13],type="response")
sum(as.numeric(predict.glm(fit.glm,tdata[,3:13],type="response")>=0.5))
class.glm2=as.numeric(predict.glm(fit.glm,tdata[,3:13],type="response")>=0.5)
table(class.glm2,tdata[,2])

# ---------------------------------------------------------------------------------------------------
# Calcul des proportions pour la matrice de confusion (on a choisi comme seuil 0.5)
# ---------------------------------------------------------------------------------------------------

# Proportion de bien classes (bon clients) sur les donnees de test
sum( score.glm >= 0.5 & vdata[,2]==1)/sum(vdata[,2]==1)
# Proportion de bien classes (mauvais clients) sur les donnees de test
sum( score.glm < 0.5 & vdata[,2]==0)/sum(vdata[,2]==0)

# Proportion de bien classes (bon clients) sur les donnees d'entrainement
sum( score.glm2 >= 0.5 & tdata[,2]==1)/sum(tdata[,2]==1)
# Proportion de bien classes (mauvais clients) sur les donnees d'entrainement
sum( score.glm2 < 0.5 & tdata[,2]==0)/sum(tdata[,2]==0)

# Graduation des axes pour la representation de la courbe ROC
s=quantile(score.glm,probs=seq(0,1,0.01)) 
# Vecteur vide qui comportera par la suite tous les pourcentages de vrais positifs (PVP)
PVP = rep(0,length(s))
# Vecteur vide qui comportera par la suite tous les pourcentages de faux positifs (PFP)
PFP = rep(0,length(s))

# Pour chaque valeur du vecteur s (vu comme seuil), on calcule les PVP et PFP
for (i in 1:length(s)){
  PVP[i]=sum(score.glm>=s[i]& vdata[,2]==1)/sum(vdata[,2]==1)
  PFP[i]=sum( score.glm >=s[i] & vdata[,2]==0)/sum(vdata[,2]==0) }

# Affichage de la courbe ROC montrant les clients positifs classes positifs 
# versus les clients positifs classes negatifs.
plot(PFP,PVP,type="l",col="red")

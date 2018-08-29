library(rvest)
library(dplyr)

#cr�ation des urls de d�part
main_url <- "https://fr.wikipedia.org/wiki/D�c�s_en_"
annee <- 2011:2016

urls <- paste0(main_url, annee)
#vecteur vide qui contiendra les urls des pages
liens <- vector()
#r�colte des urls des pages
for (url in urls) {
  liens <-
    c(liens,
      url %>% read_html() %>% html_nodes("p~ p+ ul a") %>% html_attr("href"))
}
#transforme les urls relatives en urls absolues
liens <- paste0("https://fr.wikipedia.org", liens)
#boucle principale qui r�cup�rera les tableaux html dans chaque page
tableau <- list()
index <- 1
for (lien in liens) {
  #le try({}) permet de passer outre les erreurs dues � de mauvais liens
  try({
    print(lien)
    table <-
      lien %>% read_html() %>% html_table(fill = TRUE) %>% data.frame()
    #on transforme la colonne Source, inutile, pour y stocker l'URL de la page
    table[, "Source"] <- lien
    #on cr�e une colonne ann�e en r�cup�rant cette derni�re dans l'url de la page
    matches <- regexpr("\\d{4}$", lien)
    table$annee <- lien %>% regmatches(matches, invert = FALSE)
  
    
    #ajoute les dataframes � la liste
    tableau[[index]] <- table
    index <- index + 1
  })
  
  # #on r�cup�re le lien vers la fiche des d�c�d�s
  # try({
  # links <- lien %>% read_html() %>% html_nodes( css="td:nth-child(2) a:nth-child(1)") %>% html_attr('href')
  # 
  # urls <- paste0("https://fr.wikipedia.org", links)
  # 
  # table['liens'] <- urls})
}

#fusionne la liste de dataframes en un seul
tableau_complet <- do.call("rbind", tableau)
#�criture du fichier
#write.csv(tableau_complet, "tableau_complet.csv", fileEncoding = "UTF-8")
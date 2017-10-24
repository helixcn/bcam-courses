# German Credit Data

# link: http://ftp.ics.uci.edu/pub/machine-learning-databases/statlog/german/

data <- read.table("http://ftp.ics.uci.edu/pub/machine-learning-databases/statlog/german/german.data", header = FALSE)

colnames(data)<-c("account.status","months",
                "credit.history","purpose","credit.amount",
                "savings","employment","installment.rate","personal.status",
                "guarantors","residence","property","age","other.installments",
                "housing","credit.cards","job","dependents","phone","foreign.worker","credit.rating")

head(data)
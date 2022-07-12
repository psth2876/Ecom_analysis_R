remove(list=ls())
### Setting working directory. 
setwd("D:/DataDoorGit/R Data Science Projects/")

library(ggplot2) # It is a library used for visualizations.
library(skimr) 
library(dplyr) # It is used for data manipulations.
library(scales) 
library(reshape)
library(tidyr)
library(magrittr)
library(corrplot)

dframe <- read.csv("ecom_store.csv") # Read the csv file and create a new dataframe.

dim(dframe) # Displays the dimension of the dataframe.

head(dframe) # It displays some of the top rows.

tail(dframe) # It displays some of the last rows.

str(dframe) # understand dataframe and its datatypes with their values.

# first check empty or missing values in overall dataframe. 
sum(is.na(dframe)) # It shows total number of missing values.

# check whether columns have either NA or empty cells.
empty_columns <- colSums(is.na(dframe) | dframe == "" | dframe == " ")
empty_columns

# check empty rows from postalcode column Which has almost 40k rows 
dframe_isna <- dframe[(is.na(dframe$Postal.Code) | dframe$Postal.Code=="" | dframe$Postal.Code==" "), ]
length(dframe_isna$Postal.Code)

## Remove RowID and Country as Country has only one value in all rows 'US'. 
dframe = subset(dframe, select = -c(Country,Row.ID,Postal.Code))

## Creating new column  Shipping Time
dframe$shipping_time <- as.Date(as.character(dframe$Ship.Date),
                                format="%Y-%m-%d") - as.Date(as.character(dframe$Order.Date), format="%Y-%m-%d")

dframe$order<-dframe$Order.Date
dframe<-separate(dframe,order,c("month","day","year"),sep="-")

maxSales <- max(dframe$Sales)
dframe$Sales <- replace(dframe$Sales, dframe$Sales==maxSales,mean(dframe$Sales))

#### We see that there is an outlier in the Sales feature, an unusual hike. We should replace it with the mean of sales.

summary(dframe)

skim(dframe)

region_order <- table(dframe$Market)
barplot(region_order, main="Total Orders by Markets",xlab="Markets",col="lightblue")

#### The above bar chart displays the total number of orders by market areas which clearly shows Africa has the minimum order counts (less than 5000).
## The Asia pacific has maximum orders placed while Europe is following it and remaining LATAM and USCA are almost identical at close to 10k.

hist(dframe$Quantity, main="Frequency Distribution of Quantity",xlab="Quantity Ordered",ylab="Frequency",col="lightpink")

#### The above histogram chart shows the frequency distribution of the quantity ordered. The maximum ordered quantity is 1 which is greater than 20000. 
## It is then followed by 2, the frequency for which is close to 10000. This plot clealry shows as the quantity gets increased the frequency count gets decresed.The quantity ordered 14 has the least frequency.

gd <- dframe %>% group_by(Category) %>% summarize(Sales=sum(Sales))
pct <- round(gd$Sales/sum(gd$Sales)*100)
lbls <- paste(gd$Category,pct)
lbls <- paste(lbls,"%", sep = " ")
colors = c('lightskyblue','plum2','peachpuff')
pie(gd$Sales, labels=lbls, main="", col=colors)

#### The above pie chart shows the percentage sales by category that includes Technology, Furniture and Office Supplies. Product category "Technology" has
## contributed maximum sales which is 37%. It is then followed by "Furniture” which is 33%. "Office Supplies" has contributed the least which is 30%.

num_data_cols <- dframe[,c(16,17,18,19,20)]
data.cor = cor(num_data_cols)
data.cor

corrplot(data.cor)


ggplot(data = dframe, aes(x = Quantity, y = Sales, fill = Ship.Mode) )+ geom_bar(stat = "identity")

ggplot(data = dframe, aes(x = Sales, y = Profit, color = Ship.Mode)) + geom_point()

ggplot() + geom_point(data = dframe, aes(x = Sales, y = Profit, color = Category))

ggplot() + geom_point(data = dframe, aes(x = Discount, y = Sales, color = Ship.Mode)) 

ggplot() + geom_bar(data = dframe, aes(x = Sub.Category, y = Profit, fill = Market), stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggplot() + geom_bar(data = dframe, aes(x = Category, y = Sales, fill = Order.Priority), stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggplot(dframe,aes(x=Market,fill=Segment)) + 
  geom_bar(position = "stack") + labs(title = 'Total number of category based on Segments.',x='categories',y='Total number of Categories') + facet_wrap(~Segment)

ggplot(dframe,aes(y=shipping_time,fill=Market)) + 
  geom_bar(position = "stack") + labs(title = 'Total number of injuries by Race and Sex.',
                                      x='Race of patients',y='Total number of patients')

ggplot(dframe,aes(x=Category,fill=Order.Priority)) + 
  geom_bar(position = "stack") + labs(title = 'Sub category .',
                                      x='Race of patients',y='Total number of patients')+ facet_wrap(~Order.Priority)

df_ship_cost__mean <- aggregate(dframe$Shipping.Cost, list(dframe$Order.Priority), FUN=mean)

ggplot(df_ship_cost__mean,aes(x=Group.1, y = x, fill=Group.1))+
  geom_bar( stat = "identity")+
  labs(title = 'Mean plot of losses Grouped by disasters.',x='Disaster',y='Losses')

num_cols <-dframe %>% dplyr::select(where(is.numeric))
num_cols<-num_cols[,1:5]

res1 <- cor.test(dframe$Sales, dframe$Quantity, 
                 method = "pearson")

res2 <- cor.test(dframe$Sales, dframe$Discount, 
                 method = "pearson")

res3 <- cor.test(dframe$Sales, dframe$Profit, 
                 method = "pearson")

res4 <- cor.test(dframe$Sales, dframe$Shipping.Cost, 
                 method = "pearson")

df_standardize <- as.data.frame(scale(num_cols))
data_sorted_stand <- df_standardize[order(df_standardize$Sales, decreasing = TRUE), ]
after_sort_stand = data_sorted_stand[-c(1:20),]
boxplot(after_sort_stand)

data_sorted_stand_profit <- after_sort_stand[order(after_sort_stand$Profit,decreasing = TRUE), ]
after_sort_stand_v2 = data_sorted_stand_profit[-c(1:5),]
dframe<-after_sort_stand_v2
boxplot(after_sort_stand_v2)

data_sorted_stand2 <- data_sorted_stand_profit[order(data_sorted_stand_profit$Profit), ]
after_sort_stand2 = data_sorted_stand2[-c(1:5),]
dframe<-after_sort_stand2
boxplot(after_sort_stand2)

bc <- select(dframe,Sales,Profit,Shipping.Cost,Quantity,Discount)
bc_model_full <- lm(Sales ~ Shipping.Cost + Profit + Quantity + Discount, data=dframe)
bc_model_full

preds <- predict(bc_model_full)

plot(preds, bc$Sales, xlab = "Prediction", ylab = "Observed")
abline(a = 0, b = 1)

summary(bc_model_full)


set.seed(123)
ind <- sample(2, nrow(bc), replace=TRUE, prob=c(0.80, 0.20))
bc_train <- bc[ind==1,]
bc_test <- bc[ind==2,]


#Let's build now a linear regression model using the training data and print it:
(bc_model <- lm(Sales ~ Shipping.Cost + Profit + Quantity+Discount, data=bc_train))

#We can also view the model's summary
summary(bc_model)


######Evaluating graphically
#Let's make predictions on our training dataset and store the predictions as a new column
bc_train$pred <- predict(bc_model)

# plot the ground truths vs predictions for training set
ggplot(bc_train, aes(x = pred, y = Sales)) +
  geom_point() +
  geom_abline(color = "blue")

bc_test$pred <- predict(bc_model , newdata=bc_test)

# plot the ground truths vs predictions for test set and examine the plot. Does it look as good with the predictions on the training set?
ggplot(bc_test, aes(x = pred, y = Sales)) +
  geom_point() +
  geom_abline(color = "blue")

bc_mean <- mean(bc_test$Sales)
tss <- sum((bc_test$Sales - bc_mean)^2)
err <- bc_test$Sales-bc_test$pred
rss <- sum(err^2)
(rsq <- 1-(rss/tss))


#Calculate residuals
res <- bc_train$Sales-bc_train$pred
#For training data we can also obtain the residuals using the bc_model$residuals

# Calculate RMSE, assign it to the variable rmse and print it
(rmse <- sqrt(mean(res^2)))


# Calculate the standard deviation of actual outcome and print it
(sd_bc_train <- sd(bc_train$Sales))
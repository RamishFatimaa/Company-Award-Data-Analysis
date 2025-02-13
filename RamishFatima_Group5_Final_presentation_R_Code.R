#Ramish Fatima
#Fall 2023
#CPS [BOS-A-HY]
#ALY6010: Probability Theory and Introductory Statistics
#Assignment — Milestone 5
#12/08/2023

#Boilerplate code
cat("\014")  # clears console
rm(list = ls())  # clears global environment
try(dev.off(dev.list()["RStudioGD"]), silent = TRUE)
# clears plots
try(p_unload(p_loaded(), character.only = TRUE), silent = TRUE)
# clears packages
options(scipen = 100) # disables scientific notion for entire R session

#Libraries
install.packages("corrplot")
library(pacman)
library(corrplot)
p_load(tidyverse)
p_load(janitor)
library(ggplot2)

#Part1: Data Storing
#Read the CSV file into a data frame
company_award_data <- read.csv("Group5_Final_project_dataset_NC_AL.csv")

#PART2: Data Cleaning
# Check the structure of the data
str(company_award_data)


# Load necessary packages
library(lubridate)
#Approach1:
# Convert date columns to date-time objects
company_award_data$Proposal.Award.Date <- mdy(company_award_data$Proposal.Award.Date) # date format is MM-DD-YYYY
company_award_data$Contract.End.Date <- mdy(company_award_data$Contract.End.Date) # Adjust format as needed

#Approach2:
# Convert Award.Amount from string to numeric after removing special characters
company_award_data$Award.Amount <- as.numeric(gsub("[$,]", "", company_award_data$Award.Amount))

#Approach3:
# Calculate percentage of missing values in each column
missing_percentages <- colMeans(is.na(company_award_data)) * 100

# Display columns with high missing percentages (e.g., over 50%)
high_missing_cols <- names(missing_percentages[missing_percentages > 50])

# Show columns with high missing percentages and their missing percentages
high_missing_cols_with_percentage <- missing_percentages[missing_percentages > 50]

# Output columns with high missing percentages and their respective percentages
print(high_missing_cols_with_percentage)
print(high_missing_cols)

# List of columns to be removed
cols_to_remove <- c(
  "Contract", "Address2", "Contact.Email", "PI.Phone", 
  "RI.POC.Phone", "PI.Email", "RI.POC.Name", "Contact.Email", 
  "Solicitation.Number", "Address1", "Zip", "Contact.Phone",
  "Agency.Tracking.Number", "Company.Website"
)



# Remove specified columns from the dataframe
company_award_data <- company_award_data[, !(names(company_award_data) %in% cols_to_remove)]

#Approach4:
# Convert 'Hubzone.Owned', 'Socially.and.Economically.Disadvantaged', 'Woman.Owned' to factors
company_award_data$Hubzone.Owned <- as.factor(company_award_data$Hubzone.Owned)
company_award_data$Socially.and.Economically.Disadvantaged <- as.factor(company_award_data$Socially.and.Economically.Disadvantaged)
company_award_data$Woman.Owned <- as.factor(company_award_data$Woman.Owned)

# Ensure consistency in boolean values
company_award_data$Hubzone.Owned <- factor(company_award_data$Hubzone.Owned, levels = c("N", "Y"), labels = c("No", "Yes"))
company_award_data$Socially.and.Economically.Disadvantaged <- factor(company_award_data$Socially.and.Economically.Disadvantaged, levels = c("N", "Y"), labels = c("No", "Yes"))
company_award_data$Woman.Owned <- factor(company_award_data$Woman.Owned, levels = c("N", "Y"), labels = c("No", "Yes"))

# Check the updated structure of the dataframe
str(company_award_data)

#Approach5:
# Replace NA in 'Company' with 'Unknown'
company_award_data$Company[is.na(company_award_data$Company)] <- "Unknown"
# Replace NA in 'Branch' with 'Unknown'
company_award_data$Company[is.na(company_award_data$Branch)] <- "Unknown"

library(ggplot2)

# Create a dataframe with missing percentage before and after cleaning
missing_summary <- data.frame(
  Column = names(missing_percentages),
  Percent_Missing = missing_percentages
)

# Plot bar plot for missing values before and after cleaning
ggplot(missing_summary, aes(x = Column, y = Percent_Missing, fill = "red")) +
  geom_bar(stat = "identity") +
  labs(title = "Percentage of Missing Values Before Cleaning") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


#PART4:Descriptive statistical tables
# Install psych package 
install.packages("psych")

# Load the psych package
library(psych)

# Descriptive statistics for discrete numerical variables
describe(company_award_data$Number.Employees)
describe(company_award_data$Award.Amount)


# Descriptive statistics for categorical variables
table(company_award_data$Hubzone.Owned)
table(company_award_data$Socially.and.Economically.Disadvantaged)
table(company_award_data$Woman.Owned)
table(company_award_data$Phase)
table(company_award_data$Program)


# Filter data for states 'NC' and 'AL'
filtered_data <- company_award_data %>% 
  filter(State %in% c("NC", "AL"))

# Count occurrences of agencies for each state
count_data <- table(filtered_data$State, filtered_data$Agency)

# Convert the table to a data frame for plotting
count_df <- as.data.frame(count_data)
colnames(count_df) <- c("State", "Agency", "Count")

# Plotting a bar plot for count of entries in the 'Agency' column for 'NC' and 'AL'
ggplot(count_df, aes(x = Agency, y = Count, fill = State)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  labs(title = "Count of Agencies in NC and AL", x = "Agency", y = "Count", fill = "State") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))  # Rotate x-axis labels if needed

hubzone_pie <- ggplot(company_award_data, aes(x = "", fill = Hubzone.Owned)) +
  geom_bar(width = 1, color = "white") +
  coord_polar("y", start = 0) +
  geom_text(aes(label = paste0(round((..count..)/sum(..count..) * 100, 1), "%")), 
            stat = "count", position = position_stack(vjust = 0.5)) +
  labs(title = "Hubzone Ownership") +
  theme_void()

hubzone_pie

phase_plot <- ggplot(company_award_data, aes(x = Phase)) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(title = "Phase Count", x = "Phase", y = "Count") +
  theme_minimal()

phase_plot


#PART5: VISUALIZATION
library(dplyr)
library(tidyr)

# Grouping and summarizing data
pivot_data <- company_award_data %>%
  group_by(Agency, Program, Phase) %>%
  summarise(Avg_Award_Amount = mean(Award.Amount, na.rm = TRUE)) %>%
  ungroup()

# Pivot table
pivot_table <- pivot_data %>%
  pivot_wider(names_from = Phase, values_from = Avg_Award_Amount)

# Viewing the pivot table
head(pivot_table)

library(ggplot2)

# Creating a heatmap
ggplot(pivot_data, aes(x = Phase, y = Agency, fill = Avg_Award_Amount)) +
  geom_tile() +
  facet_wrap(~Program, scales = "free_y") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Average Award Amount Across Phases, Agencies, and Programs", x = "Phase", y = "Agency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Visualization#2

#Line Plot for Trends Over Years
# Aggregate data by Award Year
yearly_summary <- company_award_data %>%
  group_by(Award.Year) %>%
  summarise(Avg_Award_Amount = mean(Award.Amount, na.rm = TRUE),
            Total_Grants = n())

# Line plot showing trends
ggplot(yearly_summary, aes(x = Award.Year, y = Avg_Award_Amount)) +
  geom_line() +
  geom_point() +
  labs(title = "Average Award Amount Over Years", x = "Award Year", y = "Average Award Amount") +
  theme_minimal()

# Bar plot for total grants over years
ggplot(yearly_summary, aes(x = factor(Award.Year), y = Total_Grants)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Total Number of Grants Over Years", x = "Award Year", y = "Total Number of Grants") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#visualization#3:

# Grouping data by City and summarizing grant counts
city_summary <- company_award_data %>%
  group_by(City) %>%
  summarise(Total_Grants = n()) %>%
  arrange(desc(Total_Grants)) %>%
  top_n(10) # Display top 15 cities for better visualization

# Bar plot for grants by City
ggplot(city_summary, aes(x = reorder(City, Total_Grants), y = Total_Grants)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Total Number of Grants by City (Top 10)", x = "City", y = "Total Number of Grants") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Visualization#4:
# Let's check correlation between 'Award.Amount' and 'Number.Employees' 
correlation <- cor(company_award_data$Award.Amount, company_award_data$Number.Employees, use = "complete.obs")
correlation

# Linear regression model to predict 'Award.Amount' based on 'Number.Employees'
linear_model <- lm(Award.Amount ~ Number.Employees, data = company_award_data)
# Summary of the linear regression model
summary(linear_model)

lm_model <- lm(Award.Amount ~ Number.Employees + Solicitation.Year, data = company_award_data)
summary(lm_model)



# Select numeric variables for correlation analysis
numeric_data <- company_award_data[, sapply(company_award_data, is.numeric)]

# Compute correlation matrix
correlation_matrix <- cor(numeric_data, use = "complete.obs")

# Create a correlation heatmap
corrplot(correlation_matrix, method = "color", type = "upper", order = "hclust", tl.cex = 0.7)


#Visualization#5:
lm_model <- lm(Award.Amount ~ Agency + Program + Phase + Woman.Owned + Socially.and.Economically.Disadvantaged + Hubzone.Owned, data = company_award_data)
summary(lm_model)
library(broom)


# Extract coefficients and tidy them
coefficients <- tidy(lm_model)

# Filter coefficients by significance level (p-value)
significant_coeffs <- coefficients[coefficients$p.value < 0.05, ]

# Create a bar plot of significant coefficients
ggplot(significant_coeffs, aes(x = reorder(term, estimate), y = estimate)) +
  geom_bar(stat = "identity", fill = "skyblue", alpha = 0.7) +
  geom_errorbar(aes(ymin = estimate - std.error, ymax = estimate + std.error), 
                width = 0.3, position = position_dodge(0.05), color = "black") +
  coord_flip() +
  labs(x = "Variables", y = "Coefficient Estimate") +
  ggtitle("Significant Coefficient Estimates from Linear Regression") +
  theme_minimal()

#Part5: Questions
#Question1:
# Filtering data for socially disadvantaged and non-disadvantaged companies
disadvantaged <- company_award_data$Award.Amount[company_award_data$Socially.and.Economically.Disadvantaged == "Yes"]
non_disadvantaged <- company_award_data$Award.Amount[company_award_data$Socially.and.Economically.Disadvantaged == "No"]

# Performing two-sample t-test assuming equal variances
t_test_result <- t.test(disadvantaged, non_disadvantaged, var.equal = TRUE)

# View the test results
t_test_result

#visulaization
# Hypothetical mean values and confidence intervals
mean_disadvantaged <- 425614.2
mean_non_disadvantaged <- 344933.1
ci_lower <- 47052.64
ci_upper <- 114309.71

# Creating a bar plot
means <- c(mean_disadvantaged, mean_non_disadvantaged)
group <- c("Socially Disadvantaged", "Non-Socially Disadvantaged")
ci <- c(ci_lower, ci_upper)

# Creating a dataframe
plot_data <- data.frame(means, group, ci)

# Plotting
library(ggplot2)
ggplot(plot_data, aes(x = group, y = means, fill = group)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.5) +
  geom_errorbar(aes(ymin = means - ci, ymax = means + ci), width = 0.2, position = position_dodge(0.5)) +
  labs(title = "Mean Award Amounts for Socially and Non-Socially Disadvantaged Companies",
       x = "Company Type", y = "Mean Award Amount") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Question2:

# Extracting award amounts for NC and AL for Year 2023
award_2023_NC <- company_award_data$Award.Amount[company_award_data$State == "NC" & company_award_data$Award.Year == 2023]
award_2023_AL <- company_award_data$Award.Amount[company_award_data$State == "AL" & company_award_data$Award.Year == 2023]

# Performing one-tailed t-tests for NC and AL for Year 2022
result_NC_AL_2023 <- t.test(award_2023_NC, award_2023_AL, alternative = "greater")

# View the test results for Year 2023
print("T-test results for Year 2023 - NC > AL:")
print(result_NC_AL_2023)

#visualization
# Filter the dataset to include only NC and AL data for 2023
filtered_data <- subset(company_award_data, State %in% c("NC", "AL") & Award.Year == 2023)

# Load necessary libraries (if not loaded)
# install.packages("ggplot2")
library(ggplot2)

# Create a boxplot
if (nrow(filtered_data) > 0) {
  ggplot(filtered_data, aes(x = State, y = Award.Amount, fill = State)) +
    geom_boxplot() +
    labs(title = "Comparison of Mean Award Amounts in 2023",
         x = "State", y = "Award Amount") +
    theme_minimal() +
    scale_fill_manual(values = c("NC" = "blue", "AL" = "red"))  # Adjust colors if needed
} else {
  print("No data found for NC and AL in 2023.")
}


#Q3:
  
  #Subset data for HHS
  hhs_data <- subset(company_award_data, Agency == "Department of Health and Human Services")

# Count the number of unique solicitations released per year
solicitations_per_year <- table(hhs_data$Solicitation.Year)

# Hypothetical average number of solicitations per year by HHS
hypothetical_average <- 200  # You can replace this with a realistic expectation

# Perform one-sample t-test
t_test_result <- t.test(solicitations_per_year, mu = hypothetical_average)
t_test_result

# Subset data for HHS
hhs_data <- subset(company_award_data, Agency == "Department of Health and Human Services")

# Count the number of unique solicitations released per year for HHS
solicitations_per_year <- table(hhs_data$Solicitation.Year)

# Calculate mean and standard deviation
mean_solicitations <- mean(solicitations_per_year)
sd_solicitations <- sd(solicitations_per_year)
hypothetical_average <- 200  # Hypothetical average

# Perform one-sample t-test
t_test_result <- t.test(solicitations_per_year, mu = hypothetical_average)
t_test_result

# Create bar plot with error bars
barplot(mean_solicitations, ylim = c(0, max(solicitations_per_year) + 50), 
        main = "Mean Solicitations per Year for HHS with CI",
        xlab = "Department of Health and Human Services", ylab = "Number of Solicitations")
segments(1, mean_solicitations - sd_solicitations, 1, mean_solicitations + sd_solicitations)

# Add label for the mean line
text(1, mean_solicitations, round(mean_solicitations, 2), pos = 3, col = "blue")


# Factorize the data
factorized_data <- as.numeric(solicitations_per_year)

# Calculate the mean
mean_value <- mean(factorized_data)


#Part1: Correlation table
# Check the updated structure of the dataframe
str(company_award_data)


# Convert categorical variables to numeric
company_award_data$Hubzoned <- as.numeric(company_award_data$Hubzone.Owned == "Yes")
company_award_data$SocialDisadvantaged <- as.numeric(company_award_data$Socially.and.Economically.Disadvantaged == "Yes")
company_award_data$WomanOwned <- as.numeric(company_award_data$Woman.Owned == "Yes")

# Select required variables for correlation analysis
correlation_data <- company_award_data[, c("Award.Amount", "Number.Employees", "Hubzoned", "SocialDisadvantaged", "WomanOwned")]

# Calculate correlation matrix
correlation_matrix <- cor(correlation_data, use = "complete.obs")
print(correlation_matrix)

library(RColorBrewer)

# Generate a new color palette
my_colors <- colorRampPalette(rev(brewer.pal(9, "RdBu")))(100)

# Plotting correlation heatmap with adjusted margins and custom colors
corrplot(correlation_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 40,
         title = "Correlation Heatmap of Selected Variables",
         tl.pos = "lt", cl.pos = "r", col = my_colors,
         order = "original", addCoef.col = "black", number.cex = 0.7,
         mar = c(0,0,2,5),
         title.cex = 1.5)  # Adjust top margin

#Part2

# Check distribution of Award.Amount
hist(company_award_data$Award.Amount, breaks = 100, xlab = "Award Amount", main = "Distribution of Award Amount")
# Clean your data (if needed)
cleaned_data <- company_award_data[company_award_data$Award.Amount != 0 & !is.na(company_award_data$Award.Amount), ]

#Clean Data
# Fit a linear regression model without an intercept
model <- lm(Award.Amount ~ Award.Year - 1, data = cleaned_data)  # Set intercept to zero

# Obtain the slope coefficient
slope_coef <- coef(model)

# Define the desired intercept (e.g., $10,000)
desired_intercept <- 10000

# Plot a sample of data points
plot(cleaned_data$Award.Year, cleaned_data$Award.Amount, 
     xlab = "Award Year", ylab = "Award Amount", main = "Linear Regression Plot")

# Set the range of x-values for the regression line
x_values <- range(cleaned_data$Award.Year)  # Adjust this range as needed

# Calculate corresponding y-values for the regression line
y_values <- slope_coef * x_values + desired_intercept

# Plot the adjusted regression line within the specified range
lines(x_values, y_values, col = "red")


# Fit a linear regression model without an intercept
model <- lm(Award.Amount ~ Award.Year - 1, data = cleaned_data)  # Set intercept to zero

# Obtain the coefficient estimates, standard errors, t-values, and p-values
summary_data <- summary(model)

# Extract coefficient estimates, standard errors, t-values, and p-values
coefficients <- summary_data$coefficients[, 1]
std_errors <- summary_data$coefficients[, 2]
t_values <- summary_data$coefficients[, 3]
p_values <- summary_data$coefficients[, 4]

# Create a data frame for the regression table
regression_table <- data.frame(
  Coefficients = rownames(summary_data$coefficients),
  Estimate = coefficients,
  `Std. Error` = std_errors,
  `t-value` = t_values,
  `Pr(>|t|)` = p_values
)

# Display the regression table
print(regression_table)


# Load necessary packages

# Install necessary packages if not already installed
install.packages("sjPlot")
install.packages("sjmisc")
install.packages("sjlabelled")
library(sjPlot)
library(sjmisc)
library(sjlabelled)

# Assuming cleaned_data is your dataset
# Fit the linear model (m1) using your cleaned_data
m1 <- lm(Award.Amount ~ Award.Year, data = cleaned_data)

# Generate regression table for m1
tab_model(m1)


#Predictive model
# Create a sequence of future years up to 2030
future_years <- seq(max(cleaned_data$Award.Year), 2030, by = 1)

# Predict corresponding y-values using the linear regression model for future years
predicted_values_future <- predict(model, newdata = data.frame(Award.Year = future_years))

# Create a sequence of x-values for the existing data
x_values <- seq(min(cleaned_data$Award.Year), max(cleaned_data$Award.Year), length.out = 100)

# Predict corresponding y-values using the linear regression model for existing data
predicted_values <- predict(model, newdata = data.frame(Award.Year = x_values))

# Plot the data and the predicted line
plot(cleaned_data$Award.Year, cleaned_data$Award.Amount, 
     xlab = "Award Year", ylab = "Award Amount", 
     main = "Predictive Model Plot with Predictions till 2030")

# Plot the predicted line for the existing data
lines(x_values, predicted_values, col = "red")

# Plot the predicted line for future years (up to 2030)
lines(future_years, predicted_values_future, col = "blue", lty = 2)

# Add a legend
legend("topright", legend = c("Existing Data", "Predictions till 2030"), 
       col = c("red", "blue"), lty = c(1, 2))

#Line Plot for Trends Over Years
# Aggregate data by Award Year
yearly_summary <- company_award_data %>%
  group_by(Award.Year) %>%
  summarise(Avg_Award_Amount = mean(Award.Amount, na.rm = TRUE),
            Total_Grants = n())
# Line plot with smoother trend line
ggplot(yearly_summary, aes(x = Award.Year, y = Avg_Award_Amount)) +
  geom_line() +
  geom_smooth(method = "loess", se = FALSE, color = "red") +  # Adding a smoother line
  geom_point() +
  labs(title = "Average Award Amount Over Years", x = "Award Year", y = "Average Award Amount") +
  theme_minimal()


# Fit a quadratic regression model
model_quadratic <- lm(Award.Amount ~ poly(Award.Year, 2, raw = TRUE), data = cleaned_data)

# Generate a sequence of values for prediction
x_seq <- seq(min(cleaned_data$Award.Year), max(cleaned_data$Award.Year), length.out = 100)

# Predict values using the quadratic regression model for the observed data
predicted_values <- predict(model_quadratic, newdata = data.frame(Award.Year = x_seq))

# Create a sequence of future years up to 2030
future_years <- seq(max(cleaned_data$Award.Year), 2030, by = 1)

# Predict values using the quadratic regression model for future years
predicted_values_future <- predict(model_quadratic, newdata = data.frame(Award.Year = future_years))

# Plot the sample data
plot(cleaned_data$Award.Year, cleaned_data$Award.Amount, 
     xlab = "Award Year", ylab = "Award Amount", main = "Predictive Model - Quadratic Regression")

# Plot the quadratic curve on top of the sample data plot
lines(x_seq, predicted_values, col = "red")

# Plot the predicted values for future years (up to 2030)
lines(future_years, predicted_values_future, col = "blue", lty = 2)

# Add a legend
legend("topright", legend = c("Existing Data", "Predictions till 2030"), 
       col = c("red", "blue"), lty = c(1, 2))




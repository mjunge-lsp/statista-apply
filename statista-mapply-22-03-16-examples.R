############################################
# mapply examples                          #
#                                          #
# Martin Junge                             #
############################################

# Example 1 - Modeling according to an excel sheet

library(ggplot2)
library(gapminder)
library(rpart)
library(futile.logger)

data("gapminder")

model_plan <- readxl::read_excel("model_plan.xlsx")

model_gapminder <- function(id = NULL,
                            model = "linear",
                            y_var = NULL,
                            x_vars = NULL,
                            filter = NULL)
{
  flog.info("fitting model id %s", id)
  
  if(!is.na(filter))
  {
    model_data <- subset(gapminder, eval(parse(text = filter)))
  }
  
  model_formula <- formula(paste0(y_var, " ~ ", x_vars))

  if(model == "linear")
  {
    res <- lm(formula = model_formula, data = model_data)
  }
  
  if(model == "tree")
  {
    res <- rpart(formula = model_formula, data = model_data)
  }
  
  pred <- predict(res)
  R2 <- cor(model_data[[y_var]], pred)
  
  results <- list(model = res, R2 = R2)
  
  return(results)
}

model_list <- mapply(model_gapminder, id = model_plan$id, model = model_plan$model, y_var = model_plan$y_var, 
       x_vars = model_plan$x_vars, filter = model_plan$filter)

# Example 2 - simulating rankings

pool <- data.frame(id = 1:100,
                   score_1 = rnorm(100, 50, 20),
                   score_2 = rnorm(100, 50, 20),
                   score_3 = rnorm(100, 50, 20),
                   last_year = c(rep(1, 10), rep(0, 90)))


compute_repl <- function(wt_1 = 1, wt_2 = 1, wt_3 = 1, wt_ly = 0, top_n = 10)
{
  pool$total_score <- pool$score_1 * wt_1 + pool$score_2 * wt_2 + pool$score_3 * wt_3 + pool$last_year * wt_ly
  ranking <- pool[order(pool$total_score, decreasing = TRUE), ]
  top <- head(ranking, top_n)
  repl <- sum(top$last_year)/10
  return(repl)
}

design <- expand.grid(wt_1 = seq(.25, 1, .25),
                      wt_2 = seq(.25, 1, .25),
                      wt_3 = seq(.25, 1, .25),
                      wt_ly = seq(10, 25, 5),
                      top_n = seq(10, 25, 5))

design$repl <- mapply(compute_repl, wt_1 = design$wt_1, wt_2 = design$wt_2, wt_3 = design$wt_3, 
       wt_ly = design$wt_ly, top_n = design$top_n)

plot(design$repl)

interaction.plot(design$wt_ly, design$top_n, design$repl)





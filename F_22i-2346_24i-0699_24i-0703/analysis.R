options(warn = -1)

if (!requireNamespace("tcltk", quietly = TRUE)) stop("tcltk package is required")
if (!requireNamespace("randomForest", quietly = TRUE)) {
  install.packages("randomForest", repos = "https://cran.r-project.org")
}
library(tcltk)
library(randomForest)

df         <- NULL
lr         <- NULL
rf_model   <- NULL
train_df   <- NULL
test_df    <- NULL
lr_pred_test  <- NULL
lr_pred_full  <- NULL
rf_pred_test  <- NULL
rf_pred_full  <- NULL
lr_mse_test   <- NULL
lr_rmse_test  <- NULL
lr_mae_test   <- NULL
lr_mse_full   <- NULL
rf_mse_test   <- NULL
rf_rmse_test  <- NULL
rf_mae_test   <- NULL
rf_mse_full   <- NULL

team_text <- "wasif mehmood mughal 24i-0699   |   hammad rasheed 24i-0703   |   abdullah sajid 22i-2346"

show_msg <- function(msg, title = "notice") {
  tkmessageBox(title = title, message = msg, icon = "info", type = "ok")
}

show_err <- function(msg) {
  tkmessageBox(title = "error", message = msg, icon = "error", type = "ok")
  cat("[error]", msg, "\n")
}

check_df <- function() {
  if (is.null(df)) {
    show_err("data not loaded. please click 'load and preprocess data' first.")
    return(FALSE)
  }
  return(TRUE)
}

check_mlr <- function() {
  if (is.null(lr)) {
    show_err("mlr model not trained. please run 'multiple linear regression model' first.")
    return(FALSE)
  }
  return(TRUE)
}

check_rf <- function() {
  if (is.null(rf_model)) {
    show_err("random forest model not trained. please run 'random forest model' first.")
    return(FALSE)
  }
  return(TRUE)
}

check_both_models <- function() {
  if (is.null(lr) || is.null(rf_model)) {
    show_err("both models required. please run mlr and random forest models first.")
    return(FALSE)
  }
  return(TRUE)
}

add_identity_bar <- function(parent_win) {
  id_frame <- tkframe(parent_win, bg = "#1a252f", relief = "flat")
  tkpack(id_frame, side = "bottom", fill = "x")
  id_label <- tklabel(id_frame,
    text    = team_text,
    font    = "Courier 8 bold",
    fg      = "#BDC3C7",
    bg      = "#1a252f",
    padx    = 10,
    pady    = 5
  )
  tkpack(id_label, side = "left")
}

win <- tktoplevel()
tkwm.title(win, "pakistan unemployment analysis")
tkwm.geometry(win, "640x580")
tkconfigure(win, bg = "#1E2D3D")

hdr_frame <- tkframe(win, bg = "#16213E", relief = "flat", borderwidth = 0)
tkpack(hdr_frame, fill = "x", padx = 0, pady = 0)

title_lbl <- tklabel(hdr_frame,
  text   = "pakistan unemployment analysis",
  font   = "Helvetica 17 bold",
  fg     = "#ECF0F1",
  bg     = "#16213E",
  pady   = 12
)
tkpack(title_lbl)

sub_lbl <- tklabel(hdr_frame,
  text   = "statistical analysis and machine learning dashboard",
  font   = "Helvetica 10",
  fg     = "#95A5A6",
  bg     = "#16213E",
  pady   = 2
)
tkpack(sub_lbl)

sep_lbl <- tklabel(hdr_frame,
  text   = team_text,
  font   = "Courier 8",
  fg     = "#F39C12",
  bg     = "#16213E",
  pady   = 6
)
tkpack(sep_lbl)

status_var <- tclVar("ready")
status_bar <- tkframe(win, bg = "#0D1B2A", relief = "flat")
tkpack(status_bar, fill = "x", padx = 0, pady = 0)
status_lbl <- tklabel(status_bar,
  textvariable = status_var,
  font         = "Helvetica 9",
  fg           = "#2ECC71",
  bg           = "#0D1B2A",
  anchor       = "w",
  padx         = 12,
  pady         = 4
)
tkpack(status_lbl, fill = "x")

set_status <- function(msg, color = "#2ECC71") {
  tclvalue(status_var) <- msg
  tkconfigure(status_lbl, fg = color)
}

btn_frame <- tkframe(win, bg = "#1E2D3D", relief = "flat")
tkpack(btn_frame, fill = "both", expand = TRUE, padx = 30, pady = 14)

make_btn <- function(parent, label, color, cmd) {
  b <- tkbutton(parent,
    text             = label,
    width            = 44,
    bg               = color,
    fg               = "white",
    font             = "Helvetica 10 bold",
    activebackground = color,
    activeforeground = "#ECF0F1",
    relief           = "flat",
    borderwidth      = 0,
    cursor           = "hand2",
    command          = cmd,
    pady             = 6
  )
  tkpack(b, pady = 5)
  return(b)
}

make_btn(btn_frame, "  load and preprocess data  ", "#2980B9", function() {
  tryCatch({
    set_status("loading data...", "#F39C12")
    files_needed <- c("unemployment.csv", "labor_force_participation.csv",
                      "urbanization.csv", "internet_penetration.csv",
                      "energy_consumption.csv", "fdi_inflows.csv")
    missing <- files_needed[!file.exists(files_needed)]
    if (length(missing) > 0) {
      show_err(paste("missing csv files:", paste(missing, collapse = ", ")))
      set_status("load failed - missing files", "#E74C3C")
      return()
    }
    d1 <- read.csv("unemployment.csv")
    d2 <- read.csv("labor_force_participation.csv")
    d3 <- read.csv("urbanization.csv")
    d4 <- read.csv("internet_penetration.csv")
    d5 <- read.csv("energy_consumption.csv")
    d6 <- read.csv("fdi_inflows.csv")
    m1 <- merge(d1, d2, by = c("country", "year"))
    m2 <- merge(m1, d3, by = c("country", "year"))
    m3 <- merge(m2, d4, by = c("country", "year"))
    m4 <- merge(m3, d5, by = c("country", "year"))
    df <<- merge(m4, d6, by = c("country", "year"))
    df <<- df[order(df$country, df$year), ]
    for (i in 3:ncol(df)) {
      for (j in 2:nrow(df)) {
        if (is.na(df[j, i]) && df[j, "country"] == df[j - 1, "country"]) {
          df[j, i] <<- df[j - 1, i]
        }
      }
    }
    for (i in 3:ncol(df)) {
      for (j in (nrow(df) - 1):1) {
        if (is.na(df[j, i]) && df[j, "country"] == df[j + 1, "country"]) {
          df[j, i] <<- df[j + 1, i]
        }
      }
    }
    df <<- na.omit(df)
    df$country <<- NULL
    write.csv(df, "final_dataset.csv", row.names = FALSE)
    cat("\ndataset loaded. observations:", nrow(df), "\n")
    cat("variables:", ncol(df), "\n")
    cat("year range:", min(df$year), "to", max(df$year), "\n")
    cat("country: pakistan (pk)\n")
    cat("note: missing values handled via forward/backward fill\n")
    set_status(paste0("data loaded successfully — ", nrow(df), " observations, years ", min(df$year), "-", max(df$year)), "#2ECC71")
    show_msg(paste0("data loaded successfully.\nobservations: ", nrow(df), "\nyears: ", min(df$year), " to ", max(df$year)))
  }, error = function(e) {
    show_err(paste("load error:", conditionMessage(e)))
    set_status("load failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  summary statistics  ", "#27AE60", function() {
  if (!check_df()) return()
  tryCatch({
    set_status("computing summary statistics...", "#F39C12")
    get_mode <- function(x) {
      ux <- unique(x)
      ux[which.max(tabulate(match(x, ux)))]
    }
    vars <- c("unemployment", "labor_force_participation", "urbanization",
              "internet_penetration", "energy_consumption", "fdi_inflows")
    missing_vars <- vars[!vars %in% names(df)]
    if (length(missing_vars) > 0) {
      show_err(paste("missing columns in data:", paste(missing_vars, collapse = ", ")))
      set_status("summary failed - missing columns", "#E74C3C")
      return()
    }
    cat("\ntask-02: summary statistics\n\n")
    cat("r summary output\n")
    print(summary(df[, vars]))
    stats_table <- data.frame(
      variable = vars,
      mean     = sapply(df[, vars], mean,    na.rm = TRUE),
      median   = sapply(df[, vars], median,  na.rm = TRUE),
      mode     = sapply(df[, vars], get_mode),
      q1       = sapply(df[, vars], quantile, probs = 0.25, na.rm = TRUE),
      q3       = sapply(df[, vars], quantile, probs = 0.75, na.rm = TRUE),
      sd       = sapply(df[, vars], sd,       na.rm = TRUE),
      min      = sapply(df[, vars], min,      na.rm = TRUE),
      max      = sapply(df[, vars], max,      na.rm = TRUE)
    )
    rownames(stats_table) <- NULL
    cat("\nextended statistics table (including mode)\n")
    print(stats_table, digits = 4)
    set_status("summary statistics computed successfully", "#2ECC71")
  }, error = function(e) {
    show_err(paste("summary error:", conditionMessage(e)))
    set_status("summary failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  boxplot  ", "#C0392B", function() {
  if (!check_df()) return()
  tryCatch({
    set_status("generating boxplot...", "#F39C12")
    vars <- c("unemployment", "labor_force_participation", "urbanization",
              "internet_penetration", "energy_consumption", "fdi_inflows")
    cat("\ntask-03: box and whisker plots\n")
    df_scaled <- as.data.frame(scale(df[, vars]))
    dev.new(width = 10, height = 7)
    par(bg = "white")
    boxplot(df_scaled,
      col      = c("#E74C3C","#3498DB","#2ECC71","#F39C12","#9B59B6","#1ABC9C"),
      names    = c("unemp.","lfp","urban.","internet","energy","fdi"),
      main     = "box and whisker plot - all variables (standardized)\npakistan 1960-2024",
      ylab     = "standardized values (z-score)",
      xlab     = "variables",
      cex.main = 1.2,
      cex.lab  = 1.0,
      las      = 1,
      frame    = FALSE
    )
    abline(h = 0, lty = 2, col = "grey50")
    for (k in 1:length(vars)) {
      col_data <- df_scaled[, vars[k]]
      bp_stats <- boxplot.stats(col_data)
      outlier_vals <- bp_stats$out
      if (length(outlier_vals) > 0) {
        cat(sprintf("  outliers in %-30s: %d point(s) detected\n", vars[k], length(outlier_vals)))
      } else {
        cat(sprintf("  outliers in %-30s: none\n", vars[k]))
      }
    }
    legend("topright",
      legend = c("unemployment","labor force part.","urbanization","internet penetration","energy consumption","fdi inflows"),
      fill   = c("#E74C3C","#3498DB","#2ECC71","#F39C12","#9B59B6","#1ABC9C"),
      cex    = 0.8,
      bty    = "n"
    )
    mtext(team_text, side = 1, line = 4, cex = 0.65, col = "gray50")
    png("boxplot.png", width = 1000, height = 700)
    par(bg = "white")
    boxplot(df_scaled,
      col      = c("#E74C3C","#3498DB","#2ECC71","#F39C12","#9B59B6","#1ABC9C"),
      names    = c("unemp.","lfp","urban.","internet","energy","fdi"),
      main     = "box and whisker plot - all variables (standardized)\npakistan 1960-2024",
      ylab     = "standardized values (z-score)",
      xlab     = "variables",
      cex.main = 1.2,
      cex.lab  = 1.0,
      las      = 1,
      frame    = FALSE
    )
    abline(h = 0, lty = 2, col = "grey50")
    legend("topright",
      legend = c("unemployment","labor force part.","urbanization","internet penetration","energy consumption","fdi inflows"),
      fill   = c("#E74C3C","#3498DB","#2ECC71","#F39C12","#9B59B6","#1ABC9C"),
      cex    = 0.8,
      bty    = "n"
    )
    mtext(team_text, side = 1, line = 4, cex = 0.65, col = "gray50")
    dev.off()
    cat("  saved: boxplot.png\n")
    set_status("boxplot generated and saved to boxplot.png", "#2ECC71")
  }, error = function(e) {
    show_err(paste("boxplot error:", conditionMessage(e)))
    set_status("boxplot failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  scatterplots  ", "#7D3C98", function() {
  if (!check_df()) return()
  tryCatch({
    set_status("generating scatterplots...", "#F39C12")
    cat("\ntask-04: scatter plots\n")
    scatter_vars <- list(
      list(x = "labor_force_participation", xlab = "labor force participation (%)"),
      list(x = "urbanization",              xlab = "urbanization (%)"),
      list(x = "internet_penetration",      xlab = "internet penetration (%)"),
      list(x = "energy_consumption",        xlab = "energy consumption (kg oil eq. per capita)"),
      list(x = "fdi_inflows",               xlab = "fdi inflows (% of gdp)")
    )
    colors <- c("#E74C3C","#3498DB","#2ECC71","#F39C12","#9B59B6")
    dev.new(width = 12, height = 9)
    par(mfrow = c(2, 3), mar = c(4, 4, 3, 1), oma = c(3, 0, 3, 0), bg = "white")
    for (k in 1:5) {
      xvar <- scatter_vars[[k]]$x
      xlab <- scatter_vars[[k]]$xlab
      plot(df[[xvar]], df$unemployment,
        col      = adjustcolor(colors[k], alpha.f = 0.6),
        pch      = 19,
        cex      = 0.8,
        xlab     = xlab,
        ylab     = "unemployment (%)",
        main     = paste("unemployment vs\n", xlab),
        cex.main = 0.95,
        frame    = FALSE
      )
      abline(lm(df$unemployment ~ df[[xvar]]), col = "black", lwd = 2, lty = 2)
      r_val <- cor(df[[xvar]], df$unemployment, use = "complete.obs")
      legend("topright", legend = paste0("r = ", round(r_val, 3)), bty = "n", cex = 0.85, text.col = "black")
    }
    plot.new()
    mtext("scatter plots: unemployment (dv) vs all independent variables\npakistan 1960-2024 | dashed line = ols trend | r = pearson correlation",
      side = 3, line = 0, outer = TRUE, cex = 1.0, font = 2)
    mtext(team_text, side = 1, line = 1, outer = TRUE, cex = 0.65, col = "gray50")
    png("scatterplots.png", width = 1200, height = 900)
    par(mfrow = c(2, 3), mar = c(4, 4, 3, 1), oma = c(3, 0, 3, 0), bg = "white")
    for (k in 1:5) {
      xvar <- scatter_vars[[k]]$x
      xlab <- scatter_vars[[k]]$xlab
      plot(df[[xvar]], df$unemployment,
        col      = adjustcolor(colors[k], alpha.f = 0.6),
        pch      = 19,
        cex      = 0.8,
        xlab     = xlab,
        ylab     = "unemployment (%)",
        main     = paste("unemployment vs\n", xlab),
        cex.main = 0.95,
        frame    = FALSE
      )
      abline(lm(df$unemployment ~ df[[xvar]]), col = "black", lwd = 2, lty = 2)
      r_val <- cor(df[[xvar]], df$unemployment, use = "complete.obs")
      legend("topright", legend = paste0("r = ", round(r_val, 3)), bty = "n", cex = 0.85, text.col = "black")
    }
    plot.new()
    mtext("scatter plots: unemployment (dv) vs all independent variables\npakistan 1960-2024 | dashed line = ols trend | r = pearson correlation",
      side = 3, line = 0, outer = TRUE, cex = 1.0, font = 2)
    mtext(team_text, side = 1, line = 1, outer = TRUE, cex = 0.65, col = "gray50")
    dev.off()
    cat("  saved: scatterplots.png\n")
    set_status("scatterplots generated and saved to scatterplots.png", "#2ECC71")
  }, error = function(e) {
    show_err(paste("scatterplot error:", conditionMessage(e)))
    set_status("scatterplots failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  multiple linear regression model  ", "#D68910", function() {
  if (!check_df()) return()
  tryCatch({
    set_status("training mlr model...", "#F39C12")
    cat("\ntask-05: model 1 - multiple linear regression\n\n")
    set.seed(42)
    n         <- nrow(df)
    train_idx <- sample(1:n, size = floor(0.8 * n))
    train_df  <<- df[train_idx, ]
    test_df   <<- df[-train_idx, ]
    lr <<- lm(unemployment ~ labor_force_participation + urbanization +
                internet_penetration + energy_consumption + fdi_inflows,
              data = train_df)
    cat("regression equation\n")
    cat("unemployment = b0 + b1(lfp) + b2(urbanization) + b3(internet)\n")
    cat("             + b4(energy) + b5(fdi) + e\n\n")
    cat("model summary\n")
    print(summary(lr))
    lr_pred_test  <<- predict(lr, test_df)
    lr_mse_test   <<- mean((test_df$unemployment - lr_pred_test)^2)
    lr_rmse_test  <<- sqrt(lr_mse_test)
    lr_mae_test   <<- mean(abs(test_df$unemployment - lr_pred_test))
    lr_pred_full  <<- predict(lr, df)
    lr_mse_full   <<- mean((df$unemployment - lr_pred_full)^2)
    cat("\nmlr performance metrics (test set)\n")
    cat(sprintf("  mse  : %.4f\n", lr_mse_test))
    cat(sprintf("  rmse : %.4f\n", lr_rmse_test))
    cat(sprintf("  mae  : %.4f\n", lr_mae_test))
    cat(sprintf("  mse (full data): %.4f\n", lr_mse_full))
    set_status(paste0("mlr trained successfully — mse: ", round(lr_mse_test, 4), " | rmse: ", round(lr_rmse_test, 4)), "#2ECC71")
    show_msg(paste0("mlr model trained.\nmse (test): ", round(lr_mse_test, 4), "\nrmse (test): ", round(lr_rmse_test, 4), "\nmae (test): ", round(lr_mae_test, 4)))
  }, error = function(e) {
    lr <<- NULL
    show_err(paste("mlr error:", conditionMessage(e)))
    set_status("mlr training failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  random forest model  ", "#148F77", function() {
  if (!check_df()) return()
  if (is.null(train_df) || is.null(test_df)) {
    show_err("training data not available. please run 'multiple linear regression model' first to create train/test split.")
    return()
  }
  tryCatch({
    set_status("training random forest (this may take a moment)...", "#F39C12")
    cat("\ntask-05: model 2 - machine learning (random forest)\n\n")
    set.seed(42)
    rf_model <<- randomForest(
      unemployment ~ labor_force_participation + urbanization +
        internet_penetration + energy_consumption + fdi_inflows,
      data       = train_df,
      ntree      = 500,
      mtry       = 2,
      importance = TRUE
    )
    cat("random forest summary\n")
    print(rf_model)
    cat("\nvariable importance\n")
    print(importance(rf_model))
    rf_pred_test <<- predict(rf_model, test_df)
    rf_pred_full <<- predict(rf_model, df)
    rf_mse_test  <<- mean((test_df$unemployment - rf_pred_test)^2)
    rf_rmse_test <<- sqrt(rf_mse_test)
    rf_mae_test  <<- mean(abs(test_df$unemployment - rf_pred_test))
    rf_mse_full  <<- mean((df$unemployment - rf_pred_full)^2)
    cat("\nrandom forest performance metrics (test set)\n")
    cat(sprintf("  mse  : %.4f\n", rf_mse_test))
    cat(sprintf("  rmse : %.4f\n", rf_rmse_test))
    cat(sprintf("  mae  : %.4f\n", rf_mae_test))
    cat(sprintf("  mse (full data): %.4f\n", rf_mse_full))
    set_status(paste0("random forest trained — mse: ", round(rf_mse_test, 4), " | rmse: ", round(rf_rmse_test, 4)), "#2ECC71")
    show_msg(paste0("random forest trained.\nmse (test): ", round(rf_mse_test, 4), "\nrmse (test): ", round(rf_rmse_test, 4), "\nmae (test): ", round(rf_mae_test, 4)))
  }, error = function(e) {
    rf_model <<- NULL
    show_err(paste("random forest error:", conditionMessage(e)))
    set_status("random forest training failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  model comparison graphs  ", "#BA4A00", function() {
  if (!check_both_models()) return()
  if (is.null(lr_pred_full) || is.null(rf_pred_full)) {
    show_err("predictions not available. please ensure both models have been trained.")
    return()
  }
  tryCatch({
    set_status("generating model comparison graphs...", "#F39C12")
    cat("\ntask-05: model comparison graphs\n")
    dev.new(width = 14, height = 10)
    par(mfrow = c(2, 3), mar = c(4, 4, 3, 2), oma = c(3, 0, 4, 0), bg = "white")
    plot(df$year, df$unemployment,
      type = "l", col = "#3498DB", lwd = 2,
      xlab = "year", ylab = "unemployment (%)",
      main = "mlr: actual vs predicted\n(full data - time series)",
      frame = FALSE)
    lines(df$year, lr_pred_full, col = "#E74C3C", lwd = 2, lty = 2)
    legend("topright", legend = c("actual","mlr predicted"),
      col = c("#3498DB","#E74C3C"), lwd = 2, lty = c(1,2), bty = "n", cex = 0.85)
    plot(df$year, df$unemployment,
      type = "l", col = "#3498DB", lwd = 2,
      xlab = "year", ylab = "unemployment (%)",
      main = "random forest: actual vs predicted\n(full data - time series)",
      frame = FALSE)
    lines(df$year, rf_pred_full, col = "#2ECC71", lwd = 2, lty = 2)
    legend("topright", legend = c("actual","rf predicted"),
      col = c("#3498DB","#2ECC71"), lwd = 2, lty = c(1,2), bty = "n", cex = 0.85)
    plot(df$year, df$unemployment,
      type = "l", col = "#3498DB", lwd = 2,
      xlab = "year", ylab = "unemployment (%)",
      main = "all models: actual vs predicted\n(full data comparison)",
      frame = FALSE)
    lines(df$year, lr_pred_full, col = "#E74C3C", lwd = 2, lty = 2)
    lines(df$year, rf_pred_full, col = "#2ECC71", lwd = 2, lty = 3)
    legend("topright", legend = c("actual","mlr","random forest"),
      col = c("#3498DB","#E74C3C","#2ECC71"), lwd = 2, lty = c(1,2,3), bty = "n", cex = 0.82)
    lim <- range(c(test_df$unemployment, lr_pred_test, rf_pred_test))
    plot(test_df$unemployment, lr_pred_test,
      col  = adjustcolor("#E74C3C", alpha.f = 0.7),
      pch  = 19, cex = 1.1,
      xlim = lim, ylim = lim,
      xlab = "actual unemployment (%)",
      ylab = "predicted unemployment (%)",
      main = paste0("mlr: actual vs predicted\n(test set | mse = ", round(lr_mse_test, 3), ")"),
      frame = FALSE)
    abline(0, 1, col = "black", lwd = 2, lty = 2)
    legend("topleft", legend = "perfect fit line", lty = 2, lwd = 2, bty = "n", cex = 0.85)
    plot(test_df$unemployment, rf_pred_test,
      col  = adjustcolor("#2ECC71", alpha.f = 0.7),
      pch  = 19, cex = 1.1,
      xlim = lim, ylim = lim,
      xlab = "actual unemployment (%)",
      ylab = "predicted unemployment (%)",
      main = paste0("random forest: actual vs predicted\n(test set | mse = ", round(rf_mse_test, 3), ")"),
      frame = FALSE)
    abline(0, 1, col = "black", lwd = 2, lty = 2)
    legend("topleft", legend = "perfect fit line", lty = 2, lwd = 2, bty = "n", cex = 0.85)
    mse_vals <- c(lr_mse_test, rf_mse_test)
    bp <- barplot(mse_vals,
      names.arg = c("mlr","random forest"),
      col       = c("#E74C3C","#2ECC71"),
      main      = "model comparison\nmse (test set)",
      ylab      = "mean squared error",
      ylim      = c(0, max(mse_vals) * 1.3),
      frame     = FALSE)
    text(bp, mse_vals + max(mse_vals) * 0.05,
      labels = round(mse_vals, 4), cex = 0.95, font = 2)
    mtext("model comparison: actual vs predicted values | pakistan unemployment",
      side = 3, line = 1, outer = TRUE, cex = 1.1, font = 2)
    mtext(team_text, side = 1, line = 1, outer = TRUE, cex = 0.65, col = "gray50")
    png("model_comparison.png", width = 1400, height = 1000)
    par(mfrow = c(2, 3), mar = c(4, 4, 3, 2), oma = c(3, 0, 4, 0), bg = "white")
    plot(df$year, df$unemployment, type = "l", col = "#3498DB", lwd = 2,
      xlab = "year", ylab = "unemployment (%)",
      main = "mlr: actual vs predicted\n(full data - time series)", frame = FALSE)
    lines(df$year, lr_pred_full, col = "#E74C3C", lwd = 2, lty = 2)
    legend("topright", legend = c("actual","mlr predicted"),
      col = c("#3498DB","#E74C3C"), lwd = 2, lty = c(1,2), bty = "n", cex = 0.85)
    plot(df$year, df$unemployment, type = "l", col = "#3498DB", lwd = 2,
      xlab = "year", ylab = "unemployment (%)",
      main = "random forest: actual vs predicted\n(full data - time series)", frame = FALSE)
    lines(df$year, rf_pred_full, col = "#2ECC71", lwd = 2, lty = 2)
    legend("topright", legend = c("actual","rf predicted"),
      col = c("#3498DB","#2ECC71"), lwd = 2, lty = c(1,2), bty = "n", cex = 0.85)
    plot(df$year, df$unemployment, type = "l", col = "#3498DB", lwd = 2,
      xlab = "year", ylab = "unemployment (%)",
      main = "all models: actual vs predicted\n(full data comparison)", frame = FALSE)
    lines(df$year, lr_pred_full, col = "#E74C3C", lwd = 2, lty = 2)
    lines(df$year, rf_pred_full, col = "#2ECC71", lwd = 2, lty = 3)
    legend("topright", legend = c("actual","mlr","random forest"),
      col = c("#3498DB","#E74C3C","#2ECC71"), lwd = 2, lty = c(1,2,3), bty = "n", cex = 0.82)
    plot(test_df$unemployment, lr_pred_test,
      col = adjustcolor("#E74C3C", alpha.f = 0.7), pch = 19, cex = 1.1,
      xlim = lim, ylim = lim,
      xlab = "actual unemployment (%)", ylab = "predicted unemployment (%)",
      main = paste0("mlr: actual vs predicted\n(test set | mse = ", round(lr_mse_test, 3), ")"),
      frame = FALSE)
    abline(0, 1, col = "black", lwd = 2, lty = 2)
    legend("topleft", legend = "perfect fit line", lty = 2, lwd = 2, bty = "n", cex = 0.85)
    plot(test_df$unemployment, rf_pred_test,
      col = adjustcolor("#2ECC71", alpha.f = 0.7), pch = 19, cex = 1.1,
      xlim = lim, ylim = lim,
      xlab = "actual unemployment (%)", ylab = "predicted unemployment (%)",
      main = paste0("random forest: actual vs predicted\n(test set | mse = ", round(rf_mse_test, 3), ")"),
      frame = FALSE)
    abline(0, 1, col = "black", lwd = 2, lty = 2)
    legend("topleft", legend = "perfect fit line", lty = 2, lwd = 2, bty = "n", cex = 0.85)
    mse_vals2 <- c(lr_mse_test, rf_mse_test)
    bp2 <- barplot(mse_vals2,
      names.arg = c("mlr","random forest"),
      col       = c("#E74C3C","#2ECC71"),
      main      = "model comparison\nmse (test set)",
      ylab      = "mean squared error",
      ylim      = c(0, max(mse_vals2) * 1.3),
      frame     = FALSE)
    text(bp2, mse_vals2 + max(mse_vals2) * 0.05,
      labels = round(mse_vals2, 4), cex = 0.95, font = 2)
    mtext("model comparison: actual vs predicted values | pakistan unemployment",
      side = 3, line = 1, outer = TRUE, cex = 1.1, font = 2)
    mtext(team_text, side = 1, line = 1, outer = TRUE, cex = 0.65, col = "gray50")
    dev.off()
    cat("  saved: model_comparison.png\n")
    set_status("model comparison graphs saved to model_comparison.png", "#2ECC71")
  }, error = function(e) {
    show_err(paste("comparison graph error:", conditionMessage(e)))
    set_status("comparison graphs failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  variable importance plot  ", "#6C3483", function() {
  if (!check_rf()) return()
  tryCatch({
    set_status("generating variable importance plot...", "#F39C12")
    dev.new(width = 8, height = 5)
    par(bg = "white", oma = c(2, 0, 0, 0))
    varImpPlot(rf_model,
      main = "random forest: variable importance\nfor predicting unemployment",
      col  = "steelblue",
      pch  = 19
    )
    mtext(team_text, side = 1, line = 1, outer = TRUE, cex = 0.65, col = "gray50")
    png("variable_importance.png", width = 800, height = 500)
    par(bg = "white", oma = c(2, 0, 0, 0))
    varImpPlot(rf_model,
      main = "random forest: variable importance\nfor predicting unemployment",
      col  = "steelblue",
      pch  = 19
    )
    mtext(team_text, side = 1, line = 1, outer = TRUE, cex = 0.65, col = "gray50")
    dev.off()
    cat("  saved: variable_importance.png\n")
    set_status("variable importance plot saved to variable_importance.png", "#2ECC71")
  }, error = function(e) {
    show_err(paste("variable importance error:", conditionMessage(e)))
    set_status("variable importance plot failed", "#E74C3C")
  })
})

make_btn(btn_frame, "  final summary output  ", "#1C2833", function() {
  if (!check_both_models()) return()
  if (is.null(lr_mse_test) || is.null(rf_mse_test)) {
    show_err("model metrics not available. please ensure both models are fully trained.")
    return()
  }
  tryCatch({
    set_status("generating final summary...", "#F39C12")
    cat("\nfinal model comparison summary\n")
    comparison <- data.frame(
      model = c("multiple linear regression","random forest"),
      mse   = round(c(lr_mse_test, rf_mse_test),  4),
      rmse  = round(c(lr_rmse_test, rf_rmse_test), 4),
      mae   = round(c(lr_mae_test, rf_mae_test),   4)
    )
    print(comparison)
    better <- ifelse(lr_mse_test < rf_mse_test, "multiple linear regression", "random forest")
    cat(sprintf("\nconclusion: %s performs better on the test set (lower mse).\n", better))
    cat("\nall outputs saved:\n")
    cat("  final_dataset.csv       - cleaned dataset\n")
    cat("  boxplot.png             - task-03\n")
    cat("  scatterplots.png        - task-04\n")
    cat("  model_comparison.png    - task-05 comparison graphs\n")
    cat("  variable_importance.png - task-05 rf importance\n")
    set_status(paste0("summary complete. best model: ", better), "#2ECC71")
    show_msg(paste0(
      "final summary\n\n",
      "mlr  — mse: ", round(lr_mse_test, 4), "  rmse: ", round(lr_rmse_test, 4), "  mae: ", round(lr_mae_test, 4), "\n",
      "rf   — mse: ", round(rf_mse_test, 4), "  rmse: ", round(rf_rmse_test, 4), "  mae: ", round(rf_mae_test, 4), "\n\n",
      "conclusion: ", better, " performs better (lower mse)."
    ))
  }, error = function(e) {
    show_err(paste("final summary error:", conditionMessage(e)))
    set_status("final summary failed", "#E74C3C")
  })
})

footer_frame <- tkframe(win, bg = "#0D1B2A", relief = "flat")
tkpack(footer_frame, fill = "x", padx = 0, pady = 0, side = "bottom")
footer_lbl <- tklabel(footer_frame,
  text  = team_text,
  font  = "Courier 8 bold",
  fg    = "#F39C12",
  bg    = "#0D1B2A",
  pady  = 7,
  padx  = 12
)
tkpack(footer_lbl, side = "left")

tkwait.window(win)

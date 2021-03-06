## Update methods for plots produced by plotxc and plotxs. Essentially doing the
## minimum amount of work possible to update the plots. Some parts are doing a
## wasteful redraw, when the original plot doesn't return enough info to easily
## erase and redraw parts of it.
##
## Not currently exported 2016-06-21.

update.xcplot <-
function (object, xclick, yclick, xc.cond = NULL, user = FALSE, draw = TRUE,
  ...)
{
  if (dev.cur() != object$device && draw)
    dev.set(object$device)
  if (!identical(object$plot.type, "full")){
    if (draw){
      screen(n = object$screen, new = FALSE)
      par(usr = object$usr)
      par(mar = object$mar)
      screen(n = object$screen, new = FALSE)
    }
    if (is.null(xc.cond)){
      if (user){
        xclickconv <- xclick
        yclickconv <- yclick
      } else {
        xclickconv <- grconvertX(xclick, "ndc", "user")
        yclickconv <- grconvertY(yclick, "ndc", "user")
      }
    }
  }
  if (identical(object$plot.type, "histogram")){
    if (is.null(xc.cond)){
      xc.cond.new <- max(min(xclickconv, max(object$xc, na.rm = TRUE)), min(
        object$xc, na.rm = TRUE), na.rm = TRUE)
    } else {
      xc.cond.new <- xc.cond
    }
    if (xc.cond.new != object$xc.cond.old){
      if (draw){
        abline(v = object$xc.cond.old, lwd = 2 * object$select.lwd, col =
          "white")
        break4redraw <- which.min(abs(object$histmp$breaks - object$xc.cond.old)
          )
        rect(xleft = object$histmp$breaks[break4redraw + c(-1, 0)], xright =
          object$histmp$breaks[break4redraw + c(0, 1)], ybottom = c(0, 0), ytop
          = object$histmp$counts[break4redraw + c(-1, 0)])
        abline(v = xc.cond.new, lwd = object$select.lwd, col = object$select.col
          )
      }
      object$xc.cond.old <- xc.cond.new
    }
  } else if (identical(object$plot.type, "barplot")){
    if (is.null(xc.cond)){
      xc.cond.new <- as.factor(object$factorcoords$level)[which.min(abs(
        xclickconv - object$factorcoords$x))]
    } else {
      xc.cond.new <- xc.cond
    }
    if (xc.cond.new != object$xc.cond.old){
      if (draw){
        barindex.old <- levels(object$xc) == object$xc.cond.old
        rect(xleft = object$bartmp$w.l[barindex.old], xright =
          object$bartmp$w.r[barindex.old], ybottom = 0, ytop =
          object$bartmp$height[barindex.old], col = "gray")
        barindex.new <- levels(object$xc) == xc.cond.new
        rect(xleft = object$bartmp$w.l[barindex.new], xright =
          object$bartmp$w.r[barindex.new], ybottom = 0, ytop =
          object$bartmp$height[barindex.new], col = object$select.colour,
          density = -1)
      }
      object$xc.cond.old <- xc.cond.new
    }
  } else if (identical(object$plot.type, "scatterplot")){
    if (is.null(xc.cond)){
      xc.cond.new.x <- max(min(xclickconv, max(object$xc[, 1], na.rm = TRUE)),
        min(object$xc[, 1], na.rm = TRUE), na.rm = TRUE)
      xc.cond.new.y <- max(min(yclickconv, max(object$xc[, 2], na.rm = TRUE)),
        min(object$xc[, 2], na.rm = TRUE), na.rm = TRUE)
      xc.cond.new <- c(xc.cond.new.x, xc.cond.new.y)
    } else {
      xc.cond.new.x <- xc.cond[, 1]
      xc.cond.new.y <- xc.cond[, 2]
      xc.cond.new <- xc.cond
    }
    if (any(xc.cond.new != object$xc.cond.old)){
      if (object$hist2d && nrow(object$xc) > 2000 && requireNamespace("gplots",
        quietly = TRUE) && draw){
        par(bg = "white")
        dev.hold()
        screen(new = TRUE)
        b <- seq(0.35, 1, length.out = 16)
        gplots::hist2d(object$xc[, 1], object$xc[, 2], nbins = 50, col =
          c("white", rgb(1 - b, 1 - b, 1 - b)), xlab = colnames(object$xc)[1],
          ylab = colnames(object$xc)[2], cex.axis = object$cex.axis, cex.lab =
          object$cex.lab, tcl = object$tck, FUN = function(x) min(length(x),
          object$fullbin))
        abline(v = xc.cond.new.x, h = xc.cond.new.y, lwd = object$select.lwd,
          col = object$select.colour)
        box()
        dev.flush()
        object$xc.cond.old <- xc.cond.new
      } else {
        if (draw){
          abline(v = object$xc.cond.old[1], h = object$xc.cond.old[2], lwd =
            2 * object$select.lwd, col = "white")
          xrange <- abs(diff(range(object$xc[, 1])))
          yrange <- abs(diff(range(object$xc[, 2])))
          redrawindex.x <- findInterval(object$xc[, 1], object$xc.cond.old[1]
            + xrange * c(-0.125, 0.125) ) == 1
          redrawindex.y <- findInterval(object$xc[, 2], object$xc.cond.old[2]
            + yrange * c(-0.125, 0.125) ) == 1
          points(object$xc[redrawindex.x | redrawindex.y, ], cex =
            object$select.cex)
          box()
          abline(v = xc.cond.new.x, h = xc.cond.new.y, lwd = object$select.lwd,
            col = object$select.colour)
        }
        object$xc.cond.old <- xc.cond.new
      }
    }
  } else if (identical(object$plot.type, "boxplot")){
    if (is.null(xc.cond)){
      xc.cond.new.x <- as.factor(object$factorcoords$level)[which.min(abs(
        xclickconv - object$factorcoords$x))]
      xc.cond.new.y <- if (abs(yclickconv - object$xc.cond.old[, 2]) >
        0.025 * abs(diff(range(object$xc[, 2])))){
        max(min(yclickconv, max(object$xc[, 2], na.rm = TRUE)),
        min(object$xc[, 2], na.rm = TRUE), na.rm = TRUE)
      } else object$xc.cond.old[, 2]
      xc.cond.new <- c(xc.cond.new.x, xc.cond.new.y)
    } else {
      xc.cond.new.x <- xc.cond[, 1]
      xc.cond.new.y <- xc.cond[, 2]
      xc.cond.new <- xc.cond
    }
    if (any(xc.cond.new != object$xc.cond.old)){
      if (draw){
        if (xc.cond.new.x != object$xc.cond.old[, 1]){
          abline(v = as.integer(object$xc.cond.old[, 1]), lwd = 2 *
            object$select.lwd, col = "white")
        }
        if (xc.cond.new.y != object$xc.cond.old[, 2]) {
          abline(h = object$xc.cond.old[, 2], lwd = 2 * object$select.lwd,
            col = "white")
        }
        par(new = TRUE)
        bxp(object$boxtmp, xaxt = "n", yaxt = "n")
        abline(v = as.integer(xc.cond.new.x), h = xc.cond.new.y, lwd =
          object$select.lwd, col = object$select.colour)
      }
      xc.cond.new <- data.frame(xc.cond.new.x, xc.cond.new.y)
      names(xc.cond.new) <- names(object$xc.cond.old)
      object$xc.cond.old <- xc.cond.new
    }
  } else if (identical(object$plot.type, "spineplot")){
    if (is.null(xc.cond)){
      sptmp <- object$sptmp
      rectcoords <- data.frame(sptmp$xleft, sptmp$xright, sptmp$ybottom,
        sptmp$ytop)
      if (c(xclickconv, yclickconv) %inrectangle% c(min(sptmp$xleft),
        max(sptmp$xright) , min(sptmp$ybottom), max(sptmp$ytop)) ){
        comb.index <- apply(rectcoords, 1L, `%inrectangle%`, point =
          c(xclickconv, yclickconv))
        if (any(comb.index)){
          xc.cond.new <- data.frame(as.factor(sptmp$xnames)[comb.index],
            as.factor(sptmp$ynames)[comb.index])
          names(xc.cond.new) <- names(object$xc.cond.old)
          if (any(xc.cond.new != object$xc.cond.old)){
            object$xc.cond.old <- xc.cond.new
            if (draw){
              par(bg = "white")
              screen(new = TRUE)
              object <- plotxc(xc = object$xc, xc.cond = xc.cond.new, name =
                object$name, select.colour = object$select.colour, select.lwd =
                object$select.lwd, cex.axis = object$cex.axis, cex.lab =
                object$cex.lab, tck = object$tck)
            }
          }
        }
      }
    } else {
      xc.cond.new <- xc.cond
      names(xc.cond.new) <- names(object$xc.cond.old)
      if (any(xc.cond.new != object$xc.cond.old)){
        object$xc.cond.old <- xc.cond.new
        if (draw){
          par(bg = "white")
          screen(new = TRUE)
          object <- plotxc(xc = object$xc, xc.cond = xc.cond.new, name =
            object$name, select.colour = object$select.colour, select.lwd =
            object$select.lwd, cex.axis = object$cex.axis, cex.lab =
            object$cex.lab, tck = object$tck)
        }
      }
    }
  } else if (identical(object$plot.type, "pcp")){
    xwhich <- which.min(abs(xclickconv - object$xcoord))
    redrawindex <- seq(max(xwhich - 1, 1), min(xwhich + 1, length(object$xcoord)
      ))
    ycoord.old <- object$ycoord
    if (xwhich %in% object$factorindex){
      tmp <- sort(unique(object$Xc.num.scaled[, xwhich]))
      yindex <- which.min(abs(yclickconv - tmp))
      object$ycoord[xwhich] <- tmp[yindex]
      object$Xc.cond[xwhich] <- factor(levels(object$Xc[, xwhich])[yindex],
        levels = levels(object$Xc[, xwhich]))
      if (!identical(ycoord.old[xwhich], object$ycoord[xwhich])){
        lines(object$xcoord[redrawindex], ycoord.old[redrawindex], col = "white"
          , lwd = 2 * object$select.lwd)
        points(xwhich, ycoord.old[xwhich], cex = 1.5 * object$cex, col = "white"
          , pch = 16)
        segments(x0 = rep(object$xcoord[head(redrawindex, -1)], each = nrow(
          object$Xc.num)), x1 = rep(object$xcoord[tail(redrawindex, -1)], each =
          nrow(object$Xc.num)), y0 = object$Xc.num.scaled[, head(redrawindex, -1
          )], y1 = object$Xc.num.scaled[, tail(redrawindex, -1)])
        segments(x0 = rep(redrawindex), y0 = rep(0, length(redrawindex)), y1 =
          rep(1, length(redrawindex)), col = "gray")
        points(redrawindex, object$ycoord[redrawindex], cex = object$cex, col =
          object$select.colour, pch = 16)
        lines(object$xcoord[redrawindex], object$ycoord[redrawindex], col =
          object$select.colour, lwd = object$select.lwd)
      }
    } else {
      propy <- max(0, min(yclickconv, 1))
      if (abs(ycoord.old[xwhich] - propy) > 0.03){
        object$ycoord[xwhich] <- propy
        object$Xc.cond[xwhich] <- object$ycoord[xwhich] * (object$xc.num.max[
          xwhich] - object$xc.num.min[xwhich]) + object$xc.num.min[xwhich]
        lines(object$xcoord[redrawindex], ycoord.old[redrawindex], col = "white"
          , lwd = 2 * object$select.lwd)
        points(xwhich, ycoord.old[xwhich], cex = 1.5 * object$cex, col = "white"
          , pch = 16)
        segments(x0 = rep(object$xcoord[head(redrawindex, -1)], each = nrow(
          object$Xc.num)), x1 = rep(object$xcoord[tail(redrawindex, -1)], each =
          nrow(object$Xc.num)), y0 = object$Xc.num.scaled[, head(redrawindex, -1
          )], y1 = object$Xc.num.scaled[, tail(redrawindex, -1)])
        segments(x0 = rep(redrawindex), y0 = rep(0, length(redrawindex)), y1 =
          rep(1, length(redrawindex)), col = "gray")
        points(redrawindex, object$ycoord[redrawindex], cex = object$cex, col =
          object$select.colour, pch = 16)
        lines(object$xcoord[redrawindex], object$ycoord[redrawindex], col =
          object$select.colour, lwd = object$select.lwd)
      }
    }
  } else if (identical(object$plot.type, "full")){
    o <- (xclick > object$coords$xleft) & (xclick < object$coords$xright) &
      (yclick > object$coords$ybottom) & (yclick < object$coords$ytop)
    index <- which(o)
    if (identical(object$cols[index], object$rows[index]))
      return(object)
    xname <- colnames(object$Xc)[object$cols[index]]
    yname <- colnames(object$Xc)[object$rows[index]]
    screenindex <- object$coords[index, "xcplots.index"]
    screen(screenindex)
    par(usr = object$usr.matrix[index, ])
    par(mar = object$mar.matrix[index, ])
    if (is.null(xc.cond)){
      if (object$factorindex[xname]){
        tmpx <- 1:nlevels(object$Xc.cond[, xname])
        propx <- grconvertX(xclick, "ndc", "user")
        xclickconv <- tmpx[which.min(abs(tmpx - propx))]
        object$Xc.cond[1, xname] <- factor(levels(object$Xc[, xname])[
          xclickconv], levels = levels(object$Xc[, xname]))
      } else {
        xclickconv <- grconvertX(xclick, "ndc", "user")
        object$Xc.cond[1, xname] <- xclickconv
      }
      if (object$factorindex[yname]){
        tmpy <- 1:nlevels(object$Xc.cond[, yname])
        propy <- grconvertY(yclick, "ndc", "user")
        yclickconv <- tmpy[which.min(abs(tmpy - propy))]
        object$Xc.cond[1, yname] <- factor(levels(object$Xc[, yname])[
          yclickconv], levels = levels(object$Xc[, yname]))
      } else {
        yclickconv <- grconvertY(yclick, "ndc", "user")
        object$Xc.cond[1, yname] <- yclickconv
      }
    }
    Xc.cond.num.old <- object$Xc.cond.num
    abline(v = Xc.cond.num.old[xname], h = Xc.cond.num.old[yname], col = "white"
      , lwd = 1.5 * object$select.lwd)
    abline(v = xclickconv, h = yclickconv, lwd = object$select.lwd, col =
      object$select.colour)
    box()
    object$Xc.cond.num[c(xname, yname)] <- c(xclickconv, yclickconv)
    indices <- c(object$cols[index], object$rows[index])
    refreshindex <- which((object$cols %in% indices | object$rows %in%
      indices) & !object$cols == object$rows)
    for (i in seq_along(refreshindex)){
      screen(object$scr2[refreshindex[i]])
      par(usr = object$usr.matrix[refreshindex[i], ])
      par(mar = object$mar.matrix[refreshindex[i], ])
      abline(v = Xc.cond.num.old[object$cols[refreshindex[i]]], h =
        Xc.cond.num.old[object$rows[refreshindex[i]]], col = "white", lwd = 1.5
        * object$select.lwd)
      points(object$Xc.num[, object$cols[refreshindex[i]]], object$Xc.num[,
        object$rows[refreshindex[i]]], cex = object$select.cex)
      abline(v = object$Xc.cond.num[object$cols[refreshindex[i]]], h =
        object$Xc.cond.num[object$rows[refreshindex[i]]], lwd =
        object$select.lwd, col = object$select.colour)
      box()
    }
  }
  object
}

update.xsplot <-
function (object, xc.cond = NULL, weights = NULL, view3d = NULL, theta3d = NULL,
  phi3d = NULL, xs.grid = NULL, prednew = NULL, ...)
{
  if (dev.cur() != object$device)
    dev.set(object$device)
  par(bg = "white")
  screen(n = object$screen, new = FALSE)
  view3d <- if (!is.null(view3d))
    view3d
  else object$view3d
  par(usr = object$usr)
  par(mar = object$mar)
  xc.cond <- if (!is.null(xc.cond))
    xc.cond
  else object$xc.cond
  if (is.null(weights)){
    data.order <- object$data.order
    data.colour <- object$data.colour
  } else {
    if (!identical(length(weights), nrow(object$y)))
      stop("'weights' should be of length equal to number of observations")
    data.colour <- weightcolor(object$col, weights)
    data.order <- attr(data.colour, "order")
  }
  theta3d <- if (!is.null(theta3d))
    theta3d
  else object$theta3d
  phi3d <- if (!is.null(phi3d))
    phi3d
  else object$phi3d
  conf <- object$conf
  if (any(xc.cond != object$xc.cond)){
    object$xc.cond <- xc.cond
    newdata <- makenewdata(xs = object$xs.grid, xc.cond = xc.cond)
    prednew <- lapply(object$model, predict1, newdata = newdata, ylevels = if
      (nlevels(object$y[, 1L]) > 2) levels(object$y[, 1L]) else NULL)
  } else {
    newdata <- object$newdata
    prednew <- object$prednew
  }
  color <- if (is.factor(object$y[, 1L])){
    if (identical(nlevels(object$y[, 1L]), 2L) && inherits(object$model[[1L]],
      "glm")){
      factor2color(as.factor(round(prednew[[1L]])))
    } else factor2color(as.factor(prednew[[1L]]))
  } else cont2color(prednew[[1L]], range(object$y[, 1L]))
  ybg <- if (length(data.order) > 0){
    if (is.factor(object$y[, 1L]))
	    factor2color(object$y[data.order, 1L])
	  else cont2color(object$y[data.order, 1L], range(object$y[, 1L]))
  } else NULL
  arefactorsxs <- vapply(object$xs, is.factor, logical(1L))

  if (identical(object$plot.type, "ff")){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    rect(object$usr[1], object$usr[3], object$usr[2], object$usr[4], col =
      "white", border = NA)
    box()
    if (identical(nlevels(object$y[, 1L]), 2L)){
      if (length(data.order) > 0)
        points.default((as.numeric(object$xs[data.order, 1L])) + rnorm(n =
          length(data.order), sd = 0.1), (as.integer(object$y[data.order, 1L]) -
          1) + rnorm(n = length(data.order), sd = 0.01), col = data.colour[
          data.order], pch = object$pch[data.order])
      for (i in seq_along(object$model)){
        if ("glm" %in% class(object$model[[i]])){
          points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
            object$model.colour[i], lwd = object$model.lwd[i], lty =
            object$model.lty[i])
        } else if (inherits(object$model[[i]], "gbm")){
          points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
            object$model.colour[i], lwd = object$model.lwd[i], lty =
            object$model.lty[i])
        } else {
          points.default(object$xs.grid[, 1L], as.numeric(prednew[[i]]) - 1,
            type = 'l', col = object$model.colour[i], lwd = object$model.lwd[i],
            lty = object$model.lty[i])
        }
      }
    } else {
      if (length(data.order) > 0)
        points(as.numeric(object$xs[data.order, 1L]), as.integer(object$y[
          data.order, 1L]), col = data.colour[data.order], pch = object$pch[
          data.order])
      for (i in seq_along(object$model)){
        points.default(as.numeric(object$xs.grid[, 1L]), as.integer(prednew[[i]]
          ), type = 'l', col = object$model.colour[i], lwd = object$model.lwd[i]
          , lty = object$model.lty[i])
      }
    }
    legend("topright", legend = object$model.name, col = object$model.colour,
      lwd = object$model.lwd, lty = object$model.lty)
    dev.flush()
    object$newdata <- newdata
    object$prednew <- prednew
    return(object)
  } else if (identical(object$plot.type, "cf")){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    rect(object$usr[1], object$usr[3], object$usr[2], object$usr[4], col =
      "white", border = NA)
    box()
    if (length(data.order) > 0)
      points(object$xs[data.order, 1L], object$y[data.order, 1L], col =
        data.colour[data.order], pch = object$pch[data.order])
    if (conf){
      prednew2 <- lapply(object$model, confpred, newdata = newdata)
      for (i in seq_along(object$model)){
        points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
          object$model.colour[i], lwd = object$model.lwd[i], lty =
          object$model.lty[i])
        if (all(c("lwr", "upr") %in% colnames(prednew2[[i]]))){
          points.default(object$xs.grid[, 1L], prednew2[[i]][, "lwr"], type =
            'l', lty = 2, col = object$model.colour[i], lwd = max(0.8, 0.5 *
            object$model.lwd[i]))
          points.default(object$xs.grid[, 1L], prednew2[[i]][, "upr"], type =
            'l', lty = 2, col = object$model.colour[i], lwd = max(0.8, 0.5 *
            object$model.lwd[i]))
        }
      }
    } else {
      for (i in seq_along(object$model)){
        points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
          object$model.colour[i], lwd = object$model.lwd[i], lty =
          object$model.lty[i])
      }
    }
    legend("topright", legend = object$model.name, col = object$model.colour,
      lwd = object$model.lwd, lty = object$model.lty)
    dev.flush()
    object$newdata <- newdata
    object$prednew <- prednew
    return(object)
  } else if (identical(object$plot.type, "fc")){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    rect(object$usr[1], object$usr[3], object$usr[2], object$usr[4], col =
      "white", border = NA)
    box()
    if (identical(nlevels(object$y[, 1L]), 2L)){
      if (length(data.order) > 0)
	      points.default(object$xs[data.order, 1L], as.integer(object$y[data.order
          , 1L]) - 1, col = data.colour[data.order], pch = object$pch[data.order])
      for (i in seq_along(object$model)){
        if ("glm" %in% class(object$model[[i]])){
          points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
            object$model.colour[i], lwd = object$model.lwd[i], lty =
            object$model.lty[i])
        } else if (inherits(object$model[[i]], "gbm")){
          points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
            object$model.colour[i], lwd = object$model.lwd[i], lty =
            object$model.lty[i])
        } else {
          points.default(object$xs.grid[, 1L], as.numeric(prednew[[i]]) - 1,
            type = 'l', col = object$model.colour[i], lwd = object$model.lwd[i],
            lty = object$model.lty[i])
        }
      }
    } else {
      if (length(data.order) > 0)
        points(object$xs[data.order, 1L], as.integer(object$y[data.order, 1L]) ,
          col = data.colour[data.order], pch = object$pch[data.order])
      for (i in seq_along(object$model)){
        points.default(as.numeric(object$xs.grid[, 1L]), as.integer(prednew[[i]]
          ), type = 'l', col = object$model.colour[i], lwd = object$model.lwd[i]
          , lty = object$model.lty[i])
      }
    }
    legend("topright", legend = object$model.name, col = object$model.colour,
      lwd = object$model.lwd, lty = object$model.lty)
    dev.flush()
    object$newdata <- newdata
    object$prednew <- prednew
    return(object)
  } else if (identical(object$plot.type, "cc")){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    rect(object$usr[1], object$usr[3], object$usr[2], object$usr[4], col =
      "white", border = NA)
    box()
    if (length(data.order) > 0)
      points(object$xs[data.order, 1L], object$y[data.order, 1L], col =
        data.colour[data.order], pch = object$pch[data.order])
    for (i in seq_along(object$model)){
      points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
        object$model.colour[i], lwd = object$model.lwd[i], lty =
        object$model.lty[i])
    }
    if (conf){
      prednew2 <- lapply(object$model, confpred, newdata = newdata)
      for (i in seq_along(object$model)){
        points.default(object$xs.grid[, 1L], prednew[[i]], type = 'l', col =
          object$model.colour[i], lwd = object$model.lwd[i], lty =
          object$model.lty[i])
        if (all(c("lwr", "upr") %in% colnames(prednew2[[i]]))){
          points.default(object$xs.grid[, 1L], prednew2[[i]][, "lwr"], type =
            'l', lty = 2, col = object$model.colour[i], lwd = max(0.8, 0.5 *
            object$model.lwd[i]))
          points.default(object$xs.grid[, 1L], prednew2[[i]][, "upr"], type =
            'l', lty = 2, col = object$model.colour[i], lwd = max(0.8, 0.5 *
            object$model.lwd[i]))
        }
      }
    }
    if (is.numeric(object$xs[, 1L])){
      pos <- if (cor(object$xs, object$y) < 0)
        "topright"
      else "bottomright"
      legend(pos, legend = object$model.name, col = object$model.colour, lwd =
        object$model.lwd, lty = object$model.lty)
    } else {
      legend("topright", legend = object$model.name, col = object$model.colour,
        lwd = object$model.lwd, lty = object$model.lty)
    }
    dev.flush()
    object$newdata <- newdata
    object$prednew <- prednew
    return(object)
  } else if (any(vapply(c("fff", "cff"), identical, logical(1), object$plot.type
    ))){
    screen(n = object$screen, new = FALSE)
	  xrect <- as.integer(object$xs.grid[, 1L])
		yrect <- as.integer(object$xs.grid[, 2L])
		xoffset <- abs(diff(unique(xrect)[1:2])) / 2.1
		yoffset <- abs(diff(unique(yrect)[1:2])) / 2.1
    dev.hold()
		rect(xleft = xrect - xoffset, xright = xrect + xoffset, ybottom = yrect -
      yoffset, ytop = yrect + yoffset, col = color)
    if (length(data.order) > 0)
      points(jitter(as.integer(object$xs[data.order, 1L]), amount = 0.6 *
        xoffset), jitter(as.integer(object$xs[data.order, 2L]), amount = 0.6 *
        yoffset), bg = ybg, col = data.colour[data.order], pch = object$pch[data.order])
    dev.flush()
    object$data.colour <- data.colour
    object$data.order <- data.order
    object$newdata <- newdata
    object$prednew <- prednew
    return(object)
  } else if (any(vapply(c("ffc", "cfc"), identical, logical(1), object$plot.type
    ))){
    screen(n = object$screen, new = FALSE)
  	xrect <- object$xs.grid[, !arefactorsxs]
		yrect <- as.integer(object$xs.grid[, arefactorsxs])
		xoffset <- abs(diff(unique(xrect)[1:2])) / 2
		yoffset <- abs(diff(unique(yrect)[1:2])) / 2.1
    dev.hold()
		rect(xleft = xrect - xoffset, xright = xrect + xoffset, ybottom = yrect -
      yoffset, ytop = yrect + yoffset, col = color, border = NA)
    if (length(data.order) > 0)
      points(jitter(object$xs[data.order, !arefactorsxs]), jitter(as.integer(
        object$xs[data.order, arefactorsxs])), bg = ybg, col = data.colour[
        data.order], pch = object$pch[data.order])
    dev.flush()
    object$data.colour <- data.colour
    object$data.order <- data.order
    object$newdata <- newdata
    object$prednew <- prednew
    return(object)
  } else if (any(vapply(c("fcc", "ccc"), identical, logical(1), object$plot.type
    ))){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    if (object$view3d & identical(object$plot.type, "ccc")){
      screen(n = object$screen, new = TRUE)
      z <- matrix(prednew[[1L]], ncol = 20L, byrow = FALSE)
      zfacet <- (z[-1, -1] + z[-1, -ncol(z)] + z[-nrow(z), -1] + z[-nrow(z),
        -ncol(z)]) / 4
      colorfacet <- cont2color(zfacet, range(object$y[, 1L]))
      par(mar = c(3, 3, 3, 3))
      persp.object <- suppressWarnings(persp(x = unique(object$xs.grid[, 1L]), y
        = unique(object$xs.grid[, 2L]), border = rgb(0.3, 0.3, 0.3), lwd = 0.1,
        z = z, col = colorfacet, zlim = range(object$y), xlab = colnames(
        object$xs)[1L], ylab = colnames(object$xs)[2L], zlab = colnames(
        object$y)[1L], d = 10, ticktype = "detailed", main =
        "Conditional expectation", theta = theta3d, phi = phi3d))
      if (length(data.order) > 0){
        points(trans3d(object$xs[data.order, 1L], object$xs[data.order, 2L],
          object$y[data.order, 1L], pmat = persp.object), col = data.colour[
          data.order], pch = object$pch[data.order])
        linestarts <- trans3d(object$xs[data.order, 1L], object$xs[data.order,
          2L], object$y[data.order, 1L], pmat = persp.object)
        lineends <- trans3d(object$xs[data.order, 1L], object$xs[data.order, 2L]
          , object$yhat[[1]][data.order], pmat = persp.object)
        segments(x0 = linestarts$x, y0 = linestarts$y, x1 = lineends$x, y1 =
          lineends$y, col = data.colour[data.order])
      }
      object$data.colour <- data.colour
      object$data.order <- data.order
      object$theta3d <- theta3d
      object$phi3d <- phi3d
    } else {
      if(object$probs){
        corners <- par()$usr
        rect(corners[1], corners[3], corners[2], corners[4], col = "white")
        pred <- predict1(object$model[[1L]], newdata = newdata, probability =
          TRUE, ylevels = levels(object$y[, 1L]))
        p1 <- extractprobs(object$model[[1L]], pred)
        totalwidth <- abs(diff(corners[1:2]))
        totalheight <- abs(diff(corners[3:4]))
        o1 <- apply(cbind(object$xs.grid, p1), 1, function (x) myglyph2(
          x[1], x[2], 0.6 * totalwidth / 15, 0.6 * totalheight / 15,
          x[3:(2 + ncol(p1))], factor2color(as.factor(levels(object$y[, 1L]
          )))))
        o2 <- matrix(t(o1), ncol = 5, byrow = FALSE)
        rect(xleft = o2[, 1], xright = o2[, 2], ybottom = o2[, 3], ytop =
          o2[, 4], col = factor2color(as.factor(levels(object$y[, 1L])))[
          o2[, 5]])
        box()
      } else {
        xoffset <- abs(diff(unique(object$xs.grid[, 1L])[1:2])) / 2
        yoffset <- abs(diff(unique(object$xs.grid[, 2L])[1:2])) / 2
        rect(xleft = object$xs.grid[, 1L] - xoffset, xright = object$xs.grid[,
          1L] + xoffset, ybottom = object$xs.grid[, 2L] - yoffset, ytop =
          object$xs.grid[, 2L] + yoffset, col = color, border = NA)
        if (length(data.order) > 0)
          points(object$xs[data.order, , drop = FALSE], bg = ybg, col =
            data.colour[data.order], pch = object$pch[data.order])
      }
    }
    dev.flush()
    object$newdata <- newdata
    object$prednew <- prednew
    object$xc.cond <- xc.cond
    return(object)
  } else if (identical(object$plot.type, "residuals")){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    rect(object$usr[1], object$usr[3], object$usr[2], object$usr[4], col =
      "white", border = NA)
    abline(v = unlist(prednew), col = object$model.colour, lwd =
      object$model.lwd, lty = object$model.lty)
    legend("topright", legend = object$model.name, col = object$model.colour,
      lwd = object$model.lwd, lty = object$model.lty)
    box()
    dev.flush()
  } else stop("unrecognised plotxs type to update")
  object
}

update.xsresplot <-
function (object, xc.cond = NULL, data.colour = NULL, data.order = NULL,
  view3d = NULL, theta3d = NULL, phi3d = NULL, xs.grid = NULL, prednew = NULL,
  ...)
{
  if (dev.cur() != object$device)
    dev.set(object$device)
  par(bg = "white")
  screen(n = object$screen, new = FALSE)
  view3d <- if (!is.null(view3d))
    view3d
  else object$view3d
  par(usr = object$usr)
  par(mar = object$mar)
  xc.cond <- if (!is.null(xc.cond))
    xc.cond
  else object$xc.cond
  data.colour <- if (!is.null(data.colour))
    data.colour
  else object$data.colour
  data.order <- if (!is.null(data.order))
    data.order
  else object$data.order
  theta3d <- if (!is.null(theta3d))
    theta3d
  else object$theta3d
  phi3d <- if (!is.null(phi3d))
    phi3d
  else object$phi3d
  conf <- object$conf

  if (object$plot.type %in% c("cc")){
    screen(n = object$screen, new = FALSE)
    dev.hold()
    rect(object$usr[1], object$usr[3], object$usr[2], object$usr[4], col =
      "white", border = NA)
    box()
    abline(h = 0, lty = 3)
    if (length(data.order) > 0){
      for (i in 1){
        points(object$xs[data.order, 1L], object$residuals[[i]][data.order], col
          = data.colour[data.order], pch = object$pch[data.order])
      }
    }
  }
  dev.flush()
  object$xc.cond <- xc.cond
  return(object)
}
